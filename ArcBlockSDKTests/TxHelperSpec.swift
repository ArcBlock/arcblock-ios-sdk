// TxHelperSpec.swift
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
//  swiftlint:disable line_length

import Quick
import Nimble
import CryptoSwift
import ArcBlockSDK

class TxHelperSpec: QuickSpec {
    override func spec() {
        describe("decode tx") {
            it("works", closure: {
                let txString = "z31yJQ2TQNnofst5GGktyVpeJdQbN971GD9CsCFE2ff7zeHFdKshsJpJdpfYBaYoPc9m21TxuJW9cZBaFJjbwFxrGqDdbjKq71Q4jBWiXL9NhJ9tD6rBNf3gD1UktUd6m2xBk7Jq7PD6dVdp6Mr1tj5ybDXns3TZRmypSygvg1SjTXxWMyPMrayAPdUQ2Z9vycbdLuqPzgwgqdCTxv1V9WKp7e5bY1mQX"
                TxHelper.decodeTxString(txString: txString)
            })
        }
    }
}
