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

public enum ClientNetworkAccessState {
    case online
    case offline
}

public protocol ConnectionStateChangeHandler {
    func stateChanged(networkState: ClientNetworkAccessState)
}

public typealias OptimisticResponseBlock = (ApolloStore.ReadWriteTransaction?) -> Void

enum ABSDKGraphQLOperation {
    case mutation
    case query
    case subscription
}

protocol NetworkConnectionNotification {
    func onNetworkAvailabilityStatusChanged(isEndpointReachable: Bool)
}

extension HTTPURLResponse {
    var statusCodeDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}

class SnapshotProcessController {
    let endpointURL: URL
    var reachability: Reachability?
    private var networkStatusWatchers: [NetworkConnectionNotification] = []
    let allowsCellularAccess: Bool

    init(endpointURL: URL, allowsCellularAccess: Bool = true) {
        self.endpointURL = endpointURL
        self.allowsCellularAccess = allowsCellularAccess
        reachability = Reachability(hostname: endpointURL.host!)
        reachability?.allowsCellularConnection = allowsCellularAccess
        NotificationCenter.default.addObserver(self, selector: #selector(checkForReachability(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        } catch {
        }
    }

    @objc func checkForReachability(note: Notification) {
        if let reachability = note.object as? Reachability {
            var isReachable = true
            switch reachability.connection {
            case .none:
                isReachable = false
            default:
                break
            }

            for watchers in networkStatusWatchers {
                watchers.onNetworkAvailabilityStatusChanged(isEndpointReachable: isReachable)
            }
        }
    }

    func shouldExecuteOperation(operation: ABSDKGraphQLOperation) -> Bool {
        switch operation {
        case .mutation:
            if !(reachability?.connection.description == "No Connection") {
                return true
            } else {
                return false
            }
        case .query:
            return true
        case .subscription:
            return true
        }
    }
}

public class ABSDKClientConfiguration {
    fileprivate var url: URL
    fileprivate var store: ApolloStore
    fileprivate var urlSessionConfiguration: URLSessionConfiguration

    fileprivate var databaseURL: URL?
    fileprivate var snapshotController: SnapshotProcessController?
    fileprivate var connectionStateChangeHandler: ConnectionStateChangeHandler?

    fileprivate var allowsCellularAccess: Bool = true
    fileprivate var autoSubmitOfflineMutations: Bool = true

    /// Creates a configuration object for the `ABSDKClient`.
    ///
    /// - Parameters:
    ///   - url: The endpoint url for Appsync endpoint.
    ///   - urlSessionConfiguration: A `URLSessionConfiguration` configuration object for custom HTTP configuration.
    ///   - databaseURL: The path to local sqlite database for persistent storage, if nil, an in-memory database is used.
    ///   - connectionStateChangeHandler: The delegate object to be notified when client network state changes.
    public init(url: URL,
                urlSessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default,
                databaseURL: URL? = nil,
                connectionStateChangeHandler: ConnectionStateChangeHandler? = nil) throws {
        self.url = url
        self.urlSessionConfiguration = urlSessionConfiguration
        self.databaseURL = databaseURL
        self.store = ApolloStore(cache: InMemoryNormalizedCache())
        self.connectionStateChangeHandler = connectionStateChangeHandler
        if let databaseURL = databaseURL {
            do {
                self.store = try ApolloStore(cache: ABSDKSQLLiteNormalizedCache(fileURL: databaseURL))
            } catch {
                // Use in memory cache incase database init fails
            }
        }
        self.snapshotController = SnapshotProcessController(endpointURL: url)
    }
}

public struct ABSDKClientError: Error, LocalizedError {

    /// The body of the response.
    public let body: Data?
    /// Information about the response as provided by the server.
    public let response: HTTPURLResponse?
    let isInternalError: Bool
    let additionalInfo: String?

    public var errorDescription: String? {
        if (isInternalError) {
            return additionalInfo
        }
        return "(\(response!.statusCode) \(response!.statusCodeDescription)) \(additionalInfo ?? "")"
    }
}

// The client for making `Mutation`, `Query` and `Subscription` requests.
public class ABSDKClient: NetworkConnectionNotification {

    public let apolloClient: ApolloClient?
    public let store: ApolloStore?

    var reachability: Reachability?

    private var networkStatusWatchers: [NetworkConnectionNotification] = []
    private var configuration: ABSDKClientConfiguration
    internal var httpTransport: HTTPNetworkTransport?
    internal var connectionStateChangeHandler: ConnectionStateChangeHandler?

    /// Creates a client with the specified `ABSDKClientConfiguration`.
    ///
    /// - Parameters:
    ///   - configuration: The `ABSDKClientConfiguration` object.
    public init(configuration: ABSDKClientConfiguration) throws {
        self.configuration = configuration

        reachability = Reachability(hostname: self.configuration.url.host!)
        self.store = configuration.store
        self.httpTransport = HTTPNetworkTransport(url: self.configuration.url, configuration: self.configuration.urlSessionConfiguration)

        self.apolloClient = ApolloClient(networkTransport: self.httpTransport!, store: self.configuration.store)

        NotificationCenter.default.addObserver(self, selector: #selector(checkForReachability(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability?.startNotifier()
        } catch {
        }
    }

    @objc func checkForReachability(note: Notification) {

        let reachability = note.object as! Reachability
        var isReachable = false

        switch reachability.connection {
        case .wifi:
            isReachable = true
        case .cellular:
            if (self.configuration.allowsCellularAccess) {
                isReachable = true
            }
        case .none:
            print("")
        }

        for watchers in networkStatusWatchers {
            watchers.onNetworkAvailabilityStatusChanged(isEndpointReachable: isReachable)
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
    ///   - result: The result of the fetched query, or `nil` if an error occurred.
    ///   - error: An error that indicates why the fetch failed, or `nil` if the fetch was succesful.
    /// - Returns: A query watcher object that can be used to control the watching behavior.
    @discardableResult public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping OperationResultHandler<Query>) -> GraphQLQueryWatcher<Query> {

        return apolloClient!.watch(query: query, cachePolicy: cachePolicy, queue: queue, resultHandler: resultHandler)
    }

//    public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping SubscriptionResultHandler<Subscription>) throws -> AWSAppSyncSubscriptionWatcher<Subscription>? {
//
//        return AWSAppSyncSubscriptionWatcher(client: self.appSyncMQTTClient,
//                                             httpClient: self.httpTransport!,
//                                             store: self.store!,
//                                             subscription: subscription,
//                                             handlerQueue: queue,
//                                             resultHandler: resultHandler)
//    }

    /// Performs a mutation by sending it to the server.
    ///
    /// - Parameters:
    ///   - mutation: The mutation to perform.
    ///   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
    ///   - optimisticUpdate: An optional closure which gets executed before making the network call, should b
    ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
    ///   - result: The result of the performed mutation, or `nil` if an error occurred.
    ///   - error: An error that indicates why the mutation failed, or `nil` if the mutation was succesful.
    /// - Returns: An object that can be used to cancel an in progress mutation.
    @discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                                                      queue: DispatchQueue = DispatchQueue.main,
                                                                      optimisticUpdate: OptimisticResponseBlock? = nil,
                                                                      resultHandler: OperationResultHandler<Mutation>? = nil) -> Cancellable  {
        if let optimisticUpdate = optimisticUpdate {
            do {
                let _ = try self.store?.withinReadWriteTransaction { transaction in
                    optimisticUpdate(transaction)
                    }.await()
            } catch {
            }
        }

        return apolloClient!.perform(mutation: mutation, queue: queue, resultHandler: resultHandler)
    }

    func onNetworkAvailabilityStatusChanged(isEndpointReachable: Bool) {
        var accessState: ClientNetworkAccessState = .offline
        if (isEndpointReachable) {
            accessState = .offline
        }
        self.connectionStateChangeHandler?.stateChanged(networkState: accessState)
    }
}
