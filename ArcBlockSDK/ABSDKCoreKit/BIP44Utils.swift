// BIP44Utils.swift
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

import CryptoSwift
import web3swift

public class BIP44Utils {
    public static func generateRecoveryCode() -> String {
        if let randomBytes = MCrypto.generateRandomBytes(bytesCount: 16) {
            return randomBytes.base58EncodedString()
        } else {
            return ""
        }
    }

    // Master Seed
    public static func generateSeed(secretCode: String, recoveryCode: String) -> Data? {
        guard let entropy = getEntropy(secretCode: secretCode, recoveryCode: recoveryCode) else { return nil }
        let seed = BIP39.seedFromEntropy(entropy)
        return seed
    }

    // Actual Child Seed
    public static func generatePrivateKey(seed: Data, path: String) -> Data? {
        guard let hdNode = HDNode.init(seed: seed) else { return nil }
        return hdNode.derive(path: path)?.privateKey
    }

    public static func generatePrivateKey(data: Data) -> Data? {
        guard let hdNode = HDNode.init(data) else {
            return nil
        }
        return hdNode.privateKey
    }

    public static func generateChildSeed(seed: Data, path: String) -> Data? {
        guard let hdNode = HDNode.init(seed: seed) else { return nil }
        return hdNode.derive(path: path)?.serialize(serializePublic: false)
    }

    private static func getEntropy(secretCode: String, recoveryCode: String) -> Data? {
        var entropy = (secretCode.sha3(.keccak256).uppercased() + recoveryCode).sha3(.keccak256).uppercased()
        entropy = String(entropy.prefix(32))
        return entropy.data(using: .ascii)
    }

    public static func keyDerivePathFor(account: String, change: String, index: Int) -> String {
        return "m/44'/260'/\(account)'/\(change)'/\(index)"
    }

    // Dapp path, index 用于多维度生成账户与appDid配合使用
    public static func keyDerivePathForAppDid(appDid: String, index: Int) -> String? {        
        if appDid == "eth" {
            return HDNode.defaultPathMetamask
        } else {
            guard let appDidHash = appDid.components(separatedBy: ":").last,
                let appDidBytes = Data.init(multibaseEncoded: appDidHash) else {
                    return nil
            }
            let appDidSha3Prefix = MCrypto.Hasher.Sha3.sha256(appDidBytes).prefix(8)
            let sk1 = (UInt32(bigEndian: appDidSha3Prefix.prefix(4).withUnsafeBytes { $0.pointee }) << 1) >> 1
            let sk2 = (UInt32(bigEndian: appDidSha3Prefix.suffix(4).withUnsafeBytes { $0.pointee }) << 1) >> 1
            return keyDerivePathFor(account: String(sk1), change: String(sk2), index: index)
        }
    }
    
    public static func generateMnemonics() -> [String]? {
        do {
            return try BIP39.generateMnemonics(bitsOfEntropy: 128)?.components(separatedBy: " ")
        } catch  {
            return nil
        }
    }
    
    public static func getSeedByMnemonics(mnemonics: [String]) -> Data? {        
        return BIP39.seedFromMmemonics(mnemonics.joined(separator: " "))
    }
    
}
