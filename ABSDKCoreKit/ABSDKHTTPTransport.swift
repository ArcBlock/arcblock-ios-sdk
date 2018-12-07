// ABSDKHTTPTransport.swift
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
import CryptoSwift

extension HTTPURLResponse {
    func isSuccessful(_ data: Data?) -> Bool {
        if (200..<300).contains(statusCode) {
            do {
                if  let data = data,
                    let body = try ABSDKJSONSerializationFormat.deserialize(data: data) as? JSONObject,
                    let errors = body["errors"] as? [JSONObject] {
                    return errors.count == 0
                }
            } catch {

            }
            return true
        }
        return false
    }

    var statusCodeDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }

    var textEncoding: String.Encoding? {
        guard let encodingName = textEncodingName else { return nil }

        return String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString)))
    }
}

/// A transport-level, HTTP-specific error.
public struct GraphQLHTTPResponseError: Error, LocalizedError {
    public enum ErrorKind {
        case errorResponse
        case invalidResponse

        var description: String {
            switch self {
            case .errorResponse:
                return "Received error response"
            case .invalidResponse:
                return "Received invalid response"
            }
        }
    }

    /// The body of the response.
    public let body: Data?
    /// Information about the response as provided by the server.
    public let response: HTTPURLResponse
    public let kind: ErrorKind

    public init(body: Data? = nil, response: HTTPURLResponse, kind: ErrorKind) {
        self.body = body
        self.response = response
        self.kind = kind
    }

    public var bodyDescription: String {
        if let body = body {
            if let description = String(data: body, encoding: response.textEncoding ?? .utf8) {
                return description
            } else {
                return "Unreadable response body"
            }
        } else {
            return "Empty response body"
        }
    }

    public var errorDescription: String? {
        if (200..<300).contains(response.statusCode) {
            do {
                if  let data = body,
                    let body = try ABSDKJSONSerializationFormat.deserialize(data: data) as? JSONObject,
                    let errors = body["errors"] as? [JSONObject],
                    let error = errors.first,
                    let description = error["message"] as? String {
                    if let statusCode = error["status"] as? Int {
                        return "\(kind.description) (\(statusCode) \(description))"
                    } else {
                        return "\(kind.description) (\(response.statusCode) \(description))"
                    }
                }
            } catch {

            }
        }
        return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
    }
}

public final class ABSDKJSONSerializationFormat {
    public class func serialize(value: JSONEncodable) throws -> Data {
        return try JSONSerialization.data(withJSONObject: value.jsonValue, options: [.sortedKeys])
    }

    public class func deserialize(data: Data) throws -> JSONValue {
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class ABSDKHTTPNetworkTransport: NetworkTransport {
    let url: URL
    let session: URLSession
    let serializationFormat = ABSDKJSONSerializationFormat.self

    var accessKey: String?
    var accessSecret: String?

    /// Creates a network transport with the specified server URL and session configuration.
    ///
    /// - Parameters:
    ///   - url: The URL of a GraphQL server to connect to.
    ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
    ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
    public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default, sendOperationIdentifiers: Bool = false,
                accessKey: String? = nil, accessSecret: String? = nil) {
        self.url = url
        self.session = URLSession(configuration: configuration)
        self.sendOperationIdentifiers = sendOperationIdentifiers
        self.accessKey = accessKey
        self.accessSecret = accessSecret
    }

    /// Send a GraphQL operation to a server and return a response.
    ///
    /// - Parameters:
    ///   - operation: The operation to send.
    ///   - completionHandler: A closure to call when a request completes.
    ///   - response: The response received from the server, or `nil` if an error occurred.
    ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
    /// - Returns: An object that can be used to cancel an in progress request.
    public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = requestBody(for: operation)
        do {
            request.httpBody = try serializationFormat.serialize(value: body)
        } catch {
            print("Error serializing request body. \(error)")
        }

        if let authHeader = getAuthHeaderValue(body: request.httpBody) {
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }

        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                completionHandler(nil, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Response should be an HTTPURLResponse")
            }

            let success = httpResponse.isSuccessful(data)
            if !success {
                completionHandler(nil, GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .errorResponse))
                return
            }

            guard let data = data else {
                completionHandler(nil, GraphQLHTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse))
                return
            }

            do {
                guard let body =  try self.serializationFormat.deserialize(data: data) as? JSONObject else {
                    throw GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                }
                let response = GraphQLResponse(operation: operation, body: body)
                completionHandler(response, nil)
            } catch {
                completionHandler(nil, error)
            }
        }

        task.resume()

        return task
    }

    private let sendOperationIdentifiers: Bool

    private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
        var deduplicatedVariables: GraphQLMap = GraphQLMap.init()
        if let variables = operation.variables {
            for (key, value) in variables where value != nil {
                deduplicatedVariables[key] = value
            }
        }
        if sendOperationIdentifiers {
            guard let operationIdentifier = operation.operationIdentifier else {
                preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
            }
            if deduplicatedVariables.count > 0 {
                return ["id": operationIdentifier, "variables": deduplicatedVariables]
            } else {
                return ["id": operationIdentifier]
            }
        }
        if deduplicatedVariables.count > 0 {
            return ["query": operation.queryDocument, "variables": deduplicatedVariables]
        } else {
            return ["query": operation.queryDocument]
        }
    }

    private func getAuthHeaderValue(body: Data?) -> String? {
        guard let accessKey = self.accessKey, let accessSecret = self.accessSecret else { return nil}

        do {
            let timestamp = String(format: "%.0f", floor(Date().timeIntervalSince1970))
            let hmac = HMAC(key: accessSecret.bytes, variant: .sha256)
            guard let body = body, let query = String(data: body, encoding: String.Encoding.utf8) else { return nil }

            let params = ["accessKey": accessKey, "query": query, "timestamp": timestamp].sorted { (arg0, arg1) -> Bool in
                let (key1, _) = arg1
                let (key2, _) = arg0
                return key1 > key2
            }
            var keyPairs: [String] = []
            let percentageEncodingAllowCharacterSet = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: ":,@#$&+"))
            for (key, value) in params {
                let keyPair = key + "=" + (value.addingPercentEncoding(withAllowedCharacters: percentageEncodingAllowCharacterSet) ?? "")
                keyPairs.append(keyPair)
            }
            let message = keyPairs.joined(separator: "&")
            guard let digest: String = try hmac.authenticate(message.bytes).toBase64() else { return nil }

            return "AB1-HMAC-SHA256 access_key=" + accessKey + ",timestamp=" + timestamp + ",signature=" + digest
        } catch {
            print("Error calculating hmac. \(error)")
        }

        return nil
    }
}
