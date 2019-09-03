// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: stake.proto
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

/// type url: fg:x:stake_asset. Stake for Tx is the same as stake for asset.
public struct ForgeAbi_stakeForAsset {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// type url: fg:x:stake_chain. So far we haven't figured out how this could be
/// done.
public struct ForgeAbi_stakeForChain {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// type url: fg:x:stake_node
public struct ForgeAbi_StakeForNode {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// type url: fg:x:stake_user
public struct ForgeAbi_stakeForUser {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// Here we will reuse DeclareTx to declare a node.
/// DeclareTx could only be carried out by node admin. We will have an RPC
/// to ask forge to use the private key of the node and declare its identity.
/// Then an account state will be created for that node and later on people can
/// stake to that account. The top N staked nodes will be validators in the
/// chain.
/// Once a node is declared, people can use StakeTx to stake its tokens to it
/// minimun staked token is 1. stake could be very flexible, that one can stake
/// for a node, a user, an asset, a chain or a tx hash (normally a vote tx)
public struct ForgeAbi_StakeTx {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var to: String {
    get {return _storage._to}
    set {_uniqueStorage()._to = newValue}
  }

  public var value: ForgeAbi_BigSint {
    get {return _storage._value ?? ForgeAbi_BigSint()}
    set {_uniqueStorage()._value = newValue}
  }
  /// Returns true if `value` has been explicitly set.
  public var hasValue: Bool {return _storage._value != nil}
  /// Clears the value of `value`. Subsequent reads from it will return its default value.
  public mutating func clearValue() {_uniqueStorage()._value = nil}

  public var message: String {
    get {return _storage._message}
    set {_uniqueStorage()._message = newValue}
  }

  public var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  /// forge won't touch this field. Only forge app shall handle it.
  /// forge app can extend the stake if the given data cannot meet its
  /// requirement.
  public var data: SwiftProtobuf.Google_Protobuf_Any {
    get {return _storage._data ?? SwiftProtobuf.Google_Protobuf_Any()}
    set {_uniqueStorage()._data = newValue}
  }
  /// Returns true if `data` has been explicitly set.
  public var hasData: Bool {return _storage._data != nil}
  /// Clears the value of `data`. Subsequent reads from it will return its default value.
  public mutating func clearData() {_uniqueStorage()._data = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "forge_abi"

extension ForgeAbi_stakeForAsset: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".stakeForAsset"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_stakeForAsset, rhs: ForgeAbi_stakeForAsset) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_stakeForChain: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".stakeForChain"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_stakeForChain, rhs: ForgeAbi_stakeForChain) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_StakeForNode: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".StakeForNode"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_StakeForNode, rhs: ForgeAbi_StakeForNode) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_stakeForUser: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".stakeForUser"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_stakeForUser, rhs: ForgeAbi_stakeForUser) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_StakeTx: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".StakeTx"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "to"),
    2: .same(proto: "value"),
    3: .same(proto: "message"),
    4: .same(proto: "address"),
    15: .same(proto: "data"),
  ]

  fileprivate class _StorageClass {
    var _to: String = String()
    var _value: ForgeAbi_BigSint? = nil
    var _message: String = String()
    var _address: String = String()
    var _data: SwiftProtobuf.Google_Protobuf_Any? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _to = source._to
      _value = source._value
      _message = source._message
      _address = source._address
      _data = source._data
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        switch fieldNumber {
        case 1: try decoder.decodeSingularStringField(value: &_storage._to)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._value)
        case 3: try decoder.decodeSingularStringField(value: &_storage._message)
        case 4: try decoder.decodeSingularStringField(value: &_storage._address)
        case 15: try decoder.decodeSingularMessageField(value: &_storage._data)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._to.isEmpty {
        try visitor.visitSingularStringField(value: _storage._to, fieldNumber: 1)
      }
      if let v = _storage._value {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if !_storage._message.isEmpty {
        try visitor.visitSingularStringField(value: _storage._message, fieldNumber: 3)
      }
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 4)
      }
      if let v = _storage._data {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_StakeTx, rhs: ForgeAbi_StakeTx) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._to != rhs_storage._to {return false}
        if _storage._value != rhs_storage._value {return false}
        if _storage._message != rhs_storage._message {return false}
        if _storage._address != rhs_storage._address {return false}
        if _storage._data != rhs_storage._data {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}