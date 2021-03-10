// MCrypto.swift
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
#if canImport(CryptoKit)
import CryptoKit
#endif
import web3swift

public struct MCrypto {

    public static func generateRandomBytes(bytesCount: Int) -> Data? {
        var keyData = Data(count: bytesCount)
        let result = keyData.withUnsafeMutableBytes {
            (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, bytesCount, mutableBytes)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }

    public struct Signer {
        public struct ED25519 {
            public static func keypair() -> (Data?, Data?) {
                if #available(iOS 13.0, *) {
                    let privateKey = Curve25519.Signing.PrivateKey()
                    return (privateKey.publicKey.rawRepresentation, privateKey.rawRepresentation)
                } else {
                    // Fallback on earlier versions
                    let (publicKey, privateKey) = Ed25519.crypto_sign_keypair()
                    return (Data.init(publicKey), Data.init(privateKey+publicKey))
                }
            }

            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                if #available(iOS 13.0, *) {
                    if let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKey.prefix(32)) {
                        return privateKey.publicKey.rawRepresentation
                    }
                    return nil
                } else {
                    // Fallback on earlier versions
                    return Data.init(Ed25519.crypto_pk(Array(privateKey.bytes.prefix(32))))
                }
            }

            public static func sign(message: Data, privateKey: Data) -> Data? {
                if #available(iOS 13.0, *) {
                    if let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: privateKey.prefix(32)),
                        let signature = try? privateKey.signature(for: message) {
                        return signature
                    }
                    return nil
                } else {
                    // Fallback on earlier versions
                    var signatureAndMessage = [UInt8]()
                    guard let publicKey = privateKeyToPublicKey(privateKey: privateKey) else {
                        return nil
                    }
                    Ed25519.crypto_sign(&signatureAndMessage, message.bytes, privateKey.bytes + publicKey.bytes)
                    return Data.init(Array(signatureAndMessage.prefix(64)))
                }
            }

            public static func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
                if #available(iOS 13.0, *) {
                    guard let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: publicKey) else {
                        return false
                    }
                    return publicKey.isValidSignature(signature, for: message)
                } else {
                    // Fallback on earlier versions
                    let signatureAndMessage = signature.bytes + message.bytes
                    return Ed25519.crypto_sign_open(signatureAndMessage, publicKey.bytes)
                }
            }
        }
        
        public struct ETHEREUM {
            // 没有04 少0x
            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                guard let pkStr = ETHEREUM.privateKeyToPublicKeyString(privateKey: privateKey) else {
                    return nil
                }
                
                return Data.init(hex: pkStr)
            }
            
            public static func privateKeyToPublicKeyString(privateKey: Data) -> String? {
                guard let pkStr = Web3.Utils.privateToPublic(privateKey)?.toHexString() else {
                    return nil
                }
                var pkString = pkStr
                pkString.removeSubrange(pkString.startIndex...pkString.index(pkString.startIndex, offsetBy: 1))
                pkString = pkString.uppercased()
                pkString.insert(contentsOf: "0x", at: pkString.startIndex)
                return pkString
            }
            
            public static func keypair(seed: Data?) -> (Data?, Data?) {
                guard let seed = seed else {
                    return (nil, nil)
                }
                return (nil, nil)
            }
            
            public static func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
                //                if privateKey.first != 0x04 && privateKey.bytes.count == 64 {
                //                    var newData: [UInt8] = privateKey.bytes
                //                    newData.insert(0x04, at: 0)
                //                }
                // Verify 需要以上条件
                return true
            }
        }
        
        // M_ 避免与第三方库重名
        public struct M_SECP256K1 {
            // 有04
            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                return Web3.Utils.privateToPublic(privateKey)
            }
            
            public static func keypair(seed: Data?) -> (Data?, Data?) {
                guard let seed = seed else {
                    return (nil, nil)
                }
                
                guard let privateKey = SECP256K1.generatePrivateKey() else {
                    return (nil, nil)
                }
                let publicKey = SECP256K1.privateToPublic(privateKey: privateKey)
                return (publicKey, privateKey)
                
            }
            
        }
    }

    public struct Hasher {
        public struct Keccakf1600 {
            public static func sha(_ input: Data) -> Data {
                return sha256(input)
            }

            public static func sha224(_ input: Data) -> Data {
                return sha224(input, 1)
            }

            public static func sha224(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.keccak224)
                } else {
                    return sha224(input.sha3(.keccak224), round - 1)
                }
            }

            public static func sha256(_ input: Data) -> Data {
                return sha256(input, 1)
            }

            public static func sha256(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.keccak256)
                } else {
                    return sha256(input.sha3(.keccak256), round - 1)
                }
            }

            public static func sha384(_ input: Data) -> Data {
                return sha384(input, 1)
            }

            public static func sha384(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.keccak384)
                } else {
                    return sha384(input.sha3(.keccak384), round - 1)
                }
            }

            public static func sha512(_ input: Data) -> Data {
                return sha512(input, 1)
            }

            public static func sha512(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.keccak512)
                } else {
                    return sha512(input.sha3(.keccak512), round - 1)
                }
            }
        }

        public struct Sha2 {
            public static func sha(_ input: Data) -> Data {
                return sha256(input)
            }

            public static func sha224(_ input: Data) -> Data {
                return sha224(input, 2)
            }

            public static func sha224(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha224()
                } else {
                    return sha224(input.sha224(), round - 1)
                }
            }

            public static func sha256(_ input: Data) -> Data {
                return sha256(input, 2)
            }

            public static func sha256(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha256()
                } else {
                    return sha256(input.sha256(), round - 1)
                }
            }

            public static func sha384(_ input: Data) -> Data {
                return sha384(input, 2)
            }

            public static func sha384(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha384()
                } else {
                    return sha384(input.sha384(), round - 1)
                }
            }

            public static func sha512(_ input: Data) -> Data {
                return sha512(input, 2)
            }

            public static func sha512(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha512()
                } else {
                    return sha512(input.sha512(), round - 1)
                }
            }
        }

        public struct Sha3 {
            public static func sha(_ input: Data) -> Data {
                return sha256(input)
            }

            public static func sha224(_ input: Data) -> Data {
                return sha224(input, 1)
            }

            public static func sha224(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.sha224)
                } else {
                    return sha224(input.sha3(.sha224), round - 1)
                }
            }

            public static func sha256(_ input: Data) -> Data {
                return sha256(input, 1)
            }

            public static func sha256(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.sha256)
                } else {
                    return sha256(input.sha3(.sha256), round - 1)
                }
            }

            public static func sha384(_ input: Data) -> Data {
                return sha384(input, 1)
            }

            public static func sha384(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.sha384)
                } else {
                    return sha384(input.sha3(.sha384), round - 1)
                }
            }

            public static func sha512(_ input: Data) -> Data {
                return sha512(input, 1)
            }

            public static func sha512(_ input: Data, _ round: Int) -> Data {
                if round < 1 {
                    return input
                } else if round == 1 {
                    return input.sha3(.sha512)
                } else {
                    return sha512(input.sha3(.sha512), round - 1)
                }
            }
        }
    }
}

