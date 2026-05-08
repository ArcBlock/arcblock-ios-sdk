// Scalars.swift
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
import BigInt

/// Proto3 scalar classification + default-folding utilities.
///
/// **Phase 2B scope:** classification (which proto type names are scalar
/// ints / floats), default-value detection, and the `ScalarType` enum
/// surface that the schema-driven encoder will switch on. The actual proto
/// wire-format encode / decode logic lives in phase 3 alongside the
/// `Google_Protobuf_Message` ↔ `CBORValue` bridge — the schema layer needs
/// `FieldResolver.fieldsForMessage` and a registry of scalar coercions, and
/// the design doc has not yet decided between reflection vs codegen for
/// that layer (see plan §"Reflection vs codegen"). Keeping that out of
/// here lets phase 3 land both decisions in one commit.
///
/// Mirrors Kotlin `Scalars` and `canonical-cbor.ts:isDefaultScalar`.
public enum Scalars {

    // MARK: - Type classification

    /// Proto type names that name a scalar integer (signed / unsigned /
    /// fixed). The set is closed and matches both sides of the OCAP
    /// pipeline; if a future proto release adds another integer scalar,
    /// add it here AND audit `isProto3Default(_:type:)`.
    public static let scalarIntTypes: Set<String> = [
        "int32", "sint32", "uint32", "sfixed32", "fixed32",
        "int64", "sint64", "uint64", "sfixed64", "fixed64"
    ]

    /// Proto type names that name a floating-point scalar.
    public static let scalarFloatTypes: Set<String> = ["double", "float"]

    /// Returns true when `type` is an integer proto scalar.
    public static func isScalarInt(_ type: String) -> Bool {
        return scalarIntTypes.contains(type)
    }

    /// Returns true when `type` is a floating-point proto scalar.
    public static func isScalarFloat(_ type: String) -> Bool {
        return scalarFloatTypes.contains(type)
    }

    // MARK: - ScalarType enum

    /// Closed enumeration of proto3 scalar kinds, plus an `enum` case that
    /// the schema layer uses to fold non-numeric enums into their numeric
    /// representation. Built from a `String` so callers parsing schema
    /// `.type` fields can convert in one step. Returns `nil` for non-scalar
    /// type names (message / map / unknown).
    ///
    /// Phase 3 will switch on these to dispatch the proto wire-format encode
    /// path; phase 2B only uses them for default-value detection.
    public enum ScalarType: Equatable {
        case int32
        case sint32
        case uint32
        case sfixed32
        case fixed32
        case int64
        case sint64
        case uint64
        case sfixed64
        case fixed64
        case float
        case double
        case bool
        case string
        case bytes
        /// Proto3 enum kind. The associated value carries the *enum type
        /// name* so the resolver can look up the enum's value table.
        case `enum`(name: String)

        /// Convert a schema `type` string. Returns `nil` for message /
        /// map types (those need `FieldResolver` to walk further).
        public static func from(typeName: String) -> ScalarType? {
            switch typeName {
            case "int32":     return .int32
            case "sint32":    return .sint32
            case "uint32":    return .uint32
            case "sfixed32":  return .sfixed32
            case "fixed32":   return .fixed32
            case "int64":     return .int64
            case "sint64":    return .sint64
            case "uint64":    return .uint64
            case "sfixed64":  return .sfixed64
            case "fixed64":   return .fixed64
            case "float":     return .float
            case "double":    return .double
            case "bool":      return .bool
            case "string":    return .string
            case "bytes":     return .bytes
            default:          return nil
            }
        }

        /// True for the int-family cases (used by default-folding).
        public var isInt: Bool {
            switch self {
            case .int32, .sint32, .uint32, .sfixed32, .fixed32,
                 .int64, .sint64, .uint64, .sfixed64, .fixed64:
                return true
            default:
                return false
            }
        }

        /// True for `.float` / `.double`.
        public var isFloat: Bool {
            switch self {
            case .float, .double: return true
            default: return false
            }
        }
    }

    // MARK: - Proto3 default detection

    /// Returns true when `value` matches the proto3 default for the given
    /// scalar `type`. Default fields are dropped from the canonical
    /// encoding (proto3 zero-fold, mirrors the TS `isDefaultScalar`).
    ///
    /// Accepts a loose `Any?` because the schema-driven encoder builds the
    /// pre-encode tree from heterogeneous sources (Swift literals, decoded
    /// JSON, `Google_Protobuf_Message` reflection in phase 3). The accepted
    /// runtime types per scalar:
    ///
    ///  - integer types: any `BinaryInteger`, `BigInt`, or numeric `String`
    ///    (non-numeric strings are non-default by definition).
    ///  - float types: any `BinaryFloatingPoint`.
    ///  - bool: only `Bool`.
    ///  - string: only `String`.
    ///  - bytes: `Data` / `[UInt8]` / numeric-empty `String`.
    ///  - enum: zero / empty-string treated as default.
    public static func isProto3Default(_ value: Any?, type: ScalarType) -> Bool {
        guard let unwrapped = value else { return true }

        if type.isInt {
            return isIntDefault(unwrapped)
        }
        if type.isFloat {
            return isFloatDefault(unwrapped)
        }
        switch type {
        case .bool:
            return (value as? Bool) == false
        case .string:
            return (value as? String) == ""
        case .bytes:
            if let d = value as? Data { return d.isEmpty }
            if let a = value as? [UInt8] { return a.isEmpty }
            // Strings can sneak through as base64/hex placeholders before
            // the schema layer canonicalizes them; treat empty as default.
            if let s = value as? String { return s.isEmpty }
            return false
        case .enum:
            // Enum default handling: 0, "", or nil (covered above).
            if let n = value as? Int, n == 0 { return true }
            if let s = value as? String, s.isEmpty { return true }
            return false
        default:
            return false
        }
    }

    /// Convenience: same as the typed overload but takes the raw schema
    /// type string. Returns `false` for unknown / non-scalar types — the
    /// caller is expected to call `FieldResolver` for message / map shapes.
    public static func isProto3Default(_ value: Any?, typeName: String) -> Bool {
        guard let scalar = ScalarType.from(typeName: typeName) else {
            return value == nil
        }
        return isProto3Default(value, type: scalar)
    }

    // MARK: - Internal helpers

    /// Default detection for any int scalar. Accepts the union of input
    /// types the TS / Kotlin sides accept.
    private static func isIntDefault(_ value: Any) -> Bool {
        // Cover the common Swift integer types without dragging in
        // `BinaryInteger` runtime checks (which require generic specialization).
        if let n = value as? Int { return n == 0 }
        if let n = value as? Int64 { return n == 0 }
        if let n = value as? UInt64 { return n == 0 }
        if let n = value as? Int32 { return n == 0 }
        if let n = value as? UInt32 { return n == 0 }
        if let n = value as? Int8 { return n == 0 }
        if let n = value as? UInt8 { return n == 0 }
        if let n = value as? Int16 { return n == 0 }
        if let n = value as? UInt16 { return n == 0 }
        if let n = value as? UInt { return n == 0 }
        if let big = value as? BigInt { return big.signum() == 0 }
        if let big = value as? BigUInt { return big.signum() == 0 }
        if let s = value as? String {
            // TS treats "" and "0" as default; preserve that contract so the
            // OCAP zero-fold matches across language ports.
            return s.isEmpty || s == "0"
        }
        // Floats coerced into an int field aren't legal but fold them as
        // default to mirror the TS reference (which does `Number(value) == 0`).
        if let d = value as? Double, d == 0 { return true }
        if let f = value as? Float, f == 0 { return true }
        return false
    }

    /// Default detection for float scalars. Both `.float` and `.double`
    /// fold zero and ±0.0 to default; non-finite values are NOT default
    /// (they're errors at encode time, but that surfaces in phase 3).
    private static func isFloatDefault(_ value: Any) -> Bool {
        if let d = value as? Double { return d == 0 }
        if let f = value as? Float { return f == 0 }
        if let n = value as? Int { return n == 0 }
        if let n = value as? Int64 { return n == 0 }
        return false
    }
}
