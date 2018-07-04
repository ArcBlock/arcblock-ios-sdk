//
//  ViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 26/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class BlockListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!

    public func updateBlockData(block: ListBlocksQuery.Data.BlocksByHeight.Datum) {
        hashLabel.text = block.hash
        transactionLabel.text = String(block.numberTxs) + " txs " + String(block.total) + " BTC"
    }
}

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKTableViewDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: DataSourceMapper<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum> = { (data) in
            return data.blocksByHeight?.data
        }
        dataSource = ABSDKTableViewDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>(client: arcblockClient, query: ListBlocksQuery(fromHeight: 0), dataSourceMapper: dataSourceMapper)
        dataSource.viewUpdateHandler = { (view, data) in
            if let cell = view as? BlockListCell {
                cell.updateBlockData(block: data)
            }
        }
        dataSource.tableView = tableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BlockListViewController: UITableViewDelegate {
    
}

