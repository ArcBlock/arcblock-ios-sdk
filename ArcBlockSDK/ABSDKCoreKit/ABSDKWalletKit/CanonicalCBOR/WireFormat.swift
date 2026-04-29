// WireFormat.swift
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
//
// =============================================================================
// Why a parallel protobuf wire-format implementation rather than using
// SwiftProtobuf's internals: SwiftProtobuf's wire-level helpers
// (`BinaryDecoder`, `BinaryEncoder`, varint readers/writers, tag/wire-type
// utilities) are declared `internal` / `fileprivate` and are NOT part of its
// public API. Reaching into them would create a fragility every minor
// SwiftProtobuf bump could break.
//
// `MessageToMap` (decode wire bytes → CBOR map) and `MapToMessage` (encode
// CBOR map → wire bytes) are two halves of the same protobuf wire-format
// implementation; they MUST agree byte-for-byte. Keeping the reader and
// writer side-by-side in this single file makes that contract auditable in
// one place.
// =============================================================================

import Foundation

/// Protobuf wire types (RFC: developers.google.com/protocol-buffers/docs/encoding).
internal enum WireType {
    /// Varint (int32, int64, uint32, uint64, sint32, sint64, bool, enum).
    static let varint: UInt8 = 0
    /// 64-bit fixed (fixed64, sfixed64, double).
    static let fixed64: UInt8 = 1
    /// Length-delimited (string, bytes, embedded messages, packed repeated).
    static let lengthDelimited: UInt8 = 2
    /// 32-bit fixed (fixed32, sfixed32, float).
    static let fixed32: UInt8 = 5
}

// MARK: - Reader

/// Minimal single-pass protobuf wire-format reader. Only the bits the
/// schema-driven bridge needs — the heavy lifting (oneof, map, packed) is
/// handled by walking schema metadata one level up.
internal struct WireReader {
    let data: Data
    var idx: Int

    init(data: Data) {
        self.data = data
        self.idx = data.startIndex
    }

    var isAtEnd: Bool { idx >= data.endIndex }

    mutating func readByte() throws -> UInt8 {
        guard idx < data.endIndex else {
            throw CanonicalCBORError.malformedCBOR("unexpected end of wire bytes")
        }
        let b = data[idx]
        idx = data.index(after: idx)
        return b
    }

    /// Read a base-128 varint. Honors the proto3 limit of 10 bytes (groups
    /// of 7 bits, top bit is continuation). 11+ bytes throws.
    mutating func readVarint() throws -> UInt64 {
        var result: UInt64 = 0
        var shift: UInt64 = 0
        for _ in 0..<10 {
            let b = try readByte()
            result |= UInt64(b & 0x7f) << shift
            if b & 0x80 == 0 { return result }
            shift += 7
        }
        throw CanonicalCBORError.malformedCBOR("varint exceeds 10 bytes")
    }

    /// Same as `readVarint` but converts to a non-negative `Int` for use
    /// as a length. Throws on values > `Int.max`.
    mutating func readVarintAsInt() throws -> Int {
        let n = try readVarint()
        guard let i = Int(exactly: n) else {
            throw CanonicalCBORError.malformedCBOR(
                "varint length \(n) exceeds Int.max"
            )
        }
        return i
    }

    mutating func readFixed32() throws -> UInt32 {
        var result: UInt32 = 0
        for i in 0..<4 {
            let b = try readByte()
            result |= UInt32(b) << UInt32(i * 8)
        }
        return result
    }

    mutating func readFixed64() throws -> UInt64 {
        var result: UInt64 = 0
        for i in 0..<8 {
            let b = try readByte()
            result |= UInt64(b) << UInt64(i * 8)
        }
        return result
    }

    mutating func readLengthDelimited() throws -> Data {
        let length = try readVarintAsInt()
        guard length >= 0 else {
            throw CanonicalCBORError.malformedCBOR("negative length")
        }
        guard idx + length <= data.endIndex else {
            throw CanonicalCBORError.malformedCBOR(
                "length-delim payload exceeds remaining bytes"
            )
        }
        let slice = data.subdata(in: idx..<(idx + length))
        idx += length
        return slice
    }

    mutating func readTag() throws -> (fieldId: Int, wireType: UInt8) {
        let tag = try readVarint()
        let wireType = UInt8(tag & 0x07)
        let fieldId = Int(tag >> 3)
        return (fieldId, wireType)
    }

    mutating func skipField(wireType: UInt8) throws {
        switch wireType {
        case WireType.varint:
            _ = try readVarint()
        case WireType.fixed64:
            _ = try readFixed64()
        case WireType.lengthDelimited:
            _ = try readLengthDelimited()
        case WireType.fixed32:
            _ = try readFixed32()
        case 3, 4:
            // Group start/end are deprecated — we skip but don't track depth.
            // OCAP messages never use groups, so this is just defensive.
            throw CanonicalCBORError.malformedCBOR(
                "group wire types not supported"
            )
        default:
            throw CanonicalCBORError.malformedCBOR(
                "unknown wire type \(wireType)"
            )
        }
    }
}

// MARK: - Writer

/// Protobuf wire-format byte writers — partner to `WireReader`. The two MUST
/// agree byte-for-byte; that's why they live in the same file.
internal enum WireFormat {
    static func writeTag(fieldId: Int, wireType: UInt8, into out: inout Data) {
        let tag = (UInt64(fieldId) << 3) | UInt64(wireType)
        writeVarint(tag, into: &out)
    }

    static func writeVarint(_ value: UInt64, into out: inout Data) {
        var v = value
        while v >= 0x80 {
            out.append(UInt8((v & 0x7f) | 0x80))
            v >>= 7
        }
        out.append(UInt8(v & 0x7f))
    }

    static func writeFixed32(_ value: UInt32, into out: inout Data) {
        for i in 0..<4 {
            out.append(UInt8((value >> UInt32(i * 8)) & 0xff))
        }
    }

    static func writeFixed64(_ value: UInt64, into out: inout Data) {
        for i in 0..<8 {
            out.append(UInt8((value >> UInt64(i * 8)) & 0xff))
        }
    }
}
