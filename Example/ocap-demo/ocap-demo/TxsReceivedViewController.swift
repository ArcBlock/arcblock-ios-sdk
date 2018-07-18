//
//  AccountTransactionsViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class TxReceivedListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!

    public func updateTransactionData(transaction: TxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum) {
        hashLabel.text = transaction.hash
    }
}

class TxsReceivedViewController: UIViewController {
    var address: String!

    var arcblockClient: ABSDKClient!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingFooter: UIView!

    var txsReceivedDataSource: ABSDKArrayViewPagedDataSource<TxsReceivedByAccountQuery, TxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let transactionSourceMapper: ArrayDataSourceMapper<TxsReceivedByAccountQuery, TxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum> = { (data) in
            return data.accountByAddress?.txsReceived?.data
        }
        let transactionDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] in
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.txsReceivedDataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let transactionPageMapper: PageMapper<TxsReceivedByAccountQuery> = { (data) in
            return (data.accountByAddress?.txsReceived?.page)!
        }
        txsReceivedDataSource = ABSDKArrayViewPagedDataSource<TxsReceivedByAccountQuery, TxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum>(client: arcblockClient, query: TxsReceivedByAccountQuery(address: address), dataSourceMapper: transactionSourceMapper, pageMapper: transactionPageMapper, dataSourceUpdateHandler: transactionDataSourceUpdateHandler)
        txsReceivedDataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TxsReceivedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return txsReceivedDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txsReceivedDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TxReceivedListCell", for: indexPath) as! TxReceivedListCell
        let data = txsReceivedDataSource.itemForIndexPath(indexPath: indexPath)
        cell.updateTransactionData(transaction: data!)
        return cell
    }
}

extension TxsReceivedViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            txsReceivedDataSource.loadMore()
        }
    }
}
