import UIKit
import CoreData

public class DATASource: NSObject {
    /**
     Initializes and returns a data source object for a table view.
     - parameter tableView: A table view used to construct the data source.
     - parameter cellIdentifier: An identifier from the registered UITableViewCell subclass.
     - parameter fetchRequest: A request to be used, requests need a sort descriptor.
     - parameter mainContext: A main thread managed object context.
     - parameter sectionName: The section to be used for generating the section headers. `nil` means no grouping by section is needed.
     - parameter configuration: A configuration block that provides you the cell, the managed object and the index path to be configured.
     */
    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: (cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: configuration, collectionConfiguration: nil)

        self.tableView = tableView
        self.tableView?.dataSource = self
    }

    /**
     Initializes and returns a data source object for a collection view.
     - parameter collectionView: A collection view used to construct the data source.
     - parameter cellIdentifier: An identifier from the registered UICollectionViewCell subclass.
     - parameter fetchRequest: A request to be used, requests need a sort descriptor.
     - parameter mainContext: A main thread managed object context.
     - parameter sectionName: The section to be used for generating the section headers. `nil` means no grouping by section is needed.
     - parameter configuration: A configuration block that provides you the cell, the managed object and the index path to be configured.
     */
    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: (cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: nil, collectionConfiguration: configuration)

        self.collectionView = collectionView
        self.collectionView?.dataSource = self

        self.collectionView?.registerClass(DATASourceCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DATASourceCollectionViewHeader.Identifier);
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

    internal weak var tableView: UITableView?
    internal weak var collectionView: UICollectionView?
    private var sectionName: String?
    internal var cellIdentifier: String
    private weak var mainContext: NSManagedObjectContext?
    private var tableConfigurationBlock: ((cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?
    private var collectionConfigurationBlock: ((cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?

    /**
     The DATASource's delegate. Used for overwritting methods overwritten by DATASource. Also used to be notified of object changes.
     */
    public weak var delegate: DATASourceDelegate?

    internal var fetchedResultsController: NSFetchedResultsController

    internal lazy var objectChanges: [NSFetchedResultsChangeType : [NSIndexPath]] = {
        return [NSFetchedResultsChangeType : [NSIndexPath]]()

    }()

    internal lazy var sectionChanges: [NSFetchedResultsChangeType : NSMutableIndexSet] = {
        return [NSFetchedResultsChangeType : NSMutableIndexSet]()
    }()

    internal lazy var cachedSectionNames: [AnyObject] = {
        return [AnyObject]()
    }()

    /**
     The DATASource's predicate.
     */
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

    /**
     The number of objects fetched by DATASource.
     */
    public var objectsCount: Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    /**
     Check for wheter the DATASource is empty or not. Returns `true` is the amount of objects
     is more than 0.
     */
    public var isEmpty: Bool {
        return self.fetchedResultsController.fetchedObjects?.count == 0
    }

    /**
     The objects fetched by DATASource. This is an array of `NSManagedObject`.
     */
    public var objects: [NSManagedObject] {
        return self.fetchedResultsController.fetchedObjects as?  [NSManagedObject] ?? [NSManagedObject]()
    }

    /**
     Returns the object for a given index path.
     - parameter indexPath: An index path used to fetch an specific object.
     - returns: The object at a given index path in the fetch results.
     */
    public func objectAtIndexPath(indexPath: NSIndexPath) -> NSManagedObject? {
        if self.fetchedResultsController.fetchedObjects?.count > 0 {
            return self.fetchedResultsController.objectAtIndexPath(indexPath) as? NSManagedObject ?? nil
        }

        return nil
    }

    /**
     Returns the index path of a given managed object.
     - parameter object: An object in the receiver’s fetch results.
     - returns: The index path of object in the receiver’s fetch results, or nil if object could not be found.
     */
    public func indexPathForObject(object: NSManagedObject) -> NSIndexPath? {
        return self.fetchedResultsController.indexPathForObject(object) ?? nil
    }

    /**
     Executes the DATASource's fetch request.
     */
    public func fetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching objects")
        }
    }

    /**
     Returns the title of a given section. Uses given `sectionName` in the initializer to do this lookup.
     - parameter section: The section used to retrieve the title.
     - returns: The title for the requested section, returns `nil` if the section is not present.
     */
    public func titleForHeaderInSection(section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].name
    }

    internal func configureCell(cell: UIView, indexPath: NSIndexPath) {
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
