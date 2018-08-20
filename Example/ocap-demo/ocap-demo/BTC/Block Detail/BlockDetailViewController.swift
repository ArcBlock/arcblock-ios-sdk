//
//  BlockDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 4/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class BlockDetailView: ABSDKObjectView<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight> {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var numberOfTxsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    var height: Int? {
        didSet {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let client: ABSDKClient = appDelegate.btcClient
            let detailDataSourceMapper: ObjectDataSourceMapper<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight> = { (data) in
                return data.blockByHeight
            }
            self.configureDataSource(client: client, operation: BtcBlockDetailQuery(height: height!), dataSourceMapper: detailDataSourceMapper)
        }
    }

    static let timeConverter: TimeConverter = {
        var timeConverter = TimeConverter()
        timeConverter.dateStyle = .medium
        timeConverter.timeStyle = .medium
        return timeConverter
    }()

    override func updateView(data: BtcBlockDetailQuery.Data.BlockByHeight) {
        hashLabel.text = data.hash
        numberOfTxsLabel.text = String(data.numberTxs)
        totalLabel.text = String(data.total)
        feesLabel.text = String(data.fees)
        timeLabel.text = type(of: self).timeConverter.convertTime(time: data.time)
    }
}

class BlockDetailViewController: TransactionListViewController<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight.Transaction.Datum> {
    public var height: Int = 0

    var detailView: BlockDetailView!

    override func viewDidLoad() {
        self.query = BtcBlockDetailQuery(height: height)

        self.transactionsSourceMapper = { (data) in
            return data.blockByHeight?.transactions?.data
        }
        self.transactionsPageMapper = { (data) in
            return (data.blockByHeight?.transactions?.page)!
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.btcClient

        super.viewDidLoad()

        detailView = Bundle.main.loadNibNamed("BlockDetailView", owner: self, options: nil)![0] as! BlockDetailView
        detailView.height = height
        self.tableView.tableHeaderView = detailView
    }

    override func transactionSelected(transation: BtcBlockDetailQuery.Data.BlockByHeight.Transaction.Datum) {
        let transactionViewController: TransactionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionViewController.txHash = transation.hash
        self.navigationController?.pushViewController(transactionViewController, animated: true)
    }
}
