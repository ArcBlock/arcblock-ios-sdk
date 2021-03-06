// ABSDKClient.swift
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

import Reachability
import Apollo
import UIKit


/// Enum to describe client's network access state
public enum ClientNetworkAccessState {
    /// the client is online
    case online
    /// the client is offline
    case offline
}



/// An optional closure which gets executed before making the network call, should be used to make local cache update
public typealias OptimisticResponseBlock = (ApolloStore.ReadWriteTransaction?) -> Void
public typealias OperationResultHandler<Operation: GraphQLOperation> = (_ result: GraphQLResult<Operation.Data>?, _ error: Error?) -> Void

/// Configuration for initializing a ABSDKClient
public class ABSDKClientConfiguration {
    fileprivate var url: URL
    fileprivate var urlSessionConfiguration: URLSessionConfiguration
    fileprivate var accessKey: String?
    fileprivate var accessSecret: String?

    fileprivate var databaseURL: URL?

    fileprivate var allowsCellularAccess: Bool = true
    fileprivate var autoSubmitOfflineMutations: Bool = true


    /// Creates a configuration object for the `ABSDKClient`.
    ///
    /// - Parameters:
    ///   - url: The endpoint url for ArcBlock endpoint.
    ///   - webSocketUrl: The websocket endpoint url for ArcBlock endpoint.
    ///   - urlSessionConfiguration: A `URLSessionConfiguration` configuration object for custom HTTP configuration.
    ///   - databaseURL: The path to local sqlite database for persistent storage, if nil, an in-memory database is used.
    public init(url: URL,
                urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default,
                databaseURL: URL? = nil,
                accessKey: String? = nil,
                accessSecret: String? = nil) {
        self.url = url
        self.urlSessionConfiguration = urlSessionConfiguration
        self.databaseURL = databaseURL
        self.accessKey = accessKey
        self.accessSecret = accessSecret
    }
}

/// Customized ABSDKClient error structure
public struct ABSDKClientError: Error, LocalizedError {

    /// The body of the response.
    public let body: Data?
    /// Information about the response as provided by the server.
    public let response: HTTPURLResponse?
    let isInternalError: Bool
    let additionalInfo: String?

    /// The human readable error description
    public var errorDescription: String? {
        if isInternalError {
            return additionalInfo
        }
        return "(\(response!.statusCode) \(response!.statusCodeDescription)) \(additionalInfo ?? "")"
    }
}

/// The ABSDKClient handles network connection, making `Query`, `Mutation` and `Subscription` requests, and resolving the results.
/// The ABSDKClient also manages local caches.
public class ABSDKClient {

    let apolloClient: ApolloClient?
    let store: ApolloStore

    private var configuration: ABSDKClientConfiguration
    internal var networkTransport: NetworkTransport?

    let reachability: Reachability!
    var accessState: ClientNetworkAccessState = .offline
    var appInForeground: Bool = false
    var observers: [Any] = []

    /// Creates a client with the specified `ABSDKClientConfiguration`.
    ///
    /// - Parameters:
    ///   - configuration: The `ABSDKClientConfiguration` object.
    public init(configuration: ABSDKClientConfiguration) throws {
        self.configuration = configuration

        var store = ApolloStore(cache: InMemoryNormalizedCache())
        if let databaseURL = self.configuration.databaseURL {
            do {
                store = try ApolloStore(cache: ABSDKSQLLiteNormalizedCache(fileURL: databaseURL))
            } catch {
                // Use in memory cache incase database init fails
            }
        }
        self.store = store

        self.networkTransport = ABSDKHTTPNetworkTransport(url: self.configuration.url,
                                                          configuration: self.configuration.urlSessionConfiguration,
                                                          accessKey: self.configuration.accessKey,
                                                          accessSecret: self.configuration.accessSecret)


        self.apolloClient = ApolloClient(networkTransport: self.networkTransport!, store: self.store)

        reachability = try Reachability()
        var observer = NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { [weak self] (notification) in
            self?.checkForReachability(notification: notification)
        }
        observers.append(observer)

        observer = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.appInForeground = true
        }
        observers.append(observer)

        observer = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            self?.appInForeground = false
        }
        observers.append(observer)

        do {
            try reachability?.startNotifier()
        } catch {
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @objc func checkForReachability(notification: Notification) {

        guard let reachability = notification.object as? Reachability else {
            return
        }

        var isReachable = false

        switch reachability.connection {
        case .wifi:
            isReachable = true
        case .cellular:
            if self.configuration.allowsCellularAccess {
                isReachable = true
            }
        default:
            print("")
        }

        self.onNetworkAvailabilityStatusChanged(isEndpointReachable: isReachable)
    }

    func onNetworkAvailabilityStatusChanged(isEndpointReachable: Bool) {
        accessState = isEndpointReachable ? .online : .offline
    }


    /// Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
    ///
    /// - Parameters:
    ///   - query: The query to fetch.
    ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
    ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
    ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
    ///   - result: The result of the fetched query, or `nil` if an error occurred.
    ///   - error: An error that indicates why the fetch failed, or `nil` if the fetch was succesful.
    /// - Returns: An object that can be used to cancel an in progress fetch.
    @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .fetchIgnoringCacheData, queue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Query>? = nil) -> Cancellable {
        return apolloClient!.fetch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
    }

    /// Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
    ///
    /// - Parameters:
    ///   - query: The query to fetch.
    ///   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
    ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
    ///   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
    /// - Returns: A query watcher object that can be used to control the watching behavior.
    @discardableResult public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataAndFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping OperationResultHandler<Query>) -> GraphQLQueryWatcher<Query> {
        return apolloClient!.watch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
    }

    /// Performs a mutation by sending it to the server.
    ///
    /// - Parameters:
    ///   - mutation: The mutation to perform.
    ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
    ///   - optimisticUpdate: An optional closure which gets executed before making the network call, should be used to make local cache update
    ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
    /// - Returns: An object that can be used to cancel an in progress mutation.
    @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                                                      queue: DispatchQueue = DispatchQueue.main,
                                                                      optimisticUpdate: OptimisticResponseBlock? = nil,
                                                                      resultHandler: OperationResultHandler<Mutation>? = nil) -> Cancellable {
        if let optimisticUpdate = optimisticUpdate {
            do {
                _ = try self.store.withinReadWriteTransaction { transaction in
                    optimisticUpdate(transaction)
                    }.await()
            } catch {
            }
        }

        return apolloClient!.perform(mutation: mutation, queue: queue, resultHandler: resultHandler)
    }

    /// Subscribe to a query on the server.
    ///
    /// - Parameters:
    ///   - subscription: The subscription to perform.
    ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
    ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
    /// - Returns: An object that can be used to cancel/unsubscribe an established subscription.
    @discardableResult public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                                                queue: DispatchQueue = DispatchQueue.main,
                                                                                resultHandler: @escaping OperationResultHandler<Subscription>) -> Cancellable {
        return apolloClient!.subscribe(subscription: subscription, queue: queue, resultHandler: resultHandler)
    }
}
