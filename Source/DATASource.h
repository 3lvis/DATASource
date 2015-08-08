@import Foundation;
@import UIKit;
@import CoreData;
@class DATAStack;

@protocol DATASourceDelegate;

@interface DATASource : NSObject <UITableViewDataSource, UICollectionViewDataSource>

/*!
 * Initialization of DATASource.
 * \param tableView The used UITableView.
 * \param fetchRequest The used NSFetchedResultsController.
 * \param cellIdentifier The used cell identifier.
 * \param mainContext A NSManagedObjectContext in the main thread.
 * \param configuration A block to configure the cell.
 * \returns An instance of DATASource.
 */
- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                   cellIdentifier:(NSString *)cellIdentifier
                      mainContext:(NSManagedObjectContext *)mainContext
                    configuration:(void (^)(id cell,
                                            id item,
                                            NSIndexPath *indexPath))configuration;

/*!
 * Initialization of DATASource.
 * \param collectionView The used UICollectionView.
 * \param fetchRequest The used NSFetchedResultsController.
 * \param cellIdentifier The used cell identifier.
 * \param mainContext A NSManagedObjectContext in the main thread.
 * \param configuration A block to configure the cell.
 * \returns An instance of DATASource.
 */
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                          fetchRequest:(NSFetchRequest *)fetchRequest
                        cellIdentifier:(NSString *)cellIdentifier
                           mainContext:(NSManagedObjectContext *)mainContext
                         configuration:(void (^)(id cell,
                                                 id item,
                                                 NSIndexPath *indexPath))configuration;

@property (nonatomic, weak) id <DATASourceDelegate> delegate;

@property (nonatomic) BOOL controllerIsHidden;

@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

/*!
 * Convenience method to change the predicate of the NSFetchedResultsController.
 * \param predicate The predicate.
 */
- (void)changePredicate:(NSPredicate *)predicate;

/*!
 * Convenience method to retreive an object at a given @c indexPath.
 * \param indexPath The indexPath.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/*!
 * Convenience method to perform fetch.
 */
- (void)fetch;

@end

@protocol DATASourceDelegate <NSObject>

@optional

- (void)dataSource:(DATASource *)dataSource
   didInsertObject:(NSManagedObject *)object
     withIndexPath:(NSIndexPath *)indexPath;

- (void)dataSource:(DATASource *)dataSource
   didUpdateObject:(NSManagedObject *)object
     withIndexPath:(NSIndexPath *)indexPath;

- (void)dataSource:(DATASource *)dataSource
   didDeleteObject:(NSManagedObject *)object
     withIndexPath:(NSIndexPath *)indexPath;

- (void)dataSource:(DATASource *)dataSource
     didMoveObject:(NSManagedObject *)object
     withIndexPath:(NSIndexPath *)indexPath
      newIndexPath:(NSIndexPath *)newIndexPath;

/*!
 * UITableView specific
 */

// Headers and footers

- (NSString *)dataSource:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section;

- (NSString *)dataSource:(UITableView *)tableView
 titleForFooterInSection:(NSInteger)section;

// Editing

- (BOOL)dataSource:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)dataSource:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath;

// Reorder / moving support

- (void)dataSource:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)destinationIndexPath;

- (BOOL)dataSource:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Indexing

- (NSArray *)sectionIndexTitlesForDataSource:(UITableView *)tableView;

- (NSInteger)dataSource:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
                atIndex:(NSInteger)index;

@end
