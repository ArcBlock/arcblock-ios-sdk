// TypeUrl.swift
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

public enum TypeUrl: String, CaseIterable {
    case accountMigrate = "fg:t:account_migrate"
    case acquireAsset = "fg:t:acquire_asset"
    case acquireAsset_v2 = "fg:t:acquire_asset_v2"
    case createAsset = "fg:t:create_asset"
    case consumeAsset = "fg:t:consume_asset"
    case declare = "fg:t:declare"
    case exchange = "fg:t:exchange"
    case exchange_v2 = "fg:t:exchange_v2"
    case poke = "fg:t:poke"
    case stake = "fg:t:stake"
    case transfer = "fg:t:transfer"
    case transfer_v2 = "fg:t:transfer_v2"
    case updateAsset = "fg:t:update_asset"
    case depositTether = "fg:t:deposit_tether"
    case exchangeTether = "fg:t:exchange_tether"
    case setupSwap = "fg:t:setup_swap"
    case retrieveSwap = "fg:t:retrieve_swap"
    case revokeSwap = "fg:t:revoke_swap"
    case delegate = "fg:t:delegate"
    case revokeDelegate = "fg:t:revoke_delegate"
    case depositToken = "fg:t:deposit_token"
    case withdrawToken = "fg:t:withdraw_token"
    case revokeWithdraw = "fg:t:revoke_withdraw"

    // v3
    case acquireAsset_v3 = "fg:t:acquire_asset_v3"
    case transfer_v3 = "fg:t:transfer_v3"
    
    // forge state
    case accountState = "fg:s:account"
    case assetState = "fg:s:asset"
    case forgeState = "fg:s:forge"
    case stakeState = "fg:s:stake"
    case statisticsState = "fg:s:statistics"

    // forge tx stake
    case stakeForNode = "fg:x:stake_node"
    case stakeForUser = "fg:x:stake_user"
    case stakeForAsset = "fg:x:stake_asset"
    case stakeForChain = "fg:x:stake_chain"

    //
    case transaction = "fg:x:tx"
    case transactionInfo = "fg:x:tx_info"
    case txStatus = "fg:x:tx_status"
    case address = "fg:x:account_migrate"
    case assetFactoryState = "fg:s:asset_factory_state"

    // asset protocol
    case certificate = "ws:x:certificate"
    case eventInfo = "ec:s:event_info"
    case ticketInfo = "ec:s:ticket_info"
    case workshopAsset = "ws:x:workshop_asset"
    case generalTicket = "ec:s:general_ticket"
    case jsonAsset = "json"
    case vcAsset = "vc"

    public func getItx(value: Data) -> Any? {
        switch self {
        case .accountMigrate:
            return try? Ocap_AccountMigrateTx(serializedData: value)
        case .acquireAsset:
            return try? Ocap_AcquireAssetTx(serializedData: value)
        case .createAsset:
            return try? Ocap_CreateAssetTx(serializedData: value)
        case .consumeAsset:
            return try? Ocap_ConsumeAssetTx(serializedData: value)
        case .declare:
            return try? Ocap_DeclareTx(serializedData: value)
        case .exchange:
            return try? Ocap_ExchangeTx(serializedData: value)
        case .poke:
            return try? Ocap_PokeTx(serializedData: value)
        case .transfer:
            return try? Ocap_TransferTx(serializedData: value)
        case .updateAsset:
            return try? Ocap_UpdateAssetTx(serializedData: value)
        case .setupSwap:
            return try? Ocap_SetupSwapTx(serializedData: value)
        case .retrieveSwap:
            return try? Ocap_RetrieveSwapTx(serializedData: value)
        case .revokeSwap:
            return try? Ocap_RevokeSwapTx(serializedData: value)
        case .delegate:
            return try? Ocap_DelegateTx(serializedData: value)
        case .revokeDelegate:
            return try? Ocap_RevokeDelegateTx(serializedData: value)
        case .withdrawToken:
            return try? Ocap_WithdrawTokenTx(serializedData: value)
        case .revokeWithdraw:
            return try? Ocap_RevokeWithdrawTx(serializedData: value)
        case .transfer_v2:
            return try? Ocap_TransferV2Tx(serializedData: value)
        case .exchange_v2:
            return try? Ocap_ExchangeV2Tx(serializedData: value)
        case .acquireAsset_v2:
            return try? Ocap_AcquireAssetV2Tx(serializedData: value)
        case .acquireAsset_v3:
            return try? Ocap_AcquireAssetV3Tx(serializedData: value)
        case .transfer_v3:
            return try? Ocap_TransferV3Tx(serializedData: value)
        default:
            return nil
        }
    }

    public func getState(value: Data) -> Any? {
        switch self {
        case .accountState:
            return try? Ocap_AccountState(serializedData: value)
        case .assetState:
            return try? Ocap_AssetState(serializedData: value)
        case .forgeState:
            return try? Ocap_ForgeState(serializedData: value)
        case .stakeState:
            return try? Ocap_StakeState(serializedData: value)
        case .statisticsState:
            return try? Ocap_StatisticsState(serializedData: value)
        default:
            return nil
        }
    }
}
