// ABSDKWebSocketTransport.swift
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
import SwiftPhoenixClient

/// A network transport that wraps a http transport and a websocket transport to cover query, mutation and subscription
public class ABSDKSplitNetworkTransport: NetworkTransport {
    private let httpNetworkTransport: ABSDKHTTPNetworkTransport
    private let webSocketNetworkTransport: ABSDKWebSocketTransport

    /// Initialize a split transport with a http transport and a websocket transport
    ///
    /// - Parameters:
    ///   - httpNetworkTransport: The http network transport
    ///   - websocketNetworkTransport: The websocket network transport
    /// - Returns: The split network transport
    public init(httpNetworkTransport: ABSDKHTTPNetworkTransport, webSocketNetworkTransport: ABSDKWebSocketTransport) {
        self.httpNetworkTransport = httpNetworkTransport
        self.webSocketNetworkTransport = webSocketNetworkTransport
    }

    /// Send an operation to server
    ///
    /// - Parameters:
    ///   - operation: The operation to send
    ///   - completionHandler: An optional closure that is called when mutation results are available or when an error occurs.
    /// - Returns: An object that can be used to cancel the operation.
    public func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
        if operation.operationType == .subscription {
            return webSocketNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        } else {
            return httpNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        }
    }

    /// Recover the connection status of the websocket transport
    public func reconnect() {
        webSocketNetworkTransport.connect()
    }
}

final class ABSDKSubscription {
    var payload: Payload
    var handlers = [String: (JSONObject?, Error?) -> Void]()

    init(payload: Payload) {
        self.payload = payload
    }

    private var sequenceNumber: Int = 0

    private func nextSeqNo() -> Int {
        sequenceNumber += 1
        return sequenceNumber
    }

    func addHandler(handler: @escaping (JSONObject?, Error?) -> Void) -> String {
        let seqNo = "\(nextSeqNo())"
        handlers[seqNo] = handler
        return seqNo
    }
}

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the SwiftPhoenixClient implementation of Phoenix client.
public class ABSDKWebSocketTransport: NetworkTransport {

    var socket: Socket?
    var channel: Channel?
    var error: WebSocketError?

    let serializationFormat = ABSDKJSONSerializationFormat.self
    let topic = "doc"

    var joined: Bool = false
    var connecting = false

    private var params: [String: String]?

    private var subscriptions: [String: ABSDKSubscription] = [:]
    private var subscriptionIds: [String: String] = [:]

    /// Initialize a websocket network transport
    ///
    /// - Parameters:
    ///   - url: Websocket url
    ///   - params: Parameters for the socket connection
    /// - Returns: The websocket network transport
    public init(url: URL, params: [String: String]? = nil) {
        self.params = params
        var request = URLRequest(url: url)
        if let params = self.params {
            request.allHTTPHeaderFields = params
        }
        self.socket = Socket(url.absoluteString, params: params)

        self.socket?.onOpen { [weak self] in
            self?.websocketDidConnect()
        }

        self.socket?.onClose { [weak self] in
            self?.websocketDidDisconnect()
        }

        self.socket?.onError(callback: { [weak self] (err) in
            self?.websocketDidFailed(err: err)
        })

        self.socket?.onMessage(callback: { [weak self] (message) in
            print(message.payload)
            if message.event == "subscription:data" {
                if  let subscriptionId: String = message.payload["subscriptionId"] as? String,
                    let subscriptionSeqNo: String = self?.subscriptionIds[subscriptionId],
                    let subscription: ABSDKSubscription = self?.subscriptions[subscriptionSeqNo],
                    let result: JSONObject = message.payload["result"] as? JSONObject {
                    for(_, handler) in subscription.handlers {
                        handler(result, nil)
                    }
                }
            }
        })

        connect()
    }

    fileprivate func connect() {
        if self.isConnected() || connecting {
            return
        }

        connecting = true
        self.socket?.connect()
    }

    deinit {
        socket?.disconnect()
    }

    /// The socket connection status
    ///
    /// - Returns: If the socket is connected
    public func isConnected() -> Bool {
        return socket?.isConnected ?? false
    }

    private func websocketDidConnect() {
        connecting = false
        error = nil
        self.joinChannel()
    }

    private func websocketDidDisconnect() {
        joined = false
        connecting = false
        error = nil
    }

    private func websocketDidFailed(err: Error) {
        joined = false
        connecting = false
        error = WebSocketError(payload: nil, error: err, type: .networkError)
        self.notifyWithError(error: error!)
    }

    private func joinChannel() {
        self.channel = self.socket?.channel("__absinthe__:control")
        self.channel?.join().receive("ok", callback: { [weak self] (_) in
            self?.joined = true
            self?.resendSubscriptions()
        }).receive("error", callback: { [weak self] (message) in
            print("join channel failed")
            self?.joined = false
            self?.notifyWithError(error: WebSocketError(payload: message.payload, error: nil, type: .joinChannelError))
        })
    }

    private func resendSubscriptions() {
        for (seqNo, subscription) in self.subscriptions {
            self.write(subscription.payload, seqNo: seqNo)
        }
    }

    private func notifyWithError(subscriptionSeqNo: String? = nil, error: WebSocketError) {
        if  let seqNo: String = subscriptionSeqNo,
            let subscription: ABSDKSubscription = subscriptions[seqNo] {
            for(_, handler) in subscription.handlers {
                handler(nil, error)
            }
        } else {
            for (_, subscription) in subscriptions {
                for(_, handler) in subscription.handlers {
                    handler(nil, error)
                }
            }
        }
    }

    /// Send an subscription request
    ///
    /// - Parameters:
    ///   - operation: The subscription to send
    ///   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
    /// - Returns: An object that can be used to cancel the subscription.
    public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
        if let error = self.error {
            completionHandler(nil, error)
        }

        return WebSocketTask(self, operation) { (body, error) in
            if let body = body {
                let response = GraphQLResponse(operation: operation, body: body)
                completionHandler(response, error)
            } else {
                completionHandler(nil, error)
            }
        }
    }

    private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> Payload {
        if let variables: GraphQLMap = operation.variables {
            return ["query": operation.queryDocument, "variables": variables]
        }
        return ["query": operation.queryDocument]
    }

    private func equals(_ lhs: Any, _ rhs: Any) -> Bool {
        if let lhs = lhs as? Reference, let rhs = rhs as? Reference {
            return lhs == rhs
        }

        let lhs = lhs as AnyObject, rhs = rhs as AnyObject
        return lhs.isEqual(rhs)
    }

    private var sequenceNumber: Int = 0

    private func nextSeqNo() -> Int {
        sequenceNumber += 1
        return sequenceNumber
    }

    fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> (subscriptionSeqNo: String, handlerSeqNo: String) {
        let payload = requestBody(for: operation)

        var sub: ABSDKSubscription!
        var subscriptionSeqNo: String!

        for (seqNo, subscription) in subscriptions {
            if self.equals(subscription.payload, payload) {
                sub = subscription
                subscriptionSeqNo = seqNo
                break
            }
        }

        if subscriptionSeqNo == nil && sub == nil {
            sub = ABSDKSubscription(payload: payload)
            subscriptionSeqNo = "\(nextSeqNo())"
            subscriptions[subscriptionSeqNo!] = sub
            write(payload, seqNo: subscriptionSeqNo!)
        }

        let handlerSeqNo = sub.addHandler(handler: resultHandler)

        return (subscriptionSeqNo, handlerSeqNo)
    }

    private func write(_ payload: Payload, seqNo: String) {
        if let websocket = socket {
            if websocket.isConnected && joined {
                channel?.push(topic, payload: payload).receive("ok", callback: { [weak self] (message) in
                    if let response: [String: String] = message.payload["response"] as? [String: String],
                        let subscriptionId: String = response["subscriptionId"] {
                        self?.subscriptionIds[subscriptionId] = seqNo
                    }
                }).receive("error", callback: { [weak self] (message) in
                    self?.notifyWithError(subscriptionSeqNo: seqNo, error: WebSocketError(payload: message.payload, error: nil, type: .subscriptionError))
                })
            }
        }
    }

    /// Unsubscribe a subscription
    ///
    /// - Parameters:
    ///   - subscriptionSeqNo: The sequence number of a subscription
    ///   - handlerSeqNo: The sequence number of the handler
    public func unsubscribe(subscriptionSeqNo: String, handlerSeqNo: String) {
        let subscription: ABSDKSubscription = subscriptions[subscriptionSeqNo]!
        subscription.handlers.removeValue(forKey: handlerSeqNo)

        if subscription.handlers.count == 0 {
            subscriptions.removeValue(forKey: subscriptionSeqNo)
            for (subscriptionId, seqNo) in subscriptionIds where seqNo == subscriptionSeqNo {
                channel?.push("unsubscribe", payload: ["subscriptionId": subscriptionId]).receive("ok", callback: { (message) in
                    print(message.payload)
                }).receive("error", callback: { (message) in
                    print(message.payload)
                })
                subscriptionIds.removeValue(forKey: subscriptionId)
                break
            }
        }
    }

    /// Close the socket connection and reset the state
    public func closeConnection() {
        self.joined = false
        self.channel?.leave()
        self.socket?.disconnect()
        self.subscriptionIds.removeAll()
        self.subscriptions.removeAll()
    }
}

private final class WebSocketTask<Operation: GraphQLOperation> : Cancellable {

    let subscriptionSeqNo: String
    let handlerSeqNo: String
    let websocketTransport: ABSDKWebSocketTransport

    init(_ wst: ABSDKWebSocketTransport, _ operation: Operation, _ completionHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) {
        (subscriptionSeqNo, handlerSeqNo) = wst.sendHelper(operation: operation, resultHandler: completionHandler)
        websocketTransport = wst
    }

    public func cancel() {
        websocketTransport.unsubscribe(subscriptionSeqNo: subscriptionSeqNo, handlerSeqNo: handlerSeqNo)
    }

    // unsubscribe same as cancel
    public func unsubscribe() {
        cancel()
    }
}

/// Struct to wrap websocket related errors
public struct WebSocketError: Error, LocalizedError {

    /// The type of the websocket error
    public enum ErrorType {
        /// Network error, connection can't be established
        case networkError
        /// Join channel error, can't not join the Pheonix channel
        case joinChannelError
        /// Subscription error, can't execute subscription
        case subscriptionError

        var description: String {
            switch self {
            case .networkError:
                return "Websocket network error"
            case .joinChannelError:
                return "Websocket error: failed to join channel"
            case .subscriptionError:
                return "Websocket error: failed to execute subscription"
            }
        }
    }

    /// The payload of the response.
    public let payload: JSONObject?
    /// The error object of the response
    public let error: Error?
    /// They type of the error
    public let type: ErrorType
}
