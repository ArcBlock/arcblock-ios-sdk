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

protocol ABSDKDataSource {
    associatedtype Query: GraphQLQuery
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var query: Query { get }
    var viewUpdateHandler: ViewUpdateHandler<Data> { get }
    var watcher: GraphQLQueryWatcher<Query>? { get }

    init(client: ABSDKClient, query: Query, viewUpdateHandler: @escaping ViewUpdateHandler<Data>)
}

final public class ABSDKObjectDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    public weak var view: UIView?

    var object: Data? = nil {
        didSet {
            viewUpdateHandler(view!, object!)
        }
    }

    var dataSourceMapper: ObjectDataSourceMapper<Query, Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query
    let viewUpdateHandler: ViewUpdateHandler<Data>

    init(client: ABSDKClient, query: Query, viewUpdateHandler: @escaping ViewUpdateHandler<Data>) {
        self.client = client
        self.query = query
        self.viewUpdateHandler = viewUpdateHandler
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ObjectDataSourceMapper<Query, Data>, viewUpdateHandler: @escaping ViewUpdateHandler<Data>) {
        self.init(client: client, query: query, viewUpdateHandler: viewUpdateHandler)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.object = self.dataSourceMapper!((result?.data)!)
        })
    }
}

final public class ABSDKTableViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: NSObject, UITableViewDataSource, ABSDKDataSource {
    public weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
        }
    }

    public var reuseIdentifier: String! = "Cell"
    
    var array: [Data?]? = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query
    let viewUpdateHandler: ViewUpdateHandler<Data>

    init(client: ABSDKClient, query: Query, viewUpdateHandler: @escaping ViewUpdateHandler<Data>) {
        self.client = client
        self.query = query
        self.viewUpdateHandler = viewUpdateHandler
        super.init()
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping (Query.Data) -> [Data?]?, viewUpdateHandler: @escaping (UIView, Data) -> Void) {
        self.init(client: client, query: query, viewUpdateHandler: viewUpdateHandler)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.array = self.dataSourceMapper!((result?.data)!)
        })
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let data = array![indexPath.row]!
        viewUpdateHandler(cell, data)
        return cell
    }
}

final public class ABSDKCollectionViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: NSObject, UICollectionViewDataSource, ABSDKDataSource {
    public weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.dataSource = self
        }
    }

    public var reuseIdentifier: String! = "Cell"

    var array: [Data?]? = [] {
        didSet {
            collectionView?.reloadData()
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>? = nil
    var watcher: GraphQLQueryWatcher<Query>? = nil

    let client: ABSDKClient
    let query: Query
    let viewUpdateHandler: ViewUpdateHandler<Data>

    init(client: ABSDKClient, query: Query, viewUpdateHandler: @escaping ViewUpdateHandler<Data>) {
        self.client = client
        self.query = query
        self.viewUpdateHandler = viewUpdateHandler
        super.init()
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping (Query.Data) -> [Data?]?, viewUpdateHandler: @escaping (UIView, Data) -> Void) {
        self.init(client: client, query: query, viewUpdateHandler: viewUpdateHandler)
        self.dataSourceMapper = dataSourceMapper

        self.watcher = self.client.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.array = self.dataSourceMapper!((result?.data)!)
        })
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return array?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let data = array![indexPath.row]!
        viewUpdateHandler(cell, data)
        return cell
    }
}
