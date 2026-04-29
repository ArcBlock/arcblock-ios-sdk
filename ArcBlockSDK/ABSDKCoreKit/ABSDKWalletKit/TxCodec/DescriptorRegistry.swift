// DescriptorRegistry.swift
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

/// typeUrl ⇄ `SwiftProtobuf.Message.Type` lookup for the OCAP itx universe.
///
/// `FieldResolver` answers schema-shape questions (fields, oneofs, enum
/// membership). `DescriptorRegistry` answers a different question — given a
/// canonical typeUrl, which generated SwiftProtobuf type should I instantiate
/// to land the bytes? Keeping the two concerns in separate files removes the
/// awkward `FieldResolver.typeUrlToMessageType` reach-through that phase 3
/// added before we knew there'd be a TxCodec layer to host it.
///
/// Phase 5 hardcodes the table because the OCAP itx universe is tiny and slow-
/// moving (11 entries today). Codegen from `ocap-spec.core.json` is on the
/// long-term roadmap; until then a new itx type means appending one line here.
///
/// **Threading**: `messageType(forTypeUrl:)` and `typeUrl(for:)` are pure reads
/// from immutable `let` storage. Safe to call from any thread without locks.
public enum DescriptorRegistry {

    // MARK: - Source of truth

    /// Hardcoded mapping from OCAP typeUrl to the generated SwiftProtobuf
    /// `Message.Type`. Each pair is bidirectional — `typeUrl(for:)` walks
    /// the inverse via ObjectIdentifier so we don't pay double the storage.
    ///
    /// The OPAQUE typeUrls (`"json"`, `"vc"`, `"fg:x:address"`) are
    /// deliberately absent: those are not protobuf messages, so callers
    /// must check `CanonicalCBOR.OPAQUE_TYPE_URLS` first and route through
    /// the OPAQUE Any branch instead of asking this registry.
    private static let entries: [(url: String, type: SwiftProtobuf.Message.Type)] = [
        ("fg:t:transfer_v2",      Ocap_TransferV2Tx.self),
        ("fg:t:transfer_v3",      Ocap_TransferV3Tx.self),
        ("fg:t:exchange_v2",      Ocap_ExchangeV2Tx.self),
        ("fg:t:delegate",         Ocap_DelegateTx.self),
        ("fg:t:revoke_delegate",  Ocap_RevokeDelegateTx.self),
        ("fg:t:stake",            Ocap_StakeTx.self),
        ("fg:t:account_migrate",  Ocap_AccountMigrateTx.self),
        ("fg:t:acquire_asset_v3", Ocap_AcquireAssetV3Tx.self),
        ("fg:t:acquire_asset_v2", Ocap_AcquireAssetV2Tx.self),
        ("fg:t:consume_asset",    Ocap_ConsumeAssetTx.self),
        ("fg:t:declare",          Ocap_DeclareTx.self),
    ]

    /// Forward index: typeUrl → Message.Type. Built once at module load.
    private static let urlToType: [String: SwiftProtobuf.Message.Type] = {
        var out: [String: SwiftProtobuf.Message.Type] = [:]
        out.reserveCapacity(entries.count)
        for (url, type) in entries { out[url] = type }
        return out
    }()

    /// Inverse index: Message.Type → typeUrl. Keyed by `ObjectIdentifier` of
    /// the metatype because `Message.Type` itself is not Hashable. Built
    /// once at module load.
    private static let typeToUrl: [ObjectIdentifier: String] = {
        var out: [ObjectIdentifier: String] = [:]
        out.reserveCapacity(entries.count)
        for (url, type) in entries { out[ObjectIdentifier(type)] = url }
        return out
    }()

    // MARK: - Public API

    /// Look up the generated SwiftProtobuf type for a canonical typeUrl.
    ///
    /// Returns `nil` when the typeUrl is not in the registry. Callers that
    /// expect a hit should throw `CanonicalCBORError.unknownTypeUrl` on nil.
    /// OPAQUE typeUrls (`json` / `vc` / `fg:x:address`) intentionally return
    /// nil — they are not protobuf-shaped and must be routed through the
    /// `OpaqueAny` carrier instead.
    public static func messageType(forTypeUrl url: String) -> SwiftProtobuf.Message.Type? {
        return urlToType[url]
    }

    /// Inverse of `messageType(forTypeUrl:)`. Returns `nil` when the type is
    /// not registered. Useful for the encode side — given a concrete
    /// `Ocap_TransferV3Tx` value, which typeUrl should we stamp on the
    /// `google.protobuf.Any` envelope?
    public static func typeUrl(for messageType: any SwiftProtobuf.Message.Type) -> String? {
        return typeToUrl[ObjectIdentifier(messageType)]
    }

    /// Set of all registered typeUrls. Useful for the wallet to make
    /// forward-compat decisions ("is this a known-shape itx, or do we need
    /// to fall back to the OPAQUE renderer?").
    public static var knownTypeUrls: Set<String> {
        return Set(urlToType.keys)
    }
}
