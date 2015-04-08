## UITableView

``` objc
DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                                  fetchRequest:fetchRequest
                                                cellIdentifier:ANDYCellIdentifier
                                                   configuration:^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
                                                cell.textLabel.text = task.title;
                                            };

self.tableView.dataSource = dataSource;
```

## UICollectionView

``` objc
DATASource *dataSource = [[DATASource alloc] initWithCollectionView:self.collectionView
                                                       fetchRequest:fetchRequest
                                                     cellIdentifier:ANDYCellIdentifier
                                                      configuration:^(UICollectionView *cell, Task *task, NSIndexPath *indexPath) {
                                                cell.textLabel.text = task.title;
                                            };

self.collectionView.dataSource = dataSource;
```

## Installation

**DATASource** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DATASource'
```

## Author

Elvis Nuñez, elvisnunez@me.com

## License

**DATASource** is available under the MIT license. See the LICENSE file for more info.
