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

    weak var tableView: UITableView?
    weak var collectionView: UICollectionView?
    private var sectionName: String?
    var cellIdentifier: String
    private weak var mainContext: NSManagedObjectContext?
    private var tableConfigurationBlock: ((cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?
    private var collectionConfigurationBlock: ((cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ())?

    /**
     The DATASource's delegate. Used for overwritting methods overwritten by DATASource. Also used to be notified of object changes.
     */
    public weak var delegate: DATASourceDelegate?

    /**
     Dictionary to configurate the different animations to be applied by each change type.
    */
    public var animations: [NSFetchedResultsChangeType: UITableViewRowAnimation]?

    var fetchedResultsController: NSFetchedResultsController

    lazy var objectChanges: [NSFetchedResultsChangeType : Set<NSIndexPath>] = {
        return [NSFetchedResultsChangeType : Set<NSIndexPath>]()

    }()

    lazy var sectionChanges: [NSFetchedResultsChangeType : NSMutableIndexSet] = {
        return [NSFetchedResultsChangeType : NSMutableIndexSet]()
    }()

    lazy var cachedSectionNames: [AnyObject] = {
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

            if let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems() where visibleIndexPaths.count > 0 {
                self.collectionView?.reloadItemsAtIndexPaths(visibleIndexPaths)
            }
        }
    }

    /**
     The number of objects fetched by DATASource.
     */
    @available(*, deprecated=5.6.3, message="Use `count` instead") public var objectsCount: Int {
        return self.count
    }

    /**
     The number of objects fetched by DATASource.
     */
    public var count: Int {
        var total = 0
        let sections = self.fetchedResultsController.sections ?? [NSFetchedResultsSectionInfo]()
        if sections.count == 0 {
            return 0
        } else {
            for section in sections {
                total += section.numberOfObjects
            }
        }

        return total
    }

    /**
     Check for wheter the DATASource is empty or not. Returns `true` is the amount of objects
     is more than 0.
     */
    public var isEmpty: Bool {
        let sections = self.fetchedResultsController.sections ?? [NSFetchedResultsSectionInfo]()
        if sections.count == 0 {
            return true
        } else {
            for section in sections {
                if section.numberOfObjects > 0 {
                    return false
                }
            }
        }

        return true
    }

    /**
     The objects fetched by DATASource. This is an array of `NSManagedObject`.
     */
    // Meant to be a Objective-C compatibility later for `all`
    public var objects: [NSManagedObject] {
        return all()
    }

    /**
     All the objects fetched by DATASource. This is an array of `NSManagedObject`.
     */
    public func all<T: NSManagedObject>() -> [T] {
        return self.fetchedResultsController.fetchedObjects as?  [T] ?? [T]()
    }

    /**
     Returns the object for a given index path.
     - parameter indexPath: An index path used to fetch an specific object.
     - returns: The object at a given index path in the fetch results.
     */
    // Meant to be a Objective-C compatibility later for object(indexPath: indexPath)
    public func objectAtIndexPath(indexPath: NSIndexPath) -> NSManagedObject? {
        return object(indexPath: indexPath)
    }

    /**
     Returns the object for a given index path.
     - parameter indexPath: An index path used to fetch an specific object.
     - returns: The object at a given index path in the fetch results.
     */
    public func object<T: NSManagedObject>(indexPath indexPath: NSIndexPath) -> T? {
        if !self.isEmpty {
            guard let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as? T else { fatalError("Couldn't cast object") }
            return object
        }

        return nil
    }

    /**
     Returns the index path of a given managed object.
     - parameter object: An object in the receiver’s fetch results.
     - returns: The index path of object in the receiver’s fetch results, or nil if object could not be found.
     */
    //
    // Meant to be a Objective-C compatibility later for `indexPath(object: object)`
    public func indexPathForObject(object: NSManagedObject) -> NSIndexPath? {
        return self.indexPath(object: object)
    }

    /**
     Returns the index path of a given managed object.
     - parameter object: An object in the receiver’s fetch results.
     - returns: The index path of object in the receiver’s fetch results, or nil if object could not be found.
     */
    public func indexPath(object object: NSManagedObject) -> NSIndexPath? {
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
    // Meant to be a Objective-C compatibility later for `titleForHeader(section: section)`
    public func titleForHeaderInSection(section: Int) -> String? {
        return self.titleForHeader(section: section)
    }

    /**
     Returns the title of a given section. Uses given `sectionName` in the initializer to do this lookup.
     - parameter section: The section used to retrieve the title.
     - returns: The title for the requested section, returns `nil` if the section is not present.
     */
    public func titleForHeader(section section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].name
    }

    func configure(cell cell: UIView, indexPath: NSIndexPath) {
        var item: NSManagedObject?

        let rowIsInsideBounds = indexPath.row < self.count
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
