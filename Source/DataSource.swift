import UIKit
import CoreData

public protocol DataSourceable: class {
    func dataSource(dataSource: DataSource, configureCell cell: UITableViewCell, item: NSManagedObject, atIndexPath indexPath: NSIndexPath)

    func dataSource(dataSource: DataSource, didInsertObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    func dataSource(dataSource: DataSource, didUpdateObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    func dataSource(dataSource: DataSource, didDeleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    func dataSource(dataSource: DataSource, didMoveObject object: NSManagedObject, fromIndexPath oldIndexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath)

    /*!
    * ********************
    *
    * UITableView specific
    *
    * ********************
    */

    // Sections and Headers

    func sectionIndexTitlesForDataSource(dataSource: DataSource, tableView: UITableView) -> [String]?
}

extension DataSourceable {
    func dataSource(dataSource: DataSource, didInsertObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {}
    func dataSource(dataSource: DataSource, didUpdateObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {}
    func dataSource(dataSource: DataSource, didDeleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {}
    func dataSource(dataSource: DataSource, didMoveObject object: NSManagedObject, fromIndexPath oldIndexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath) {}
}

public class DataSource: NSObject, UITableViewDataSource {
    private weak var tableView: UITableView?
    private weak var collectionView: UICollectionView?
    private var sectionName: String?
    private var cellIdentifier: String
    private weak var mainContext: NSManagedObjectContext?
    public weak var delegate: DataSourceable?

    private var fetchedResultsController: NSFetchedResultsController
    private var cachedSectionNames: [String]?

    private lazy var objectChanges: [NSFetchedResultsChangeType : [NSIndexPath]] = {
        return [NSFetchedResultsChangeType : [NSIndexPath]]()

    }()

    private lazy var sectionChanges: [NSFetchedResultsChangeType : NSMutableIndexSet] = {
        return [NSFetchedResultsChangeType : NSMutableIndexSet]()
    }()

    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String?) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName)

        self.tableView = tableView
    }

    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String?, delegate: DataSourceable) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName)

        self.collectionView = collectionView
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DataSourceCollectionViewHeader.Identifier);
    }

    private init(cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String?) {
        self.cellIdentifier = cellIdentifier

        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: sectionName, cacheName: nil)

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching objects")
        }
    }
}

extension DataSource: UITableViewDataSource {
    
}

extension DataSource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        self.cachedSectionNames = nil

        if let tableView = self.tableView {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Move, .Update:
                tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            }
        } else if let _ = self.collectionView {
            switch type {
            case .Insert, .Delete:
                if let changeSet = self.sectionChanges[type] {
                    changeSet.addIndex(sectionIndex)
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
                    self.delegate?.dataSource(self, didInsertObject: anObject, atIndexPath: newIndexPath)
                }
                break
            case .Delete:
                if let indexPath = indexPath, anObject = anObject as? NSManagedObject {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.delegate?.dataSource(self, didDeleteObject: anObject, atIndexPath: indexPath)
                }
                break
            case .Update:
                if let indexPath = indexPath {
                    if tableView.indexPathsForVisibleRows?.indexOf(indexPath) != nil {
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                            self.configureCell(cell, indexPath: indexPath)
                        }

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource(self, didUpdateObject: anObject, atIndexPath: indexPath)
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
                            self.delegate?.dataSource(self, didMoveObject: anObject, fromIndexPath: indexPath, toIndexPath: newIndexPath)
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
            let moves = self.objectChanges[.Move]
            if let moves = moves {
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

                if let deletes = self.objectChanges[.Delete] {
                    if deletes.count > 0 {
                        let sections = self.sectionChanges[.Delete]
                        let filtered = deletes.filter({ element -> Bool in
                            return (sections?.containsIndex(element.section))!
                        })
                        self.objectChanges[.Delete] = filtered
                    }
                }

                if let inserts = self.objectChanges[.Insert] {
                    if inserts.count > 0 {
                        let sections = self.sectionChanges[.Insert]
                        let filtered = inserts.filter({ element -> Bool in
                            return (sections?.containsIndex(element.section))!
                        })
                        self.objectChanges[.Insert] = filtered
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
    }

    private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        var item: NSManagedObject?

        let rowIsInsideBounds = indexPath.row < self.fetchedResultsController.fetchedObjects?.count
        if rowIsInsideBounds {
            item = self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject
        }

        if let item = item {
            self.delegate?.dataSource(self, configureCell: cell, item: item, atIndexPath: indexPath)
        }
    }
}
