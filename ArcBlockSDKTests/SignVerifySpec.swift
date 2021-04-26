// SignVerifySpec.swift
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

class SignVerifySpec: QuickSpec {
    override func spec() {

        let (msg, privkey, sig) = (
            Data.init(hex: "A6BF12BBCAFB5E1AE19725E5BBCAF856270195EABB75DB09153A9ECA4FC094CF"),
            Data.init(hex: "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"),
            Data.init(hex: "304502210093E20AFA592D448B36CDBEB58E12035F24765C6E040591536576AC43BF33DBA7022041B9D75076B87C9B8D7B2A1F7E1D7A3DD3A20BAAE2C5DCE0781DC0D3A293E660")
        )
                
        describe("testVerifyETHFromJS") {
            //
            let pk = "50863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6"
            it("verify works", closure: {
                expect(MCrypto.Signer.ETHEREUM.verify(message: msg, signature: sig, publicKey: Data(hex: pk))).to(beTrue())
            })
        }
        
        describe("testVerifySecp256k1") {
            let pk = "0450863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B23522CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6"
            it("verify works", closure: {
                expect(MCrypto.Signer.M_SECP256K1.verify(message: msg, signature: sig, publicKey: Data(hex: pk))).to(beTrue())
            })
        }
        
        describe("testVerifyEd25519") {
            let pk = "zBQbgFnZsUEJeAfjbHNMEiRjCAxjbJu7hJtzNcaFZNX5f"
            let message = "zbFNtuU1rp9DvvWSG4G2k6P7ND6kzQWkZgPwqbbyHLPkgAiq9YXwScx5jkPqhbyE4qp12NohwDQzjHVhRwnJZijP7KePywbFioCAzVdSWoktVVWUY55HJGTBPu8emUhKUwWtdTyjffHne5WhySnuke4EWJrARr"
            let signature = "z31C4D3hfpLPUeEi6eXyZq6uxTXusD74doKA9wLHPGrrw19vxsm2FsxPw9XDtZBTzdfuaVDNtY5T68LNtxGXNV3qn"
            it("verify works", closure: {
                expect(MCrypto.Signer.ED25519.verify(message: Data.init(multibaseEncoded: message)!, signature: Data.init(multibaseEncoded: signature)!, publicKey: Data.init(multibaseEncoded: pk)!)).to(beTrue())
            })
        }
        
        describe("complete process") {
            guard let mnemonics = BIP44Utils.generateMnemonics() else { return }
            guard let seed = BIP44Utils.getSeedByMnemonics(mnemonics: mnemonics) else {
                fatalError()
            }
            guard let path = BIP44Utils.keyDerivePathForAppDid(appDid: "z1W9zWEfB84QRemgLV4T7Lk5EGC728cSiUF", index: 0) else {
                fatalError()
            }
            guard let sk = BIP44Utils.generatePrivateKey(seed: seed, path: path) else { fatalError() }
            
            guard let ed25519_pk = MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: sk) else { fatalError() }
            guard let secp256k1_pk = MCrypto.Signer.M_SECP256K1.privateKeyToPublicKey(privateKey: sk) else { fatalError() }
            guard let eth_pk = MCrypto.Signer.ETHEREUM.privateKeyToPublicKey(privateKey: sk) else { fatalError() }
            
            let didTypeForgeBase16 = DidType(roleType: .account, keyType: .secp256k1, hashType: .sha3, encodingType: .base16)
            
            guard let ed25519_did = DidHelper.getUserDid(didType: DidType.Types.didTypeForge, publicKey: ed25519_pk) else { fatalError() }
            guard let secp256k1_did = DidHelper.getUserDid(didType: DidType(roleType: .account, keyType: .secp256k1, hashType: .sha3, encodingType: .base58), publicKey: secp256k1_pk) else { fatalError() }
            guard let eth_did = DidHelper.getUserDid(didType: DidType.Types.didTypeForgeEthereum, publicKey: eth_pk) else { fatalError() }
            guard let ed25519_base16_did = DidHelper.getUserDid(didType: didTypeForgeBase16, publicKey: ed25519_pk) else { fatalError() }
            
            guard let ed25519_sig = MCrypto.Signer.ED25519.sign(message: msg, privateKey: sk) else { fatalError() }
            guard let secp256k1_sig = MCrypto.Signer.M_SECP256K1.sign(message: msg, privateKey: sk) else { fatalError() }
            guard let eth_sig = MCrypto.Signer.ETHEREUM.sign(message: msg, privateKey: sk) else { fatalError() }
            

            
            it("works", closure: {
                expect(DidHelper.pkToAddress(didType: DidType.Types.didTypeForge, publicKey: ed25519_pk)).to(equal(DidHelper.removeDidPrefix(ed25519_did)))
                expect(DidHelper.pkToAddress(didType: DidType(roleType: .account, keyType: .secp256k1, hashType: .sha3, encodingType: .base58), publicKey: secp256k1_pk)).to(equal(DidHelper.removeDidPrefix(secp256k1_did)))
                expect(DidHelper.pkToAddress(didType: DidType.Types.didTypeForgeEthereum, publicKey: eth_pk)).to(equal(DidHelper.removeDidPrefix(eth_did)))
                
                expect(DidHelper.calculateTypesFromDid(did: ed25519_base16_did)).to(equal(didTypeForgeBase16))
                expect(DidHelper.calculateTypesFromDid(did: ed25519_base16_did)).to(equal(didTypeForgeBase16))
                                
                expect(MCrypto.Signer.ED25519.verify(message: msg, signature: ed25519_sig, publicKey: ed25519_pk)).to(beTrue())
                expect(MCrypto.Signer.M_SECP256K1.verify(message: msg, signature: secp256k1_sig, publicKey: secp256k1_pk)).to(beTrue())
                expect(MCrypto.Signer.ETHEREUM.verify(message: msg, signature: eth_sig, publicKey: eth_pk)).to(beTrue())
                
            })
        }
        
        describe("get key pair") {
            it("ed25519 work") {
                for _ in 0...100 {
                    let (randomPk, randomSk) = KeyType.ed25519.getKeypair()

    //                let (pk, sk) = KeyType.ed25519.getKeypair(by: Data.init(hex: "D67C071B6F51D2B61180B9B1AA9BE0DD0704619F0E30453AB4A592B036EDE644E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7"))
                    expect(randomPk?.bytes.count).to(equal(32))
                    expect(randomSk?.bytes.count).to(equal(32))
                }
            }

            it("secp256k1 work") {
                for _ in 0...100 {
                    let (randomPk, randomSk) = KeyType.secp256k1.getKeypair()

    //                let (pk, sk) = KeyType.secp256k1.getKeypair(by: Data.init(hex: "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"))
                    expect(randomPk?.bytes.count).to(equal(65))
                    expect(randomSk?.bytes.count).to(equal(32))
                }
            }

            it("ethereum work") {
                for _ in 0...100 {
                    let (randomPk, randomSk) = KeyType.ethereum.getKeypair()
    //                let (pk, sk) = KeyType.ethereum.getKeypair(by: Data.init(hex: "18E14A7B6A307F426A94F8114701E7C8E774E7F9A47E2C2035DB29A206321725"))
                    expect(randomPk?.bytes.count).to(equal(64))
                    expect(randomSk?.bytes.count).to(equal(32))
                }
            }

        }
    }
}
