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
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!

    public func updateBlockData(block: ListBlocksQuery.Data.BlocksByHeight.Datum) {
        heightLabel.text = "Block Height: " + String(block.height)
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

        let dataSourceMapper: ArrayDataSourceMapper<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum> = { (data) in
            return data.blocksByHeight?.data
        }
        let viewUpdateHandler: ViewUpdateHandler<ListBlocksQuery.Data.BlocksByHeight.Datum> = { (view, data) in
            if let cell = view as? BlockListCell {
                cell.updateBlockData(block: data)
            }
        }
        dataSource = ABSDKTableViewDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>(client: arcblockClient, query: ListBlocksQuery(fromHeight: 0), dataSourceMapper: dataSourceMapper, viewUpdateHandler: viewUpdateHandler)

        dataSource.tableView = tableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BlockDetailSegue" {
            let indexPath: IndexPath = tableView.indexPathForSelectedRow!
            let data: ListBlocksQuery.Data.BlocksByHeight.Datum = dataSource.dataForIndexPath(indexPath: indexPath)!
            let destinationViewController: BlockDetailViewController = segue.destination as! BlockDetailViewController
            destinationViewController.height = data.height
            destinationViewController.title = "Block " + String(data.height)
        }
    }

}

extension BlockListViewController: UITableViewDelegate {
    
}

