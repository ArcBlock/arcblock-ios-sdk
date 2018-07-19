//
//  AccountTransactionsViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class TxsReceivedViewController: TransactionListViewController<TxsReceivedByAccountQuery, TxsReceivedByAccountQuery.Data.AccountByAddress.TxsReceived.Datum> {
    var address: String!

    override func viewDidLoad() {
        self.query = TxsReceivedByAccountQuery(address: address)

        self.transactionsSourceMapper = { (data) in
            return data.accountByAddress?.txsReceived?.data
        }
        self.transactionsPageMapper = { (data) in
            return (data.accountByAddress?.txsReceived?.page)!
        }

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
