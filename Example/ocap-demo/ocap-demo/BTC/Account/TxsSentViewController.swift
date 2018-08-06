//
//  TxsSentViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class TxsSentViewController: TransactionListViewController<BtcTxsSentByAccountQuery, BtcTxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum> {
    var address: String!

    var txsSentDataSource: ABSDKPagedArrayDataSource<BtcTxsSentByAccountQuery, BtcTxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum>!

    override func viewDidLoad() {
        self.query = BtcTxsSentByAccountQuery(address: address)

        self.transactionsSourceMapper = { (data) in
            return data.accountByAddress?.txsSent?.data
        }

        self.transactionsPageMapper = { (data) in
            return (data.accountByAddress?.txsSent?.page)!
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.btcClient

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.frame = self.view.bounds
    }

    override func transactionSelected(transation: BtcTxsSentByAccountQuery.Data.AccountByAddress.TxsSent.Datum) {
        let transactionViewController: TransactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionViewController.txHash = transation.hash
        self.navigationController?.pushViewController(transactionViewController, animated: true)
    }
}
