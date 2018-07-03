// ABSDKSQLLiteNormalizedCache.swift
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
import SQLite

public enum ABSDKSQLLiteNormalizedCacheError: Error {
    case invalidRecordEncoding(record: String)
    case invalidRecordShape(object: Any)
    case invalidRecordValue(value: Any)
}

public final class ABSDKSQLLiteNormalizedCache: NormalizedCache {

    public init(fileURL: URL) throws {
        database = try Connection(.uri(fileURL.absoluteString), readonly: false)
        try createTableIfNeeded()
    }

    public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
        return Promise { try mergeRecords(records: records) }
    }

    public func clear() -> Promise<Void> {
        return Promise {
            return try clearRecords()
        }
    }

    public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
        return Promise {
            let records = try selectRecords(forKeys: keys)
            let recordsOrNil: [Record?] = keys.map { key in
                if let recordIndex = records.index(where: { $0.key == key }) {
                    return records[recordIndex]
                }
                return nil
            }
            return recordsOrNil
        }
    }

    private let database: Connection
    private let records = Table("records")
    private let identifier = Expression<Int64>("_id")
    private let key = Expression<CacheKey>("key")
    private let record = Expression<String>("record")

    private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
        var components = fieldCacheKey.components(separatedBy: ".")
        if components.count > 1 {
            components.removeLast()
        }
        return components.joined(separator: ".")
    }

    private func createTableIfNeeded() throws {
        try database.run(records.create(ifNotExists: true) { table in
            table.column(identifier, primaryKey: .autoincrement)
            table.column(key, unique: true)
            table.column(record)
        })
        try database.run(records.createIndex(key, unique: true, ifNotExists: true))
    }

    private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
        var recordSet = RecordSet(records: try selectRecords(forKeys: records.keys))
        let changedFieldKeys = recordSet.merge(records: records)
        let changedRecordKeys = changedFieldKeys.map { recordCacheKey(forFieldCacheKey: $0) }
        for recordKey in Set(changedRecordKeys) {
            if let recordFields = recordSet[recordKey]?.fields {
                let recordData = try SQLiteSerialization.serialize(fields: recordFields)
                guard let recordString = String(data: recordData, encoding: .utf8) else {
                    assertionFailure("Serialization should yield UTF-8 data")
                    continue
                }
                try database.run(self.records.insert(or: .replace, self.key <- recordKey, self.record <- recordString))
            }
        }
        return Set(changedFieldKeys)
    }

    private func selectRecords(forKeys keys: [CacheKey]) throws -> [Record] {
        let query = records.filter(keys.contains(key))
        return try database.prepare(query).map { try parse(row: $0) }
    }

    private func clearRecords() throws {
        try database.run(records.delete())
    }

    private func parse(row: Row) throws -> Record {
        let record = row[self.record]

        guard let recordData = record.data(using: .utf8) else {
            throw ABSDKSQLLiteNormalizedCacheError.invalidRecordEncoding(record: record)
        }

        let fields = try SQLiteSerialization.deserialize(data: recordData)
        return Record(key: row[key], fields)
    }
}

private let serializedReferenceKey = "$reference"

private final class SQLiteSerialization {
    static func serialize(fields: Record.Fields) throws -> Data {
        var objectToSerialize = JSONObject()
        for (key, value) in fields {
            objectToSerialize[key] = try serialize(fieldValue: value)
        }
        return try JSONSerialization.data(withJSONObject: objectToSerialize, options: [])
    }

    private static func serialize(fieldValue: Record.Value) throws -> JSONValue {
        switch fieldValue {
        case let reference as Reference:
            return [serializedReferenceKey: reference.key]
        case let array as [Record.Value]:
            return try array.map { try serialize(fieldValue: $0) }
        default:
            return fieldValue
        }
    }

    static func deserialize(data: Data) throws -> Record.Fields {
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        guard let jsonObject = object as? JSONObject else {
            throw ABSDKSQLLiteNormalizedCacheError.invalidRecordShape(object: object)
        }
        var fields = Record.Fields()
        for (key, value) in jsonObject {
            fields[key] = try deserialize(fieldJSONValue: value)
        }
        return fields
    }

    private static func deserialize(fieldJSONValue: JSONValue) throws -> Record.Value {
        switch fieldJSONValue {
        case let dictionary as JSONObject:
            guard let reference = dictionary[serializedReferenceKey] as? String else {
                throw ABSDKSQLLiteNormalizedCacheError.invalidRecordValue(value: fieldJSONValue)
            }
            return Reference(key: reference)
        case let array as [JSONValue]:
            return try array.map { try deserialize(fieldJSONValue: $0) }
        default:
            return fieldJSONValue
        }
    }
}
