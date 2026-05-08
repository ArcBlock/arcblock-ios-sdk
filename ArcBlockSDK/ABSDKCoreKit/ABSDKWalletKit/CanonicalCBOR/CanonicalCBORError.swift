// CanonicalCBORError.swift
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

/// Thrown by the canonical CBOR codec on any failure to encode or decode a
/// canonical CBOR message. Mirrors `CanonicalCborException` on the Android
/// side. Error messages deliberately avoid echoing user-supplied field
/// content to prevent leaking payloads in logs.
public enum CanonicalCBORError: Error, CustomStringConvertible, Equatable {
    /// Generic encode/decode failure. Carries a short, payload-free message.
    case message(String)
    /// The input bytes are missing the self-describe tag 55799 prefix
    /// (`0xd9 0xd9 0xf7`) and therefore are not a canonical CBOR message.
    case missingSelfDescribePrefix
    /// A bignum-tagged value used a tag other than 2 (positive) or 3
    /// (negative) where one of those was required.
    case unexpectedBignumTag(UInt64)
    /// The CBOR input could not be parsed as well-formed CBOR.
    case malformedCBOR(String)
    /// A non-integer or out-of-range integer was used as a CBOR map key
    /// where this codec only allows integer keys (proto field ids) or
    /// canonical-ordered keys.
    case invalidMapKey(String)
    /// A scalar was outside the supported value range (e.g. a non-finite
    /// float).
    case valueOutOfRange(String)
    /// A decoded value's CBOR type did not match the expected shape.
    case typeMismatch(String)
    /// An `Any` field carries a `typeUrl` whose inner-message schema is not
    /// known to this decoder AND is not in `CanonicalCBOR.OPAQUE_TYPE_URLS`.
    /// OPAQUE typeUrls (`json` / `vc` / `fg:x:address`) bypass the schema
    /// lookup and surface as `OpaqueAny` carriers; unknown pass-through
    /// (phase 5) is still a hard error here.
    case unknownTypeUrl(String)
    /// The decode path nested deeper than the configured maximum (matches
    /// SwiftProtobuf's own default of 32). Guards against stack-blow attacks
    /// from maliciously crafted CBOR input.
    case recursionDepthExceeded(Int)
    /// A `CBORDecodeOptions` cap was hit during decode. The associated
    /// string names which cap (`"maxBytes"` / `"maxDepth"` /
    /// `"maxKeyCount"` / `"maxArrayLength"`). Surfaces from
    /// `CanonicalCBOR.decodeOpaque(_:options:)` and any other entry point
    /// that takes a `CBORDecodeOptions`. Distinct from
    /// `recursionDepthExceeded(_:)` so callers can distinguish a hard
    /// codec invariant (32-deep recursion) from a tunable resource cap.
    case decodeOptionsExceeded(String)

    public var description: String {
        switch self {
        case .message(let s): return s
        case .missingSelfDescribePrefix:
            return "canonical-cbor: missing self-describe tag 55799 prefix"
        case .unexpectedBignumTag(let t):
            return "canonical-cbor: bignum wrapper expects tag 2/3, got \(t)"
        case .malformedCBOR(let s): return "canonical-cbor: malformed CBOR input — \(s)"
        case .invalidMapKey(let s): return "canonical-cbor: invalid map key — \(s)"
        case .valueOutOfRange(let s): return "canonical-cbor: value out of range — \(s)"
        case .typeMismatch(let s): return "canonical-cbor: type mismatch — \(s)"
        case .unknownTypeUrl(let s):
            return "canonical-cbor: unknown typeUrl \"\(s)\" (must be a known OCAP type or in OPAQUE_TYPE_URLS)"
        case .recursionDepthExceeded(let max):
            return "canonical-cbor: recursion depth exceeded \(max)"
        case .decodeOptionsExceeded(let cap):
            return "canonical-cbor: decode options cap exceeded — \(cap)"
        }
    }
}
