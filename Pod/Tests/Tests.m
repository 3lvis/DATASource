@import UIKit;
@import XCTest;

#import "DATAStack.h"
#import "DATASource.h"
#import "User.h"

static NSString * const CellIdentifier = @"CellIdentifier";
static NSString * const EntityName = @"User";
static NSString * const ModelName = @"DataModel";

@interface PodTests : XCTestCase

@end

@implementation PodTests

- (User *)userWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:EntityName
                                              inManagedObjectContext:context];
    User *user = (User *)[[NSManagedObject alloc] initWithEntity:entity
                                  insertIntoManagedObjectContext:context];
    user.name = name;

    return user;
}

- (void)testTableViewDataSource
{
    __block BOOL success = NO;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    DATAStack *dataStack = [[DATAStack alloc] initWithModelName:ModelName
                                                         bundle:bundle
                                                      storeType:DATAStackInMemoryStoreType];

    UITableView *tableView = [UITableView new];
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:CellIdentifier];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:EntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES]];
    DATASource *dataSource = [[DATASource alloc] initWithTableView:tableView
                                                      fetchRequest:request
                                                    cellIdentifier:CellIdentifier
                                                       mainContext:dataStack.mainContext
                                                     configuration:^(UITableViewCell *cell, User *item, NSIndexPath *indexPath) {
                                                         XCTAssertEqualObjects(item.name, @"Elvis");
                                                         success = YES;
                                                     }];

    tableView.dataSource = dataSource;
    [tableView reloadData];

    [dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        [self userWithName:@"Elvis" inContext:backgroundContext];
        [backgroundContext save:nil];
    }];

    XCTAssertTrue(success);
}

/*- (void)testCollectionViewDataSource
{
    __block BOOL success = NO;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    DATAStack *dataStack = [[DATAStack alloc] initWithModelName:ModelName
                                                         bundle:bundle
                                                      storeType:DATAStackInMemoryStoreType];

    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                          collectionViewLayout:layout];
    [collectionView registerClass:[UICollectionViewCell class]
       forCellWithReuseIdentifier:CellIdentifier];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:EntityName];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES]];
    DATASource *dataSource = [[DATASource alloc] initWithCollectionView:collectionView
                                                           fetchRequest:request
                                                         cellIdentifier:CellIdentifier
                                                            mainContext:dataStack.mainContext
                                                          configuration:^(id cell, User *item, NSIndexPath *indexPath) {
                                                              XCTAssertEqualObjects(item.name, @"Elvis");
                                                              success = YES;
                                                          }];
    collectionView.dataSource = dataSource;
    [collectionView reloadData];

    [dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        [self userWithName:@"Elvis" inContext:backgroundContext];
        [backgroundContext save:nil];
    }];

    XCTAssertTrue(success);

    // 2015-04-08 08:13:59.809 xctest[58450:1294897] *** Assertion failure in -[UICollectionView _endItemAnimations], /SourceCache/UIKit_Sim/UIKit-3318.93/UICollectionView.m:3917
    // 2015-04-08 08:13:59.811 xctest[58450:1294897] CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  Invalid update: invalid number of items in section 0.  The number of items contained in an existing section after the update (1) must be equal to the number of items contained in that section before the update (1), plus or minus the number of items inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of items moved into or out of that section (0 moved in, 0 moved out). with userInfo (null)
}*/

@end
