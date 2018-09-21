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

/// The callback to extract page info from query result
public typealias PageMapper<Query: GraphQLPagedQuery> = (_ data: Query.Data) -> Page

/// A protocol for GraphQL queries with paged results
public protocol GraphQLPagedQuery: GraphQLQuery {
    /// The query argument related to page
    var paging: PageInput? { get set }
    /// Copy an idential query
    func copy() -> Self
}

/// A protocol for GraphQL result data the contains page info
public protocol PagedData: GraphQLSelectionSet {
    /// The field for page info
    var page: Page? { get }
}

/// A ABSDKArrayDataSource that supports paging
final public class ABSDKPagedArrayDataSource<Query: GraphQLPagedQuery, Data: GraphQLSelectionSet>: ABSDKArrayDataSource<Query, Data> {

    /// Flag indicates whether there're more pages
    public var hasMore: Bool = true

    /// Flag indicates is the data source currently loading a page
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
            array = newArray
        }
    }

    var pageMapper: PageMapper<Query>!
    var watchers: [String: GraphQLQueryWatcher<Query>] = [:]

    /// Init a paged array data source
    ///
    /// - Parameters:
    ///     - client: An ABSDKClient for sending requests
    ///     - query: A GraphQL query to get the array
    ///     - dataSourceMapper: A callback to extract the concerned array from the query result
    ///     - dataSourceUpdateHandler: A callback that gets called whenever the concerned array gets update
    ///     - arrayDataKeyEqualCHecker: An optional callback to check whether two elements in the concerned array are with the same key. This is used to calculate the row changes to update view dynamically.
    ///     - pageMapper: A callback to extract page info from the query result
    public init(client: ABSDKClient, query: Query, dataSourceMapper: @escaping ArrayDataSourceMapper<Query, Data>, dataSourceUpdateHandler: @escaping DataSourceUpdateHandler, arrayDataKeyEqualChecker: ArrayDataKeyEqualChecker<Data>? = nil, pageMapper: @escaping PageMapper<Query>) {
        super.init(client: client, operation: query, dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler, arrayDataKeyEqualChecker: arrayDataKeyEqualChecker)
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
            let pagedQuery: Query = operation.copy()
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
                } else {
                    print("paged query error: " + err!.localizedDescription)
                    self?.dataSourceUpdateHandler(err)
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

    /// Load from the first page again
    public func refresh() {
        page = nil
        pages = [:]
        pageCursors = []
        load()
    }

    /// Load next page
    public func loadMore() {
        if !isLoading && hasMore {
            load()
        }
    }
}
