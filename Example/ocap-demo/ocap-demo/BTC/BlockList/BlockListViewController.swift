//
//  ViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 26/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class BlockListViewController: ABSDKTableViewController<ListBtcBlocksQuery, ListBtcBlocksQuery.Data.BlocksByHeight.Datum, BlockListCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func configDataSource() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        client = appDelegate.btcClient

        dataSourceMapper = { (data) in
            return data.blocksByHeight?.data
        }
        pageMapper = { (data) in
            return (data.blocksByHeight?.page)!
        }
        query = ListBtcBlocksQuery(fromHeight: 500000)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data: ListBtcBlocksQuery.Data.BlocksByHeight.Datum = self.dataSource!.itemForIndexPath(indexPath: indexPath)!
        let destinationViewController: BlockDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BlockDetailViewController") as! BlockDetailViewController
        destinationViewController.height = data.height
        destinationViewController.title = "Block " + String(data.height)
    }
}
