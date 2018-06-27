// ABSDKObjectDataSourceSpec.swift
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

// swiftlint:disable function_body_length

import Quick
import Nimble

class ABSDKObjectDataSourceSpec: QuickSpec {
    override func spec() {
        describe("data source") {
            var datastore: ABSDKDataStore!
            let collection = "objectDataSourceTest"
            let key = "key"
            let model = ["_id": key, "name": "John Appleseed", "avatar": "http://example.com", "action": "Message"]
            let mockImage = UIImage.init()

            var dataSource: ABSDKObjectDataSource!
            var dataSourceUpdated = false
            var label: UILabel!
            var imageView: UIImageViewMock!
            var button: UIButton!
            var view: UIView!

            beforeSuite {
                datastore = ABSDKDataStore.sharedInstance()
                label = UILabel.init()
                label.bind("text", objectKey: "name")
                imageView = UIImageViewMock.init(mockURL: model["avatar"], image: mockImage)
                imageView.bind("imageUrl", objectKey: "avatar")
                button = UIButton.init()
                button.bind("title", objectKey: "action")
                view = UIView.init()
                view.addSubview(label)
                view.addSubview(imageView)
                view.addSubview(button)

                dataSource = ABSDKObjectDataSource(collection: collection, key: key)
                view.observe(dataSource, updatedBlock: {
                    dataSourceUpdated = true
                })
            }

            describe("data change", {
                beforeEach {
                    datastore.setupDataStore(nil)
                    datastore.removeObject(forKey: key, inCollection: collection, completionBlock: nil)
                    dataSourceUpdated = false
                    view.update(withObject: nil)
                }

                context("in correct collection and key", {
                    beforeEach {
                        datastore.setObject(model, forKey: key, inCollection: collection, completionBlock: nil)
                    }

                    it("get correct value, view update correct, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource.fetchObject() as? [String: String]).toEventually(equal(model))
                        expect(label.text).to(equal(model["name"]))
                        expect(button.title(for: UIControlState.normal)).to(equal(model["action"]))
                        expect(imageView.image).to(equal(mockImage))
                    })
                })

                context("in wrong collection", {
                    beforeEach {
                        datastore.setObject(model, forKey: key, inCollection: "wrongCollection", completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource.fetchObject() as? String).toEventually(beNil())
                        expect(label.text).to(beNil())
                        expect(button.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView.image).to(beNil())
                    })
                })

                context("in wrong key", {
                    beforeEach {
                        datastore.setObject(model, forKey: "wrongKey", inCollection: collection, completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource.fetchObject() as? String).toEventually(beNil())
                        expect(label.text).to(beNil())
                        expect(button.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView.image).to(beNil())
                    })
                })

                context("in wrong key and wrong collection", {
                    beforeEach {
                        datastore.setObject(model, forKey: "wrongKey", inCollection: "wrong collection", completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource.fetchObject() as? String).toEventually(beNil())
                        expect(label.text).to(beNil())
                        expect(button.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView.image).to(beNil())
                    })
                })

                context("data store quitted", {
                    beforeEach {
                        datastore.quitDataStore()
                    }

                    it("get nil value, view empty, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource.fetchObject() as? String).toEventually(beNil())
                        expect(label.text).to(beNil())
                        expect(button.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView.image).to(beNil())
                    })
                })
            })
        }
    }
}
