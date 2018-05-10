//
//  ABSDKObjectDataSourceSpec.swift
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 8/5/2018.
//

// swiftlint:disable function_body_length

import Quick
import Nimble

class ABSDKObjectDataSourceSpec: QuickSpec {
    override func spec() {
        describe("data source") {
            let collection = "objectDataSourceTest"
            let key = "key"
            let viewModel = ["_id": key, "name": "John Appleseed", "avatar": "http://example.com", "action": "Message"]
            var dataSource: ABSDKObjectDataSource?
            var observation: NSKeyValueObservation?
            var dataSourceUpdated: Bool?
            var label: UILabel?
            var imageView: UIImageViewMock?
            var button: UIButton?
            var view: UIView?
            let mockImage = UIImage.init()

            beforeSuite {
                label = UILabel.init()
                label?.bind("text", objectKey: "name")
                imageView = UIImageViewMock.init(mockURL: viewModel["avatar"], image: mockImage)
                imageView?.bind("imageUrl", objectKey: "avatar")
                button = UIButton.init()
                button?.bind("title", objectKey: "action")
                view = UIView.init()
                view?.addSubview(label!)
                view?.addSubview(imageView!)
                view?.addSubview(button!)

                dataSource = ABSDKObjectDataSource(collection: collection, key: key)
                observation = dataSource?.observe(\.updated, options: NSKeyValueObservingOptions.new, changeHandler: { (_, _) in
                    dataSourceUpdated = true
                    view?.update(with: dataSource?.fetchObject())
                })
            }

            describe("data change", {
                beforeEach {
                    ABSDKDataStore.sharedInstance().setupDataStore(nil)
                    ABSDKDataStore.sharedInstance().removeObject(forKey: key, inCollection: collection, completionBlock: nil)
                    dataSourceUpdated = false
                    view?.update(with: nil)
                }

                context("in correct collection and key", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(viewModel, forKey: key, inCollection: collection, completionBlock: nil)
                    }

                    it("get correct value, view update correct, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource?.fetchObject() as? [String: String]).toEventually(equal(viewModel))
                        expect(label?.text).to(equal(viewModel["name"]))
                        expect(button?.title(for: UIControlState.normal)).to(equal(viewModel["action"]))
                        expect(imageView?.image).to(equal(mockImage))
                    })
                })

                context("in wrong collection", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(viewModel, forKey: key, inCollection: "wrongCollection", completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                        expect(label?.text).to(beNil())
                        expect(button?.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView?.image).to(beNil())
                    })
                })

                context("in wrong key", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(viewModel, forKey: "wrongKey", inCollection: collection, completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                        expect(label?.text).to(beNil())
                        expect(button?.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView?.image).to(beNil())
                    })
                })

                context("in wrong key and wrong collection", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(viewModel, forKey: "wrongKey", inCollection: "wrong collection", completionBlock: nil)
                    }

                    it("get nil value, view empty, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                        expect(label?.text).to(beNil())
                        expect(button?.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView?.image).to(beNil())
                    })
                })

                context("data store quitted", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().quitDataStore()
                    }

                    it("get nil value, view empty, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                        expect(label?.text).to(beNil())
                        expect(button?.title(for: UIControlState.normal)).to(beNil())
                        expect(imageView?.image).to(beNil())
                    })
                })
            })

            afterSuite {
                observation?.invalidate()
            }
        }
    }
}
