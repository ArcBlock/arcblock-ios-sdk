// TxHelper.swift
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

// swiftlint:disable function_parameter_count

import Foundation
import SwiftProtobuf
import BigInt
import web3swift

public struct TxParams {
    var hashType: HashType
    var keyType: KeyType
    var chainId: String
    var from: String
    var nonce: UInt64
    var delegatee: String?

    public init(hashType: HashType, keyType: KeyType,
                chainId: String, from: String, nonce: UInt64? = nil, delegatee: String? = nil) {
        self.hashType = hashType
        self.keyType = keyType
        self.chainId = chainId
        self.from = from
        if let nonce = nonce {
            self.nonce = nonce
        } else {
            self.nonce = UInt64(Date.init().timeIntervalSince1970 * 1000)
        }
        self.delegatee = delegatee
    }
}

public class TxHelper {
    public static func createDeclareTx(chainId: String, issuer: String? = nil, moniker: String? = nil, publicKey: Data, privateKey: Data, address: String, didType: DidType) -> String? {
        var declareTx = Ocap_DeclareTx()
        
        declareTx.moniker = moniker ?? "account"
        if let issuer = issuer {
            declareTx.issuer = issuer
        }

        guard let tx = try? declareTx.serializedData() else {
            return nil
        }
        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: address)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.declare.rawValue, txParams: txParams, privateKey: privateKey, publicKey: publicKey)
        return txString
    }

    public static func createSetupSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, delegatee: String? = nil,
                                         demandToken: Double, demandAssets: [String] = [], blockHeight: UInt32, hashKey: Data, receiver: String, didType: DidType) -> String? {
        var setupSwapTx = Ocap_SetupSwapTx()

        var demandTokenValue = Ocap_BigUint()
        let demandTokenBigUInt = BigUInt(demandToken)
        demandTokenValue.value = demandTokenBigUInt.serialize()
        setupSwapTx.value = demandTokenValue

        setupSwapTx.locktime = blockHeight
        setupSwapTx.hashlock = MCrypto.Hasher.Sha3.sha(hashKey)
        setupSwapTx.receiver = receiver
        setupSwapTx.assets = demandAssets

        guard let tx = try? setupSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from, delegatee: delegatee)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.setupSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createRetrieveSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, swapAddress: String, hashKey: Data, didType: DidType)  -> String? {
        var retrieveSwapTx = Ocap_RetrieveSwapTx()

        retrieveSwapTx.address = swapAddress
        retrieveSwapTx.hashkey = hashKey

        guard let tx = try? retrieveSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.retrieveSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createRevokeSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, delegatee: String? = nil,
                                          swapAddress: String, didType: DidType)  -> String? {
        var revokeSwapTx = Ocap_RevokeSwapTx()

        revokeSwapTx.address = swapAddress

        guard let tx = try? revokeSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from, delegatee: delegatee)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.revokeSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createTransferTx(chainId: String, publicKey: Data, privateKey: Data, from: String, delegatee: String? = nil,
                                        to: String, message: String?, value: BigUInt, assets: [String]? = nil, didType: DidType)  -> String? {

        var transferTx = Ocap_TransferTx()
        var txMessage = Google_Protobuf_Any.init()

        if let message = message,
            let temp = message.data(using: .utf8) {
            txMessage.value = temp
        }

        transferTx.data = txMessage
        transferTx.to = to
        var txValue = Ocap_BigUint()
        txValue.value = value.serialize()
        transferTx.value = txValue
        
        if let assets = assets {
            transferTx.assets = assets
        }

        guard let tx = try? transferTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from, delegatee: delegatee)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.transfer.rawValue,
                                   txParams: txParams, privateKey: privateKey, publicKey: publicKey)
        return txString
    }

    public static func createWithdrawTokenTx(chainId: String, publicKey: Data, privateKey: Data, from: String, delegatee: String? = nil,
                                        to: String, chainType: String, foreignChainId: String, ttl: Date, value: BigUInt, didType: DidType)  -> String? {
        var withdrawTokenTx = Ocap_WithdrawTokenTx()
        withdrawTokenTx.to = to
        withdrawTokenTx.chainID = foreignChainId
        withdrawTokenTx.ttl = Google_Protobuf_Timestamp(date: ttl)
        withdrawTokenTx.chainType = chainType
        var txValue = Ocap_BigUint()
        txValue.value = value.serialize()
        withdrawTokenTx.value = txValue

        guard let tx = try? withdrawTokenTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from, delegatee: delegatee)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.withdrawToken.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createDelegateTx(chainId: String, publicKey: Data, privateKey: Data, from: String,
                                        to: String, ops: [String: [String]], didType: DidType)  -> String? {
        guard let delegateAddress = DidHelper.getDelegateAddress(sender: from, receiver: to),
            ops.count > 0 else {
            return nil
        }
        var delegateTx = Ocap_DelegateTx()
        delegateTx.address = delegateAddress
        var delegateOps = [Ocap_DelegateOp]()
        for (typeUrl, rules) in ops {
            var op = Ocap_DelegateOp()
            op.typeURL = typeUrl
            op.rules = rules
            delegateOps.append(op)
        }
        delegateTx.ops = delegateOps
        delegateTx.to = to

        guard let tx = try? delegateTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.delegate.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func genTxString(tx: Data, typeUrl: String, txParams: TxParams, privateKey: Data, publicKey: Data) -> String? {

        var transaction = composePartialTxData(tx: tx, typeUrl: typeUrl,
                                              txParams: txParams, publicKey: publicKey)

        guard let partialTxData = try? transaction.serializedData(),
            let sig = calculateSignature(txParams: txParams, partialTxData: partialTxData, privateKey: privateKey) else {
            return nil
        }

        transaction.signature = sig

        guard let data = try? transaction.serializedData() else {
            return nil
        }
        return data.base64URLPadEncodedString()
    }

    public static func genTxSignature(tx: Data, typeUrl: String,
                               txParams: TxParams, privateKey: Data, publicKey: Data) -> String? {

        let transaction = composePartialTxData(tx: tx, typeUrl: typeUrl,
                                              txParams: txParams, publicKey: publicKey)
        guard let partialTxData = try? transaction.serializedData(),
            let sig = calculateSignature(txParams: txParams, partialTxData: partialTxData, privateKey: privateKey) else {
            return nil
        }

        return sig.base64URLPadEncodedString()
    }

    private static func composePartialTxData(tx: Data, typeUrl: String, txParams: TxParams, publicKey: Data) -> Ocap_Transaction {
        var anyMessage = Google_Protobuf_Any.init()
        anyMessage.value = tx
        anyMessage.typeURL = typeUrl

        var transaction = Ocap_Transaction.init()
        transaction.chainID = txParams.chainId
        transaction.from = txParams.from
        transaction.itx = anyMessage
        transaction.nonce = txParams.nonce
        if let delegatee = txParams.delegatee {
            transaction.delegator = txParams.from
            transaction.from = delegatee
        }
        transaction.pk = publicKey

        return transaction
    }

    private static func calculateSignature(txParams: TxParams, partialTxData: Data, privateKey: Data) -> Data? {
        var contentHash: Data?
        switch txParams.hashType {
        case .keccak:
            contentHash = MCrypto.Hasher.Keccakf1600.sha256(partialTxData)
        case .sha3:
            contentHash = MCrypto.Hasher.Sha3.sha256(partialTxData)
        case .keccak384:
            contentHash = MCrypto.Hasher.Keccakf1600.sha384(partialTxData)
        case .sha3384:
            contentHash = MCrypto.Hasher.Sha3.sha384(partialTxData)
        case .keccak512:
            contentHash = MCrypto.Hasher.Keccakf1600.sha512(partialTxData)
        case .sha3512:
            contentHash = MCrypto.Hasher.Sha3.sha512(partialTxData)
        default:
            contentHash = nil
        }

        guard let message = contentHash else {
            return nil
        }

        var signature: Data?
        switch txParams.keyType {
        case .ed25519:
            signature = MCrypto.Signer.ED25519.sign(message: message, privateKey: privateKey)
        case .secp256k1:
            signature = MCrypto.Signer.M_SECP256K1.sign(message: message, privateKey: privateKey)
        case .ethereum:
            signature = MCrypto.Signer.ETHEREUM.sign(message: message, privateKey: privateKey)
        }

        return signature
    }

    public static func decodeTxString(txString: String) -> Ocap_Transaction? {
        guard let transactionData = Data.init(multibaseEncoded: txString),
            let transaction = try? Ocap_Transaction(serializedData: transactionData) else { return nil }
        return transaction
    }
    
    // MARK: - Ocap V2
    public static func createTransferSecondaryTx(chainId: String, publicKey: Data, privateKey: Data, from: String, delegatee: String? = nil,
                                                 to: String, message: String?, value: String, assets: [String]? = nil, didType: DidType, tokenAddress: String)  -> String? {

        var transferTx = Ocap_TransferV2Tx()
        var txMessage = Google_Protobuf_Any.init()

        if let message = message,
            let temp = message.data(using: .utf8) {
            txMessage.value = temp
        }

        transferTx.data = txMessage
        transferTx.to = to
        
        var tokens = [Ocap_TokenPayload]()
        var token = Ocap_TokenPayload()
        token.address = tokenAddress
        token.value = value
        tokens.append(token)
        transferTx.tokens = tokens
        
        if let assets = assets {
            transferTx.assets = assets
        }

        guard let tx = try? transferTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                chainId: chainId, from: from, delegatee: delegatee)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.transfer_v2.rawValue,
                                   txParams: txParams, privateKey: privateKey, publicKey: publicKey)
        return txString
    }
}
