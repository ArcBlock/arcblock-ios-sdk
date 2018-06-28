// ABSDKArrayDataSourceSpec.swift
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
                                                                 groupingBlock: { (collection, _, _) -> String? in
                                                                    if collection == self.collection {
                                                                        return collection
                                                                    }
                                                                    return nil
            },
                                                                 sortingBlock: sorting)
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
