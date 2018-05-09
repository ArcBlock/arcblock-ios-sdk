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
    enum Collection: String {
        case registered, temporary
    }

    override func spec() {
        describe("data store") {
            var datastore: ABSDKDataStore!
            let key = "key"
            let initialValue = "initialValue"
            let alternativeValue = "alternativeValue"

            beforeSuite {
                datastore = ABSDKDataStore.sharedInstance()
                datastore.registerCollections([Collection.registered.rawValue])
                datastore.setupDataStore(nil)
            }

            describe("CRUD", {
                struct Flags: Equatable {
                    var valueChanged: Bool?
                    var willUpdateBlockCalled: Bool?
                    var didUpdateBlockCalled: Bool?
                    var didRemovedBlockCalled: Bool?

                    mutating func reset() {
                        valueChanged = false
                        willUpdateBlockCalled = false
                        didUpdateBlockCalled = false
                        didRemovedBlockCalled = false
                    }
                }

                var flagsForRegisteredCollection = Flags()
                var flagsForTemporaryCollection = Flags()
                var expectedFlagsForRegisteredCollection = Flags()
                var expectedFlagsForTemporaryCollection = Flags()
                var observers = [NSObjectProtocol]()

                beforeSuite {
                    // observe data store modified event
                    var notificationObserver = NotificationCenter.default.addObserver(
                        forName: Notification.Name.ABSDKDataStoreModified,
                        object: nil,
                        queue: nil,
                        using: { (notification) in
                            flagsForRegisteredCollection.valueChanged = datastore.hasChange(forKey: key, inCollection: Collection.registered.rawValue, notification: notification)
                        }
                    )
                    observers.append(notificationObserver)

                    notificationObserver = NotificationCenter.default.addObserver(
                        forName: Notification.Name.ABSDKDataStoreModified,
                        object: nil,
                        queue: nil,
                        using: { (notification) in
                            flagsForTemporaryCollection.valueChanged = datastore.hasChange(forKey: key, inCollection: Collection.temporary.rawValue, notification: notification)
                        }
                    )
                    observers.append(notificationObserver)

                    // add will update hooks
                    datastore.setDataStoreWillUpdateBlockForCollection(
                        Collection.registered.rawValue,
                        block: { (_, _, object) -> Any? in
                            flagsForRegisteredCollection.willUpdateBlockCalled = true
                            return object
                        }
                    )

                    datastore.setDataStoreWillUpdateBlockForCollection(
                        Collection.temporary.rawValue,
                        block: { (_, _, object) -> Any? in
                            flagsForTemporaryCollection.willUpdateBlockCalled = true
                            return object
                        }
                    )

                    // add did update hooks
                    datastore.setDataStoreDidUpdateBlockForCollection(
                        Collection.registered.rawValue,
                        block: { (_, _, _) in
                            flagsForRegisteredCollection.didUpdateBlockCalled = true
                        }
                    )

                    datastore.setDataStoreDidUpdateBlockForCollection(
                        Collection.temporary.rawValue,
                        block: { (_, _, _) in
                            flagsForTemporaryCollection.didUpdateBlockCalled = true
                        }
                    )

                    // add did remove hooks
                    datastore.setDataStoreDidRemoveBlockForCollection(
                        Collection.registered.rawValue,
                        block: { (_, _) in
                            flagsForRegisteredCollection.didRemovedBlockCalled = true
                        }
                    )

                    datastore.setDataStoreDidRemoveBlockForCollection(
                        Collection.temporary.rawValue,
                        block: { (_, _) in
                            flagsForTemporaryCollection.didRemovedBlockCalled = true
                        }
                    )
                }

                beforeEach {
                    flagsForRegisteredCollection.reset()
                    flagsForTemporaryCollection.reset()
                    expectedFlagsForRegisteredCollection.reset()
                    expectedFlagsForTemporaryCollection.reset()
                }

                describe("create", {
                    context("in registered collection", {
                        beforeEach {
                            datastore.setObject(initialValue, forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                        }

                        it("create success, value has changed, will update called, did update called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)).toEventually(equal(initialValue))
                            expectedFlagsForRegisteredCollection.valueChanged = true
                            expectedFlagsForRegisteredCollection.willUpdateBlockCalled = true
                            expectedFlagsForRegisteredCollection.didUpdateBlockCalled = true

                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })

                    context("in temporary collection", {
                        beforeEach {
                            datastore.setObject(initialValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                        }

                        it("create success, value has changed, will update called, did update called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(equal(initialValue))
                            expectedFlagsForTemporaryCollection.valueChanged = true
                            expectedFlagsForTemporaryCollection.willUpdateBlockCalled = true
                            expectedFlagsForTemporaryCollection.didUpdateBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })
                })

                describe("update with same value", {
                    context("in registered collection", {
                        beforeEach {
                            let currentValue = (datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)
                            datastore.setObject(currentValue, forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                        }

                        it("update ignored, value has not changed, will update called, did update not called", closure: {
                            expectedFlagsForRegisteredCollection.willUpdateBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })

                    context("in temporary collection", {
                        beforeEach {
                            let oldValue = (datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)
                            datastore.setObject(oldValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                        }

                        it("update ignored, value has not changed, will update called, did update not called", closure: {
                            expectedFlagsForTemporaryCollection.willUpdateBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })
                })

                describe("update with different value", {
                    context("in registered collection", {
                        beforeEach {
                            datastore.setObject(alternativeValue, forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                        }

                        it("update success, value has changed, will update called, did update called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)).toEventually(equal(alternativeValue))
                            expectedFlagsForRegisteredCollection.valueChanged = true
                            expectedFlagsForRegisteredCollection.willUpdateBlockCalled = true
                            expectedFlagsForRegisteredCollection.didUpdateBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })

                    context("in temporary collection", {
                        beforeEach {
                            datastore.setObject(alternativeValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                        }

                        it("update success, value has changed, will update called, did update called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(equal(alternativeValue))
                            expectedFlagsForTemporaryCollection.valueChanged = true
                            expectedFlagsForTemporaryCollection.willUpdateBlockCalled = true
                            expectedFlagsForTemporaryCollection.didUpdateBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })
                })

                describe("remove", {
                    context("in registered collection", {
                        beforeEach {
                            datastore.removeObject(forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                        }

                        it("remove success, value has changed, did remove called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)).toEventually(beNil())
                            expectedFlagsForRegisteredCollection.valueChanged = true
                            expectedFlagsForRegisteredCollection.didRemovedBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })

                    context("in temporary collection", {
                        beforeEach {
                            datastore.removeObject(forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                        }
                        it("remove success, value has changed, did remove called", closure: {
                            expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(beNil())
                            expectedFlagsForTemporaryCollection.valueChanged = true
                            expectedFlagsForTemporaryCollection.didRemovedBlockCalled = true
                            expect(flagsForRegisteredCollection).toEventually(equal(expectedFlagsForRegisteredCollection))
                            expect(flagsForTemporaryCollection).toEventually(equal(expectedFlagsForTemporaryCollection))
                        })
                    })
                })

                afterSuite {
                    observers.forEach({ (notificationObserver) in
                        NotificationCenter.default.removeObserver(notificationObserver)
                    })
                }
            })

            describe("lifecycle", {
                var dataStoreReadyChanged: Bool?
                var observation: NSKeyValueObservation?

                beforeSuite {
                    observation = datastore.observe(\.dataStoreReady, changeHandler: { (_, _) in
                        dataStoreReadyChanged = true
                    })
                }

                beforeEach {
                    dataStoreReadyChanged = false
                }

                context("setup", {
                    beforeEach {
                        datastore.setupDataStore(nil)
                    }

                    it("data store become ready", closure: {
                        expect(datastore.dataStoreReady).to(beTrue())
                        expect(dataStoreReadyChanged).toEventually(beTrue())
                    })
                })

                context("quit", {
                    beforeEach {
                        datastore.quitDataStore()
                    }

                    it("data store become not ready", closure: {
                        expect(datastore.dataStoreReady).to(beFalse())
                        expect(dataStoreReadyChanged).toEventually(beTrue())
                    })
                })

                afterSuite {
                    observation?.invalidate()
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
}
