// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: deploy_protocol.proto
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

public struct ForgeAbi_CodeInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// checksum of the module
  public var checksum: Data = SwiftProtobuf.Internal.emptyData

  /// gzipped binary
  public var binary: Data = SwiftProtobuf.Internal.emptyData

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ForgeAbi_TypeUrls {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var url: String = String()

  public var module: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct ForgeAbi_DeployProtocolTx {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// address of the tx protocol
  public var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  /// human readable name of the transaction, shall only contains alphabat and
  /// underscore. For CoreTx, it shall be compatible with existing definition in
  /// type_url.ex..
  public var name: String {
    get {return _storage._name}
    set {_uniqueStorage()._name = newValue}
  }

  /// version of the tx protocol. If version is 0, this is a genesis
  /// installation.
  public var version: UInt32 {
    get {return _storage._version}
    set {_uniqueStorage()._version = newValue}
  }

  /// namespace of the tx protocol. If namespace is CoreTx, it will use
  /// "fg:t:#{name}" as type_url, this is for backward compatibility.
  public var namespace: String {
    get {return _storage._namespace}
    set {_uniqueStorage()._namespace = newValue}
  }

  /// human readable description on what the tx is about, limited to 256 chars.
  public var description_p: String {
    get {return _storage._description_p}
    set {_uniqueStorage()._description_p = newValue}
  }

  /// new type urls used by this tx protocol. Will be registered in ForgeAbi
  public var typeUrls: [ForgeAbi_TypeUrls] {
    get {return _storage._typeUrls}
    set {_uniqueStorage()._typeUrls = newValue}
  }

  /// the protobuf definition for the tx protocol.
  public var proto: String {
    get {return _storage._proto}
    set {_uniqueStorage()._proto = newValue}
  }

  /// the pipeline of the tx protocol, in yaml format.
  public var pipeline: String {
    get {return _storage._pipeline}
    set {_uniqueStorage()._pipeline = newValue}
  }

  /// the source code for the tx protocol, in elixir.
  public var sources: [String] {
    get {return _storage._sources}
    set {_uniqueStorage()._sources = newValue}
  }

  /// the compressed code of the protocol
  public var code: [ForgeAbi_CodeInfo] {
    get {return _storage._code}
    set {_uniqueStorage()._code = newValue}
  }

  /// categories or tags this protocol belongs to
  public var tags: [String] {
    get {return _storage._tags}
    set {_uniqueStorage()._tags = newValue}
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

extension ForgeAbi_CodeInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CodeInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "checksum"),
    2: .same(proto: "binary"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularBytesField(value: &self.checksum)
      case 2: try decoder.decodeSingularBytesField(value: &self.binary)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.checksum.isEmpty {
      try visitor.visitSingularBytesField(value: self.checksum, fieldNumber: 1)
    }
    if !self.binary.isEmpty {
      try visitor.visitSingularBytesField(value: self.binary, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_CodeInfo, rhs: ForgeAbi_CodeInfo) -> Bool {
    if lhs.checksum != rhs.checksum {return false}
    if lhs.binary != rhs.binary {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_TypeUrls: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TypeUrls"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "url"),
    2: .same(proto: "module"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.url)
      case 2: try decoder.decodeSingularStringField(value: &self.module)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.url.isEmpty {
      try visitor.visitSingularStringField(value: self.url, fieldNumber: 1)
    }
    if !self.module.isEmpty {
      try visitor.visitSingularStringField(value: self.module, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_TypeUrls, rhs: ForgeAbi_TypeUrls) -> Bool {
    if lhs.url != rhs.url {return false}
    if lhs.module != rhs.module {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension ForgeAbi_DeployProtocolTx: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".DeployProtocolTx"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "address"),
    2: .same(proto: "name"),
    3: .same(proto: "version"),
    4: .same(proto: "namespace"),
    5: .same(proto: "description"),
    6: .standard(proto: "type_urls"),
    7: .same(proto: "proto"),
    8: .same(proto: "pipeline"),
    9: .same(proto: "sources"),
    10: .same(proto: "code"),
    11: .same(proto: "tags"),
    15: .same(proto: "data"),
  ]

  fileprivate class _StorageClass {
    var _address: String = String()
    var _name: String = String()
    var _version: UInt32 = 0
    var _namespace: String = String()
    var _description_p: String = String()
    var _typeUrls: [ForgeAbi_TypeUrls] = []
    var _proto: String = String()
    var _pipeline: String = String()
    var _sources: [String] = []
    var _code: [ForgeAbi_CodeInfo] = []
    var _tags: [String] = []
    var _data: SwiftProtobuf.Google_Protobuf_Any? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _address = source._address
      _name = source._name
      _version = source._version
      _namespace = source._namespace
      _description_p = source._description_p
      _typeUrls = source._typeUrls
      _proto = source._proto
      _pipeline = source._pipeline
      _sources = source._sources
      _code = source._code
      _tags = source._tags
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
        case 1: try decoder.decodeSingularStringField(value: &_storage._address)
        case 2: try decoder.decodeSingularStringField(value: &_storage._name)
        case 3: try decoder.decodeSingularUInt32Field(value: &_storage._version)
        case 4: try decoder.decodeSingularStringField(value: &_storage._namespace)
        case 5: try decoder.decodeSingularStringField(value: &_storage._description_p)
        case 6: try decoder.decodeRepeatedMessageField(value: &_storage._typeUrls)
        case 7: try decoder.decodeSingularStringField(value: &_storage._proto)
        case 8: try decoder.decodeSingularStringField(value: &_storage._pipeline)
        case 9: try decoder.decodeRepeatedStringField(value: &_storage._sources)
        case 10: try decoder.decodeRepeatedMessageField(value: &_storage._code)
        case 11: try decoder.decodeRepeatedStringField(value: &_storage._tags)
        case 15: try decoder.decodeSingularMessageField(value: &_storage._data)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 1)
      }
      if !_storage._name.isEmpty {
        try visitor.visitSingularStringField(value: _storage._name, fieldNumber: 2)
      }
      if _storage._version != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._version, fieldNumber: 3)
      }
      if !_storage._namespace.isEmpty {
        try visitor.visitSingularStringField(value: _storage._namespace, fieldNumber: 4)
      }
      if !_storage._description_p.isEmpty {
        try visitor.visitSingularStringField(value: _storage._description_p, fieldNumber: 5)
      }
      if !_storage._typeUrls.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._typeUrls, fieldNumber: 6)
      }
      if !_storage._proto.isEmpty {
        try visitor.visitSingularStringField(value: _storage._proto, fieldNumber: 7)
      }
      if !_storage._pipeline.isEmpty {
        try visitor.visitSingularStringField(value: _storage._pipeline, fieldNumber: 8)
      }
      if !_storage._sources.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._sources, fieldNumber: 9)
      }
      if !_storage._code.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._code, fieldNumber: 10)
      }
      if !_storage._tags.isEmpty {
        try visitor.visitRepeatedStringField(value: _storage._tags, fieldNumber: 11)
      }
      if let v = _storage._data {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: ForgeAbi_DeployProtocolTx, rhs: ForgeAbi_DeployProtocolTx) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._address != rhs_storage._address {return false}
        if _storage._name != rhs_storage._name {return false}
        if _storage._version != rhs_storage._version {return false}
        if _storage._namespace != rhs_storage._namespace {return false}
        if _storage._description_p != rhs_storage._description_p {return false}
        if _storage._typeUrls != rhs_storage._typeUrls {return false}
        if _storage._proto != rhs_storage._proto {return false}
        if _storage._pipeline != rhs_storage._pipeline {return false}
        if _storage._sources != rhs_storage._sources {return false}
        if _storage._code != rhs_storage._code {return false}
        if _storage._tags != rhs_storage._tags {return false}
        if _storage._data != rhs_storage._data {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}