//
//  ViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 26/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

let cellIdentifier = "Cell"

class BlockListCell: UITableViewCell {
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!

    public func updateBlockData(block: ListBlocksQuery.Data.BlocksByHeight.Datum) {
        heightLabel.text = "Block Height: " + String(block.height)
        transactionLabel.text = String(block.numberTxs) + " txs " + String(block.total) + " BTC"
    }
}

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKArrayViewDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: ArrayDataSourceMapper<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum> = { (data) in
            return data.blocksByHeight?.data
        }
        dataSource = ABSDKArrayViewDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>(client: arcblockClient, query: ListBlocksQuery(fromHeight: 0, toHeight: 9999, paging: PageInput(cursor: nil, order: nil, size: 10)), dataSourceMapper: dataSourceMapper)

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

extension BlockListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BlockListCell
        let data = dataSource.dataForIndexPath(indexPath: indexPath)
        cell.updateBlockData(block: data!)
        return cell
    }
}

extension BlockListViewController: UITableViewDelegate {

}
