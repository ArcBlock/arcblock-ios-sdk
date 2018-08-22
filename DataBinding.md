# Data binding with ABSDKDataSource

In your UIViewControllers, you want to send a **query** or **subscription** and display its result in a **view**. You also want the result to be cached so that when the users went offline, they can still see the data, but when they get online, the view will be updated if there's a difference between the cache and the server result.

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
    detailDataSource = ABSDKObjectDataSource<AccountByAddressQuery, AccountByAddressQuery.Data.AccountByAddress>(client: arcblockClient, operation: AccountByAddressQuery(address: address), dataSourceMapper: detailSourceMapper, dataSourceUpdateHandler: detailDataSourceUpdateHandler)
    detailDataSource.observe()

    ...
}
```

The above codes create an ABSDKObjectDataSource, with a client, a query(or a subscription), a mapper closure and an update handler. Now the data source will handle networking, caching and live update for you.

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

As you can see the usage is very similar to ABSDKObjectDataSource, except that the ABSDKArrayDataSource provides the interface for you to use in UITableViewDataSource protocol.

#### Pagination

Pagination is also supported in data source level. You can use ABSDKPagedArrayDataSource to render paged arrays with UITableView or UICollectionView. It supports infinite scroll:

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

You need to specify a pageMapper closure for the data source to extra the paging info in the query result, and you can call the loadMore method in the UIScrollViewDelegate method. Now the tableView supports infinite scroll.

More code examples can be found [here](./Example/ocap-demo)