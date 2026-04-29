// CBORPrimitivesTest.swift
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
import BigInt
@testable import ArcBlockSDK

/// Phase 2A — exercise the low-level CBOR codec and BigInt helpers. These
/// tests are framework-agnostic (plain XCTest) so they can be moved into
/// any test target. The pbxproj wiring is deferred to phase 2.5; a
/// standalone smoke run lives in `/tmp/cbor-smoke.swift` for ad-hoc
/// verification while the test target setup is in flux.
class CBORPrimitivesTest: XCTestCase {

    // MARK: - Round-trip primitives

    func testRoundTripUnsignedShortAndLong() throws {
        for value: UInt64 in [0, 1, 23, 24, 100, 255, 256, 65535, 65536,
                              0xffff_ffff, UInt64.max] {
            let v = CBORValue.unsigned(value)
            let bytes = try CBOREncoder.encode(v)
            let decoded = try CBORDecoder.decode(bytes)
            XCTAssertEqual(decoded, v, "roundtrip unsigned \(value)")
        }
    }

    func testRoundTripNegative() throws {
        for value: Int64 in [-1, -24, -100, -1000, -65536, Int64.min] {
            let v = CBORValue.negative(value)
            let bytes = try CBOREncoder.encode(v)
            let decoded = try CBORDecoder.decode(bytes)
            XCTAssertEqual(decoded, v, "roundtrip negative \(value)")
        }
    }

    func testNegativeInt64MinCanonicalBytes() throws {
        // RFC 8949 §3.1: major type 1 encodes -1 - n. For Int64.min
        // (-0x8000_0000_0000_0000) the magnitude is `-1 - Int64.min ==
        // 0x7FFF_FFFF_FFFF_FFFF == Int64.max`. Cross-encoder byte equality
        // (Kotlin/TS) must hold here, so pin the bytes explicitly.
        let encoded = try CBOREncoder.encode(.negative(.min))
        XCTAssertEqual(
            encoded,
            Data([0x3b, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        )
    }

    func testRoundTripBytes() throws {
        let v = CBORValue.bytes(Data([0x00, 0x01, 0x7f, 0xff]))
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripText() throws {
        let v = CBORValue.text("hello, 世界 🌍")
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripArray() throws {
        let v: CBORValue = .array([.unsigned(1), .text("two"), .bool(true), .null])
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripMap() throws {
        // Keys in arbitrary order — the encoder must canonicalize.
        let v: CBORValue = .map([
            CBORMapPair(key: .unsigned(2), value: .text("two")),
            CBORMapPair(key: .unsigned(1), value: .text("one")),
        ])
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        // Decoded order is the canonical (sorted) order.
        let expected: CBORValue = .map([
            CBORMapPair(key: .unsigned(1), value: .text("one")),
            CBORMapPair(key: .unsigned(2), value: .text("two")),
        ])
        XCTAssertEqual(decoded, expected)
    }

    func testRoundTripTagged() throws {
        let v: CBORValue = .tagged(42, .text("answer"))
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripBoolNullUndefined() throws {
        for v in [CBORValue.bool(true), .bool(false), .null, .undefined] {
            let bytes = try CBOREncoder.encode(v)
            let decoded = try CBORDecoder.decode(bytes)
            XCTAssertEqual(decoded, v)
        }
    }

    func testRoundTripFloat32() throws {
        let v = CBORValue.float32(3.5)
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
        XCTAssertEqual(bytes.first, 0xfa) // major 7, info 26
    }

    func testRoundTripFloat64() throws {
        let v = CBORValue.float64(3.141592653589793)
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
        XCTAssertEqual(bytes.first, 0xfb) // major 7, info 27
    }

    // MARK: - BigInt cases

    func testRoundTripBigUnsignedZeroLiteral() throws {
        // `.bigUnsigned(0)` is the literal CBOR `tag(2, h'')`. The
        // omit-zero policy is enforced one layer up; the encoder itself
        // happily emits an empty byte string.
        let v = CBORValue.bigUnsigned(BigUInt(0))
        let bytes = try CBOREncoder.encode(v)
        XCTAssertEqual(bytes, Data([0xc2, 0x40])) // tag 2, byte string len 0
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripBigUnsignedAboveUInt64() throws {
        // UInt64.max + 1 — definitely doesn't fit in a UInt64.
        let huge = BigUInt(UInt64.max) + 1
        let v = CBORValue.bigUnsigned(huge)
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testRoundTripBigSigned() throws {
        // Negative magnitude beyond Int64 range.
        let big = -BigInt(UInt64.max) - 100
        let v = CBORValue.bigSigned(big)
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testBigIntCodecOmitForZero() throws {
        XCTAssertEqual(BigIntCodec.normalize(BigUInt(0)), .omit)
        XCTAssertNil(BigIntCodec.encode(BigUInt(0)))

        // Non-zero produces tagged bytes.
        let repr = BigIntCodec.normalize(BigUInt(42))
        if case let .tagged(bytes, negative) = repr {
            XCTAssertEqual(bytes, Data([42]))
            XCTAssertFalse(negative)
        } else {
            XCTFail("expected tagged repr for 42")
        }
    }

    func testBigIntCodecRejectsNegativeForBigUInt() throws {
        XCTAssertThrowsError(try BigIntCodec.normalize(BigInt(-1), kind: .bigUInt))
    }

    func testBigIntCodecBigSintNegative() throws {
        let repr = try BigIntCodec.normalize(BigInt(-256), kind: .bigSInt)
        if case let .tagged(bytes, negative) = repr {
            // -256 → magnitude 0x0100, leading zero stripped → 0x0100 still 2 bytes.
            XCTAssertEqual(bytes, Data([0x01, 0x00]))
            XCTAssertTrue(negative)
        } else {
            XCTFail("expected tagged repr for -256")
        }
    }

    // MARK: - Canonical key ordering (RFC 8949 §4.2.1)

    func testCanonicalKeyOrderIntegersByLengthThenLex() throws {
        // Keys 0, 100, 1000, 65536 — their CBOR encodings are 1, 2, 3, 5
        // bytes respectively, so length sort already produces ascending
        // numeric order (matches the test case from the task brief).
        let v: CBORValue = .map([
            CBORMapPair(key: .unsigned(65536), value: .unsigned(4)),
            CBORMapPair(key: .unsigned(0), value: .unsigned(1)),
            CBORMapPair(key: .unsigned(1000), value: .unsigned(3)),
            CBORMapPair(key: .unsigned(100), value: .unsigned(2)),
        ])
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        guard case let .map(pairs) = decoded else {
            return XCTFail("expected map")
        }
        let keys: [CBORValue] = pairs.map { $0.key }
        XCTAssertEqual(keys, [.unsigned(0), .unsigned(100), .unsigned(1000), .unsigned(65536)])
    }

    func testCanonicalKeyOrderEqualLengthLexOrder() throws {
        // Two text keys of the same length — must order by byte lex.
        let v: CBORValue = .map([
            CBORMapPair(key: .text("bb"), value: .unsigned(2)),
            CBORMapPair(key: .text("aa"), value: .unsigned(1)),
        ])
        let bytes = try CBOREncoder.encode(v)
        let decoded = try CBORDecoder.decode(bytes)
        guard case let .map(pairs) = decoded else {
            return XCTFail("expected map")
        }
        XCTAssertEqual(pairs.map { $0.key }, [.text("aa"), .text("bb")])
    }

    func testCanonicalKeyOrderDuplicateRejected() throws {
        let v: CBORValue = .map([
            CBORMapPair(key: .unsigned(1), value: .text("a")),
            CBORMapPair(key: .unsigned(1), value: .text("b")),
        ])
        XCTAssertThrowsError(try CBOREncoder.encode(v))
    }

    // MARK: - Self-describe wrapping

    func testSelfDescribeWrapPrefix() throws {
        let v: CBORValue = .text("hello")
        let bytes = try CBOREncoder.encodeTopLevel(v)
        XCTAssertEqual(bytes.prefix(3), Data([0xd9, 0xd9, 0xf7]))
    }

    func testSelfDescribeUnwrap() throws {
        let v: CBORValue = .map([
            CBORMapPair(key: .unsigned(1), value: .text("hi")),
        ])
        let bytes = try CBOREncoder.encodeTopLevel(v)
        let decoded = try CBORDecoder.decodeTopLevel(bytes)
        XCTAssertEqual(decoded, v)
    }

    func testSelfDescribeRequiredAtTopLevel() throws {
        // Bytes without the prefix should be rejected.
        let bytes = try CBOREncoder.encode(.text("hello"))
        XCTAssertThrowsError(try CBORDecoder.decodeTopLevel(bytes)) { err in
            guard let cborErr = err as? CanonicalCBORError else {
                return XCTFail("unexpected error type")
            }
            XCTAssertEqual(cborErr, .missingSelfDescribePrefix)
        }
    }

    // MARK: - Misc

    func testIndefiniteLengthRejected() throws {
        // 0x5f = byte string with indefinite length. Canonical CBOR
        // forbids it; our decoder must reject.
        let bad = Data([0x5f, 0xff])
        XCTAssertThrowsError(try CBORDecoder.decode(bad))
    }

    func testTrailingBytesRejected() throws {
        var bytes = try CBOREncoder.encode(.unsigned(1))
        bytes.append(0xff) // garbage
        XCTAssertThrowsError(try CBORDecoder.decode(bytes))
    }

    // MARK: - Adversarial length headers

    // These three guard the contract that untrusted bytes from a dapp must
    // throw, never crash. Pre-fix, `Int(arg)` traps for `arg > Int.max`,
    // and a 9-byte payload `0x{5b,9b,bb} ff ff ff ff ff ff ff ff` crashes
    // the wallet before any IO check runs. The decoder must convert
    // through `Int(exactly:)` and surface a thrown error instead.

    func testDecoderRejectsHugeByteStringLength() {
        // 0x5b = bytes (major 2), info=27 (8-byte length), then UInt64.max.
        let bytes = Data([0x5b]) + Data(repeating: 0xff, count: 8)
        XCTAssertThrowsError(try CBORDecoder.decode(bytes))
    }

    func testDecoderRejectsHugeArrayLength() {
        // 0x9b = array (major 4), info=27, count=UInt64.max.
        let bytes = Data([0x9b]) + Data(repeating: 0xff, count: 8)
        XCTAssertThrowsError(try CBORDecoder.decode(bytes))
    }

    func testDecoderRejectsHugeMapLength() {
        // 0xbb = map (major 5), info=27, count=UInt64.max.
        let bytes = Data([0xbb]) + Data(repeating: 0xff, count: 8)
        XCTAssertThrowsError(try CBORDecoder.decode(bytes))
    }
}
