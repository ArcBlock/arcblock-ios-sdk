//  This file was automatically generated and should not be edited.

import Apollo
import ArcBlockSDK

public final class RichestAccountsQuery: GraphQLPagedQuery {
  public let operationDefinition =
    "query RichestAccounts($paging: PageInput) {\n  richestAccounts(paging: $paging) {\n    __typename\n    data {\n      __typename\n      address\n      balance\n    }\n    page {\n      __typename\n      total\n      next\n      cursor\n    }\n  }\n}"

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