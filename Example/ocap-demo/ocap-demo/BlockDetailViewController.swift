//
//  BlockDetailViewController.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 4/7/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

class BlockDetailView: UIView {
    @IBOutlet weak var hashLabel: UILabel!

    public func updateBlockData(block: BlockDetailQuery.Data.BlockByHeight) {
        hashLabel.text = block.hash
    }
}

class BlockDetailViewController: UIViewController {

    public var height: Int = 0
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKObjectDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight>!

    @IBOutlet weak var detailView:BlockDetailView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: ObjectDataSourceMapper<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight> = { (data) in
            return data.blockByHeight
        }
        let viewUpdateHandler: ViewUpdateHandler<BlockDetailQuery.Data.BlockByHeight> = { (view, data) in
            if let blockDetailView = view as? BlockDetailView {
                blockDetailView.updateBlockData(block: data)
            }
        }
        dataSource = ABSDKObjectDataSource<BlockDetailQuery, BlockDetailQuery.Data.BlockByHeight>(client: arcblockClient, query: BlockDetailQuery(height: height), dataSourceMapper: dataSourceMapper, viewUpdateHandler: viewUpdateHandler)

        dataSource.view = detailView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
