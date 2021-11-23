//
//  Double+Extension.swift
//  ArcBlockSDK
//
//  Created by David Yu on 2021/11/23.
//

import Foundation
import BigInt

public extension Double {
    /// 将解析完成的BigUInt格式化成余额展示
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
