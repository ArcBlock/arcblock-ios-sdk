// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: consume_asset.proto
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

public struct ForgeAbi_ConsumeAssetTx {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// `issuer` could be the same as `from`, or different, depending on use case.
  /// when this tx is being mutisigned by the asset holder, the wallet could
  /// check if the issuer is the issuer of the asset, otherwise wallet shall
  /// refuse signing it. when it goes into the chain, at verify state stage, we
  /// shall check `from` of this tx:
  ///  a. the same as the issuer
  ///  b. `from.issuer == issuer`
  /// For example, a museum issued a ticket and Alice bought it. At the
  /// door (doorman) of the meseum, Alice need to consume the asset, which she
  /// scan a QR code with a prepolulated ConsumeAssetTx. Most of the time, this
  /// prepopulated tx shall be signed by the account of the door (doorman) so
  /// that we can trace where and how Alice consumed this asset, however we don't
  /// want anyone to be able to create this tx to allure Alice to consume the
  /// asset, thus the door (doorman) shall be an account that issued by the
  /// museum. The chain will make sure only accounts that has this issuer would
  /// be able to successfully sign this tx.
  public var issuer: String {
    get {return _storage._issuer}
    set {_uniqueStorage()._issuer = newValue}
  }

  /// an asset might belong to another asset, for example a ticket belongs to a
  /// specific concert or movie asset. If this is provided, besides issuer we
  /// will verify if the parent address of the asset equals to this address.
  public var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  /// forge won't update data into state if app is interested in this tx.
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

extension ForgeAbi_ConsumeAssetTx: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ConsumeAssetTx"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "issuer"),
    2: .same(proto: "address"),
    15: .same(proto: "data"),
  ]

  fileprivate class _StorageClass {
    var _issuer: String = String()
    var _address: String = String()
    var _data: SwiftProtobuf.Google_Protobuf_Any? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _issuer = source._issuer
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
        case 1: try decoder.decodeSingularStringField(value: &_storage._issuer)
        case 2: try decoder.decodeSingularStringField(value: &_storage._address)
        case 15: try decoder.decodeSingularMessageField(value: &_storage._data)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._issuer.isEmpty {
        try visitor.visitSingularStringField(value: _storage._issuer, fieldNumber: 1)
      }
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 2)
      }
      if let v = _storage._data {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_ConsumeAssetTx, rhs: ForgeAbi_ConsumeAssetTx) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._issuer != rhs_storage._issuer {return false}
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