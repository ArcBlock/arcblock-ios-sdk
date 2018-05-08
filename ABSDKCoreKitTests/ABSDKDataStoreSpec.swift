//
//  ABSDKDataStoreSpec.swift
//  Pods
//
//  Created by Jonathan Lu on 6/5/2018.
//

import Quick
import Nimble

class ABSDKDataStoreSpec: QuickSpec {
    override func spec() {
        var datastore : ABSDKDataStore!
        let registeredCollection = "registeredCollection"
        let nonregisteredCollection = "nonregisteredCollection"
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"
        var observers = [NSKeyValueObservation]()
        
        Nimble.AsyncDefaults.Timeout = 10
        
        beforeSuite {
            datastore = ABSDKDataStore.sharedInstance()
            datastore.registerCollections([registeredCollection])
            datastore.setupDataStore(nil);
        }
        
        describe("CRUD with registered collection", {
            var hasChange:Bool?
            
            beforeSuite {
                NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                    hasChange = datastore.hasChange(forKey: key1, inCollection: registeredCollection, notification: notification)
                })
            }
            
            beforeEach {
                hasChange = false
            }
            
            it("create", closure: {
                waitUntil(action: { (done) in
                    datastore.setObject(value1, forKey: key1, inCollection: registeredCollection, completionBlock: {
                        expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).to(equal(value1))
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            })
            
            it("update with same value", closure: {
                waitUntil(action: { (done) in
                    datastore.setObject((datastore.object(forKey: key1, inCollection: registeredCollection) as? String), forKey: key1, inCollection: registeredCollection, completionBlock: {
                        expect(hasChange).to(beFalse())
                        done()
                    })
                })
                
            })
            
            it("update with different value", closure: {
                waitUntil(action: { (done) in
                    datastore.setObject(value2, forKey: key1, inCollection: registeredCollection, completionBlock: {
                        expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).to(equal(value2))
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            })
            
            it("remove", closure: {
                waitUntil(action: { (done) in
                    datastore.removeObject(forKey: key1, inCollection: registeredCollection, completionBlock: {
                        expect((datastore.object(forKey: key1, inCollection: registeredCollection) as? String)).to(beNil())
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            })
        })
        
        describe("CRUD with nonregistered collection", {
            var hasChange:Bool?
            
            beforeSuite {
                NotificationCenter.default.addObserver(forName: Notification.Name.ABSDKDataStoreModified, object: nil, queue: nil, using: { (notification) in
                    hasChange = datastore.hasChange(forKey: key2, inCollection: nonregisteredCollection, notification: notification)
                })
            }
            
            beforeEach {
                hasChange = false
            }
            
            it("create") {
                waitUntil(action: { (done) in
                    datastore.setObject(value2, forKey: key2, inCollection: nonregisteredCollection, completionBlock: {
                        expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).to(equal(value2))
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            }
            
            it("update with same value", closure: {
                waitUntil(action: { (done) in
                    datastore.setObject((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String), forKey: key2, inCollection: nonregisteredCollection, completionBlock: {
                        expect(hasChange).to(beFalse())
                        done()
                    })
                })
            })
            
            it("update with different value", closure: {
                waitUntil(action: { (done) in
                    datastore.setObject(value1, forKey: key2, inCollection: nonregisteredCollection, completionBlock: {
                        expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).to(equal(value1))
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            })
            
            it("remove", closure: {
                waitUntil(action: { (done) in
                    datastore.removeObject(forKey: key2, inCollection: nonregisteredCollection, completionBlock: {
                        expect((datastore.object(forKey: key2, inCollection: nonregisteredCollection) as? String)).to(beNil())
                        expect(hasChange).to(beTrue())
                        done()
                    })
                })
            })
        })
        
        describe("lifecycle", {
            var dataStoreReadyChanged:Bool?

            beforeSuite {
                observers.append(datastore.observe(\.dataStoreReady, changeHandler: { (datastore, changed) in
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
