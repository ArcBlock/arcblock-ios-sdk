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
    case ethereum = 2

    // childSeed to PublicKey
    public func privateKeyToPublicKey(privateKey: Data) -> Data? {
        switch self {
        case .ed25519:
            return MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: privateKey)
        case .secp256k1:
            return MCrypto.Signer.M_SECP256K1.privateKeyToPublicKey(privateKey: privateKey)
        case .ethereum:
            return MCrypto.Signer.ETHEREUM.privateKeyToPublicKey(privateKey: privateKey)
        }
    }

    public func getKeypair() -> (Data?, Data?) {
        switch self {
        case .ed25519:
            return MCrypto.Signer.ED25519.keypair()
        case .secp256k1:
            return MCrypto.Signer.M_SECP256K1.keypair()
        case .ethereum:
            return MCrypto.Signer.ETHEREUM.keypair()
        }
    }

    public func getKeypair(by privateKey: Data) -> (Data?, Data?) {
        switch self {
        case .ed25519:
            return (MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: privateKey) , privateKey)
        case .secp256k1:
            return (MCrypto.Signer.M_SECP256K1.privateKeyToPublicKey(privateKey: privateKey) , privateKey)
        case .ethereum:
            return (MCrypto.Signer.ETHEREUM.privateKeyToPublicKey(privateKey: privateKey) , privateKey)
        }
    }


    public static func keyTypeWithName(_ name: String) -> KeyType {
        switch name.lowercased() {
        case "secp256k1":
            return .secp256k1
        case "ed25519":
            return .ed25519
        case "ethereum" :
            return .ethereum
        default:
            return .ed25519
        }
    }
    
    public func name() -> String {
        switch self {
        case .ed25519:
            return "ed25519"
        case .secp256k1:
            return "secp256k1"
        case .ethereum:
            return "ethereum"
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

public enum EncodingType: Int8 {
    case base16 = 0
    case base58 = 1
    
    public func encodedtring(_ value: Data) -> String {
        switch self {
        case .base16:
            return value.multibaseEncodedString(inBase: .base16)
        case .base58:
            return value.multibaseEncodedString(inBase: .base58BTC)
        }
    }
}

public struct DidType: Equatable {
    
    
    public var roleType: RoleType = .account
    public var keyType: KeyType = .ed25519
    public var hashType: HashType = .sha3
    public var encodingType: EncodingType = .base58
    
    public init(roleType: RoleType, keyType: KeyType, hashType: HashType, encodingType: EncodingType) {
        self.roleType = roleType
        self.keyType = keyType
        self.hashType = hashType
        self.encodingType = encodingType
    }
    
    public struct Types {
        public static let didTypeForge = DidType(roleType: .account, keyType: .ed25519, hashType: .sha3, encodingType: .base58)
        public static let didTypeForgeDelegate = DidType(roleType: .delegate, keyType: .ed25519, hashType: .sha3, encodingType: .base58)
        public static let didTypeForgeTether = DidType(roleType: .tether, keyType: .ed25519, hashType: .sha2, encodingType: .base58)
        public static let didTypeForgeValidator = DidType(roleType: .validator, keyType: .ed25519, hashType: .sha2, encodingType: .base58)
        public static let didTypeForgeNode = DidType(roleType: .node, keyType: .ed25519, hashType: .sha2, encodingType: .base58)
        public static let didTypeForgeSwap = DidType(roleType: .swap, keyType: .ed25519, hashType: .sha2, encodingType: .base58)
        public static let didTypeForgeStake = DidType(roleType: .stake, keyType: .ed25519, hashType: .sha3, encodingType: .base58)
        public static let didTypeForgeTx = DidType(roleType: .tx, keyType: .ed25519, hashType: .sha3, encodingType: .base58)
        public static let didTypeForgeApplication = DidType(roleType: .application, keyType: .ed25519, hashType: .sha3, encodingType: .base58)
        public static let didTypeForgeEthereum = DidType(roleType: .account, keyType: .ethereum, hashType: .keccak, encodingType: .base16)
    }
    
    public func sign(message: Data, privateKey: Data) -> Data? {
        switch self.keyType {
        case .ed25519:
            return MCrypto.Signer.ED25519.sign(message: message, privateKey: privateKey)
        case .secp256k1:
            return MCrypto.Signer.M_SECP256K1.sign(message: message, privateKey: privateKey)
        case .ethereum:
            return MCrypto.Signer.ETHEREUM.sign(message: message, privateKey: privateKey)
        }
    }
    
    public func verify(message: Data, signature: Data, publicKey: Data) -> Bool {
        switch self.keyType {
        case .ed25519:
            return MCrypto.Signer.ED25519.verify(message: message, signature: signature, publicKey: publicKey)
        case .secp256k1:
            return MCrypto.Signer.M_SECP256K1.verify(message: message, signature: signature, publicKey: publicKey)
        case .ethereum:
            return MCrypto.Signer.ETHEREUM.verify(message: message, signature: signature, publicKey: publicKey)
        }
    }
}

public class DidHelper {
    
    public static func getUserDid(userPrivateKey: Data) -> String? {        
        return getUserDid(didType: DidType.Types.didTypeForge, privateKey: userPrivateKey)
    }

    // sk2addres
    public static func getUserDid(didType: DidType, privateKey: Data) -> String? {
        guard let publicKey = didType.keyType.privateKeyToPublicKey(privateKey: privateKey) else { return nil }
        return DidHelper.getUserDid(didType: didType, publicKey: publicKey)
    }

    public static func getUserDid(didType: DidType, publicKey: Data) -> String? {
        if didType.keyType == .ethereum {
            guard let address = pkToAddress(didType: didType, publicKey: publicKey) else {
                return nil
            }
            return EthereumAddress.toChecksumAddress(address)
        } else {
            guard let address = pkToAddress(didType: didType, publicKey: publicKey) else {
                return nil
            }
            return "did:abt:" + address
        }
    }

    public static func getSwapAddress(data: Data) -> String? {
        return hashToAddress(didType: DidType.Types.didTypeForgeSwap, hash: data)
    }

    public static func getDelegateAddress(sender: String, receiver: String) -> String? {
        if let senderData = sender.data(using: .utf8),
            let receiverData = receiver.data(using: .utf8) {
            return hashToAddress(didType: DidType.Types.didTypeForgeDelegate, hash: MCrypto.Hasher.Sha3.sha(senderData + receiverData))
        }
        return nil
    }

    public static func getUserPk(userPrivateKey: Data) -> Data? {
        return MCrypto.Signer.ED25519.privateKeyToPublicKey(privateKey: userPrivateKey)
    }

    public static func pkToAddress(didType: DidType, publicKey: Data) -> String? {
        if didType.keyType == .ethereum {
            let address = Web3.Utils.publicToAddress(publicKey)
            return address?.address
        } else if let hash = didType.hashType.hash(data: publicKey) {
            return hashToAddress(didType: didType, hash: hash)
        }
        return nil
    }

    private static func hashToAddress(didType: DidType, hash: Data) -> String? {
        let truncatedHash = hash.prefix(20)
        let didTypeBytes = calculateTypeBytes(didType: didType)
        let prefixedHash = didTypeBytes + truncatedHash
        if let extendedHash = didType.hashType.hash(data: prefixedHash) {
            let suffix = extendedHash.prefix(4)
            let fullHash = prefixedHash + suffix
            var encodeDidString = didType.encodingType.encodedtring(fullHash)
            if didType.encodingType == .base16 {                
                encodeDidString = "0x" + encodeDidString
            }
            return encodeDidString
        }
        return nil
    }

    public static func calculateTypeBytes(didType: DidType) -> Data {
        var didTypeBytes: UInt16 = 0
        didTypeBytes = didTypeBytes | (UInt16(didType.roleType.rawValue) << 10)
        didTypeBytes = didTypeBytes | (UInt16(didType.keyType.rawValue) << 5)
        didTypeBytes = didTypeBytes | (UInt16(didType.hashType.rawValue))
        return didTypeBytes.bigEndian.data
    }
    
    public static func getDidEncodingType(did: String) -> EncodingType {
        if (did.hasPrefix("z")) {
            return .base58
        } else {
            return .base16
        }
    }

    public static func calculateTypesFromDid(did: String) -> DidType? {
        if did.isEmpty {
            return DidType.Types.didTypeForge
        }

        let didWithoutPrefix = DidHelper.removeDidPrefix(did)
        
        if let address = EthereumAddress(didWithoutPrefix),
           address.isValid {
            return DidType.Types.didTypeForgeEthereum
        }
        
        var encodedDid = didWithoutPrefix
        
        if encodedDid.hasPrefix("0x") {
            encodedDid.removeFirst(2)
        }
        
        guard let encodedDidData = Data.init(multibaseEncoded: encodedDid) else {
            return nil
        }

        let didTypeBytes = Array(encodedDidData.bytes.prefix(2))
        let u16 = UInt16(didTypeBytes[0]) << 8 + UInt16(didTypeBytes[1])
        guard let hashType = HashType.init(rawValue: Int8(u16 & 0b00011111)),
            let keyType = KeyType.init(rawValue: Int8((u16 >> 5) & 0b00011111)),
            let roleType = RoleType.init(rawValue: Int8((u16 >> 10) & 0b00111111)) else {
                return nil
        }
        
        let encodingType = DidHelper.getDidEncodingType(did: didWithoutPrefix)
        
        return DidType(roleType: roleType, keyType: keyType, hashType: hashType, encodingType: encodingType)
    }
    
    public static func removeDidPrefix(_ did: String) -> String {
        if did.hasPrefix("did:abt:") {
            var newDid = did
            newDid.removeFirst(8)
            return newDid
        }
        return did
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
