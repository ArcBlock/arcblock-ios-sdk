//
//  ABSDKCustomScalarTypes.swift
//  Apollo
//
//  Created by Jonathan Lu on 21/9/2018.
//

import Apollo

public typealias BigNumber = String

public typealias DateTime = String

public typealias FunctionInput = [String: Any]

extension Dictionary: JSONDecodable where Key == String, Value == Any {
    public init(jsonValue value: JSONValue) throws {
        guard let dict = value as? [String: Any] else {
            throw JSONDecodingError.couldNotConvert(value: value, to: [String: Any].self)
        }
        self = dict
    }
}
