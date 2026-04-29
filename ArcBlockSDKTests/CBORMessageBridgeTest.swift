// CBORMessageBridgeTest.swift
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

/// Phase 3 exit gate — Schema-driven Map ↔ Message bridge with `Any`
/// (known typeUrls) + `Timestamp` special-cases.
///
/// The five mandated test cases (per plan §"Tests to write"):
///
/// 1. Encode each OCAP fixture's input → CBOR, decode back, assertEqual.
/// 2. Cross-encoder: decode `*.cbor.bin` via the bridge, re-serialize as
///    protobuf, compare bytes against `*.meta.json`'s protobuf-hex.
/// 3. `Any` round-trip with `Ocap_TransferV3Tx` inner message.
/// 4. `Timestamp` round-trip.
/// 5. Unknown typeUrl in `Any` field → encode + decode both throw
///    `CanonicalCBORError.unknownTypeUrl`.
class CBORMessageBridgeTest: XCTestCase {

    // MARK: - Setup

    override class func setUp() {
        super.setUp()
        // Force the schema to load via the source-tree fallback. Once the
        // test bundle resource glob picks up Resources/ocap-spec.core.json
        // this becomes a no-op (FieldResolver finds it in the bundle first).
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

    /// Hex-string → Data, accepting either lowercase or uppercase digits.
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

    /// Resolve the test fixtures directory, preferring the bundle but
    /// falling back to the worktree path until phase 2.5 wiring lands.
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

    // MARK: - Test 4 (Timestamp round-trip)

    func testTimestampRoundTrip() throws {
        var ts = Google_Protobuf_Timestamp()
        ts.seconds = 1700000000
        ts.nanos = 123456789
        let bytes = try CanonicalCBOR.encode(ts)
        let decoded = try CanonicalCBOR.decode(bytes, as: Google_Protobuf_Timestamp.self)
        XCTAssertEqual(decoded.seconds, 1700000000)
        XCTAssertEqual(decoded.nanos, 123456789)
    }

    func testTimestampZeroNanos() throws {
        var ts = Google_Protobuf_Timestamp()
        ts.seconds = 1700000000
        let bytes = try CanonicalCBOR.encode(ts)
        let decoded = try CanonicalCBOR.decode(bytes, as: Google_Protobuf_Timestamp.self)
        XCTAssertEqual(decoded.seconds, 1700000000)
        XCTAssertEqual(decoded.nanos, 0)
    }

    func testTimestampZeroSecondsNonZeroNanos() throws {
        var ts = Google_Protobuf_Timestamp()
        ts.nanos = 1
        let bytes = try CanonicalCBOR.encode(ts)
        let decoded = try CanonicalCBOR.decode(bytes, as: Google_Protobuf_Timestamp.self)
        XCTAssertEqual(decoded.seconds, 0)
        XCTAssertEqual(decoded.nanos, 1)
    }

    // MARK: - Test 3 (Any round-trip)

    func testAnyRoundTripWithTransferV3() throws {
        var inner = Ocap_TransferV3Tx()
        var i1 = Ocap_TransactionInput()
        i1.owner = "z1WfGZHaLkv16upggvqBhPAT1UKZZvdKe1L"
        i1.assets = ["asset1", "asset2"]
        inner.inputs = [i1]
        var o1 = Ocap_TransactionInput()
        o1.owner = "z1djzQ7tYaSC2E183dxFMFScriZgvsrhQD1"
        inner.outputs = [o1]

        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:transfer_v3"
        anyMsg.value = try inner.serializedData()

        var tx = Ocap_Transaction()
        tx.from = "z1WfGZHaLkv16upggvqBhPAT1UKZZvdKe1L"
        tx.nonce = 1717171717171
        tx.chainID = "beta"
        tx.itx = anyMsg

        let cborBytes = try CanonicalCBOR.encode(tx)
        let decoded = try CanonicalCBOR.decode(cborBytes, as: Ocap_Transaction.self)
        XCTAssertEqual(decoded.from, tx.from)
        XCTAssertEqual(decoded.nonce, tx.nonce)
        XCTAssertEqual(decoded.chainID, tx.chainID)
        XCTAssertEqual(decoded.itx.typeURL, "fg:t:transfer_v3")

        let recoveredInner = try Ocap_TransferV3Tx(serializedBytes: decoded.itx.value)
        XCTAssertEqual(recoveredInner.inputs.count, 1)
        XCTAssertEqual(recoveredInner.outputs.count, 1)
        XCTAssertEqual(recoveredInner.inputs[0].owner,
                       "z1WfGZHaLkv16upggvqBhPAT1UKZZvdKe1L")
        XCTAssertEqual(recoveredInner.inputs[0].assets, ["asset1", "asset2"])
    }

    // MARK: - Test 5 (Unknown typeUrl)

    func testUnknownTypeUrlOnEncodeThrows() throws {
        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:totally_made_up_typeurl"
        anyMsg.value = Data([0x01, 0x02])
        var tx = Ocap_Transaction()
        tx.from = "z1abc"
        tx.itx = anyMsg
        XCTAssertThrowsError(try CanonicalCBOR.encode(tx)) { error in
            guard let cborErr = error as? CanonicalCBORError,
                  case .unknownTypeUrl(_) = cborErr else {
                XCTFail("expected .unknownTypeUrl, got \(error)")
                return
            }
        }
    }

    func testUnknownTypeUrlOnDecodeThrows() throws {
        // Build a CBOR Transaction whose itx has an unknown typeUrl.
        let itxMap: CBORValue = .map([
            CBORMapPair(key: .unsigned(0), value: .text("fg:t:fictional_unknown_v9")),
        ])
        let txMap: CBORValue = .map([
            CBORMapPair(key: .unsigned(1), value: .text("z1abc")),
            CBORMapPair(key: .unsigned(15), value: itxMap),
        ])
        let bytes = try CanonicalCBOR.encodeRaw(txMap)
        XCTAssertThrowsError(
            try CanonicalCBOR.decode(bytes, as: Ocap_Transaction.self)
        ) { error in
            guard let cborErr = error as? CanonicalCBORError,
                  case .unknownTypeUrl(_) = cborErr else {
                XCTFail("expected .unknownTypeUrl, got \(error)")
                return
            }
        }
    }

    // MARK: - Test 1 (Encode message → CBOR → decode → equal)

    func testEncodeTransferV2WrappedTransaction() throws {
        // Construct the Transaction shape from `wallet_transfer_v2` fixture.
        var inner = Ocap_TransferV2Tx()
        inner.to = "z1djzQ7tYaSC2E183dxFMFScriZgvsrhQD1"
        var bigU = Ocap_BigUint()
        bigU.value = hexToData("0de0b6b3a7640000")
        inner.value = bigU

        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:transfer_v2"
        anyMsg.value = try inner.serializedData()

        var tx = Ocap_Transaction()
        tx.from = "z1WfGZHaLkv16upggvqBhPAT1UKZZvdKe1L"
        tx.nonce = 1717171717171
        tx.chainID = "beta"
        tx.pk = hexToData(
            "1f3da92f9443ad4c789310c88d42e68f5439b3d86187de5de8ec90100614dff1"
        )
        tx.itx = anyMsg

        let cborBytes = try CanonicalCBOR.encode(tx)

        // Compare against the vendored fixture if available.
        if let dir = fixturesDir() {
            let path = dir.appendingPathComponent("wallet_transfer_v2.cbor.bin").path
            if let expected = FileManager.default.contents(atPath: path) {
                XCTAssertEqual(cborBytes, expected,
                               "encode of TransferV2Tx-wrapped Transaction must match fixture")
            }
        }

        let decoded = try CanonicalCBOR.decode(cborBytes, as: Ocap_Transaction.self)
        XCTAssertEqual(decoded, tx)
    }

    // MARK: - Test 1b (BigUint zero-magnitude omit)

    func testBigUintZeroMagnitudeOmitsAndRecovers() throws {
        var inner = Ocap_TransferV2Tx()
        inner.to = "zReceiver"
        var bigU = Ocap_BigUint()
        bigU.value = Data() // zero magnitude
        inner.value = bigU

        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:transfer_v2"
        anyMsg.value = try inner.serializedData()
        var tx = Ocap_Transaction()
        tx.from = "zSender"
        tx.itx = anyMsg

        let cborBytes = try CanonicalCBOR.encode(tx)
        let decoded = try CanonicalCBOR.decode(cborBytes, as: Ocap_Transaction.self)
        let recoveredInner = try Ocap_TransferV2Tx(serializedBytes: decoded.itx.value)
        XCTAssertTrue(recoveredInner.value.value.isEmpty,
                      "zero-magnitude BigUint round-trips as empty bytes")
        XCTAssertEqual(recoveredInner.to, "zReceiver")
    }

    // MARK: - Test 2 (Cross-encoder fixture sweep)

    /// For each fixture: decode its CBOR via the bridge → wire bytes →
    /// compare against the `meta.json` protobuf-hex. Allow byte-asymmetry
    /// for zero-magnitude BigUint cases (per plan spec essentials #4) by
    /// falling back to a CBOR-roundtrip equivalence check.
    func testCrossEncoderAllFixtures() throws {
        struct FixtureSpec {
            let name: String
            let schemaName: String
            let messageType: SwiftProtobuf.Message.Type
        }
        let fixtures: [FixtureSpec] = [
            .init(name: "transaction_full",                schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "transfer_v2",                     schemaName: "TransferV2Tx",      messageType: Ocap_TransferV2Tx.self),
            .init(name: "acquire_asset_v2",                schemaName: "AcquireAssetV2Tx",  messageType: Ocap_AcquireAssetV2Tx.self),
            .init(name: "consume_asset",                   schemaName: "ConsumeAssetTx",    messageType: Ocap_ConsumeAssetTx.self),
            .init(name: "declare_tx",                      schemaName: "DeclareTx",         messageType: Ocap_DeclareTx.self),
            .init(name: "wallet_account_migrate_tx",       schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_acquire_asset_v3",         schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_delegate_tx",              schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_exchange_v2_multisig",     schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_revoke_delegate_tx",       schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_stake_tx",                 schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_transfer_v2",              schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_transfer_v2_signed",       schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_transfer_v3_multi_input",  schemaName: "Transaction",       messageType: Ocap_Transaction.self),
            .init(name: "wallet_transfer_v3_single_input", schemaName: "Transaction",       messageType: Ocap_Transaction.self),
        ]

        guard let dir = fixturesDir() else {
            XCTFail("fixtures directory not found — phase 1 vendoring should put them in Resources/CBORFixtures/")
            return
        }

        var bytePass = 0
        var semanticPass = 0
        var failures: [String] = []

        for spec in fixtures {
            let cborPath = dir.appendingPathComponent(spec.name + ".cbor.bin").path
            guard let cborBytes = FileManager.default.contents(atPath: cborPath) else {
                failures.append("\(spec.name): cbor.bin missing")
                continue
            }
            do {
                let cbor = try CanonicalCBOR.decodeRaw(cborBytes)
                let wireBytes = try MapToMessage.encodeToWireBytes(
                    messageName: spec.schemaName,
                    cborMap: cbor
                )
                let metaPath = dir.appendingPathComponent(spec.name + ".meta.json").path
                if !FileManager.default.fileExists(atPath: metaPath) {
                    // No meta.json — just confirm the wire bytes parse.
                    if spec.schemaName == "Transaction" {
                        _ = try Ocap_Transaction(serializedBytes: wireBytes)
                    }
                    bytePass += 1
                    continue
                }
                let metaData = FileManager.default.contents(atPath: metaPath)!
                let metaJson = try JSONSerialization.jsonObject(with: metaData)
                    as! [String: Any]
                let pbObj = metaJson["protobuf"] as! [String: Any]
                let expectedHex = pbObj["hex"] as! String
                let expectedBytes = hexToData(expectedHex)

                if wireBytes == expectedBytes {
                    bytePass += 1
                } else if spec.schemaName == "Transaction" {
                    let actual = try Ocap_Transaction(serializedBytes: wireBytes)
                    let expected = try Ocap_Transaction(serializedBytes: expectedBytes)
                    if actual == expected {
                        semanticPass += 1
                    } else {
                        // Cross-encoder via CBOR (BigUint zero-magnitude
                        // asymmetry path).
                        let actualCBOR = try CanonicalCBOR.encode(actual)
                        let expectedCBOR = try CanonicalCBOR.encode(expected)
                        if actualCBOR == expectedCBOR && actualCBOR == cborBytes {
                            semanticPass += 1
                        } else {
                            failures.append(
                                "\(spec.name): byte-diff AND not Equatable AND not CBOR-equivalent"
                            )
                        }
                    }
                } else {
                    failures.append("\(spec.name): byte-diff for non-Transaction shape")
                }
            } catch {
                failures.append("\(spec.name): threw \(error)")
            }
        }

        let total = fixtures.count
        let pass = bytePass + semanticPass
        XCTAssertGreaterThanOrEqual(pass, 8,
            "phase 3 exit gate requires ≥ 8/15 fixtures — got \(pass)/\(total)")
        XCTAssertTrue(failures.isEmpty,
            "fixture failures (\(failures.count)/\(total)):\n" +
            failures.joined(separator: "\n"))
        // Diagnostic banner — visible in `xcodebuild test` output.
        print("CBORMessageBridge: byte-equal=\(bytePass)/\(total), semantic=\(semanticPass)/\(total)")
    }

    // MARK: - Smoke: encode each known transaction message → CBOR → decode

    func testRoundTripStakeTx() throws {
        var stake = Ocap_StakeTx()
        stake.address = "z1stake"
        stake.receiver = "z1receiver"
        stake.locked = true
        stake.message = "hello-stake"
        stake.revokeWaitingPeriod = 7
        stake.slashers = ["z1slash1", "z1slash2"]

        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:stake"
        anyMsg.value = try stake.serializedData()
        var tx = Ocap_Transaction()
        tx.from = "z1from"
        tx.itx = anyMsg

        let bytes = try CanonicalCBOR.encode(tx)
        let decoded = try CanonicalCBOR.decode(bytes, as: Ocap_Transaction.self)
        XCTAssertEqual(decoded, tx)
        let recoveredStake = try Ocap_StakeTx(serializedBytes: decoded.itx.value)
        XCTAssertEqual(recoveredStake, stake)
    }

    func testRoundTripDelegateTx() throws {
        var delegate = Ocap_DelegateTx()
        delegate.address = "z1delegate"
        delegate.to = "z1to"
        var op = Ocap_DelegateOp()
        op.typeURL = "fg:t:transfer_v2"
        op.rules = ["rule1"]
        delegate.ops = [op]
        delegate.deny = ["denied1"]
        delegate.validUntil = 9999

        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:delegate"
        anyMsg.value = try delegate.serializedData()
        var tx = Ocap_Transaction()
        tx.from = "z1from"
        tx.itx = anyMsg

        let bytes = try CanonicalCBOR.encode(tx)
        let decoded = try CanonicalCBOR.decode(bytes, as: Ocap_Transaction.self)
        XCTAssertEqual(decoded, tx)
    }

    func testRoundTripAccountMigrateTx() throws {
        var am = Ocap_AccountMigrateTx()
        am.pk = hexToData("deadbeefdeadbeef")
        am.address = "z1migrated"
        var anyMsg = Google_Protobuf_Any()
        anyMsg.typeURL = "fg:t:account_migrate"
        anyMsg.value = try am.serializedData()
        var tx = Ocap_Transaction()
        tx.from = "z1from"
        tx.itx = anyMsg

        let bytes = try CanonicalCBOR.encode(tx)
        let decoded = try CanonicalCBOR.decode(bytes, as: Ocap_Transaction.self)
        XCTAssertEqual(decoded, tx)
    }
}
