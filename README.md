# DataSource

Using `NSFetchedResultsController` and `NSFetchedResultsControllerDelegate` is awesome, but sadly it involves a lot of boilerplate. Well, luckily with DataSource not anymore.

## UITableView

### Basic Usage

Hooking up your table view to your `Task` model and making your UITableView react to insertions, updates and deletions is as simple as this.

``` objc
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

DataSource *dataSource = [[DataSource alloc] initWithTableView:self.tableView
                                                  fetchRequest:fetchRequest
                                                   sectionName:nil
                                                cellIdentifier:ANDYCellIdentifier
                                                   mainContext:context
                                                 configuration:^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
                                                cell.textLabel.text = task.title;
                                            };

self.tableView.dataSource = dataSource;
```

### Indexed UITableView

`DataSource` provides an easy way to show an indexed UITableView, you just need to specify the attribute we should use to group your items. This attribute is located in the `dataSource` initializer as a parameter called `sectionName`.

Check the [Swift Demo](https://github.com/3lvis/DataSource/tree/master/Demos/TableView) for an example of this, were we have an indexed UITableView of names, just like the Contacts.app!

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/DataSource/master/GitHub/table.gif" />
</p>

### UITableViewDataSource

`DataSource` takes ownership of your `UITableViewDataSource` providing boilerplate functionality for the most common tasks, but if you need to override any of the `UITableViewDataSource` methods you can use the `DataSourceDelegate`.

## UICollectionView

### Basic Usage

Hooking up a UICollectionView is as simple as doing it with a UITableView, just use this method.

``` objc
NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

DataSource *dataSource = [[DataSource alloc] initWithCollectionView:self.collectionView
                                                       fetchRequest:fetchRequest
                                                        sectionName:sectionName
                                                     cellIdentifier:ANDYCellIdentifier
                                                        mainContext:context
                                                      configuration:^(UICollectionView *cell, Task *task, NSIndexPath *indexPath) {
                                                cell.textLabel.text = task.title;
                                            };

self.collectionView.dataSource = dataSource;
```

### Indexed UITableView

`DataSource` provides an easy way to show an grouped UICollectionView, you just need to specify the attribute we should use to group your items. This attribute is located in the `dataSource` initializer as a parameter called `sectionName`. This will create a collectionView reusable header.

Check the [CollectionView Demo](https://github.com/3lvis/DataSource/tree/master/Demos/CollectionView) for an example of this, were we have a grouped UICollectionView using the first letter of a name as a header, just like the Contacts.app!

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/DataSource/master/GitHub/collection.gif" />
</p>

### UICollectionViewDataSource

`DataSource` takes ownership of your `UICollectionViewDataSource` providing boilerplate functionality for the most common tasks, but if you need to override any of the `UICollectionViewDataSource` methods you can use the `DataSourceDelegate`. Check the [CollectionView Demo](https://github.com/3lvis/DataSource/tree/master/Demos/CollectionView) where we show how to add a footer view to your `DataSource` backed UICollectionView.

## Installation

**DataSource** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DataSource'
```

## Author

Elvis Nuñez, [@3lvis](https://twitter.com/3lvis)

## License

**DataSource** is available under the MIT license. See the LICENSE file for more info.
