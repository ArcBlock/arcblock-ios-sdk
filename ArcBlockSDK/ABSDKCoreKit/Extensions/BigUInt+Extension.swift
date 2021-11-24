// BigUInt+Extension.swift
//
// Copyright (c) 2017-present ArcBlock Foundation Ltd <https://www.arcblock.io/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation
import web3swift
import BigInt

public extension BigUInt {
    static var MinFormattingDecimals: Int = 6
    
    /// 格式化余额展示
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func toAmountString(decimals: Int? = 18, formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> String {
        let realDecimals = decimals ?? 18
        var realFormattingDecimals = formattingDecimals
        if realFormattingDecimals > Self.MinFormattingDecimals {
            realFormattingDecimals = Self.MinFormattingDecimals
        }
        let amountStr = Web3.Utils.formatToPrecision(self, numberDecimals: realDecimals, formattingDecimals: realFormattingDecimals, decimalSeparator: ".", fallbackToScientific: false) ?? "0"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = realFormattingDecimals
        formatter.roundingMode = .floor
        return formatter.string(from: NSDecimalNumber(string: amountStr)) ?? "0"
    }
    
    func toAmountFormattedString(decimals: Int? = 18) -> String {
        if self >= "1".toBigUInt(decimals: decimals) {
            return self.toAmountString(decimals: decimals, formattingDecimals: 2)
        } else {
            return self.toAmountString(decimals: decimals, formattingDecimals: 8)
        }
    }
    
    /// 格式化发送金额
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func toSendString(decimals: Int? = 18, formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> String {
        let realDecimals = decimals ?? 18
        var realFormattingDecimals = formattingDecimals
        if realFormattingDecimals > Self.MinFormattingDecimals {
            realFormattingDecimals = Self.MinFormattingDecimals
        }
        let amountStr = Web3.Utils.formatToPrecision(self, numberDecimals: realDecimals, formattingDecimals: realFormattingDecimals, decimalSeparator: ".", fallbackToScientific: false) ?? "0"
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = realFormattingDecimals
        formatter.roundingMode = .floor
        return formatter.string(from: NSDecimalNumber(string: amountStr)) ?? "0"
    }
    
    // TODO: - 待废弃
    func toAmountDouble(decimals: Int? = 18, formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> Double {
        let balance = self.toAmountString(decimals: decimals, formattingDecimals: formattingDecimals)
        return Double(balance) ?? 0.0
    }
    
    // 转化为展示用的x Gwei
    func toGasPriceInt() -> Int? {
        if let value = Web3.Utils.formatToEthereumUnits(self, toUnits: .Gwei, decimals: 0) {
            return Int(value)
        }
        return nil
    }
}
