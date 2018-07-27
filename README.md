# ArcBlock iOS SDK

[![Build Status](https://travis-ci.com/ArcBlock/arcblock-ios-sdk.svg?token=qqAgewfANpc6odwwyKWa&branch=master)](https://travis-ci.com/ArcBlock/arcblock-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<!-- [![Version](https://img.shields.io/cocoapods/v/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![License](https://img.shields.io/cocoapods/l/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK)
[![Platform](https://img.shields.io/cocoapods/p/ArcBlockSDK.svg?style=flat)](http://cocoapods.org/pods/ArcBlockSDK) -->

Welcome to ArcBlock iOS SDK! This is what you need to integrate your iOS apps with ArcBlock Platform. The ArcBlock iOS SDK is based on the Apollo project found [here](https://github.com/apollographql/apollo-ios).

## Requirements
The ArcBlock iOS SDK is compatible with apps supporting iOS 9 and above and requires Xcode 9 to build from source.

## Usage

### Installation

#### CocoaPods
ArcBlockSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
pod 'ArcBlockSDK', :git => 'https://github.com/ArcBlock/arcblock-ios-sdk.git'
pod 'Apollo', :git => 'https://github.com/ArcBlock/apollo-ios.git'
```

#### Carthage

To integrate ArcBlockSDK into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "ArcBlock/arcblock-ios-sdk"
```

Run `carthage` to build the framework and drag the built frameworks into your Xcode project.

### Codegen

To communicate with ArcBlock platform, you will need to use ArcBlock's Open Chain Access Protocol(OCAP) interface. It's a GraphQL interface that provides an unified endpoint for all data operation, and you as developer can customize your own requests(aka queries) under ArcBlock schema. You can go to [ArcBlock OCAP Playground](https://ocap.arcblock.io/) to write and test your ArcBlock OCAP queries. The playground is really easy to use, and is a great place to get started with OCAP API. For more information about GraphQL, please see its [website](https://graphql.org/).

One of the great things about GraphQL is that after the queries and schema is finalized, the data are strongly typed. So is Swift! That is to say, we can enforce the queries arguments and the return data type during compile time. This is why we provide this codegen tool to help you generate Swift codes that wraps your queries and works with this iOS SDK. No more type error in runtime!

The swift codegen is directly integrated into the OCAP Playground. After testing your queries, you can save them together as a playbook. Inside the playbook, you can see a **Generate Codes** button. Choose Swift as Language and generate, and an API.swift file will be downloaded to your local machine. Finally, you just need to drag the file to your project folder.


### Write your UIViewControllers

After you've done the codegen, you can now use our SDK API to write your UIViewControllers that send requests to OCAP service and display data.

#### Initiate an ABSDKClient

An ABSDKClient is a GraphQL client that's responsible for sending queries, resolving results, managing caches, etc.. You can create one client for each request, or share one across your app:

``` Swift
// in AppDelegate.swift

var arcblockClient: ABSDKClient!

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let databaseURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("YOUR_DB_NAME")
    do {
        // initialize the AppSync client configuration configuration
        let arcblockConfiguration = try ABSDKClientConfiguration(url: URL(string: "YOUR_OCAP_ENDPOINT")!,
                                                       databaseURL: databaseURL)
        // initialize app sync client
        arcblockClient = try ABSDKClient(configuration: arcblockConfiguration)
    } catch {
        print("Error initializing AppSync client. \(error)")
    }
    return true
}
```

#### Data binding with ABSDKDataSource

In your UIViewControllers, you want to send a **query** and display its result in a **view**. You also want the result to be cached, so that when the users went offline, they can still see the data, but when they get online, the view will be updated if there's a difference between the cache and the server result.

ABSDKDataSource takes care of it. Let's see how it works.

``` Swift
// in a ViewController.swift

var arcblockClient: ABSDKClient!

var detailDataSource: ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>!

@IBOutlet weak var detailView: AccountDetailView!

override func viewDidLoad() {
    super.viewDidLoad()

    // get the shared client
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    arcblockClient = appDelegate.arcblockClient

    // implement the data source mapper to specify which field in the query you want to bind with the view. The field can be a nested field.
    let detailSourceMapper: ObjectDataSourceMapper<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress> = { (data) in
        return data.accountByAddress
    }

    // implement a update handler to preform UI update logic when there's an data update or error occurred
    let detailDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
        if err != nil {
            return
        }
        self?.detailView.updateAddressData(address: (self?.detailDataSource.getObject())!)
    }

    // create the data source
    detailDataSource = ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>(client: arcblockClient, query: AccountByAddressQuery(address: address), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)

    ...
}
```

That's it! You create a ABSDKObjectDataSource, with a client, a query, a mapper callback and a update handler, and the data source will handle networking, caching and live update for you.

#### TableView/CollectionView

In many cases, you're requesting for an array of data, and rendering them using UITableView or UICollectionView. ABSDKArrayDataSource is for this:

``` Swift

class TransactionViewController: UIViewController {
    public var txHash: String? = nil

    var arcblockClient: ABSDKClient!

    @IBOutlet weak var tableView: UITableView!

    var inputDataSource: ABSDKArrayDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let inputSourceMapper: ArrayDataSourceMapper<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum> = { (data) in
            return data.transactionByHash?.inputs?.data
        }
        let inputDataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err == nil {
                self?.tableView.reloadData()
            }
        }
        inputDataSource = ABSDKArrayDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum>(client: arcblockClient, query: TransactionDetailQuery(hash: txHash!), dataSourceMapper: inputSourceMapper, dataSourceUpdateHandler: inputDataSourceUpdateHandler)
    }
}

extension TransactionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return inputDataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inputDataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "InputCell", for: indexPath) as! InputCell
      let data = inputDataSource.itemForIndexPath(indexPath: indexPath)
      cell.updateInputData(input: data!)
      return cell
    }
}
```

As you can see the usage is very similar to ABSDKObjectDataSource, except that the ABSDKArrayDataSource provides interface for you to use in UITableViewDataSource protocol.

#### Pagination

Pagination is also supported. You can use ABSDKPagedArrayDataSource to render paged arrays with UITableView or UICollectionView. It supports infinite scroll:

``` Swift

class RichestAccountsViewController: UIViewController {
    @IBOutlet weak var loadingFooter: UIView!
    @IBOutlet weak var tableView: UITableView!
    var arcblockClient: ABSDKClient!
    var dataSource: ABSDKPagedArrayDataSource<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum>!

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        arcblockClient = appDelegate.arcblockClient

        let dataSourceMapper: ArrayDataSourceMapper<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum> = { (data) in
            return data.richestAccounts?.data
        }
        let dataSourceUpdateHandler: DataSourceUpdateHandler = { [weak self] (err) in
            if err != nil {
                return
            }
            self?.tableView.reloadData()
            if let hasMore: Bool = self?.dataSource.hasMore {
                self?.tableView.tableFooterView = hasMore ? self?.loadingFooter : nil
            }
        }
        let pageMapper: PageMapper<RichestAccountsQuery> = { (data) in
            return (data.richestAccounts?.page)!
        }
        dataSource = ABSDKPagedArrayDataSource<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum>(client: arcblockClient, query: RichestAccountsQuery(), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler, pageMapper: pageMapper)
        dataSource.refresh()
    }
}

extension RichestAccountsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountListCell", for: indexPath) as! AccountListCell
        let data = dataSource.itemForIndexPath(indexPath: indexPath)
        cell.updateAccountData(account: data!)
        return cell
    }
}

extension RichestAccountsViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height {
            dataSource.loadMore()
        }
    }
}

```

You need to specify a PageMapper for data source to extra the paging info in the query result, and you can call the loadMore method in the UIScrollViewDelegate method. Now the tableView supports infinite scroll!

<!-- ## SDK Components

ArcBlock iOS SDK includes 4 kits, they are **ABSDKCoreKit**, **ABSDKAccountKit**, **ABSDKMessagingKit** and **ABSDKWalletKit**.

### ABSDKCoreKit
ABSDKCoreKit is the core module of the ArcBlock iOS SDK. It handles data persistence, networking and UI-data binding for higher level application logics. Other SDK components such as ABSDKAccountKit are based on ABSDKCoreKit. Altogether they serve as the cornerstones for all ArcBlock iOS apps, and can be used by many other developers to build apps on ArcBlock platform.

### ABSDKAccountKit

TBD

### ABSDKMessagingKit

TBD

### ABSDKWalletKit

TBD -->

## License

ArcBlockSDK is available under the MIT license. See the LICENSE file for more info.
