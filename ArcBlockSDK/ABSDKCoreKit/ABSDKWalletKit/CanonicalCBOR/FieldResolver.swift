// FieldResolver.swift
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

/// Schema-driven field lookup for canonical CBOR encoding.
///
/// Loads `ocap-spec.core.json` (pbjs `proto.json` shape, vendored from
/// `@ocap/proto/schema`) once on first access and caches the parsed
/// descriptors. Mirrors Kotlin `FieldResolver` and `canonical-cbor.ts`
/// `getFields` / `isEnumType` / `toTypeUrl` / `fromTypeUrl`.
///
/// **Phase 2B scope:** structural lookup only. The proto wire-format
/// encoder / decoder built on top of this lives in phase 3.
///
/// **Bundle wiring caveat (phase 2.5):** the schema file lives at
/// `ArcBlockSDK/ABSDKCoreKit/ABSDKWalletKit/CanonicalCBOR/Resources/ocap-spec.core.json`.
/// The framework podspec / pbxproj resource glob hasn't been audited yet
/// (that's a phase 2.5 wiring task). Until then, callers that run outside
/// the framework bundle (smoke harness, ad-hoc unit tests) can call
/// `FieldResolver.loadSchema(fromPath:)` to point at the file directly.
public enum FieldResolver {

    // MARK: - Descriptors

    /// Schema field descriptor — mirrors the `ProtoField` interface in
    /// `canonical-cbor.ts` line 24.
    public struct FieldInfo: Equatable {
        public let id: Int
        public let name: String
        public let type: String
        /// `nil` when the field's `type` is a scalar; otherwise the message
        /// type name (set equal to `type` so callers can unconditionally
        /// read it). We keep `type` and `messageType` separate so future
        /// scalar-vs-message dispatch reads cleanly.
        public let messageType: String?
        public let repeated: Bool
        /// `"repeated"` / `"optional"` / `nil` — the raw rule from the JSON.
        public let rule: String?
        /// Map key type (`"string"` / `"int32"` …) when `keyType` is set in
        /// the schema; nil for non-map fields.
        public let keyType: String?

        public init(id: Int,
                    name: String,
                    type: String,
                    messageType: String?,
                    repeated: Bool,
                    rule: String?,
                    keyType: String?) {
            self.id = id
            self.name = name
            self.type = type
            self.messageType = messageType
            self.repeated = repeated
            self.rule = rule
            self.keyType = keyType
        }
    }

    /// Schema descriptor for a single message type.
    public struct MessageDescriptor: Equatable {
        public let name: String
        /// Fields in declaration order. Canonical encoding sorts by `id`
        /// at encode time per spec §2 — this preserves the insertion order
        /// for diagnostics.
        public let fields: [FieldInfo]
        /// `oneof` group name → list of member field names.
        public let oneofs: [String: [String]]
    }

    // MARK: - Cached state

    /// Whether the schema has been loaded (lazy-init).
    private static var initialized = false
    /// Most recent load error, if any. Sticky: once `ensureLoaded()` fails
    /// it does NOT re-attempt on every public lookup (which is on the hot
    /// path). A manual `loadSchema(fromPath:)` clears this so callers can
    /// recover after fixing the underlying cause.
    private static var loadError: Error?
    /// Synchronizes the lazy-init across threads. Reads after init
    /// is complete are racy-safe because the dictionaries are never
    /// mutated again — but the init itself must be serialized.
    private static let initLock = NSLock()
    private static var messages: [String: MessageDescriptor] = [:]
    private static var enums: [String: [String: Int]] = [:]
    private static var typeUrlByName: [String: String] = [:]
    private static var nameByTypeUrl: [String: String] = [:]

    // MARK: - Public lookup

    /// Returns the field list for a message type, or `nil` if the type is
    /// unknown. Phase 3 callers that require the type may want to throw on
    /// nil; phase 2B keeps the surface tolerant.
    public static func fieldsForMessage(_ typeName: String) -> [FieldInfo]? {
        ensureLoaded()
        if loadError != nil { return nil }
        return messages[typeName]?.fields
    }

    /// Full descriptor (fields + oneofs) for a message type.
    public static func messageDescriptor(_ typeName: String) -> MessageDescriptor? {
        ensureLoaded()
        if loadError != nil { return nil }
        return messages[typeName]
    }

    /// Returns true when `typeName` names an enum declared at the ocap
    /// schema root. Used by `Scalars.isProto3Default` (phase 3) to fold
    /// zero-valued enum members.
    public static func isEnumType(_ typeName: String) -> Bool {
        ensureLoaded()
        if loadError != nil { return false }
        return enums[typeName] != nil
    }

    /// Numeric value for an enum's named member, or nil when the member
    /// (or the enum type) is unknown.
    public static func enumValue(_ typeName: String, member: String) -> Int? {
        ensureLoaded()
        if loadError != nil { return nil }
        return enums[typeName]?[member]
    }

    /// Map a message NAME (e.g. "TransferV2Tx") to its typeUrl
    /// (e.g. "fg:t:transfer_v2"). Falls back to the input name when the
    /// schema doesn't declare a remap — matches TS / Kotlin behavior.
    public static func toTypeUrl(_ messageName: String) -> String {
        ensureLoaded()
        if loadError != nil { return messageName }
        return typeUrlByName[messageName] ?? messageName
    }

    /// Inverse of `toTypeUrl`. Returns input unchanged on miss.
    public static func fromTypeUrl(_ url: String) -> String {
        ensureLoaded()
        if loadError != nil { return url }
        return nameByTypeUrl[url] ?? url
    }

    // MARK: - Schema loading

    /// Force schema initialization. Test harnesses should call this in a
    /// setup block to surface load failures eagerly. Idempotent.
    /// Throws when the bundle resource is missing AND no override path
    /// is set — production code paths log via `CanonicalCBOR.diagnosticHook`
    /// and re-throw.
    public static func ensureLoaded() {
        initLock.lock()
        defer { initLock.unlock() }
        if initialized { return }

        do {
            let data = try loadSchemaData()
            try parseAndIndex(data)
            initialized = true
        } catch {
            // Phase 2B leaves this non-fatal: a missing schema only matters
            // when the schema-driven encoder runs. The codec primitives
            // (CBOREncoder / CBORDecoder) still work without it. Log via
            // the diagnostic hook so wallet integrators notice during
            // staging instead of in production.
            //
            // Sticky failure: mark `initialized = true` and capture the
            // error so subsequent `fieldsForMessage(_:)` calls short-circuit
            // (return nil) without re-locking and re-trying on every hot-path
            // lookup. A manual `loadSchema(fromPath:)` resets both.
            initialized = true
            loadError = error
            CanonicalCBOR.diagnosticHook?(
                CanonicalCBORDiagnosticEvent(
                    kind: .schemaLoadFailure,
                    head16: Data(),
                    totalBytes: 0,
                    underlyingError: error
                )
            )
        }
    }

    /// Override the schema file path. Intended for tests / smoke harnesses
    /// that run outside the framework bundle. Calling this resets the cache
    /// so the next `ensureLoaded()` re-reads from `path`. Also clears any
    /// sticky `loadError` from a prior failed load so callers can recover
    /// after fixing the underlying cause (e.g. writing the schema file).
    ///
    /// On failure: the error is re-thrown to the caller AND `loadError` is
    /// captured so subsequent public lookups short-circuit to nil rather
    /// than racing through `ensureLoaded()` with stale state.
    public static func loadSchema(fromPath path: String) throws {
        initLock.lock()
        defer { initLock.unlock() }
        // Clear sticky failure state up-front so a manual retry path exists.
        // If `Data(contentsOf:)` or parsing throws below, we capture it as a
        // sticky failure (initialized=true, loadError set) before re-throwing
        // so subsequent lookups return nil instead of attempting a bundle
        // re-load via ensureLoaded().
        loadError = nil
        initialized = false
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            try parseAndIndex(data)
            initialized = true
        } catch {
            initialized = true
            loadError = error
            CanonicalCBOR.diagnosticHook?(
                CanonicalCBORDiagnosticEvent(
                    kind: .schemaLoadFailure,
                    head16: Data(),
                    totalBytes: 0,
                    underlyingError: error
                )
            )
            throw error
        }
    }

    /// Returns the bundle-resolved schema bytes, or the explicit override
    /// path if `loadSchema(fromPath:)` was called. Throws when neither
    /// works.
    private static func loadSchemaData() throws -> Data {
        // Try the framework / test bundle that owns this class first.
        if let url = bundleURL() {
            return try Data(contentsOf: url)
        }
        // No bundle and no override → explicit error so the diagnostic
        // hook gets a meaningful message.
        throw CanonicalCBORError.message(
            "ocap-spec.core.json not found in bundle; " +
            "use FieldResolver.loadSchema(fromPath:) to set an explicit path"
        )
    }

    /// Look up the schema URL in the bundle. Tries a few known resource
    /// names so the file can land in either the framework bundle or a
    /// test bundle.
    private static func bundleURL() -> URL? {
        // The bundle that contains this enum's runtime metadata. For the
        // framework target this is the framework bundle; for SwiftPM this
        // is `Bundle.module` (handled implicitly because SwiftPM injects
        // accessors at the file level — see the SPM resource note below).
        let candidates: [Bundle] = [Bundle(for: BundleToken.self), Bundle.main]
        let names = ["ocap-spec.core", "ocap-spec.core.json"]
        for bundle in candidates {
            for name in names {
                if let url = bundle.url(forResource: name, withExtension: "json") {
                    return url
                }
                if let url = bundle.url(forResource: name, withExtension: nil) {
                    return url
                }
            }
        }
        return nil
    }

    // MARK: - Parsing

    /// Parse a JSON `Data` into the message / enum / typeUrl tables.
    /// Throws on malformed JSON or a missing `nested.ocap.nested` root.
    /// Idempotent — safe to call multiple times; clears prior state first.
    private static func parseAndIndex(_ data: Data) throws {
        messages.removeAll()
        enums.removeAll()
        typeUrlByName.removeAll()
        nameByTypeUrl.removeAll()
        let any = try JSONSerialization.jsonObject(with: data, options: [])
        guard let root = any as? [String: Any],
              let nested = root["nested"] as? [String: Any],
              let ocap = nested["ocap"] as? [String: Any],
              let ocapNested = ocap["nested"] as? [String: Any] else {
            throw CanonicalCBORError.message(
                "ocap-spec.core.json missing nested.ocap.nested root"
            )
        }

        // First pass: classify each entry as message vs enum.
        for (key, raw) in ocapNested {
            guard let entry = raw as? [String: Any] else { continue }
            if let _ = entry["fields"] as? [String: Any] {
                let descriptor = parseMessage(name: key, entry: entry)
                messages[key] = descriptor
            } else if let values = entry["values"] as? [String: Any] {
                enums[key] = parseEnum(values: values)
            }
            // Other entries (e.g. nested types) ignored at this level —
            // the schema flat-list keeps top-level types only.
        }

        buildTypeUrls()
    }

    /// Parse a single message entry. Field order follows the JSON
    /// dictionary's insertion order (which `JSONSerialization` preserves
    /// from the file via NSMutableDictionary's ordering on Apple
    /// platforms — confirmed empirically). For deterministic ordering at
    /// encode time we sort by id one layer up, so insertion-order is
    /// only diagnostic.
    private static func parseMessage(name: String, entry: [String: Any]) -> MessageDescriptor {
        var fields: [FieldInfo] = []
        if let fieldsJson = entry["fields"] as? [String: Any] {
            // Sort by id to give a stable output independent of dict order.
            let pairs: [(String, [String: Any])] = fieldsJson.compactMap { key, raw in
                guard let f = raw as? [String: Any] else { return nil }
                return (key, f)
            }
            let sorted = pairs.sorted { lhs, rhs in
                let l = (lhs.1["id"] as? Int) ?? Int.max
                let r = (rhs.1["id"] as? Int) ?? Int.max
                return l < r
            }
            for (fieldName, f) in sorted {
                let id = (f["id"] as? Int) ?? -1
                let type = (f["type"] as? String) ?? ""
                let rule = f["rule"] as? String
                let keyType = f["keyType"] as? String
                let repeated = rule == "repeated"
                // Mark `messageType` only when the field's type isn't a
                // scalar / map. Phase 3 will tighten this once the bridge
                // layer exists; for now mirror the simple test in TS.
                let messageType: String? = Scalars.ScalarType.from(typeName: type) == nil
                    ? type
                    : nil
                fields.append(FieldInfo(
                    id: id,
                    name: fieldName,
                    type: type,
                    messageType: messageType,
                    repeated: repeated,
                    rule: rule,
                    keyType: keyType
                ))
            }
        }

        var oneofs: [String: [String]] = [:]
        if let oneofsJson = entry["oneofs"] as? [String: Any] {
            for (groupName, raw) in oneofsJson {
                guard let group = raw as? [String: Any],
                      let members = group["oneof"] as? [String] else { continue }
                oneofs[groupName] = members
            }
        }

        return MessageDescriptor(name: name, fields: fields, oneofs: oneofs)
    }

    private static func parseEnum(values: [String: Any]) -> [String: Int] {
        var out: [String: Int] = [:]
        for (k, v) in values {
            if let n = v as? Int {
                out[k] = n
            }
        }
        return out
    }

    // MARK: - typeUrl mapping

    /// Build typeUrl mappings per `core/proto/lib/schema.js createTypeUrls`
    /// rules. Mirrors Kotlin `FieldResolver.buildTypeUrls`.
    ///
    ///  - Name ending in `Tx`     → `fg:t:<snake>`
    ///  - Name ending in `State`  → `fg:s:<snake>`
    ///  - Prefix `StakeFor`       → `fg:x:stake_<snake>`
    ///  - `TransactionInfo`       → `fg:x:transaction_info`
    ///  - `AssetFactoryState`     → `fg:s:asset_factory_state`
    ///  - `AssetFactory`          → `fg:x:asset_factory`
    ///  - `DummyCodec`            → `fg:x:address`
    ///  - Prefix `Request`/`Response` → no remap
    private static func buildTypeUrls() {
        for name in messages.keys {
            if name.hasPrefix("Request") || name.hasPrefix("Response") {
                typeUrlByName[name] = name
                nameByTypeUrl[name] = name
                continue
            }

            let url: String
            switch name {
            case "AssetFactoryState":
                url = "fg:s:asset_factory_state"
            case "AssetFactory":
                url = "fg:x:asset_factory"
            case "DummyCodec":
                url = "fg:x:address"
            case "TransactionInfo":
                url = "fg:x:\(toSnakeCase(name))"
            default:
                if name.hasPrefix("StakeFor") {
                    let suffix = String(name.dropFirst("StakeFor".count))
                    url = "fg:x:\(toSnakeCase("Stake" + suffix))"
                } else if name.hasSuffix("Tx") {
                    let stem = String(name.dropLast(2))
                    url = "fg:t:\(toSnakeCase(stem))"
                } else if name.hasSuffix("State") {
                    let stem = String(name.dropLast(5))
                    url = "fg:s:\(toSnakeCase(stem))"
                } else {
                    url = name
                }
            }

            typeUrlByName[name] = url
            nameByTypeUrl[url] = name
        }

        // Unconditional overrides — some runtime typeUrls (DummyCodec,
        // AssetFactory) don't appear as schema entries but wallets must
        // still resolve them.
        let overrides: [(String, String)] = [
            ("AssetFactoryState", "fg:s:asset_factory_state"),
            ("AssetFactory", "fg:x:asset_factory"),
            ("DummyCodec", "fg:x:address"),
            ("TransactionInfo", "fg:x:transaction_info")
        ]
        for (name, url) in overrides {
            typeUrlByName[name] = url
            nameByTypeUrl[url] = name
        }
    }

    /// JS-equivalent `lowerUnder`: insert `_` before each uppercase letter
    /// (except at index 0), lowercase the result. `TransferV2 → transfer_v2`,
    /// `AccountMigrate → account_migrate`.
    private static func toSnakeCase(_ input: String) -> String {
        if input.isEmpty { return input }
        var out = ""
        out.reserveCapacity(input.count + 4)
        for (i, ch) in input.enumerated() {
            if i > 0 && ch.isUppercase {
                out.append("_")
            }
            out.append(Character(ch.lowercased()))
        }
        return out
    }
}

/// Empty class used only as a token for `Bundle(for:)`. Anchors the bundle
/// lookup to whatever framework / test bundle this file is compiled into.
private final class BundleToken {}
