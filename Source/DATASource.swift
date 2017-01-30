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
    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: @escaping (_ cell: UITableViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ()) {
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
    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: @escaping (_ cell: UICollectionViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ()) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: nil, collectionConfiguration: configuration)

        self.collectionView = collectionView
        self.collectionView?.dataSource = self

        self.collectionView?.register(DATASourceCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DATASourceCollectionViewHeader.Identifier)
    }

    /**
     Initializes and returns a data source object for a table view.
     - parameter tableView: A table view used to construct the data source.
     - parameter cellIdentifier: An identifier from the registered UITableViewCell subclass.
     - parameter fetchRequest: A request to be used, requests need a sort descriptor.
     - parameter mainContext: A main thread managed object context.
     - parameter sectionName: The section to be used for generating the section headers. `nil` means no grouping by section is needed.
     */
    public convenience init(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, mainContext: NSManagedObjectContext, sectionName: String? = nil) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: nil, collectionConfiguration: nil)

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
     */
    public convenience init(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, mainContext: NSManagedObjectContext, sectionName: String? = nil) {
        self.init(cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: mainContext, sectionName: sectionName, tableConfiguration: nil, collectionConfiguration: nil)

        self.collectionView = collectionView
        self.collectionView?.dataSource = self

        self.collectionView?.register(DATASourceCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DATASourceCollectionViewHeader.Identifier)
    }

    private init(cellIdentifier: String, fetchRequest: NSFetchRequest<NSFetchRequestResult>, mainContext: NSManagedObjectContext, sectionName: String? = nil, tableConfiguration: ((_ cell: UITableViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ())?, collectionConfiguration: ((_ cell: UICollectionViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ())?) {
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
    private var tableConfigurationBlock: ((_ cell: UITableViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ())?
    private var collectionConfigurationBlock: ((_ cell: UICollectionViewCell, _ item: NSManagedObject, _ indexPath: IndexPath) -> ())?

    /**
     The DATASource's delegate. Used for overwritting methods overwritten by DATASource. Also used to be notified of object changes.
     */
    public weak var delegate: DATASourceDelegate?

    /**
     Dictionary to configurate the different animations to be applied by each change type.
     */
    public var animations: [NSFetchedResultsChangeType: UITableViewRowAnimation]?

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>

    lazy var objectChanges: [NSFetchedResultsChangeType: Set<IndexPath>] = {
        return [NSFetchedResultsChangeType: Set<IndexPath>]()

    }()

    lazy var sectionChanges: [NSFetchedResultsChangeType: IndexSet] = {
        return [NSFetchedResultsChangeType: IndexSet]()
    }()

    lazy var cachedSectionNames: [Any] = {
        return [Any]()
    }()

    /**
     The DATASource's predicate.
     */
    public var predicate: NSPredicate? {
        get {
            return self.fetchedResultsController.fetchRequest.predicate
        }

        set {
            self.cachedSectionNames = [String]() as [Any]
            self.fetchedResultsController.fetchRequest.predicate = newValue
            self.fetch()
            self.tableView?.reloadData()

            if let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems, visibleIndexPaths.count > 0 {
                self.collectionView?.reloadItems(at: visibleIndexPaths)
            }
        }
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
        return self.fetchedResultsController.fetchedObjects as? [T] ?? [T]()
    }

    /**
     Returns the object for a given index path.
     - parameter indexPath: An index path used to fetch an specific object.
     - returns: The object at a given index path in the fetch results.
     */
    // Meant to be a Objective-C compatibility later for object(indexPath: indexPath)
    public func objectAtIndexPath(_ indexPath: IndexPath) -> NSManagedObject? {
        return object(indexPath)
    }

    /**
     Returns the object for a given index path.
     - parameter indexPath: An index path used to fetch an specific object.
     - returns: The object at a given index path in the fetch results.
     */
    public func object<T: NSManagedObject>(_ indexPath: IndexPath) -> T? {
        if !self.isEmpty && self.isIndexPathWithinBounds(indexPath) {
            guard let object = self.fetchedResultsController.object(at: indexPath) as? T else { fatalError("Couldn't cast object") }
            return object
        }

        return nil
    }

    private func isIndexPathWithinBounds(_ indexPath: IndexPath) -> Bool {
        return self.fetchedResultsController.sections?.count ?? 0 > indexPath.section &&
            self.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 > indexPath.row
    }
    
    /**
     Returns the index path of a given managed object.
     - parameter object: An object in the receiver’s fetch results.
     - returns: The index path of object in the receiver’s fetch results, or nil if object could not be found.
     */
    //
    // Meant to be a Objective-C compatibility later for `indexPath(object: object)`
    public func indexPathForObject(_ object: NSManagedObject) -> IndexPath? {
        return self.indexPath(object)
    }

    /**
     Returns the index path of a given managed object.
     - parameter object: An object in the receiver’s fetch results.
     - returns: The index path of object in the receiver’s fetch results, or nil if object could not be found.
     */
    public func indexPath(_ object: NSManagedObject) -> IndexPath? {
        return self.fetchedResultsController.indexPath(forObject: object) ?? nil
    }

    /**
     Executes the DATASource's fetch request.
     */
    public func fetch() {
        do {
            self.cachedSectionNames = [String]() as [Any]
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
    public func titleForHeaderInSection(_ section: Int) -> String? {
        return self.titleForHeader(section)
    }

    /**
     Returns the title of a given section. Uses given `sectionName` in the initializer to do this lookup.
     - parameter section: The section used to retrieve the title.
     - returns: The title for the requested section, returns `nil` if the section is not present.
     */
    public func titleForHeader(_ section: Int) -> String? {
        return self.fetchedResultsController.sections?[section].name
    }

    /**
     Requests to reload the contents of the cell at a specific indexPath.
     - parameter cell: The cell to be loaded.
     - parameter indexPath: The indexPath where the cell is located.
     */
    public func configure(_ cell: UIView, indexPath: IndexPath) {
        if let item = self.objectAtIndexPath(indexPath) {
            if let _ = self.tableView {
                if let configuration = self.tableConfigurationBlock {
                    configuration(cell as! UITableViewCell, item, indexPath)
                } else if self.delegate?.responds(to: #selector(DATASourceDelegate.dataSource(_:configureTableViewCell:withItem:atIndexPath:))) != nil {
                    self.delegate?.dataSource?(self, configureTableViewCell: cell as! UITableViewCell, withItem: item, atIndexPath: indexPath)
                } else {
                    fatalError()
                }
            } else if let _ = self.collectionView {
                if let configuration = self.collectionConfigurationBlock {
                    configuration(cell as! UICollectionViewCell, item, indexPath)
                } else if self.delegate?.responds(to: #selector(DATASourceDelegate.dataSource(_:configureCollectionViewCell:withItem:atIndexPath:))) != nil {
                    self.delegate?.dataSource?(self, configureCollectionViewCell: cell as! UICollectionViewCell, withItem: item, atIndexPath: indexPath)
                } else {
                    fatalError()
                }
            }
        }
    }

    /**
     Lightweight replacement for `reloadItemsAtIndexPaths` that doesn't flash the reloaded items.
     - parameter indexPaths: The array of indexPaths to be reloaded.
     */
    public func reloadCells(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let tableView = self.tableView {
                if let cell = tableView.cellForRow(at: indexPath) {
                    self.configure(cell, indexPath: indexPath)
                }
            } else if let collectionView = self.collectionView {
                if let cell = collectionView.cellForItem(at: indexPath) {
                    self.configure(cell, indexPath: indexPath)
                }
            }
        }
    }
}
