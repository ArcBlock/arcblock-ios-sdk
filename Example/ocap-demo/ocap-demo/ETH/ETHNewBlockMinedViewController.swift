//
//  ETHNewBlockMinedViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 8/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class ETHNewBlockMinedViewController: UITableViewController {

    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKObjectDataSource<NewEthBlockMinedSubscription, NewEthBlockMinedSubscription.Data.NewBlockMined>!

    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var minerLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!

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
        authorLabel.text = block.author?.address
        feesLabel.text = String(block.fees)
        minerLabel.text = block.miner?.address
        rewardLabel.text = String(block.reward)
    }

}
