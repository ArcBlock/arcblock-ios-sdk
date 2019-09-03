// ABSDKObjectView.swift
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

import UIKit
import Apollo

protocol ABSDKViewBinding {
    associatedtype Data: GraphQLSelectionSet
    func updateView(data: Data)
}

/// A base class for custom views that supports data binding
open class ABSDKView<Operation: GraphQLOperation, Data: GraphQLSelectionSet>: UIView, ABSDKViewBinding {

    var dataSource: ABSDKObjectDataSource<Operation, Data>?

    /// update view with data
    ///
    /// - Parameters:
    ///     - data: the latest data to update the view with
    open func updateView(data: Data) {
        // base class
    }

    func setupDataSource(client: ABSDKClient, operation: Operation, dataSourceMapper: @escaping ObjectDataSourceMapper<Operation, Data>) {
        if self.dataSource != nil {
            return
        }
        self.dataSource = ABSDKObjectDataSource<Operation, Data>(client: client, operation: operation, dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: { [weak self] (err) in
            if err != nil {
                return
            }
            self?.updateView(data: (self?.dataSource?.getObject())!)
        })
    }
}

public extension ABSDKView where Operation: GraphQLQuery {
    /// configure the data source of the view
    ///
    /// - Parameters:
    ///     - client: An ABSDKClient for sending requests
    ///     - operation: A GraphQL operation to get the object
    ///     - dataSourceMapper: A callback to extract the concerned object from the operation result
    public func configureDataSource(client: ABSDKClient, operation: Operation, dataSourceMapper: @escaping ObjectDataSourceMapper<Operation, Data>) {
        self.setupDataSource(client: client, operation: operation, dataSourceMapper: dataSourceMapper)
        self.dataSource?.observe()
    }
}

public extension ABSDKView where Operation: GraphQLSubscription {
    /// configure the data source of the view
    ///
    /// - Parameters:
    ///     - client: An ABSDKClient for sending requests
    ///     - operation: A GraphQL operation to get the object
    ///     - dataSourceMapper: A callback to extract the concerned object from the operation result
    public func configureDataSource(client: ABSDKClient, operation: Operation, dataSourceMapper: @escaping ObjectDataSourceMapper<Operation, Data>) {
        self.setupDataSource(client: client, operation: operation, dataSourceMapper: dataSourceMapper)
        self.dataSource?.observe()
    }
}

public protocol CellWithNib {
    static var nibName: String? { get }
}

open class ABSDKTableViewCell<Data: GraphQLSelectionSet>: UITableViewCell, ABSDKViewBinding {
    open func updateView(data: Data) {
        // base class
    }
}
