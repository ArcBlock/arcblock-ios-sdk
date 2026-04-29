// CanonicalCBOR.swift
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

/// Public namespace for canonical CBOR encoding/decoding.
///
/// Mirrors the Kotlin `CanonicalCbor` object on the Android SDK side. Phase
/// 2B exposes the byte-level entry points (`encodeRaw` / `decodeRaw`) and a
/// diagnostic hook so wallet sites can capture failure context without
/// leaking payload bytes. Phase 3 will add `encode(message:)` /
/// `decode(message:)` overloads that bridge `CBORValue` to
/// `Google_Protobuf_Message` via the schema-driven scalar / field-resolver
/// machinery.
///
/// All entry points enforce the RFC 8949 self-describe tag 55799 prefix on
/// the top-level CBOR — the wallet uses that prefix to distinguish CBOR
/// from protobuf input without a try/catch.
public enum CanonicalCBOR {

    // MARK: - Constants

    /// typeUrls whose payload is treated as opaque CBOR (no schema-driven
    /// encoding). Mirror of the constant in `canonical-cbor.ts` and the
    /// Android `CanonicalCbor.OPAQUE_TYPE_URLS`. Kept here as the single
    /// source of truth so the bridge layer (phase 3) and any wallet
    /// integration sites (phase 6) read the same set.
    public static let OPAQUE_TYPE_URLS: Set<String> = ["json", "vc", "fg:x:address"]

    /// CBOR tag 55799 — RFC 8949 §3.4.6 self-describe. Re-exported from
    /// `CanonicalCBORConstants` so callers don't have to reach into the
    /// codec's internal constants enum.
    public static let SELF_DESCRIBE_TAG: UInt64 = CanonicalCBORConstants.tagSelfDescribe

    // MARK: - Diagnostics

    /// Optional hook invoked when `encodeRaw` / `decodeRaw` fail. The hook
    /// receives a sanitized `CanonicalCBORDiagnosticEvent` (only the first
    /// 16 bytes of the offending input plus the total byte count) — keep it
    /// free of payload content so it's safe to wire into telemetry. Set
    /// from app-startup code; nil by default to keep the codec
    /// side-effect-free.
    ///
    /// Concurrency note: writes to the hook are not synchronized — the
    /// expectation is that the wallet sets it once at startup. If the hook
    /// must be replaced at runtime, do it from the main thread or wrap with
    /// a queue at the call site.
    public static var diagnosticHook: ((CanonicalCBORDiagnosticEvent) -> Void)?

    // MARK: - Top-level entry points

    /// Encode a `CBORValue` to canonical bytes including the self-describe
    /// tag 55799 prefix. On throw, invokes `diagnosticHook` (if set) with a
    /// sanitized event describing the failure. The thrown error is
    /// re-propagated unchanged so callers can pattern-match on
    /// `CanonicalCBORError`.
    public static func encodeRaw(_ value: CBORValue) throws -> Data {
        do {
            return try CBOREncoder.encodeTopLevel(value)
        } catch {
            // Encoding failures don't have an input byte stream to sample —
            // there's no Data to peek at. Emit an empty head16 with totalBytes
            // 0 so consumers know the failure happened *before* byte
            // production. This keeps the event shape uniform between encode
            // and decode paths.
            emit(kind: .encodeFailure, source: Data(), error: error)
            throw error
        }
    }

    /// Decode canonical bytes back to a `CBORValue`. Requires (and strips)
    /// the self-describe tag 55799 prefix — input that omits the prefix
    /// throws `CanonicalCBORError.missingSelfDescribePrefix`. On any throw
    /// the diagnostic hook is fired with the first 16 bytes of `data`.
    public static func decodeRaw(_ data: Data) throws -> CBORValue {
        do {
            return try CBORDecoder.decodeTopLevel(data)
        } catch {
            emit(kind: .decodeFailure, source: data, error: error)
            throw error
        }
    }

    // MARK: - Schema-driven Message <-> CBOR (phase 3)

    /// Encode a `SwiftProtobuf.Message` to canonical CBOR bytes (with the
    /// self-describe tag 55799 prefix). The message's `protoMessageName`
    /// is used to look up the schema descriptor — only types declared in
    /// the bundled OCAP schema (`ocap-spec.core.json`) are supported.
    ///
    /// **Phase 3 scope:** known typeUrls only. An `Any` field carrying an
    /// unrecognized typeUrl throws `CanonicalCBORError.unknownTypeUrl`.
    public static func encode<M: SwiftProtobuf.Message>(_ message: M) throws -> Data {
        do {
            let cborValue = try MessageToMap.encode(message)
            return try CBOREncoder.encodeTopLevel(cborValue)
        } catch {
            emit(kind: .encodeFailure, source: Data(), error: error)
            throw error
        }
    }

    /// Decode canonical CBOR bytes into a `SwiftProtobuf.Message` of type
    /// `M`. The bytes must include the self-describe tag 55799 prefix.
    ///
    /// Special-cases mirror `MessageToMap.encode`: top-level `Timestamp` /
    /// `Any` / `BigUint` / `BigSint` are accepted as their CBOR primitives
    /// (text / map / tagged-bignum) without an OCAP message-schema lookup.
    public static func decode<M: SwiftProtobuf.Message>(_ data: Data, as type: M.Type) throws -> M {
        do {
            let cborValue = try CBORDecoder.decodeTopLevel(data)
            let messageName = MessageToMap.ocapName(of: type)
            let wireBytes: Data
            // Suffix-matching is defensive against accidental name collisions
            // outside OCAP (e.g. someone exporting a namespaced `…BigUint`
            // type from another schema). `protoMessageName` for `Ocap_BigUint`
            // is "ocap.BigUint" so suffix match works the same as the literal
            // "BigUint" did before, and the `google.protobuf.Foo` checks
            // accept either the fully qualified name or the bare suffix.
            if messageName == "Timestamp"
                || messageName.hasSuffix(".Timestamp") {
                guard case let .text(iso) = cborValue else {
                    throw CanonicalCBORError.typeMismatch(
                        "Timestamp top-level expected ISO-8601 text"
                    )
                }
                wireBytes = try MapToMessage.buildTimestampWire(iso: iso)
            } else if messageName == "Any" || messageName.hasSuffix(".Any") {
                wireBytes = try MapToMessage.buildAnyWire(value: cborValue)
            } else if messageName == "BigUint" || messageName == "BigSint"
                || messageName.hasSuffix(".BigUint")
                || messageName.hasSuffix(".BigSint") {
                wireBytes = try MapToMessage.buildBigIntWrapperWire(
                    typeName: messageName.hasSuffix(".BigSint") || messageName == "BigSint"
                        ? "BigSint" : "BigUint",
                    value: cborValue
                )
            } else {
                wireBytes = try MapToMessage.encodeToWireBytes(
                    messageName: messageName,
                    cborMap: cborValue
                )
            }
            // SwiftProtobuf 1.27+ deprecates `serializedData:` in favor of
            // `serializedBytes:`. The new initializer is generic over any
            // `ContiguousBytes` so `Data` slots in unchanged.
            return try M(serializedBytes: wireBytes)
        } catch {
            emit(kind: .decodeFailure, source: data, error: error)
            throw error
        }
    }

    // MARK: - Private helpers

    /// Build and dispatch a diagnostic event. Cheap to call — short-circuits
    /// when the hook is nil, and the head slice is at most 16 bytes.
    private static func emit(kind: CanonicalCBORDiagnosticEvent.Kind,
                             source: Data,
                             error: Error) {
        guard let hook = diagnosticHook else { return }
        // `prefix(_:)` on `Data` returns a slice that shares storage; copy to
        // a fresh `Data` so the consumer can hold onto it without keeping the
        // original (potentially much larger) buffer alive.
        let head16 = Data(source.prefix(16))
        let event = CanonicalCBORDiagnosticEvent(
            kind: kind,
            head16: head16,
            totalBytes: source.count,
            underlyingError: error
        )
        hook(event)
    }
}

/// Sanitized failure event handed to `CanonicalCBOR.diagnosticHook`.
///
/// Carries enough context for triage (kind, byte head, total length, the
/// underlying error) without leaking the full payload. Wallet integrations
/// can route this into their telemetry pipeline; the head is intentionally
/// capped at 16 bytes to keep decoded transaction content out of logs.
public struct CanonicalCBORDiagnosticEvent {

    /// Which API surface failed.
    public enum Kind: Equatable {
        /// `decodeRaw` threw.
        case decodeFailure
        /// `encodeRaw` threw.
        case encodeFailure
        /// `FieldResolver` could not load / parse the schema. Distinct from
        /// decode/encode because the failure is structural (file missing,
        /// JSON malformed) rather than a CBOR value being processed.
        case schemaLoadFailure
    }

    public let kind: Kind
    /// First 16 bytes of the input (decode) or empty for encode failures.
    /// Capped to keep payload content out of logs.
    public let head16: Data
    /// Total length of the source byte buffer (for decode) or 0 (for encode).
    public let totalBytes: Int
    /// The error that was about to be thrown.
    public let underlyingError: Error

    public init(kind: Kind,
                head16: Data,
                totalBytes: Int,
                underlyingError: Error) {
        self.kind = kind
        self.head16 = head16
        self.totalBytes = totalBytes
        self.underlyingError = underlyingError
    }
}
