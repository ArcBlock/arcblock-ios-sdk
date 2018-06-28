//
//  BlockDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 27/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import Apollo

class TransactionListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var inputOutputLabel: UILabel!

    public func updateTransactionData(transaction: ListTransactionsQuery.Data.Transaction) {
        hashLabel.text = transaction.hash
        inputOutputLabel.text = String(transaction.numberInputs) + " inputs " + String(transaction.numberOutputs) + " outputs " + String(transaction.total) + " BTC"
    }
}

class TransactionListViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    var apolloClient: ApolloClient!

    var transactionList: [ListTransactionsQuery.Data.Transaction?]? = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        apolloClient = appDelegate.apolloClient
        
        apolloClient.fetch(query: ListTransactionsQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.transactionList = result?.data?.transactions
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TransactionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionListCell
        let transaction = transactionList![indexPath.row]!
        cell.updateTransactionData(transaction: transaction)
        return cell
    }
}

extension TransactionListViewController: UITableViewDelegate {

}
