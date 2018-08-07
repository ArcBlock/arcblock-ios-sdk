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

public class ABSDKSplitNetworkTransport: NetworkTransport {
    private let httpNetworkTransport: NetworkTransport
    private let webSocketNetworkTransport: NetworkTransport

    public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport) {
        self.httpNetworkTransport = httpNetworkTransport
        self.webSocketNetworkTransport = webSocketNetworkTransport
    }

    public func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
        if operation.operationType == .subscription {
            return webSocketNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        } else {
            return httpNetworkTransport.send(operation: operation, completionHandler: completionHandler)
        }
    }
}

struct ABSDKSubscription {
    var payload: Payload!
    var callback: (JSONObject?, Error?) -> Void

    init(payload: Payload, callback: @escaping (JSONObject?, Error?) -> Void) {
        self.payload = payload
        self.callback = callback
    }
}

/// A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.
public class ABSDKWebSocketTransport: NetworkTransport {

    var socket: Socket? = nil
    var channel: Channel? = nil
    var error : Error? = nil

    let serializationFormat = JSONSerializationFormat.self
    let topic = "doc"

    var reconnect : Bool = false
    var joined: Bool = false

    private var params: [String:String]?
    private var connectingParams: [String:String]?

    private var subscribers = [String: (JSONObject?, Error?) -> Void]()
    private var subscriptions : [String: ABSDKSubscription] = [:]

    private let sendOperationIdentifiers: Bool

    public init(url: URL, sendOperationIdentifiers: Bool = false, params: [String:String]? = nil, connectingParams: [String:String]? = [:]) {
        self.params = params
        self.connectingParams = connectingParams
        self.sendOperationIdentifiers = sendOperationIdentifiers
        var request = URLRequest(url: url)
        if let params = self.params {
            request.allHTTPHeaderFields = params
        }
        self.socket = Socket(url: url, params: params)

        self.socket?.onOpen { [weak self] in
            self?.websocketDidConnect()
        }

        self.socket?.onClose { [weak self] in
            self?.websocketDidDisconnect()
        }

        self.socket?.onError(callback: { [weak self] (err) in
            self?.websocketDidFailed(error: err)
        })

        self.socket?.onMessage(callback: { [weak self] (message) in
            print(message.payload)
            if message.event == "subscription:data" {
                if let subscriptionId: String = message.payload["subscriptionId"] as? String,
                    let callback: (JSONObject?, Error?) -> Void = self?.subscribers[subscriptionId],
                    let result: JSONObject = message.payload["result"] as? JSONObject{
                    callback(result, nil)
                }
            }
        })

        self.socket?.connect()
    }

    deinit {
        socket?.disconnect()
    }

    public func isConnected() -> Bool {
        return socket?.isConnected ?? false
    }

    fileprivate func joinChannel() {
        self.channel = self.socket?.channel("__absinthe__:control")
        self.channel?.join().receive("ok", callback: { [weak self] (message) in
            self?.joined = true

            // re-send the subscriptions whenever we are re-connected
            // for the first connect, any subscriptions are already in queue
            for (id, subscription) in (self?.subscriptions)! {
                self?.write(subscription.payload, id: id)
            }
        }).receive("error", callback: { [weak self] (message) in
            print("join channel failed")
            self?.joined = false
        })
    }

    fileprivate func websocketDidConnect() {
        self.error = nil
        self.joinChannel()
    }

    fileprivate func websocketDidDisconnect() {
        self.error = nil
        joined = false
        if (reconnect) {
            socket?.connect()
        }
    }

    fileprivate func websocketDidFailed(error: Error) {
        self.error = WebSocketError(payload: nil, error: error, kind: .networkError)
        joined = false
        for (_,responseHandler) in subscribers {
            responseHandler(nil,error)
        }
    }

    public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {

        if let error = self.error {
            completionHandler(nil,error)
        }

        return WebSocketTask(self, operation) { (body, error) in
            if let body = body {
                let response = GraphQLResponse(operation: operation, body: body)
                completionHandler(response,error)
            } else {
                completionHandler(nil,error)
            }
        }

    }

    fileprivate final class WebSocketTask<Operation: GraphQLOperation> : Cancellable {

        let seqNo : String?
        let wst: ABSDKWebSocketTransport

        init(_ ws: ABSDKWebSocketTransport, _ operation: Operation, _ completionHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) {

            seqNo = ws.sendHelper(operation: operation, resultHandler: completionHandler)
            wst = ws
        }

        public func cancel() {
            if let seqNo = seqNo {
                wst.unsubscribe(seqNo)
            }
        }

        // unsubscribe same as cancel
        public func unsubscribe() {
            cancel()
        }
    }

    private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
        if sendOperationIdentifiers {
            guard let operationIdentifier = operation.operationIdentifier else {
                preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
            }
            return ["id": operationIdentifier, "variables": operation.variables]
        }
        return ["query": operation.queryDocument, "variables": operation.variables]
    }

    fileprivate func sendHelper<Operation: GraphQLOperation>(operation: Operation, resultHandler: @escaping (_ response: JSONObject?, _ error: Error?) -> Void) -> String? {

        let payload = requestBody(for: operation)
        let seqNo = "\(nextSeqNo())"
        subscriptions[seqNo] = ABSDKSubscription(payload: payload, callback: resultHandler)
        write(payload, id: seqNo)

        return seqNo
    }

    fileprivate var sequenceNumber : Int = 0

    fileprivate func nextSeqNo() -> Int {
        sequenceNumber += 1
        return sequenceNumber
    }


    public func unsubscribe(_ subscriptionId: String) {
        // TODO: send unsubscribe message
        subscribers.removeValue(forKey: subscriptionId)
        subscriptions.removeValue(forKey: subscriptionId)
    }

    func notifyErrorAllHandlers(_ error: Error) {
        for (_,handler) in subscribers {
            handler(nil,error)
        }
    }

    public func closeConnection() {
        self.reconnect = false
        self.joined = false
        self.channel?.leave()
        self.socket?.disconnect()
        self.subscribers.removeAll()
        self.subscriptions.removeAll()
    }

    private func write(_ payload: Payload, id: String) {

        if let websocket = socket {
            if websocket.isConnected && joined {
                channel?.push(topic, payload: payload).receive("ok", callback: { [weak self] (message) in
                    if let response: [String: String] = message.payload["response"] as? [String: String],
                        let callback: (JSONObject?, Error?) -> Void = self?.subscriptions[id]?.callback,
                        let subscriptionId: String = response["subscriptionId"] {
                        self?.subscribers[subscriptionId] = callback
                    }
                }).receive("error", callback: { (message) in
                    // TODO: handle error
                })
            }
        }
    }
}

public struct WebSocketError: Error, LocalizedError {
    public enum ErrorKind {
        case errorResponse
        case networkError
        case unprocessedMessage(String)
        case serializedMessageError

        var description: String {
            switch self {
            case .errorResponse:
                return "Received error response"
            case .networkError:
                return "Websocket network error"
            case .unprocessedMessage(let message):
                return "Websocket error: Unprocessed message \(message)"
            case .serializedMessageError:
                return "Websocket error: Serialized message not found"
            }
        }
    }

    /// The payload of the response.
    public let payload: JSONObject?
    public let error: Error?
    public let kind: ErrorKind
}
