// CBORSchemaUtilitiesTest.swift
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

import XCTest
import Foundation
@testable import ArcBlockSDK

/// Phase 2B unit tests for the schema-utility scaffolds (`Scalars` and
/// `FieldResolver`). These tests don't need the proto wire-format
/// machinery (that's phase 3) — they only exercise classification,
/// default-folding, and schema lookup.
class CBORSchemaUtilitiesTest: XCTestCase {

    // MARK: - Schema fixture

    /// Resolve the path to `ocap-spec.core.json`. Prefers the bundle
    /// resource (when phase-2.5 wiring is in place); falls back to the
    /// vendored worktree path so the tests run today.
    // TODO(phase-2.5): remove this fallback once pbxproj wires Resources/ocap-spec.core.json into the test bundle
    private func schemaPath() -> String? {
        let bundle = Bundle(for: type(of: self))
        if let url = bundle.url(forResource: "ocap-spec.core", withExtension: "json") {
            return url.path
        }
        // Source-tree fallback. `#filePath` is the path to *this* test file;
        // walk up to the worktree root, then into the vendored Resources/.
        let here = URL(fileURLWithPath: #filePath)
        // ArcBlockSDKTests/<this file>.swift → worktree root is ../
        let root = here.deletingLastPathComponent().deletingLastPathComponent()
        let candidate = root.appendingPathComponent(
            "ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/CanonicalCBOR/Resources/ocap-spec.core.json"
        )
        return FileManager.default.fileExists(atPath: candidate.path)
            ? candidate.path : nil
    }

    private func loadSchemaOrSkip() throws {
        guard let path = schemaPath() else {
            throw XCTSkip("ocap-spec.core.json not reachable; phase-2.5 wiring still pending")
        }
        try FieldResolver.loadSchema(fromPath: path)
    }

    // MARK: - Lifecycle

    /// Reset `FieldResolver` to a known-good state so test order can't leak.
    /// Tests that exercise the failure path (`testFieldResolverHandlesMalformedSchema`,
    /// `testFieldResolverSchemaLoadFailureFiresHook`, etc.) leave the resolver
    /// in a sticky-failure state; without this, a later test that assumes the
    /// schema is loaded would silently see nil lookups.
    override func setUp() {
        super.setUp()
        if let path = schemaPath() {
            try? FieldResolver.loadSchema(fromPath: path)
        }
    }

    /// Belt-and-braces cleanup so a test forgetting its `defer` doesn't leak
    /// the diagnostic hook into the next test.
    override func tearDown() {
        CanonicalCBOR.diagnosticHook = nil
        super.tearDown()
    }

    // MARK: - FieldResolver

    func testFieldResolverLoadsTransactionFields() throws {
        try loadSchemaOrSkip()
        guard let fields = FieldResolver.fieldsForMessage("Transaction") else {
            return XCTFail("Transaction descriptor missing")
        }
        let names = fields.map { $0.name }
        for needed in ["from", "nonce", "chainId", "pk", "signature",
                       "signatures", "itx"] {
            XCTAssertTrue(names.contains(needed),
                "Transaction missing field \(needed); have \(names)")
        }

        let byName = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0) })
        XCTAssertEqual(byName["from"]?.id, 1)
        XCTAssertEqual(byName["nonce"]?.id, 2)
        XCTAssertEqual(byName["chainId"]?.id, 3)
        XCTAssertEqual(byName["pk"]?.id, 4)
        XCTAssertEqual(byName["signature"]?.id, 13)
        XCTAssertEqual(byName["signatures"]?.id, 14)
        XCTAssertEqual(byName["itx"]?.id, 15)
        XCTAssertEqual(byName["signatures"]?.repeated, true)
    }

    func testFieldResolverTransferV3TxFields() throws {
        try loadSchemaOrSkip()
        guard let fields = FieldResolver.fieldsForMessage("TransferV3Tx") else {
            return XCTFail("TransferV3Tx descriptor missing")
        }
        let names = fields.map { $0.name }
        XCTAssertTrue(names.contains("inputs"))
        XCTAssertTrue(names.contains("outputs"))
        XCTAssertTrue(names.contains("data"))
    }

    func testFieldResolverTypeUrlMapping() throws {
        try loadSchemaOrSkip()
        XCTAssertEqual(FieldResolver.toTypeUrl("TransferV2Tx"), "fg:t:transfer_v2")
        XCTAssertEqual(FieldResolver.toTypeUrl("AccountState"), "fg:s:account")
        XCTAssertEqual(FieldResolver.fromTypeUrl("fg:t:transfer_v2"), "TransferV2Tx")
        // Unknown urls round-trip unchanged (matches TS / Kotlin).
        XCTAssertEqual(FieldResolver.fromTypeUrl("unknown:url"), "unknown:url")
    }

    func testFieldResolverEnumDetection() throws {
        try loadSchemaOrSkip()
        XCTAssertTrue(FieldResolver.isEnumType("StatusCode"))
        XCTAssertFalse(FieldResolver.isEnumType("Transaction"))
    }

    // MARK: - FieldResolver negative paths

    func testFieldResolverReturnsNilForUnknownMessage() {
        XCTAssertNil(FieldResolver.fieldsForMessage("DoesNotExist"))
        XCTAssertNil(FieldResolver.fieldsForMessage(""))
        XCTAssertNil(FieldResolver.fieldsForMessage("foo.bar.Baz"))
    }

    func testFieldResolverHandlesMalformedSchema() throws {
        // Write a malformed JSON to a temp file, attempt loadSchema(fromPath:),
        // assert it does NOT crash. Verify subsequent lookups return nil.
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("cbor-malformed.json")
        try "{ this is not valid json".write(
            to: tempURL, atomically: true, encoding: .utf8
        )
        defer { try? FileManager.default.removeItem(at: tempURL) }

        XCTAssertThrowsError(try FieldResolver.loadSchema(fromPath: tempURL.path)) { error in
            // Verify it's a meaningful error, not a crash.
            XCTAssertNotNil(error)
        }
        XCTAssertNil(FieldResolver.fieldsForMessage("Transaction"))
    }

    func testFieldResolverRepeatedFlagDistinguishesShape() throws {
        try loadSchemaOrSkip()
        let fields = FieldResolver.fieldsForMessage("Transaction") ?? []
        let byName = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0) })
        XCTAssertEqual(byName["from"]?.repeated, false, "from is a single field")
        XCTAssertEqual(byName["signatures"]?.repeated, true, "signatures is repeated")
    }

    // MARK: - Schema-load failure semantics

    func testFieldResolverSchemaLoadFailureFiresHook() {
        var captured: CanonicalCBORDiagnosticEvent?
        CanonicalCBOR.diagnosticHook = { ev in captured = ev }
        defer { CanonicalCBOR.diagnosticHook = nil }

        // Use a path that definitely doesn't exist — `loadSchema(fromPath:)`
        // throws to the caller (since this is the explicit-path API), so the
        // diagnostic hook fires from the lazy `ensureLoaded()` path. Force
        // that by failing the explicit load AND then triggering a lookup.
        XCTAssertThrowsError(
            try FieldResolver.loadSchema(fromPath: "/nonexistent/cbor-test/path.json")
        )
        // Now `ensureLoaded()` runs (initialized was set false by the failed
        // loadSchema call) — its bundle lookup will fail in the test runner,
        // which fires the hook with .schemaLoadFailure.
        _ = FieldResolver.fieldsForMessage("Transaction")
        if let ev = captured {
            XCTAssertEqual(ev.kind, .schemaLoadFailure)
        } else {
            XCTFail("schema-load failure hook did not fire")
        }
    }

    func testFieldResolverSchemaLoadFailureIsSticky() {
        var eventCount = 0
        CanonicalCBOR.diagnosticHook = { _ in eventCount += 1 }
        defer { CanonicalCBOR.diagnosticHook = nil }

        // Force a failure first.
        XCTAssertThrowsError(
            try FieldResolver.loadSchema(fromPath: "/nonexistent/cbor-test/path.json")
        )
        _ = FieldResolver.fieldsForMessage("Transaction")
        let countAfterFirstLookup = eventCount

        // Subsequent lookups MUST NOT re-fire the hook (sticky failure).
        _ = FieldResolver.fieldsForMessage("Transaction")
        _ = FieldResolver.fieldsForMessage("TransferV2Tx")
        _ = FieldResolver.isEnumType("StatusCode")
        XCTAssertEqual(eventCount, countAfterFirstLookup,
                       "sticky failure: hook should not fire on each lookup")
    }

    // MARK: - Scalars

    func testScalarsClassification() {
        XCTAssertTrue(Scalars.isScalarInt("int32"))
        XCTAssertTrue(Scalars.isScalarInt("uint64"))
        XCTAssertTrue(Scalars.isScalarInt("sfixed32"))
        XCTAssertFalse(Scalars.isScalarInt("string"))
        XCTAssertFalse(Scalars.isScalarInt("Transaction"))

        XCTAssertTrue(Scalars.isScalarFloat("float"))
        XCTAssertTrue(Scalars.isScalarFloat("double"))
        XCTAssertFalse(Scalars.isScalarFloat("int32"))
    }

    func testScalarsDefaultDetectionInts() {
        XCTAssertTrue(Scalars.isProto3Default(0, type: .int32))
        XCTAssertTrue(Scalars.isProto3Default(0 as Int64, type: .int64))
        XCTAssertTrue(Scalars.isProto3Default(0 as UInt64, type: .uint64))
        XCTAssertTrue(Scalars.isProto3Default(nil, type: .int32))
        XCTAssertTrue(Scalars.isProto3Default("", type: .uint64))
        XCTAssertTrue(Scalars.isProto3Default("0", type: .uint64))
        XCTAssertFalse(Scalars.isProto3Default(1, type: .int32))
        XCTAssertFalse(Scalars.isProto3Default("42", type: .uint64))
    }

    func testScalarsDefaultDetectionStringsAndBytes() {
        XCTAssertTrue(Scalars.isProto3Default("", type: .string))
        XCTAssertFalse(Scalars.isProto3Default("hi", type: .string))

        XCTAssertTrue(Scalars.isProto3Default(Data(), type: .bytes))
        XCTAssertFalse(Scalars.isProto3Default(Data([0x01]), type: .bytes))

        XCTAssertTrue(Scalars.isProto3Default(false, type: .bool))
        XCTAssertFalse(Scalars.isProto3Default(true, type: .bool))
    }

    func testScalarsDefaultDetectionFloats() {
        XCTAssertTrue(Scalars.isProto3Default(0.0, type: .double))
        XCTAssertTrue(Scalars.isProto3Default(Float(0), type: .float))
        XCTAssertFalse(Scalars.isProto3Default(1.5, type: .double))
    }

    func testScalarTypeFromTypeName() {
        XCTAssertEqual(Scalars.ScalarType.from(typeName: "int32"), .int32)
        XCTAssertEqual(Scalars.ScalarType.from(typeName: "string"), .string)
        XCTAssertEqual(Scalars.ScalarType.from(typeName: "bytes"), .bytes)
        XCTAssertNil(Scalars.ScalarType.from(typeName: "Transaction"))
    }

    // MARK: - CanonicalCBOR public API

    func testCanonicalCBORRoundTripPublic() throws {
        let v: CBORValue = .map([CBORMapPair(key: .text("k"), value: .unsigned(1))])
        let bytes = try CanonicalCBOR.encodeRaw(v)
        XCTAssertEqual(bytes.prefix(3), Data([0xd9, 0xd9, 0xf7]))
        let decoded = try CanonicalCBOR.decodeRaw(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testDiagnosticHookFiresOnDecodeFailure() {
        var captured: CanonicalCBORDiagnosticEvent?
        CanonicalCBOR.diagnosticHook = { ev in captured = ev }
        defer { CanonicalCBOR.diagnosticHook = nil }

        let bad = Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
                        0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
                        0x10, 0x11, 0x12])
        XCTAssertThrowsError(try CanonicalCBOR.decodeRaw(bad))

        guard let ev = captured else {
            return XCTFail("hook did not fire")
        }
        XCTAssertEqual(ev.kind, .decodeFailure)
        XCTAssertLessThanOrEqual(ev.head16.count, 16)
        XCTAssertEqual(ev.totalBytes, bad.count)
    }

    func testDiagnosticHookFiresOnEncodeFailure() {
        var captured: CanonicalCBORDiagnosticEvent?
        CanonicalCBOR.diagnosticHook = { ev in captured = ev }
        defer { CanonicalCBOR.diagnosticHook = nil }

        XCTAssertThrowsError(try CanonicalCBOR.encodeRaw(.negative(0)))
        guard let ev = captured else {
            return XCTFail("hook did not fire")
        }
        XCTAssertEqual(ev.kind, .encodeFailure)
    }

    func testCanonicalCBORConstantsExposed() {
        XCTAssertEqual(CanonicalCBOR.OPAQUE_TYPE_URLS,
                       ["json", "vc", "fg:x:address"])
        XCTAssertEqual(CanonicalCBOR.SELF_DESCRIBE_TAG, 55799)
    }
}

