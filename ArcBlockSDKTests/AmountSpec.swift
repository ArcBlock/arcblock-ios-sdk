// BigUIntSpec.swift
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


import Quick
import ArcBlockSDK
import Nimble
import BigInt

class AmountSpec: QuickSpec {

    override func spec() {
        describe("BigUInt To Amount") {
            it("works", closure: {
                expect(BigUInt("1123456789123456789").toAmountString()).to(equal("1.123456"))
                expect(BigUInt("1123456789000000000").toAmountString()).to(equal("1.123456"))
                expect(BigUInt("1123400000000000000").toAmountString()).to(equal("1.1234"))
                expect(BigUInt("1000000000000000000").toAmountString()).to(equal("1"))
                expect(BigUInt("1000000000000000000000").toAmountString()).to(equal("1,000"))
                expect(BigUInt("123456").toAmountString(decimals: 5)).to(equal("1.23456"))
                expect(BigUInt("100023456").toAmountString(decimals: 5)).to(equal("1,000.23456"))
                expect(BigUInt("100023450").toAmountString(decimals: 5)).to(equal("1,000.2345"))
                expect(BigUInt("").toAmountString(decimals: 5)).to(equal("0"))
            })
        }
        
        describe("BigUInt To Send") {
            it("works", closure: {
                expect(BigUInt("1123456789123456789").toSendString()).to(equal("1.123456"))
                expect(BigUInt("1123456789000000000").toSendString()).to(equal("1.123456"))
                expect(BigUInt("1123456789000000000000").toSendString()).to(equal("1123.456789"))
                expect(BigUInt("1123400000000000000").toSendString()).to(equal("1.1234"))
                expect(BigUInt("1000000000000000000").toSendString()).to(equal("1"))
                expect(BigUInt("1000000000000000000000").toSendString()).to(equal("1000"))
                expect(BigUInt("123456").toSendString(decimals: 5)).to(equal("1.23456"))
                expect(BigUInt("100023456").toSendString(decimals: 5)).to(equal("1000.23456"))
                expect(BigUInt("100023450").toSendString(decimals: 5)).to(equal("1000.2345"))
                expect(BigUInt("").toSendString(decimals: 5)).to(equal("0"))
            })
        }
        
        describe("BigUInt String To Amount") {
            it("works", closure: {
                expect("1123456789000000000".toAmountString(decimals: 18)).to(equal("1.123456"))
                expect("1123400000000000000".toAmountString(decimals: 18)).to(equal("1.1234"))
                expect("1000000000000000000".toAmountString(decimals: 18)).to(equal("1"))
                expect("1000000000000000000000".toAmountString(decimals: 18)).to(equal("1,000"))
                expect("123456".toAmountString(decimals: 5)).to(equal("1.23456"))
                expect("100023456".toAmountString(decimals: 5)).to(equal("1,000.23456"))
                expect("100023450".toAmountString(decimals: 5)).to(equal("1,000.2345"))
                expect("".toAmountString(decimals: 5)).to(equal("0"))
            })
        }
        
        describe("String To Amount") {
            it("works", closure: {
                expect("12.00".formatAmount()).to(equal("12"))
                expect("12.121234543546".formatAmount()).to(equal("12.121234"))
                expect("12.1212345435460000".formatAmount()).to(equal("12.121234"))
                expect("1000.2345".formatAmount()).to(equal("1,000.2345"))
                expect("10.0".formatAmount()).to(equal("10"))
                expect("0.123456789".formatAmount()).to(equal("0.123456"))
                expect(".1".formatAmount()).to(equal("0.1"))
                expect("0.0".formatAmount()).to(equal("0"))
                expect(".".formatAmount()).to(equal("0"))
                expect("".formatAmount()).to(equal("0"))
            })
        }
        
        describe("Double To Amount") {
            it("works", closure: {
                expect(12.00.formatAmount()).to(equal("12"))
                expect(12.121234543546.formatAmount()).to(equal("12.121234"))
                expect(12.1212345435460000.formatAmount()).to(equal("12.121234"))
                expect(1000.2345.formatAmount()).to(equal("1,000.2345"))
                expect(10.0.formatAmount()).to(equal("10"))
                expect(0.123456789.formatAmount()).to(equal("0.123456"))
                expect(0.0.formatAmount()).to(equal("0"))
                expect(10000.formatAmount()).to(equal("10,000"))
            })
        }
        
        describe("Format currency") {
            it("works", closure: {
                expect(12.2233.formatCurrency).to(equal("12.22"))
                expect(66.0023.formatCurrency).to(equal("66.00"))
            })
        }
        
        describe("BigUInt extension") {
            it("works", closure: {
                expect(BigUInt("3000000000").toGasPriceInt()).to(equal(3))
                expect(BigUInt("23000000000").toGasPriceInt()).to(equal(23))
            })
        }
    }

}
