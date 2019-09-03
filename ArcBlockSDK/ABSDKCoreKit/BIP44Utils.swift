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

    public static func generateSeed(secretCode: String, recoveryCode: String) -> Data? {
        guard let entropy = getEntropy(secretCode: secretCode, recoveryCode: recoveryCode) else { return nil }
        let seed = BIP39.seedFromEntropy(entropy)
        return seed
    }

    public static func generatePrivateKey(seed: Data, path: String) -> Data? {
        guard let hdNode = HDNode.init(seed: seed) else { return nil }
        return hdNode.derive(path: path)?.privateKey
    }

    private static func getEntropy(secretCode: String, recoveryCode: String) -> Data? {
        var entropy = (secretCode.sha3(.keccak256).uppercased() + recoveryCode).sha3(.keccak256).uppercased()
        entropy = String(entropy.prefix(32))
        return entropy.data(using: .ascii)
    }
}
