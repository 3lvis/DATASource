import UIKit
import CoreData

public protocol DataSourceable: class {
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

public class DataSource: NSObject {
    private weak var tableView: UITableView?
    private weak var collectionView: UICollectionView?
    private var sectionName: String?
    private var cellIdentifier: String
    private weak var mainContext: NSManagedObjectContext?
    private weak var delegate: DataSourceable?

    private var fetchedResultsController: NSFetchedResultsController
    private var objectChanges: [String : AnyObject]?
    private var sectionChanges: [NSFetchedResultsChangeType : NSMutableIndexSet]?
    private var cachedSectionNames: [String]?

    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest, sectionName: String, mainContext: NSManagedObjectContext) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, sectionName: sectionName, mainContext: mainContext)

        self.tableView = tableView
    }

    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest, sectionName: String, mainContext: NSManagedObjectContext, delegate: DataSourceable) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, sectionName: sectionName, mainContext: mainContext)

        self.collectionView = collectionView
        self.collectionView?.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DataSourceCollectionViewHeader.Identifier);
    }

    public init(cellIdentifier: String, fetchRequest: NSFetchRequest, sectionName: String?, mainContext: NSManagedObjectContext) {
        self.cellIdentifier = cellIdentifier

        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainContext, sectionNameKeyPath: sectionName, cacheName: nil)

        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching objects")
        }
    }
}

extension DataSource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
            self.objectChanges = [String : AnyObject]()
            self.sectionChanges = [NSFetchedResultsChangeType : NSMutableIndexSet]()
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
                if var sectionChanges = self.sectionChanges {
                    if let changeSet = sectionChanges[type] {
                        changeSet.addIndex(sectionIndex)
                    } else {
                        sectionChanges[type] = NSMutableIndexSet(index: sectionIndex)
                    }
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
                if let newIndexPath = newIndexPath {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                }

                break
            }
        } else if let collectionView = self.collectionView {
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
        } else if let collectionView = self.collectionView {
        }
    }
}
