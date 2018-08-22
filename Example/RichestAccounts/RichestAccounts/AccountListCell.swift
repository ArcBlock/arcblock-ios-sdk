//
//  AccountListCell.swift
//  RichestAccounts
//
//  Created by Jonathan Lu on 22/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class AccountListCell: ABSDKTableViewCell<RichestAccountsQuery.Data.RichestAccount.Datum>, CellWithNib {
    static var nibName: String? {
        get {
            return "AccountListCell"
        }
    }

    override func updateView(data: RichestAccountsQuery.Data.RichestAccount.Datum) {
        self.textLabel?.text = data.address
        self.detailTextLabel?.text = "Balance: " + String(data.balance!)
    }
}
