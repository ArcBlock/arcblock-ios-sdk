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

internal let sqlBusyTimeoutConstant = 100.0 // Fix a sqllite busy time out of 100ms

public enum MutationRecordState: String {
    case inProgress
    case inQueue
    case isDone
}

public enum MutationType: String {
    case graphQLMutation
    case graphQLMutationWithS3Object
}

protocol InMemoryMutationDelegate: class {
    func performMutation(dispatchGroup: DispatchGroup)
}

public class ABSDKMutationRecord {
    var jsonRecord: JSONObject?
    var data: Data?
    var contentMap: GraphQLMap?
    public var recordIdentitifer: String
    public var recordState: MutationRecordState = .inQueue
    var timestamp: Date
    var selections: [GraphQLSelection]?
    var operationTypeClass: String?
    var inmemoryExecutor: InMemoryMutationDelegate?
    var type: MutationType
    var operationString: String?

    init(recordIdentifier: String = UUID().uuidString, timestamp: Date = Date(), type: MutationType = .graphQLMutation) {
        self.recordIdentitifer = recordIdentifier
        self.timestamp = timestamp
        self.type = type
    }
}

public protocol MutationCache {
    func saveMutation(body: Data) -> Int64
    func getMutation(id: Int64) -> Data
    func loadAllMutation() -> [Int64: Data]
}

public final class ABSDKMutationCache {

    private let db: Connection
    private let mutationRecords = Table("mutation_records")
    private let id = Expression<Int64>("_id")
    private let recordIdentifier = Expression<CacheKey>("recordIdentifier")
    private let data = Expression<Data>("data")
    private let contentMap = Expression<String>("contentMap")
    private let recordState = Expression<String>("recordState")
    private let timestamp = Expression<Date>("timestamp")
    private let operationString = Expression<String>("operationString")

    public init(fileURL: URL) throws {
        db = try Connection(.uri(fileURL.absoluteString), readonly: false)
        db.busyTimeout = sqlBusyTimeoutConstant
        try createTableIfNeeded()
    }

    private func createTableIfNeeded() throws {
        try db.run(mutationRecords.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(recordIdentifier, unique: true)
            table.column(data)
            table.column(contentMap)
            table.column(recordState)
            table.column(timestamp)
            table.column(operationString)
        })
        try db.run(mutationRecords.createIndex(recordIdentifier, unique: true, ifNotExists: true))
    }

    internal func saveMutationRecord(record: ABSDKMutationRecord) throws {
        let insert = mutationRecords.insert(recordIdentifier <- record.recordIdentitifer,
                                            data <- record.data!,
                                            contentMap <- record.contentMap!.description,
                                            recordState <- record.recordState.rawValue,
                                            timestamp <- record.timestamp,
                                            operationString <- record.operationString!)
        try db.run(insert)

    }

    internal func updateMutationRecord(record: ABSDKMutationRecord) throws {
        let sqlRecord = mutationRecords.filter(recordIdentifier == record.recordIdentitifer)
        try db.run(sqlRecord.update(recordState <- record.recordState.rawValue))
    }

    internal func deleteMutationRecord(record: ABSDKMutationRecord) throws {
        let sqlRecord = mutationRecords.filter(recordIdentifier == record.recordIdentitifer)
        try db.run(sqlRecord.delete())
    }

    internal func getStoredMutationRecordsInQueue() throws -> [ABSDKMutationRecord] {
        let sqlRecords = mutationRecords.filter(recordState == MutationRecordState.inQueue.rawValue).order(timestamp.asc)
        var mutationRecordQueue = [ABSDKMutationRecord]()
        for record in try db.prepare(sqlRecords) {
            do {
                let mutationRecord = ABSDKMutationRecord(recordIdentifier: try record.get(recordIdentifier), timestamp: try record.get(timestamp))
                mutationRecord.data = try record.get(data)
                mutationRecord.recordState = .inQueue
                mutationRecord.operationString = try record.get(operationString)
                mutationRecordQueue.append(mutationRecord)
            } catch {
            }
        }
        return mutationRecordQueue
    }
}

public final class ABSDKSQLLiteNormalizedCache: NormalizedCache {

    public init(fileURL: URL) throws {
        db = try Connection(.uri(fileURL.absoluteString), readonly: false)
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

    private let db: Connection
    private let records = Table("records")
    private let id = Expression<Int64>("_id")
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
        try db.run(records.create(ifNotExists: true) { table in
            table.column(id, primaryKey: .autoincrement)
            table.column(key, unique: true)
            table.column(record)
        })
        try db.run(records.createIndex(key, unique: true, ifNotExists: true))
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
                try db.run(self.records.insert(or: .replace, self.key <- recordKey, self.record <- recordString))
            }
        }
        return Set(changedFieldKeys)
    }

    private func selectRecords(forKeys keys: [CacheKey]) throws -> [Record] {
        let query = records.filter(keys.contains(key))
        return try db.prepare(query).map { try parse(row: $0) }
    }

    private func clearRecords() throws {
        try db.run(records.delete())
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
