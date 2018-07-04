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

public typealias DataSourceMapper<Query: GraphQLQuery, Data: GraphQLSelectionSet> = (_ data: Query.Data) -> [Data?]?

public typealias ViewUpdateHandler<Data: GraphQLSelectionSet> = (_ view: UIView, _ data: Data) -> Void

protocol ABSDKDataSource {
    associatedtype Query: GraphQLQuery
    associatedtype Data: GraphQLSelectionSet

    var client: ABSDKClient { get }
    var query: Query { get }
    var dataSourceMapper: DataSourceMapper<Query, Data> { get }

    init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping DataSourceMapper<Query, Data>)
}

final public class ABSDKTableViewDataSource<Query: GraphQLQuery, Data: GraphQLSelectionSet>: NSObject, UITableViewDataSource, ABSDKDataSource {
    public weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
        }
    }

    public var viewUpdateHandler: ViewUpdateHandler<Data>? = nil
    
    var array: [Data?]? = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    let client: ABSDKClient
    let query: Query
    let dataSourceMapper: DataSourceMapper<Query, Data>
    var reuseIdentifier: String!

    init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping DataSourceMapper<Query, Data>) {
        self.client = client
        self.query = query
        self.dataSourceMapper = dataSourceMapper
        super.init()

        self.client.apolloClient?.watch(query: self.query, cachePolicy: .returnCacheDataAndFetch, resultHandler: { (result, err) in
            self.array = self.dataSourceMapper((result?.data)!)
        })
    }

    public convenience init(client: ABSDKClient, query: Query, reuseIdentifier: String = "Cell", dataSourceMapper: @escaping DataSourceMapper<Query, Data>) {
        self.init(client: client, query: query, dataSourceMapper: dataSourceMapper)
        self.reuseIdentifier = reuseIdentifier
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
        viewUpdateHandler?(cell, data)
        return cell
    }
}
