// ABSDKArrayViewPagedDataSource.swift
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

import Apollo

public typealias PageMapper<Query: GraphQLPagedQuery> = (_ data: Query.Data) -> Page
public typealias KeyEqualChecker<Data: GraphQLSelectionSet> = (_ object1: Data?, _ object2: Data?) -> Bool

public protocol GraphQLPagedQuery: GraphQLQuery {
    var paging: PageInput? { get set }
    func copy() -> Self
}

public protocol PagedData: GraphQLSelectionSet {
    var page: Page? { get }
}

public struct RowChange {
    public enum RowChangeType {
        case insert
        case delete
        case move
        case update
    }

    public var type: RowChangeType!
    public var indexPath: IndexPath?
    public var newIndexPath: IndexPath?

    init(type: RowChangeType, indexPath: IndexPath? = nil, newIndexPath: IndexPath? = nil) {
        self.type = type
        self.indexPath = indexPath
        self.newIndexPath = newIndexPath
    }
}

final public class ABSDKArrayViewPagedDataSource<Query: GraphQLPagedQuery, Data: GraphQLSelectionSet>: ABSDKDataSource {
    var array: [Data?] = [] {
        didSet {
            dataSourceUpdateHandler()
        }
    }

    var changes: [RowChange] = []

    public var hasMore: Bool = true

    public var isLoading = false

    var page: Page?
    var pageCursors: [String] = []
    var pages: [String: [Data?]] = [:] {
        didSet {
            var newArray: [Data?] = []
            for pageCursor in pageCursors {
                if let items: [Data?] = pages[pageCursor] {
                    newArray += items
                }
            }

            if let checker: KeyEqualChecker = keyEqualChecker {
                var newChanges: [RowChange] = []
                var inNewArrayIndexes:[Int] = []
                if array.count == 0 && newArray.count != 0 {
                    for index in 0...newArray.count-1 {
                        newChanges.append(RowChange(type: .insert, newIndexPath: IndexPath(row: index, section: 0)))
                    }
                }
                else if array.count != 0 && newArray.count == 0 {
                    for index in 0...array.count-1 {
                        newChanges.append(RowChange(type: .delete, indexPath: IndexPath(row: index, section: 0)))
                    }
                }
                else if (array.count != 0 && newArray.count != 0) {
                    for i in 0...newArray.count-1 {
                        var inOldArray: Bool = false
                        for j in 0...array.count-1{
                            if checker(newArray[i], array[j]) {
                                if i == j {
                                    let value1: JSONObject = (newArray[i]?.jsonObject)!
                                    let value2: JSONObject = (array[j]?.jsonObject)!
                                    if !NSDictionary(dictionary: value1).isEqual(to: value2) {
                                        newChanges.append(RowChange(type: .update, indexPath: IndexPath(row: j, section: 0)))
                                    }
                                }
                                else {
                                    newChanges.append(RowChange(type: .move, indexPath: IndexPath(row: j, section: 0), newIndexPath: IndexPath(row: i, section: 0)))
                                }
                                inOldArray = true
                                inNewArrayIndexes.append(j)
                            }
                        }
                        if !inOldArray {
                            newChanges.append(RowChange(type: .insert, newIndexPath: IndexPath(row: i, section: 0)))
                        }
                    }

                    for index in 0...array.count-1 {
                        if !inNewArrayIndexes.contains(index) {
                            newChanges.append(RowChange(type: .delete, indexPath: IndexPath(row: index, section: 0)))
                        }
                    }
                }

                changes = newChanges
            }

            array = newArray
        }
    }

    var dataSourceMapper: ArrayDataSourceMapper<Query, Data>!
    var pageMapper: PageMapper<Query>!
    var watchers: [String: GraphQLQueryWatcher<Query>] = [:]

    public var keyEqualChecker: KeyEqualChecker<Data>?

    let client: ABSDKClient
    let query: Query
    let dataSourceUpdateHandler: DataSourceUpdateHandler

    init(client: ABSDKClient, query: Query, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.client = client
        self.query = query
        self.dataSourceUpdateHandler = dataSourceUpdateHandler
    }

    public convenience init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ArrayDataSourceMapper<Query, Data>, pageMapper: @escaping PageMapper<Query>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler) {
        self.init(client: client, query: query, dataSourceUpdateHandler: dataSourceUpdateHandler)
        self.dataSourceMapper = dataSourceMapper
        self.pageMapper = pageMapper
    }

    func load() {
        var pageCursor: String = ""
        if page != nil {
            pageCursor = (page?.cursor)!
        }
        if let watcher: GraphQLQueryWatcher<Query> = watchers[pageCursor] {
            isLoading = true
            watcher.refetch()
        } else {
            let pagedQuery: Query = query.copy()
            pagedQuery.paging = PageInput(cursor: pageCursor)

            let watcher: GraphQLQueryWatcher<Query> = client.watch(query: pagedQuery, cachePolicy: .returnCacheDataAndFetch, resultHandler: { [weak self] (result, err) in
                if err == nil {
                    if result?.source == .server {
                        self?.isLoading = false
                        if let data: Query.Data = result?.data, let page: Page = self?.pageMapper(data) {
                            self?.page = page
                            self?.hasMore = page.next
                        }
                    }
                    if let data: Query.Data = result?.data, let items: [Data?] = self?.dataSourceMapper(data) {
                        self?.addPage(pageCursor: pageCursor, items: items)
                    }
                }
            })
            watchers[pageCursor] = watcher
        }
    }

    func addPage(pageCursor: String!, items: [Data?]?) {
        if !pages.keys.contains(pageCursor) {
            pageCursors.append(pageCursor)
        }
        pages[pageCursor] = items
    }

    public func refresh() {
        page = nil
        pages = [:]
        pageCursors = []
        load()
    }

    public func loadMore() {
        if !isLoading && hasMore {
            load()
        }
    }

    public func numberOfSections() -> Int {
        return 1
    }

    public func numberOfRows(section: Int) -> Int {
        return array.count
    }

    public func itemForIndexPath(indexPath: IndexPath) -> Data? {
        return array[indexPath.row]
    }

    public func getChanges() -> [RowChange] {
        return changes
    }
}
