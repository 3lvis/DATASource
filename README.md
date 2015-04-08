# DATASource

[![Version](https://img.shields.io/cocoapods/v/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)
[![License](https://img.shields.io/cocoapods/l/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)
[![Platform](https://img.shields.io/cocoapods/p/DATASource.svg?style=flat)](http://cocoadocs.org/docsets/DATASource)

## Usage

``` objc
DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                                  fetchRequest:fetchRequest
                                                cellIdentifier:ANDYCellIdentifier
                                                   configuration:^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
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
