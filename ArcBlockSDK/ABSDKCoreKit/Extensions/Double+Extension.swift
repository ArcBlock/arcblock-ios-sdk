//
//  Double+Extension.swift
//  ArcBlockSDK
//
//  Created by David Yu on 2021/11/23.
//

import Foundation
import BigInt

public extension Double {
    /// 格式化法币展示 保留2位小数 如 1000.2345 -> 1,000.23
    var formatCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.roundingMode = .floor
        return formatter.string(from: NSDecimalNumber(floatLiteral: self)) ?? "0"
    }
    
    /// 将double格式化成余额展示(这里的double非BigUInt格式) 如: 12.121234543546 -> 12.121234  10000 -> 10,000
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func formatAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = BigUInt.MinFormattingDecimals
        formatter.roundingMode = .floor
        return formatter.string(from: NSNumber(floatLiteral: self)) ?? "0"
    }
}
