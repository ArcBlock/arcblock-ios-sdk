//  This file was automatically generated and should not be edited.

import Apollo

public final class ListBlocksQuery: GraphQLQuery {
  public static let operationString =
    "query ListBlocks {\n  blocks {\n    __typename\n    height\n    fees\n    total\n    hash\n    numberTxs\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blocks", type: .list(.object(Block.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(blocks: [Block?]? = nil) {
      self.init(snapshot: ["__typename": "RootQueryType", "blocks": blocks.flatMap { (value: [Block?]) -> [Snapshot?] in value.map { (value: Block?) -> Snapshot? in value.flatMap { (value: Block) -> Snapshot in value.snapshot } } }])
    }

    /// Get all blocks
    public var blocks: [Block?]? {
      get {
        return (snapshot["blocks"] as? [Snapshot?]).flatMap { (value: [Snapshot?]) -> [Block?] in value.map { (value: Snapshot?) -> Block? in value.flatMap { (value: Snapshot) -> Block in Block(snapshot: value) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { (value: [Block?]) -> [Snapshot?] in value.map { (value: Block?) -> Snapshot? in value.flatMap { (value: Block) -> Snapshot in value.snapshot } } }, forKey: "blocks")
      }
    }

    public struct Block: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinBlock"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .nonNull(.scalar(Int.self))),
        GraphQLField("fees", type: .nonNull(.scalar(Int.self))),
        GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        GraphQLField("hash", type: .nonNull(.scalar(String.self))),
        GraphQLField("numberTxs", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(height: Int, fees: Int, total: Int, hash: String, numberTxs: Int) {
        self.init(snapshot: ["__typename": "BitcoinBlock", "height": height, "fees": fees, "total": total, "hash": hash, "numberTxs": numberTxs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var height: Int {
        get {
          return snapshot["height"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "height")
        }
      }

      public var fees: Int {
        get {
          return snapshot["fees"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "fees")
        }
      }

      public var total: Int {
        get {
          return snapshot["total"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "total")
        }
      }

      public var hash: String {
        get {
          return snapshot["hash"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hash")
        }
      }

      public var numberTxs: Int {
        get {
          return snapshot["numberTxs"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "numberTxs")
        }
      }
    }
  }
}