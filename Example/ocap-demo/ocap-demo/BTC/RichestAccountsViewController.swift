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

    public func updateAccountData(account: BtcRichestAccountsQuery.Data.RichestAccount.Datum) {
        addressLabel.text = account.address
        balanceLabel.text = "Balance: " + String(account.balance!) + " BTC"
    }
}

class RichestAccountsViewController: UIViewController {
    @IBOutlet weak var loadingFooter: UIView!
    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKPagedArrayDataSource<BtcRichestAccountsQuery, BtcRichestAccountsQuery.Data.RichestAccount.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.btcClient

        let dataSourceMapper: ArrayDataSourceMapper<BtcRichestAccountsQuery, BtcRichestAccountsQuery.Data.RichestAccount.Datum> = { (data) in
            return data.richestAccounts?.data
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                let alert = UIAlertController.init(title: "Oops", message: err?.localizedDescription , preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.dataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let pageMapper: PageMapper<BtcRichestAccountsQuery> = { (data) in
            return (data.richestAccounts?.page)!
        }
        dataSource = ABSDKPagedArrayDataSource<BtcRichestAccountsQuery, BtcRichestAccountsQuery.Data.RichestAccount.Datum>(client: arcblockClient, query: BtcRichestAccountsQuery(), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler, pageMapper: pageMapper)
        dataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountDetailSegue" {
            let indexPath: IndexPath = tableView.indexPathForSelectedRow!
            let data: BtcRichestAccountsQuery.Data.RichestAccount.Datum = dataSource.itemForIndexPath(indexPath: indexPath)!
            let destinationViewController: AccountDetailViewController = segue.destination as! AccountDetailViewController
            destinationViewController.address = data.address
            destinationViewController.title = data.address
        }
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
