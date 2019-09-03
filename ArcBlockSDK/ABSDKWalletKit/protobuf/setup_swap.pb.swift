// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: setup_swap.proto
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

public struct ForgeAbi_SetupSwapTx {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The amount of token to swap.
  public var value: ForgeAbi_BigUint {
    get {return _storage._value ?? ForgeAbi_BigUint()}
    set {_uniqueStorage()._value = newValue}
  }
  /// Returns true if `value` has been explicitly set.
  public var hasValue: Bool {return _storage._value != nil}
  /// Clears the value of `value`. Subsequent reads from it will return its default value.
  public mutating func clearValue() {_uniqueStorage()._value = nil}

  /// The addresses of assets to swap.
  public var assets: [String] {
    get {return _storage._assets}
    set {_uniqueStorage()._assets = newValue}
  }

  /// The address of the receiver who is the only one allowed to get the token and assets locktime.
  public var receiver: String {
    get {return _storage._receiver}
    set {_uniqueStorage()._receiver = newValue}
  }

  /// The sha3 value of the random number.
  public var hashlock: Data {
    get {return _storage._hashlock}
    set {_uniqueStorage()._hashlock = newValue}
  }

  /// The height of the block before which the swap is locked.
  public var locktime: UInt32 {
    get {return _storage._locktime}
    set {_uniqueStorage()._locktime = newValue}
  }

  /// forge won't touch this field. Only forge app shall handle it.
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

extension ForgeAbi_SetupSwapTx: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetupSwapTx"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "value"),
    2: .same(proto: "assets"),
    3: .same(proto: "receiver"),
    4: .same(proto: "hashlock"),
    5: .same(proto: "locktime"),
    15: .same(proto: "data"),
  ]

  fileprivate class _StorageClass {
    var _value: ForgeAbi_BigUint? = nil
    var _assets: [String] = []
    var _receiver: String = String()
    var _hashlock: Data = SwiftProtobuf.Internal.emptyData
    var _locktime: UInt32 = 0
    var _data: SwiftProtobuf.Google_Protobuf_Any? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _value = source._value
      _assets = source._assets
      _receiver = source._receiver
      _hashlock = source._hashlock
      _locktime = source._locktime
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._value)
        case 2: try decoder.decodeRepeatedStringField(value: &_storage._assets)
        case 3: try decoder.decodeSingularStringField(value: &_storage._receiver)
        case 4: try decoder.decodeSingularBytesField(value: &_storage._hashlock)
        case 5: try decoder.decodeSingularUInt32Field(value: &_storage._locktime)
        case 15: try decoder.decodeSingularMessageField(value: &_storage._data)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._value {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_storage._assets.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._assets, fieldNumber: 2)
      }
      if !_storage._receiver.isEmpty {
        try visitor.visitSingularStringField(value: _storage._receiver, fieldNumber: 3)
      }
      if !_storage._hashlock.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._hashlock, fieldNumber: 4)
      }
      if _storage._locktime != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._locktime, fieldNumber: 5)
      }
      if let v = _storage._data {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_SetupSwapTx, rhs: ForgeAbi_SetupSwapTx) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._value != rhs_storage._value {return false}
        if _storage._assets != rhs_storage._assets {return false}
        if _storage._receiver != rhs_storage._receiver {return false}
        if _storage._hashlock != rhs_storage._hashlock {return false}
        if _storage._locktime != rhs_storage._locktime {return false}
        if _storage._data != rhs_storage._data {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
