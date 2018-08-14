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

/// The callback that gets called when there's a data update(err=nil), or there's an error during data update(err!=nil)
public typealias DataSourceUpdateHandler = (_ err: Error?) -> Void

protocol ABSDKDataSource {
    associatedtype Operation: GraphQLOperation
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var operation: Operation { get }
    var dataSourceUpdateHandler: DataSourceUpdateHandler { get }
    var observer: Cancellable? { get }
}

/// The callback to extract the object in query result
public typealias ObjectDataSourceMapper<Operation: GraphQLOperation, Data: GraphQLSelectionSet> = (_ data: Operation.Data) -> Data?

/// A data source that binds with an object type of data in a GraphQL query and monitors its update
final public class ABSDKObjectDataSource<Operation: GraphQLOperation, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var object: Data? = nil {
        didSet {
            dataSourceUpdateHandler(nil)
        }
    }

    let client: ABSDKClient
    let operation: Operation
    let dataSourceUpdateHandler: DataSourceUpdateHandler
    let dataSourceMapper: ObjectDataSourceMapper<Operation, Data>
    var observer: Cancellable?

    /// Init an object data source
    ///
    /// - Parameters:
    ///     client: An ABSDKClient for sending requests
    ///     query: A GraphQL query to get the object
    ///     dataSourceMapper: A callback to extract the concerned object from the query result
    ///     dataSourceUpdateHandler: A callback that gets called whenever the concerned object gets update
    public init(client: ABSDKClient, operation: Operation, dataSourceMapper: @escaping ObjectDataSourceMapper<Operation, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.client = client
        self.operation = operation
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
        self.dataSourceMapper = dataSourceMapper
    }

    deinit {
        observer?.cancel()
    }

    /// Get the concerned object
    public func getObject() -> Data? {
        return object
    }
}

public extension ABSDKObjectDataSource where Operation: GraphQLQuery {
    /// Start observing on the operation related data
    public func observe() {
        self.observer = self.client.watch(query: self.operation, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Operation.Data = result?.data, let object: Data = self?.dataSourceMapper(data) {
                    self?.object = object
                }
            } else {
                self?.dataSourceUpdateHandler(err)
            }
        })
    }
}

public extension ABSDKObjectDataSource where Operation: GraphQLSubscription {
    /// Start observing on the operation related data
    public func observe() {
        self.observer = self.client.subscribe(subscription: self.operation, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Operation.Data = result?.data, let object: Data = self?.dataSourceMapper(data) {
                    self?.object = object
                }
            } else {
                self?.dataSourceUpdateHandler(err)
            }
        })
    }
}

/// The callback to extract the array in query result
public typealias ArrayDataSourceMapper<Operation: GraphQLOperation, Data: GraphQLSelectionSet> = (_ data: Operation.Data) -> [Data?]?

/// The callback to check whether two elements in the array has the same key
public typealias ArrayDataKeyEqualChecker<Data: GraphQLSelectionSet> = (_ object1: Data?, _ object2: Data?) -> Bool

/// A structure to describe a row change
public struct RowChange {

    /// Enum of type of row change
    public enum RowChangeType {
        /// A row should be inserted
        case insert
        /// A row should be deleted
        case delete
        /// A row should be moved
        case move
        /// A row should be updated
        case update
    }

    /// The type of the row change
    public var type: RowChangeType!
    /// The indexPath of the row before change
    public var indexPath: IndexPath?
    /// The indexPath of the row after change
    public var newIndexPath: IndexPath?

    init(type: RowChangeType, indexPath: IndexPath? = nil, newIndexPath: IndexPath? = nil) {
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }
}

/// A data source that binds with an array type of data in a GraphQL query and monitors its update
public class ABSDKArrayDataSource<Operation: GraphQLOperation, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var array: [Data?] = [] {
        willSet(newValue) {
            calculateChanges(oldArray: array, newArray: newValue)
        }
        didSet {
            dataSourceUpdateHandler(nil)
        }
    }

    var changes: [RowChange] = []

    let client: ABSDKClient
    let operation: Operation
    let dataSourceUpdateHandler: DataSourceUpdateHandler
    let dataSourceMapper: ArrayDataSourceMapper<Operation, Data>
    var arrayDataKeyEqualChecker: ArrayDataKeyEqualChecker<Data>?
    var observer: Cancellable?

    /// Init an array data source
    ///
    /// - Parameters:
    ///     client: an ABSDKClient for sending requests
    ///     query: A GraphQL query to get the array
    ///     dataSourceMapper: A callback to extract the concerned array from the query result
    ///     dataSourceUpdateHandler: A callback that gets called whenever the concerned array gets update
    ///     arrayDataKeyEqualCHecker: An optional callback to check whether two elements in the concerned array are with the same key. This is used to calculate the row changes to update view dynamically.
    public init(client: ABSDKClient, operation: Operation, dataSourceMapper: @escaping ArrayDataSourceMapper<Operation, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler, arrayDataKeyEqualChecker: ArrayDataKeyEqualChecker<Data>? = nil) {
        self.client = client
        self.operation = operation
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
        self.dataSourceMapper = dataSourceMapper
        self.arrayDataKeyEqualChecker = arrayDataKeyEqualChecker
    }

    deinit {
        self.observer?.cancel()
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

    /// Get number of sections in the array, for tableView/CollectionView. default is 1
    public func numberOfSections() -> Int {
        return 1
    }

    /// Get number of rows in the array, for tableView/CollectionView.
    public func numberOfRows(section: Int) -> Int {
        return array.count
    }

    /// Get the element in the array, for tableView/CollectionView. 
    /// - Parameters:
    ///     indexPath: The indexPath of the item
    /// - Returns: The element at the indexPath
    public func itemForIndexPath(indexPath: IndexPath) -> Data? {
        return array[indexPath.row]
    }

    /// Get row changes, usually get called in DataSourceUpdateHandler
    public func getChanges() -> [RowChange] {
        return changes
    }
}

public extension ABSDKArrayDataSource where Operation: GraphQLQuery {
    /// Start observing on the operation related data
    public func observe() {
        self.observer = self.client.watch(query: self.operation, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Operation.Data = result?.data, let items: [Data?] = self?.dataSourceMapper(data) {
                    self?.array = items
                }
            } else {
                self?.dataSourceUpdateHandler(err)
            }
        })
    }
}

public extension ABSDKArrayDataSource where Operation: GraphQLSubscription {
    /// Start observing on the operation related data
    public func observe() {
        self.observer = self.client.subscribe(subscription: self.operation, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Operation.Data = result?.data, let items: [Data?] = self?.dataSourceMapper(data) {
                    self?.array = items
                }
            } else {
                self?.dataSourceUpdateHandler(err)
            }
        })
    }
}
