// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: assets.proto
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

public struct AssetProtocol_TicketInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: UInt32 = 0

  public var eventAddress: String = String()

  public var isUsed: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct AssetProtocol_TicketHolder {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var ticketCreate: ForgeAbi_Transaction {
    get {return _storage._ticketCreate ?? ForgeAbi_Transaction()}
    set {_uniqueStorage()._ticketCreate = newValue}
  }
  /// Returns true if `ticketCreate` has been explicitly set.
  public var hasTicketCreate: Bool {return _storage._ticketCreate != nil}
  /// Clears the value of `ticketCreate`. Subsequent reads from it will return its default value.
  public mutating func clearTicketCreate() {_uniqueStorage()._ticketCreate = nil}

  public var ticketExchange: ForgeAbi_Transaction {
    get {return _storage._ticketExchange ?? ForgeAbi_Transaction()}
    set {_uniqueStorage()._ticketExchange = newValue}
  }
  /// Returns true if `ticketExchange` has been explicitly set.
  public var hasTicketExchange: Bool {return _storage._ticketExchange != nil}
  /// Clears the value of `ticketExchange`. Subsequent reads from it will return its default value.
  public mutating func clearTicketExchange() {_uniqueStorage()._ticketExchange = nil}

  public var id: UInt32 {
    get {return _storage._id}
    set {_uniqueStorage()._id = newValue}
  }

  public var address: String {
    get {return _storage._address}
    set {_uniqueStorage()._address = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

public struct AssetProtocol_GeneralTicket {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: String = String()

  /// same as event, fixed
  public var startTime: String = String()

  public var endTime: String = String()

  public var location: String = String()

  public var imgURL: String = String()

  public var title: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct AssetProtocol_EventInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var details: String = String()

  public var consumeAssetTx: Data = SwiftProtobuf.Internal.emptyData

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct AssetProtocol_Certificate {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var from: String = String()

  public var to: String = String()

  public var iat: UInt64 = 0

  public var nbf: UInt64 = 0

  public var exp: UInt64 = 0

  public var title: String = String()

  public var content: Int64 = 0

  public var sig: Data = SwiftProtobuf.Internal.emptyData

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "asset_protocol"

extension AssetProtocol_TicketInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TicketInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    3: .same(proto: "id"),
    4: .standard(proto: "event_address"),
    5: .standard(proto: "is_used"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 3: try decoder.decodeSingularUInt32Field(value: &self.id)
      case 4: try decoder.decodeSingularStringField(value: &self.eventAddress)
      case 5: try decoder.decodeSingularBoolField(value: &self.isUsed)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularUInt32Field(value: self.id, fieldNumber: 3)
    }
    if !self.eventAddress.isEmpty {
      try visitor.visitSingularStringField(value: self.eventAddress, fieldNumber: 4)
    }
    if self.isUsed != false {
      try visitor.visitSingularBoolField(value: self.isUsed, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AssetProtocol_TicketInfo, rhs: AssetProtocol_TicketInfo) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.eventAddress != rhs.eventAddress {return false}
    if lhs.isUsed != rhs.isUsed {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AssetProtocol_TicketHolder: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TicketHolder"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "ticket_create"),
    2: .standard(proto: "ticket_exchange"),
    4: .same(proto: "id"),
    5: .same(proto: "address"),
  ]

  fileprivate class _StorageClass {
    var _ticketCreate: ForgeAbi_Transaction? = nil
    var _ticketExchange: ForgeAbi_Transaction? = nil
    var _id: UInt32 = 0
    var _address: String = String()

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _ticketCreate = source._ticketCreate
      _ticketExchange = source._ticketExchange
      _id = source._id
      _address = source._address
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._ticketCreate)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._ticketExchange)
        case 4: try decoder.decodeSingularUInt32Field(value: &_storage._id)
        case 5: try decoder.decodeSingularStringField(value: &_storage._address)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._ticketCreate {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if let v = _storage._ticketExchange {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if _storage._id != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._id, fieldNumber: 4)
      }
      if !_storage._address.isEmpty {
        try visitor.visitSingularStringField(value: _storage._address, fieldNumber: 5)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AssetProtocol_TicketHolder, rhs: AssetProtocol_TicketHolder) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._ticketCreate != rhs_storage._ticketCreate {return false}
        if _storage._ticketExchange != rhs_storage._ticketExchange {return false}
        if _storage._id != rhs_storage._id {return false}
        if _storage._address != rhs_storage._address {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AssetProtocol_GeneralTicket: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GeneralTicket"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "start_time"),
    3: .standard(proto: "end_time"),
    4: .same(proto: "location"),
    6: .standard(proto: "img_url"),
    7: .same(proto: "title"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.id)
      case 2: try decoder.decodeSingularStringField(value: &self.startTime)
      case 3: try decoder.decodeSingularStringField(value: &self.endTime)
      case 4: try decoder.decodeSingularStringField(value: &self.location)
      case 6: try decoder.decodeSingularStringField(value: &self.imgURL)
      case 7: try decoder.decodeSingularStringField(value: &self.title)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.id.isEmpty {
      try visitor.visitSingularStringField(value: self.id, fieldNumber: 1)
    }
    if !self.startTime.isEmpty {
      try visitor.visitSingularStringField(value: self.startTime, fieldNumber: 2)
    }
    if !self.endTime.isEmpty {
      try visitor.visitSingularStringField(value: self.endTime, fieldNumber: 3)
    }
    if !self.location.isEmpty {
      try visitor.visitSingularStringField(value: self.location, fieldNumber: 4)
    }
    if !self.imgURL.isEmpty {
      try visitor.visitSingularStringField(value: self.imgURL, fieldNumber: 6)
    }
    if !self.title.isEmpty {
      try visitor.visitSingularStringField(value: self.title, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AssetProtocol_GeneralTicket, rhs: AssetProtocol_GeneralTicket) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.startTime != rhs.startTime {return false}
    if lhs.endTime != rhs.endTime {return false}
    if lhs.location != rhs.location {return false}
    if lhs.imgURL != rhs.imgURL {return false}
    if lhs.title != rhs.title {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AssetProtocol_EventInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".EventInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "details"),
    2: .standard(proto: "consume_asset_tx"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.details)
      case 2: try decoder.decodeSingularBytesField(value: &self.consumeAssetTx)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.details.isEmpty {
      try visitor.visitSingularStringField(value: self.details, fieldNumber: 1)
    }
    if !self.consumeAssetTx.isEmpty {
      try visitor.visitSingularBytesField(value: self.consumeAssetTx, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AssetProtocol_EventInfo, rhs: AssetProtocol_EventInfo) -> Bool {
    if lhs.details != rhs.details {return false}
    if lhs.consumeAssetTx != rhs.consumeAssetTx {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension AssetProtocol_Certificate: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Certificate"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "from"),
    2: .same(proto: "to"),
    3: .same(proto: "iat"),
    4: .same(proto: "nbf"),
    5: .same(proto: "exp"),
    6: .same(proto: "title"),
    7: .same(proto: "content"),
    8: .same(proto: "sig"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      switch fieldNumber {
      case 1: try decoder.decodeSingularStringField(value: &self.from)
      case 2: try decoder.decodeSingularStringField(value: &self.to)
      case 3: try decoder.decodeSingularUInt64Field(value: &self.iat)
      case 4: try decoder.decodeSingularUInt64Field(value: &self.nbf)
      case 5: try decoder.decodeSingularUInt64Field(value: &self.exp)
      case 6: try decoder.decodeSingularStringField(value: &self.title)
      case 7: try decoder.decodeSingularInt64Field(value: &self.content)
      case 8: try decoder.decodeSingularBytesField(value: &self.sig)
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.from.isEmpty {
      try visitor.visitSingularStringField(value: self.from, fieldNumber: 1)
    }
    if !self.to.isEmpty {
      try visitor.visitSingularStringField(value: self.to, fieldNumber: 2)
    }
    if self.iat != 0 {
      try visitor.visitSingularUInt64Field(value: self.iat, fieldNumber: 3)
    }
    if self.nbf != 0 {
      try visitor.visitSingularUInt64Field(value: self.nbf, fieldNumber: 4)
    }
    if self.exp != 0 {
      try visitor.visitSingularUInt64Field(value: self.exp, fieldNumber: 5)
    }
    if !self.title.isEmpty {
      try visitor.visitSingularStringField(value: self.title, fieldNumber: 6)
    }
    if self.content != 0 {
      try visitor.visitSingularInt64Field(value: self.content, fieldNumber: 7)
    }
    if !self.sig.isEmpty {
      try visitor.visitSingularBytesField(value: self.sig, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: AssetProtocol_Certificate, rhs: AssetProtocol_Certificate) -> Bool {
    if lhs.from != rhs.from {return false}
    if lhs.to != rhs.to {return false}
    if lhs.iat != rhs.iat {return false}
    if lhs.nbf != rhs.nbf {return false}
    if lhs.exp != rhs.exp {return false}
    if lhs.title != rhs.title {return false}
    if lhs.content != rhs.content {return false}
    if lhs.sig != rhs.sig {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
