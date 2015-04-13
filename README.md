# DATASource

Using `NSFetchedResultsController` and `NSFetchedResultsControllerDelegate` is awesome, but sadly it involves a lot of boilerplate. Well, luckily with DATASource not anymore.

## UITableView

Hooking up your table view to your `Task` model and making your UITableView react to insertions, updates and deletions is as simple as this.

``` objc
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                                  fetchRequest:fetchRequest
                                                cellIdentifier:ANDYCellIdentifier
                                                 configuration:^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
                                                cell.textLabel.text = task.title;
                                            };

self.tableView.dataSource = dataSource;
```

## UICollectionView

Hooking up a UICollectionView is as simple as doing it with a UITableView, just use this method.

``` objc
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

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

Elvis Nuñez, [@3lvis](https://twitter.com/3lvis)

## License

**DATASource** is available under the MIT license. See the LICENSE file for more info.
