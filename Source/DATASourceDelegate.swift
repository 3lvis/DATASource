import UIKit
import CoreData

@objc public protocol DATASourceDelegate: NSObjectProtocol {
    /*!
     * **************************
     *
     * Cell Configuration
     *
     * **************************
     */
    @objc optional func dataSource(_ dataSource: DATASource, cellIdentifierFor indexPath: IndexPath) -> String
    @objc optional func dataSource(_ dataSource: DATASource, configureTableViewCell cell: UITableViewCell, withItem item: NSManagedObject, atIndexPath indexPath: IndexPath)
    @objc optional func dataSource(_ dataSource: DATASource, configureCollectionViewCell cell: UICollectionViewCell, withItem item: NSManagedObject, atIndexPath indexPath: IndexPath)

    /*!
     * **************************
     *
     * NSFetchedResultsControllerDelegate
     *
     * **************************
     */
    @objc optional func dataSource(_ dataSource: DATASource, didInsertObject object: NSManagedObject, atIndexPath indexPath: IndexPath)
    @objc optional func dataSource(_ dataSource: DATASource, didUpdateObject object: NSManagedObject, atIndexPath indexPath: IndexPath)
    @objc optional func dataSource(_ dataSource: DATASource, didDeleteObject object: NSManagedObject, atIndexPath indexPath: IndexPath)
    @objc optional func dataSource(_ dataSource: DATASource, didMoveObject object: NSManagedObject, fromIndexPath oldIndexPath: IndexPath, toIndexPath newIndexPath: IndexPath)
    @objc optional func dataSourceDidChangeContent(_ dataSource: DATASource)

    /*!
     * **************************
     *
     * UITableView
     *
     * **************************
     */

    // Sections and Headers

    @objc optional func sectionIndexTitlesForDataSource(_ dataSource: DATASource, tableView: UITableView) -> [String]
    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, titleForFooterInSection section: Int) -> String?

    // Editing

    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)

    // Moving or Reordering

    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func dataSource(_ dataSource: DATASource, tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)

    /*!
     * **************************
     *
     * UICollectionView
     *
     * **************************
     */

    @objc optional func dataSource(_ dataSource: DATASource, collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath, withTitle title: Any?) -> UICollectionReusableView?
}
