// BigIntCodec.swift
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

/// Canonical encoding for OCAP `BigUint` / `BigSint` wrapper messages.
///
/// Mirrors the Kotlin `BigIntCodec` object (canonical-cbor module) which is in
/// turn ported from `canonical-cbor.ts`:
///
///  - Zero magnitude → omit entirely (caller drops the parent field).
///  - Non-zero positive → CBOR tag 2 + magnitude bytes (big-endian, no
///    leading zeros).
///  - Non-zero negative `BigSint` → CBOR tag 3 + magnitude bytes.
///
/// **Phase 2A scope.** This file ports only the magnitude / sign / omit
/// arithmetic. Coercion of the OCAP wrapper Map shape (`{value, minus}`)
/// from a `Google_Protobuf_Message` lives in phase 2B alongside the field
/// resolver.
public enum BigIntCodec {

    /// Whether a wrapper accepts negative magnitudes. `BigUInt` rejects them
    /// at the boundary so a caller's data error doesn't silently coerce to a
    /// positive number.
    public enum Kind {
        case bigUInt
        case bigSInt
    }

    /// Result of normalizing a candidate magnitude:
    ///
    ///  - `.tagged(bytes, negative)` — a non-zero magnitude ready to be
    ///    wrapped in a CBOR tag 2 / 3.
    ///  - `.omit` — the magnitude is zero. Callers MUST drop the parent
    ///    field; emitting `tag(2, [])` here would be wrong because the
    ///    canonical encoding omits zero BigUint/BigSint fields.
    public enum Repr: Equatable {
        case tagged(bytes: Data, negative: Bool)
        case omit
    }

    /// Strip leading zero bytes from a big-endian magnitude. Always returns
    /// at least one byte; an all-zero input becomes `[0x00]` (the omit
    /// decision happens in `normalize`).
    public static func stripLeadingZeros(_ bytes: Data) -> Data {
        if bytes.isEmpty { return Data([0]) }
        var start = 0
        while start < bytes.count - 1 && bytes[bytes.startIndex + start] == 0 {
            start += 1
        }
        if start == 0 { return bytes }
        return bytes.subdata(in: (bytes.startIndex + start)..<bytes.endIndex)
    }

    /// Magnitude bytes (big-endian, leading zeros stripped) of a `BigUInt`.
    /// `BigUInt(0).serialize()` returns an empty Data; we keep that empty
    /// shape because the omit decision is made by the caller via `normalize`.
    public static func magnitudeBytes(_ value: BigUInt) -> Data {
        let raw = value.serialize()
        if raw.isEmpty { return Data() }
        return stripLeadingZeros(raw)
    }

    /// Magnitude bytes of a `BigInt` (sign discarded — caller decides the
    /// CBOR tag).
    public static func magnitudeBytes(_ value: BigInt) -> Data {
        let mag = value.magnitude // BigUInt
        return magnitudeBytes(mag)
    }

    /// Normalize a `BigUInt` magnitude. Returns `.omit` when the value is
    /// zero (matches the OCAP zero-fold rule), otherwise `.tagged(bytes,
    /// negative: false)`.
    public static func normalize(_ value: BigUInt) -> Repr {
        if value == 0 { return .omit }
        return .tagged(bytes: magnitudeBytes(value), negative: false)
    }

    /// Normalize a `BigInt` against the requested `Kind`. Throws if a
    /// negative value is supplied for `.bigUInt`. Zero returns `.omit`.
    public static func normalize(_ value: BigInt, kind: Kind) throws -> Repr {
        if value.signum() == 0 { return .omit }
        if value.signum() < 0 && kind == .bigUInt {
            throw CanonicalCBORError.valueOutOfRange(
                "BigUint cannot encode negative BigInt"
            )
        }
        let negative = value.signum() < 0 && kind == .bigSInt
        return .tagged(bytes: magnitudeBytes(value), negative: negative)
    }

    /// Build the `CBORValue` for a `Repr.tagged`. Use the encoded form for
    /// round-tripping into a parent map. Callers seeing `.omit` MUST drop
    /// the parent field.
    public static func toCBORValue(_ repr: Repr) -> CBORValue? {
        switch repr {
        case .omit:
            return nil
        case let .tagged(bytes, negative):
            let tag: UInt64 = negative ? CanonicalCBORConstants.tagNegativeBignum
                                       : CanonicalCBORConstants.tagPositiveBignum
            return .tagged(tag, .bytes(bytes))
        }
    }

    /// Convenience: returns the encoded `CBORValue` or `nil` for the omit
    /// case. Mirrors Kotlin `BigIntCodec.encode`.
    public static func encode(_ value: BigUInt) -> CBORValue? {
        return toCBORValue(normalize(value))
    }

    /// Convenience encode for a `BigInt` against a kind (used by the future
    /// schema layer for `BigSint` fields).
    public static func encode(_ value: BigInt, kind: Kind) throws -> CBORValue? {
        return toCBORValue(try normalize(value, kind: kind))
    }

    /// Decode a tag-2/tag-3 wrapped `CBORValue` back to a `BigInt`. Returns
    /// `nil` if the input is not a bignum-tagged byte string. Throws on a
    /// tagged value with the wrong tag.
    public static func decode(_ value: CBORValue) throws -> BigInt? {
        guard case let .tagged(tag, inner) = value else { return nil }
        guard case let .bytes(magnitude) = inner else {
            throw CanonicalCBORError.typeMismatch("bignum tag must wrap a byte string")
        }
        switch tag {
        case CanonicalCBORConstants.tagPositiveBignum:
            return BigInt(BigUInt(magnitude))
        case CanonicalCBORConstants.tagNegativeBignum:
            // RFC 8949 §3.4.3: tag 3 encodes -1 - n. The magnitude bytes
            // carry n, and the wallet wrapper just records the absolute
            // value with `minus = true`. For a faithful BigInt, return
            // `-(n+1)`; for a wrapper-shape consumer, take the magnitude
            // verbatim and the sign separately. We expose the BigInt form
            // here — wrapper bridging happens one layer up.
            let n = BigUInt(magnitude)
            return -BigInt(n) - 1
        default:
            throw CanonicalCBORError.unexpectedBignumTag(tag)
        }
    }
}

/// Constants shared between the encoder/decoder.
public enum CanonicalCBORConstants {
    /// RFC 8949 self-describe tag 55799 prefix. Every canonical CBOR message
    /// starts with these three bytes.
    public static let selfDescribePrefix: [UInt8] = [0xd9, 0xd9, 0xf7]
    /// CBOR tag 2 — positive bignum.
    public static let tagPositiveBignum: UInt64 = 2
    /// CBOR tag 3 — negative bignum.
    public static let tagNegativeBignum: UInt64 = 3
    /// CBOR tag 55799 — self-describe.
    public static let tagSelfDescribe: UInt64 = 55799
}
