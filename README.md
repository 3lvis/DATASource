# DATASource

If you are not familiarized with [NSFetchedResultsController](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsController_Class/index.html), it allows you to efficiently manage the results returned from a `Core Data` fetch request to provide data for a `UITableView` or a `UICollectionView`. `NSFetchedResultsController` monitors changes in `Core Data` objects and notifies the view about those changes allowing you to be reactive about them.<sup>[1](#footnote1)<sup>

Using `NSFetchedResultsController` and `NSFetchedResultsControllerDelegate` is awesome, but sadly it involves a lot of boilerplate. Well, luckily with DATASource not anymore.

- Encapsulates NSFetchedResultsController and NSFetchedResultsControllerDelegate boilerplate
- Supports indexed tables out of the box
- Supports sectioned collections out of the box
- Swift
- Objective-C compatibility

## Table of Contents

* [Running the demos](#running-the-demos)
* [UITableView](#uitableview)
  * [Basic Usage](#basic-usage)
  * [Sectioned UITableView](#sectioned-uitableview)
  * [Sectioned UITableView Without Indexes](#sectioned-uitableview-without-indexes)
  * [Custom Headers](#custom-headers)
  * [UITableViewDataSource](#uitableviewdatasource)
* [UICollectionView](#example)
  * [Basic Usage](#basic-usage-1)
  * [Sectioned UICollectionViewController](#sectioned-uicollectionviewcontroller)
  * [UICollectionViewDataSource](#uicollectionviewdatasource)
* [Customizing change animations](#customizing-change-animations) 
* [Installation](#installation)
* [Author](#author)
* [License](#license)
* [Footnotes](#footnotes)

## Running the demos
Before being able to run the demos you have to install the demo dependencies using [Carthage](https://github.com/Carthage/Carthage).

- [ ] Install Carthage
- [ ] Run `carthage update`
- [ ] Enjoy!

## UITableView

### Basic Usage

Hooking up your table view to your `Task` model and making your UITableView react to insertions, updates and deletions is as simple as this.

**Swift:**
```swift
let request: NSFetchRequest = NSFetchRequest(entityName: "Task")
request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
    cell.textLabel?.text = item.valueForKey("title") as? String
})

tableView.dataSource = dataSource
```

**Objective-C:**
```objc
NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

DATASource *dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                                cellIdentifier:@"Cell"
                                                  fetchRequest:request
                                                   mainContext:self.dataStack.mainContext
                                                   sectionName:nil
                                                 configuration:^(UITableViewCell * _Nonnull cell, NSManagedObject * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                                                     cell.textLabel.text = [item valueForKey:@"name"];
                                                 }];

self.tableView.dataSource = dataSource;
```

### Sectioned UITableView

**DATASource** provides an easy way to show an sectioned UITableView, you just need to specify the attribute we should use to group your items. This attribute is located in the `dataSource` initializer as a parameter called `sectionName`.

Check the [Swift Demo](https://github.com/3lvis/DATASource/blob/master/TableSwift/ViewController.swift) for an example of this, were we have an sectioned UITableView of names, where each section is defined by the first letter of the name, just like the Contacts app!

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/DATASource/master/GitHub/table.gif" />
</p>

### Sectioned UITableView Without Indexes

You can disable the indexes by overwritting the method that generates them and just return an empty list of indexes. Add the `DATASourceDelegate` protocol to your controller then implement the `sectionIndexTitlesForDataSource:dataSource:tableView` method, like this:

```swift
self.dataSource.delegate = self

extension MyController: DATASourceDelegate {
    func sectionIndexTitlesForDataSource(dataSource: DATASource, tableView: UITableView) -> [String] {
        return [String]()
    }
}
```

### Custom Headers

By default **DATASource** uses the UITableView's built-in header. But many apps require the use of custom headers when using sectioned table views. To be able to use your [custom header view](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UITableViewDelegate_Protocol/#//apple_ref/occ/intfm/UITableViewDelegate/tableView:viewForHeaderInSection:), you will need to disable the built-in header by implementing `dataSource:tableView:titleForHeaderInSection:` in the DATASourceDelegate so it returns `nil`:

```swift
self.dataSource.delegate = self

extension MyController: DATASourceDelegate {
    func dataSource(dataSource: DATASource, tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
}
```

**DATASource** also provides [a simple method to get the title for an specific section](https://github.com/3lvis/DATASource/blob/d2e095cc864cef5363b571898210baf3feffa50e/Source/DATASource.swift#L156), useful when dealing with custom headers.

```swift
let sectionTitle = self.dataSource.titleForHeaderInSection(section)
```

### UITableViewDataSource

**DATASource** takes ownership of your `UITableViewDataSource` providing boilerplate functionality for the most common tasks, but if you need to override any of the `UITableViewDataSource` methods you can use the [`DATASourceDelegate`](/Source/DATASourceDelegate.swift).

## UICollectionView

### Basic Usage

Hooking up a UICollectionView is as simple as doing it with a UITableView, just use this method.

**Swift**:
```swift
let request: NSFetchRequest = NSFetchRequest(entityName: "Task")
request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

let dataSource = DATASource(collectionView: self.collectionView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
    cell.textLabel.text = item.valueForKey("title") as? String
})

collectionView.dataSource = dataSource
```

**Objective-C:**
```objc
NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];

DATASource *dataSource = [[DATASource alloc] initWithCollectionView:self.collectionView
                                                     cellIdentifier:CollectionCellIdentifier
                                                       fetchRequest:request
                                                        mainContext:self.dataStack.mainContext
                                                        sectionName:nil
                                                      configuration:^(UICollectionViewCell * _Nonnull cell, NSManagedObject * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                                                          CollectionCell *collectionCell = (CollectionCell *)cell;
                                                          [collectionCell updateWithText:[item valueForKey:@"name"]];
                                                      }];

self.collectionView.dataSource = dataSource;
```

### Sectioned UICollectionViewController

**DATASource** provides an easy way to show an grouped UICollectionView, you just need to specify the attribute we should use to group your items. This attribute is located in the `dataSource` initializer as a parameter called `sectionName`. This will create a collectionView reusable header.

Check the [CollectionView Demo](https://github.com/3lvis/DATASource/tree/master/CollectionSwift) for an example of this, were we have a grouped UICollectionView using the first letter of a name as a header, just like the Contacts.app!

<p align="center">
  <img src="https://raw.githubusercontent.com/3lvis/DATASource/master/GitHub/collection.gif" />
</p>

### UICollectionViewDataSource

**DATASource** takes ownership of your `UICollectionViewDataSource` providing boilerplate functionality for the most common tasks, but if you need to override any of the `UICollectionViewDataSource` methods you can use the `DATASourceDelegate`. Check the [CollectionView Demo](https://github.com/3lvis/DATASource/tree/master/CollectionSwift) where we show how to add a footer view to your **DATASource** backed UICollectionView.

## Customizing change animations

By default `UITableViewRowAnimation.Automatic` is used to animate inserts, updates and deletes, but if you want to overwrite this animation types you can use the `animations` dictionary on **DATASource**.

### Animate insertions using fade
```swift
let dataSource = ...
dataSource.animations[.Insert] = .Fade
```

### Disabling all animations
```swift
let dataSource = ...
dataSource.animations = [.Update: .None, .Move  : .None, .Insert: .None]
```

## Installation

**DATASource** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DATASource'
```

**DATASource** is also available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Cartfile:

```ruby
github '3lvis/DATASource'
```

## Author

Elvis Nuñez, [@3lvis](https://twitter.com/3lvis)

## License

**DATASource** is available under the MIT license. See the LICENSE file for more info.

## Footnotes:

<a name="footnote1">1.-</a> Quoted from the [RealmResultsController](https://redbooth.com/engineering/ios/realmresultscontroller) article.
