//  This file was automatically generated and should not be edited.

import Apollo

public final class ListBlocksQuery: GraphQLQuery {
  public static let operationString =
    "query ListBlocks($fromHeight: Int!) {\n  blocksByHeight(fromHeight: $fromHeight) {\n    data {\n      hash\n      numberTxs\n      total\n    }\n  }\n}"

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
        GraphQLField("data", type: .list(.object(Datum.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: [Datum?]? = nil) {
        self.init(snapshot: ["__typename": "PagedBitcoinBlocks", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }])
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
          GraphQLField("hash", type: .nonNull(.scalar(String.self))),
          GraphQLField("numberTxs", type: .nonNull(.scalar(Int.self))),
          GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(hash: String, numberTxs: Int, total: Int) {
          self.init(snapshot: ["__typename": "BitcoinBlock", "hash": hash, "numberTxs": numberTxs, "total": total])
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