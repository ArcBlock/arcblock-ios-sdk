//
//  ABSDKDataStoreSpec.swift
//  Pods
//
//  Created by Jonathan Lu on 6/5/2018.
//

// swiftlint:disable function_body_length

import Quick
import Nimble

class ABSDKDataStoreSpec: QuickSpec {
    override func spec() {
        var datastore: ABSDKDataStore!
        let registeredCollection = "registeredCollection"
        let nonregisteredCollection = "nonregisteredCollection"
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"
        var observers = [NSKeyValueObservation]()

        beforeSuite {
            datastore = ABSDKDataStore.sharedInstance()
            datastore.registerCollections([registeredCollection])
            datastore.setupDataStore(nil)
        }

        describe("CRUD with registered collection", {
            var hasChange: Bool?
            var willUpdateCalled: Bool?
            var didUpdateCalled: Bool?
            var didRemoveCalled: Bool?

            beforeSuite {
                NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                    hasChange = datastore.hasChange(forKey: key1, inCollection: registeredCollection, notification: notification)
                })

                datastore?.setDataStoreWillUpdateBlockForCollection(registeredCollection, block: { (_, _, object) -> Any? in
                    willUpdateCalled = true
                    return object
                })

                datastore.setDataStoreDidUpdateBlockForCollection(registeredCollection, block: { (_, _, _) in
                    didUpdateCalled = true
                })

                datastore.setDataStoreDidRemoveBlockForCollection(registeredCollection, block: { (_, _) in
                    didRemoveCalled = true
                })
            }

            beforeEach {
                hasChange = false
            }

            it("create", closure: {
                willUpdateCalled = false
                didUpdateCalled = false
                datastore.setObject(value1, forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(equal(value1))
                expect(hasChange).toEventually(beTrue())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beTrue())
            })

            it("update with same value", closure: {
                willUpdateCalled = false
                didUpdateCalled = false
                let oldValue = (datastore.object(forKey: key1, inCollection: registeredCollection) as? String)
                datastore.setObject(oldValue, forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                expect(hasChange).toEventually(beFalse())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beFalse())

            })

            it("update with different value", closure: {
                willUpdateCalled = false
                didUpdateCalled = false
                datastore.setObject(value2, forKey: key1, inCollection: registeredCollection, completionBlock:nil)
                expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(equal(value2))
                expect(hasChange).toEventually(beTrue())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beTrue())
            })

            it("remove", closure: {
                didRemoveCalled = false
                datastore.removeObject(forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(beNil())
                expect(hasChange).toEventually(beTrue())
                expect(didRemoveCalled).toEventually(beTrue())
            })
        })

        describe("CRUD with nonregistered collection", {
            var hasChange: Bool?
            var willUpdateCalled: Bool?
            var didUpdateCalled: Bool?
            var didRemoveCalled: Bool?

            beforeSuite {
                NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                    hasChange = datastore.hasChange(forKey: key2, inCollection: nonregisteredCollection, notification: notification)
                })

                datastore?.setDataStoreWillUpdateBlockForCollection(nonregisteredCollection, block: { (_, _, object) -> Any? in
                    willUpdateCalled = true
                    return object
                })

                datastore.setDataStoreDidUpdateBlockForCollection(nonregisteredCollection, block: { (_, _, _) in
                    didUpdateCalled = true
                })

                datastore.setDataStoreDidRemoveBlockForCollection(nonregisteredCollection, block: { (_, _) in
                    didRemoveCalled = true
                })
            }

            beforeEach {
                hasChange = false
            }

            it("create") {
                willUpdateCalled = false
                didUpdateCalled = false
                datastore.setObject(value2, forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(equal(value2))
                expect(hasChange).toEventually(beTrue())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beTrue())
            }

            it("update with same value", closure: {
                willUpdateCalled = false
                didUpdateCalled = false
                let oldValue = (datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)
                datastore.setObject(oldValue, forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                expect(hasChange).toEventually(beFalse())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beFalse())
            })

            it("update with different value", closure: {
                willUpdateCalled = false
                didUpdateCalled = false
                datastore.setObject(value1, forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(equal(value1))
                expect(hasChange).toEventually(beTrue())
                expect(willUpdateCalled).toEventually(beTrue())
                expect(didUpdateCalled).toEventually(beTrue())
            })

            it("remove", closure: {
                didRemoveCalled = false
                waitUntil(action: { (done) in
                    datastore.removeObject(forKey: key2, inCollection: nonregisteredCollection, completionBlock: {

                        done()
                    })
                })
                expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(beNil())
                expect(hasChange).toEventually(beTrue())
                expect(didRemoveCalled).toEventually(beTrue())
            })
        })

        describe("lifecycle", {
            var dataStoreReadyChanged: Bool?

            beforeSuite {
                observers.append(datastore.observe(\.dataStoreReady, changeHandler: { (_, _) in
                    dataStoreReadyChanged = true
                }))
            }

            beforeEach {
                dataStoreReadyChanged = false
            }

            it("setup") {
                datastore.setupDataStore(nil)
                expect(datastore.dataStoreReady).to(beTrue())
                expect(dataStoreReadyChanged).toEventually(beTrue())
            }

            it("quit") {
                datastore.quitDataStore()
                expect(datastore.dataStoreReady).to(beFalse())
                expect(dataStoreReadyChanged).toEventually(beTrue())
            }
        })

        afterSuite {
            datastore.quitDataStore()
            datastore = nil
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let dbFilePath = paths[0].appending("/tmp.sqlite")
            try? FileManager.default.removeItem(atPath: dbFilePath)
        }
    }
}
