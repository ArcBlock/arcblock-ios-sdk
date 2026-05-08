// CBOREncoder.swift
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
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import BigInt

/// Low-level canonical CBOR encoder. Takes a `CBORValue` tree and emits
/// **RFC 8949 §4.2.1 deterministically encoded** bytes:
///
///  - Shortest-form integer head per major type.
///  - Map keys sorted ascending by length-then-byte-lex on their *encoded*
///    form (`encodeMapKeysCanonically(_:)`).
///  - Floats are emitted at the width specified by the `CBORValue` case;
///    the encoder does NOT down-cast float64 → float32 on its own (callers
///    decide the precision they need).
///
/// The encoder intentionally has no protobuf knowledge — that lives in
/// phase 2B (`Encoder.kt` Map walker port).
public enum CBOREncoder {

    /// Encode a single CBOR value to bytes. Does NOT prepend the
    /// self-describe tag — see `encodeTopLevel(_:)` for that.
    public static func encode(_ value: CBORValue) throws -> Data {
        var out = Data()
        try writeValue(value, into: &out)
        return out
    }

    /// Top-level entry point. Wraps `value` in CBOR tag 55799 (self-describe)
    /// and emits the canonical bytes. Receivers can use the resulting
    /// `0xd9 0xd9 0xf7` prefix to distinguish CBOR from protobuf input.
    public static func encodeTopLevel(_ value: CBORValue) throws -> Data {
        return try encode(.tagged(CanonicalCBORConstants.tagSelfDescribe, value))
    }

    // MARK: - Internal writers

    static func writeValue(_ value: CBORValue, into out: inout Data) throws {
        switch value {
        case .unsigned(let n):
            writeHead(major: 0, value: n, into: &out)
        case .negative(let n):
            // RFC 8949 §3.1: major type 1 encodes -1 - n.
            if n >= 0 {
                throw CanonicalCBORError.valueOutOfRange(
                    "negative case must hold a strictly negative value"
                )
            }
            // For n < 0, the canonical encoding stores `-1 - n` (per RFC
            // 8949 §3.1). The negation `-n` traps for `Int64.min`, so we
            // special-case it: `-1 - Int64.min == Int64.max`, which is the
            // largest non-negative Int64 and fits in UInt64 directly.
            let magnitude: UInt64
            if n == Int64.min {
                magnitude = UInt64(Int64.max)
            } else {
                magnitude = UInt64(-n - 1)
            }
            writeHead(major: 1, value: magnitude, into: &out)
        case .bytes(let data):
            writeHead(major: 2, value: UInt64(data.count), into: &out)
            out.append(data)
        case .text(let s):
            let utf8 = Data(s.utf8)
            writeHead(major: 3, value: UInt64(utf8.count), into: &out)
            out.append(utf8)
        case .array(let items):
            writeHead(major: 4, value: UInt64(items.count), into: &out)
            for item in items {
                try writeValue(item, into: &out)
            }
        case .map(let pairs):
            try writeMap(pairs, into: &out)
        case .tagged(let tag, let inner):
            writeHead(major: 6, value: tag, into: &out)
            try writeValue(inner, into: &out)
        case .bool(let b):
            // Major type 7, simple values 20 (false) / 21 (true).
            out.append(b ? 0xf5 : 0xf4)
        case .null:
            out.append(0xf6)
        case .undefined:
            out.append(0xf7)
        case .float32(let f):
            out.append(0xfa)
            var be = f.bitPattern.bigEndian
            withUnsafeBytes(of: &be) { out.append(contentsOf: $0) }
        case .float64(let d):
            out.append(0xfb)
            var be = d.bitPattern.bigEndian
            withUnsafeBytes(of: &be) { out.append(contentsOf: $0) }
        case .bigUnsigned(let value):
            // Tag 2 + magnitude bytes. Empty magnitude (BigUInt(0)) is
            // emitted literally as `tag(2, h'')` — the omit policy lives
            // one layer up in `BigIntCodec.normalize`.
            let bytes = BigIntCodec.magnitudeBytes(value)
            try writeValue(
                .tagged(CanonicalCBORConstants.tagPositiveBignum, .bytes(bytes)),
                into: &out
            )
        case .bigSigned(let value):
            // RFC 8949 §3.4.3: tag 3 encodes -1 - n where n is the
            // magnitude carried in the byte string. So for a negative
            // BigInt v, we emit magnitude bytes of (-v - 1). For a
            // non-negative BigInt routed through this case (unusual but
            // legal), use tag 2 — keeps the case symmetrical with the
            // BigUInt path so callers can shovel any BigInt through.
            if value.signum() < 0 {
                let n = (-value) - 1 // BigInt
                let magnitude = BigUInt(n) // safe: n >= 0
                let bytes = BigIntCodec.magnitudeBytes(magnitude)
                try writeValue(
                    .tagged(CanonicalCBORConstants.tagNegativeBignum, .bytes(bytes)),
                    into: &out
                )
            } else {
                let bytes = BigIntCodec.magnitudeBytes(value)
                try writeValue(
                    .tagged(CanonicalCBORConstants.tagPositiveBignum, .bytes(bytes)),
                    into: &out
                )
            }
        }
    }

    /// Write the integer head for a CBOR major type. Always picks the
    /// shortest form per RFC 8949 §4.2.1.
    static func writeHead(major: UInt8, value: UInt64, into out: inout Data) {
        let typeBits = major << 5
        switch value {
        case 0...23:
            out.append(typeBits | UInt8(value))
        case 24...0xff:
            out.append(typeBits | 24)
            out.append(UInt8(value))
        case 0x100...0xffff:
            out.append(typeBits | 25)
            var be = UInt16(value).bigEndian
            withUnsafeBytes(of: &be) { out.append(contentsOf: $0) }
        case 0x1_0000...0xffff_ffff:
            out.append(typeBits | 26)
            var be = UInt32(value).bigEndian
            withUnsafeBytes(of: &be) { out.append(contentsOf: $0) }
        default:
            out.append(typeBits | 27)
            var be = value.bigEndian
            withUnsafeBytes(of: &be) { out.append(contentsOf: $0) }
        }
    }

    /// Sort a list of map pairs by their *encoded* key bytes per RFC 8949
    /// §4.2.1 length-then-lex, then write the map.
    static func writeMap(_ pairs: [CBORMapPair], into out: inout Data) throws {
        let sorted = try canonicalSort(pairs)
        writeHead(major: 5, value: UInt64(sorted.count), into: &out)
        for pair in sorted {
            try writeValue(pair.key, into: &out)
            try writeValue(pair.value, into: &out)
        }
    }

    /// Sort a list of pairs by their canonical encoded-key order. Internal
    /// to the codec — phase 2B will expose a friendlier wrapper if a real
    /// caller materializes; until then we keep the public surface minimal.
    static func canonicalSort(_ pairs: [CBORMapPair]) throws -> [CBORMapPair] {
        // Encode each key once, pair it with its value, sort by the encoded
        // bytes (length then lex), then drop the cached encoding. Per RFC
        // 8949 §4.2.1, byte order tie-breaks at equal length only.
        let keyed: [(Data, CBORMapPair)] = try pairs.map { pair in
            let bytes = try CBOREncoder.encode(pair.key)
            return (bytes, pair)
        }
        // Detect duplicate keys here — RFC 8949 §3.1 says duplicate keys are
        // not well-formed for canonical CBOR, and silent dedupe is worse
        // than an explicit error.
        var seen = Set<Data>()
        for (bytes, _) in keyed {
            if !seen.insert(bytes).inserted {
                throw CanonicalCBORError.invalidMapKey(
                    "duplicate map key in canonical encoding"
                )
            }
        }
        let sorted = keyed.sorted { lhs, rhs in
            if lhs.0.count != rhs.0.count { return lhs.0.count < rhs.0.count }
            return lhs.0.lexicographicallyPrecedes(rhs.0)
        }
        return sorted.map { $0.1 }
    }
}
