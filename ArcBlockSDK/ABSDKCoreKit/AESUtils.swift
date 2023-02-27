// AES.swift
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
import CryptoSwift

public class AESUtils {
    private static func createKey(_ key: String) -> Array<UInt8>? {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        return MCrypto.Hasher.Sha3.sha256(keyData).bytes
    }
    /// 加密byte到byte
    public static func encryptByte2Byte(bytes: Array<UInt8>, key: String) -> Array<UInt8>? {
        guard let keyData = Self.createKey(key) else { return nil }
        do {
            let aes = try AES(key: keyData, blockMode: ECB(), padding: .pkcs5)
            let encrypted = try aes.encrypt(bytes)
            return encrypted
        } catch {
            return nil
        }
    }
    /// 加密字符串到byte
    public static func encryptString2Byte(string: String, key: String) -> Array<UInt8>? {
        encryptByte2Byte(bytes: string.bytes, key: key)
    }
    /// 加密字符串到Hex
    public static func encryptString2Hex(string: String, key: String) -> String? {
        encryptByte2Byte(bytes: string.bytes, key: key)?.toHexString()
    }
    /// 加密字符串到Base64
    public static func encryptString2Base64(string: String, key: String) -> String? {
        encryptByte2Byte(bytes: string.bytes, key: key)?.toBase64()
    }
    /// 解密byte到byte
    public static func decryptByte2Byte(_ bytes: Array<UInt8>, key: String) -> Array<UInt8>? {
        guard let keyData = Self.createKey(key) else { return nil }
        do {
            let aes = try AES(key: keyData, blockMode: ECB(), padding: .pkcs5)
            let decrypted = try aes.decrypt(bytes)
            return decrypted
        } catch {
            print(error)
            return nil
        }
    }
    /// 解密byte到String
    public static func decryptByte2String(_ bytes: Array<UInt8>, key: String) -> String? {
        guard let bytes = decryptByte2Byte(bytes, key: key) else {
            return nil
        }
        return String(bytes: bytes, encoding: .utf8)
    }
    /// 解密String到String
    public static func decryptString2String(_ string: String, key: String) -> String? {
        guard let bytes = Data(multibaseEncoded: string)?.bytes, let decrypted = decryptByte2Byte(bytes, key: key) else {
            return nil
        }
        return String(bytes: decrypted, encoding: .utf8)
    }
    /// 解密hex到Byte
    public static func decryptHex2Byte(_ hex: String, key: String) -> Array<UInt8>? {
        decryptByte2Byte(Data(hex: hex).bytes, key: key)
    }
    /// 解密hex到string
    public static func decryptHex2String(_ hex: String, key: String) -> String? {
        decryptByte2String(Data(hex: hex).bytes, key: key)
    }
    /// 解密base64到Byte
    public static func decryptBase642Byte(_ base64: String, key: String) -> Array<UInt8>? {
        guard let bytes = Data(base64Encoded: base64)?.bytes else { return nil }
        return decryptByte2Byte(bytes, key: key)
    }
    /// 解密base64到String
    public static func decryptBase642String(_ base64: String, key: String) -> String? {
        guard let bytes = Data(base64Encoded: base64)?.bytes else { return nil }
        return decryptByte2String(bytes, key: key)
    }
}
