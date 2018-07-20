//
//  TransactionListViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 19/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK
import Apollo

class TransactionListViewController<Query: GraphQLPagedQuery, Data: GraphQLSelectionSet>: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var arcblockClient: ABSDKClient!
    var query: Query!
    var transactionsSourceMapper: ArrayDataSourceMapper<Query, Data>!
    var transactionsPageMapper: PageMapper<Query>!

    var tableView: UITableView!
    var loadingFooter: UIView!

    var transactionDataSource: ABSDKArrayViewPagedDataSource<Query, Data>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        tableView = UITableView.init(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "TransactionListCell", bundle: nil), forCellReuseIdentifier: "TransactionListCell")
        self.view.addSubview(tableView)

        let transactionDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] in
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.transactionDataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        transactionDataSource = ABSDKArrayViewPagedDataSource<Query, Data>(client: arcblockClient, query: query, dataSourceMapper: transactionsSourceMapper, dataSourceUpdateHandler: transactionDataSourceUpdateHandler, pageMapper: transactionsPageMapper)

        loadingFooter = UIView.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width, height: 44)))
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.center = loadingFooter.center
        activityIndicator.startAnimating()
        loadingFooter.addSubview(activityIndicator)
        tableView.tableFooterView = loadingFooter

        transactionDataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionListCell", for: indexPath) as! TransactionListCell
        let data = transactionDataSource.itemForIndexPath(indexPath: indexPath)
        cell.updateTransactionData(transaction: data!)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath: IndexPath = tableView.indexPathForSelectedRow!
        let data: Data = transactionDataSource.itemForIndexPath(indexPath: indexPath)!
        let transactionViewController: TransactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionViewController.txHash = data.resultMap["hash"] as! String
        self.navigationController?.pushViewController(transactionViewController, animated: true)
        tableView .deselectRow(at: indexPath, animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            transactionDataSource.loadMore()
        }
    }
}
