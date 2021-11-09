// InputSpec.swift
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
import Nimble
import ArcBlockSDK

class InputSpec: QuickSpec {
    override func spec() {
        describe("Amount input") {
            it("works", closure: {
                expect("".isValidAmount(decimal: 18)).to(equal(false))
                expect(".".isValidAmount(decimal: 18)).to(equal(false))
                expect("11.".isValidAmount(decimal: 18)).to(equal(false))
                expect(".1".isValidAmount(decimal: 18)).to(equal(false))
                expect("11.0".isValidAmount(decimal: 18)).to(equal(true))
                expect("11".isValidAmount(decimal: 18)).to(equal(true))
                
                expect("111.123456".isValidAmount(decimal: 18)).to(equal(true))
                expect("1234.1234567".isValidAmount(decimal: 18)).to(equal(false))
                
                expect("12345.1234".isValidAmount(decimal: 4)).to(equal(true))
                expect("123456.12345".isValidAmount(decimal: 4)).to(equal(false))
            })
        }
        
        describe("Gas Price input") {
            it("works", closure: {
                expect("".isValidGasPrice()).to(equal(false))
                
                expect("111.123456789".isValidGasPrice()).to(equal(true))
                expect("1234.1234567891".isValidGasPrice()).to(equal(false))
            })
        }
        
        describe("Gas Limit input") {
            it("works", closure: {
                expect("0".isValidGasLimit()).to(equal(false))
                expect("21000.0".isValidGasLimit()).to(equal(false))
                expect("20000".isValidGasLimit()).to(equal(false))
                expect("80000".isValidGasLimit()).to(equal(true))
            })
        }
    }
}
