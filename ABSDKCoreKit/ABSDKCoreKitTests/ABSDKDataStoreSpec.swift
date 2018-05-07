//
//  ABSDKDataStoreSpec.swift
//  Pods
//
//  Created by Jonathan Lu on 6/5/2018.
//

import Quick
import Nimble
import ABSDKCoreKit

class ABSDKDataStoreSpec: QuickSpec {
    override func spec() {
        describe("a data store") {
            var datastore : ABSDKDataStore!
            let registeredCollection = "registeredCollection"
            let nonregisteredCollection = "nonregisteredCollection"
            let key1 = "key1"
            let key2 = "key2"
            let value1 = "value1"
            let value2 = "value2"
            
            beforeSuite {
                datastore = ABSDKDataStore.sharedInstance()
                datastore.registerCollections([registeredCollection])
            }
            
            describe("setup", {
                it("data store should be ready") {
                    datastore.setupDataStore(nil)
                    expect(datastore.dataStoreReady).to(beTrue())
                }
            })
            
            describe("create, update and delete with registered collection", {
                var hasChange:Bool?
                beforeEach {
                    datastore.setupDataStore(nil)
                    hasChange = false
                    NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                        hasChange = datastore.hasChange(forKey: key1, inCollection: registeredCollection, notification: notification)
                    })
                }
                
                it("create", closure: {
                    datastore.setObject(value1, forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(equal(value1))
                    expect(hasChange).toEventually(beTrue())
                })
                
                it("update with same value", closure: {
                    datastore.setObject((datastore.object(forKey: key1, inCollection: registeredCollection) as? String), forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                    expect(hasChange).toEventually(beFalse())
                })
                
                it("update with different value", closure: {
                    datastore.setObject(value2, forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(equal(value2))
                    expect(hasChange).toEventually(beTrue())
                })
                
                it("remove", closure: {
                    datastore.removeObject(forKey: key1, inCollection: registeredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).toEventually(beNil())
                    expect(hasChange).toEventually(beTrue())
                })
            })
            
            describe("create, update and delete with nonregistered collection", {
                var hasChange:Bool?
                beforeEach {
                    datastore.setupDataStore(nil)
                    hasChange = false
                    NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                        hasChange = datastore.hasChange(forKey: key2, inCollection: nonregisteredCollection, notification: notification)
                    })
                }
                
                it("create") {
                    datastore.setObject(value2, forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(equal(value2))
                    expect(hasChange).toEventually(beTrue())
                }
                
                it("update with same value", closure: {
                    datastore.setObject((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String), forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                    expect(hasChange).toEventually(beFalse())
                })
                
                it("update with different value", closure: {
                    datastore.setObject(value1, forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(equal(value1))
                    expect(hasChange).toEventually(beTrue())
                })
                
                it("remove", closure: {
                    datastore.removeObject(forKey: key2, inCollection: nonregisteredCollection, completionBlock: nil)
                    expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).toEventually(beNil())
                    expect(hasChange).toEventually(beTrue())
                })
            })
            
            describe("quit", {
                it("data store should be not ready") {
                    datastore.quitDataStore()
                    expect(datastore.dataStoreReady).to(beFalse())
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
