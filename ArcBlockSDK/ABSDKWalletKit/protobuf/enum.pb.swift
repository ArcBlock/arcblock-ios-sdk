// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: enum.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public enum ForgeAbi_StatusCode: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case ok // = 0

  /// common code
  /// 1 - 15
  case invalidNonce // = 1
  case invalidSignature // = 2
  case invalidSenderState // = 3
  case invalidReceiverState // = 4
  case insufficientData // = 5
  case insufficientFund // = 6
  case invalidOwner // = 7
  case invalidTx // = 8
  case unsupportedTx // = 9
  case expiredTx // = 10
  case tooManyTxs // = 11
  case invalidLockStatus // = 12
  case invalidRequest // = 13

  /// 16 - 2047 various errors
  case invalidMoniker // = 16
  case invalidPassphrase // = 17
  case invalidMultisig // = 20
  case invalidWallet // = 21
  case invalidChainID // = 22
  case consensusRpcError // = 24
  case storageRpcError // = 25
  case noent // = 26
  case accountMigrated // = 27
  case unsupportedStake // = 30
  case insufficientStake // = 31
  case invalidStakeState // = 32
  case expiredWalletToken // = 33
  case bannedUnstake // = 34
  case invalidAsset // = 35
  case invalidTxSize // = 36
  case invalidSignerState // = 37
  case invalidForgeState // = 38
  case expiredAsset // = 39
  case untransferrableAsset // = 40
  case readonlyAsset // = 41
  case consumedAsset // = 42
  case invalidDepositValue // = 43
  case exceedDepositCap // = 44
  case invalidDepositTarget // = 45
  case invalidDepositor // = 46
  case invalidWithdrawer // = 47
  case duplicateTether // = 48
  case invalidExpiryDate // = 49
  case invalidDeposit // = 50
  case invalidCustodian // = 51
  case insufficientGas // = 52
  case invalidSwap // = 53
  case invalidHashkey // = 54
  case invalidDelegation // = 55
  case insufficientDelegation // = 56
  case invalidDelegationRule // = 57
  case invalidDelegationTypeURL // = 58
  case senderNotAuthorized // = 59
  case protocolNotRunning // = 60
  case protocolNotPaused // = 61
  case protocolNotActivated // = 62
  case invalidDeactivation // = 63
  case senderWithdrawItemsFull // = 64
  case withdrawItemMissing // = 65
  case invalidWithdrawTx // = 66
  case invalidChainType // = 67
  case forbidden // = 403
  case `internal` // = 500
  case timeout // = 504
  case UNRECOGNIZED(Int)

  public init() {
    self = .ok
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .ok
    case 1: self = .invalidNonce
    case 2: self = .invalidSignature
    case 3: self = .invalidSenderState
    case 4: self = .invalidReceiverState
    case 5: self = .insufficientData
    case 6: self = .insufficientFund
    case 7: self = .invalidOwner
    case 8: self = .invalidTx
    case 9: self = .unsupportedTx
    case 10: self = .expiredTx
    case 11: self = .tooManyTxs
    case 12: self = .invalidLockStatus
    case 13: self = .invalidRequest
    case 16: self = .invalidMoniker
    case 17: self = .invalidPassphrase
    case 20: self = .invalidMultisig
    case 21: self = .invalidWallet
    case 22: self = .invalidChainID
    case 24: self = .consensusRpcError
    case 25: self = .storageRpcError
    case 26: self = .noent
    case 27: self = .accountMigrated
    case 30: self = .unsupportedStake
    case 31: self = .insufficientStake
    case 32: self = .invalidStakeState
    case 33: self = .expiredWalletToken
    case 34: self = .bannedUnstake
    case 35: self = .invalidAsset
    case 36: self = .invalidTxSize
    case 37: self = .invalidSignerState
    case 38: self = .invalidForgeState
    case 39: self = .expiredAsset
    case 40: self = .untransferrableAsset
    case 41: self = .readonlyAsset
    case 42: self = .consumedAsset
    case 43: self = .invalidDepositValue
    case 44: self = .exceedDepositCap
    case 45: self = .invalidDepositTarget
    case 46: self = .invalidDepositor
    case 47: self = .invalidWithdrawer
    case 48: self = .duplicateTether
    case 49: self = .invalidExpiryDate
    case 50: self = .invalidDeposit
    case 51: self = .invalidCustodian
    case 52: self = .insufficientGas
    case 53: self = .invalidSwap
    case 54: self = .invalidHashkey
    case 55: self = .invalidDelegation
    case 56: self = .insufficientDelegation
    case 57: self = .invalidDelegationRule
    case 58: self = .invalidDelegationTypeURL
    case 59: self = .senderNotAuthorized
    case 60: self = .protocolNotRunning
    case 61: self = .protocolNotPaused
    case 62: self = .protocolNotActivated
    case 63: self = .invalidDeactivation
    case 64: self = .senderWithdrawItemsFull
    case 65: self = .withdrawItemMissing
    case 66: self = .invalidWithdrawTx
    case 67: self = .invalidChainType
    case 403: self = .forbidden
    case 500: self = .internal
    case 504: self = .timeout
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .ok: return 0
    case .invalidNonce: return 1
    case .invalidSignature: return 2
    case .invalidSenderState: return 3
    case .invalidReceiverState: return 4
    case .insufficientData: return 5
    case .insufficientFund: return 6
    case .invalidOwner: return 7
    case .invalidTx: return 8
    case .unsupportedTx: return 9
    case .expiredTx: return 10
    case .tooManyTxs: return 11
    case .invalidLockStatus: return 12
    case .invalidRequest: return 13
    case .invalidMoniker: return 16
    case .invalidPassphrase: return 17
    case .invalidMultisig: return 20
    case .invalidWallet: return 21
    case .invalidChainID: return 22
    case .consensusRpcError: return 24
    case .storageRpcError: return 25
    case .noent: return 26
    case .accountMigrated: return 27
    case .unsupportedStake: return 30
    case .insufficientStake: return 31
    case .invalidStakeState: return 32
    case .expiredWalletToken: return 33
    case .bannedUnstake: return 34
    case .invalidAsset: return 35
    case .invalidTxSize: return 36
    case .invalidSignerState: return 37
    case .invalidForgeState: return 38
    case .expiredAsset: return 39
    case .untransferrableAsset: return 40
    case .readonlyAsset: return 41
    case .consumedAsset: return 42
    case .invalidDepositValue: return 43
    case .exceedDepositCap: return 44
    case .invalidDepositTarget: return 45
    case .invalidDepositor: return 46
    case .invalidWithdrawer: return 47
    case .duplicateTether: return 48
    case .invalidExpiryDate: return 49
    case .invalidDeposit: return 50
    case .invalidCustodian: return 51
    case .insufficientGas: return 52
    case .invalidSwap: return 53
    case .invalidHashkey: return 54
    case .invalidDelegation: return 55
    case .insufficientDelegation: return 56
    case .invalidDelegationRule: return 57
    case .invalidDelegationTypeURL: return 58
    case .senderNotAuthorized: return 59
    case .protocolNotRunning: return 60
    case .protocolNotPaused: return 61
    case .protocolNotActivated: return 62
    case .invalidDeactivation: return 63
    case .senderWithdrawItemsFull: return 64
    case .withdrawItemMissing: return 65
    case .invalidWithdrawTx: return 66
    case .invalidChainType: return 67
    case .forbidden: return 403
    case .internal: return 500
    case .timeout: return 504
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_StatusCode: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_StatusCode] = [
    .ok,
    .invalidNonce,
    .invalidSignature,
    .invalidSenderState,
    .invalidReceiverState,
    .insufficientData,
    .insufficientFund,
    .invalidOwner,
    .invalidTx,
    .unsupportedTx,
    .expiredTx,
    .tooManyTxs,
    .invalidLockStatus,
    .invalidRequest,
    .invalidMoniker,
    .invalidPassphrase,
    .invalidMultisig,
    .invalidWallet,
    .invalidChainID,
    .consensusRpcError,
    .storageRpcError,
    .noent,
    .accountMigrated,
    .unsupportedStake,
    .insufficientStake,
    .invalidStakeState,
    .expiredWalletToken,
    .bannedUnstake,
    .invalidAsset,
    .invalidTxSize,
    .invalidSignerState,
    .invalidForgeState,
    .expiredAsset,
    .untransferrableAsset,
    .readonlyAsset,
    .consumedAsset,
    .invalidDepositValue,
    .exceedDepositCap,
    .invalidDepositTarget,
    .invalidDepositor,
    .invalidWithdrawer,
    .duplicateTether,
    .invalidExpiryDate,
    .invalidDeposit,
    .invalidCustodian,
    .insufficientGas,
    .invalidSwap,
    .invalidHashkey,
    .invalidDelegation,
    .insufficientDelegation,
    .invalidDelegationRule,
    .invalidDelegationTypeURL,
    .senderNotAuthorized,
    .protocolNotRunning,
    .protocolNotPaused,
    .protocolNotActivated,
    .invalidDeactivation,
    .senderWithdrawItemsFull,
    .withdrawItemMissing,
    .invalidWithdrawTx,
    .invalidChainType,
    .forbidden,
    .internal,
    .timeout,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_KeyType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case ed25519 // = 0
  case secp256K1 // = 1
  case UNRECOGNIZED(Int)

  public init() {
    self = .ed25519
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .ed25519
    case 1: self = .secp256K1
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .ed25519: return 0
    case .secp256K1: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_KeyType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_KeyType] = [
    .ed25519,
    .secp256K1,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_HashType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case keccak // = 0
  case sha3 // = 1
  case sha2 // = 2
  case keccak384 // = 6
  case sha3384 // = 7
  case keccak512 // = 13
  case sha3512 // = 14
  case UNRECOGNIZED(Int)

  public init() {
    self = .keccak
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .keccak
    case 1: self = .sha3
    case 2: self = .sha2
    case 6: self = .keccak384
    case 7: self = .sha3384
    case 13: self = .keccak512
    case 14: self = .sha3512
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .keccak: return 0
    case .sha3: return 1
    case .sha2: return 2
    case .keccak384: return 6
    case .sha3384: return 7
    case .keccak512: return 13
    case .sha3512: return 14
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_HashType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_HashType] = [
    .keccak,
    .sha3,
    .sha2,
    .keccak384,
    .sha3384,
    .keccak512,
    .sha3512,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_EncodingType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case base16 // = 0
  case base58 // = 1
  case UNRECOGNIZED(Int)

  public init() {
    self = .base16
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .base16
    case 1: self = .base58
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .base16: return 0
    case .base58: return 1
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_EncodingType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_EncodingType] = [
    .base16,
    .base58,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_RoleType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case roleAccount // = 0
  case roleNode // = 1
  case roleDevice // = 2
  case roleApplication // = 3
  case roleSmartContract // = 4
  case roleBot // = 5
  case roleAsset // = 6
  case roleStake // = 7
  case roleValidator // = 8
  case roleGroup // = 9
  case roleTx // = 10
  case roleTether // = 11
  case roleAny // = 63
  case UNRECOGNIZED(Int)

  public init() {
    self = .roleAccount
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .roleAccount
    case 1: self = .roleNode
    case 2: self = .roleDevice
    case 3: self = .roleApplication
    case 4: self = .roleSmartContract
    case 5: self = .roleBot
    case 6: self = .roleAsset
    case 7: self = .roleStake
    case 8: self = .roleValidator
    case 9: self = .roleGroup
    case 10: self = .roleTx
    case 11: self = .roleTether
    case 63: self = .roleAny
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .roleAccount: return 0
    case .roleNode: return 1
    case .roleDevice: return 2
    case .roleApplication: return 3
    case .roleSmartContract: return 4
    case .roleBot: return 5
    case .roleAsset: return 6
    case .roleStake: return 7
    case .roleValidator: return 8
    case .roleGroup: return 9
    case .roleTx: return 10
    case .roleTether: return 11
    case .roleAny: return 63
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_RoleType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_RoleType] = [
    .roleAccount,
    .roleNode,
    .roleDevice,
    .roleApplication,
    .roleSmartContract,
    .roleBot,
    .roleAsset,
    .roleStake,
    .roleValidator,
    .roleGroup,
    .roleTx,
    .roleTether,
    .roleAny,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_UpgradeType: SwiftProtobuf.Enum {
  public typealias RawValue = Int

  /// configuration
  case configApp // = 0
  case configForge // = 1
  case configDfs // = 2
  case configConsensus // = 3
  case configP2P // = 4

  /// executable
  case exeApp // = 10
  case exeForge // = 11
  case exeDfs // = 12
  case exeConsensus // = 13
  case exeP2P // = 14
  case UNRECOGNIZED(Int)

  public init() {
    self = .configApp
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .configApp
    case 1: self = .configForge
    case 2: self = .configDfs
    case 3: self = .configConsensus
    case 4: self = .configP2P
    case 10: self = .exeApp
    case 11: self = .exeForge
    case 12: self = .exeDfs
    case 13: self = .exeConsensus
    case 14: self = .exeP2P
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .configApp: return 0
    case .configForge: return 1
    case .configDfs: return 2
    case .configConsensus: return 3
    case .configP2P: return 4
    case .exeApp: return 10
    case .exeForge: return 11
    case .exeDfs: return 12
    case .exeConsensus: return 13
    case .exeP2P: return 14
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_UpgradeType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_UpgradeType] = [
    .configApp,
    .configForge,
    .configDfs,
    .configConsensus,
    .configP2P,
    .exeApp,
    .exeForge,
    .exeDfs,
    .exeConsensus,
    .exeP2P,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_UpgradeAction: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case verify // = 0
  case backup // = 1
  case replace // = 2

  /// restart different part of the system
  case restartApp // = 10
  case restartDfs // = 11
  case restartConsensus // = 12
  case restartP2P // = 13

  /// restart forge will indirectly restart all component in a graceful manner
  case restartForge // = 14

  /// depend on deployment, the monitor app (e.g. systemd) shall bring the
  /// process back
  case rollbackIfFail // = 30
  case restartAllIfFail // = 31
  case crashIfFail // = 33

  /// drop different intermediate files
  case dropAddressBook // = 50
  case UNRECOGNIZED(Int)

  public init() {
    self = .verify
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .verify
    case 1: self = .backup
    case 2: self = .replace
    case 10: self = .restartApp
    case 11: self = .restartDfs
    case 12: self = .restartConsensus
    case 13: self = .restartP2P
    case 14: self = .restartForge
    case 30: self = .rollbackIfFail
    case 31: self = .restartAllIfFail
    case 33: self = .crashIfFail
    case 50: self = .dropAddressBook
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .verify: return 0
    case .backup: return 1
    case .replace: return 2
    case .restartApp: return 10
    case .restartDfs: return 11
    case .restartConsensus: return 12
    case .restartP2P: return 13
    case .restartForge: return 14
    case .rollbackIfFail: return 30
    case .restartAllIfFail: return 31
    case .crashIfFail: return 33
    case .dropAddressBook: return 50
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_UpgradeAction: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_UpgradeAction] = [
    .verify,
    .backup,
    .replace,
    .restartApp,
    .restartDfs,
    .restartConsensus,
    .restartP2P,
    .restartForge,
    .rollbackIfFail,
    .restartAllIfFail,
    .crashIfFail,
    .dropAddressBook,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_StateType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case stateAccount // = 0
  case stateAsset // = 1
  case stateChannel // = 2
  case stateForge // = 3
  case stateStake // = 4
  case UNRECOGNIZED(Int)

  public init() {
    self = .stateAccount
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .stateAccount
    case 1: self = .stateAsset
    case 2: self = .stateChannel
    case 3: self = .stateForge
    case 4: self = .stateStake
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .stateAccount: return 0
    case .stateAsset: return 1
    case .stateChannel: return 2
    case .stateForge: return 3
    case .stateStake: return 4
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_StateType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_StateType] = [
    .stateAccount,
    .stateAsset,
    .stateChannel,
    .stateForge,
    .stateStake,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_StakeType: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case stakeNode // = 0
  case stakeUser // = 1
  case stakeAsset // = 2
  case stakeChain // = 3
  case UNRECOGNIZED(Int)

  public init() {
    self = .stakeNode
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .stakeNode
    case 1: self = .stakeUser
    case 2: self = .stakeAsset
    case 3: self = .stakeChain
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .stakeNode: return 0
    case .stakeUser: return 1
    case .stakeAsset: return 2
    case .stakeChain: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_StakeType: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_StakeType] = [
    .stakeNode,
    .stakeUser,
    .stakeAsset,
    .stakeChain,
  ]
}

#endif  // swift(>=4.2)

public enum ForgeAbi_ProtocolStatus: SwiftProtobuf.Enum {
  public typealias RawValue = Int
  case running // = 0
  case paused // = 1
  case terminated // = 2
  case UNRECOGNIZED(Int)

  public init() {
    self = .running
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .running
    case 1: self = .paused
    case 2: self = .terminated
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .running: return 0
    case .paused: return 1
    case .terminated: return 2
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension ForgeAbi_ProtocolStatus: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static var allCases: [ForgeAbi_ProtocolStatus] = [
    .running,
    .paused,
    .terminated,
  ]
}

#endif  // swift(>=4.2)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension ForgeAbi_StatusCode: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ok"),
    1: .same(proto: "invalid_nonce"),
    2: .same(proto: "invalid_signature"),
    3: .same(proto: "invalid_sender_state"),
    4: .same(proto: "invalid_receiver_state"),
    5: .same(proto: "insufficient_data"),
    6: .same(proto: "insufficient_fund"),
    7: .same(proto: "invalid_owner"),
    8: .same(proto: "invalid_tx"),
    9: .same(proto: "unsupported_tx"),
    10: .same(proto: "expired_tx"),
    11: .same(proto: "too_many_txs"),
    12: .same(proto: "invalid_lock_status"),
    13: .same(proto: "invalid_request"),
    16: .same(proto: "invalid_moniker"),
    17: .same(proto: "invalid_passphrase"),
    20: .same(proto: "invalid_multisig"),
    21: .same(proto: "invalid_wallet"),
    22: .same(proto: "invalid_chain_id"),
    24: .same(proto: "consensus_rpc_error"),
    25: .same(proto: "storage_rpc_error"),
    26: .same(proto: "noent"),
    27: .same(proto: "account_migrated"),
    30: .same(proto: "unsupported_stake"),
    31: .same(proto: "insufficient_stake"),
    32: .same(proto: "invalid_stake_state"),
    33: .same(proto: "expired_wallet_token"),
    34: .same(proto: "banned_unstake"),
    35: .same(proto: "invalid_asset"),
    36: .same(proto: "invalid_tx_size"),
    37: .same(proto: "invalid_signer_state"),
    38: .same(proto: "invalid_forge_state"),
    39: .same(proto: "expired_asset"),
    40: .same(proto: "untransferrable_asset"),
    41: .same(proto: "readonly_asset"),
    42: .same(proto: "consumed_asset"),
    43: .same(proto: "invalid_deposit_value"),
    44: .same(proto: "exceed_deposit_cap"),
    45: .same(proto: "invalid_deposit_target"),
    46: .same(proto: "invalid_depositor"),
    47: .same(proto: "invalid_withdrawer"),
    48: .same(proto: "duplicate_tether"),
    49: .same(proto: "invalid_expiry_date"),
    50: .same(proto: "invalid_deposit"),
    51: .same(proto: "invalid_custodian"),
    52: .same(proto: "insufficient_gas"),
    53: .same(proto: "invalid_swap"),
    54: .same(proto: "invalid_hashkey"),
    55: .same(proto: "invalid_delegation"),
    56: .same(proto: "insufficient_delegation"),
    57: .same(proto: "invalid_delegation_rule"),
    58: .same(proto: "invalid_delegation_type_url"),
    59: .same(proto: "sender_not_authorized"),
    60: .same(proto: "protocol_not_running"),
    61: .same(proto: "protocol_not_paused"),
    62: .same(proto: "protocol_not_activated"),
    63: .same(proto: "invalid_deactivation"),
    64: .same(proto: "sender_withdraw_items_full"),
    65: .same(proto: "withdraw_item_missing"),
    66: .same(proto: "invalid_withdraw_tx"),
    67: .same(proto: "invalid_chain_type"),
    403: .same(proto: "forbidden"),
    500: .same(proto: "internal"),
    504: .same(proto: "timeout"),
  ]
}

extension ForgeAbi_KeyType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ed25519"),
    1: .same(proto: "secp256k1"),
  ]
}

extension ForgeAbi_HashType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "keccak"),
    1: .same(proto: "sha3"),
    2: .same(proto: "sha2"),
    6: .same(proto: "keccak_384"),
    7: .same(proto: "sha3_384"),
    13: .same(proto: "keccak_512"),
    14: .same(proto: "sha3_512"),
  ]
}

extension ForgeAbi_EncodingType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "base16"),
    1: .same(proto: "base58"),
  ]
}

extension ForgeAbi_RoleType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "role_account"),
    1: .same(proto: "role_node"),
    2: .same(proto: "role_device"),
    3: .same(proto: "role_application"),
    4: .same(proto: "role_smart_contract"),
    5: .same(proto: "role_bot"),
    6: .same(proto: "role_asset"),
    7: .same(proto: "role_stake"),
    8: .same(proto: "role_validator"),
    9: .same(proto: "role_group"),
    10: .same(proto: "role_tx"),
    11: .same(proto: "role_tether"),
    63: .same(proto: "role_any"),
  ]
}

extension ForgeAbi_UpgradeType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "config_app"),
    1: .same(proto: "config_forge"),
    2: .same(proto: "config_dfs"),
    3: .same(proto: "config_consensus"),
    4: .same(proto: "config_p2p"),
    10: .same(proto: "exe_app"),
    11: .same(proto: "exe_forge"),
    12: .same(proto: "exe_dfs"),
    13: .same(proto: "exe_consensus"),
    14: .same(proto: "exe_p2p"),
  ]
}

extension ForgeAbi_UpgradeAction: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "verify"),
    1: .same(proto: "backup"),
    2: .same(proto: "replace"),
    10: .same(proto: "restart_app"),
    11: .same(proto: "restart_dfs"),
    12: .same(proto: "restart_consensus"),
    13: .same(proto: "restart_p2p"),
    14: .same(proto: "restart_forge"),
    30: .same(proto: "rollback_if_fail"),
    31: .same(proto: "restart_all_if_fail"),
    33: .same(proto: "crash_if_fail"),
    50: .same(proto: "drop_address_book"),
  ]
}

extension ForgeAbi_StateType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "state_account"),
    1: .same(proto: "state_asset"),
    2: .same(proto: "state_channel"),
    3: .same(proto: "state_forge"),
    4: .same(proto: "state_stake"),
  ]
}

extension ForgeAbi_StakeType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "stake_node"),
    1: .same(proto: "stake_user"),
    2: .same(proto: "stake_asset"),
    3: .same(proto: "stake_chain"),
  ]
}

extension ForgeAbi_ProtocolStatus: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "running"),
    1: .same(proto: "paused"),
    2: .same(proto: "terminated"),
  ]
}
