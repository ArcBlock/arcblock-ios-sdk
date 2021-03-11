// DidManagerSpec.swift
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
import ArcBlockSDK
import web3swift

class DidHelperSpec: QuickSpec {
    override func spec() {
        describe("sk to did") {
            it("works", closure: {
                let privateKey = Data.init(hex: "D67C071B6F51D2B61180B9B1AA9BE0DD0704619F0E30453AB4A592B036EDE644E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7")
                let did = DidHelper.getUserDid(didType: DidType.Types.didTypeForgeApplication, privateKey: privateKey)
                expect(did).to(equal("did:abt:zNKtCNqYWLYWYW3gWRA1vnRykfCBZYHZvzKr"))
            })
        }

        describe("seed to did") {
            it("works", closure: {
                let seed = Data.init(hex: "07abfceff5cdfb0cd164d2da98099c15b7223fc5a1b8c02c2cf1f74670c72aac27e1d28ed47cf4f2c4330a6e6e1dc0724721e80fa56177fdba926937a253fe7e")
                let path = BIP44Utils.keyDerivePathForAppDid(appDid: "did:abt:z", index: 0)
                let privateKey = BIP44Utils.generatePrivateKey(seed: seed, path: path!)
                let did = DidHelper.getUserDid(didType: DidType.Types.didTypeForge, privateKey: privateKey!)
                expect(did).to(equal("did:abt:z1Zhi9h6do1EUNkM63CEXHonyHx47WQKtxB"))
            })
        }

        describe("verify did with pk") {
            it("works", closure: {
                let publicKey = "z7CaThvPHdaMd3HsnEbiC9986vZgiiVLGV5UhUzpW6fYx"
                let did = "did:abt:z115ZCfaB7LYj9i2uxr4hknJJMLe7GkZASY4"
                if let didType = DidHelper.calculateTypesFromDid(did: did) {
                    expect(DidHelper.getUserDid(didType: didType, publicKey: publicKey)).to(equal(did))
                }
            })
        }

        describe("generate swap address") {
            it("works", closure: {
                let data = Data(hex: "0E79AD918B562F7085DC5E5CAEE56A949BDAF3AC143FE0340F6EEB233FF8ED30")
                expect(DidHelper.getSwapAddress(data: data)).to(equal("z2UHsX5Gzj24oT81Kis6fekS1xTRvdejNqM88"))
            })
        }

        describe("generate delegate address") {
            it("works", closure: {
                let address = DidHelper.getDelegateAddress(sender: "z1ewYeWM7cLamiB6qy6mDHnzw1U5wEZCoj7", receiver: "z1T6maYajgDLjhVErT71WEbqaxaWHs9nqpZ")
                expect(address).to(equal("z2bN1iucQC2obei6B2cJrtp7d9zbVCKoceKEo"))
            })
        }
        
        describe("ethereum") {
            let etherumCase = [
                [
                    "secretKey" : "4646464646464646464646464646464646464646464646464646464646464646",
                    "publicKey" : "4BC2A31265153F07E70E0BAB08724E6B85E217F8CD628CEB62974247BB493382CE28CAB79AD7119EE1AD3EBCDB98A16805211530ECC6CFEFA1B88E6DFF99232A",
                    "address" : "0x9d8A62f656a8d1615C1294fd71e9CFb3E4855A4F"
                ],
                [
                    "secretKey" : "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef",
                    "publicKey" : "4646AE5047316B4230D0086C8ACEC687F00B1CD9D1DC634F6CB358AC0A9A8FFFFE77B4DD0A4BFB95851F3B7355C781DD60F8418FC8A65D14907AFF47C903A559",
                    "address" : "0xFCAd0B19bB29D4674531d6f115237E16AfCE377c"
                ]
            ]
            
            it("sk to address works", closure: {
                etherumCase.forEach { (dict) in
                    let sk = dict["secretKey"]!
                    let address = dict["address"]!
                    guard let pk = MCrypto.Signer.ETHEREUM.privateKeyToPublicKey(privateKey: Data.init(hex: sk)) else { return }
                    expect(DidHelper.pkToAddress(didType: DidType.Types.didTypeForgeEthereum, publicKey: pk)).to(equal(address))
                }
            })
            
            it("pk to address works", closure: {
                etherumCase.forEach { (dict) in
                    let pk = dict["publicKey"]!
                    let address = dict["address"]!
                    expect(DidHelper.pkToAddress(didType: DidType.Types.didTypeForgeEthereum, publicKey: Data.init(hex: pk))).to(equal(address))
                }
            })
            
            it("sk to did works", closure: {
                etherumCase.forEach { (dict) in
                    let sk = dict["secretKey"]!
                    let address = dict["address"]!
                    expect(DidHelper.getUserDid(didType: DidType.Types.didTypeForgeEthereum, privateKey: Data.init(hex: sk))).to(equal(address))
                }
            })
            
            it("pk to did works", closure: {
                etherumCase.forEach { (dict) in
                    let pk = dict["publicKey"]!
                    let address = dict["address"]!
                    expect(DidHelper.getUserDid(didType: DidType.Types.didTypeForgeEthereum, publicKey: pk)).to(equal(address))
                }
            })
            
        }
    }
}
