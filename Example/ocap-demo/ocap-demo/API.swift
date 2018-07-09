//  This file was automatically generated and should not be edited.

import Apollo

/// The common arguments for quering data with pagination.
public struct PageInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(cursor: Optional<String?> = nil, order: Optional<[PageOrder?]?> = nil, size: Optional<Int?> = nil) {
    graphQLMap = ["cursor": cursor, "order": order, "size": size]
  }

  public var cursor: Optional<String?> {
    get {
      return graphQLMap["cursor"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "cursor")
    }
  }

  public var order: Optional<[PageOrder?]?> {
    get {
      return graphQLMap["order"] as! Optional<[PageOrder?]?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var size: Optional<Int?> {
    get {
      return graphQLMap["size"] as! Optional<Int?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

/// When you carry out a query, in most of cases you can provide which field you want to us to order the result. The field to be ordered is vary query by query.
public struct PageOrder: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(field: Optional<String?> = nil, type: Optional<String?> = nil) {
    graphQLMap = ["field": field, "type": type]
  }

  public var field: Optional<String?> {
    get {
      return graphQLMap["field"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "field")
    }
  }

  public var type: Optional<String?> {
    get {
      return graphQLMap["type"] as! Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public final class ListBlocksQuery: GraphQLQuery {
  public static let operationString =
    "query ListBlocks($fromHeight: Int!, $toHeight: Int!, $paging: PageInput) {\n  blocksByHeight(fromHeight: $fromHeight, toHeight: $toHeight, paging: $paging) {\n    __typename\n    data {\n      __typename\n      height\n      hash\n      numberTxs\n      total\n    }\n    page {\n      __typename\n      cursor\n      next\n      total\n    }\n  }\n}"

  public var fromHeight: Int
  public var toHeight: Int
  public var paging: PageInput?

  public init(fromHeight: Int, toHeight: Int, paging: PageInput? = nil) {
    self.fromHeight = fromHeight
    self.toHeight = toHeight
    self.paging = paging
  }

  public var variables: GraphQLMap? {
    return ["fromHeight": fromHeight, "toHeight": toHeight, "paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blocksByHeight", arguments: ["fromHeight": GraphQLVariable("fromHeight"), "toHeight": GraphQLVariable("toHeight"), "paging": GraphQLVariable("paging")], type: .object(BlocksByHeight.selections)),
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
        GraphQLField("page", type: .object(Page.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(data: [Datum?]? = nil, page: Page? = nil) {
        self.init(snapshot: ["__typename": "PagedBitcoinBlocks", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }, "page": page.flatMap { (value: Page) -> Snapshot in value.snapshot }])
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

      public var page: Page? {
        get {
          return (snapshot["page"] as? Snapshot).flatMap { Page(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "page")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes = ["BitcoinBlock"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .nonNull(.scalar(Int.self))),
          GraphQLField("hash", type: .nonNull(.scalar(String.self))),
          GraphQLField("numberTxs", type: .nonNull(.scalar(Int.self))),
          GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(height: Int, hash: String, numberTxs: Int, total: Int) {
          self.init(snapshot: ["__typename": "BitcoinBlock", "height": height, "hash": hash, "numberTxs": numberTxs, "total": total])
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

      public struct Page: GraphQLSelectionSet {
        public static let possibleTypes = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
          GraphQLField("next", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("total", type: .scalar(Int.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(cursor: String, next: Bool, total: Int? = nil) {
          self.init(snapshot: ["__typename": "PageInfo", "cursor": cursor, "next": next, "total": total])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cursor: String {
          get {
            return snapshot["cursor"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "cursor")
          }
        }

        public var next: Bool {
          get {
            return snapshot["next"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "next")
          }
        }

        public var total: Int? {
          get {
            return snapshot["total"] as? Int
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
    "query BlockDetail($height: Int!) {\n  blockByHeight(height: $height) {\n    __typename\n    height\n    hash\n    preHash\n    numberTxs\n    total\n    fees\n    merkleRoot\n    transactions {\n      __typename\n      data {\n        __typename\n        index\n        hash\n        numberInputs\n        numberOutputs\n        size\n        total\n        fees\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

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
        GraphQLField("transactions", type: .object(Transaction.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(height: Int, hash: String, preHash: String, numberTxs: Int, total: Int, fees: Int, merkleRoot: String, transactions: Transaction? = nil) {
        self.init(snapshot: ["__typename": "BitcoinBlock", "height": height, "hash": hash, "preHash": preHash, "numberTxs": numberTxs, "total": total, "fees": fees, "merkleRoot": merkleRoot, "transactions": transactions.flatMap { (value: Transaction) -> Snapshot in value.snapshot }])
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

      public var transactions: Transaction? {
        get {
          return (snapshot["transactions"] as? Snapshot).flatMap { Transaction(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "transactions")
        }
      }

      public struct Transaction: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedBitcoinTransactions"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
          GraphQLField("page", type: .object(Page.selections)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(data: [Datum?]? = nil, page: Page? = nil) {
          self.init(snapshot: ["__typename": "PagedBitcoinTransactions", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }, "page": page.flatMap { (value: Page) -> Snapshot in value.snapshot }])
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

        public var page: Page? {
          get {
            return (snapshot["page"] as? Snapshot).flatMap { Page(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue?.snapshot, forKey: "page")
          }
        }

        public struct Datum: GraphQLSelectionSet {
          public static let possibleTypes = ["BitcoinTransaction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("index", type: .nonNull(.scalar(Int.self))),
            GraphQLField("hash", type: .nonNull(.scalar(String.self))),
            GraphQLField("numberInputs", type: .nonNull(.scalar(Int.self))),
            GraphQLField("numberOutputs", type: .nonNull(.scalar(Int.self))),
            GraphQLField("size", type: .nonNull(.scalar(Int.self))),
            GraphQLField("total", type: .nonNull(.scalar(Int.self))),
            GraphQLField("fees", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(index: Int, hash: String, numberInputs: Int, numberOutputs: Int, size: Int, total: Int, fees: Int) {
            self.init(snapshot: ["__typename": "BitcoinTransaction", "index": index, "hash": hash, "numberInputs": numberInputs, "numberOutputs": numberOutputs, "size": size, "total": total, "fees": fees])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var index: Int {
            get {
              return snapshot["index"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "index")
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

          public var size: Int {
            get {
              return snapshot["size"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "size")
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
        }

        public struct Page: GraphQLSelectionSet {
          public static let possibleTypes = ["PageInfo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("total", type: .scalar(Int.self)),
            GraphQLField("next", type: .nonNull(.scalar(Bool.self))),
            GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(total: Int? = nil, next: Bool, cursor: String) {
            self.init(snapshot: ["__typename": "PageInfo", "total": total, "next": next, "cursor": cursor])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var total: Int? {
            get {
              return snapshot["total"] as? Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "total")
            }
          }

          public var next: Bool {
            get {
              return snapshot["next"]! as! Bool
            }
            set {
              snapshot.updateValue(newValue, forKey: "next")
            }
          }

          public var cursor: String {
            get {
              return snapshot["cursor"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "cursor")
            }
          }
        }
      }
    }
  }
}

public final class TransactionDetailQuery: GraphQLQuery {
  public static let operationString =
    "query TransactionDetail($hash: String!) {\n  transactionByHash(hash: $hash) {\n    __typename\n    fees\n    total\n    numberInputs\n    numberOutputs\n    inputs {\n      __typename\n      data {\n        __typename\n        account\n        value\n      }\n    }\n    outputs {\n      __typename\n      data {\n        __typename\n        account\n        value\n      }\n    }\n  }\n}"

  public var hash: String

  public init(hash: String) {
    self.hash = hash
  }

  public var variables: GraphQLMap? {
    return ["hash": hash]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("transactionByHash", arguments: ["hash": GraphQLVariable("hash")], type: .object(TransactionByHash.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(transactionByHash: TransactionByHash? = nil) {
      self.init(snapshot: ["__typename": "RootQueryType", "transactionByHash": transactionByHash.flatMap { (value: TransactionByHash) -> Snapshot in value.snapshot }])
    }

    /// Returns a transaction by it's hash.
    public var transactionByHash: TransactionByHash? {
      get {
        return (snapshot["transactionByHash"] as? Snapshot).flatMap { TransactionByHash(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "transactionByHash")
      }
    }

    public struct TransactionByHash: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinTransaction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fees", type: .nonNull(.scalar(Int.self))),
        GraphQLField("total", type: .nonNull(.scalar(Int.self))),
        GraphQLField("numberInputs", type: .nonNull(.scalar(Int.self))),
        GraphQLField("numberOutputs", type: .nonNull(.scalar(Int.self))),
        GraphQLField("inputs", type: .object(Input.selections)),
        GraphQLField("outputs", type: .object(Output.selections)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(fees: Int, total: Int, numberInputs: Int, numberOutputs: Int, inputs: Input? = nil, outputs: Output? = nil) {
        self.init(snapshot: ["__typename": "BitcoinTransaction", "fees": fees, "total": total, "numberInputs": numberInputs, "numberOutputs": numberOutputs, "inputs": inputs.flatMap { (value: Input) -> Snapshot in value.snapshot }, "outputs": outputs.flatMap { (value: Output) -> Snapshot in value.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
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

      public var inputs: Input? {
        get {
          return (snapshot["inputs"] as? Snapshot).flatMap { Input(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "inputs")
        }
      }

      public var outputs: Output? {
        get {
          return (snapshot["outputs"] as? Snapshot).flatMap { Output(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "outputs")
        }
      }

      public struct Input: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedTransactionInputs"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(data: [Datum?]? = nil) {
          self.init(snapshot: ["__typename": "PagedTransactionInputs", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }])
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
          public static let possibleTypes = ["TransactionInput"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("account", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(account: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "TransactionInput", "account": account, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var account: String? {
            get {
              return snapshot["account"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "account")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }
      }

      public struct Output: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedTransactionOutputs"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(data: [Datum?]? = nil) {
          self.init(snapshot: ["__typename": "PagedTransactionOutputs", "data": data.flatMap { (value: [Datum?]) -> [Snapshot?] in value.map { (value: Datum?) -> Snapshot? in value.flatMap { (value: Datum) -> Snapshot in value.snapshot } } }])
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
          public static let possibleTypes = ["TransactionOutput"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("account", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(account: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "TransactionOutput", "account": account, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var account: String? {
            get {
              return snapshot["account"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "account")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }
      }
    }
  }
}