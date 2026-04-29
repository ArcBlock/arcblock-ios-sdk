// TxCodecTest.swift
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

/// Phase 5 — TxCodec bytes-first public API + DescriptorRegistry.
///
/// Test groups (mirror plan §"Tests"):
///  a. detectEncoding — CBOR fixture, protobuf hex, empty, random-CBOR-prefix
///  b. convert identity — same encoding returns input unchanged
///  c. convert cross — every fixture: cbor → proto byte-equal,
///                                     proto → cbor byte-equal (semantic
///                                     fallback for documented BigUint zero-
///                                     magnitude case in
///                                     `wallet_exchange_v2_multisig`).
///  d. toProtobuf / toEncoding shortcuts equal the long form.
///  e. DescriptorRegistry forward / inverse / knownTypeUrls / OPAQUE-nil.
class TxCodecTest: XCTestCase {

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

    // MARK: - Helpers

    private func hexToData(_ hex: String) -> Data {
        var data = Data()
        var i = hex.startIndex
        while i < hex.endIndex {
            let next = hex.index(i, offsetBy: 2)
            if let b = UInt8(hex[i..<next], radix: 16) {
                data.append(b)
            }
            i = next
        }
        return data
    }

    private func fixturesDir() -> URL? {
        let bundle = Bundle(for: type(of: self))
        if let urls = bundle.urls(
            forResourcesWithExtension: "bin",
            subdirectory: "CBORFixtures"
        ), let first = urls.first {
            return first.deletingLastPathComponent()
        }
        let here = URL(fileURLWithPath: #filePath)
        let dir = here.deletingLastPathComponent()
            .appendingPathComponent("Resources/CBORFixtures", isDirectory: true)
        if FileManager.default.fileExists(atPath: dir.path) { return dir }
        return nil
    }

    /// Names of fixtures whose CBOR↔protobuf cross-encode is byte-asymmetric
    /// because the dapp pipeline emitted a zero-magnitude `BigUint` that
    /// canonicalizes to an empty bytes wrapper. The semantic equivalence
    /// still holds (`Ocap_Transaction == Ocap_Transaction`); this list just
    /// scopes which fixtures we allow that fallback for.
    private let bigUintZeroMagnitudeFixtures: Set<String> = [
        "wallet_exchange_v2_multisig"
    ]

    // MARK: - a. detectEncoding

    func testDetectEncodingCBORFromFixture() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let path = dir.appendingPathComponent("wallet_transfer_v3_single_input.cbor.bin").path
        let bytes = FileManager.default.contents(atPath: path)!
        XCTAssertEqual(TxCodec.detectEncoding(bytes), .cbor)
    }

    func testDetectEncodingProtobufFromMeta() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let metaPath = dir.appendingPathComponent("wallet_transfer_v3_single_input.meta.json").path
        let metaData = FileManager.default.contents(atPath: metaPath)!
        let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
        let pbObj = metaJson["protobuf"] as! [String: Any]
        let proto = hexToData(pbObj["hex"] as! String)
        XCTAssertEqual(TxCodec.detectEncoding(proto), .protobuf)
    }

    func testDetectEncodingEmpty() {
        // Empty data → protobuf (no self-describe prefix can match).
        XCTAssertEqual(TxCodec.detectEncoding(Data()), .protobuf)
    }

    func testDetectEncodingShortBuffer() {
        // Buffers shorter than the 3-byte prefix are protobuf.
        XCTAssertEqual(TxCodec.detectEncoding(Data([0xd9])), .protobuf)
        XCTAssertEqual(TxCodec.detectEncoding(Data([0xd9, 0xd9])), .protobuf)
    }

    func testDetectEncodingRandomCBORPrefix() {
        // Documented behavior: structural detector. Any buffer starting
        // with 0xd9 0xd9 0xf7 is classified as CBOR even if the rest is
        // garbage. The decode call will throw — that's the real
        // validation.
        let bytes = Data([0xd9, 0xd9, 0xf7, 0x00, 0x01, 0x02, 0x03])
        XCTAssertEqual(TxCodec.detectEncoding(bytes), .cbor)
    }

    // MARK: - b. convert identity

    func testConvertIdentityCBOR() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let path = dir.appendingPathComponent("wallet_transfer_v3_single_input.cbor.bin").path
        let bytes = FileManager.default.contents(atPath: path)!
        let result = try TxCodec.convert(bytes, from: .cbor, to: .cbor)
        XCTAssertEqual(result, bytes)
    }

    func testConvertIdentityProtobuf() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let metaPath = dir.appendingPathComponent("wallet_transfer_v3_single_input.meta.json").path
        let metaData = FileManager.default.contents(atPath: metaPath)!
        let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
        let pbObj = metaJson["protobuf"] as! [String: Any]
        let proto = hexToData(pbObj["hex"] as! String)
        let result = try TxCodec.convert(proto, from: .protobuf, to: .protobuf)
        XCTAssertEqual(result, proto)
    }

    // MARK: - c. convert cross direction

    /// For every Transaction-shaped fixture: cross-encode in both directions
    /// and assert byte-equal (with the documented BigUint-zero-magnitude
    /// fallback). Mirrors `CBORMessageBridgeTest.testCrossEncoderAllFixtures`
    /// at the public TxCodec layer.
    func testConvertAllFixturesBothDirections() throws {
        let txFixtures = [
            "wallet_account_migrate_tx",
            "wallet_acquire_asset_v3",
            "wallet_delegate_tx",
            "wallet_exchange_v2_multisig",
            "wallet_revoke_delegate_tx",
            "wallet_stake_tx",
            "wallet_transfer_v2",
            "wallet_transfer_v2_signed",
            "wallet_transfer_v3_multi_input",
            "wallet_transfer_v3_single_input",
        ]
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        var checked = 0
        for name in txFixtures {
            let cborPath = dir.appendingPathComponent(name + ".cbor.bin").path
            let metaPath = dir.appendingPathComponent(name + ".meta.json").path
            guard let cborBytes = FileManager.default.contents(atPath: cborPath),
                  let metaData = FileManager.default.contents(atPath: metaPath)
            else {
                XCTFail("fixture or meta missing: \(name)"); continue
            }
            let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
            let pbObj = metaJson["protobuf"] as! [String: Any]
            let expectedProto = hexToData(pbObj["hex"] as! String)

            // CBOR → protobuf: byte-equal (semantic for BigUint zero case).
            let actualProto = try TxCodec.convert(cborBytes, from: .cbor, to: .protobuf)
            if actualProto != expectedProto {
                XCTAssertTrue(
                    bigUintZeroMagnitudeFixtures.contains(name),
                    "\(name): cbor→proto byte mismatch and not in the documented asymmetric set"
                )
                let actual = try Ocap_Transaction(serializedBytes: actualProto)
                let expected = try Ocap_Transaction(serializedBytes: expectedProto)
                // Semantic equivalence: re-encode through CBOR and compare
                // — this is the same fallback CBORMessageBridgeTest uses.
                let actualCBOR = try CanonicalCBOR.encode(actual)
                let expectedCBOR = try CanonicalCBOR.encode(expected)
                XCTAssertEqual(
                    actualCBOR, expectedCBOR,
                    "\(name): cbor→proto semantic fallback failed"
                )
                XCTAssertEqual(
                    actualCBOR, cborBytes,
                    "\(name): cbor→proto re-encode does not match fixture"
                )
            }

            // protobuf → CBOR: byte-equal to the original cbor.bin.
            let actualCBOR = try TxCodec.convert(expectedProto, from: .protobuf, to: .cbor)
            XCTAssertEqual(
                actualCBOR, cborBytes,
                "\(name): proto→cbor not byte-equal to the fixture"
            )
            checked += 1
        }
        XCTAssertEqual(checked, txFixtures.count)
    }

    // MARK: - d. toProtobuf / toEncoding shortcuts

    func testToProtobufMatchesConvert() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let path = dir.appendingPathComponent("wallet_transfer_v3_single_input.cbor.bin").path
        let cborBytes = FileManager.default.contents(atPath: path)!
        let viaShortcut = try TxCodec.toProtobuf(cborBytes)
        let viaConvert = try TxCodec.convert(cborBytes, from: .cbor, to: .protobuf)
        XCTAssertEqual(viaShortcut, viaConvert)
    }

    func testToProtobufIdentityOnProtobufInput() throws {
        // toProtobuf on protobuf bytes detects .protobuf and returns input
        // unchanged via the convert identity path.
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let metaPath = dir.appendingPathComponent("wallet_transfer_v3_single_input.meta.json").path
        let metaData = FileManager.default.contents(atPath: metaPath)!
        let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
        let pbObj = metaJson["protobuf"] as! [String: Any]
        let proto = hexToData(pbObj["hex"] as! String)
        let result = try TxCodec.toProtobuf(proto)
        XCTAssertEqual(result, proto)
    }

    func testToEncodingCBORMatchesConvert() throws {
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let metaPath = dir.appendingPathComponent("wallet_transfer_v3_single_input.meta.json").path
        let metaData = FileManager.default.contents(atPath: metaPath)!
        let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
        let pbObj = metaJson["protobuf"] as! [String: Any]
        let proto = hexToData(pbObj["hex"] as! String)
        let viaShortcut = try TxCodec.toEncoding(proto, encoding: .cbor)
        let viaConvert = try TxCodec.convert(proto, from: .protobuf, to: .cbor)
        XCTAssertEqual(viaShortcut, viaConvert)
    }

    func testToEncodingProtobufIdentity() throws {
        // toEncoding(_, encoding: .protobuf) on protobuf input is identity.
        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found"); return
        }
        let metaPath = dir.appendingPathComponent("wallet_transfer_v3_single_input.meta.json").path
        let metaData = FileManager.default.contents(atPath: metaPath)!
        let metaJson = try JSONSerialization.jsonObject(with: metaData) as! [String: Any]
        let pbObj = metaJson["protobuf"] as! [String: Any]
        let proto = hexToData(pbObj["hex"] as! String)
        let result = try TxCodec.toEncoding(proto, encoding: .protobuf)
        XCTAssertEqual(result, proto)
    }

    // MARK: - e. DescriptorRegistry

    func testDescriptorRegistryForwardLookup() {
        let t = DescriptorRegistry.messageType(forTypeUrl: "fg:t:transfer_v3")
        XCTAssertNotNil(t)
        XCTAssertTrue(t == Ocap_TransferV3Tx.self)
    }

    func testDescriptorRegistryOpaqueIsNil() {
        // OPAQUE typeUrls are not protobuf messages — registry returns nil.
        XCTAssertNil(DescriptorRegistry.messageType(forTypeUrl: "json"))
        XCTAssertNil(DescriptorRegistry.messageType(forTypeUrl: "vc"))
        XCTAssertNil(DescriptorRegistry.messageType(forTypeUrl: "fg:x:address"))
    }

    func testDescriptorRegistryUnknownIsNil() {
        XCTAssertNil(DescriptorRegistry.messageType(forTypeUrl: "fg:t:no_such_type"))
    }

    func testDescriptorRegistryInverseLookup() {
        XCTAssertEqual(
            DescriptorRegistry.typeUrl(for: Ocap_TransferV3Tx.self),
            "fg:t:transfer_v3"
        )
    }

    func testDescriptorRegistryKnownTypeUrlsCount() {
        // Phase 5 hardcodes 11 entries; the spec asks for >= 8 so the
        // assertion stays useful as the table grows.
        XCTAssertGreaterThanOrEqual(DescriptorRegistry.knownTypeUrls.count, 8)
    }

    /// Round-trip every entry: forward → inverse → forward must close.
    func testDescriptorRegistryInverseConsistency() {
        for url in DescriptorRegistry.knownTypeUrls {
            guard let type = DescriptorRegistry.messageType(forTypeUrl: url) else {
                XCTFail("forward lookup for known url \(url) returned nil")
                continue
            }
            XCTAssertEqual(
                DescriptorRegistry.typeUrl(for: type),
                url,
                "inverse lookup for \(url) did not close"
            )
        }
    }

    /// FieldResolver's old surface forwards to DescriptorRegistry. Confirms
    /// the consolidation didn't break the deprecated entry points used by
    /// any pre-phase-5 caller.
    func testFieldResolverShimForwards() {
        XCTAssertEqual(
            FieldResolver.knownAnyTypeUrls,
            DescriptorRegistry.knownTypeUrls
        )
        XCTAssertTrue(
            FieldResolver.messageType(forTypeUrl: "fg:t:transfer_v3")
                == DescriptorRegistry.messageType(forTypeUrl: "fg:t:transfer_v3")
        )
    }
}
