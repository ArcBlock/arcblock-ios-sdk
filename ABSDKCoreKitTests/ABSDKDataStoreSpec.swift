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
            struct Flags {
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
            var observers = [NSObjectProtocol]()

            beforeSuite {
                // observe data store modified event
                var notificationObserver = NotificationCenter.default.addObserver(
                                    forName: Notification.Name.ABSDKDataStoreModified,
                                    object: nil,
                                    queue: nil,
                                    using: { (notification) in
                                        flagsForRegisteredCollection.valueChanged = datastore.hasChange(forKey: key, inCollection: Collection.registered.rawValue, notification: notification)
                                })
                observers.append(notificationObserver)
                notificationObserver = NotificationCenter.default.addObserver(
                    forName: Notification.Name.ABSDKDataStoreModified,
                    object: nil,
                    queue: nil,
                    using: { (notification) in
                        flagsForTemporaryCollection.valueChanged = datastore.hasChange(forKey: key, inCollection: Collection.temporary.rawValue, notification: notification)
                })
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
            }

            describe("create", {
                context("in registered collection", {
                    beforeEach {
                        datastore.setObject(initialValue, forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                    }

                    it("create success, value has changed, will update called, did update called", closure: {
                        expect((datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)).toEventually(equal(initialValue))
                        expect(flagsForRegisteredCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.didUpdateBlockCalled).toEventually(beTrue())
                    })
                })

                context("in temporary collection", {
                    beforeEach {
                        datastore.setObject(initialValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                    }

                    it("create success, value has changed, will update called, did update called", closure: {
                        expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(equal(initialValue))
                        expect(flagsForTemporaryCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.didUpdateBlockCalled).toEventually(beTrue())
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
                        expect(flagsForRegisteredCollection.valueChanged).toEventually(beFalse())
                        expect(flagsForRegisteredCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.didUpdateBlockCalled).toEventually(beFalse())
                    })
                })

                context("in temporary collection", {
                    beforeEach {
                        let oldValue = (datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)
                        datastore.setObject(oldValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                    }
                    it("update ignored, value has not changed, will update called, did update not called", closure: {
                        expect(flagsForTemporaryCollection.valueChanged).toEventually(beFalse())
                        expect(flagsForTemporaryCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.didUpdateBlockCalled).toEventually(beFalse())
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
                        expect(flagsForRegisteredCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.didUpdateBlockCalled).toEventually(beTrue())
                    })
                })

                context("in temporary collection", {
                    beforeEach {
                        datastore.setObject(alternativeValue, forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                    }
                    it("update success, value has changed, will update called, did update called", closure: {
                        expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(equal(alternativeValue))
                        expect(flagsForTemporaryCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.willUpdateBlockCalled).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.didUpdateBlockCalled).toEventually(beTrue())
                    })
                })
            })

            describe("remove", {
                context("in registered collection", {
                    beforeEach {
                        datastore.removeObject(forKey: key, inCollection: Collection.registered.rawValue, completionBlock: nil)
                    }
                    it("remove success, value has changed, will update called, did update called", closure: {
                        expect((datastore.object(forKey: key, inCollection: Collection.registered.rawValue) as? String)).toEventually(beNil())
                        expect(flagsForRegisteredCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForRegisteredCollection.didRemovedBlockCalled).toEventually(beTrue())
                    })
                })

                context("in temporary collection", {
                    beforeEach {
                        datastore.removeObject(forKey: key, inCollection: Collection.temporary.rawValue, completionBlock: nil)
                    }
                    it("remove success, value has changed, will update called, did update called", closure: {
                        expect((datastore.object(forKey: key, inCollection: Collection.temporary.rawValue) as? String)).toEventually(beNil())
                        expect(flagsForTemporaryCollection.valueChanged).toEventually(beTrue())
                        expect(flagsForTemporaryCollection.didRemovedBlockCalled).toEventually(beTrue())
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
            var observer: NSKeyValueObservation?

            beforeSuite {
                observer = datastore.observe(\.dataStoreReady, changeHandler: { (_, _) in
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
                observer?.invalidate()
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
