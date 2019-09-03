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
import CryptoSwift

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
                let (publicKey, privateKey) = Ed25519.crypto_sign_keypair()
                return (Data.init(bytes: publicKey), Data.init(bytes: privateKey+publicKey))
            }

            public static func privateKeyToPublicKey(privateKey: Data) -> Data? {
                return Data.init(bytes: Ed25519.crypto_pk(Array(privateKey.bytes.prefix(32))))
            }

            public static func sign(message: Data, privateKey: Data) -> Data? {
                var signatureAndMessage = [UInt8]()
                guard let publicKey = privateKeyToPublicKey(privateKey: privateKey) else {
                    return nil
                }
                Ed25519.crypto_sign(&signatureAndMessage, message.bytes, privateKey.bytes + publicKey.bytes)
                return Data.init(bytes: Array(signatureAndMessage.prefix(64)))
            }

            public static func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
                let signatureAndMessage = signature.bytes + message.bytes
                return Ed25519.crypto_sign_open(signatureAndMessage, publicKey.bytes)
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
