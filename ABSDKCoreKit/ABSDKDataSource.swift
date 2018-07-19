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

public typealias ArrayDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> [Data?]?

public typealias ObjectDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> Data?

public typealias DataSourceUpdateHandler = () -> Void

protocol ABSDKDataSource {
    associatedtype Query: GraphQLQuery
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var query: Query { get }
    var dataSourceUpdateHandler: DataSourceUpdateHandler { get }

    init(client: ABSDKClient, query: Query, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler)
}

final public class ABSDKObjectDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var object: Data? = nil {
        didSet {
            dataSourceUpdateHandler()
        }
    }

    var dataSourceMapper: ObjectDataSourceMapper<Query, Data>!
    var watcher: GraphQLQueryWatcher<Query>?

    let client: ABSDKClient
    let query: Query
    let dataSourceUpdateHandler: DataSourceUpdateHandler

    init(client: ABSDKClient, query: Query, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.client = client
        self.query = query
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ObjectDataSourceMapper<Query, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.init(client: client, query: query, dataSourceUpdateHandler: dataSourceUpdateHandler)
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

final public class ABSDKArrayViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var array: [Data?] = [] {
        didSet {
            dataSourceUpdateHandler()
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>!
    var watcher: GraphQLQueryWatcher<Query>?

    let client: ABSDKClient
    let query: Query
    let dataSourceUpdateHandler: DataSourceUpdateHandler

    init(client: ABSDKClient, query: Query, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.client = client
        self.query = query
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ArrayDataSourceMapper<Query, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.init(client: client, query: query, dataSourceUpdateHandler: dataSourceUpdateHandler)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
            if err == nil {
                if let data: Query.Data = result?.data, let items: [Data?] = self?.dataSourceMapper(data) {
                    self?.array = items
                }
            }
        })
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
