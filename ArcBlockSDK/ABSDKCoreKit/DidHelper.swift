// DidHelper.swift
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
import web3swift

public enum RoleType: Int8 {
    case account = 0
    case node = 1
    case device = 2
    case application = 3
    case smartContract = 4
    case bot = 5
    case asset = 6
    case stake = 7
    case validator = 8
    case group = 9
    case tx = 10
    case tether = 11
    case swap = 12
    case delegate = 13
    case any = 63

    public static func roleTypeWithName(_ name: String) -> RoleType {
        switch name {
        case "account":
            return .account
        case "node":
            return .node
        case "device":
            return .device
        case "application":
            return .application
        case "smartContract":
            return .smartContract
        case "bot":
            return .bot
        case "asset":
            return .asset
        case "stake":
            return .stake
        case "validator":
            return .validator
        case "group":
            return .group
        case "tx":
            return .tx
        case "tether":
            return .tether
        case "swap":
            return .swap
        case "delegate":
            return .delegate
        default:
            return .any
        }
    }
}

public enum KeyType: Int8 {
    case ed25519 = 0
    case secp256k1 = 1

    func privateKeyToPublicKey(privateKey: Data) -> Data? {
        switch self {
        case .ed25519:
            return MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: privateKey)
        case .secp256k1:
            return nil
        }
    }

    public func getKeypair() -> (Data?, Data?) {
        switch self {
        case .ed25519:
            return MCrypto.Signer.ED25519.keypair()
        case .secp256k1:
            return (nil, nil)
        }
    }

    public static func keyTypeWithName(_ name: String) -> KeyType {
        switch "name" {
        case "secp256k1":
            return .secp256k1
        case "ed25519":
            return .ed25519
        default:
            return .ed25519
        }
    }
}

public enum HashType: Int8 {
    case keccak = 0
    case sha3 = 1
    case keccak384 = 2
    case sha3384 = 3
    case keccak512 = 4
    case sha3512 = 5
    case sha2 = 6

    public func hash(data: Data) -> Data? {
        switch self {
        case .keccak:
            return MCrypto.Hasher.Keccakf1600.sha(data)
        case .sha3:
            return MCrypto.Hasher.Sha3.sha(data)
        case .keccak384:
            return MCrypto.Hasher.Keccakf1600.sha384(data)
        case .sha3384:
            return MCrypto.Hasher.Sha3.sha384(data)
        case .keccak512:
            return MCrypto.Hasher.Keccakf1600.sha512(data)
        case .sha3512:
            return MCrypto.Hasher.Sha3.sha512(data)
        case .sha2:
            return MCrypto.Hasher.Sha2.sha256(data, 1)
        }
    }

    public static func hashTypeWithName(_ name: String) -> HashType {
        switch name {
        case "keccak":
            return .keccak
        case "sha3":
            return .sha3
        case "keccak384":
            return .keccak384
        case "sha3384":
            return .sha3384
        case "keccak512":
            return .keccak512
        case "sha3512":
            return .sha3512
        case "sha2":
            return .sha2
        default:
            return .sha3
        }
    }
}

public class DidHelper {
    public static func getUserDid(userPrivateKey: Data) -> String? {
        return getUserDid(roleType: .account, keyType: .ed25519, hashType: .sha3, privateKey: userPrivateKey)
    }

    public static func getUserDid(roleType: RoleType, keyType: KeyType, hashType: HashType, privateKey: Data) -> String? {
        guard let publicKey = keyType.privateKeyToPublicKey(privateKey: privateKey),
            let address = pkToAddress(roleType: roleType, keyType: keyType, hashType: hashType, publicKey: publicKey) else { return nil }
        return "did:abt:" + address
    }

    public static func getUserDid(roleType: RoleType, keyType: KeyType, hashType: HashType, publicKey: String) -> String? {
        guard let data = Data.init(multibaseEncoded: publicKey),
            let address = pkToAddress(roleType: roleType, keyType: keyType, hashType: hashType, publicKey: data) else {
                return nil
        }
        return "did:abt:" + address
    }

    public static func getSwapAddress(data: Data) -> String? {
        return hashToAddress(roleType: .swap, keyType: .ed25519, hashType: .sha2, hash: data)
    }

    public static func getDelegateAddress(sender: String, receiver: String) -> String? {
        if let senderData = sender.data(using: .utf8),
            let receiverData = receiver.data(using: .utf8) {
            return hashToAddress(roleType: .delegate, keyType: .ed25519, hashType: .sha3, hash: MCrypto.Hasher.Sha3.sha(senderData + receiverData))
        }
        return nil
    }

    public static func getUserPk(userPrivateKey: Data) -> Data? {
        return MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: userPrivateKey)
    }

    public static func pkToAddress(roleType: RoleType, keyType: KeyType, hashType: HashType, publicKey: Data) -> String? {
        if let hash = hashType.hash(data: publicKey) {
            return hashToAddress(roleType: roleType, keyType: keyType, hashType: hashType, hash: hash)
        }
        return nil
    }

    private static func hashToAddress(roleType: RoleType, keyType: KeyType, hashType: HashType, hash: Data) -> String? {
        let truncatedHash = hash.prefix(20)
        let didTypeBytes = calculateTypeBytes(roleType: roleType, keyType: keyType, hashType: hashType)
        let prefixedHash = didTypeBytes + truncatedHash
        if let extendedHash = hashType.hash(data: prefixedHash) {
            let suffix = extendedHash.prefix(4)
            let fullHash = prefixedHash + suffix
            let base58DidString = fullHash.multibaseEncodedString(inBase: .base58BTC)
            return base58DidString
        }
        return nil
    }

    public static func calculateTypeBytes(roleType: RoleType, keyType: KeyType, hashType: HashType) -> Data {
        var didTypeBytes: UInt16 = 0
        didTypeBytes = didTypeBytes | (UInt16(roleType.rawValue) << 10)
        didTypeBytes = didTypeBytes | (UInt16(keyType.rawValue) << 5)
        didTypeBytes = didTypeBytes | (UInt16(hashType.rawValue))
        return didTypeBytes.bigEndian.data
    }

    public static func calculateTypesFromDid(did: String) -> (roleType: RoleType, keyType: KeyType, hashType: HashType)? {
        var base58Did = did
        if let didWithoutPrefix = did.split(separator: ":").last {
            base58Did = String(didWithoutPrefix)
        }
        guard let base58DidData = Data.init(multibaseEncoded: base58Did) else {
            return nil
        }

        let didTypeBytes = Array(base58DidData.bytes.prefix(2))
        let u16 = UInt16(didTypeBytes[0]) << 8 + UInt16(didTypeBytes[1])
        guard let hashType = HashType.init(rawValue: Int8(u16 & 0b00011111)),
            let keyType = KeyType.init(rawValue: Int8((u16 >> 5) & 0b00011111)),
            let roleType = RoleType.init(rawValue: Int8((u16 >> 10) & 0b00111111)) else {
                return nil
        }
        return (roleType, keyType, hashType)
    }
}

extension Numeric {
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

extension Data {
    var uint64: UInt64? {
        get {
            let i64array = self.withUnsafeBytes {
                UnsafeBufferPointer<UInt64>(start: $0, count: self.count/2).map(UInt64.init(littleEndian:))
            }
            return i64array.count > 0 ? i64array[0] : nil
        }
    }
}
