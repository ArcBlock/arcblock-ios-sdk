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
import secp256k1

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
                
        // M_ 避免与第三方库重名
        public struct M_SECP256K1 {
            // 有04
            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                return Web3.Utils.privateToPublic(privateKey)
            }
            
            public static func keypair() -> (Data?, Data?) {
                
                guard let privateKey = SECP256K1.generatePrivateKey() else {
                    return (nil, nil)
                }
                let publicKey = SECP256K1.privateToPublic(privateKey: privateKey)
                return (publicKey, privateKey)
            }
            
            
            public static func sign(message: Data, privateKey: Data) -> Data? {
                if !SECP256K1.verifyPrivateKey(privateKey: privateKey) {
                    return nil
                }

                let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
                defer {
                    secp256k1_context_destroy(context)
                }

                var cSignature = secp256k1_ecdsa_signature()

                guard secp256k1_ecdsa_sign(context, &cSignature, message.bytes, privateKey.bytes, secp256k1_nonce_function_default, nil) == 1 else {
                    return nil
                }

                var sigLen = 74
                var signature = [UInt8](repeating: 0, count: sigLen)

                guard secp256k1_ecdsa_signature_serialize_der(context, &signature, &sigLen, &cSignature) == 1,
                    secp256k1_ecdsa_signature_parse_der(context, &cSignature, &signature, sigLen) == 1 else {
                    return nil
                }
                return Data.init(Array(signature.prefix(sigLen)))
                
            }
            
            public static func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
                guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN|SECP256K1_CONTEXT_VERIFY)) else { return false }

                defer {
                    secp256k1_context_destroy(context)
                }
                
                var cSignature = secp256k1_ecdsa_signature()
                var cPubkey = secp256k1_pubkey()

                guard secp256k1_ecdsa_signature_parse_der(context, &cSignature, signature.bytes, signature.bytes.count) == 1,
                      secp256k1_ec_pubkey_parse(context, &cPubkey, publicKey.bytes, publicKey.bytes.count) == 1 else {
                    return false
                }

                if secp256k1_ecdsa_verify(context, &cSignature, message.bytes, &cPubkey) != 1 {
                    return false
                }

                return true
            }
        }
        
        public struct ETHEREUM {
            // 没有04 少0x
            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                guard let pkData = Web3.Utils.privateToPublic(privateKey) else {
                    return nil
                }
                
                var publicKey = pkData
                if publicKey.bytes.count == 65 {
                    publicKey.removeFirst()
                }
                
                if publicKey.bytes.count != 64 {
                    return nil
                }
                
                return publicKey
            }
            
            public static func keypair() -> (Data?, Data?) {
                let (publicKey, privateKey) = MCrypto.Signer.M_SECP256K1.keypair()
                guard let pk = publicKey else {
                    return (nil, nil)
                }
                var stipped = pk.bytes
                
                if (stipped.count == 65) {
                    if (stipped[0] != 4) {
                        return (nil, nil)
                    }
                    stipped = Array(stipped[1...64])
                }
                
                if stipped.count != 64 {
                    return (nil, nil)
                }
                
                return (Data(stipped), privateKey)
            }
            
            public static func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
                var newPk = publicKey.bytes
                if publicKey.bytes.first != 0x04 && publicKey.bytes.count == 64 {
                    var newData: [UInt8] = publicKey.bytes
                    newData.insert(0x04, at: 0)
                    newPk = newData
                }
                // Verify 需要以上条件
                return MCrypto.Signer.M_SECP256K1.verify(message: message, signature: signature, publicKey: Data.init(newPk))
            }
            
            public static func sign(message: Data, privateKey: Data) -> Data? {
                return MCrypto.Signer.M_SECP256K1.sign(message: message, privateKey: privateKey)
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

