//
//  Double+Extension.swift
//  ArcBlockSDK
//
//  Created by David Yu on 2021/11/23.
//

import Foundation
import BigInt

public extension Double {
    /// 将double格式化成余额展示(这里的double非BigUInt格式) 如: 12.121234543546 -> 12.121234  10000 -> 10,000
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func toAmountString(formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> String {
        let realFormattingDecimals = min(formattingDecimals, BigUInt.MinFormattingDecimals)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = realFormattingDecimals
        formatter.roundingMode = .floor
        return formatter.string(from: NSNumber(floatLiteral: self)) ?? "0"
    }
}
