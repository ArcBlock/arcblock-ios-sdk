// ABSDKTableViewController.swift
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

import UIKit
import Apollo

/// A base class for custom TableViewController that supports data binding and pagination
open class ABSDKTableViewController<Query: GraphQLPagedQuery, Data: GraphQLSelectionSet, Cell: ABSDKTableViewCell<Data> & CellWithNib>: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var loadingFooter: UIView!

    /// The ABSDKClient for sending requests
    public var client: ABSDKClient?
    /// The GraphQL query to get the array
    public var query: Query?
    /// The callback to extract the concerned array from the query result
    public var dataSourceMapper: ArrayDataSourceMapper<Query, Data>?
    /// The callback to extract page info from the query result
    public var pageMapper: PageMapper<Query>?

    /// The dataSource the performs data binding
    public private(set) var dataSource: ABSDKPagedArrayDataSource<Query, Data>?

    /// Override to perform custom setup
    override open func viewDidLoad() {
        super.viewDidLoad()

        tableView = UITableView.init(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        if let nibName: String = Cell.nibName {
            tableView.register(UINib.init(nibName: nibName, bundle: nil), forCellReuseIdentifier: "Cell")
        } else {
            tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        }
        self.view.addSubview(tableView)

        self.configDataSource()
        self.setupDataSource()

        loadingFooter = UIView.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width, height: 44)))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.center = loadingFooter.center
        activityIndicator.startAnimating()
        loadingFooter.addSubview(activityIndicator)
        tableView.tableFooterView = loadingFooter
    }

    /// Override to configure the data source
    open func configDataSource() {
        // base class
    }

    func setupDataSource() {
        if  let client: ABSDKClient = self.client,
            let query: Query = self.query,
            let dataSourceMapper: ArrayDataSourceMapper<Query, Data> = self.dataSourceMapper,
            let pageMapper: PageMapper<Query> = self.pageMapper {
            dataSource = ABSDKPagedArrayDataSource<Query, Data>(client: client, query: query, dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: { [weak self] (err) in
                if err != nil {
                    return
                }
                self?.tableView.reloadData()
                if let hasMore: Bool = self?.dataSource?.hasMore {
                    self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
                }
            }, pageMapper: pageMapper)
            dataSource?.refresh()
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.numberOfRows(section: section) ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if  let data: Data = self.dataSource?.itemForIndexPath(indexPath: indexPath),
            let cellForData: ABSDKTableViewCell<Data> = cell as? ABSDKTableViewCell<Data> {
            cellForData.updateView(data: data)
        }
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            dataSource?.loadMore()
        }
    }
}
