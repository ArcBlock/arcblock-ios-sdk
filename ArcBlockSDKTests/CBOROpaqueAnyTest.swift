// CBOROpaqueAnyTest.swift
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

import XCTest
import Foundation
import SwiftProtobuf
@testable import ArcBlockSDK

/// Phase 4 — OPAQUE typeUrl handling (`json` / `vc` / `fg:x:address`) and
/// `CBORDecodeOptions` resource caps.
///
/// Test cases:
///  1. `OpaqueAny.toWireAny` / `fromWireAny` round-trip (carrier only).
///  2. Public `encodeOpaque` / `decodeOpaque` round-trip.
///  3. OPAQUE inside a `DelegateTx` — bridge produces a wallet-internal
///     carrier (`x-arcblock-opaque/<canonical>`) so a consumer that calls
///     `unpackTo(_:)` is forced to fail.
///  4. All three OPAQUE typeUrls (`json`, `vc`, `fg:x:address`) preserve
///     through the bridge.
///  5. Each `CBORDecodeOptions` cap throws independently:
///     `maxBytes`, `maxDepth`, `maxKeyCount`, `maxArrayLength`.
class CBOROpaqueAnyTest: XCTestCase {

    // MARK: - Setup

    override class func setUp() {
        super.setUp()
        let here = URL(fileURLWithPath: #filePath)
        let schemaURL = here
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/CanonicalCBOR/Resources/ocap-spec.core.json")
        if FileManager.default.fileExists(atPath: schemaURL.path) {
            try? FieldResolver.loadSchema(fromPath: schemaURL.path)
        }
    }

    // MARK: - 1. OpaqueAny carrier round-trip

    func testOpaqueAnyCarrierRoundTrip() throws {
        // Synthesize an arbitrary canonical CBOR map for the inner payload.
        let inner: CBORValue = .map([
            CBORMapPair(key: .text("paymentMethod"), value: .text("card")),
            CBORMapPair(key: .text("frequency"), value: .text("monthly")),
            CBORMapPair(key: .text("limit"), value: .unsigned(10000)),
        ])
        let cborBytes = try CanonicalCBOR.encodeRaw(inner)
        let opaque = OpaqueAny(typeUrl: "json", cborBytes: cborBytes)

        let wireAny = opaque.toWireAny()
        XCTAssertEqual(wireAny.typeURL, "x-arcblock-opaque/json",
                       "carrier typeUrl must use the wallet-internal prefix")
        XCTAssertEqual(wireAny.value, cborBytes,
                       "carrier value must be raw CBOR bytes verbatim")

        let recovered = OpaqueAny.fromWireAny(wireAny)
        XCTAssertNotNil(recovered)
        XCTAssertEqual(recovered?.typeUrl, "json")
        XCTAssertEqual(recovered?.cborBytes, cborBytes)
    }

    func testFromWireAnyReturnsNilOnNonPrefixed() {
        var any = Google_Protobuf_Any()
        any.typeURL = "fg:t:transfer_v3"
        any.value = Data([0x01, 0x02, 0x03])
        XCTAssertNil(OpaqueAny.fromWireAny(any),
                     "fromWireAny must return nil so callers fall back to SwiftProtobuf unpack")
    }

    // MARK: - 2. encodeOpaque / decodeOpaque public API

    func testEncodeOpaqueRoundTrip() throws {
        let inner: CBORValue = .map([
            CBORMapPair(key: .text("name"), value: .text("subscription")),
            CBORMapPair(key: .text("active"), value: .bool(true)),
        ])
        let innerBytes = try CanonicalCBOR.encodeRaw(inner)
        let opaque = OpaqueAny(typeUrl: "json", cborBytes: innerBytes)
        let encoded = try CanonicalCBOR.encodeOpaque(opaque)
        let decoded = try CanonicalCBOR.decodeOpaque(encoded)
        guard case let .map(pairs) = decoded else {
            return XCTFail("expected map at top-level after decodeOpaque")
        }
        XCTAssertEqual(pairs.count, 2,
                       "encodeOpaque must emit exactly typeUrl (key 0) + payload (key 1)")
        var sawTypeUrl = false
        var sawInner = false
        for p in pairs {
            if p.key == .unsigned(0), case let .text(s) = p.value, s == "json" {
                sawTypeUrl = true
            }
            if p.key == .unsigned(1), case .map = p.value { sawInner = true }
        }
        XCTAssertTrue(sawTypeUrl)
        XCTAssertTrue(sawInner)
    }

    // MARK: - 3. OPAQUE inside DelegateTx via the bridge

    func testOpaqueInsideDelegateTx() throws {
        // TODO: replace with vendored fixture once
        // tools/cbor-fixture-generate.js subscription_claim_opaque fixture lands.
        let inner: CBORValue = .map([
            CBORMapPair(key: .text("contract"), value: .text("erc20")),
            CBORMapPair(key: .text("amount"), value: .unsigned(42)),
        ])
        let innerBytes = try CanonicalCBOR.encodeRaw(inner)

        var dt = Ocap_DelegateTx()
        dt.address = "z1abc"
        dt.to = "z1to"
        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "json"
        anyMsg.value = innerBytes
        dt.data = anyMsg

        let cborBytes = try CanonicalCBOR.encode(dt)
        let rebuilt = try CanonicalCBOR.decode(cborBytes, as: Ocap_DelegateTx.self)

        XCTAssertEqual(rebuilt.address, "z1abc")
        XCTAssertEqual(rebuilt.to, "z1to")
        // The bridge MUST surface the wallet-internal carrier prefix so
        // anyone reaching for `unpackTo(_:)` fails fast — that is the
        // OPAQUE pitfall guard.
        XCTAssertEqual(rebuilt.data.typeURL, "x-arcblock-opaque/json")
        let opaque = OpaqueAny.fromWireAny(rebuilt.data)
        XCTAssertNotNil(opaque)
        XCTAssertEqual(opaque?.typeUrl, "json",
                       "OpaqueAny.fromWireAny must recover the canonical typeUrl")
        guard let opaqueBytes = opaque?.cborBytes else {
            return XCTFail("nil opaque bytes")
        }
        let recoveredInner = try CanonicalCBOR.decodeOpaque(opaqueBytes)
        guard case let .map(rPairs) = recoveredInner else {
            return XCTFail("inner CBOR did not decode to a map")
        }
        var sawContract = false
        var sawAmount = false
        for p in rPairs {
            if p.key == .text("contract"), case let .text(s) = p.value, s == "erc20" {
                sawContract = true
            }
            if p.key == .text("amount"), case let .unsigned(n) = p.value, n == 42 {
                sawAmount = true
            }
        }
        XCTAssertTrue(sawContract)
        XCTAssertTrue(sawAmount)
    }

    // MARK: - 4. Three OPAQUE typeUrls preserved through the bridge

    func testThreeOpaqueTypeUrlsPreserveThroughBridge() throws {
        for typeUrl in ["json", "vc", "fg:x:address"] {
            let inner: CBORValue = .map([
                CBORMapPair(key: .text("which"), value: .text(typeUrl)),
            ])
            let innerBytes = try CanonicalCBOR.encodeRaw(inner)
            var dt = Ocap_DelegateTx()
            dt.address = "z1addr"
            var anyMsg = Google_Protobuf_Any()
            anyMsg.typeURL = typeUrl
            anyMsg.value = innerBytes
            dt.data = anyMsg
            let cbor = try CanonicalCBOR.encode(dt)
            let back = try CanonicalCBOR.decode(cbor, as: Ocap_DelegateTx.self)
            XCTAssertEqual(back.data.typeURL, "x-arcblock-opaque/" + typeUrl,
                           "typeUrl \(typeUrl) must be carrier-prefixed on decode")
            let recovered = OpaqueAny.fromWireAny(back.data)
            XCTAssertNotNil(recovered)
            XCTAssertEqual(recovered?.typeUrl, typeUrl)
        }
    }

    // MARK: - 5. CBORDecodeOptions caps

    func testMaxBytesCap() throws {
        // Build a non-trivially sized but well-formed CBOR document, then
        // dial maxBytes below its size. The cap is checked BEFORE parsing
        // so we don't need a parseable structure; any blob over the cap
        // must throw.
        let payload = Data(repeating: 0x42, count: 2048)
        var bytes = Data([0xd9, 0xd9, 0xf7])
        bytes.append(0x59)                        // bytes header (2-byte len)
        bytes.append(contentsOf: [0x08, 0x00])    // length 2048
        bytes.append(payload)
        var opts = CBORDecodeOptions()
        opts.maxBytes = 100
        XCTAssertThrowsError(try CanonicalCBOR.decodeOpaque(bytes, options: opts)) { error in
            guard case CanonicalCBORError.decodeOptionsExceeded(let cap) = error else {
                return XCTFail("expected decodeOptionsExceeded, got \(error)")
            }
            XCTAssertEqual(cap, "maxBytes")
        }
    }

    func testMaxDepthCap() throws {
        func nested(_ depth: Int) -> CBORValue {
            if depth == 0 { return .unsigned(1) }
            return .array([nested(depth - 1)])
        }
        let bytes = try CanonicalCBOR.encodeRaw(nested(20))
        var opts = CBORDecodeOptions()
        opts.maxDepth = 5
        XCTAssertThrowsError(try CanonicalCBOR.decodeOpaque(bytes, options: opts)) { error in
            guard case CanonicalCBORError.decodeOptionsExceeded(let cap) = error else {
                return XCTFail("expected decodeOptionsExceeded, got \(error)")
            }
            XCTAssertEqual(cap, "maxDepth")
        }
    }

    func testMaxKeyCountCap() throws {
        var pairs: [CBORMapPair] = []
        for i in 0..<50 {
            pairs.append(CBORMapPair(key: .unsigned(UInt64(i)), value: .unsigned(UInt64(i))))
        }
        let bytes = try CanonicalCBOR.encodeRaw(.map(pairs))
        var opts = CBORDecodeOptions()
        opts.maxKeyCount = 10
        XCTAssertThrowsError(try CanonicalCBOR.decodeOpaque(bytes, options: opts)) { error in
            guard case CanonicalCBORError.decodeOptionsExceeded(let cap) = error else {
                return XCTFail("expected decodeOptionsExceeded, got \(error)")
            }
            XCTAssertEqual(cap, "maxKeyCount")
        }
    }

    func testMaxArrayLengthCap() throws {
        var items: [CBORValue] = []
        for i in 0..<50 {
            items.append(.unsigned(UInt64(i)))
        }
        let bytes = try CanonicalCBOR.encodeRaw(.array(items))
        var opts = CBORDecodeOptions()
        opts.maxArrayLength = 10
        XCTAssertThrowsError(try CanonicalCBOR.decodeOpaque(bytes, options: opts)) { error in
            guard case CanonicalCBORError.decodeOptionsExceeded(let cap) = error else {
                return XCTFail("expected decodeOptionsExceeded, got \(error)")
            }
            XCTAssertEqual(cap, "maxArrayLength")
        }
    }

    func testDefaultOptionsAcceptOcapShapes() throws {
        // Sanity that the existing fixture self-round-trip still works on
        // the public decodeRaw entry point — the OCAP fixtures are well
        // under the default caps, so unchanged behavior is the contract.
        let v: CBORValue = .map([
            CBORMapPair(key: .unsigned(0), value: .text("hello")),
        ])
        let bytes = try CanonicalCBOR.encodeRaw(v)
        XCTAssertNoThrow(try CanonicalCBOR.decodeRaw(bytes))
    }
}
