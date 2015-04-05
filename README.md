# DATASource

[![CI Status](http://img.shields.io/travis/3lvis/DATASource.svg?style=flat)](https://travis-ci.org/3lvis/DATASource)
[![Version](https://img.shields.io/cocoapods/v/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)
[![License](https://img.shields.io/cocoapods/l/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)
[![Platform](https://img.shields.io/cocoapods/p/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)

## Usage

How much does it take to insert a NSManagedObject into Core Data and show it in your UITableView in an animated way (using NSFetchedResultsController, of course)?

100 LOC? 200 LOC? 300 LOC?

Well, DATASource does it in **12 LOC**.

``` objc
DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                                  fetchRequest:fetchRequest
                                                cellIdentifier:ANDYCellIdentifier
                                                   mainContext:mainContext];

dataSource.configureCellBlock = ^(UITableViewCell *cell,
                                  Task *task,
                                  NSIndexPath *indexPath) {
    cell.textLabel.text = task.title;
};

self.tableView.dataSource = self.dataSource;
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
