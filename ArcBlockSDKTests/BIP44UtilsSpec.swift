// BIP44UtilsSpec.swift
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

import Quick
import Nimble
import web3swift
import ArcBlockSDK

class BIP44UtilsSpec: QuickSpec {
    override func spec() {
        describe("BIP 44 key generation") {
            it("works", closure: {
                let secretCode = "123456"
                let recoveryCode = "MzeR6VFvemuWXooxxGzeFP"
                guard let seed = BIP44Utils.generateSeed(secretCode: secretCode, recoveryCode: recoveryCode) else {
//                    _ = throwAssertion()
                    return
                }
                let path = HDNode.defaultPathMetamask
                let childSeed = BIP44Utils.generateChildSeed(seed: seed, path: path)
                let privateKey = BIP44Utils.generatePrivateKey(seed: seed, path: path)
                expect(seed.base64EncodedString()).to(equal("NxwhITc5zKDVZvvM1661+HZ/zz9M2my9e6zkgMF/uhKOldgHEi1m5sxX/XuhPamdyjJq/XRiHQMZelTlEYI3tA=="))
                expect(privateKey?.toHexString()).to(equal("7e72fea21398acd41cdccad0ea8797d2aac82ff08308ab75045e3a054997ef35"))
                expect(privateKey?.toHexString()).to(equal(BIP44Utils.generatePrivateKey(data: childSeed!)?.toHexString()))
            })
        }

        describe("ETH key generation") {
            it("works", closure: {
                guard let seed = Data(base64Encoded: "MzyV7t37IJusabYK4zAks57as4ZSKKOuXuJVqH6DJSn2h794sXnIL4UBpijTf9oyDnM4wWOyoy/kkepfoiA1wg==") else {
//                    _ = throwAssertion()
                    return
                }
                let privateKey = BIP44Utils.generatePrivateKey(seed: seed, path: HDNode.defaultPathMetamask)
                let publicKey = Web3.Utils.privateToPublic(privateKey!, compressed: true)
                let address = Web3.Utils.publicToAddressString(publicKey!)
                expect(privateKey?.toHexString()).to(equal("df29f1911c6264d76feb7d482e83b55a95a3f1df4fe0f4d208b8be2c44142f68"))
                expect(address).to(equal("0x30a61514525283de572e521afee0500a6b0dee8c"))
            })
        }
    }
}
