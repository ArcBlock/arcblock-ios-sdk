// TxCodec.swift
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

/// Wire encodings the wallet may receive at the dapp boundary or hash with on
/// the outbound side. CBOR is the new canonical-CBOR carrier; protobuf is the
/// legacy-and-still-supported binary form. Every dapp ↔ wallet bytes-handling
/// site reads / writes one of these two.
public enum TxEncoding {
    case cbor
    case protobuf
}

/// Bytes-first transaction codec. Wraps the schema-driven `CanonicalCBOR`
/// bridge with a thin API the wallet calls without knowing about CBOR vs
/// protobuf internals.
///
/// Phase 5 scope: exactly four entry points, all on `Data`:
///  - `detectEncoding(_:)`  — peek the self-describe prefix, no allocation.
///  - `convert(_:from:to:)` — switch wire formats; identity when from == to.
///  - `toProtobuf(_:)`      — inbound shorthand: detect + convert to proto.
///  - `toEncoding(_:encoding:)` — outbound shorthand: convert proto to N.
///
/// All conversion goes through `Ocap_Transaction` because that is the OCAP
/// wire envelope. Inner-itx-only conversion (e.g. a bare `Ocap_TransferV3Tx`
/// payload, no envelope) is intentionally out of scope; if a future caller
/// needs it we'll add a generic `convert<M>(_:from:to:as:)` overload then.
public enum TxCodec {

    /// CBOR self-describe tag prefix — `0xd9 0xd9 0xf7`. Three bytes; cheap
    /// to read. Mirrors `CanonicalCBOR.SELF_DESCRIBE_TAG` in byte form so we
    /// don't have to materialize the tag value at the detect site.
    private static let selfDescribePrefix: [UInt8] = [0xd9, 0xd9, 0xf7]

    // MARK: - Detection

    /// Inspect `data` to determine wire format.
    ///
    /// CBOR if the buffer starts with the self-describe prefix
    /// `0xd9 0xd9 0xf7`, otherwise protobuf.
    ///
    /// Edge cases — documented behavior:
    ///  - Empty `data` → `.protobuf` (the prefix can't match, so we fall
    ///    through; protobuf bytes can also be empty for a default-valued
    ///    `Message`).
    ///  - Random bytes that happen to start with `0xd9 0xd9 0xf7` are
    ///    classified as `.cbor`. The detector is purely structural; it does
    ///    not attempt to validate the rest of the buffer. Callers that
    ///    receive untrusted bytes should pair `detectEncoding` with the
    ///    decode call (which validates) and treat decode-throw as the
    ///    real "is this CBOR?" answer.
    public static func detectEncoding(_ data: Data) -> TxEncoding {
        guard data.count >= 3 else { return .protobuf }
        // `Data.starts(with:)` allocates the prefix sequence; do the
        // three-byte compare manually for the wallet's hot path.
        if data[data.startIndex] == selfDescribePrefix[0]
            && data[data.startIndex + 1] == selfDescribePrefix[1]
            && data[data.startIndex + 2] == selfDescribePrefix[2] {
            return .cbor
        }
        return .protobuf
    }

    // MARK: - Conversion

    /// Convert `data` from one wire format to another.
    ///
    /// Identity when `from == to`: the input `Data` is returned unchanged
    /// (no copy, no parse). Wallet hot paths call this on every signing
    /// operation, so allocation matters — the spec for this method is
    /// "zero allocation when the bytes are already in the requested
    /// encoding".
    ///
    /// All cross-encoding conversion routes through `Ocap_Transaction`,
    /// which is the OCAP wire envelope at the dapp ↔ wallet boundary.
    /// Passing inner-itx-only bytes (e.g. a bare `Ocap_TransferV3Tx`) will
    /// fail because those bytes don't parse as a Transaction. Phase 5
    /// deliberately does not expose a generic version — see the note on
    /// `TxCodec` itself.
    ///
    /// Throws when the input is malformed, when CBOR decoding hits a
    /// `CBORDecodeOptions` cap, or when the schema bridge can't resolve a
    /// typeUrl. Errors propagate verbatim from the underlying
    /// `CanonicalCBOR` / `SwiftProtobuf` calls so callers can pattern-match
    /// on `CanonicalCBORError` if they need finer-grained handling.
    public static func convert(
        _ data: Data,
        from: TxEncoding,
        to: TxEncoding
    ) throws -> Data {
        if from == to {
            // Identity case: return the input verbatim. `Data` is a
            // value type with copy-on-write semantics, so this is a
            // pointer-cheap return — no copy of the underlying byte
            // buffer happens.
            return data
        }
        switch (from, to) {
        case (.cbor, .protobuf):
            return try cborToProtobuf(data)
        case (.protobuf, .cbor):
            return try protobufToCBOR(data)
        case (.cbor, .cbor), (.protobuf, .protobuf):
            // Unreachable — handled by the `from == to` short-circuit
            // above. Listed here so the switch is exhaustive without a
            // catch-all, which would silently absorb a future TxEncoding
            // case.
            return data
        }
    }

    /// Detect the encoding and convert to protobuf bytes if needed.
    ///
    /// Used at the inbound dapp boundary: the wallet receives `Data` over a
    /// transport that is encoding-agnostic, calls `toProtobuf` to normalize,
    /// then hands the result to `Ocap_Transaction(serializedData:)` (or any
    /// other SwiftProtobuf parser) without branching on the wire format.
    ///
    /// Equivalent to `convert(data, from: detectEncoding(data), to: .protobuf)`.
    public static func toProtobuf(_ data: Data) throws -> Data {
        return try convert(data, from: detectEncoding(data), to: .protobuf)
    }

    /// Convert protobuf bytes to the requested encoding.
    ///
    /// Used on the outbound side to mirror the dapp's chosen wire format
    /// for `finalTx` and any signature-input hashes. The wallet-internal
    /// representation is always protobuf (because that's what
    /// SwiftProtobuf's generated types serialize to), and we only convert
    /// at the egress point.
    ///
    /// Equivalent to `convert(protoBytes, from: .protobuf, to: encoding)` —
    /// the identity case (`encoding == .protobuf`) returns `protoBytes`
    /// without copying.
    public static func toEncoding(_ protoBytes: Data, encoding: TxEncoding) throws -> Data {
        return try convert(protoBytes, from: .protobuf, to: encoding)
    }

    // MARK: - Internal: cross-encoding

    /// CBOR → protobuf. Decodes the canonical-CBOR bytes into an
    /// `Ocap_Transaction` (the OCAP envelope) and re-serializes as protobuf
    /// wire bytes via SwiftProtobuf.
    private static func cborToProtobuf(_ data: Data) throws -> Data {
        let tx = try CanonicalCBOR.decode(data, as: Ocap_Transaction.self)
        return try tx.serializedData()
    }

    /// Protobuf → CBOR. Parses the protobuf wire bytes into an
    /// `Ocap_Transaction` and re-encodes via the canonical-CBOR bridge.
    private static func protobufToCBOR(_ data: Data) throws -> Data {
        // `serializedBytes:` is the SwiftProtobuf 1.27+ replacement for the
        // deprecated `serializedData:` initializer; functionally equivalent.
        let tx = try Ocap_Transaction(serializedBytes: data)
        return try CanonicalCBOR.encode(tx)
    }
}
