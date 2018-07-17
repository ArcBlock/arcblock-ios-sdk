//
//  RichestAccountsViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 17/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class AccountListCell: UITableViewCell {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    public func updateAccountData(account: RichestAccountsQuery.Data.RichestAccount.Datum) {
        addressLabel.text = account.address
        balanceLabel.text = "Balance: " + String(account.balance!) + " BTC"
    }
}

class RichestAccountsViewController: UIViewController {
    @IBOutlet weak var loadingFooter: UIView!
    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKArrayViewPagedDataSource<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: ArrayDataSourceMapper<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum> = { (data) in
            return data.richestAccounts?.data
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] in
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.dataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let pageMapper: PageMapper<RichestAccountsQuery> = { (data) in
            return (data.richestAccounts?.page)!
        }
        dataSource = ABSDKArrayViewPagedDataSource<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum>(client: arcblockClient, query: RichestAccountsQuery(), dataSourceMapper: dataSourceMapper, pageMapper: pageMapper, dataSourceUpdateHandler: dataSourceUpdateHandler)
        dataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RichestAccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountListCell", for: indexPath) as! AccountListCell
        let data = dataSource.itemForIndexPath(indexPath: indexPath)
        cell.updateAccountData(account: data!)
        return cell
    }
}

extension RichestAccountsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            dataSource.loadMore()
        }
    }
}
