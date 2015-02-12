DATASource
=================================

How much does it take to insert a NSManagedObject into CoreData and show it in your UITableView in an animated way (using NSFetchedResultsController, of course)?

100 LOC? 200 LOC? 300 LOC?

Well, DATASource does it in 71 LOC.

``` objc
DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView 
                                      fetchedResultsController:self.fetchedResultsController
                                                cellIdentifier:ANDYCellIdentifier];

dataSource.configureCellBlock = ^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@ (%@)", task.title, task.date, indexPath];
};

self.tableView.dataSource = self.dataSource;
```

Attribution
===========

Based on the work of the awesome guys at [objc.io](http://www.objc.io/).

Be Awesome
==========

If something looks stupid, please create a friendly and constructive issue, getting your feedback would be awesome. Have a great day.

## Author

Elvis Nuñez, hello@nselvis.com

## License

**DATASource** is available under the MIT license. See the LICENSE file for more info.
