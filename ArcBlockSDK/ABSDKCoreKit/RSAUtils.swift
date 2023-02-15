// RSAUtils.swift
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
import Security

public class RSAUtils {
    public static func generateKeyPair(_ length: Int) -> (pk: Data, sk: Data)? {
        let attributes: [CFString: Any] = [
           kSecAttrType: kSecAttrKeyTypeRSA,
           kSecAttrKeySizeInBits: 1024,
           kSecPrivateKeyAttrs: [
             kSecAttrIsPermanent: false,
           ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
              let publicKey = SecKeyCopyPublicKey(privateKey) else {
            return nil
        }
        
        var pkError: Unmanaged<CFError>?
        guard let cfPKData = SecKeyCopyExternalRepresentation(publicKey, &pkError) else {
            return nil
        }
        
        var skError: Unmanaged<CFError>?
        guard let cfSKData = SecKeyCopyExternalRepresentation(privateKey, &skError) else {
            return nil
        }
        
        return (cfPKData as Data , cfSKData as Data)
    }
    /// ASN1处理过的Pk,可以导出给其他平台使用
    public static func exportASN1Pk(data: Data) -> String {
        return RSAPublicKeyExporter().toSubjectPublicKeyInfo(data).base64EncodedString()
    }
    
    public static func decodeSecKeyFromBase64(encodedKey: String, isPrivate: Bool = false, keySzie: Int = 1024) -> SecKey? {
        var keyString = encodedKey
        keyString = keyString.replacingOccurrences(of:"-----BEGIN PUBLIC KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----END PUBLIC KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----BEGIN PRIVATE KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----END PRIVATE KEY-----", with: "")
        
        keyString = keyString.replacingOccurrences(of:"-----BEGIN RSA PUBLIC KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----END RSA PUBLIC KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----BEGIN RSA PRIVATE KEY-----", with: "")
        keyString = keyString.replacingOccurrences(of:"-----END RSA PRIVATE KEY-----", with: "")
        
        keyString = keyString.replacingOccurrences(of: "\r", with: "")
        keyString = keyString.replacingOccurrences(of: "\n", with: "")
        keyString = keyString.replacingOccurrences(of: " ", with: "")
        var keyClass = kSecAttrKeyClassPublic
        if isPrivate {
            keyClass = kSecAttrKeyClassPrivate
        }
        let attributes: [CFString: Any] = [
            kSecAttrKeyClass: keyClass,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: keySzie,
            kSecReturnPersistentRef: true
        ]
        guard var secKeyData = Data(base64Encoded: keyString) else {
            print("Error: invalid encodedKey, cannot extract data")
            return nil
        }
        
        if let stripedData = stripKeyHeader(keyData: secKeyData) {
            secKeyData = stripedData
        }
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(secKeyData as CFData, attributes as CFDictionary, &error) else {
            print("Error: Problem in SecKeyCreateWithData()")
            return nil
        }
        return secKey
    }
    
    static func stripKeyHeader(keyData: Data) -> Data? {
        let node: Asn1Parser.Node
        do {
            node = try Asn1Parser.parse(data: keyData)
        } catch {
            return nil
        }
        
        // Ensure the raw data is an ASN1 sequence
        guard case .sequence(let nodes) = node else {
            return nil
        }
        
        // Detect whether the sequence only has integers, in which case it's a headerless key
        let onlyHasIntegers = nodes.filter { node -> Bool in
            if case .integer = node {
                return false
            }
            return true
        }.isEmpty
        
        // Headerless key
        if onlyHasIntegers {
            return keyData
        }
        
        // If last element of the sequence is a bit string, return its data
        if let last = nodes.last, case .bitString(let data) = last {
            return data
        }
        
        // If last element of the sequence is an octet string, return its data
        if let last = nodes.last, case .octetString(let data) = last {
            return data
        }
        
        // Unable to extract bit/octet string or raw integer sequence
        return nil
    }
    
    /// 加密Data到Data
    public static func encryptData2Data(_ data: Data, publicKey: String) -> Data? {
        guard let pk = decodeSecKeyFromBase64(encodedKey: publicKey) else {
            return nil
        }

        var error: Unmanaged<CFError>?
        let encrypted = SecKeyCreateEncryptedData(pk, .rsaEncryptionOAEPSHA1, data as CFData, &error)
        return encrypted as? Data
    }
    /// 加密String到Data
    public static func encryptString2Data(_ string: String, publicKey: String) -> Data? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return encryptData2Data(data, publicKey: publicKey)
    }
    /// 加密String到Base58Btc
    public static func encryptString2B58Btc(_ string: String, publicKey: String) -> String? {
        guard let encrypted = encryptString2Data(string, publicKey: publicKey) else {
            return nil
        }
        return encrypted.multibaseEncodedString(inBase: .base58BTC)
    }
    /// 解密Data到Data
    public static func decryptData2Data(_ data: Data, privateKey: String) -> Data? {
        guard let sk = decodeSecKeyFromBase64(encodedKey: privateKey, isPrivate: true) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        let encrypted = SecKeyCreateDecryptedData(sk, .rsaEncryptionOAEPSHA1, data as CFData, &error)
        return encrypted as? Data
    }
    /// 解密Base58Btc到Data
    public static func decryptB58Btc2Data(_ string: String, privateKey: String) -> Data? {
        guard let data = Data(multibaseEncoded: string) else {
            return nil
        }
        return decryptData2Data(data, privateKey: privateKey)
    }
    /// 解密Base58Btc到String
    public static func decryptB58Btc2String(_ string: String, privateKey: String) -> String? {
        guard let data = Data(multibaseEncoded: string), let decrypted = decryptData2Data(data, privateKey: privateKey) else {
            return nil
        }
        return String(data: decrypted, encoding: .utf8)
    }
}
