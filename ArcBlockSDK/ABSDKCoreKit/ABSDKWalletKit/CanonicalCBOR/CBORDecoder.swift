// CBORDecoder.swift
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

/// Low-level canonical CBOR decoder. Parses bytes produced by
/// `CBOREncoder` (or any RFC 8949 §4.2.1 deterministic encoder) back into a
/// `CBORValue` tree.
///
/// `decodeTopLevel(_:)` enforces the self-describe tag 55799 prefix and
/// strips it; `decode(_:)` accepts arbitrary CBOR and is what the schema
/// layer will call for inner values.
///
/// **What this decoder does NOT do:** indefinite-length items (major types
/// 2-5 with additional info 31), half-precision floats, or simple values
/// outside `false` / `true` / `null` / `undefined`. Canonical CBOR per RFC
/// 8949 §4.2.1 forbids those, so a producer that emits them is bug-for-bug
/// not interoperable with this codec — we reject rather than silently
/// accept.
public enum CBORDecoder {

    /// Decode top-level canonical bytes. Requires the self-describe tag
    /// 55799 prefix and unwraps it before returning the inner value.
    public static func decodeTopLevel(_ data: Data) throws -> CBORValue {
        guard data.count >= 3 else {
            throw CanonicalCBORError.missingSelfDescribePrefix
        }
        let p = CanonicalCBORConstants.selfDescribePrefix
        let start = data.startIndex
        guard data[start] == p[0],
              data[start + 1] == p[1],
              data[start + 2] == p[2] else {
            throw CanonicalCBORError.missingSelfDescribePrefix
        }
        let value = try decode(data)
        guard case let .tagged(tag, inner) = value,
              tag == CanonicalCBORConstants.tagSelfDescribe else {
            // Should be impossible given the prefix check, but keep an
            // explicit guard so a future encoder bug surfaces here.
            throw CanonicalCBORError.missingSelfDescribePrefix
        }
        return inner
    }

    /// Decode arbitrary CBOR bytes (with or without self-describe tag).
    /// Throws if there are trailing bytes after the top-level value.
    public static func decode(_ data: Data) throws -> CBORValue {
        var reader = Reader(data: data)
        let value = try reader.readValue()
        if !reader.isAtEnd {
            throw CanonicalCBORError.malformedCBOR("trailing bytes after top-level value")
        }
        return value
    }

    // MARK: - Reader

    /// Single-pass byte reader. Holds an index into the source `Data`; all
    /// reads bump the index forward.
    fileprivate struct Reader {
        let data: Data
        var idx: Data.Index

        init(data: Data) {
            self.data = data
            self.idx = data.startIndex
        }

        var isAtEnd: Bool { idx >= data.endIndex }

        mutating func readByte() throws -> UInt8 {
            guard idx < data.endIndex else {
                throw CanonicalCBORError.malformedCBOR("unexpected end of input")
            }
            let b = data[idx]
            idx = data.index(after: idx)
            return b
        }

        mutating func readBytes(_ count: Int) throws -> Data {
            guard count >= 0 else {
                throw CanonicalCBORError.malformedCBOR("negative byte count")
            }
            let end = data.index(idx, offsetBy: count, limitedBy: data.endIndex)
            guard let stop = end else {
                throw CanonicalCBORError.malformedCBOR("unexpected end of input")
            }
            let slice = data.subdata(in: idx..<stop)
            idx = stop
            return slice
        }

        mutating func readUInt(_ size: Int) throws -> UInt64 {
            let bytes = try readBytes(size)
            var value: UInt64 = 0
            for b in bytes {
                value = (value << 8) | UInt64(b)
            }
            return value
        }

        /// Parse the major type / additional-info head and return
        /// `(majorType, argument, additionalInfo)`. `argument` is the
        /// integer payload, `additionalInfo` is the low 5 bits of the
        /// initial byte (used for major-type 7 to distinguish simple
        /// values vs floats).
        mutating func readHead() throws -> (major: UInt8, arg: UInt64, info: UInt8) {
            let initial = try readByte()
            let major = initial >> 5
            let info = initial & 0x1f
            let arg: UInt64
            switch info {
            case 0...23: arg = UInt64(info)
            case 24: arg = UInt64(try readByte())
            case 25: arg = try readUInt(2)
            case 26: arg = try readUInt(4)
            case 27: arg = try readUInt(8)
            case 28, 29, 30:
                throw CanonicalCBORError.malformedCBOR("reserved additional info \(info)")
            case 31:
                // Indefinite-length items are forbidden by canonical CBOR.
                throw CanonicalCBORError.malformedCBOR(
                    "indefinite-length items are not supported"
                )
            default:
                throw CanonicalCBORError.malformedCBOR("invalid additional info")
            }
            return (major, arg, info)
        }

        mutating func readValue() throws -> CBORValue {
            let (major, arg, info) = try readHead()
            switch major {
            case 0:
                return .unsigned(arg)
            case 1:
                // -1 - arg. If arg <= Int64.max, fits in Int64 negative —
                // and `arg == Int64.max` yields `-Int64.max - 1 == Int64.min`
                // exactly. Anything above Int64.max is below Int64.min and
                // surfaces as `.bigSigned`. Per RFC 8949 a major-type-1
                // value can encode magnitudes up to 2^64.
                if arg <= UInt64(Int64.max) {
                    return .negative(-Int64(arg) - 1)
                } else {
                    let big = -BigInt(BigUInt(arg)) - 1
                    return .bigSigned(big)
                }
            case 2:
                let bytes = try readBytes(Int(arg))
                return .bytes(bytes)
            case 3:
                let bytes = try readBytes(Int(arg))
                guard let s = String(data: bytes, encoding: .utf8) else {
                    throw CanonicalCBORError.malformedCBOR("invalid UTF-8 text string")
                }
                return .text(s)
            case 4:
                var items: [CBORValue] = []
                items.reserveCapacity(Int(arg))
                for _ in 0..<Int(arg) {
                    items.append(try readValue())
                }
                return .array(items)
            case 5:
                var pairs: [CBORMapPair] = []
                pairs.reserveCapacity(Int(arg))
                for _ in 0..<Int(arg) {
                    let key = try readValue()
                    let value = try readValue()
                    pairs.append(CBORMapPair(key: key, value: value))
                }
                return .map(pairs)
            case 6:
                let inner = try readValue()
                return try mapTag(arg, inner: inner)
            case 7:
                return try readSimpleOrFloat(info: info, arg: arg)
            default:
                throw CanonicalCBORError.malformedCBOR("invalid major type \(major)")
            }
        }

        /// Decode a tagged value. We collapse the well-known bignum tags
        /// (2 / 3) into the dedicated `.bigUnsigned` / `.bigSigned` cases
        /// so callers don't have to walk through `.tagged` for every
        /// magnitude. Self-describe and unknown tags pass through as
        /// `.tagged(_:_:)`.
        private func mapTag(_ tag: UInt64, inner: CBORValue) throws -> CBORValue {
            if tag == CanonicalCBORConstants.tagPositiveBignum {
                guard case let .bytes(bytes) = inner else {
                    throw CanonicalCBORError.typeMismatch(
                        "tag 2 must wrap a byte string"
                    )
                }
                return .bigUnsigned(BigUInt(bytes))
            }
            if tag == CanonicalCBORConstants.tagNegativeBignum {
                guard case let .bytes(bytes) = inner else {
                    throw CanonicalCBORError.typeMismatch(
                        "tag 3 must wrap a byte string"
                    )
                }
                let n = BigUInt(bytes)
                return .bigSigned(-BigInt(n) - 1)
            }
            return .tagged(tag, inner)
        }

        private mutating func readSimpleOrFloat(info: UInt8, arg: UInt64) throws -> CBORValue {
            switch info {
            case 20: return .bool(false)
            case 21: return .bool(true)
            case 22: return .null
            case 23: return .undefined
            case 24:
                // Simple value with 1-byte argument. Canonical CBOR forbids
                // values 0-31 in this slot; anything else is a custom
                // simple value we don't model.
                throw CanonicalCBORError.malformedCBOR(
                    "1-byte simple value (arg \(arg)) is not supported"
                )
            case 25:
                throw CanonicalCBORError.malformedCBOR(
                    "half-precision floats are not supported"
                )
            case 26:
                let bits = UInt32(truncatingIfNeeded: arg)
                return .float32(Float(bitPattern: bits))
            case 27:
                return .float64(Double(bitPattern: arg))
            default:
                throw CanonicalCBORError.malformedCBOR(
                    "unsupported simple/float info \(info)"
                )
            }
        }
    }
}
