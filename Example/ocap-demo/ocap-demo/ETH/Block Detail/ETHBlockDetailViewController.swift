//
//  ETHBlockDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 6/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class EthBlockDetailView: UIView {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    static let timeConverter: TimeConverter = {
        var timeConverter = TimeConverter()
        timeConverter.dateStyle = .medium
        timeConverter.timeStyle = .medium
        return timeConverter
    }()

    public func updateBlockData(block: EthBlockDetailQuery.Data.BlockByHeight) {
        hashLabel.text = block.hash
        feesLabel.text = String(block.fees)
        timeLabel.text = type(of: self).timeConverter.convertTime(time: block.time)
    }
}

class ETHBlockDetailViewController: TransactionListViewController<EthBlockDetailQuery, EthBlockDetailQuery.Data.BlockByHeight.Transaction.Datum> {

    public var height: Int = 0

    var detailView: EthBlockDetailView!

    var detailDataSource: ABSDKObjectDataSource<EthBlockDetailQuery, EthBlockDetailQuery.Data.BlockByHeight>!

    override func viewDidLoad() {
        self.query = EthBlockDetailQuery(height: height)

        self.transactionsSourceMapper = { (data) in
            return data.blockByHeight?.transactions?.data
        }
        self.transactionsPageMapper = { (data) in
            return (data.blockByHeight?.transactions?.page)!
        }

        super.viewDidLoad()

        let detailSourceMapper: ObjectDataSourceMapper<EthBlockDetailQuery, EthBlockDetailQuery.Data.BlockByHeight> = { (data) in
            return data.blockByHeight
        }
        let detailDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }
            self?.detailView.updateBlockData(block: (self?.detailDataSource.getObject()!)!)
        }
        detailDataSource = ABSDKObjectDataSource<EthBlockDetailQuery, EthBlockDetailQuery.Data.BlockByHeight>(client: arcblockClient, query: EthBlockDetailQuery(height: height), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)

        detailView = Bundle.main.loadNibNamed("ETHBlockDetailView", owner: self, options: nil)![0] as! EthBlockDetailView
        self.tableView.tableHeaderView = detailView
    }

}
