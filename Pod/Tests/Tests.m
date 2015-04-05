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
                                                         configure:^(id cell, User *item, NSIndexPath *indexPath) {
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

- (void)testCollectionViewDataSource
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
                                                              configure:^(id cell, User *item, NSIndexPath *indexPath) {
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
}

@end
