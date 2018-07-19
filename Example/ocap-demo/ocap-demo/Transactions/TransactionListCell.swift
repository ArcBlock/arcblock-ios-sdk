//
//  TransactionListCell.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 19/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import Apollo

class TransactionListCell: UITableViewCell {
    @IBOutlet weak var hashLabel: UILabel!

    public func updateTransactionData<Data: GraphQLSelectionSet>(transaction: Data) {
        hashLabel.text = transaction.resultMap["hash"] as! String
    }
}
