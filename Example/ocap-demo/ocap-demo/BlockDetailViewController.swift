//
//  BlockDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 4/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class BlockDetailView: UIView {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var numberOfTxsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    fileprivate static let timeConverter: TimeConverter = {
        var timeConverter = TimeConverter()
        timeConverter.dateStyle = .medium
        timeConverter.timeStyle = .medium
        return timeConverter
    }()

    public func updateBlockData(block: BlockDetailQuery.Data.BlockByHeight) {
        hashLabel.text = block.hash
        numberOfTxsLabel.text = String(block.numberTxs)
        totalLabel.text = String(block.total)
        feesLabel.text = String(block.fees)
        timeLabel.text = type(of: self).timeConverter.convertTime(time: block.time)
    }
}

class TransactionListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!

    public func updateTransactionData(transaction: BlockDetailQuery.Data.BlockByHeight.Transaction.Datum) {
        hashLabel.text = transaction.hash
    }
}

class BlockDetailViewController: UIViewController {
    public var height: Int = 0

    var arcblockClient: ABSDKClient!
    var blockDetailQuery: BlockDetailQuery!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailView: BlockDetailView!

    var detailDataSource: ABSDKObjectDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight>!
    var transactionDataSource: ABSDKArrayViewDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight.Transaction.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        blockDetailQuery = BlockDetailQuery(height: height)

        let detailSourceMapper: ObjectDataSourceMapper<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight> = { (data) in
            return data.blockByHeight
        }
        let viewUpdateHandler: ViewUpdateHandler<BlockDetailQuery.Data.BlockByHeight> = { (view, data) in
            if let blockDetailView = view as? BlockDetailView {
                blockDetailView.updateBlockData(block: data)
            }
        }
        detailDataSource = ABSDKObjectDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight>(client: arcblockClient, query: blockDetailQuery, dataSourceMapper: detailSourceMapper, viewUpdateHandler: viewUpdateHandler)
        detailDataSource.view = detailView

        let transactionSourceMapper: ArrayDataSourceMapper<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight.Transaction.Datum> = { (data) in
            return data.blockByHeight?.transactions?.data
        }
        transactionDataSource = ABSDKArrayViewDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight.Transaction.Datum>(client: arcblockClient, query: blockDetailQuery, dataSourceMapper: transactionSourceMapper)
        transactionDataSource.tableView = tableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionSegue" {
            let indexPath: IndexPath = tableView.indexPathForSelectedRow!
            let data: BlockDetailQuery.Data.BlockByHeight.Transaction.Datum = transactionDataSource.dataForIndexPath(indexPath: indexPath)!
            let destinationViewController: TransactionViewController = segue.destination as! TransactionViewController
            destinationViewController.txHash = data.hash
        }
    }
}

extension BlockDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionListCell", for: indexPath) as! TransactionListCell
        let data = transactionDataSource.dataForIndexPath(indexPath: indexPath)
        cell.updateTransactionData(transaction: data!)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }
}
