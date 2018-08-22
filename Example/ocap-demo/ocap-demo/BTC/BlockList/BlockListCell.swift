//
//  BlockListCell.swift
//  ocap-demo
//
//  Created by Jonathan Lu on 20/8/2018.
//  Copyright © 2018 ArcBlock. All rights reserved.
//

import UIKit
import ArcBlockSDK

struct TimeConverter {
    public var dateStyle: DateFormatter.Style = .short {
        didSet {
            outputDateFormatter.dateStyle = dateStyle
        }
    }

    public var timeStyle: DateFormatter.Style = .short {
        didSet {
            outputDateFormatter.timeStyle = timeStyle
        }
    }

    let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        return formatter
    }()

    let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()

    func convertTime(time: String) -> String {
        let date: Date = inputDateFormatter.date(from: time)!
        return outputDateFormatter.string(from: date)
    }
}

class BlockListCell: ABSDKTableViewCell<ListBtcBlocksQuery.Data.BlocksByHeight.Datum>, CellWithNib {
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    fileprivate static let timeConverter: TimeConverter = TimeConverter()

    static var nibName: String? {
        get {
            return "BlockListCell"
        }
    }

    override func awakeFromNib() {
        self.accessoryType = .disclosureIndicator
    }

    override func updateView(data: ListBtcBlocksQuery.Data.BlocksByHeight.Datum) {
        heightLabel.text = "Block Height: " + String(data.height)
        transactionLabel.text = String(data.numberTxs) + " txs " + String(data.total) + " BTC"
        timeLabel.text = type(of: self).timeConverter.convertTime(time: data.time)
    }
}
