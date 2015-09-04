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
 * \param sectionName The Core Data attribute to be used as a section
 * \param cellIdentifier The used cell identifier.
 * \param mainContext A NSManagedObjectContext in the main thread.
 * \param configuration A block to configure the cell.
 * \returns An instance of DATASource.
 */
- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                      sectionName:(NSString *)sectionName
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
                           sectionName:(NSString *)sectionName
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

//********************************************************
//********************************************************
//********************   DEPRECATED   ********************
//********************************************************
//********************************************************

- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                   cellIdentifier:(NSString *)cellIdentifier
                      mainContext:(NSManagedObjectContext *)mainContext
                    configuration:(void (^)(id cell,
                                            id item,
                                            NSIndexPath *indexPath))configuration __attribute__((deprecated("Use the method that includes the sectionName instead (sectionName is optional and can be nil).")));

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                          fetchRequest:(NSFetchRequest *)fetchRequest
                        cellIdentifier:(NSString *)cellIdentifier
                           mainContext:(NSManagedObjectContext *)mainContext
                         configuration:(void (^)(id cell,
                                                 id item,
                                                 NSIndexPath *indexPath))configuration __attribute__((deprecated("Use the method that includes the sectionName instead (sectionName is optional and can be nil).")));

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
 * ********************
 *
 * UITableView specific
 *
 * ********************
 */
- (BOOL)dataSource:(DATASource *)dataSource
         tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)dataSource:(DATASource *)dataSource
         tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)dataSource:(DATASource *)dataSource
               tableView:(UITableView *)tableView
 titleForHeaderInSection:(NSInteger)section;

- (NSString *)dataSource:(DATASource *)dataSource
               tableView:(UITableView *)tableView
 titleForFooterInSection:(NSInteger)section;

- (BOOL)dataSource:(DATASource *)dataSource
         tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)sectionIndexTitlesForDataSource:(DATASource *)dataSource
                                   tableView:(UITableView *)tableView;

- (NSInteger)dataSource:(DATASource *)dataSource
              tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
                atIndex:(NSInteger)index;

- (void)dataSource:(DATASource *)dataSource
         tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
       toIndexPath:(NSIndexPath *)destinationIndexPath;

/*!
 * ********************
 *
 * UICollectionView specific
 *
 * ********************
 */

- (UICollectionReusableView *)dataSource:(DATASource *)dataSource
                          collectionView:(UICollectionView *)collectionView
       viewForSupplementaryElementOfKind:(NSString *)kind
                             atIndexPath:(NSIndexPath *)indexPath;


@end
