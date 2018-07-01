// AWSOfflineMutationStore.swift
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
import Apollo

public class ABSDKOfflineMutationStore {
    private var persistentCache: ABSDKMutationCache?
    var recordQueue = [String: ABSDKMutationRecord]()
    var processQueue = [ABSDKMutationRecord]()

    init(fileURL: URL? = nil) throws {
        if let fileURL = fileURL {
            self.persistentCache = try ABSDKMutationCache(fileURL: fileURL)
            try self.loadPersistedData()
        }
    }

    internal func loadPersistedData() throws {
        let _ = try self.persistentCache?.getStoredMutationRecordsInQueue().map({ record in
            recordQueue[record.recordIdentitifer] = record
            processQueue.append(record)
        })
    }

    internal func add(mutationRecord: ABSDKMutationRecord) {
        do {
            try _add(mutationRecord: mutationRecord)
        }
        catch {
        }
    }

    fileprivate func _add(mutationRecord: ABSDKMutationRecord) throws {
        recordQueue[mutationRecord.recordIdentitifer] = mutationRecord
        do {
            try persistentCache?.saveMutationRecord(record: mutationRecord)
        } catch {
        }
    }

    internal func removeRecordFromQueue(record: ABSDKMutationRecord) throws -> Bool {
        return try _removeRecordFromQueue(record: record)
    }

    fileprivate func _removeRecordFromQueue(record: ABSDKMutationRecord) throws -> Bool {
        do {
            try persistentCache?.deleteMutationRecord(record: record)
        } catch {}
        if let index = processQueue.index(where: {$0.recordIdentitifer == record.recordIdentitifer}) {
            processQueue.remove(at: index)
        }
        recordQueue.removeValue(forKey: record.recordIdentitifer)
        return true
    }

    internal func listAllMuationRecords() -> [String: ABSDKMutationRecord] {
        return recordQueue
    }
}

class MutationExecutor: NetworkConnectionNotification {

    var mutationQueue = [ABSDKMutationRecord]()
    let dispatchGroup = DispatchGroup()
    var isExecuting = false
    var shouldExecute = true

    let isExecutingDispatchGroup = DispatchGroup()
    var currentMutation: ABSDKMutationRecord?
    var networkClient: HTTPNetworkTransport
    var client: ABSDKClient
    var handlerQueue = DispatchQueue.main
    var store: ApolloStore?
    var apolloClient: ApolloClient?
    var autoSubmitOfflineMutations: Bool = true
    private var persistentCache: ABSDKMutationCache?
    var snapshotProcessController: SnapshotProcessController

    init(networkClient: HTTPNetworkTransport,
         client: ABSDKClient,
         snapshotProcessController: SnapshotProcessController,
         fileURL: URL? = nil) {
        self.networkClient = networkClient
        self.client = client
        self.snapshotProcessController = snapshotProcessController
        if let fileURL = fileURL {
            do {
                self.persistentCache = try ABSDKMutationCache(fileURL: fileURL)
                try self.loadPersistedData()
            } catch {
            }
        }
    }

    func onNetworkAvailabilityStatusChanged(isEndpointReachable: Bool) {
        if (isEndpointReachable) {
            if(listAllMuationRecords().count > 0 && autoSubmitOfflineMutations) {
                resumeMutationExecutions()
            }
        } else {
            pauseMutationExecutions()
        }
    }

    internal func loadPersistedData() throws {
        do {
            let _ = try self.persistentCache?.getStoredMutationRecordsInQueue().map({ record in
                mutationQueue.append(record)
            })
        } catch {}
    }

    func queueMutation(mutation: ABSDKMutationRecord) {
        mutationQueue.append(mutation)
        do {
            try persistentCache?.saveMutationRecord(record: mutation)
        } catch {
            // silent fail
        }

        // if the record is just queued and we are online, immediately submit the record
        if (snapshotProcessController.shouldExecuteOperation(operation: .mutation)
            && self.listAllMuationRecords().count == 1) {
            self.mutationQueue.removeFirst()
            mutation.inmemoryExecutor?.performMutation(dispatchGroup: dispatchGroup)
            do  {
                let _ = try self.removeRecordFromQueue(record: mutation)
            } catch {}
        }

    }

    internal func removeRecordFromQueue(record: ABSDKMutationRecord) throws -> Bool {
        return try _removeRecordFromQueue(record: record)
    }

    fileprivate func _removeRecordFromQueue(record: ABSDKMutationRecord) throws -> Bool {
        try persistentCache?.deleteMutationRecord(record: record)
        return true
    }

    internal func listAllMuationRecords() -> [ABSDKMutationRecord] {
        return mutationQueue
    }

    fileprivate func executeMutation(mutation: ABSDKMutationRecord) {
        if let inMemoryMutationExecutor = mutation.inmemoryExecutor {
            dispatchGroup.enter()
            inMemoryMutationExecutor.performMutation(dispatchGroup: dispatchGroup)
            self.mutationQueue.removeFirst()
            do {
                let _ = try self.removeRecordFromQueue(record: mutation)
            } catch {
            }
        } else {
            performPersistentOfflineMutation(mutation: mutation)
        }
    }

    fileprivate func performPersistentOfflineMutation(mutation: ABSDKMutationRecord) {
        func notifyResultHandler(record: ABSDKMutationRecord, result: JSONObject?, success: Bool, error: Error?) {
            handlerQueue.async {
                // call master delegate
                self.client.offlineMutationDelegate?.mutationCallback(recordIdentifier: record.recordIdentitifer, operationString: record.operationString!, snapshot: result, error: error)
            }
        }

        func deleteMutationRecord() {
            // remove from current queue
            let record = self.mutationQueue.removeFirst()
            // remove from persistent store
            do {
                let _ = try self.removeRecordFromQueue(record: record)
            } catch {
            }
        }

        func sendDataRequest(mutation: ABSDKMutationRecord) {
//            networkClient.send(data: mutation.data!) { (result, error) in
//                deleteMutationRecord()
//                guard let result = result else {
//                    notifyResultHandler(record: mutation, result: nil, success: false, error: error)
//                    self.dispatchGroup.leave()
//                    return
//                }
//
//                notifyResultHandler(record: mutation, result: result, success: true, error: nil)
//                self.dispatchGroup.leave()
//            }
        }

        dispatchGroup.enter()
        sendDataRequest(mutation: mutation)
        dispatchGroup.wait()
    }

    func pauseMutationExecutions() {
        shouldExecute = false
    }

    func resumeMutationExecutions() {
        shouldExecute = true
        executeAllQueuedMutations()
    }

    // executes all queued mutations synchronously
    func executeAllQueuedMutations() {
        if !isExecuting {
            isExecuting = true
            while !mutationQueue.isEmpty {
                if (shouldExecute) {
                    executeMutation(mutation: mutationQueue.first!)
                    currentMutation = mutationQueue.first
                } else {
                    // halt execution
                    break
                }
            }
            // update status to not executing
            isExecuting = false
        }
    }
}
