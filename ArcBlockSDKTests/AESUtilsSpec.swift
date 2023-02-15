// AESUtilsSpec.swift
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

class AESUtilsSpec: QuickSpec {
    override func spec() {
        describe("AESUtilsSpec") {
            it("works", closure: {
                let key = "123456"
                let string = "abcd"
                let encryptedHexString = "1c72c78500c351aefddf48ffa193e71a"
                let encryptedBase64 = "HHLHhQDDUa7930j/oZPnGg=="
                
                guard let encryptedByte = AESUtils.encryptString2Byte(string: string, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                guard let encryptedHex = AESUtils.encryptString2Hex(string: string, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                guard let encryptedBase46 = AESUtils.encryptString2Base64(string: string, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                
                expect(encryptedByte.toHexString()).to(equal(encryptedHexString))
                expect(encryptedHex).to(equal(encryptedHexString))
                expect(encryptedBase46).to(equal(encryptedBase64))
                
                guard let byte2ByteDecrypted = AESUtils.decryptByte2Byte(encryptedByte, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                guard let byte2StringDecrypted = AESUtils.decryptByte2String(encryptedByte, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                
                guard let hex2ByteDecrypted = AESUtils.decryptHex2Byte(encryptedHexString, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                guard let hex2StringDecrypted = AESUtils.decryptHex2String(encryptedHexString, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                
                guard let base642ByteDecrypted = AESUtils.decryptBase642Byte(encryptedBase64, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                guard let base642StringDecrypted = AESUtils.decryptBase642String(encryptedBase64, key: key) else {
                    expect(0).to(equal(1))
                    return
                }
                
                expect(String(bytes: byte2ByteDecrypted, encoding: .utf8)).to(equal("abcd"))
                expect(byte2StringDecrypted).to(equal("abcd"))
                
                expect(String(bytes: hex2ByteDecrypted, encoding: .utf8)).to(equal("abcd"))
                expect(hex2StringDecrypted).to(equal("abcd"))

                expect(String(bytes: base642ByteDecrypted, encoding: .utf8)).to(equal("abcd"))
                expect(base642StringDecrypted).to(equal("abcd"))
            })
        }
    }
}
