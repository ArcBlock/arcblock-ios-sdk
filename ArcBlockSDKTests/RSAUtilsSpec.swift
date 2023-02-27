// RSAUtilsSpec.swift
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

class RSAUtilsSpec: QuickSpec {
    override func spec() {
        let webPKPEM = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApk/Ovd2m0IyMGwSBB2I5mMRDsoYRBdGDtyW+eF2a/qDa8JVekmsAYA+DofkkFTAu1oJZs1afXALpNMcEMYXhxFCdPgOSpal2cL6dc7jYQkm1VopGvg9oIA5IJrwLHSqqkh0V+YDdepU7OStzH5n8RLh/Thb8od+JtYQkAuy9CbifU+A5CBe7FCBvzMqGEil3oucVZ7t01vLVRJkAVWaCzQgwMvd/8HTPv0ebVeLndF6NfOHOoooLw2C5rtaoTLcC9eJBQabx/f4PTF37QDM0W7/Rv5fk0yWq3cB3xmZN4teEOQTuSe5XF1lBa6E8Vv+TqNI0A6eeUHLbSAV2U04YeQIDAQAB
        -----END PUBLIC KEY-----
        """
        let webSKPEM = """
        -----BEGIN PRIVATE KEY-----
        MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCmT8693abQjIwbBIEHYjmYxEOyhhEF0YO3Jb54XZr+oNrwlV6SawBgD4Oh+SQVMC7WglmzVp9cAuk0xwQxheHEUJ0+A5KlqXZwvp1zuNhCSbVWika+D2ggDkgmvAsdKqqSHRX5gN16lTs5K3MfmfxEuH9OFvyh34m1hCQC7L0JuJ9T4DkIF7sUIG/MyoYSKXei5xVnu3TW8tVEmQBVZoLNCDAy93/wdM+/R5tV4ud0Xo184c6iigvDYLmu1qhMtwL14kFBpvH9/g9MXftAMzRbv9G/l+TTJardwHfGZk3i14Q5BO5J7lcXWUFroTxW/5Oo0jQDp55QcttIBXZTThh5AgMBAAECggEAA9t2ABFT/SJFXZsNIw60J0bmCw3w9yGU3HqToFcLcTxp14qfVuYEbDXv56HPpG4pp+/+BJrNt2SZ5A95mWxxgAwemYGbtRvpE1RYcoam/WKYQhmS6nWRBK1QHxXdbB/BNQJXsCG9AUrUxM6tLN51a2KcEUOXOGnm177o1uiGueL0vMRavTAG7/8IIraGBB4h0GBgwaMhGo1JtzjkeXjJqA6AidsDSHa4mj3dfH1zcubLigaSz/azbmMNEQ08h0oyviz+4B06NbMXVbW92GQT/CKyMGpxtU+bj1Jh8ybaMIsT5NjWXcw4HLuztqwNnX4uQrhC269RqK6cL7sAm+D9wQKBgQDO4jrHVsoBDf09VM9N/irRB4a7mDj5d+PpD8y2gFksRh1MIjInXqz6BH4BIJootriYiT1p8Q5Ao6lNIOp57dUZlElZimZDZ2v9MmLv4+S+UYjDR+EgMt05z0vNzNXw3uv8uoic+xYfIF2mqxj0BC32mgWgToxkdZHch6zKY/7igwKBgQDNy7xuvPbM4hm+TRdkGK+BIb55ztryVIzbRzjNeeRj28ZpZQ6V9n7lvGSYds9+Afxzd1QVcecC20GfEDq8besAOThkKRaFrJVD0bcTwmHvRF/CfauhosGO4P3hodmRqhtJhx7O19c5Jth/Z6Uz2kOB9XK2Ew4zHjO2Rd9Z7wo4UwKBgCdUdM4unqqCqVD+jYaLOkKQxrllH/e1JhvJiCZt0gYLskgl/Bjl88Z4EihOtV/mFMPS210HmakKNAZYqprRbwC04xjlqblIsQvqh0qJrZPM1k4hnRfM86eo1AVk2os3Je/e2lfVmAgE1Cj6P/0ryj0mXMl0BVaXz0n4dQ3o4qzXAoGAYaL4in1ihj/7QLsojtfbZGOTEA1g+Tm9/kbjHzFmdy4NC3Hjoqho+iwQeflcZgchM9L4dJgupr9JeeLkSwPHS7raE0MfKVqBEsULm/dMKY2B9S9UX4JtXJFIQmVcaOyQt6jAqBflR3szmfadfWVfQ+gkfVe7E+uPUzoBRpTPf3sCgYEAl/gAzMCHw9LpexmTitmmm7EK4K9XFLQ/m7QXHLJ9XAohdr6CqfLwscQ9BSuEf79E6jAiQLhpc9qJ13cG9gr79F0FKqnRlXTVs7gr7lQolzO+jwY8hD4qv3/b/717rDzAArjvw/GDKmdtIh/n2FlQY4wPaNrWxbU/fGexmhsn2d0=
        -----END PRIVATE KEY-----
        """
        
        let androidPKPEM = """
        -----BEGIN RSA PUBLIC KEY-----
        MIGJAoGBALVX7OlxyLjTSfTuH0glqn9bbRi189joF+Ytqy1C7vocA+qu0E/LKPli
        xNn2K+5wk8LtVw7hnMH4+rR9q5kk5xuztw2LiFEl70Vusq7S68di5cMa5SDDL40G
        eNLD2jZb/cscyhzP4smxIHjcIenZ9RcHOf4l0LWfjPwEBCX2rmZbAgMBAAE=
        -----END RSA PUBLIC KEY-----
        """
        let androidSKPEM = """
        -----BEGIN RSA PRIVATE KEY-----
        MIICXAIBAAKBgQC1V+zpcci400n07h9IJap/W20YtfPY6BfmLastQu76HAPqrtBP
        yyj5YsTZ9ivucJPC7VcO4ZzB+Pq0fauZJOcbs7cNi4hRJe9FbrKu0uvHYuXDGuUg
        wy+NBnjSw9o2W/3LHMocz+LJsSB43CHp2fUXBzn+JdC1n4z8BAQl9q5mWwIDAQAB
        AoGAKfFaNGxC1qzX8DSbO56qnqZQx2ReMA8OaAisDN3sVCDirwcb2zjME1JK4XbU
        lmOnaXBnsGNyVFL3+YMPi25DnXoYFubTAhTFbUoTGyQpaUr0N5tyj6QTdwh/gMOL
        Pbvg7FvFEZaFXu95HtRMwj4ScpuY4FrfFdYU24bGZQslZvECQQD2HmHuEKHYr6Da
        zqS/bFK0EAKdJLgdlooQpFwstbs1IhVlUhnintVXTHITjaFAoTyGR/ue/d23+Rmy
        YE3DzQ9dAkEAvJ/H1nOmY2GWmiquczbPO//llanLEFmPAKnZNAFdV1FjBH3Ds8KH
        M46tFISiq2uwYeDz+Qjxa7Ql8qAH3drJFwJAHsK3XKjJgaqZwR84qhAg2g5yNS/E
        rzYEdYYFWzUve7mR0QMM5y0Q3wNX8qet8sT0KphOk5WJI5hHpOqybXlwpQJBALl8
        qqixu7rZGZ9rP3ffOzU2dM+TVDQ0zdKKNCTW/rJCP4wIHK4mKoxBzuRxdgH6eU4X
        R/PqnnYahoKsam/5mWsCQGIWJsaaUQqNaY0c5Pes1a4Jrrxd/W9fUVuOkgQQAFus
        GBRxjxzifqzn5G/CM6vX/dddr392ed2mqu/9cgD/qJM=
        -----END RSA PRIVATE KEY-----
        """
        
        let abcdOriginString = "abcd"
        let emptyOriginString = ""
        let webABCDEncrypted = "z76MRS8iyHWJLMroRtpdZ9gzGKsWV7yx2qEkn3cnzbREjjp79iiuQymuyT74GNpjcHxVF5QZgW7d2E2CZb93sM6w8QBeZyWq1bst4KHVMzpG7pgwvvTwBnBh1957vAyafnivxG3EXAQevUnD5wrjUExTibT68GjxmrCtTyEZEyBZHpPx65j5eJfMgCmNRMsKJrYA4HRFrqiVQ6g7o56N1uyuhv7nvvn93AFgD7HdP3tzuw22ZqmWcyequVxwNAmoHzb2bF36ikCrwEKN6bioag4MJvt1SMPMYX9zAjnCCEwYDtdkTvPStvTqzvP1JfzwTjEBDiUybgFpzyjJG29AfNszLNKve2X"
       let webEmptyEncrypted = "z49E3pw1L8b4UP9L5gtNZ9QYyGcqaCJCLECryRgboFZTWSj46nZEEPSTdVvpctvyw2ij1JsCTiL12VPx7mNoQRfnDCwmnjBP8ggDQ4UgJz3shNF8rRSHMPvKsznXPNWHZix9DVytjPFAowZnkeyAwUWj16oZg5FPB71dPMxJrTWH7c62iELunJkKScaj5v4iUyQ8SBtatNxE7fR4cPzZTysnvgeaqhgK14rKqZuncyMjcwzLAtH1dzpDwCChipSCJdY3w84CTMarLtyKnRkbaxhBG9G3ZiXsM7i2bzpWGNK5QVndnKr9n7N5jg2vBb3mAxk5HnrDVkKDMfkMKDUUj7JTMo6ZA3q"
        
        describe("RSAUtilsSpec") {
            it("works", closure: {
                
                if let keyPair = RSAUtils.generateKeyPair() {
                    print(RSAUtils.exportPemB58BtcASN1Pk(data: keyPair.pk))
                    print(RSAUtils.exportPemB58BtcSk(data: keyPair.sk))
                }
                
                let encryted = RSAUtils.encryptString2B58Btc(abcdOriginString, base64PK: androidPKPEM)
                let decrypted = RSAUtils.decryptB58Btc2String(encryted!, base64SK: androidSKPEM)
                print(encryted)
                print(decrypted)
                
                let emptyEncryted = RSAUtils.encryptString2B58Btc(emptyOriginString, base64PK: androidPKPEM)
                let emptyDecrypted = RSAUtils.decryptB58Btc2String(emptyEncryted!, base64SK: androidSKPEM)
                print(emptyEncryted)
                print(emptyDecrypted)
                guard let webPKABCDEncrypted = RSAUtils.encryptString2B58Btc(abcdOriginString, base64PK: webPKPEM) else {
                    XCTFail("WebPkEncrypt Failed!")
                    return
                }
                expect(RSAUtils.decryptB58Btc2String(webPKABCDEncrypted, base64SK: webSKPEM)).to(equal(abcdOriginString))

                guard let webPKEmptyEncrypted = RSAUtils.encryptString2B58Btc(emptyOriginString, base64PK: webPKPEM) else {
                    XCTFail("WebPkEmptyEncrypt Failed!")
                    return
                }
                expect(RSAUtils.decryptB58Btc2String(webPKEmptyEncrypted, base64SK: webSKPEM)).to(equal(emptyOriginString))

                guard let webSKABCDDecrypted = RSAUtils.decryptB58Btc2String(webABCDEncrypted, base64SK: webSKPEM) else {
                    XCTFail("WebSkDecrypt Failed!")
                    return
                }
                expect(webSKABCDDecrypted).to(equal(abcdOriginString))

                guard let webSKEmptyDecrypted = RSAUtils.decryptB58Btc2String(webEmptyEncrypted, base64SK: webSKPEM) else {
                    XCTFail("WebSkDecrypt Failed!")
                    return
                }
                expect(webSKEmptyDecrypted).to(equal(emptyOriginString))
            })
        }
    }
}
