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
import UIKit

public typealias ArrayDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> [Data?]?

public typealias ObjectDataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> Data?

public typealias ViewUpdateHandler<Data: GraphQLSelectionSet> = (_ view: UIView, _ data: Data) -> Void

public protocol GraphQLPagedQuery: GraphQLQuery {
    var paging: PageInput? { get }
}

public protocol PagedData: GraphQLSelectionSet {
    var page: Page? { get }
}

protocol ABSDKDataSource {
    associatedtype Query: GraphQLQuery
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var query: Query { get }
    var watcher: GraphQLQueryWatcher<Query>? { get }

    init(client: ABSDKClient, query: Query)
}

final public class ABSDKObjectDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    public weak var view: UIView?

    var object: Data? = nil {
        didSet {
            if view != nil && object != nil {
                viewUpdateHandler!(view!, object!)
            }
        }
    }

    var dataSourceMapper: ObjectDataSourceMapper<Query, Data>? = nil
    var viewUpdateHandler: ViewUpdateHandler<Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query

    init(client: ABSDKClient, query: Query) {
        self.client = client
        self.query = query
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ObjectDataSourceMapper<Query, Data>, viewUpdateHandler: @escaping ViewUpdateHandler<Data>) {
        self.init(client: client, query: query)
        self.dataSourceMapper = dataSourceMapper
        self.viewUpdateHandler = viewUpdateHandler

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.object = self.dataSourceMapper!((result?.data)!)
        })
    }
}

final public class ABSDKArrayViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: NSObject, ABSDKDataSource {
    public weak var tableView: UITableView?
    
    var array: [Data?]? = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query

    init(client: ABSDKClient, query: Query) {
        self.client = client
        self.query = query
        super.init()
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping (Query.Data) -> [Data?]?) {
        self.init(client: client, query: query)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.array = self.dataSourceMapper!((result?.data)!)
        })
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(section: Int) -> Int{
        return (array?.count)!
    }

    public func dataForIndexPath(indexPath: IndexPath) -> Data? {
        return array![indexPath.row]
    }
}

final public class ABSDKArrayViewPagedDataSource<Query: GraphQLPagedQuery, Data: GraphQLSelectionSet>: NSObject, ABSDKDataSource {
    public weak var tableView: UITableView?

    var array: [Data?]? = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query

    init(client: ABSDKClient, query: Query) {
        self.client = client
        self.query = query
        super.init()
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping (Query.Data) -> [Data?]?) {
        self.init(client: client, query: query)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.array = self.dataSourceMapper!((result?.data)!)
        })
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(section: Int) -> Int{
        return (array?.count)!
    }

    public func dataForIndexPath(indexPath: IndexPath) -> Data? {
        return array![indexPath.row]
    }
}
