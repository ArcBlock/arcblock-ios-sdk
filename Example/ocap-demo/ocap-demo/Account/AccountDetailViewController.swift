//
//  AccountDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 18/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class AccountDetailView: UIView {
    @IBOutlet weak var publicKeyLabel: UILabel!
    @IBOutlet weak var scriptTypeLabel: UILabel!

    public func updateAddressData(address: AccountByAddressQuery.Data.AccountByAddress) {
        publicKeyLabel.text = address.pubKey
        scriptTypeLabel.text = address.scriptType
    }
}

class AccountDetailViewController: UIViewController {
    var address: String!

    var arcblockClient: ABSDKClient!

    var detailDataSource: ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>!

    var receivedTxsViewController: TxsReceivedViewController!
    var sentTxsViewController: TxsSentViewController!

    @IBOutlet weak var detailView: AccountDetailView!
    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let detailSourceMapper: ObjectDataSourceMapper<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress> = { (data) in
            return data.accountByAddress
        }
        let detailDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }
            self?.detailView.updateAddressData(address: (self?.detailDataSource.getObject())!)
        }
        detailDataSource = ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>(client: arcblockClient, query: AccountByAddressQuery(address: address), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        receivedTxsViewController = storyboard.instantiateViewController(withIdentifier: "TxsReceivedViewController") as! TxsReceivedViewController
        receivedTxsViewController.address = address

        sentTxsViewController = storyboard.instantiateViewController(withIdentifier: "TxsSentViewController") as! TxsSentViewController
        sentTxsViewController.address = address
        sentTxsViewController.view.frame = contentView.bounds

        showChildViewController(viewContoller: receivedTxsViewController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showChildViewController(viewContoller: UIViewController) {
        addChildViewController(viewContoller)
        viewContoller.view.frame = contentView.bounds
        contentView.addSubview(viewContoller.view)
        viewContoller.didMove(toParentViewController: self)
    }

    func removeChildViewController(viewContoller: UIViewController) {
        viewContoller.willMove(toParentViewController: nil)
        viewContoller.removeFromParentViewController()
        viewContoller.view.removeFromSuperview()
    }

    @IBAction func segmentControlDidChanged(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            removeChildViewController(viewContoller: sentTxsViewController)
            showChildViewController(viewContoller: receivedTxsViewController)
            break
        case 1:
            removeChildViewController(viewContoller: receivedTxsViewController)
            showChildViewController(viewContoller: sentTxsViewController)
            break
        default:
            break
        }
    }

}
