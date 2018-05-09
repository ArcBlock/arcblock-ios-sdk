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
            let value = "value"
            var dataSource: ABSDKObjectDataSource?
            var observation: NSKeyValueObservation?
            var dataSourceUpdated: Bool?

            beforeSuite {
                dataSource = ABSDKObjectDataSource(collection: collection, key: key)
                observation = dataSource?.observe(\.updated, options: NSKeyValueObservingOptions.new, changeHandler: { (_, _) in
                    dataSourceUpdated = true
                })
            }

            describe("data change", {
                beforeEach {
                    ABSDKDataStore.sharedInstance().setupDataStore(nil)
                    ABSDKDataStore.sharedInstance().removeObject(forKey: key, inCollection: collection, completionBlock: nil)
                    dataSourceUpdated = false
                }

                context("in correct collection and key", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(value, forKey: key, inCollection: collection, completionBlock: nil)
                    }

                    it("get correct value, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource?.fetchObject() as? String).toEventually(equal(value))
                    })
                })

                context("in wrong collection", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(value, forKey: key, inCollection: "wrongCollection", completionBlock: nil)
                    }

                    it("get nil value, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                    })
                })

                context("in wrong key", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(value, forKey: "wrongKey", inCollection: collection, completionBlock: nil)
                    }

                    it("get nil value, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                    })
                })

                context("in wrong key and wrong collection", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().setObject(value, forKey: "wrongKey", inCollection: "wrong collection", completionBlock: nil)
                    }

                    it("get nil value, no recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beFalse())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                    })
                })

                context("data store quitted", {
                    beforeEach {
                        ABSDKDataStore.sharedInstance().quitDataStore()
                    }

                    it("get nil value, recieve update", closure: {
                        expect(dataSourceUpdated).toEventually(beTrue())
                        expect(dataSource?.fetchObject() as? String).toEventually(beNil())
                    })
                })
            })

            afterSuite {
                observation?.invalidate()
            }
        }
    }
}
