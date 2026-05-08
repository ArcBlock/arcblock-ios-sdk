// CBORValue.swift
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

/// Low-level CBOR value model. Mirrors the CBOR data model (RFC 8949 §3),
/// adapted for Swift idioms. This is the codec layer's working type: the
/// schema-driven (proto-aware) layer lives above it and produces / consumes
/// instances of `CBORValue`.
///
/// The `map` case uses an *ordered list of pairs* on purpose. Canonical CBOR
/// encoding requires keys to be sorted by RFC 8949 §4.2.1 length-then-lex on
/// their encoded byte form. An ordinary `Dictionary` does not preserve
/// insertion order, and re-sorting on decode would silently destroy the
/// original key emission order — useful for round-trip diagnostics. The
/// encoder sorts keys before serialization; the decoder preserves the order
/// it read them in.
public indirect enum CBORValue: Equatable {
    /// A non-negative integer (CBOR major type 0).
    case unsigned(UInt64)
    /// A strictly negative integer expressible in `Int64` (CBOR major
    /// type 1). Out-of-range negatives must use `bigSigned`.
    case negative(Int64)
    /// A byte string (CBOR major type 2).
    case bytes(Data)
    /// A UTF-8 text string (CBOR major type 3).
    case text(String)
    /// An array of values (CBOR major type 4).
    case array([CBORValue])
    /// A map of key/value pairs (CBOR major type 5). Order is significant
    /// only when round-tripping unknown maps. The canonical encoder always
    /// sorts before writing.
    case map([CBORMapPair])
    /// A tagged value (CBOR major type 6).
    case tagged(UInt64, CBORValue)
    /// CBOR `false` (`0xf4`) / `true` (`0xf5`).
    case bool(Bool)
    /// CBOR `null` (`0xf6`).
    case null
    /// CBOR `undefined` (`0xf7`).
    case undefined
    /// IEEE-754 single-precision float.
    case float32(Float)
    /// IEEE-754 double-precision float.
    case float64(Double)
    /// CBOR tag 2 wrapped magnitude bytes — represented natively as a
    /// `BigUInt` for ergonomic arithmetic. Round-trips through `BigUInt(0)`
    /// produce `tag(2, h'')`, exactly as `tag(2, [])` is emitted by the
    /// reference TypeScript implementation when an explicit zero is asked
    /// for. The OCAP zero-omit policy lives one layer up — see
    /// `BigIntCodec.normalize`.
    case bigUnsigned(BigUInt)
    /// CBOR tag 3 wrapped magnitude — the value is the *negative* integer
    /// encoded by the tag (i.e. the magnitude is `-1 - bytes` per RFC
    /// 8949 §3.4.3). Implementation-wise we carry the raw `BigInt` and the
    /// encoder emits the magnitude bytes.
    case bigSigned(BigInt)
}

/// A single key/value pair in a CBOR map. Modeled as a struct rather than a
/// tuple so it can conform to `Equatable` (Swift tuples are not Equatable as
/// of the SDK's pinned Swift version) and so an array-of-pairs reads
/// naturally at call sites.
public struct CBORMapPair: Equatable {
    public let key: CBORValue
    public let value: CBORValue

    public init(key: CBORValue, value: CBORValue) {
        self.key = key
        self.value = value
    }
}

// MARK: - Convenience constructors

public extension CBORValue {
    /// Convenience for building a map from a Swift dictionary literal-style
    /// list of `(key, value)` tuples. Order is preserved exactly as supplied
    /// — the canonical encoder will sort before writing bytes.
    static func mapFromPairs(_ pairs: [(CBORValue, CBORValue)]) -> CBORValue {
        return .map(pairs.map { CBORMapPair(key: $0.0, value: $0.1) })
    }
}
