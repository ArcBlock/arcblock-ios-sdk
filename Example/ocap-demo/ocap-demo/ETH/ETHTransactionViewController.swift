//
//  ETHTransactionViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 6/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class ETHTransactionViewController: UITableViewController {

    public var txHash: String? = nil

    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!

    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var fromBalanceLabel: UILabel!
    @IBOutlet weak var fromContractLabel: UILabel!

    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var toBalanceLabel: UILabel!
    @IBOutlet weak var toContractLabel: UILabel!

    var arcblockClient: ABSDKClient!
    var transactionDataSource: ABSDKObjectDataSource<EthTransactionDetailQuery, EthTransactionDetailQuery.Data.TransactionByHash>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Transaction Detail"

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.ethClient

        let transactionSourceMapper: ObjectDataSourceMapper<EthTransactionDetailQuery, EthTransactionDetailQuery.Data.TransactionByHash> = { (data) in
            return data.transactionByHash
        }
        let transactionDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }

            self?.updateTransaction(data: self?.transactionDataSource.getObject())
        }

        transactionDataSource = ABSDKObjectDataSource<EthTransactionDetailQuery, EthTransactionDetailQuery.Data.TransactionByHash>(client: arcblockClient, operation: EthTransactionDetailQuery(hash: txHash!), dataSourceMapper: transactionSourceMapper, dataSourceUpdateHandler: transactionDataSourceUpdateHandler)
        transactionDataSource.observe()
    }

    func updateTransaction(data: EthTransactionDetailQuery.Data.TransactionByHash?) {
        hashLabel.text = txHash

        if let transaction: EthTransactionDetailQuery.Data.TransactionByHash = data {
            totalLabel.text = transaction.total
            feesLabel.text = transaction.fees

            fromAddressLabel.text = transaction.from.address
            fromBalanceLabel.text = String(transaction.from.balance!)
            fromContractLabel.text = transaction.from.isContract ? "Yes" : "No"

            toAddressLabel.text = transaction.to?.address
            toBalanceLabel.text = String((transaction.to?.balance)!)
            toContractLabel.text = (transaction.to?.isContract)! ? "Yes" : "No"
        }
    }

}
