//
//  ETHBlockListViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 2/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class ETHBlockListViewController: UIViewController {

    @IBOutlet weak var loadingFooter: UIView!
    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKPagedArrayDataSource<ListEthBlocksQuery, ListEthBlocksQuery.Data.BlocksByHeight.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.ethClient

        let dataSourceMapper: ArrayDataSourceMapper<ListEthBlocksQuery, ListEthBlocksQuery.Data.BlocksByHeight.Datum> = { (data) in
            return data.blocksByHeight?.data
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                let alert = UIAlertController.init(title: "Oops", message: err?.localizedDescription , preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }

            self?.tableView.reloadData();
            if let hasMore: Bool = self?.dataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let pageMapper: PageMapper<ListEthBlocksQuery> = { (data) in
            return (data.blocksByHeight?.page)!
        }
        let checker: ArrayDataKeyEqualChecker<ListEthBlocksQuery.Data.BlocksByHeight.Datum> = { (object1, object2) in
            if (object1 != nil) && (object2 != nil) {
                return object1?.height == object2?.height
            }
            return false
        }
        dataSource = ABSDKPagedArrayDataSource<ListEthBlocksQuery, ListEthBlocksQuery.Data.BlocksByHeight.Datum>(client: arcblockClient, query: ListEthBlocksQuery(fromHeight: 0), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler, arrayDataKeyEqualChecker: checker, pageMapper: pageMapper)
        dataSource.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ETHBlockListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ETHBlockList", for: indexPath)
        let data = dataSource.itemForIndexPath(indexPath: indexPath)
        if let block: ListEthBlocksQuery.Data.BlocksByHeight.Datum = data {
            cell.textLabel?.text = "Block Height: " + String(block.height)
            cell.detailTextLabel?.text = block.hash
        }
        return cell
    }
}

extension ETHBlockListViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            dataSource.loadMore()
        }
    }
}
