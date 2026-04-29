// MapToMessage.swift
//
// Copyright (c) 2017-present ArcBlock Foundation Ltd <https://www.arcblock.io/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

import Foundation
import BigInt
import SwiftProtobuf

/// Schema-driven `[Int: CBORValue]` → protobuf wire-format bytes bridge.
///
/// Strategy: walk the schema (`FieldResolver.fieldsForMessage`) and the CBOR
/// pair list in parallel, emitting the corresponding wire-format bytes
/// (varint / fixed32 / fixed64 / length-delim) one field at a time. The
/// resulting `Data` is fed to `try MessageType(serializedData: bytes)` to
/// land a concrete SwiftProtobuf-typed value.
///
/// Mirrors Kotlin `MapToTransaction` but works on `CBORValue` directly
/// rather than parsing CBOR bytes, since canonical-cbor's outer
/// encode/decode is a separate concern (handled by `CBOREncoder` /
/// `CBORDecoder`).
public enum MapToMessage {

    /// Top-level: convert a `CBORValue.map` to wire bytes that
    /// `MessageType(serializedData:)` will accept. The `messageName` is
    /// the OCAP schema name (`"Transaction"`, etc.).
    public static func encodeToWireBytes(
        messageName: String,
        cborMap: CBORValue
    ) throws -> Data {
        guard case let .map(pairs) = cborMap else {
            throw CanonicalCBORError.typeMismatch(
                "MapToMessage: expected CBOR map, got \(cborMap)"
            )
        }
        return try buildWireBytes(messageName: messageName, pairs: pairs)
    }

    /// Internal: build wire bytes from an unwrapped pair list.
    static func buildWireBytes(messageName: String, pairs: [CBORMapPair]) throws -> Data {
        guard let descriptor = FieldResolver.messageDescriptor(messageName) else {
            throw CanonicalCBORError.message(
                "MapToMessage: unknown message type \"\(messageName)\""
            )
        }
        var fieldsById: [Int: FieldResolver.FieldInfo] = [:]
        for f in descriptor.fields { fieldsById[f.id] = f }

        // Stable order: ascending field id — protobuf doesn't require it but
        // keeps wire bytes deterministic for tests.
        let sortedPairs = pairs.compactMap { pair -> (Int, CBORValue)? in
            guard case let .unsigned(k) = pair.key else { return nil }
            guard let id = Int(exactly: k) else { return nil }
            return (id, pair.value)
        }.sorted { $0.0 < $1.0 }

        var out = Data()
        for (fieldId, value) in sortedPairs {
            guard let fieldInfo = fieldsById[fieldId] else {
                // Unknown field: skip silently — preserves forward-compat.
                continue
            }
            try emitField(fieldInfo: fieldInfo, value: value, into: &out)
        }
        return out
    }

    // MARK: - Per-field emit

    static func emitField(
        fieldInfo: FieldResolver.FieldInfo,
        value: CBORValue,
        into out: inout Data
    ) throws {
        let typeName = fieldInfo.type
        let fieldId = fieldInfo.id

        if fieldInfo.repeated {
            guard case let .array(elems) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "repeated field \"\(fieldInfo.name)\" expected CBOR array"
                )
            }
            // Packing applies only to scalar numeric / bool / enum types. The
            // canonical-cbor JS reference does NOT pack repeated scalars — it
            // emits each one with its own tag — and since the `*.cbor.bin`
            // fixtures were produced by that pipeline, we mirror the
            // unpacked emission to keep cross-encoder bytes aligned.
            for elem in elems {
                try emitSingle(
                    fieldId: fieldId,
                    typeName: typeName,
                    value: elem,
                    into: &out
                )
            }
            return
        }
        try emitSingle(
            fieldId: fieldId,
            typeName: typeName,
            value: value,
            into: &out
        )
    }

    static func emitSingle(
        fieldId: Int,
        typeName: String,
        value: CBORValue,
        into out: inout Data
    ) throws {
        // Scalars
        if let scalar = Scalars.ScalarType.from(typeName: typeName) {
            try emitScalar(fieldId: fieldId, scalar: scalar, value: value, into: &out)
            return
        }
        // Enum (varint)
        if FieldResolver.isEnumType(typeName) {
            let n = try cborToUInt64(value)
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(n, into: &out)
            return
        }
        // BigUint / BigSint wrapper — accept the tagged-bignum and reverse
        // it into the wrapper's wire shape.
        if typeName == "BigUint" || typeName == "BigSint" {
            let inner = try buildBigIntWrapperWire(typeName: typeName, value: value)
            writeTag(fieldId: fieldId, wireType: 2, into: &out)
            writeVarint(UInt64(inner.count), into: &out)
            out.append(inner)
            return
        }
        // Timestamp — accept ISO-8601 string, reverse to wire bytes.
        if typeName == "google.protobuf.Timestamp" || typeName == "Timestamp" {
            guard case let .text(iso) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "Timestamp field expected ISO-8601 text, got \(value)"
                )
            }
            let inner = try buildTimestampWire(iso: iso)
            writeTag(fieldId: fieldId, wireType: 2, into: &out)
            writeVarint(UInt64(inner.count), into: &out)
            out.append(inner)
            return
        }
        // Any — reverse the flat `{0: typeUrl, ...inner}` form to a
        // protobuf Any (`type_url = 1`, `value = 2`).
        if typeName == "google.protobuf.Any" || typeName == "Any" {
            let inner = try buildAnyWire(value: value)
            writeTag(fieldId: fieldId, wireType: 2, into: &out)
            writeVarint(UInt64(inner.count), into: &out)
            out.append(inner)
            return
        }
        // Plain nested message — recurse.
        guard case let .map(innerPairs) = value else {
            throw CanonicalCBORError.typeMismatch(
                "nested message \(typeName) expected CBOR map, got \(value)"
            )
        }
        let inner = try buildWireBytes(messageName: typeName, pairs: innerPairs)
        writeTag(fieldId: fieldId, wireType: 2, into: &out)
        writeVarint(UInt64(inner.count), into: &out)
        out.append(inner)
    }

    // MARK: - Scalar emit

    static func emitScalar(
        fieldId: Int,
        scalar: Scalars.ScalarType,
        value: CBORValue,
        into out: inout Data
    ) throws {
        switch scalar {
        case .int32, .int64:
            // Signed varint: negative values are sign-extended to 64 bits.
            let n: UInt64
            switch value {
            case let .unsigned(u): n = u
            case let .negative(s): n = UInt64(bitPattern: s)
            default:
                throw CanonicalCBORError.typeMismatch(
                    "int field expected integer, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(n, into: &out)
        case .uint32, .uint64:
            let n: UInt64
            switch value {
            case let .unsigned(u): n = u
            case let .negative(s): n = UInt64(bitPattern: s)
            default:
                throw CanonicalCBORError.typeMismatch(
                    "uint field expected unsigned integer, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(n, into: &out)
        case .sint32, .sint64:
            let signed = try cborToInt64(value)
            let zigzag: UInt64
            if signed >= 0 {
                zigzag = UInt64(signed) << 1
            } else {
                // Standard zigzag: ((n << 1) ^ (n >> 63)) for 64-bit.
                zigzag = UInt64(bitPattern: (signed << 1) ^ (signed >> 63))
            }
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(zigzag, into: &out)
        case .fixed32:
            let n = try cborToUInt64(value)
            writeTag(fieldId: fieldId, wireType: 5, into: &out)
            writeFixed32(UInt32(truncatingIfNeeded: n), into: &out)
        case .fixed64:
            let n = try cborToUInt64(value)
            writeTag(fieldId: fieldId, wireType: 1, into: &out)
            writeFixed64(n, into: &out)
        case .sfixed32:
            let signed = Int32(truncatingIfNeeded: try cborToInt64(value))
            writeTag(fieldId: fieldId, wireType: 5, into: &out)
            writeFixed32(UInt32(bitPattern: signed), into: &out)
        case .sfixed64:
            let signed = try cborToInt64(value)
            writeTag(fieldId: fieldId, wireType: 1, into: &out)
            writeFixed64(UInt64(bitPattern: signed), into: &out)
        case .float:
            guard case let .float32(f) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "float field expected float32, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 5, into: &out)
            writeFixed32(f.bitPattern, into: &out)
        case .double:
            guard case let .float64(d) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "double field expected float64, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 1, into: &out)
            writeFixed64(d.bitPattern, into: &out)
        case .bool:
            let b: Bool
            switch value {
            case let .bool(x): b = x
            case let .unsigned(n): b = n != 0
            default:
                throw CanonicalCBORError.typeMismatch(
                    "bool field expected bool, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(b ? 1 : 0, into: &out)
        case .string:
            guard case let .text(s) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "string field expected text, got \(value)"
                )
            }
            let utf8 = Data(s.utf8)
            writeTag(fieldId: fieldId, wireType: 2, into: &out)
            writeVarint(UInt64(utf8.count), into: &out)
            out.append(utf8)
        case .bytes:
            guard case let .bytes(b) = value else {
                throw CanonicalCBORError.typeMismatch(
                    "bytes field expected bytes, got \(value)"
                )
            }
            writeTag(fieldId: fieldId, wireType: 2, into: &out)
            writeVarint(UInt64(b.count), into: &out)
            out.append(b)
        case .enum:
            let n = try cborToUInt64(value)
            writeTag(fieldId: fieldId, wireType: 0, into: &out)
            writeVarint(n, into: &out)
        }
    }

    // MARK: - BigUint / BigSint wrapper

    /// Build the protobuf wire bytes for a `BigUint` / `BigSint` wrapper
    /// from a tagged-bignum CBORValue. Accepts:
    ///  - `.tagged(2, .bytes(magnitude))` → BigUint
    ///  - `.tagged(3, .bytes(magnitude))` → BigSint with minus = true
    ///  - `.bigUnsigned(BigUInt)` / `.bigSigned(BigInt)` → typed equivalents
    ///  - `.unsigned(n)` → BigUint(n) (the JS pipeline emits small magnitudes
    ///    as plain unsigned ints when they fit in 1-8 bytes; we accept it
    ///    so cross-encoder fixtures parse).
    static func buildBigIntWrapperWire(typeName: String, value: CBORValue) throws -> Data {
        var magnitude = Data()
        var minus = false

        switch value {
        case let .tagged(tag, inner):
            guard case let .bytes(bytes) = inner else {
                throw CanonicalCBORError.typeMismatch(
                    "\(typeName) tagged inner must be bytes"
                )
            }
            magnitude = bytes
            if tag == CanonicalCBORConstants.tagNegativeBignum {
                minus = true
            } else if tag != CanonicalCBORConstants.tagPositiveBignum {
                throw CanonicalCBORError.unexpectedBignumTag(tag)
            }
        case let .bigUnsigned(big):
            magnitude = BigIntCodec.magnitudeBytes(big)
        case let .bigSigned(big):
            magnitude = BigIntCodec.magnitudeBytes(big)
            minus = big.signum() < 0
        case let .unsigned(n):
            magnitude = uint64ToMinimalBytes(n)
        case let .negative(s):
            // Treat the raw negative as a magnitude-with-flag.
            // RFC 8949 negative .negative(s) encodes -1 - s, but for
            // wallet-side BigSint inputs we expect tag(3,...) form.
            // Defensive: convert the magnitude to bytes.
            let mag = UInt64(bitPattern: -s - 1)
            magnitude = uint64ToMinimalBytes(mag)
            minus = true
        default:
            throw CanonicalCBORError.typeMismatch(
                "\(typeName) expected tagged-bignum or integer, got \(value)"
            )
        }

        // Strip leading zeros in the magnitude (BigUint canonical form).
        if !magnitude.isEmpty {
            var start = 0
            while start < magnitude.count - 1 && magnitude[magnitude.startIndex + start] == 0 {
                start += 1
            }
            if start > 0 {
                magnitude = magnitude.subdata(
                    in: (magnitude.startIndex + start)..<magnitude.endIndex
                )
            }
        }

        // Wrapper wire: field 1 = bytes magnitude (always present, even for
        // magnitude == 0 which is an empty byte string per OCAP convention).
        var inner = Data()
        // Field 1 (bytes value)
        // Per Kotlin reference: even a zero-magnitude wrapper writes the
        // empty byte string under field 1. But ALSO per the OCAP zero-fold
        // rule, a zero-magnitude BigUint at the parent-field level is meant
        // to be omitted entirely. The omission decision lives one layer up
        // in MessageToMap.buildMap (sentinel `.null`). At THIS layer (wire
        // emit) the caller has already decided to write the wrapper, so we
        // emit the magnitude bytes verbatim (might be empty).
        writeTag(fieldId: 1, wireType: 2, into: &inner)
        writeVarint(UInt64(magnitude.count), into: &inner)
        inner.append(magnitude)
        if typeName == "BigSint" && minus {
            writeTag(fieldId: 2, wireType: 0, into: &inner)
            writeVarint(1, into: &inner)
        }
        return inner
    }

    static func uint64ToMinimalBytes(_ n: UInt64) -> Data {
        if n == 0 { return Data() }
        var bytes = [UInt8]()
        var v = n
        while v > 0 {
            bytes.insert(UInt8(v & 0xff), at: 0)
            v >>= 8
        }
        return Data(bytes)
    }

    // MARK: - Timestamp

    /// Parse an RFC-3339 ISO-8601 string into wire bytes for
    /// `google.protobuf.Timestamp` (`int64 seconds = 1; int32 nanos = 2;`).
    /// Lenient about fractional length and trailing zeros.
    static func buildTimestampWire(iso: String) throws -> Data {
        let (seconds, nanos) = try parseISO8601(iso)
        var out = Data()
        if seconds != 0 {
            writeTag(fieldId: 1, wireType: 0, into: &out)
            writeVarint(UInt64(bitPattern: seconds), into: &out)
        }
        if nanos != 0 {
            writeTag(fieldId: 2, wireType: 0, into: &out)
            writeVarint(UInt64(bitPattern: Int64(nanos)), into: &out)
        }
        return out
    }

    /// Parse an RFC-3339 timestamp into `(seconds, nanos)`. Accepts:
    ///  - `YYYY-MM-DDTHH:MM:SSZ`
    ///  - `YYYY-MM-DDTHH:MM:SS.fffZ` (1-9 fractional digits)
    ///  - `YYYY-MM-DDTHH:MM:SS+HH:MM` / `-HH:MM` (offsets)
    static func parseISO8601(_ s: String) throws -> (seconds: Int64, nanos: Int32) {
        // Manual parser — `DateFormatter` doesn't handle 9-digit fractional
        // and ISO8601DateFormatter limits to milliseconds.
        guard s.count >= 20 else {
            throw CanonicalCBORError.malformedCBOR("timestamp too short: \(s)")
        }
        let chars = Array(s)
        func readInt(_ start: Int, _ length: Int) -> Int? {
            guard start + length <= chars.count else { return nil }
            let str = String(chars[start..<(start + length)])
            return Int(str)
        }
        guard
            chars[4] == "-",
            chars[7] == "-",
            chars[10] == "T" || chars[10] == "t",
            chars[13] == ":",
            chars[16] == ":",
            let year = readInt(0, 4),
            let month = readInt(5, 2),
            let day = readInt(8, 2),
            let hour = readInt(11, 2),
            let minute = readInt(14, 2),
            let second = readInt(17, 2)
        else {
            throw CanonicalCBORError.malformedCBOR("invalid ISO-8601 layout: \(s)")
        }

        var pos = 19
        var nanos: Int32 = 0
        if pos < chars.count && chars[pos] == "." {
            pos += 1
            var fracDigits = ""
            while pos < chars.count && chars[pos].isNumber {
                fracDigits.append(chars[pos])
                pos += 1
            }
            // Right-pad to 9 digits, then truncate (clip extra digits).
            if fracDigits.count > 9 {
                fracDigits = String(fracDigits.prefix(9))
            } else {
                fracDigits += String(repeating: "0", count: 9 - fracDigits.count)
            }
            nanos = Int32(fracDigits) ?? 0
        }

        // Offset
        var offsetSeconds: Int = 0
        if pos < chars.count {
            let c = chars[pos]
            if c == "Z" || c == "z" {
                pos += 1
            } else if c == "+" || c == "-" {
                let sign = c == "+" ? 1 : -1
                guard pos + 6 <= chars.count, chars[pos + 3] == ":" else {
                    throw CanonicalCBORError.malformedCBOR(
                        "invalid timestamp offset: \(s)"
                    )
                }
                guard
                    let oh = readInt(pos + 1, 2),
                    let om = readInt(pos + 4, 2)
                else {
                    throw CanonicalCBORError.malformedCBOR(
                        "invalid timestamp offset numbers: \(s)"
                    )
                }
                offsetSeconds = sign * (oh * 3600 + om * 60)
                pos += 6
            }
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = second
        guard let date = calendar.date(from: comps) else {
            throw CanonicalCBORError.malformedCBOR("ISO-8601 not a real date: \(s)")
        }
        let seconds = Int64(date.timeIntervalSince1970) - Int64(offsetSeconds)
        return (seconds, nanos)
    }

    // MARK: - Any

    /// Build wire bytes for `google.protobuf.Any` from the canonical-CBOR
    /// flat shape `{0: typeUrl, ...innerFieldIds...}`.
    static func buildAnyWire(value: CBORValue) throws -> Data {
        guard case let .map(pairs) = value else {
            throw CanonicalCBORError.typeMismatch(
                "Any field expected CBOR map, got \(value)"
            )
        }
        var typeUrl = ""
        var innerPairs: [CBORMapPair] = []
        for pair in pairs {
            if case .unsigned(0) = pair.key {
                guard case let .text(s) = pair.value else {
                    throw CanonicalCBORError.typeMismatch(
                        "Any.typeUrl (key 0) must be text"
                    )
                }
                typeUrl = s
            } else {
                innerPairs.append(pair)
            }
        }
        if typeUrl.isEmpty {
            // Empty Any — emit empty wire bytes.
            return Data()
        }

        // Look up the inner message name. Phase 3 supports KNOWN typeUrls
        // only — explicit fail on unknown.
        let messageName = FieldResolver.fromTypeUrl(typeUrl)
        guard FieldResolver.fieldsForMessage(messageName) != nil else {
            throw CanonicalCBORError.unknownTypeUrl(typeUrl)
        }
        let innerWire = try buildWireBytes(messageName: messageName, pairs: innerPairs)

        var out = Data()
        // Field 1: type_url (string)
        let urlBytes = Data(typeUrl.utf8)
        writeTag(fieldId: 1, wireType: 2, into: &out)
        writeVarint(UInt64(urlBytes.count), into: &out)
        out.append(urlBytes)
        // Field 2: value (bytes)
        writeTag(fieldId: 2, wireType: 2, into: &out)
        writeVarint(UInt64(innerWire.count), into: &out)
        out.append(innerWire)
        return out
    }

    // MARK: - Wire-format writers

    static func writeTag(fieldId: Int, wireType: UInt8, into out: inout Data) {
        let tag = (UInt64(fieldId) << 3) | UInt64(wireType)
        writeVarint(tag, into: &out)
    }

    static func writeVarint(_ value: UInt64, into out: inout Data) {
        var v = value
        while v >= 0x80 {
            out.append(UInt8((v & 0x7f) | 0x80))
            v >>= 7
        }
        out.append(UInt8(v & 0x7f))
    }

    static func writeFixed32(_ value: UInt32, into out: inout Data) {
        for i in 0..<4 {
            out.append(UInt8((value >> UInt32(i * 8)) & 0xff))
        }
    }

    static func writeFixed64(_ value: UInt64, into out: inout Data) {
        for i in 0..<8 {
            out.append(UInt8((value >> UInt64(i * 8)) & 0xff))
        }
    }

    // MARK: - CBORValue → integer coercion

    static func cborToUInt64(_ value: CBORValue) throws -> UInt64 {
        switch value {
        case let .unsigned(n): return n
        case let .negative(s): return UInt64(bitPattern: s)
        default:
            throw CanonicalCBORError.typeMismatch(
                "expected integer, got \(value)"
            )
        }
    }

    static func cborToInt64(_ value: CBORValue) throws -> Int64 {
        switch value {
        case let .unsigned(n):
            guard let s = Int64(exactly: n) else {
                throw CanonicalCBORError.valueOutOfRange(
                    "value \(n) out of Int64 range"
                )
            }
            return s
        case let .negative(s): return s
        default:
            throw CanonicalCBORError.typeMismatch(
                "expected integer, got \(value)"
            )
        }
    }
}
