// OpaqueAny.swift
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
import SwiftProtobuf

/// Used internally by the bridge when decoding a CBOR-encoded transaction whose
/// `itx.typeUrl` is OPAQUE per the canonical-cbor spec
/// (`json` / `vc` / `fg:x:address`). The bytes are RAW CBOR, NOT
/// protobuf-encoded — anyone tempted to unpack these via
/// `Google_Protobuf_Any.unpackTo(_:)` must instead call
/// `CanonicalCBOR.decodeOpaque(opaqueAny.cborBytes)`.
///
/// Why a dedicated type instead of stuffing CBOR into a real
/// `Google_Protobuf_Any.value`? Because `Any.value` is, by SwiftProtobuf
/// convention, the protobuf-serialized bytes of the inner message. A consumer
/// holding a `Google_Protobuf_Any{typeURL: "json", value: <CBOR>}` and
/// reaching for `try inner.unpackTo(...)` would crash or silently produce
/// garbage. The wrapper carrier makes that mistake impossible because the
/// `typeURL` is rewritten to `x-arcblock-opaque/<original>` — no protobuf
/// descriptor matches that name.
public struct OpaqueAny: Equatable {

    /// The original canonical typeUrl (`"json"`, `"vc"`, or `"fg:x:address"`).
    /// This is what the on-wire CBOR reports — the `x-arcblock-opaque/`
    /// prefix lives only on the in-memory `Google_Protobuf_Any` carrier.
    public let typeUrl: String

    /// Self-describe-tagged canonical CBOR bytes (i.e. include the `0xd9 0xd9
    /// 0xf7` prefix). Treat as opaque dapp-controlled payload — never decode
    /// without supplying a `CBORDecodeOptions` to bound resource use.
    public let cborBytes: Data

    public init(typeUrl: String, cborBytes: Data) {
        self.typeUrl = typeUrl
        self.cborBytes = cborBytes
    }

    /// Wallet-internal typeUrl prefix for in-memory carriers. NEVER appears in
    /// canonical CBOR output — the bridge strips it before re-encoding. The
    /// purpose of the prefix is to make accidental `unpackTo(_:)` calls fail
    /// loudly rather than silently producing garbage.
    public static let wireTypeUrlPrefix = "x-arcblock-opaque/"

    /// Round-trip carrier into a `Google_Protobuf_Any` with a custom typeUrl
    /// scheme so the deception is self-documenting and non-OPAQUE consumers
    /// see "this isn't a real Any" immediately.
    ///
    /// The wrapper typeUrl is `x-arcblock-opaque/<original-typeUrl>`, e.g.
    /// `x-arcblock-opaque/json`. The `value` field carries the raw CBOR
    /// bytes verbatim (NOT protobuf-encoded). Any consumer that calls
    /// `unpackTo(_:)` on the result will fail to match a protobuf descriptor
    /// for the prefixed name, which is exactly the intended safety net.
    public func toWireAny() -> Google_Protobuf_Any {
        var any = Google_Protobuf_Any()
        any.typeURL = OpaqueAny.wireTypeUrlPrefix + typeUrl
        any.value = cborBytes
        return any
    }

    /// Inverse of `toWireAny()`. Returns `nil` if the `Any`'s typeUrl doesn't
    /// carry the wallet-internal opaque prefix — callers can then fall back
    /// to the regular SwiftProtobuf unpack path.
    public static func fromWireAny(_ any: Google_Protobuf_Any) -> OpaqueAny? {
        guard any.typeURL.hasPrefix(wireTypeUrlPrefix) else { return nil }
        let canonical = String(any.typeURL.dropFirst(wireTypeUrlPrefix.count))
        return OpaqueAny(typeUrl: canonical, cborBytes: any.value)
    }
}
