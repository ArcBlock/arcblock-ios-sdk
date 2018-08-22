//
//  ViewController.swift
//  RichestAccounts
//
//  Created by Jonathan Lu on 22/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class ViewController: ABSDKTableViewController<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum, AccountListCell> {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func configDataSource() {
        // config the parameters for initiating data source

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        client = appDelegate.arcblockClient

        dataSourceMapper = { (data) in
            return data.richestAccounts?.data
        }
        pageMapper = { (data) in
            return (data.richestAccounts?.page)!
        }
        query = RichestAccountsQuery()
    }
}
