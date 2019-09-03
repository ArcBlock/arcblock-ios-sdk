// ABSDKPagination.swift
//
// Copyright (c) 2017-present ArcBlock Foundation Ltd <https://www.arcblock.io/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// swiftlint:disable identifier_name

import Apollo

/// A custom type that used in query arguments for requesting paged data
public struct PageInput: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    public init(cursor: String? = nil, order: [PageOrder?]? = nil, size: Int? = nil) {
        graphQLMap = ["cursor": cursor, "order": order, "size": size]
    }

    public var cursor: String? {
        get {
            guard let cursor = graphQLMap["cursor"] as? String else {
                return nil
            }
            return cursor
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "cursor")
        }
    }

    public var order: [PageOrder?]? {
        get {
            guard let order = graphQLMap["order"] as? [PageOrder?] else {
                return nil
            }
            return order
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "order")
        }
    }

    public var size: Int? {
        get {
            guard let size = graphQLMap["size"] as? Int else {
                return nil
            }
            return size
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "size")
        }
    }
}

/// When you carry out a query, in most of cases you can provide which field you want to us to order the result. The field to be ordered is vary query by query.
public struct PageOrder: GraphQLMapConvertible {
    public var graphQLMap: GraphQLMap

    public init(field: String? = nil, type: String? = nil) {
        graphQLMap = ["field": field, "type": type]
    }

    public var field: String? {
        get {
            guard let field = graphQLMap["field"] as? String else {
                return nil
            }
            return field
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "field")
        }
    }

    public var type: String? {
        get {
            guard let type = graphQLMap["type"] as? String else {
                return nil
            }
            return type
        }
        set {
            graphQLMap.updateValue(newValue, forKey: "type")
        }
    }
}

/// A custom type that returns from server describing the page info
public struct Page: GraphQLSelectionSet {
    public static let possibleTypes = ["PageInfo"]

    public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("total", type: .scalar(Int.self)),
        GraphQLField("next", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("cursor", type: .nonNull(.scalar(String.self)))
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
            guard let __typename = resultMap["__typename"]! as? String else {
                return ""
            }
            return __typename
        }
        set {
            resultMap.updateValue(newValue, forKey: "__typename")
        }
    }

    public var total: Int? {
        get {
            guard let total = resultMap["total"]! as? Int else {
                return nil
            }
            return total
        }
        set {
            resultMap.updateValue(newValue, forKey: "total")
        }
    }

    public var next: Bool {
        get {
            guard let next = resultMap["next"]! as? Bool else {
                return false
            }
            return next
        }
        set {
            resultMap.updateValue(newValue, forKey: "next")
        }
    }

    public var cursor: String {
        get {
            guard let cursor = resultMap["cursor"]! as? String else {
                return ""
            }
            return cursor
        }
        set {
            resultMap.updateValue(newValue, forKey: "cursor")
        }
    }
}
