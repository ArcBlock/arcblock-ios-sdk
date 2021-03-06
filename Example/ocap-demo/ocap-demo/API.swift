//  This file was automatically generated and should not be edited.

import Apollo
import ArcBlockSDK

public final class ListBtcBlocksQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query ListBTCBlocks($fromHeight: Int!, $paging: PageInput) {\n  blocksByHeight(fromHeight: $fromHeight, paging: $paging) {\n    __typename\n    data {\n      __typename\n      height\n      hash\n      numberTxs\n      total\n      time\n    }\n    page {\n      __typename\n      cursor\n      next\n      total\n    }\n  }\n}"

  public var fromHeight: Int
  public var paging: PageInput?

  public init(fromHeight: Int, paging: PageInput? = nil) {
    self.fromHeight = fromHeight
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(fromHeight: fromHeight, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["fromHeight": fromHeight, "paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blocksByHeight", arguments: ["fromHeight": GraphQLVariable("fromHeight"), "paging": GraphQLVariable("paging")], type: .object(BlocksByHeight.selections)),
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

    public struct BlocksByHeight: PagedData {
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
          GraphQLField("time", type: .nonNull(.scalar(DateTime.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int, hash: String, numberTxs: Int, total: Int, time: DateTime) {
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

        public var time: DateTime {
          get {
            return resultMap["time"]! as! DateTime
          }
          set {
            resultMap.updateValue(newValue, forKey: "time")
          }
        }
      }
    }
  }
}

public final class BtcBlockDetailQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query BTCBlockDetail($height: Int!, $paging: PageInput) {\n  blockByHeight(height: $height) {\n    __typename\n    height\n    hash\n    preHash\n    numberTxs\n    total\n    fees\n    merkleRoot\n    time\n    transactions(paging: $paging) {\n      __typename\n      data {\n        __typename\n        hash\n        lockTime\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

  public var height: Int
  public var paging: PageInput?

  public init(height: Int, paging: PageInput? = nil) {
    self.height = height
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(height: height, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["height": height, "paging": paging]
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
        GraphQLField("time", type: .nonNull(.scalar(DateTime.self))),
        GraphQLField("transactions", arguments: ["paging": GraphQLVariable("paging")], type: .object(Transaction.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(height: Int, hash: String, preHash: String, numberTxs: Int, total: Int, fees: Int, merkleRoot: String, time: DateTime, transactions: Transaction? = nil) {
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

      public var time: DateTime {
        get {
          return resultMap["time"]! as! DateTime
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

      public struct Transaction: PagedData {
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
      }
    }
  }
}

public final class BtcTransactionDetailQuery: GraphQLQuery {
  public let operationDefinition =
    "query BTCTransactionDetail($hash: String!) {\n  transactionByHash(hash: $hash) {\n    __typename\n    fees\n    total\n    numberInputs\n    numberOutputs\n    inputs {\n      __typename\n      data {\n        __typename\n        account\n        value\n      }\n    }\n    outputs {\n      __typename\n      data {\n        __typename\n        account\n        value\n      }\n    }\n  }\n}"

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

public final class BtcRichestAccountsQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query BTCRichestAccounts($paging: PageInput) {\n  richestAccounts(paging: $paging) {\n    __typename\n    data {\n      __typename\n      address\n      balance\n    }\n    page {\n      __typename\n      total\n      next\n      cursor\n    }\n  }\n}"

  public var paging: PageInput?

  public init(paging: PageInput? = nil) {
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("richestAccounts", arguments: ["paging": GraphQLVariable("paging")], type: .object(RichestAccount.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(richestAccounts: RichestAccount? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "richestAccounts": richestAccounts.flatMap { (value: RichestAccount) -> ResultMap in value.resultMap }])
    }

    /// Returns richest accounts, order by balance.
    public var richestAccounts: RichestAccount? {
      get {
        return (resultMap["richestAccounts"] as? ResultMap).flatMap { RichestAccount(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "richestAccounts")
      }
    }

    public struct RichestAccount: PagedData {
      public static let possibleTypes = ["PagedBitcoinAccounts"]

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
        self.init(unsafeResultMap: ["__typename": "PagedBitcoinAccounts", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, "page": page.flatMap { (value: Page) -> ResultMap in value.resultMap }])
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
        public static let possibleTypes = ["BitcoinAccount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
          GraphQLField("balance", type: .scalar(Int.self)),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(address: String, balance: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "BitcoinAccount", "address": address, "balance": balance])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var address: String {
          get {
            return resultMap["address"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "address")
          }
        }

        public var balance: Int? {
          get {
            return resultMap["balance"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "balance")
          }
        }
      }
    }
  }
}

public final class BtcAccountByAddressQuery: GraphQLQuery {
  public let operationDefinition =
    "query BTCAccountByAddress($address: String!) {\n  accountByAddress(address: $address) {\n    __typename\n    pubKey\n    scriptType\n  }\n}"

  public var address: String

  public init(address: String) {
    self.address = address
  }

  public var variables: GraphQLMap? {
    return ["address": address]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("accountByAddress", arguments: ["address": GraphQLVariable("address")], type: .object(AccountByAddress.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(accountByAddress: AccountByAddress? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "accountByAddress": accountByAddress.flatMap { (value: AccountByAddress) -> ResultMap in value.resultMap }])
    }

    /// Returns information of an account.
    public var accountByAddress: AccountByAddress? {
      get {
        return (resultMap["accountByAddress"] as? ResultMap).flatMap { AccountByAddress(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "accountByAddress")
      }
    }

    public struct AccountByAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinAccount"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("pubKey", type: .scalar(String.self)),
        GraphQLField("scriptType", type: .scalar(String.self)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(pubKey: String? = nil, scriptType: String? = nil) {
        self.init(unsafeResultMap: ["__typename": "BitcoinAccount", "pubKey": pubKey, "scriptType": scriptType])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var pubKey: String? {
        get {
          return resultMap["pubKey"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "pubKey")
        }
      }

      public var scriptType: String? {
        get {
          return resultMap["scriptType"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "scriptType")
        }
      }
    }
  }
}

public final class BtcTxsReceivedByAccountQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query BTCTxsReceivedByAccount($address: String!, $paging: PageInput) {\n  accountByAddress(address: $address) {\n    __typename\n    txsReceived(paging: $paging) {\n      __typename\n      data {\n        __typename\n        hash\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

  public var address: String
  public var paging: PageInput?

  public init(address: String, paging: PageInput? = nil) {
    self.address = address
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(address: address, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["address": address, "paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("accountByAddress", arguments: ["address": GraphQLVariable("address")], type: .object(AccountByAddress.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(accountByAddress: AccountByAddress? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "accountByAddress": accountByAddress.flatMap { (value: AccountByAddress) -> ResultMap in value.resultMap }])
    }

    /// Returns information of an account.
    public var accountByAddress: AccountByAddress? {
      get {
        return (resultMap["accountByAddress"] as? ResultMap).flatMap { AccountByAddress(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "accountByAddress")
      }
    }

    public struct AccountByAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinAccount"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("txsReceived", arguments: ["paging": GraphQLVariable("paging")], type: .object(TxsReceived.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(txsReceived: TxsReceived? = nil) {
        self.init(unsafeResultMap: ["__typename": "BitcoinAccount", "txsReceived": txsReceived.flatMap { (value: TxsReceived) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var txsReceived: TxsReceived? {
        get {
          return (resultMap["txsReceived"] as? ResultMap).flatMap { TxsReceived(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "txsReceived")
        }
      }

      public struct TxsReceived: PagedData {
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
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hash: String) {
            self.init(unsafeResultMap: ["__typename": "BitcoinTransaction", "hash": hash])
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
        }
      }
    }
  }
}

public final class BtcTxsSentByAccountQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query BTCTxsSentByAccount($address: String!, $paging: PageInput) {\n  accountByAddress(address: $address) {\n    __typename\n    txsSent(paging: $paging) {\n      __typename\n      data {\n        __typename\n        hash\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

  public var address: String
  public var paging: PageInput?

  public init(address: String, paging: PageInput? = nil) {
    self.address = address
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(address: address, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["address": address, "paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("accountByAddress", arguments: ["address": GraphQLVariable("address")], type: .object(AccountByAddress.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(accountByAddress: AccountByAddress? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "accountByAddress": accountByAddress.flatMap { (value: AccountByAddress) -> ResultMap in value.resultMap }])
    }

    /// Returns information of an account.
    public var accountByAddress: AccountByAddress? {
      get {
        return (resultMap["accountByAddress"] as? ResultMap).flatMap { AccountByAddress(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "accountByAddress")
      }
    }

    public struct AccountByAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["BitcoinAccount"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("txsSent", arguments: ["paging": GraphQLVariable("paging")], type: .object(TxsSent.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(txsSent: TxsSent? = nil) {
        self.init(unsafeResultMap: ["__typename": "BitcoinAccount", "txsSent": txsSent.flatMap { (value: TxsSent) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var txsSent: TxsSent? {
        get {
          return (resultMap["txsSent"] as? ResultMap).flatMap { TxsSent(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "txsSent")
        }
      }

      public struct TxsSent: PagedData {
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
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hash: String) {
            self.init(unsafeResultMap: ["__typename": "BitcoinTransaction", "hash": hash])
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
        }
      }
    }
  }
}

public final class ListEthBlocksQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query ListETHBlocks($fromHeight: Int!, $paging: PageInput) {\n  blocksByHeight(fromHeight: $fromHeight, paging: $paging) {\n    __typename\n    data {\n      __typename\n      height\n      hash\n      time\n    }\n    page {\n      __typename\n      cursor\n      next\n      total\n    }\n  }\n}"

  public var fromHeight: Int
  public var paging: PageInput?

  public init(fromHeight: Int, paging: PageInput? = nil) {
    self.fromHeight = fromHeight
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(fromHeight: fromHeight, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["fromHeight": fromHeight, "paging": paging]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("blocksByHeight", arguments: ["fromHeight": GraphQLVariable("fromHeight"), "paging": GraphQLVariable("paging")], type: .object(BlocksByHeight.selections)),
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

    public struct BlocksByHeight: PagedData {
      public static let possibleTypes = ["PagedEthereumBlocks"]

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
        self.init(unsafeResultMap: ["__typename": "PagedEthereumBlocks", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, "page": page.flatMap { (value: Page) -> ResultMap in value.resultMap }])
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
        public static let possibleTypes = ["EthereumBlock"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .nonNull(.scalar(Int.self))),
          GraphQLField("hash", type: .nonNull(.scalar(String.self))),
          GraphQLField("time", type: .nonNull(.scalar(DateTime.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int, hash: String, time: DateTime) {
          self.init(unsafeResultMap: ["__typename": "EthereumBlock", "height": height, "hash": hash, "time": time])
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

        public var time: DateTime {
          get {
            return resultMap["time"]! as! DateTime
          }
          set {
            resultMap.updateValue(newValue, forKey: "time")
          }
        }
      }
    }
  }
}

public final class EthBlockDetailQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query ETHBlockDetail($height: Int!, $paging: PageInput) {\n  blockByHeight(height: $height) {\n    __typename\n    height\n    hash\n    preHash\n    fees\n    time\n    transactions(paging: $paging) {\n      __typename\n      data {\n        __typename\n        hash\n      }\n      page {\n        __typename\n        total\n        next\n        cursor\n      }\n    }\n  }\n}"

  public var height: Int
  public var paging: PageInput?

  public init(height: Int, paging: PageInput? = nil) {
    self.height = height
    self.paging = paging
  }

  public func copy() -> Self {
    return type(of: self).init(height: height, paging: paging)
  }

  public var variables: GraphQLMap? {
    return ["height": height, "paging": paging]
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
      public static let possibleTypes = ["EthereumBlock"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .nonNull(.scalar(Int.self))),
        GraphQLField("hash", type: .nonNull(.scalar(String.self))),
        GraphQLField("preHash", type: .nonNull(.scalar(String.self))),
        GraphQLField("fees", type: .nonNull(.scalar(BigNumber.self))),
        GraphQLField("time", type: .nonNull(.scalar(DateTime.self))),
        GraphQLField("transactions", arguments: ["paging": GraphQLVariable("paging")], type: .object(Transaction.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(height: Int, hash: String, preHash: String, fees: BigNumber, time: DateTime, transactions: Transaction? = nil) {
        self.init(unsafeResultMap: ["__typename": "EthereumBlock", "height": height, "hash": hash, "preHash": preHash, "fees": fees, "time": time, "transactions": transactions.flatMap { (value: Transaction) -> ResultMap in value.resultMap }])
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

      public var fees: BigNumber {
        get {
          return resultMap["fees"]! as! BigNumber
        }
        set {
          resultMap.updateValue(newValue, forKey: "fees")
        }
      }

      public var time: DateTime {
        get {
          return resultMap["time"]! as! DateTime
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

      public struct Transaction: PagedData {
        public static let possibleTypes = ["PagedEthereumTransactions"]

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
          self.init(unsafeResultMap: ["__typename": "PagedEthereumTransactions", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }, "page": page.flatMap { (value: Page) -> ResultMap in value.resultMap }])
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
          public static let possibleTypes = ["EthereumTransaction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("hash", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hash: String) {
            self.init(unsafeResultMap: ["__typename": "EthereumTransaction", "hash": hash])
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
        }
      }
    }
  }
}

public final class EthTransactionDetailQuery: GraphQLQuery {
  public let operationDefinition =
    "query ETHTransactionDetail($hash: String!) {\n  transactionByHash(hash: $hash) {\n    __typename\n    fees\n    total\n    from {\n      __typename\n      address\n      balance\n      isContract\n    }\n    to {\n      __typename\n      address\n      balance\n      isContract\n    }\n    traces {\n      __typename\n      data {\n        __typename\n        actionFunctionInput\n      }\n    }\n  }\n}"

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
      public static let possibleTypes = ["EthereumTransaction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fees", type: .nonNull(.scalar(BigNumber.self))),
        GraphQLField("total", type: .nonNull(.scalar(BigNumber.self))),
        GraphQLField("from", type: .nonNull(.object(From.selections))),
        GraphQLField("to", type: .object(To.selections)),
        GraphQLField("traces", type: .object(Trace.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fees: BigNumber, total: BigNumber, from: From, to: To? = nil, traces: Trace? = nil) {
        self.init(unsafeResultMap: ["__typename": "EthereumTransaction", "fees": fees, "total": total, "from": from.resultMap, "to": to.flatMap { (value: To) -> ResultMap in value.resultMap }, "traces": traces.flatMap { (value: Trace) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fees: BigNumber {
        get {
          return resultMap["fees"]! as! BigNumber
        }
        set {
          resultMap.updateValue(newValue, forKey: "fees")
        }
      }

      public var total: BigNumber {
        get {
          return resultMap["total"]! as! BigNumber
        }
        set {
          resultMap.updateValue(newValue, forKey: "total")
        }
      }

      public var from: From {
        get {
          return From(unsafeResultMap: resultMap["from"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "from")
        }
      }

      public var to: To? {
        get {
          return (resultMap["to"] as? ResultMap).flatMap { To(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "to")
        }
      }

      public var traces: Trace? {
        get {
          return (resultMap["traces"] as? ResultMap).flatMap { Trace(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "traces")
        }
      }

      public struct From: GraphQLSelectionSet {
        public static let possibleTypes = ["EthereumAccount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
          GraphQLField("balance", type: .scalar(BigNumber.self)),
          GraphQLField("isContract", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(address: String, balance: BigNumber? = nil, isContract: Bool) {
          self.init(unsafeResultMap: ["__typename": "EthereumAccount", "address": address, "balance": balance, "isContract": isContract])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var address: String {
          get {
            return resultMap["address"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "address")
          }
        }

        public var balance: BigNumber? {
          get {
            return resultMap["balance"] as? BigNumber
          }
          set {
            resultMap.updateValue(newValue, forKey: "balance")
          }
        }

        public var isContract: Bool {
          get {
            return resultMap["isContract"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isContract")
          }
        }
      }

      public struct To: GraphQLSelectionSet {
        public static let possibleTypes = ["EthereumAccount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
          GraphQLField("balance", type: .scalar(BigNumber.self)),
          GraphQLField("isContract", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(address: String, balance: BigNumber? = nil, isContract: Bool) {
          self.init(unsafeResultMap: ["__typename": "EthereumAccount", "address": address, "balance": balance, "isContract": isContract])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var address: String {
          get {
            return resultMap["address"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "address")
          }
        }

        public var balance: BigNumber? {
          get {
            return resultMap["balance"] as? BigNumber
          }
          set {
            resultMap.updateValue(newValue, forKey: "balance")
          }
        }

        public var isContract: Bool {
          get {
            return resultMap["isContract"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "isContract")
          }
        }
      }

      public struct Trace: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedEthereumTraces"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(data: [Datum?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "PagedEthereumTraces", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }])
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
          public static let possibleTypes = ["EthereumTrace"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("actionFunctionInput", type: .list(.scalar(FunctionInput.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(actionFunctionInput: [FunctionInput?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "EthereumTrace", "actionFunctionInput": actionFunctionInput])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var actionFunctionInput: [FunctionInput?]? {
            get {
              return resultMap["actionFunctionInput"] as? [FunctionInput?]
            }
            set {
              resultMap.updateValue(newValue, forKey: "actionFunctionInput")
            }
          }
        }
      }
    }
  }
}

public final class NewEthBlockMinedSubscription: GraphQLSubscription {
  public let operationDefinition =
    "subscription newETHBlockMined {\n  newBlockMined {\n    __typename\n    fees\n    hash\n    height\n    miner {\n      __typename\n      address\n    }\n    reward\n    size\n    time\n    transactions {\n      __typename\n      data {\n        __typename\n        hash\n      }\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["RootSubscriptionType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("newBlockMined", type: .object(NewBlockMined.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(newBlockMined: NewBlockMined? = nil) {
      self.init(unsafeResultMap: ["__typename": "RootSubscriptionType", "newBlockMined": newBlockMined.flatMap { (value: NewBlockMined) -> ResultMap in value.resultMap }])
    }

    /// Returns block data once a new block is mined
    public var newBlockMined: NewBlockMined? {
      get {
        return (resultMap["newBlockMined"] as? ResultMap).flatMap { NewBlockMined(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "newBlockMined")
      }
    }

    public struct NewBlockMined: GraphQLSelectionSet {
      public static let possibleTypes = ["EthereumBlock"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("fees", type: .nonNull(.scalar(BigNumber.self))),
        GraphQLField("hash", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .nonNull(.scalar(Int.self))),
        GraphQLField("miner", type: .nonNull(.object(Miner.selections))),
        GraphQLField("reward", type: .nonNull(.scalar(BigNumber.self))),
        GraphQLField("size", type: .nonNull(.scalar(Int.self))),
        GraphQLField("time", type: .nonNull(.scalar(DateTime.self))),
        GraphQLField("transactions", type: .object(Transaction.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(fees: BigNumber, hash: String, height: Int, miner: Miner, reward: BigNumber, size: Int, time: DateTime, transactions: Transaction? = nil) {
        self.init(unsafeResultMap: ["__typename": "EthereumBlock", "fees": fees, "hash": hash, "height": height, "miner": miner.resultMap, "reward": reward, "size": size, "time": time, "transactions": transactions.flatMap { (value: Transaction) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var fees: BigNumber {
        get {
          return resultMap["fees"]! as! BigNumber
        }
        set {
          resultMap.updateValue(newValue, forKey: "fees")
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

      public var height: Int {
        get {
          return resultMap["height"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "height")
        }
      }

      public var miner: Miner {
        get {
          return Miner(unsafeResultMap: resultMap["miner"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "miner")
        }
      }

      public var reward: BigNumber {
        get {
          return resultMap["reward"]! as! BigNumber
        }
        set {
          resultMap.updateValue(newValue, forKey: "reward")
        }
      }

      public var size: Int {
        get {
          return resultMap["size"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "size")
        }
      }

      public var time: DateTime {
        get {
          return resultMap["time"]! as! DateTime
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

      public struct Miner: GraphQLSelectionSet {
        public static let possibleTypes = ["EthereumAccount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("address", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(address: String) {
          self.init(unsafeResultMap: ["__typename": "EthereumAccount", "address": address])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var address: String {
          get {
            return resultMap["address"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "address")
          }
        }
      }

      public struct Transaction: GraphQLSelectionSet {
        public static let possibleTypes = ["PagedEthereumTransactions"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.object(Datum.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(data: [Datum?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "PagedEthereumTransactions", "data": data.flatMap { (value: [Datum?]) -> [ResultMap?] in value.map { (value: Datum?) -> ResultMap? in value.flatMap { (value: Datum) -> ResultMap in value.resultMap } } }])
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
          public static let possibleTypes = ["EthereumTransaction"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("hash", type: .nonNull(.scalar(String.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hash: String) {
            self.init(unsafeResultMap: ["__typename": "EthereumTransaction", "hash": hash])
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
        }
      }
    }
  }
}
