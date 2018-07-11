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

    public func updateTransactionData(transaction: TransactionDetailQuery.Data.TransactionByHash) {
        totalLabel.text = String(transaction.total)
        numberOfInputsLabel.text = String(transaction.numberInputs)
        numberOfOutputsLabel.text = String(transaction.numberOutputs)
        feesLabel.text = String(transaction.fees)
    }
}

class InputCell: UITableViewCell {

    public func updateInputData(input: TransactionDetailQuery.Data.TransactionByHash.Input.Datum) {
        self.textLabel?.text = input.account
        self.detailTextLabel?.text = String(input.value)
    }
}

class OutputCell: UITableViewCell {
    public func updateOuputData(output: TransactionDetailQuery.Data.TransactionByHash.Output.Datum) {
        self.textLabel?.text = output.account
        self.detailTextLabel?.text = String(output.value)
    }
}

class TransactionViewController: UIViewController {
    public var txHash: String? = nil

    var arcblockClient: ABSDKClient!
    var transactionDetailQuery: TransactionDetailQuery!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var detailView: TransactionDetailView!

    var detailDataSource: ABSDKObjectDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash>!
    var inputDataSource: ABSDKArrayViewDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum>!
    var outputDataSource: ABSDKArrayViewDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Output.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = txHash

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        transactionDetailQuery = TransactionDetailQuery(hash: txHash!)

        let detailSourceMapper: ObjectDataSourceMapper<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash> = { (data) in
            return data.transactionByHash
        }
        let viewUpdateHandler: ViewUpdateHandler<TransactionDetailQuery.Data.TransactionByHash> = { (view, data) in
            if let transactionDetailView = view as? TransactionDetailView {
                transactionDetailView.updateTransactionData(transaction: data)
            }
        }
        detailDataSource = ABSDKObjectDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash>(client: arcblockClient, query: transactionDetailQuery, dataSourceMapper: detailSourceMapper, viewUpdateHandler: viewUpdateHandler)
        detailDataSource.view = detailView

        let inputSourceMapper: ArrayDataSourceMapper<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum> = { (data) in
            return data.transactionByHash?.inputs?.data
        }
        inputDataSource = ABSDKArrayViewDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum>(client: arcblockClient, query: transactionDetailQuery, dataSourceMapper: inputSourceMapper)
        inputDataSource.tableView = tableView

        let outputSourceMapper: ArrayDataSourceMapper<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Output.Datum> = { (data) in
            return data.transactionByHash?.outputs?.data
        }
        outputDataSource = ABSDKArrayViewDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Output.Datum>(client: arcblockClient, query: transactionDetailQuery, dataSourceMapper: outputSourceMapper)
        outputDataSource.tableView = tableView
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
            let data = inputDataSource.dataForIndexPath(indexPath: indexPath)
            cell.updateInputData(input: data!)
            return cell
        }
        else {
            let dataIndexPath: IndexPath = IndexPath(row: indexPath.row, section: indexPath.section - numberOfSectionsForInputs)
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutputCell", for: indexPath) as! OutputCell
            let data = outputDataSource.dataForIndexPath(indexPath: dataIndexPath)
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
