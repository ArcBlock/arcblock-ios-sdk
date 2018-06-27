//
//  ViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 26/6/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import Apollo

class BlockListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!

    public func updateBlockData(block: ListBlocksQuery.Data.Block) {
        hashLabel.text = block.hash
        transactionLabel.text = String(block.numberTxs) + " txs " + String(block.total) + " BTC"
    }
}

class BlockListViewController: UIViewController {

    @IBOutlet weak var tableView:UITableView!
    var apolloClient: ApolloClient!

    var blockList: [ListBlocksQuery.Data.Block?]? = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        apolloClient = appDelegate.apolloClient

        apolloClient.fetch(query: ListBlocksQuery(), cachePolicy: .returnCacheDataAndFetch) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.blockList = result?.data?.blocks
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension BlockListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockList?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BlockListCell
        let block = blockList![indexPath.row]!
        cell.updateBlockData(block: block)
        return cell
    }
}

extension BlockListViewController: UITableViewDelegate {
    
}

