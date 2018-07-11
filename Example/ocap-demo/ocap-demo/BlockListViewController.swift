//
//  ViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 26/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

struct TimeConverter {
    public var dateStyle: DateFormatter.Style = .short {
        didSet {
            outputDateFormatter.dateStyle = dateStyle
        }
    }

    public var timeStyle: DateFormatter.Style = .short {
        didSet {
            outputDateFormatter.timeStyle = timeStyle
        }
    }

    let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return formatter
    }()

    let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()

    func convertTime(time: String) -> String {
        let date: Date = inputDateFormatter.date(from: time)!
        return outputDateFormatter.string(from: date)
    }
}

class BlockListCell: UITableViewCell {
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    fileprivate static let timeConverter: TimeConverter = TimeConverter()

    public func updateBlockData(block: ListBlocksQuery.Data.BlocksByHeight.Datum) {
        heightLabel.text = "Block Height: " + String(block.height)
        transactionLabel.text = String(block.numberTxs) + " txs " + String(block.total) + " BTC"
        timeLabel.text = type(of: self).timeConverter.convertTime(time: block.time)
    }
}

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKArrayViewPagedDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: ArrayDataSourceMapper<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum> = { (data) in
            return data.blocksByHeight?.data
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = {
            self.tableView.reloadData()
        }
        dataSource = ABSDKArrayViewPagedDataSource<ListBlocksQuery, ListBlocksQuery.Data.BlocksByHeight.Datum>(client: arcblockClient, query: ListBlocksQuery(fromHeight: 500000, toHeight: 500099), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockListCell", for: indexPath) as! BlockListCell
        let data = dataSource.dataForIndexPath(indexPath: indexPath)
        cell.updateBlockData(block: data!)
        return cell
    }
}

extension BlockListViewController: UITableViewDelegate {

}
