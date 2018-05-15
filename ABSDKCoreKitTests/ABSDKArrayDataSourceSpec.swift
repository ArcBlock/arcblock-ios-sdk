//
//  ABSDKArrayDataSourceSpec.swift
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 10/5/2018.
//

import Quick
import Nimble

class ABSDKArrayDataSourceSpec: QuickSpec {

    var datastore: ABSDKDataStore!
    var tableView: UITableView!
    var tableViewArrayDataSource: ABSDKArrayDataSource!
    let tableViewCellIdentifier = "tableViewCellIdentifier"
    let collection = "arrayDataSourceCollection"
    let key = "key"
    var tableViewObjects: [[String: Any]] = []

    override func spec() {

        beforeSuite {
            self.datastore = ABSDKDataStore.sharedInstance()
            self.datastore.registerCollections([self.collection])

            self.tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            self.tableView.dataSource = self

            let sorting: ABSDKArrayDataSourceSortingBlock = { (_, _, key1, _, _, key2, _) -> ComparisonResult in
                return (key1?.compare(key2!))!
            }

            self.tableViewArrayDataSource = ABSDKArrayDataSource.init(identifier: self.tableViewCellIdentifier,
                                                                 sections: [self.collection],
                                                                 grouping: { (collection, _, _) -> String? in
                                                                        if collection == self.collection {
                                                                            return collection
                                                                        }
                                                                        return nil
                                                                    },
                                                                 sorting: sorting)
            self.tableView.observe(self.tableViewArrayDataSource, updatedBlock: nil)
            self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: self.tableViewCellIdentifier)

            for index in 1...2 {
                self.tableViewObjects.append(["_id": self.key, "name": String(index)])
            }
        }

        describe("insert row in table view") {
            beforeEach {
                self.datastore.setupDataStore(nil)
                self.datastore.setObject(self.tableViewObjects[0], forKey: self.key, inCollection: self.collection, completionBlock: nil)
            }

            it("cell inserted", closure: {
                expect(self.tableView.numberOfSections).toEventually(equal(1))
                expect(self.tableView.numberOfRows(inSection: 0)).toEventually(equal(1))
                let text = self.tableViewObjects[0]["name"] as? String
                expect(self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text).toEventually(equal(text))
            })
        }

        describe("update row in table view") {
            beforeEach {
                self.datastore.setupDataStore(nil)
                self.datastore.setObject(self.tableViewObjects[1], forKey: self.key, inCollection: self.collection, completionBlock: nil)
            }

            it("cell updated", closure: {
                expect(self.tableView.numberOfSections).toEventually(equal(1))
                expect(self.tableView.numberOfRows(inSection: 0)).toEventually(equal(1))
                let text = self.tableViewObjects[1]["name"] as? String
                expect(self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text).toEventually(equal(text))
            })
        }

        describe("remove row in table view") {
            beforeEach {
                self.datastore.setupDataStore(nil)
                self.datastore.removeObject(forKey: self.key, inCollection: self.collection, completionBlock: nil)
            }

            it("cell deleted", closure: {
                expect(self.tableView.numberOfSections).toEventually(equal(1))
                expect(self.tableView.numberOfRows(inSection: 0)).toEventually(equal(0))
            })
        }
    }
}

extension ABSDKArrayDataSourceSpec: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewArrayDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewArrayDataSource.numberOfItems(forSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        cell.textLabel?.text = self.tableViewArrayDataSource.object(at: indexPath)["name"] as? String
        return cell
    }
}
