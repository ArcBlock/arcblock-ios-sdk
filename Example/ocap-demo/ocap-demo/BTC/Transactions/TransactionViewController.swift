//
//  TransactionViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 9/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

let inputCellIdentifier = "InputCell"
let outputCellIdentifier = "OutputCell"

class TransactionDetailView: UIView {
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var numberOfInputsLabel: UILabel!
    @IBOutlet weak var numberOfOutputsLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!

    public func updateTransactionData(transaction: BtcTransactionDetailQuery.Data.TransactionByHash) {
        totalLabel.text = String(transaction.total)
        numberOfInputsLabel.text = String(transaction.numberInputs)
        numberOfOutputsLabel.text = String(transaction.numberOutputs)
        feesLabel.text = String(transaction.fees)
    }
}

class InputCell: UITableViewCell {

    public func updateInputData(input: BtcTransactionDetailQuery.Data.TransactionByHash.Input.Datum) {
        self.textLabel?.text = input.account
        self.detailTextLabel?.text = String(input.value)
    }
}

class OutputCell: UITableViewCell {
    public func updateOuputData(output: BtcTransactionDetailQuery.Data.TransactionByHash.Output.Datum) {
        self.textLabel?.text = output.account
        self.detailTextLabel?.text = String(output.value)
    }
}

class TransactionViewController: UIViewController {
    public var txHash: String? = nil

    var arcblockClient: ABSDKClient!
    var transactionDetailQuery: BtcTransactionDetailQuery!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailView: TransactionDetailView!

    var detailDataSource: ABSDKObjectDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash>!
    var inputDataSource: ABSDKArrayDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Input.Datum>!
    var outputDataSource: ABSDKArrayDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Output.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = txHash

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.btcClient

        transactionDetailQuery = BtcTransactionDetailQuery(hash: txHash!)

        let detailSourceMapper: ObjectDataSourceMapper<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash> = { (data) in
            return data.transactionByHash
        }
        let detailDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err == nil {
                self?.detailView.updateTransactionData(transaction: (self?.detailDataSource.getObject()!)!)
            }
        }
        detailDataSource = ABSDKObjectDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash>(client: arcblockClient, operation: transactionDetailQuery, dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)
        detailDataSource.observe()

        let inputSourceMapper: ArrayDataSourceMapper<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Input.Datum> = { (data) in
            return data.transactionByHash?.inputs?.data
        }
        let inputDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err == nil {
                self?.tableView.reloadData()
            }
        }
        inputDataSource = ABSDKArrayDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Input.Datum>(client: arcblockClient, operation: transactionDetailQuery, dataSourceMapper: inputSourceMapper, dataSourceUpdateHandler: inputDataSourceUpdateHandler)
        inputDataSource.observe()

        let outputSourceMapper: ArrayDataSourceMapper<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Output.Datum> = { (data) in
            return data.transactionByHash?.outputs?.data
        }
        let outputDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }
            self?.tableView.reloadData()
        }
        outputDataSource = ABSDKArrayDataSource<BtcTransactionDetailQuery, BtcTransactionDetailQuery.Data.TransactionByHash.Output.Datum>(client: arcblockClient, operation: transactionDetailQuery, dataSourceMapper: outputSourceMapper, dataSourceUpdateHandler: outputDataSourceUpdateHandler)
        outputDataSource.observe()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TransactionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return inputDataSource.numberOfSections() + outputDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfSectionsForInputs = inputDataSource.numberOfSections()
        if section < numberOfSectionsForInputs {
            return inputDataSource.numberOfRows(section: section)
        }
        else {
            return outputDataSource.numberOfRows(section: section - numberOfSectionsForInputs)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfSectionsForInputs = inputDataSource.numberOfSections()
        if indexPath.section < numberOfSectionsForInputs {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputCell
            let data = inputDataSource.itemForIndexPath(indexPath: indexPath)
            cell.updateInputData(input: data!)
            return cell
        }
        else {
            let dataIndexPath: IndexPath = IndexPath(row: indexPath.row, section: indexPath.section - numberOfSectionsForInputs)
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath) as! OutputCell
            let data = outputDataSource.itemForIndexPath(indexPath: dataIndexPath)
            cell.updateOuputData(output: data!)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let numberOfSectionsForInputs = inputDataSource.numberOfSections()
        if section < numberOfSectionsForInputs {
            return "Inputs"
        }
        else {
            return "Outputs"
        }
    }
}
