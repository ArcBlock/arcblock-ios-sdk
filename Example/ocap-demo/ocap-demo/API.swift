//  This file was automatically generated and should not be edited.

import Apollo

public final class ListBlocksQuery: GraphQLQuery {
  public static let operationString =
    "query ListBlocks {\n  blocks {\n    __typename\n    hash\n    numberTxs\n    total\n  }\n}"

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

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
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

public final class ListTransactionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListTransactions {\n  transactions {\n    __typename\n    hash\n    total\n    numberInputs\n    numberOutputs\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("transactions", type: .list(.object(Transaction.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(transactions: [Transaction?]? = nil) {
      self.init(snapshot: ["__typename": "RootQueryType", "transactions": transactions.flatMap { (value: [Transaction?]) -> [Snapshot?] in value.map { (value: Transaction?) -> Snapshot? in value.flatMap { (value: Transaction) -> Snapshot in value.snapshot } } }])
    }

    /// Get all transactions
    public var transactions: [Transaction?]? {
      get {
        return (snapshot["transactions"] as? [Snapshot?]).flatMap { (value: [Snapshot?]) -> [Transaction?] in value.map { (value: Snapshot?) -> Transaction? in value.flatMap { (value: Snapshot) -> Transaction in Transaction(snapshot: value) } } }
      }
      set {
        snapshot.updateValue(newValue.flatMap { (value: [Transaction?]) -> [Snapshot?] in value.map { (value: Transaction?) -> Snapshot? in value.flatMap { (value: Transaction) -> Snapshot in value.snapshot } } }, forKey: "transactions")
      }
    }

    public struct Transaction: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinTransaction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("hash", type: .nonNull(.scalar(String.self))),
        GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        GraphQLField("numberInputs", type: .nonNull(.scalar(Int.self))),
        GraphQLField("numberOutputs", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(hash: String, total: Int, numberInputs: Int, numberOutputs: Int) {
        self.init(snapshot: ["__typename": "BitcoinTransaction", "hash": hash, "total": total, "numberInputs": numberInputs, "numberOutputs": numberOutputs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
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

      public var total: Int {
        get {
          return snapshot["total"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "total")
        }
      }

      public var numberInputs: Int {
        get {
          return snapshot["numberInputs"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "numberInputs")
        }
      }

      public var numberOutputs: Int {
        get {
          return snapshot["numberOutputs"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "numberOutputs")
        }
      }
    }
  }
}