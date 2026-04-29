// MessageToMap.swift
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

/// Schema-driven Message → `[Int: CBORValue]` bridge.
///
/// Strategy: serialize the message to protobuf bytes via SwiftProtobuf, then
/// walk those wire bytes against the schema (`FieldResolver`) to build a
/// CBOR map. This sidesteps SwiftProtobuf's `Visitor` protocol surface (40+
/// callbacks) at the cost of one extra serialize/parse pass — perfectly
/// acceptable for wallet hash sites that only run a few times per second.
///
/// Mirrors Kotlin `TransactionToMap.messageToMap` but staying schema-driven
/// rather than reflection-driven (the schema descriptor *is* our reflection
/// surface).
///
/// Reverse direction (`CBORValue` → wire bytes) lives in `MapToMessage.swift`.
/// The shared protobuf wire-format primitives (`WireReader`, varint/fixed/tag
/// writers) live in `WireFormat.swift` so the two halves agree byte-for-byte.
public enum MessageToMap {

    /// Top-level: convert any `SwiftProtobuf.Message` to a `CBORValue`
    /// suitable for `CBOREncoder.encodeTopLevel(_:)`. The `messageName` is
    /// the OCAP schema name (`"Transaction"`, `"TransferV2Tx"`, …) — pulled
    /// from `protoMessageName` after stripping the `ocap.` package prefix.
    ///
    /// Special-cases that bypass schema lookup (the schema does not include
    /// google.protobuf.* types):
    ///  - `google.protobuf.Timestamp` → ISO-8601 text
    ///  - `google.protobuf.Any`       → flat `{0: typeUrl, …inner…}` map
    ///  - OCAP `BigUint` / `BigSint`  → tagged-bignum (or `.null` sentinel
    ///    when zero-magnitude — top-level callers never see this case
    ///    because zero-magnitude wrapper messages aren't a valid root).
    public static func encode(_ message: SwiftProtobuf.Message) throws -> CBORValue {
        let messageName = ocapName(of: type(of: message))
        let bytes = try message.serializedData()
        // Top-level google.protobuf.* special-cases:
        switch messageName {
        case "google.protobuf.Timestamp", "Timestamp":
            let (seconds, nanos) = try decodeTimestampWire(bytes)
            return .text(formatISO8601(seconds: seconds, nanos: nanos))
        case "google.protobuf.Any", "Any":
            return try decodeAnyWire(bytes)
        case "BigUint", "BigSint":
            return try decodeBigIntWrapper(typeName: messageName, wireBytes: bytes)
        default:
            let pairs = try buildMap(messageName: messageName, wireBytes: bytes)
            return .map(pairs)
        }
    }

    /// Strip the `ocap.` package prefix from `protoMessageName` so the
    /// schema lookup works. SwiftProtobuf-generated `Ocap_Foo` types declare
    /// `protoMessageName = "ocap.Foo"`.
    static func ocapName(of type: SwiftProtobuf.Message.Type) -> String {
        let full = type.protoMessageName
        if full.hasPrefix("ocap.") {
            return String(full.dropFirst("ocap.".count))
        }
        if full.hasPrefix("google.protobuf.") {
            return full // Any / Timestamp handled by callers
        }
        return full
    }

    /// Build the canonical-CBOR pair list from protobuf wire bytes. Field
    /// ids that don't appear in `wireBytes` are omitted — proto3 zero-fold
    /// is implicit because SwiftProtobuf's encoder already drops them.
    static func buildMap(messageName: String, wireBytes: Data) throws -> [CBORMapPair] {
        // Special-case the BigUint / BigSint wrapper types: the canonical
        // form is the tagged-bignum directly, not a CBOR map. But this
        // function returns a list of pairs (the parent map's contents) —
        // BigUint is converted at field-encoding time in `encodeFieldValue`
        // below, so we never get here for top-level wrappers.

        guard let descriptor = FieldResolver.messageDescriptor(messageName) else {
            throw CanonicalCBORError.message(
                "MessageToMap: unknown message type \"\(messageName)\""
            )
        }

        // Index schema by field id for quick lookup as we walk wire bytes.
        var fieldsById: [Int: FieldResolver.FieldInfo] = [:]
        for f in descriptor.fields { fieldsById[f.id] = f }

        // Accumulator: collect one or many per-field encoded `CBORValue`s,
        // then assemble the final pair list per schema field id (sorted).
        // For repeated fields we accumulate the per-element values and emit
        // a single `.array(...)` at the end.
        var collected: [Int: [CBORValue]] = [:]
        var collectedSingle: [Int: CBORValue] = [:]

        var reader = WireReader(data: wireBytes)
        while !reader.isAtEnd {
            let (fieldId, wireType) = try reader.readTag()
            guard let fieldInfo = fieldsById[fieldId] else {
                // Unknown field: skip according to wire type.
                try reader.skipField(wireType: wireType)
                continue
            }
            let value = try decodeWireValue(
                fieldInfo: fieldInfo,
                wireType: wireType,
                reader: &reader
            )
            if fieldInfo.repeated {
                if case let .array(elems) = value {
                    // Packed repeated scalar — append all.
                    collected[fieldId, default: []].append(contentsOf: elems)
                } else {
                    collected[fieldId, default: []].append(value)
                }
            } else {
                collectedSingle[fieldId] = value
            }
        }

        // Build pair list in ascending field id order. Canonical CBOR
        // re-sorts keys at byte-encode time, but this gives a stable
        // intermediate shape useful for diagnostics.
        var pairs: [CBORMapPair] = []
        let allIds = Set(collected.keys).union(collectedSingle.keys)
        for id in allIds.sorted() {
            if let arr = collected[id] {
                if arr.isEmpty { continue }
                pairs.append(CBORMapPair(
                    key: .unsigned(UInt64(id)),
                    value: .array(arr)
                ))
            } else if let v = collectedSingle[id] {
                // BigUint-omit propagation: a zero-magnitude BigUint
                // returns `.null` from `decodeWireValue`, which we drop
                // here so the parent map omits the field.
                if case .null = v {
                    // Sentinel for "omit me"
                    continue
                }
                pairs.append(CBORMapPair(key: .unsigned(UInt64(id)), value: v))
            }
        }
        return pairs
    }

    /// Decode a single wire value for the given schema field. For repeated
    /// scalar fields with packed wire encoding (length-delimited), returns
    /// `.array([...])` — caller flattens.
    static func decodeWireValue(
        fieldInfo: FieldResolver.FieldInfo,
        wireType: UInt8,
        reader: inout WireReader
    ) throws -> CBORValue {
        let typeName = fieldInfo.type

        // Bytes / string / message / packed-repeated all use length-delim.
        // Non-message scalars take their wire type from the proto3 spec —
        // we trust the wire type matches the schema (SwiftProtobuf's
        // serialize honors it).

        // Handle scalar types first.
        if let scalar = Scalars.ScalarType.from(typeName: typeName) {
            return try decodeScalarWire(
                scalar: scalar,
                wireType: wireType,
                fieldInfo: fieldInfo,
                reader: &reader
            )
        }

        // Enum is a varint.
        if FieldResolver.isEnumType(typeName) {
            // Packed repeated enum is length-delim; non-packed uses varint.
            if fieldInfo.repeated && wireType == 2 {
                let length = try reader.readVarintAsInt()
                let endIdx = reader.idx + length
                var elems: [CBORValue] = []
                while reader.idx < endIdx {
                    let n = try reader.readVarint()
                    elems.append(uintToCBOR(n))
                }
                return .array(elems)
            }
            let n = try reader.readVarint()
            return uintToCBOR(n)
        }

        // BigUint / BigSint wrapper messages — emit tagged-bignum directly.
        if typeName == "BigUint" || typeName == "BigSint" {
            let inner = try reader.readLengthDelimited()
            return try decodeBigIntWrapper(typeName: typeName, wireBytes: inner)
        }

        // google.protobuf.Timestamp → ISO-8601 string.
        if typeName == "google.protobuf.Timestamp" || typeName == "Timestamp" {
            let inner = try reader.readLengthDelimited()
            let (seconds, nanos) = try decodeTimestampWire(inner)
            return .text(formatISO8601(seconds: seconds, nanos: nanos))
        }

        // google.protobuf.Any → flat `{0: typeUrl, ...innerFields}` map.
        if typeName == "google.protobuf.Any" || typeName == "Any" {
            let inner = try reader.readLengthDelimited()
            return try decodeAnyWire(inner)
        }

        // Plain nested message — recurse.
        let inner = try reader.readLengthDelimited()
        let pairs = try buildMap(messageName: typeName, wireBytes: inner)
        return .map(pairs)
    }

    // MARK: - Scalar wire decode

    static func decodeScalarWire(
        scalar: Scalars.ScalarType,
        wireType: UInt8,
        fieldInfo: FieldResolver.FieldInfo,
        reader: inout WireReader
    ) throws -> CBORValue {
        // Packed repeated scalar uses length-delim wire type 2.
        // Packed-repeated wire format only applies to scalar numeric/bool types.
        if fieldInfo.repeated && wireType == 2 && (scalar.isInt || scalar.isFloat || scalar == .bool) {
            let length = try reader.readVarintAsInt()
            let endIdx = reader.idx + length
            var elems: [CBORValue] = []
            while reader.idx < endIdx {
                let v = try decodeSingleScalar(scalar: scalar, reader: &reader,
                                               nestedWireType: scalar.isFloat ?
                                                (scalar == .float ? 5 : 1) : 0)
                elems.append(v)
            }
            return .array(elems)
        }
        return try decodeSingleScalar(scalar: scalar, reader: &reader,
                                      nestedWireType: wireType)
    }

    /// Decode a single scalar at the current reader position. `wireType` is
    /// what the tag indicated; for packed-repeated paths the caller passes
    /// the per-element wire type derived from the scalar.
    static func decodeSingleScalar(
        scalar: Scalars.ScalarType,
        reader: inout WireReader,
        nestedWireType: UInt8
    ) throws -> CBORValue {
        switch scalar {
        case .int32, .int64, .uint32, .uint64:
            let n = try reader.readVarint()
            // For int32/int64, negative wire values come through as large
            // UInt64 (sign-extended). Detect and emit `.negative`.
            if scalar == .int32 || scalar == .int64 {
                let signed = Int64(bitPattern: n)
                if signed < 0 { return .negative(signed) }
                return .unsigned(n)
            }
            return .unsigned(n)
        case .sint32, .sint64:
            let raw = try reader.readVarint()
            let zigzag = Int64(bitPattern: (raw >> 1) ^ (~(raw & 1) &+ 1))
            if zigzag < 0 { return .negative(zigzag) }
            return .unsigned(UInt64(zigzag))
        case .fixed32:
            let n = try reader.readFixed32()
            return .unsigned(UInt64(n))
        case .fixed64:
            let n = try reader.readFixed64()
            return .unsigned(n)
        case .sfixed32:
            let n = try reader.readFixed32()
            let signed = Int32(bitPattern: n)
            if signed < 0 { return .negative(Int64(signed)) }
            return .unsigned(UInt64(signed))
        case .sfixed64:
            let n = try reader.readFixed64()
            let signed = Int64(bitPattern: n)
            if signed < 0 { return .negative(signed) }
            return .unsigned(UInt64(signed))
        case .float:
            let bits = try reader.readFixed32()
            return .float32(Float(bitPattern: bits))
        case .double:
            let bits = try reader.readFixed64()
            return .float64(Double(bitPattern: bits))
        case .bool:
            let n = try reader.readVarint()
            return .bool(n != 0)
        case .string:
            let bytes = try reader.readLengthDelimited()
            guard let s = String(data: bytes, encoding: .utf8) else {
                throw CanonicalCBORError.malformedCBOR("invalid UTF-8 in string field")
            }
            return .text(s)
        case .bytes:
            let bytes = try reader.readLengthDelimited()
            return .bytes(bytes)
        case .enum:
            let n = try reader.readVarint()
            return uintToCBOR(n)
        }
    }

    // MARK: - BigUint / BigSint wrapper

    /// The BigUint / BigSint wrapper is `bytes value = 1; [bool minus = 2]`.
    /// Canonical CBOR emits the tagged-bignum directly. A zero-magnitude
    /// returns `.null` here as a sentinel for "omit"; the caller drops it
    /// from the parent pair list.
    static func decodeBigIntWrapper(typeName: String, wireBytes: Data) throws -> CBORValue {
        var reader = WireReader(data: wireBytes)
        var magnitudeBytes = Data()
        var minus = false
        while !reader.isAtEnd {
            let (fieldId, wireType) = try reader.readTag()
            switch fieldId {
            case 1:
                guard wireType == 2 else {
                    throw CanonicalCBORError.typeMismatch(
                        "BigUint.value expected length-delim wire type"
                    )
                }
                magnitudeBytes = try reader.readLengthDelimited()
            case 2:
                guard wireType == 0 else {
                    throw CanonicalCBORError.typeMismatch(
                        "BigSint.minus expected varint wire type"
                    )
                }
                minus = (try reader.readVarint()) != 0
            default:
                try reader.skipField(wireType: wireType)
            }
        }
        let mag = BigUInt(magnitudeBytes)
        if mag.signum() == 0 {
            // Zero-magnitude → omit. Returning `.null` as sentinel; the
            // caller in `buildMap` strips `.null` singletons from the
            // parent pair list. Repeated BigUint isn't a thing in OCAP.
            return .null
        }
        let stripped = BigIntCodec.magnitudeBytes(mag)
        if typeName == "BigSint" && minus {
            return .tagged(CanonicalCBORConstants.tagNegativeBignum, .bytes(stripped))
        }
        return .tagged(CanonicalCBORConstants.tagPositiveBignum, .bytes(stripped))
    }

    // MARK: - Timestamp

    /// Decode `google.protobuf.Timestamp` wire bytes into `(seconds, nanos)`.
    static func decodeTimestampWire(_ wireBytes: Data) throws -> (seconds: Int64, nanos: Int32) {
        var reader = WireReader(data: wireBytes)
        var seconds: Int64 = 0
        var nanos: Int32 = 0
        while !reader.isAtEnd {
            let (fieldId, wireType) = try reader.readTag()
            switch (fieldId, wireType) {
            case (1, 0):
                let raw = try reader.readVarint()
                seconds = Int64(bitPattern: raw)
            case (2, 0):
                let raw = try reader.readVarint()
                nanos = Int32(truncatingIfNeeded: Int64(bitPattern: raw))
            default:
                try reader.skipField(wireType: wireType)
            }
        }
        return (seconds, nanos)
    }

    /// Format `(seconds, nanos)` as RFC-3339 ISO-8601 with 9-digit
    /// nanosecond fractional. Stable across locales (forces UTC).
    static func formatISO8601(seconds: Int64, nanos: Int32) -> String {
        // Clamp nanos into [0, 999_999_999]; protobuf Timestamp guarantees
        // this on a normalized input but we don't enforce it here.
        let nanosClamped = max(0, min(nanos, 999_999_999))
        let secondsClamped = seconds
        // Use Calendar/DateComponents to break the seconds into Y/M/D/h/m/s
        // — DateFormatter would truncate to milliseconds.
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let date = Date(timeIntervalSince1970: TimeInterval(secondsClamped))
        let comps = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let year = comps.year ?? 1970
        let month = comps.month ?? 1
        let day = comps.day ?? 1
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let second = comps.second ?? 0
        let frac = String(format: "%09d", nanosClamped)
        // Mirror the JS / Kotlin RFC-3339 format. Always emit the fractional
        // part even when it's all zeros so round-trips are byte-stable.
        return String(format: "%04d-%02d-%02dT%02d:%02d:%02d.%@Z",
                      year, month, day, hour, minute, second, frac)
    }

    // MARK: - Any

    /// Decode `google.protobuf.Any` wire bytes (`string type_url = 1;
    /// bytes value = 2;`) and emit the canonical-CBOR shape.
    ///
    /// Three branches, in order of precedence:
    ///  1. Wallet-internal `OpaqueAny` carrier — the typeUrl carries the
    ///     `x-arcblock-opaque/<canonical>` prefix, and `value` holds raw
    ///     CBOR bytes. Strip the prefix, decode the bytes, and emit
    ///     `{0: <canonical>, 1: <decoded>}` (NESTED shape).
    ///  2. OPAQUE canonical typeUrl (`json` / `vc` / `fg:x:address`) — the
    ///     `value` field carries raw CBOR bytes (NOT a nested protobuf
    ///     message). Decode them and emit `{0: typeUrl, 1: <decoded>}`
    ///     (NESTED shape, matching JS / Kotlin reference).
    ///  3. Schema-known typeUrl — recurse via the bridge and emit the FLAT
    ///     shape `{0: typeUrl, ...innerFieldIds}` per spec §7.
    ///
    /// Anything else is a hard error.
    static func decodeAnyWire(_ wireBytes: Data) throws -> CBORValue {
        var reader = WireReader(data: wireBytes)
        var typeUrl = ""
        var valueBytes = Data()
        while !reader.isAtEnd {
            let (fieldId, wireType) = try reader.readTag()
            switch (fieldId, wireType) {
            case (1, 2):
                let bytes = try reader.readLengthDelimited()
                guard let s = String(data: bytes, encoding: .utf8) else {
                    throw CanonicalCBORError.malformedCBOR(
                        "Any.type_url must be UTF-8"
                    )
                }
                typeUrl = s
            case (2, 2):
                valueBytes = try reader.readLengthDelimited()
            default:
                try reader.skipField(wireType: wireType)
            }
        }
        if typeUrl.isEmpty {
            // No typeUrl, no value → empty map.
            return .map([])
        }

        // Branch 1: wallet-internal OpaqueAny carrier (`x-arcblock-opaque/`
        // prefix). Strip the prefix to recover the canonical typeUrl, then
        // fall through to the OPAQUE branch.
        let canonicalTypeUrl: String
        if typeUrl.hasPrefix(OpaqueAny.wireTypeUrlPrefix) {
            canonicalTypeUrl = String(typeUrl.dropFirst(OpaqueAny.wireTypeUrlPrefix.count))
        } else {
            canonicalTypeUrl = typeUrl
        }

        // Branch 2: OPAQUE — value bytes are raw CBOR (with self-describe
        // prefix), not protobuf. Decode them and nest under key 1.
        if CanonicalCBOR.OPAQUE_TYPE_URLS.contains(canonicalTypeUrl) {
            // Empty value is legal — emit `{0: typeUrl}` only.
            if valueBytes.isEmpty {
                return .map([
                    CBORMapPair(key: .unsigned(0), value: .text(canonicalTypeUrl))
                ])
            }
            let inner: CBORValue
            do {
                // The carrier always stores self-describe-tagged bytes — that
                // matches what `CanonicalCBOR.encodeOpaque` produces. We use
                // `decodeTopLevel` so a missing prefix surfaces as a
                // typed error rather than silent garbage.
                inner = try CBORDecoder.decodeTopLevel(valueBytes)
            } catch {
                throw CanonicalCBORError.malformedCBOR(
                    "OPAQUE Any payload is not valid canonical CBOR"
                )
            }
            return .map([
                CBORMapPair(key: .unsigned(0), value: .text(canonicalTypeUrl)),
                CBORMapPair(key: .unsigned(1), value: inner)
            ])
        }

        // Branch 3: schema-known typeUrl. Recurse via the bridge.
        let messageName = FieldResolver.fromTypeUrl(canonicalTypeUrl)
        guard FieldResolver.fieldsForMessage(messageName) != nil else {
            // Not OPAQUE, not in schema — hard error.
            throw CanonicalCBORError.unknownTypeUrl(canonicalTypeUrl)
        }
        // Build the inner map. Use the FLAT shape per the canonical-cbor
        // spec: `{0: typeUrl, ...innerFieldIds...}`. Inner fields are
        // promoted into the same map as the typeUrl, NOT nested under key 1.
        let innerPairs = try buildMap(messageName: messageName, wireBytes: valueBytes)
        var pairs: [CBORMapPair] = [
            CBORMapPair(key: .unsigned(0), value: .text(canonicalTypeUrl))
        ]
        // Drop any inner key 0 (defensive — shouldn't happen for proto types).
        for p in innerPairs where !(p.key == .unsigned(0)) {
            pairs.append(p)
        }
        return .map(pairs)
    }

    // MARK: - Helpers

    /// Convert a UInt64 wire value to a CBORValue, choosing `.unsigned` or
    /// `.negative` based on the high bit (matches int32/int64 sign semantics).
    static func uintToCBOR(_ n: UInt64) -> CBORValue {
        let signed = Int64(bitPattern: n)
        if signed < 0 { return .negative(signed) }
        return .unsigned(n)
    }
}

// `WireReader` lives in WireFormat.swift (sibling source file).
