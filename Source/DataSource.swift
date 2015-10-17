import UIKit
import CoreData

@objc public protocol DataSourceDelegate: class {
    optional func dataSource(dataSource: DataSource, didInsertObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DataSource, didUpdateObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DataSource, didDeleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DataSource, didMoveObject object: NSManagedObject, fromIndexPath oldIndexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath)

    /*!
    * **************************
    *
    * UITableView specific
    *
    * **************************
    */

    // Sections and Headers

    optional func sectionIndexTitlesForDataSource(dataSource: DataSource, tableView: UITableView) -> [String]?
    optional func dataSource(dataSource: DataSource, tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    optional func dataSource(dataSource: DataSource, tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    optional func dataSource(dataSource: DataSource, tableView: UITableView, titleForFooterInSection section: Int) -> String?

    // Editing

    optional func dataSource(dataSource: DataSource, tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func dataSource(dataSource: DataSource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)

    // Moving or Reordering

    optional func dataSource(dataSource: DataSource, tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func dataSource(dataSource: DataSource, tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)

    /*!
    * **************************
    *
    * UICollectionView specific
    *
    * **************************
    */

    optional func dataSource(dataSource: DataSource, collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
}

public class DataSource: NSObject {
    private weak var tableView: UITableView?
    private weak var collectionView: UICollectionView?
    private var sectionName: String?
    private var cellIdentifier: String
    private weak var mainContext: NSManagedObjectContext?
    private var tableConfigurationBlock: ((cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?
    private var collectionConfigurationBlock: ((cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?

    public weak var delegate: DataSourceDelegate?

    private var fetchedResultsController: NSFetchedResultsController

    private lazy var objectChanges: [NSFetchedResultsChangeType : [NSIndexPath]] = {
        return [NSFetchedResultsChangeType : [NSIndexPath]]()

        }()

    private lazy var sectionChanges: [NSFetchedResultsChangeType : NSMutableIndexSet] = {
        return [NSFetchedResultsChangeType : NSMutableIndexSet]()
        }()

    private lazy var cachedSectionNames: [String] = {
        return [String]()
        }()

    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: (cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: configuration, collectionConfiguration: nil)

        self.tableView = tableView
        self.tableView?.dataSource = self
    }

    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: (cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: nil, collectionConfiguration: configuration)

        self.collectionView = collectionView
        self.collectionView?.dataSource = self

        self.collectionView?.registerClass(DataSourceCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DataSourceCollectionViewHeader.Identifier);
    }

    private init(cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, tableConfiguration: ((cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?, collectionConfiguration: ((cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?) {
        self.cellIdentifier = cellIdentifier
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: sectionName, cacheName: nil)
        self.tableConfigurationBlock = tableConfiguration
        self.collectionConfigurationBlock = collectionConfiguration

        super.init()

        self.fetchedResultsController.delegate = self
        self.fetch()
    }

    public var predicate: NSPredicate? {
        get {
            return self.fetchedResultsController.fetchRequest.predicate
        }

        set {
            self.cachedSectionNames = [String]()
            self.fetchedResultsController.fetchRequest.predicate = newValue
            self.fetch()
            self.tableView?.reloadData()
            self.collectionView?.reloadData()
        }
    }

    public var objectsCount: Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    public var isEmpty: Bool {
        return self.fetchedResultsController.fetchedObjects?.count == 0
    }

    public var objects: [NSManagedObject] {
        return self.fetchedResultsController.fetchedObjects as?  [NSManagedObject] ?? [NSManagedObject]()
    }

    public func objectAtIndexPath(indexPath: NSIndexPath) -> NSManagedObject? {
        return self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject ?? nil
    }

    public func indexPathForObject(object: NSManagedObject) -> NSIndexPath? {
        return self.fetchedResultsController.indexPathForObject(object) ?? nil
    }

    public func fetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching objects")
        }
    }
}

extension DataSource: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfRowsInSection = sections[section].numberOfObjects
        }

        return numberOfRowsInSection
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath)

        self.configureCell(cell, indexPath: indexPath)

        return cell
    }

    // Sections and Headers

    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if let titles = self.delegate?.sectionIndexTitlesForDataSource?(self, tableView: tableView) {
            return titles
        } else if let keyPath = self.fetchedResultsController.sectionNameKeyPath {
            let request = NSFetchRequest()
            request.entity = self.fetchedResultsController.fetchRequest.entity
            request.resultType = .DictionaryResultType
            request.returnsDistinctResults = true
            request.propertiesToFetch = [keyPath]
            request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: true)]
            var names = [String]()
            var objects: [NSDictionary]?

            do {
                objects = try self.fetchedResultsController.managedObjectContext.executeFetchRequest(request) as? [NSDictionary]
            } catch {
                print("Error")
            }

            if let objects = objects {
                for object in objects {
                    names.appendContentsOf(object.allValues as! [String])
                }
            }

            return names
        }

        return nil
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.delegate?.dataSource?(self, tableView: tableView, sectionForSectionIndexTitle: title, atIndex: index) ?? index
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var resultTitle: String?

        if let title = self.delegate?.dataSource?(self, tableView: tableView, titleForHeaderInSection: section) {
            resultTitle = title
        } else if let sections = self.fetchedResultsController.sections {
            resultTitle = sections[section].name
        }

        return resultTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.delegate?.dataSource?(self, tableView: tableView, titleForFooterInSection: section)
    }

    // Editing

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canEditRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }

    // Moving or Reordering

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canMoveRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}

extension DataSource: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItemsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfItemsInSection = sections[section].numberOfObjects
        }

        return numberOfItemsInSection
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath)

        self.configureCell(cell, indexPath: indexPath)

        return cell
    }

    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let view = self.delegate?.dataSource?(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath) {
            return view
        }

        if kind == UICollectionElementKindSectionHeader {
            if let keyPath = self.fetchedResultsController.sectionNameKeyPath, headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: DataSourceCollectionViewHeader.Identifier, forIndexPath: indexPath) as? DataSourceCollectionViewHeader {
                let request = NSFetchRequest()
                request.entity = self.fetchedResultsController.fetchRequest.entity
                request.resultType = .DictionaryResultType
                request.returnsDistinctResults = true
                request.propertiesToFetch = [keyPath]
                request.predicate = self.fetchedResultsController.fetchRequest.predicate
                request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: true)]
                var objects: [NSDictionary]?

                do {
                    objects = try self.fetchedResultsController.managedObjectContext.executeFetchRequest(request) as? [NSDictionary]
                } catch {
                    print("Error")
                }

                if let objects = objects {
                    for object in objects {
                        self.cachedSectionNames.appendContentsOf(object.allValues as! [String])
                    }
                }

                let title = self.cachedSectionNames[indexPath.section]
                headerView.title = title

                return headerView
            }
        } else if (kind == UICollectionElementKindSectionFooter) {
            // Add support for footers
        }

        return UICollectionReusableView()
    }
}

extension DataSource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
            self.sectionChanges = [NSFetchedResultsChangeType : NSMutableIndexSet]()
            self.objectChanges = [NSFetchedResultsChangeType : [NSIndexPath]]()
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        self.cachedSectionNames.removeAll()

        if let tableView = self.tableView {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Move, .Update:
                break
            }
        } else if let _ = self.collectionView {
            switch type {
            case .Insert, .Delete:
                if let changeSet = self.sectionChanges[type] {
                    changeSet.addIndex(sectionIndex)
                    self.sectionChanges[type] = changeSet
                } else {
                    self.sectionChanges[type] = NSMutableIndexSet(index: sectionIndex)
                }
                break
            case .Move, .Update:
                break
            }
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let tableView = self.tableView {
            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath, anObject = anObject as? NSManagedObject {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    self.delegate?.dataSource?(self, didInsertObject: anObject, atIndexPath: newIndexPath)
                }
                break
            case .Delete:
                if let indexPath = indexPath, anObject = anObject as? NSManagedObject {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.delegate?.dataSource?(self, didDeleteObject: anObject, atIndexPath: indexPath)
                }
                break
            case .Update:
                if let indexPath = indexPath {
                    if tableView.indexPathsForVisibleRows?.indexOf(indexPath) != nil {
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                            self.configureCell(cell, indexPath: indexPath)
                        }

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didUpdateObject: anObject, atIndexPath: indexPath)
                        }
                    }
                }
                break
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)

                    if let oldCell = tableView.cellForRowAtIndexPath(indexPath), newCell = tableView.cellForRowAtIndexPath(newIndexPath) {
                        self.configureCell(oldCell, indexPath: indexPath)
                        self.configureCell(newCell, indexPath: newIndexPath)

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didMoveObject: anObject, fromIndexPath: indexPath, toIndexPath: newIndexPath)
                        }
                    }
                }
                break
            }
        } else if let _ = self.collectionView {
            var changeSet = self.objectChanges[type] ?? [NSIndexPath]()

            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath {
                    changeSet.append(newIndexPath)
                }
                break
            case .Delete, .Update:
                if let indexPath = indexPath {
                    changeSet.append(indexPath)
                }
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    changeSet.append(indexPath)
                    changeSet.append(newIndexPath)
                }
                break
            }

            self.objectChanges[type] = changeSet
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.endUpdates()
        } else if let _ = self.collectionView {
            if let moves = self.objectChanges[.Move] {
                if moves.count > 0 {
                    var updatedMoves = [NSIndexPath]()
                    if let insertSections = self.sectionChanges[.Insert], deleteSections = self.sectionChanges[.Delete] {
                        let fromIndexPath = moves[0]
                        let toIndexPath = moves[1]

                        if deleteSections.containsIndex(fromIndexPath.section) {
                            if insertSections.containsIndex(toIndexPath.section) == false {
                                if var changeSet = self.objectChanges[.Insert] {
                                    changeSet.append(toIndexPath)
                                    self.objectChanges[.Insert] = changeSet
                                } else {
                                    self.objectChanges[.Insert] = [toIndexPath]
                                }
                            }
                        } else if insertSections.containsIndex(toIndexPath.section) {
                            if var changeSet = self.objectChanges[.Delete] {
                                changeSet.append(fromIndexPath)
                                self.objectChanges[.Delete] = changeSet
                            } else {
                                self.objectChanges[.Delete] = [fromIndexPath]
                            }
                        } else {
                            updatedMoves.appendContentsOf(moves)
                        }
                    }

                    if updatedMoves.count > 0 {
                        self.objectChanges[.Move] = updatedMoves
                    } else {
                        self.objectChanges.removeValueForKey(.Move)
                    }
                }
            }

            if let deletes = self.objectChanges[.Delete] {
                if deletes.count > 0 {
                    if let sections = self.sectionChanges[.Delete] {
                        let filtered = deletes.filter({ element -> Bool in
                            return (sections.containsIndex(element.section))
                        })
                        self.objectChanges[.Delete] = filtered
                    }
                }
            }

            if let inserts = self.objectChanges[.Insert] {
                if inserts.count > 0 {
                    if let sections = self.sectionChanges[.Insert] {
                        let filtered = inserts.filter({ element -> Bool in
                            return (sections.containsIndex(element.section))
                        })

                        self.objectChanges[.Insert] = filtered
                    }
                }
            }

            if let collectionView = self.collectionView {
                collectionView.performBatchUpdates({
                    if let deletedSections = self.sectionChanges[.Delete] {
                        collectionView.deleteSections(deletedSections)
                    }

                    if let insertedSections = self.sectionChanges[.Insert] {
                        collectionView.insertSections(insertedSections)
                    }

                    if let deleteItems = self.objectChanges[.Delete] {
                        collectionView.deleteItemsAtIndexPaths(deleteItems)
                    }

                    if let insertedItems = self.objectChanges[.Insert] {
                        collectionView.insertItemsAtIndexPaths(insertedItems)
                    }

                    if let reloadItems = self.objectChanges[.Update] {
                        collectionView.reloadItemsAtIndexPaths(reloadItems)
                    }

                    if let moveItems = self.objectChanges[.Move] {
                        collectionView.moveItemAtIndexPath(moveItems[0], toIndexPath: moveItems[1])
                    }
                    
                    }, completion: nil)
            }
        }
    }

    private func configureCell(cell: UIView, indexPath: NSIndexPath) {
        var item: NSManagedObject?

        let rowIsInsideBounds = indexPath.row < self.fetchedResultsController.fetchedObjects?.count
        if rowIsInsideBounds {
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject
        }

        if let item = item {
            if let _ = self.tableView, configuration = self.tableConfigurationBlock {
                configuration(cell: cell as! UITableViewCell, item: item, indexPath: indexPath)
            } else if let _ = self.collectionView, configuration = self.collectionConfigurationBlock {
                configuration(cell: cell as! UICollectionViewCell, item: item, indexPath: indexPath)
            }
        }
    }
}
