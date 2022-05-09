// TxHelperSpec.swift
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
//  swiftlint:disable line_length

import Quick
import Nimble
import CryptoSwift
import ArcBlockSDK

class TxHelperSpec: QuickSpec {
    override func spec() {
        
        describe("decode tx") {
            it("works", closure: {
                let txString = "z31yJQ2TQNnofst5GGktyVpeJdQbN971GD9CsCFE2ff7zeHFdKshsJpJdpfYBaYoPc9m21TxuJW9cZBaFJjbwFxrGqDdbjKq71Q4jBWiXL9NhJ9tD6rBNf3gD1UktUd6m2xBk7Jq7PD6dVdp6Mr1tj5ybDXns3TZRmypSygvg1SjTXxWMyPMrayAPdUQ2Z9vycbdLuqPzgwgqdCTxv1V9WKp7e5bY1mQX"
                TxHelper.decodeTxString(txString: txString)
            })
        }
        
        describe("create transferV2 tx") {
            it("works", closure: {
                let txString = "CiN6MVJoVFZmNXZmTDN1TFNBMkd1WExLdURZSHYyZjJwSnNGRxABGgRiZXRhIiCiFCQRpunfXsMwf4ynTfeZM0-VI_OKDDhgNF-EkXoCkmpAqWjSdQo3M4ZffED4Izqg5M5DS5eGsirWBTWjAdg7VXEgMB8JF_7bPiGvDFBMer-5cI_BslDjBKd_SxlGm06GBXp4ChBmZzp0OnRyYW5zZmVyX3YyEmQKJHpOS2VMS2l4dkNNMzJUa1ZNMXptUkRkQVUzYnZtM2RUdEFjTSI8CiV6MzVuM1dWVG5ON0tyUjRnWG4zc3pSNm9uZVZlZmtCQng3OEZjEhMxMDAwMDAwMDAwMDAwMDAwMDAwigEBMA"
                let sk = Data(base64URLPadEncoded: "IamB8ReOa-YlX8gTI1m0F1r-er-tj5-6Afe0pW-gxXY")!
                let pk = Data(base64URLPadEncoded: "ohQkEabp317DMH-Mp033mTNPlSPzigw4YDRfhJF6ApI")!
                let sig = Data(hex: "a968d2750a3733865f7c40f8233aa0e4ce434b9786b22ad60535a301d83b557120301f0917fedb3e21af0c504c7abfb9708fc1b250e304a77f4b19469b4e8605")
                
                let chainId = "beta"
                let from = "z1RhTVf5vfL3uLSA2GuXLKuDYHv2f2pJsFG"
                let to = "zNKeLKixvCM32TkVM1zmRDdAU3bvm3dTtAcM"
                let didType = DidHelper.calculateTypesFromDid(did: from)!
                
                var transferTx = Ocap_TransferV2Tx()

                transferTx.to = to
                
                var tokens = [Ocap_TokenInput]()
                var token = Ocap_TokenInput()
                token.address = "z35n3WVTnN7KrR4gXn3szR6oneVefkBBx78Fc"
                token.value = "1000000000000000000"
                tokens.append(token)
                
                transferTx.tokens = tokens

                guard let tx = try? transferTx.serializedData() else {
                    return 
                }
                
                let txParams = TxParams(hashType: didType.hashType, keyType: didType.keyType,
                                        chainId: chainId, from: from, nonce: 1, delegatee: nil)
                var transaction = TxHelper.composePartialTxData(tx: tx, typeUrl: TypeUrl.transfer_v2.rawValue,
                                                      txParams: txParams, publicKey: pk)
                // 此测试用例要控制nonce 和 signature 才能保证结果一致
                transaction.signature = sig
                let value = try? transaction.serializedData().base64URLPadEncodedString()
                
                expect(value).to(equal(txString))
            })
        }
    }
}
