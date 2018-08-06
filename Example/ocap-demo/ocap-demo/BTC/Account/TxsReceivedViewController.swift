//
//  AccountTransactionsViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class TxsReceivedViewController: TransactionListViewController<BtcTxsReceivedByAccountQuery, BtcTxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum> {
    var address: String!

    override func viewDidLoad() {
        self.query = BtcTxsReceivedByAccountQuery(address: address)

        self.transactionsSourceMapper = { (data) in
            return data.accountByAddress?.txsReceived?.data
        }
        self.transactionsPageMapper = { (data) in
            return (data.accountByAddress?.txsReceived?.page)!
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.btcClient

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.frame = self.view.bounds
    }

    override func transactionSelected(transation: BtcTxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum) {
        let transactionViewController: TransactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionViewController.txHash = transation.hash
        self.navigationController?.pushViewController(transactionViewController, animated: true)
    }
}
