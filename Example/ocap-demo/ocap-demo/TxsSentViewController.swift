//
//  TxsSentViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit

import ArcBlockSDK

class TxSentListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!

    public func updateTransactionData(transaction: TxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum) {
        hashLabel.text = transaction.hash
    }
}

class TxsSentViewController: UIViewController {
    var address: String!

    var arcblockClient: ABSDKClient!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingFooter: UIView!

    var txsSentDataSource: ABSDKArrayViewPagedDataSource<TxsSentByAccountQuery, TxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let transactionSourceMapper: ArrayDataSourceMapper<TxsSentByAccountQuery, TxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum> = { (data) in
            return data.accountByAddress?.txsSent?.data
        }
        let transactionDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] in
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.txsSentDataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let transactionPageMapper: PageMapper<TxsSentByAccountQuery> = { (data) in
            return (data.accountByAddress?.txsSent?.page)!
        }
        txsSentDataSource = ABSDKArrayViewPagedDataSource<TxsSentByAccountQuery, TxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum>(client: arcblockClient, query: TxsSentByAccountQuery(address: address), dataSourceMapper: transactionSourceMapper, pageMapper: transactionPageMapper, dataSourceUpdateHandler: transactionDataSourceUpdateHandler)
        txsSentDataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TxsSentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return txsSentDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txsSentDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TxSentListCell", for: indexPath) as! TxSentListCell
        let data = txsSentDataSource.itemForIndexPath(indexPath: indexPath)
        cell.updateTransactionData(transaction: data!)
        return cell
    }
}

extension TxsSentViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            txsSentDataSource.loadMore()
        }
    }
}
