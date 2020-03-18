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
    case createAsset = "fg:t:create_asset"
    case consumeAsset = "fg:t:consume_asset"
    case declare = "fg:t:declare"
    case exchange = "fg:t:exchange"
    case poke = "fg:t:poke"
    case stake = "fg:t:stake"
    case transfer = "fg:t:transfer"
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
            return try? ForgeAbi_AccountMigrateTx(serializedData: value)
        case .acquireAsset:
            return try? ForgeAbi_AcquireAssetTx(serializedData: value)
        case .createAsset:
            return try? ForgeAbi_CreateAssetTx(serializedData: value)
        case .consumeAsset:
            return try? ForgeAbi_ConsumeAssetTx(serializedData: value)
        case .declare:
            return try? ForgeAbi_DeclareTx(serializedData: value)
        case .exchange:
            return try? ForgeAbi_ExchangeTx(serializedData: value)
        case .poke:
            return try? ForgeAbi_PokeTx(serializedData: value)
        case .stake:
            return try? ForgeAbi_StakeTx(serializedData: value)
        case .transfer:
            return try? ForgeAbi_TransferTx(serializedData: value)
        case .updateAsset:
            return try? ForgeAbi_UpdateAssetTx(serializedData: value)
        case .depositTether:
            return try? ForgeAbi_DepositTetherTx(serializedData: value)
        case .exchangeTether:
            return try? ForgeAbi_ExchangeTetherTx(serializedData: value)
        case .setupSwap:
            return try? ForgeAbi_SetupSwapTx(serializedData: value)
        case .retrieveSwap:
            return try? ForgeAbi_RetrieveSwapTx(serializedData: value)
        case .revokeSwap:
            return try? ForgeAbi_RevokeSwapTx(serializedData: value)
        case .delegate:
            return try? ForgeAbi_DelegateTx(serializedData: value)
        case .revokeDelegate:
            return try? ForgeAbi_RevokeDelegationTx(serializedData: value)
        case .withdrawToken:
            return try? ForgeAbi_WithdrawTokenTx(serializedData: value)
        case .revokeWithdraw:
            return try? ForgeAbi_RevokeWithdrawTx(serializedData: value)
        default:
            return nil
        }
    }

    public func getState(value: Data) -> Any? {
        switch self {
        case .accountState:
            return try? ForgeAbi_AccountState(serializedData: value)
        case .assetState:
            return try? ForgeAbi_AssetState(serializedData: value)
        case .forgeState:
            return try? ForgeAbi_ForgeState(serializedData: value)
        case .stakeState:
            return try? ForgeAbi_StakeState(serializedData: value)
        case .statisticsState:
            return try? ForgeAbi_StatisticsState(serializedData: value)
        default:
            return nil
        }
    }

    public func getAsset(value: Data) -> Any? {
        switch self {
        case .certificate:
            if let string = String.init(data: value, encoding: .utf8),
                let data = Data.init(base64URLPadEncoded: string) {
                return try? AssetProtocol_Certificate(serializedData: data)
            }
            return try? AssetProtocol_Certificate(serializedData: value)
        case .eventInfo:
            if let string = String.init(data: value, encoding: .utf8),
                let data = Data.init(base64URLPadEncoded: string) {
                return try? AssetProtocol_EventInfo(serializedData: data)
            }
            return try? AssetProtocol_EventInfo(serializedData: value)
        case .ticketInfo:
            return try? AssetProtocol_TicketInfo(serializedData: value)
        case .workshopAsset:
            if let string = String.init(data: value, encoding: .utf8),
                let data = Data.init(base64URLPadEncoded: string) {
                return try? AbtDidWorkshop_WorkshopAsset(serializedData: data)
            }
            return try? AbtDidWorkshop_WorkshopAsset(serializedData: value)
        case .generalTicket:
            if let string = String.init(data: value, encoding: .utf8),
                let data = Data(base64URLPadEncoded: string) {
                return try? AssetProtocol_GeneralTicket(serializedData: data)
            }
            return try? AssetProtocol_GeneralTicket(serializedData: value)
        case .assetFactoryState:
            if let string = String.init(data: value, encoding: .utf8),
                let data = Data(base64URLPadEncoded: string) {
                return try? ForgeAbi_AssetFactoryState(serializedData: data)
            }
            return try? ForgeAbi_AssetFactoryState(serializedData: value)
        default:
            return nil
        }
    }
}
