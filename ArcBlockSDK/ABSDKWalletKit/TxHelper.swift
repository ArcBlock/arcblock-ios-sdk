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

import Foundation
import SwiftProtobuf
import BigInt

public struct TxParams {
    var hashType: ForgeAbi_HashType
    var keyType: ForgeAbi_KeyType
    var chainId: String
    var from: String
    var nonce: UInt64

    public init(hashType: ForgeAbi_HashType, keyType: ForgeAbi_KeyType,
         chainId: String, from: String, nonce: UInt64? = nil) {
        self.hashType = hashType
        self.keyType = keyType
        self.chainId = chainId
        self.from = from
        if let nonce = nonce {
            self.nonce = nonce
        } else {
            self.nonce = UInt64(Date.init().timeIntervalSince1970 * 1000)
        }
    }
}

public class TxHelper {
    public static func createDeclareTx(chainId: String, publicKey: Data, privateKey: Data, address: String) -> String? {
        var declareTx = ForgeAbi_DeclareTx.init()
        var walletType = ForgeAbi_WalletType.init()
        walletType.pk = ForgeAbi_KeyType.ed25519
        walletType.hash = ForgeAbi_HashType.sha3
        walletType.address = ForgeAbi_EncodingType.base58
        declareTx.moniker = "account"

        guard let tx = try? declareTx.serializedData() else {
            return nil
        }
        let txParams = TxParams(hashType: ForgeAbi_HashType.sha3, keyType: ForgeAbi_KeyType.ed25519,
                                chainId: chainId, from: address)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.declare.rawValue, txParams: txParams, privateKey: privateKey, publicKey: publicKey)
        return txString
    }

    public static func createSetupSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, demandToken: Double,
                                  blockHeight: UInt32, hashKey: Data, receiver: String) -> String? {
        var setupSwapTx = ForgeAbi_SetupSwapTx()

        var demandTokenValue = ForgeAbi_BigUint()
        let demandTokenBigUInt = BigUInt(demandToken)
        demandTokenValue.value = demandTokenBigUInt.serialize()
        setupSwapTx.value = demandTokenValue

        setupSwapTx.locktime = blockHeight
        setupSwapTx.hashlock = MCrypto.Hasher.Sha3.sha(hashKey)
        setupSwapTx.receiver = receiver

        guard let tx = try? setupSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: ForgeAbi_HashType.sha3, keyType: ForgeAbi_KeyType.ed25519,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.setupSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createRetrieveSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, swapAddress: String, hashKey: Data) -> String? {
        var retrieveSwapTx = ForgeAbi_RetrieveSwapTx()

        retrieveSwapTx.address = swapAddress
        retrieveSwapTx.hashkey = hashKey

        guard let tx = try? retrieveSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: ForgeAbi_HashType.sha3, keyType: ForgeAbi_KeyType.ed25519,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.retrieveSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createRevokeSwapTx(chainId: String, publicKey: Data, privateKey: Data, from: String, swapAddress: String) -> String? {
        var revokeSwapTx = ForgeAbi_RevokeSwapTx()

        revokeSwapTx.address = swapAddress

        guard let tx = try? revokeSwapTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: ForgeAbi_HashType.sha3, keyType: ForgeAbi_KeyType.ed25519,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.revokeSwap.rawValue, txParams: txParams,
                                   privateKey: privateKey, publicKey: publicKey)

        return txString
    }

    public static func createTransferTx(chainId: String, publicKey: Data, privateKey: Data, from: String, to: String, message: String?, value: Double, decimal: Int? = nil) -> String? {

        var transferTx = ForgeAbi_TransferTx.init()
        var txMessage = Google_Protobuf_Any.init()

        if let message = message,
            let temp = message.data(using: .utf8) {
            txMessage.value = temp
        }

        transferTx.data = txMessage
        transferTx.to = to
        var txValue = ForgeAbi_BigUint.init()
        if let decimal = decimal,
            let decimals = Double("1e\(decimal)") {
            let valueWithDecimals = BigUInt(value * decimals)
            txValue.value = valueWithDecimals.serialize()
        } else {
            let valueBigUInt = BigUInt(value)
            txValue.value = valueBigUInt.serialize()
        }
        transferTx.value = txValue

        guard let tx = try? transferTx.serializedData() else {
            return nil
        }

        let txParams = TxParams(hashType: ForgeAbi_HashType.sha3, keyType: ForgeAbi_KeyType.ed25519,
                                chainId: chainId, from: from)
        let txString = genTxString(tx: tx, typeUrl: TypeUrl.transfer.rawValue,
                                   txParams: txParams, privateKey: privateKey, publicKey: publicKey)
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

    private static func composePartialTxData(tx: Data, typeUrl: String, txParams: TxParams, publicKey: Data) -> ForgeAbi_Transaction {
        var anyMessage = Google_Protobuf_Any.init()
        anyMessage.value = tx
        anyMessage.typeURL = typeUrl

        var transaction = ForgeAbi_Transaction.init()
        transaction.chainID = txParams.chainId
        transaction.from = txParams.from
        transaction.itx = anyMessage
        transaction.nonce = txParams.nonce
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
        default:
            signature = nil
        }

        return signature
    }

    public static func decodeTxString(txString: String) -> ForgeAbi_Transaction? {
        guard let transactionData = Data.init(multibaseEncoded: txString),
            let transaction = try? ForgeAbi_Transaction(serializedData: transactionData) else { return nil }
        return transaction
    }
}