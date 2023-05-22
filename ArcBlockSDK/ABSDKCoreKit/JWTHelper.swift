// JWTHelper.swift
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


import Foundation
import JWTDecode

public enum JWTCheckError: Error, Equatable {
    case invalidJson
    case expired
    case serverError(errorMsg: String)
    case jwtVerifyError
    case pkIssNotMatch
    case vcEmpty
    case vcType
    case vcContent
    case invalidSignature(errorMsg: String)
    case opsNotMatch(errorMsg: String)
    
    public var localizedDescription: String {
        switch self {
        case .invalidJson:
            return "Json Data Structure error, parse json error"
        case .expired:
            return "JWT Expired"
        case .serverError(let errorMsg):
            return errorMsg
        case .jwtVerifyError:
            return "JWT verify error"
        case .pkIssNotMatch:
            return "JWT issuer error"
        case .vcEmpty:
            return "Verifiable is empty"
        case .vcType:
            return "Verifiableclaims type is not certificate"
        case .vcContent:
            return "Verifiableclaims token is empty"
        case .invalidSignature(let errorMsg):
            return errorMsg
        case .opsNotMatch(let errorMsg):
            return errorMsg
        }
    }
    
    public var code: Int {
        switch self {
        case .invalidJson:
            return 30020
        case .expired:
            return 30021
        case .serverError:
            return 30022
        case .jwtVerifyError:
            return 30023
        case .pkIssNotMatch:
            return 30024
        case .vcEmpty, .vcType, .vcContent, .invalidSignature, .opsNotMatch:
            return 33001
        }
    }
}

public class JWTHelper {
    static let DEFAULT_JWT_VERSION = "1.0"
    static let JWT_VERSION_REQUIRE_HASH_BEFORE_SIGN = "1.1.0"
    
    static func signUserInfo(body: [String: Any], did: String, userPrivateKey: Data, version: String?) -> String? {
        var jwtBody = body
        if let ver = version {
            jwtBody["version"] = ver
        } else {
            jwtBody["version"] = DEFAULT_JWT_VERSION
        }
        guard let didType = DidHelper.calculateTypesFromDid(did: did),
              let header = jwtEncode(jsonObject: ["alg": "\(didType.keyType.name())", "typ": "JWT"]),
            let body = jwtEncode(jsonObject: jwtBody),
            let message = hashDataIfNeeded(data: "\(header).\(body)".data(using: .utf8), version: version),
            let signature = didType.sign(message: message, privateKey: userPrivateKey)?.base64URLPadEncodedString() else {
                return nil
        }
        return "\(header).\(body).\(signature)"
    }

    static func jwtEncode(jsonObject: [String: Any]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let json = jsonData?.base64URLPadEncodedString()
        return json
    }
    
    static func checkAuthInfo(authInfo: String, appPk: String, agentPk: String?) -> Result<[String: Any], JWTCheckError> {
        guard let jwt = try? decode(jwt: authInfo) else {
            return .failure(.invalidJson)
        }
        
        guard !jwt.expired else {
            return .failure(.expired)
        }
        
        if let errorMessage = jwt.claim(name: "errorMessage").string {
            return .failure(.serverError(errorMsg: errorMessage))
        }
        
        let message = authInfo.components(separatedBy: ".").dropLast().joined(separator: ".")
        guard let signature = jwt.signature,
              let version = jwt.claim(name: "version").string,
              let signatureData = Data(base64URLPadEncoded: signature),
              let messageData = hashDataIfNeeded(data: message.data(using: .utf8), version: version),
              let did = jwt.issuer,
              let didType = DidHelper.calculateTypesFromDid(did: did) else {
            return .failure(.invalidSignature(errorMsg: "certificate verify error"))
        }
        
        if jwt.claim(name: "verifiableClaims").rawValue as? [[String: Any]] != nil,
           let agentDid = jwt.claim(name: "agentDid").string ?? jwt.claim(name: "to").string,
           let agentPk = agentPk, let issuer = jwt.issuer {
            let checkResult = checkCert(jwt: jwt, appPk: appPk, appDid: issuer)
            if case Result.failure(let error) = checkResult {
                return .failure(error)
            }
            guard let pkData = Data(multibaseEncoded: agentPk),
                  didType.verify(message: messageData, signature: signatureData, publicKey: pkData) else {
                return .failure(.jwtVerifyError)
            }
            
            guard DidHelper.addDidPrefix(DidHelper.pkToAddress(didType: didType, publicKey: pkData) ?? "") == DidHelper.addDidPrefix(agentDid) else {
                return .failure(.pkIssNotMatch)
            }
        } else {
            guard let pkData = Data(multibaseEncoded: appPk),
                  didType.verify(message: messageData, signature: signatureData, publicKey: pkData) else {
                return .failure(.jwtVerifyError)
            }
            guard DidHelper.addDidPrefix(DidHelper.pkToAddress(didType: didType, publicKey: pkData) ?? "") == DidHelper.addDidPrefix(did) else {
                return .failure(.pkIssNotMatch)
            }
        }
        return .success(jwt.body)
    }
    
    static func checkCert(jwt: JWT, appPk: String, appDid: String) -> Result<Void, JWTCheckError> {
        guard let verifiableClaims = jwt.claim(name: "verifiableClaims").rawValue as? [[String: Any]],
              let cert = verifiableClaims.first else {
            return .failure(.vcEmpty)
        }
        
        guard cert["type"] as? String == "certificate" else {
            return .failure(.vcType)
        }
        
        guard let token = cert["content"] as? String, token.contains(".") else {
            return .failure(.vcContent)
        }
        
        guard let jwtCert = try? decode(jwt: token) else {
            /// 抛出错误
            return .failure(.invalidJson)
        }
        
        guard !jwtCert.expired else {
            return .failure(.expired)
        }
        
        let tokenMessage = token.components(separatedBy: ".").dropLast().joined(separator: ".")
        guard let pkData = Data(multibaseEncoded: appPk),
              let signature = jwtCert.signature,
              let version = jwtCert.claim(name: "version").string,
              let signatureData = Data(base64URLPadEncoded: signature),
              let messageData = hashDataIfNeeded(data: tokenMessage.data(using: .utf8), version: version),
              let didType = DidHelper.calculateTypesFromDid(did: appDid),
              didType.verify(message: messageData, signature: signatureData, publicKey: pkData) else {
            return .failure(.invalidSignature(errorMsg: "certificate verify error"))
        }
        
        // 如果是代理appID
        let outAgentDid = jwt.claim(name: "agentDid").string ?? jwt.claim(name: "to").string
        let inAgentDid = jwtCert.claim(name: "agentDid").string ?? jwtCert.claim(name: "to").string
        guard DidHelper.addDidPrefix(inAgentDid ?? "") == DidHelper.addDidPrefix(outAgentDid ?? "") else {
            return .failure(.invalidSignature(errorMsg: "agent did not match issuer"))
        }
        let requestedClaimsTypes = (jwt.claim(name: "requestedClaims").rawValue as? [[String: Any]])?.compactMap { ($0["type"] as? String)?.lowercased() } ?? [String]()
        if let permissions = jwtCert.claim(name: "permissions").rawValue as? [[String: Any]], !permissions.isEmpty {
            //  如果是签署了 delegation
            guard let hasAgentPermission = permissions.first(where: { ($0["role"] as? String)?.uppercased() == "DIDConnectAgent".uppercased() }) else {
                return .failure(.invalidSignature(errorMsg: "Certificate no DIDConnectAgent permission"))
            }
            let allowedClaims = (hasAgentPermission["claims"] as? [String])?.compactMap { $0.lowercased() } ?? [String]()
            let notAllowClaimed = requestedClaimsTypes.filter { !allowedClaims.contains($0) }
            guard notAllowClaimed.isEmpty else {
                return .failure(.invalidSignature(errorMsg: "Certificate not allow claims: \(notAllowClaimed.joined(separator: ","))"))
            }
        } else {
            let types = requestedClaimsTypes.filter { $0.lowercased() != "authprincipal" }
            let ops = (jwtCert.claim(name: "ops").rawValue as? [String: Any] ?? [:]).map { $0.key }
            for type in types {
                guard ops.contains(type) else {
                    return .failure(.opsNotMatch(errorMsg: "claim \(type) has no permission"))
                }
            }
        }
        return .success(())
    }

    static func composeJWTBody(iss: String) -> [String: Any] {
        var body = [String: Any]()
        body["iss"] = iss
        let timestamp = Int(Date().timeIntervalSince1970)
        body["iat"] = String(timestamp)
        body["nbf"] = String(timestamp)
        body["exp"] = String(timestamp + 300)
        return body
    }
    
    private static func versionNeedHash(version: String) -> Bool {
        guard let versionNum = Int(version.components(separatedBy: ".").joined()),
              let requireHashVerionNum = Int(JWT_VERSION_REQUIRE_HASH_BEFORE_SIGN.components(separatedBy: ".").joined()) else {
            return false
        }
        
        if versionNum >= requireHashVerionNum {
            return true
        }
        
        return false
    }
    
    private static func hashDataIfNeeded(data: Data?, version: String?) -> Data? {
        guard let valueData = data else {
            return nil
        }

        var resultData: Data?
        if versionNeedHash(version: version ?? DEFAULT_JWT_VERSION) {
            resultData = MCrypto.Hasher.Sha3.sha256(valueData)
        } else {
            resultData = valueData
        }
        
        return resultData
    }
    
}
