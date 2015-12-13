import UIKit
import CoreData

@objc public protocol DATASourceDelegate: NSObjectProtocol {
    optional func dataSource(dataSource: DATASource, didInsertObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DATASource, didUpdateObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DATASource, didDeleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    optional func dataSource(dataSource: DATASource, didMoveObject object: NSManagedObject, fromIndexPath oldIndexPath: NSIndexPath, toIndexPath newIndexPath: NSIndexPath)
    optional func dataSourceDidChangeContent(dataSource: DATASource)

    /*!
    * **************************
    *
    * UITableView specific
    *
    * **************************
    */

    // Sections and Headers

    optional func sectionIndexTitlesForDataSource(dataSource: DATASource, tableView: UITableView) -> [String]
    optional func dataSource(dataSource: DATASource, tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    optional func dataSource(dataSource: DATASource, tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    optional func dataSource(dataSource: DATASource, tableView: UITableView, titleForFooterInSection section: Int) -> String?

    // Editing

    optional func dataSource(dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func dataSource(dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)

    // Moving or Reordering

    optional func dataSource(dataSource: DATASource, tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func dataSource(dataSource: DATASource, tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)

    /*!
    * **************************
    *
    * UICollectionView specific
    *
    * **************************
    */

    optional func dataSource(dataSource: DATASource, collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath, withTitle title: AnyObject?) -> UICollectionReusableView?

    @available(*, deprecated=5.1.0, message="Use dataSource(_:collectionView:viewForSupplementaryElementOfKind:atIndexPath:withTitle) instead") optional func dataSource(dataSource: DATASource, collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
}
