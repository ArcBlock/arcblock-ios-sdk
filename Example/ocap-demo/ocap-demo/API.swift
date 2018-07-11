//  This file was automatically generated and should not be edited.

import Apollo

/// The common arguments for quering data with pagination.
public struct PageInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(cursor: Swift.Optional<String?> = nil, order: Swift.Optional<[PageOrder?]?> = nil, size: Swift.Optional<Int?> = nil) {
    graphQLMap = ["cursor": cursor, "order": order, "size": size]
  }

  public var cursor: Swift.Optional<String?> {
    get {
      return graphQLMap["cursor"] as! Swift.Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "cursor")
    }
  }

  public var order: Swift.Optional<[PageOrder?]?> {
    get {
      return graphQLMap["order"] as! Swift.Optional<[PageOrder?]?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "order")
    }
  }

  public var size: Swift.Optional<Int?> {
    get {
      return graphQLMap["size"] as! Swift.Optional<Int?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "size")
    }
  }
}

/// When you carry out a query, in most of cases you can provide which field you want to us to order the result. The field to be ordered is vary query by query.
public struct PageOrder: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(field: Swift.Optional<String?> = nil, type: Swift.Optional<String?> = nil) {
    graphQLMap = ["field": field, "type": type]
  }

  public var field: Swift.Optional<String?> {
    get {
      return graphQLMap["field"] as! Swift.Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "field")
    }
  }

  public var type: Swift.Optional<String?> {
    get {
      return graphQLMap["type"] as! Swift.Optional<String?>
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public final class ListBlocksQuery: GraphQLQuery {
  public let operationDefinition =
    "query ListBlocks($fromHeight: Int!, $toHeight: Int!, $paging: PageInput) {\n  blocksByHeight(fromHeight: $fromHeight, toHeight: $toHeight, paging: $paging) {\n    __typename\n    data {\n      __typename\n      height\n      hash\n      numberTxs\n      total\n      time\n    }\n    page {\n      __typename\n      cursor\n      next\n      total\n    }\n  }\n}"

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

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(blocksByHeight: BlocksByHeight? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "blocksByHeight": blocksByHeight.flatMap { (value: BlocksByHeight) -> ResultMap in value.resultMap }])
    }

    /// Returns blockks with paginations based on their height.
    public var blocksByHeight: BlocksByHeight? {
      get {
        return (resultMap["blocksByHeight"] as? ResultMap).flatMap { BlocksByHeight(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "blocksByHeight")
      }
    }

    public struct BlocksByHeight: GraphQLSelectionSet {
      public static let possibleTypes = ["PagedBitcoinBlocks"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("data", type: .list(.object(Datum.selections))),
        GraphQLField("page", type: .object(Page.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(data: [Datum?]? = nil, page: Page? = nil) {
        self.init(unsafeResultMap: ["__typename": "PagedBitcoinBlocks", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, "page": page.flatMap { (value: Page) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var data: [Datum?]? {
        get {
          return (resultMap["data"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Datum?] in value.map { (value: ResultMap?) -> Datum? in value.flatMap { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, forKey: "data")
        }
      }

      public var page: Page? {
        get {
          return (resultMap["page"] as? ResultMap).flatMap { Page(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "page")
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
          GraphQLField("time", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int, hash: String, numberTxs: Int, total: Int, time: String) {
          self.init(unsafeResultMap: ["__typename": "BitcoinBlock", "height": height, "hash": hash, "numberTxs": numberTxs, "total": total, "time": time])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var height: Int {
          get {
            return resultMap["height"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "height")
          }
        }

        public var hash: String {
          get {
            return resultMap["hash"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "hash")
          }
        }

        public var numberTxs: Int {
          get {
            return resultMap["numberTxs"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "numberTxs")
          }
        }

        public var total: Int {
          get {
            return resultMap["total"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }

        public var time: String {
          get {
            return resultMap["time"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "time")
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

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(cursor: String, next: Bool, total: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "cursor": cursor, "next": next, "total": total])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var cursor: String {
          get {
            return resultMap["cursor"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "cursor")
          }
        }

        public var next: Bool {
          get {
            return resultMap["next"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "next")
          }
        }

        public var total: Int? {
          get {
            return resultMap["total"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "total")
          }
        }
      }
    }
  }
}

public final class BlockDetailQuery: GraphQLQuery {
  public let operationDefinition =
    "query BlockDetail($height: Int!) {\n  blockByHeight(height: $height) {\n    __typename\n    height\n    hash\n    preHash\n    numberTxs\n    total\n    fees\n    merkleRoot\n    time\n    transactions {\n      __typename\n      data {\n        __typename\n        hash\n        lockTime\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

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

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(blockByHeight: BlockByHeight? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "blockByHeight": blockByHeight.flatMap { (value: BlockByHeight) -> ResultMap in value.resultMap }])
    }

    /// Returns a block by it's height.
    public var blockByHeight: BlockByHeight? {
      get {
        return (resultMap["blockByHeight"] as? ResultMap).flatMap { BlockByHeight(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "blockByHeight")
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
        GraphQLField("time", type: .nonNull(.scalar(String.self))),
        GraphQLField("transactions", type: .object(Transaction.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(height: Int, hash: String, preHash: String, numberTxs: Int, total: Int, fees: Int, merkleRoot: String, time: String, transactions: Transaction? = nil) {
        self.init(unsafeResultMap: ["__typename": "BitcoinBlock", "height": height, "hash": hash, "preHash": preHash, "numberTxs": numberTxs, "total": total, "fees": fees, "merkleRoot": merkleRoot, "time": time, "transactions": transactions.flatMap { (value: Transaction) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var height: Int {
        get {
          return resultMap["height"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "height")
        }
      }

      public var hash: String {
        get {
          return resultMap["hash"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "hash")
        }
      }

      public var preHash: String {
        get {
          return resultMap["preHash"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "preHash")
        }
      }

      public var numberTxs: Int {
        get {
          return resultMap["numberTxs"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "numberTxs")
        }
      }

      public var total: Int {
        get {
          return resultMap["total"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "total")
        }
      }

      public var fees: Int {
        get {
          return resultMap["fees"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fees")
        }
      }

      public var merkleRoot: String {
        get {
          return resultMap["merkleRoot"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "merkleRoot")
        }
      }

      public var time: String {
        get {
          return resultMap["time"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "time")
        }
      }

      public var transactions: Transaction? {
        get {
          return (resultMap["transactions"] as? ResultMap).flatMap { Transaction(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "transactions")
        }
      }

      public struct Transaction: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedBitcoinTransactions"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
          GraphQLField("page", type: .object(Page.selections)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(data: [Datum?]? = nil, page: Page? = nil) {
          self.init(unsafeResultMap: ["__typename": "PagedBitcoinTransactions", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, "page": page.flatMap { (value: Page) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var data: [Datum?]? {
          get {
            return (resultMap["data"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Datum?] in value.map { (value: ResultMap?) -> Datum? in value.flatMap { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, forKey: "data")
          }
        }

        public var page: Page? {
          get {
            return (resultMap["page"] as? ResultMap).flatMap { Page(unsafeResultMap: $0) }
          }
          set {
            resultMap.updateValue(newValue?.resultMap, forKey: "page")
          }
        }

        public struct Datum: GraphQLSelectionSet {
          public static let possibleTypes = ["BitcoinTransaction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("hash", type: .nonNull(.scalar(String.self))),
            GraphQLField("lockTime", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hash: String, lockTime: Int) {
            self.init(unsafeResultMap: ["__typename": "BitcoinTransaction", "hash": hash, "lockTime": lockTime])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var hash: String {
            get {
              return resultMap["hash"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "hash")
            }
          }

          public var lockTime: Int {
            get {
              return resultMap["lockTime"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "lockTime")
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

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(total: Int? = nil, next: Bool, cursor: String) {
            self.init(unsafeResultMap: ["__typename": "PageInfo", "total": total, "next": next, "cursor": cursor])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var total: Int? {
            get {
              return resultMap["total"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "total")
            }
          }

          public var next: Bool {
            get {
              return resultMap["next"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "next")
            }
          }

          public var cursor: String {
            get {
              return resultMap["cursor"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "cursor")
            }
          }
        }
      }
    }
  }
}

public final class TransactionDetailQuery: GraphQLQuery {
  public let operationDefinition =
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

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(transactionByHash: TransactionByHash? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "transactionByHash": transactionByHash.flatMap { (value: TransactionByHash) -> ResultMap in value.resultMap }])
    }

    /// Returns a transaction by it's hash.
    public var transactionByHash: TransactionByHash? {
      get {
        return (resultMap["transactionByHash"] as? ResultMap).flatMap { TransactionByHash(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "transactionByHash")
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

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fees: Int, total: Int, numberInputs: Int, numberOutputs: Int, inputs: Input? = nil, outputs: Output? = nil) {
        self.init(unsafeResultMap: ["__typename": "BitcoinTransaction", "fees": fees, "total": total, "numberInputs": numberInputs, "numberOutputs": numberOutputs, "inputs": inputs.flatMap { (value: Input) -> ResultMap in value.resultMap }, "outputs": outputs.flatMap { (value: Output) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fees: Int {
        get {
          return resultMap["fees"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "fees")
        }
      }

      public var total: Int {
        get {
          return resultMap["total"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "total")
        }
      }

      public var numberInputs: Int {
        get {
          return resultMap["numberInputs"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "numberInputs")
        }
      }

      public var numberOutputs: Int {
        get {
          return resultMap["numberOutputs"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "numberOutputs")
        }
      }

      public var inputs: Input? {
        get {
          return (resultMap["inputs"] as? ResultMap).flatMap { Input(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "inputs")
        }
      }

      public var outputs: Output? {
        get {
          return (resultMap["outputs"] as? ResultMap).flatMap { Output(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "outputs")
        }
      }

      public struct Input: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedTransactionInputs"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(data: [Datum?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "PagedTransactionInputs", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var data: [Datum?]? {
          get {
            return (resultMap["data"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Datum?] in value.map { (value: ResultMap?) -> Datum? in value.flatMap { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, forKey: "data")
          }
        }

        public struct Datum: GraphQLSelectionSet {
          public static let possibleTypes = ["TransactionInput"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("account", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(account: String? = nil, value: Int) {
            self.init(unsafeResultMap: ["__typename": "TransactionInput", "account": account, "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var account: String? {
            get {
              return resultMap["account"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "account")
            }
          }

          public var value: Int {
            get {
              return resultMap["value"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
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

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(data: [Datum?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "PagedTransactionOutputs", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var data: [Datum?]? {
          get {
            return (resultMap["data"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Datum?] in value.map { (value: ResultMap?) -> Datum? in value.flatMap { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, forKey: "data")
          }
        }

        public struct Datum: GraphQLSelectionSet {
          public static let possibleTypes = ["TransactionOutput"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("account", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(account: String? = nil, value: Int) {
            self.init(unsafeResultMap: ["__typename": "TransactionOutput", "account": account, "value": value])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var account: String? {
            get {
              return resultMap["account"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "account")
            }
          }

          public var value: Int {
            get {
              return resultMap["value"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }
        }
      }
    }
  }
}