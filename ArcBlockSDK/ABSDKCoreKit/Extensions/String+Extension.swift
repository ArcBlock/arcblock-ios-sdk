// String+Extension.swift
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
import UIKit
import BigInt
import web3swift

public extension String {
    
    func isMatchRegex(decimals: Int? = 18) -> Bool {
        guard !self.isEmpty,
              self != "." else {
                  return false
              }
        
        let realDecimal = decimals ?? 18
        let reg = "^[0-9]{0,18}+(\\.[0-9]{0,\(realDecimal)})?"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if pre.evaluate(with: self) {
            return true
        } else {
            return false
        }
    }
    
    func isValidDigital(decimals: Int? = 18) -> Bool {
        let isMatch = isMatchRegex(decimals: decimals)
        let canBeBigUInt = Web3.Utils.parseToBigUInt(self, decimals: decimals ?? 18) != nil
        
        return isMatch && canBeBigUInt
    }
    
    func isValidAmount(decimal: Int? = 18) -> Bool {
        let realDecimal = min(6, decimal ?? 18)
        
        if !isValidDigital(decimals: realDecimal) {
            return false
        }
        
        return true
    }
    
    func isValidGasPrice() -> Bool {
        if !isValidDigital(decimals: 9) {
            return false
        }
        
        return true
    }
    
    func isValidGasLimit() -> Bool {
        guard let intValue = Int(self) else {
            return false
        }
        
        return intValue >= 21000
    }
    
    func toBigUInt(decimals: Int? = 18) -> BigUInt {
        return Web3.Utils.parseToBigUInt(self, decimals: decimals ?? 18) ?? BigUInt(0)
    }
    
    /// 将解析完成的BigUInt格式化成余额展示
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func toAmountString(formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> String {
        guard !isEmpty else {
            return "0"
        }
        let realFormattingDecimals = min(formattingDecimals, BigUInt.MinFormattingDecimals)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = realFormattingDecimals
        formatter.roundingMode = .floor
        return formatter.string(from: NSDecimalNumber(string: self)) ?? "0"
    }
    
    /// 将未解析的BigUInt格式化成余额展示
    ///
    /// - Parameters:
    ///   - formattingDecimals: 保留的小数位 最终取Min(6, formattingDecimals)
    func toAmountString(decimals: Int? = 18, formattingDecimals: Int = BigUInt.MinFormattingDecimals) -> String {
        guard let balance = Web3.Utils.parseToBigUInt(self, decimals: 0) else {
            return "0"
        }
        return balance.toAmountString(decimals: decimals, formattingDecimals: formattingDecimals)
    }
}
