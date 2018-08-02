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

    public func updateBlockData(block: BtcBlockDetailQuery.Data.BlockByHeight) {
        hashLabel.text = block.hash
        numberOfTxsLabel.text = String(block.numberTxs)
        totalLabel.text = String(block.total)
        feesLabel.text = String(block.fees)
        timeLabel.text = type(of: self).timeConverter.convertTime(time: block.time)
    }
}

class BlockDetailViewController: TransactionListViewController<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight.Transaction.Datum> {
    public var height: Int = 0

    var detailView: BlockDetailView!

    var detailDataSource: ABSDKObjectDataSource<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight>!

    override func viewDidLoad() {
        self.query = BtcBlockDetailQuery(height: height)

        self.transactionsSourceMapper = { (data) in
            return data.blockByHeight?.transactions?.data
        }
        self.transactionsPageMapper = { (data) in
            return (data.blockByHeight?.transactions?.page)!
        }

        super.viewDidLoad()

        let detailSourceMapper: ObjectDataSourceMapper<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight> = { (data) in
            return data.blockByHeight
        }
        let detailDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }
            self?.detailView.updateBlockData(block: (self?.detailDataSource.getObject()!)!)
        }
        detailDataSource = ABSDKObjectDataSource<BtcBlockDetailQuery, BtcBlockDetailQuery.Data.BlockByHeight>(client: arcblockClient, query: BtcBlockDetailQuery(height: height), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)

        detailView = Bundle.main.loadNibNamed("BlockDetailView", owner: self, options: nil)![0] as! BlockDetailView
        self.tableView.tableHeaderView = detailView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
