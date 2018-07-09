//  This file was automatically generated and should not be edited.

import Apollo

public final class ListBlocksQuery: GraphQLQuery {
  public static let operationString =
    "query ListBlocks($fromHeight: Int!) {\n  blocksByHeight(fromHeight: $fromHeight) {\n    __typename\n    data {\n      __typename\n      height\n      numberTxs\n      total\n    }\n  }\n}"

  public var fromHeight: Int

  public init(fromHeight: Int) {
    self.fromHeight = fromHeight
  }

  public var variables: GraphQLMap? {
    return ["fromHeight": fromHeight]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blocksByHeight", arguments: ["fromHeight": GraphQLVariable("fromHeight")], type: .object(BlocksByHeight.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(blocksByHeight: BlocksByHeight? = nil) {
      self.init(snapshot: ["__typename": "RootQueryType", "blocksByHeight": blocksByHeight.flatMap { (value: BlocksByHeight) -> Snapshot in value.snapshot }])
    }

    /// Returns blockks with paginations based on their height.
    public var blocksByHeight: BlocksByHeight? {
      get {
        return (snapshot["blocksByHeight"] as? Snapshot).flatMap { BlocksByHeight(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "blocksByHeight")
      }
    }

    public struct BlocksByHeight: GraphQLSelectionSet {
      public static let possibleTypes = ["PagedBitcoinBlocks"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .list(.object(Datum.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: [Datum?]? = nil) {
        self.init(snapshot: ["__typename": "PagedBitcoinBlocks", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: [Datum?]? {
        get {
          return (snapshot["data"] as? [Snapshot?]).flatMap { (value: [Snapshot?]) -> [Datum?] in value.map { (value: Snapshot?) -> Datum? in value.flatMap { (value: Snapshot) -> Datum in Datum(snapshot: value) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }, forKey: "data")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["BitcoinBlock"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .nonNull(.scalar(Int.self))),
          GraphQLField("numberTxs", type: .nonNull(.scalar(Int.self))),
          GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(height: Int, numberTxs: Int, total: Int) {
          self.init(snapshot: ["__typename": "BitcoinBlock", "height": height, "numberTxs": numberTxs, "total": total])
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

        public var numberTxs: Int {
          get {
            return snapshot["numberTxs"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "numberTxs")
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
      }
    }
  }
}

public final class BlockDetailQuery: GraphQLQuery {
  public static let operationString =
    "query BlockDetail($height: Int!) {\n  blockByHeight(height: $height) {\n    __typename\n    height\n    hash\n    preHash\n    numberTxs\n    total\n    fees\n    merkleRoot\n  }\n}"

  public var height: Int

  public init(height: Int) {
    self.height = height
  }

  public var variables: GraphQLMap? {
    return ["height": height]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blockByHeight", arguments: ["height": GraphQLVariable("height")], type: .object(BlockByHeight.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(blockByHeight: BlockByHeight? = nil) {
      self.init(snapshot: ["__typename": "RootQueryType", "blockByHeight": blockByHeight.flatMap { (value: BlockByHeight) -> Snapshot in value.snapshot }])
    }

    /// Returns a block by it's height.
    public var blockByHeight: BlockByHeight? {
      get {
        return (snapshot["blockByHeight"] as? Snapshot).flatMap { BlockByHeight(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "blockByHeight")
      }
    }

    public struct BlockByHeight: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinBlock"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .nonNull(.scalar(Int.self))),
        GraphQLField("hash", type: .nonNull(.scalar(String.self))),
        GraphQLField("preHash", type: .nonNull(.scalar(String.self))),
        GraphQLField("numberTxs", type: .nonNull(.scalar(Int.self))),
        GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        GraphQLField("fees", type: .nonNull(.scalar(Int.self))),
        GraphQLField("merkleRoot", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(height: Int, hash: String, preHash: String, numberTxs: Int, total: Int, fees: Int, merkleRoot: String) {
        self.init(snapshot: ["__typename": "BitcoinBlock", "height": height, "hash": hash, "preHash": preHash, "numberTxs": numberTxs, "total": total, "fees": fees, "merkleRoot": merkleRoot])
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

      public var hash: String {
        get {
          return snapshot["hash"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "hash")
        }
      }

      public var preHash: String {
        get {
          return snapshot["preHash"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "preHash")
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

      public var total: Int {
        get {
          return snapshot["total"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "total")
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

      public var merkleRoot: String {
        get {
          return snapshot["merkleRoot"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "merkleRoot")
        }
      }
    }
  }
}