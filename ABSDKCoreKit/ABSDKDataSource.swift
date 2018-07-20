// ABSDKDataSource.swift
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

import Apollo

public typealias DataSourceUpdateHandler = () -> Void

protocol ABSDKDataSource {
    associatedtype Query: GraphQLQuery
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var query: Query { get }
    var dataSourceUpdateHandler: DataSourceUpdateHandler { get }
}

public typealias ObjectDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> Data?

final public class ABSDKObjectDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var object: Data? = nil {
        didSet {
            dataSourceUpdateHandler()
        }
    }

    let client: ABSDKClient
    let query: Query
    let dataSourceUpdateHandler: DataSourceUpdateHandler
    let dataSourceMapper: ObjectDataSourceMapper<Query, Data>

    var watcher: GraphQLQueryWatcher<Query>?

    public init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ObjectDataSourceMapper<Query, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.client = client
        self.query = query
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Query.Data = result?.data, let object: Data = self?.dataSourceMapper(data) {
                    self?.object = object
                }
            }
        })
    }

    public func getObject() -> Data? {
        return object
    }
}

public typealias ArrayDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> [Data?]?
public typealias ArrayDataKeyEqualChecker<Data: GraphQLSelectionSet> = (_ object1: Data?, _ object2: Data?) -> Bool

public struct RowChange {
    public enum RowChangeType {
        case insert
        case delete
        case move
        case update
    }

    public var type: RowChangeType!
    public var indexPath: IndexPath?
    public var newIndexPath: IndexPath?

    init(type: RowChangeType, indexPath: IndexPath? = nil, newIndexPath: IndexPath? = nil) {
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }
}

public class ABSDKArrayViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var array: [Data?] = [] {
        willSet(newValue) {
            calculateChanges(oldArray: array, newArray: newValue)
        }
        didSet {
            dataSourceUpdateHandler()
        }
    }

    var changes: [RowChange] = []

    let client: ABSDKClient
    let query: Query
    let dataSourceUpdateHandler: DataSourceUpdateHandler
    let dataSourceMapper: ArrayDataSourceMapper<Query, Data>
    var arrayDataKeyEqualChecker: ArrayDataKeyEqualChecker<Data>?

    var watcher: GraphQLQueryWatcher<Query>?

    public init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ArrayDataSourceMapper<Query, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler, arrayDataKeyEqualChecker: ArrayDataKeyEqualChecker<Data>? = nil) {
        self.client = client
        self.query = query
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
        self.dataSourceMapper = dataSourceMapper
        self.arrayDataKeyEqualChecker = arrayDataKeyEqualChecker

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Query.Data = result?.data, let items: [Data?] = self?.dataSourceMapper(data) {
                    self?.array = items
                }
            }
        })
    }

    func calculateChanges(oldArray: [Data?], newArray: [Data?]) {
        if let checker: ArrayDataKeyEqualChecker = arrayDataKeyEqualChecker {
            var newChanges: [RowChange] = []

            if oldArray.count == 0 && newArray.count != 0 {
                for index in 0...newArray.count-1 {
                    newChanges.append(RowChange(type: .insert, newIndexPath: IndexPath(row: index, section: 0)))
                }
            } else if oldArray.count != 0 && newArray.count == 0 {
                for index in 0...oldArray.count-1 {
                    newChanges.append(RowChange(type: .delete, indexPath: IndexPath(row: index, section: 0)))
                }
            } else if oldArray.count != 0 && newArray.count != 0 {
                var intersections: [Int] = []
                for newArrayIndex in 0...newArray.count-1 {
                    var inOldArray: Bool = false
                    for oldArrayIndex in 0...oldArray.count-1 {
                        if checker(newArray[newArrayIndex], oldArray[oldArrayIndex]) {
                            if newArrayIndex == oldArrayIndex {
                                let value1: JSONObject = (newArray[newArrayIndex]?.jsonObject)!
                                let value2: JSONObject = (oldArray[oldArrayIndex]?.jsonObject)!
                                if !NSDictionary(dictionary: value1).isEqual(to: value2) {
                                    newChanges.append(RowChange(type: .update, indexPath: IndexPath(row: oldArrayIndex, section: 0)))
                                }
                            } else {
                                newChanges.append(RowChange(type: .move, indexPath: IndexPath(row: oldArrayIndex, section: 0), newIndexPath: IndexPath(row: newArrayIndex, section: 0)))
                            }

                            inOldArray = true
                            intersections.append(oldArrayIndex)
                            break
                        }
                    }

                    if !inOldArray {
                        newChanges.append(RowChange(type: .insert, newIndexPath: IndexPath(row: newArrayIndex, section: 0)))
                    }
                }

                for index in 0...array.count-1 {
                    if !intersections.contains(index) {
                        newChanges.append(RowChange(type: .delete, indexPath: IndexPath(row: index, section: 0)))
                    }
                }
            }

            changes = newChanges
        }
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(section: Int) -> Int {
        return array.count
    }

    public func itemForIndexPath(indexPath: IndexPath) -> Data? {
        return array[indexPath.row]
    }
}
