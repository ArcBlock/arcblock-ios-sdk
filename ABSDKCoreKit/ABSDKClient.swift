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

let ocapBaseUrl = "https://ocap.arcblock.io/"
let websocketBaseUrl = "wss://ocap.arcblock.io/"

/// Enum for ArcBlock supported endpoints
public enum ABSDKEndpoint {
    /// the Bitcoin endpoint
    case btc
    /// the Ethereum endpoint
    case eth

    var url: URL {
        switch self {
        case .btc:
            return URL(string: ocapBaseUrl + "api/btc")!
        case .eth:
            return URL(string: ocapBaseUrl + "api/eth")!
        }
    }

    var webSocketUrl: URL {
        switch self {
        case .btc:
            return URL(string: websocketBaseUrl + "api/btc/socket/websocket")!
        case .eth:
            return URL(string: websocketBaseUrl + "api/eth/socket/websocket")!
        }
    }
}

/// Enum to describe client's network access state
public enum ClientNetworkAccessState {
    /// the client is online
    case online
    /// the client is offline
    case offline
}

/// An optional closure which gets executed before making the network call, should be used to make local cache update
public typealias OptimisticResponseBlock = (ApolloStore.ReadWriteTransaction?) -> Void

extension HTTPURLResponse {
    var statusCodeDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}

/// Configuration for initializing a ABSDKClient
public class ABSDKClientConfiguration {
    fileprivate var url: URL
    fileprivate var webSocketUrl: URL?
    fileprivate var store: ApolloStore
    fileprivate var urlSessionConfiguration: URLSessionConfiguration

    fileprivate var databaseURL: URL?

    fileprivate var allowsCellularAccess: Bool = true
    fileprivate var autoSubmitOfflineMutations: Bool = true

    /// Creates a configuration object for the `ABSDKClient`.
    ///
    /// - Parameters:
    ///   - endpoint: The ArcBlock endpoint.
    ///   - databaseURL: The path to local sqlite database for persistent storage, if nil, an in-memory database is used.
    public convenience init(endpoint: ABSDKEndpoint,
                            databaseURL: URL? = nil) throws {
        try self.init(url: endpoint.url, webSocketUrl: endpoint.webSocketUrl, databaseURL: databaseURL)
    }

    /// Creates a configuration object for the `ABSDKClient`.
    ///
    /// - Parameters:
    ///   - url: The endpoint url for ArcBlock endpoint.
    ///   - webSocketUrl: The websocket endpoint url for ArcBlock endpoint.
    ///   - urlSessionConfiguration: A `URLSessionConfiguration` configuration object for custom HTTP configuration.
    ///   - databaseURL: The path to local sqlite database for persistent storage, if nil, an in-memory database is used.
    public init(url: URL,
                webSocketUrl: URL? = nil,
                urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default,
                databaseURL: URL? = nil) throws {
        self.url = url
        self.webSocketUrl = webSocketUrl
        self.urlSessionConfiguration = urlSessionConfiguration
        self.databaseURL = databaseURL
        self.store = ApolloStore(cache: InMemoryNormalizedCache())
        if let databaseURL = databaseURL {
            do {
                self.store = try ApolloStore(cache: ABSDKSQLLiteNormalizedCache(fileURL: databaseURL))
            } catch {
                // Use in memory cache incase database init fails
            }
        }
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
    let store: ApolloStore?

    private var configuration: ABSDKClientConfiguration
    internal var networkTransport: NetworkTransport?

    let reachability: Reachability!
    var accessState: ClientNetworkAccessState = .offline
    var appInForeground: Bool!
    var observers: [Any] = []

    /// Creates a client with the specified `ABSDKClientConfiguration`.
    ///
    /// - Parameters:
    ///   - configuration: The `ABSDKClientConfiguration` object.
    public init(configuration: ABSDKClientConfiguration) throws {
        self.configuration = configuration

        self.store = configuration.store

        if let webSocketUrl: URL = self.configuration.webSocketUrl {
            let httpTransport: HTTPNetworkTransport = HTTPNetworkTransport(url: self.configuration.url, configuration: self.configuration.urlSessionConfiguration)
            let websocketTransport: ABSDKWebSocketTransport = ABSDKWebSocketTransport(url: webSocketUrl)
            self.networkTransport = ABSDKSplitNetworkTransport(httpNetworkTransport: httpTransport, webSocketNetworkTransport: websocketTransport)
        } else {
            self.networkTransport = HTTPNetworkTransport(url: self.configuration.url, configuration: self.configuration.urlSessionConfiguration)
        }

        self.apolloClient = ApolloClient(networkTransport: self.networkTransport!, store: self.configuration.store)

        reachability = Reachability()
        var observer = NotificationCenter.default.addObserver(forName: .reachabilityChanged, object: nil, queue: nil) { [weak self] (notification) in
            self?.checkForReachability(notification: notification)
        }
        observers.append(observer)

        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
            self?.appInForeground = true
            self?.handleStateChange()
        }
        observers.append(observer)

        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
            self?.appInForeground = false
        }
        observers.append(observer)

        do {
            try reachability?.startNotifier()
        } catch {
        }
        appInForeground = UIApplication.shared.applicationState == .active
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
        case .none:
            print("")
        }

        self.onNetworkAvailabilityStatusChanged(isEndpointReachable: isReachable)
    }

    func onNetworkAvailabilityStatusChanged(isEndpointReachable: Bool) {
        accessState = isEndpointReachable ? .online : .offline
        self.handleStateChange()
    }

    func handleStateChange() {
        guard let networkTransport: ABSDKSplitNetworkTransport = self.networkTransport as? ABSDKSplitNetworkTransport else {
            return
        }
        if appInForeground && accessState == .online {
            networkTransport.reconnect()
        }
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
    @discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: OperationResultHandler<Query>? = nil) -> Cancellable {
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
    @discardableResult public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping OperationResultHandler<Query>) -> GraphQLQueryWatcher<Query> {
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
                _ = try self.store?.withinReadWriteTransaction { transaction in
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
