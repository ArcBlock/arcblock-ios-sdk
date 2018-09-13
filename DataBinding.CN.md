# 使用ABSDKDataSource进行数据绑定

在您的UIViewControllers中，您通常会需要向OCAP service发送一些查询或者订阅请求，并将结果展示在界面中。同时您可能也希望请求的结果可以被缓存在本地，以便用户在没有网络的时候仍然可以查看。对于订阅请求而言，当数据出现更新之后，界面也需要能够使用最新的数据来刷新显示。

ABSDKDataSource就提供了这一系列功能。下面我们来看看他是如何工作的。

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
    detailDataSource = ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>(client: arcblockClient, operation: AccountByAddressQuery(address: address), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)
    detailDataSource.observe()

    ...
}
```

上面的代码创建了一个ABSDKObjectDataSource对象，并提供了client、query（或subscription）、一个mapper闭包以及一个update handler闭包作为参数。对创建好的data source对象调用observe方法，它将会帮助您发送网络请求，并处理缓存和动态更新。

#### TableView/CollectionView

在许多场景下，您需要查询的结果是一个数组，并将它们展示在UITableView/UICollectionView中。ABSDKArrayDataSource可以帮助您做到这一点：

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
        inputDataSource = ABSDKArrayDataSource<TransactionDetailQuery, TransactionDetailQuery.Data.TransactionByHash.Input.Datum>(client: arcblockClient, operation: TransactionDetailQuery(hash: txHash!), dataSourceMapper: inputSourceMapper, dataSourceUpdateHandler: inputDataSourceUpdateHandler)
        inputDataSource.observe()
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

您可以看到ABSDKArrayDataSource的使用方法类似于ABSDKObjectDataSource。它提供了一些额外的结构，供您在UITableViewDataSource扩展中使用。

#### 分页

在data source层面上，我们也支持分页。您可以使用ABSDKPagedArrayDataSource在UITableView或UICollectionView中展示分页的数组结果。它目前支持无限滚动：

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
        dataSource = ABSDKPagedArrayDataSource<RichestAccountsQuery, RichestAccountsQuery.Data.RichestAccount.Datum>(client: arcblockClient, operation: RichestAccountsQuery(), dataSourceMapper: dataSourceMapper, dataSourceUpdateHandler: dataSourceUpdateHandler, pageMapper: pageMapper)
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

和ABSDKArrayDataSource略有不同的地方在于，您需要额外指定一个pageMapper闭包，用于提取结果中的分页信息相关字段。此外，如果需要支持无限滚动，您需要在UIScrollViewDelegate扩展中调用data source的loadMore方法。

更多的示例代码可以查看[这里](./Example/ocap-demo)