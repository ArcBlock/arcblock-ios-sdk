// MCryptoSpec.swift
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
// swiftlint:disable line_length

import Quick
import Nimble
import CryptoSwift
import ArcBlockSDK
import web3swift

class MCryptoSpec: QuickSpec {
    override func spec() {
        describe("keccakf1600 hashing") {
            it("works", closure: {
                let input = Data.init(hex: "68656C6C6F")
                expect(MCrypto.Hasher.Keccakf1600.sha(Data.init(hex: "")).toHexString())
                    .to(equal("c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"))
                expect(MCrypto.Hasher.Keccakf1600.sha(input).toHexString())
                    .to(equal("1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8"))
                expect(MCrypto.Hasher.Keccakf1600.sha384(input).toHexString())
                    .to(equal("dcef6fb7908fd52ba26aaba75121526abbf1217f1c0a31024652d134d3e32fb4cd8e9c703b8f43e7277b59a5cd402175"))
            })
        }

        describe("sha2 hashing") {
            it("works", closure: {
                let input = Data.init(hex: "68656C6C6F")
                expect(MCrypto.Hasher.Sha2.sha(Data.init(hex: "")).toHexString())
                    .to(equal("5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456"))
                expect(MCrypto.Hasher.Sha2.sha(input).toHexString())
                    .to(equal("9595c9df90075148eb06860365df33584b75bff782a510c6cd4883a419833d50"))
                expect(MCrypto.Hasher.Sha2.sha384(input).toHexString())
                    .to(equal("d47d89ffd5071e8260cd6fca1a4668605871af5fbedbed7375a1117c8c14c82d3ceac2344dd1e03035ae1c5e755cf5f2"))
            })
        }

        describe("sha3 hashing") {
            it("works", closure: {
                let input = Data.init(hex: "68656C6C6F")
                expect(MCrypto.Hasher.Sha3.sha(Data.init(hex: "")).toHexString())
                    .to(equal("a7ffc6f8bf1ed76651c14756a061d662f580ff4de43b49fa82d80a4b80f8434a"))
                expect(MCrypto.Hasher.Sha3.sha(input).toHexString())
                    .to(equal("3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392"))
                expect(MCrypto.Hasher.Sha3.sha384(input).toHexString())
                    .to(equal("720aea11019ef06440fbf05d87aa24680a2153df3907b23631e7177ce620fa1330ff07c0fddee54699a4c3ee0ee9d887"))
            })
        }

        describe("ed25519") {
            it("sk to pk works", closure: {
                let sk = "D67C071B6F51D2B61180B9B1AA9BE0DD0704619F0E30453AB4A592B036EDE644E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7"
                let pk = "E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7"
                expect(MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: Data.init(hex: sk))?.toHexString().uppercased()).to(equal(pk))
            })

            it("sign and verify works", closure: {
                let sk = Data.init(hex: "D67C071B6F51D2B61180B9B1AA9BE0DD0704619F0E30453AB4A592B036EDE644E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7")
                let pk = Data.init(hex: "E4852B7091317E3622068E62A5127D1FB0D4AE2FC50213295E10652D2F0ABFC7")
                let message = "15D0014A9CF581EC068B67500683A2784A15E1F68057E5E37AAF3A0F58F3C43F083D6A5630130399D4E5003EA191FDE30849"
                let signature = "321EE8262407BF091F16ED190A3074339EBDF956B3924A9CF29B86A366C9570C72C6A8D8363705182D5A99FAF152C617FD89D291C9D944F2A95DF57019303200"
//                expect(MCrypto.Signer.ED25519.sign(message: Data.init(hex: message), privateKey: sk)?.toHexString().uppercased()).to(equal(signature))
                expect(MCrypto.Signer.ED25519.verify(message: Data.init(hex: message), signature: Data.init(hex: signature), publicKey: pk)).to(beTrue())
            })

            it("verify jwt signature works", closure: {
                guard let pk = Data.init(base64URLPadEncoded: "71MugS2tzyAfHVZDqroRTcLSDtA8PixvUadQf1oPm9xo"),
                    let message = Data.init(base64URLPadEncoded: "eyJhbGciOiJFZDI1NTE5IiwidHlwIjoiSldUIn0.eyJpYXQiOiIxNTUyMDEwODgzIiwiaXNzIjoiZGlkOmFidDp6MWF5NVNxa2E4SmhEZVZ6bWlLY3dQQlJVU3pTUkFlVDN2eCIsImV4cCI6IjE1NTIxMTA4ODMiLCJuYmYiOiIxNTUyMDEwODgzIiwicmVxdWVzdGVkQ2xhaW1zIjpbeyJ0eXBlIjoicHJvZmlsZSIsIm1ldGEiOnsiZGVzY3JpcHRpb24iOiJQbGVhc2UgcHJvdmlkZSB5b3VyIHByb2ZpbGUgaW5mb3JtYXRpb24uIn0sImZ1bGxOYW1lIjoiVGVzdCJ9XX0"),
                    let signature = Data.init(base64URLPadEncoded: "BV1XpzJ5Brly8NbaP85ZrBpU/mn9mbs7Z8+zt96ZuobLkFBBtGarACxj4gnBbRAV0D4Bqf4TC/YKy6Yem76CCA") else {
                        return
                }
                expect(MCrypto.Signer.ED25519.verify(message: message, signature: signature, publicKey: pk)).to(beTrue())
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
            
            it("sk to pk works", closure: {
                etherumCase.forEach { (dict) in
                    let sk = dict["secretKey"]!
                    let pk = dict["publicKey"]!
                    expect(MCrypto.Signer.ETHEREUM.privateKeyToPublicKey(privateKey: Data.init(hex: sk))?.toHexString().uppercased()).to(equal(pk))
                }
            })
        }
    }
}
    
