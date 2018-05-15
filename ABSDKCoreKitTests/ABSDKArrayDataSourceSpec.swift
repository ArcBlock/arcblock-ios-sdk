//
//  ABSDKArrayDataSourceSpec.swift
//  ABSDKCoreKitTests
//
//  Created by Jonathan Lu on 10/5/2018.
//

import Quick
import Nimble

class ABSDKArrayDataSourceSpec: QuickSpec {
    enum Collection: String {
        case tableView, collectionView
    }

    var datastore: ABSDKDataStore!
    var tableView: UITableView!
    var collectionView: UICollectionView!
    var tableViewArrayDataSource: ABSDKArrayDataSource!
    var collectionViewArrayDataSource: ABSDKArrayDataSource!
    let tableViewCellIdentifier = "tableViewCellIdentifier"
    let collectionViewCellIdentifier = "collectionViewCellIdentifier"
    let key = "key"
    var tableViewObjects: [[String: Any]] = []
    var collectionViewObjects: [[String: Any]] = []

    override func spec() {

        beforeSuite {
            self.datastore = ABSDKDataStore.sharedInstance()
            self.datastore.registerCollections([Collection.tableView.rawValue, Collection.collectionView.rawValue])

            self.tableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
            self.tableView.dataSource = self
            self.collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 640), collectionViewLayout: UICollectionViewLayout.init())
            self.collectionView.dataSource = self

            let sorting: ABSDKArrayDataSourceSortingBlock = { (_, _, key1, _, _, key2, _) -> ComparisonResult in
                return (key1?.compare(key2!))!
            }

            self.tableViewArrayDataSource = ABSDKArrayDataSource.init(identifier: "tableViewArrayDataSource",
                                                                 sections: [Collection.tableView.rawValue],
                                                                 grouping: { (collection, _, _) -> String? in
                                                                        if collection == Collection.tableView.rawValue {
                                                                            return collection
                                                                        }
                                                                        return nil
                                                                    },
                                                                 sorting: sorting)
            self.tableView.observe(self.tableViewArrayDataSource, updatedBlock: nil)
            self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: self.tableViewCellIdentifier)

            self.collectionViewArrayDataSource = ABSDKArrayDataSource.init(identifier: "collectionViewArrayDataSource",
                                                                      sections: [Collection.collectionView.rawValue],
                                                                      grouping: { (collection, _, _) -> String? in
                                                                            if collection == Collection.collectionView.rawValue {
                                                                                return collection
                                                                            }
                                                                            return nil
                                                                        },
                                                                      sorting: sorting)
            self.collectionView.observe(self.collectionViewArrayDataSource, updatedBlock: nil)
            self.collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: self.collectionViewCellIdentifier)

            for index in 1...2 {
                self.tableViewObjects.append(["_id": self.key, "name": String(index)])
            }

            for index in 1...2 {
                self.collectionViewObjects.append(["_id": self.key, "name": String(index)])
            }
        }

        describe("insert row") {
            beforeEach {
                self.datastore.setupDataStore(nil)
            }

            context("in table view", {
                beforeEach {
                    self.datastore.setObject(self.tableViewObjects[0], forKey: self.key, inCollection: Collection.tableView.rawValue, completionBlock: nil)
                }

                it("cell inserted", closure: {
                    expect(self.tableView.numberOfSections).toEventually(equal(1))
                    expect(self.tableView.numberOfRows(inSection: 0)).toEventually(equal(1))
                    let text = self.tableViewObjects[0]["name"] as? String
                    expect(self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text).toEventually(equal(text))
                })
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

extension ABSDKArrayDataSourceSpec: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.collectionViewArrayDataSource.numberOfSections()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewArrayDataSource.numberOfItems(forSection: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCellIdentifier, for: indexPath)
        return cell
    }
}
