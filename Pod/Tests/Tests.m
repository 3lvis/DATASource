@import UIKit;
@import XCTest;

#import "DATAStack.h"
#import "DATASource.h"
#import "User.h"

@interface PodTests : XCTestCase

@end

@implementation PodTests

- (void)testTableViewDataSource
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    DATAStack *dataStack = [[DATAStack alloc] initWithModelName:@"DataModel"
                                                         bundle:bundle
                                                      storeType:DATAStackInMemoryStoreType];

    UITableView *tableView = [UITableView new];
    [tableView registerClass:[UITableViewCell class]
      forCellReuseIdentifier:@"CellIdentifier"];

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES]];
    DATASource *dataSource = [[DATASource alloc] initWithTableView:tableView
                                                      fetchRequest:request
                                                    cellIdentifier:@"CellIdentifier"
                                                       mainContext:dataStack.mainContext
                                                         configure:^(id cell, User *item, NSIndexPath *indexPath) {
                                                             XCTAssertEqualObjects(item.name, @"Elvis");
                                                         }];
    tableView.dataSource = dataSource;
    [tableView reloadData];

    [dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        [self userWithName:@"Elvis" inContext:backgroundContext];
        [backgroundContext save:nil];
    }];
}

- (User *)userWithName:(NSString *)name inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:context];
    User *user = (User *)[[NSManagedObject alloc] initWithEntity:entity
                                  insertIntoManagedObjectContext:context];
    user.name = name;

    return user;
}

@end
