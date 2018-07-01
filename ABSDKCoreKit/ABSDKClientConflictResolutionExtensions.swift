// AWSAppSyncClientConflictResolutionExtensions.swift
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

enum MutationQueuePosition {
    case start
    case end
}

class ConflictMutation<Mutation: GraphQLMutation> {
    let mutation: Mutation
    let position: MutationQueuePosition

    init(mutation: Mutation, position: MutationQueuePosition) {
        self.mutation = mutation
        self.position = position
    }
}

extension ABSDKClient {

    internal func send<Operation: GraphQLMutation>(operation: Operation, context: UnsafeMutableRawPointer?, dispatchGroup: DispatchGroup, handlerQueue: DispatchQueue, resultHandler: OperationResultHandler<Operation>?) -> Cancellable {
        func notifyResultHandler(result: GraphQLResult<Operation.Data>?, error: Error?) {
            dispatchGroup.leave()
            guard let resultHandler = resultHandler else { return }

            handlerQueue.async {
                resultHandler(result, error)
            }
        }

        return self.httpTransport!.send(operation: operation) { (response, error) in
            guard let response = response else {
                notifyResultHandler(result: nil, error: error)
                return
            }

            firstly {
                try response.parseResult(cacheKeyForObject: self.store!.cacheKeyForObject)
                }.andThen { (result, records) in
                    if let resultError = result.errors,
//                        let conflictResolutionBlock = conflictResolutionBlock,
                        let error = resultError.first,
                        error.localizedDescription.hasPrefix("The conditional request failed") {
                        let error = resultError[0]
                        if error.localizedDescription.hasPrefix("The conditional request failed") {
//                            let serverState = error["data"] as? JSONObject
//                            let taskCompletionSource = AWSTaskCompletionSource<Operation>()
//                            conflictResolutionBlock(serverState, taskCompletionSource, nil)
//                            taskCompletionSource.task.continueWith(block: { (task) -> Any? in
//                                if let mutation = task.result {
//                                    let _ = self.send(operation: mutation, context: nil, conflictResolutionBlock: nil, dispatchGroup: dispatchGroup, handlerQueue: handlerQueue, resultHandler: resultHandler)
//                                }
//                                return nil
//                            }).waitUntilFinished()
                        }
                    } else {
                        notifyResultHandler(result: result, error: nil)
//                        if let records = records {
//                            self.store?.publish(records: records, context: context).catch { error in
//                                preconditionFailure(String(describing: error))
//                            }
//                        }
                    }
                }.catch { error in
                    notifyResultHandler(result: nil, error: error)
            }
        }
    }
}
