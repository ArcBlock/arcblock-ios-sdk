//
//  ETHNewBlockMinedViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 8/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class ETHNewBlockMinedViewController: UIViewController {

    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKObjectDataSource<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined>!
    var transactionsDataSource: ABSDKArrayDataSource<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined.Transaction.Datum>!

    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var minerLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.ethClient

        let dataSourceMapper: ObjectDataSourceMapper<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined> = { (data) in
            return data.newBlockMined
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }

            self?.updateNewBlock(block: (self?.dataSource.getObject())!)
        }

        dataSource = ABSDKObjectDataSource<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined>(client: arcblockClient, operation: NewEthBlockMinedSubscription(), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler)
        dataSource.observe()

        let transactionsDataSourceMapper: ArrayDataSourceMapper<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined.Transaction.Datum> = { (data) in
            return data.newBlockMined?.transactions?.data
        }
        let transactionsDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }

            self?.tableView.reloadData()
        }

        transactionsDataSource = ABSDKArrayDataSource<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined.Transaction.Datum>(client: arcblockClient, operation: NewEthBlockMinedSubscription(), dataSourceMapper: transactionsDataSourceMapper, dataSourceUpdateHandler: transactionsDataSourceUpdateHandler)
        transactionsDataSource.observe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateNewBlock(block: NewEthBlockMinedSubscription.Data.NewBlockMined) {
        self.title = "Block " + String(block.height)
        hashLabel.text = block.hash
        sizeLabel.text = String(block.size)
        timeLabel.text = block.time
        feesLabel.text = block.fees
        minerLabel.text = block.miner.address
        rewardLabel.text = String(block.reward)
    }

}

extension ETHNewBlockMinedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionsDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewBlockTransactions", for: indexPath)
        let data = transactionsDataSource.itemForIndexPath(indexPath: indexPath)
        if let block: NewEthBlockMinedSubscription.Data.NewBlockMined.Transaction.Datum = data {
            cell.textLabel?.text = block.hash
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }
}
