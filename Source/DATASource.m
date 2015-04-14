#import "DATASource.h"

@interface DATASource () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSString *cellIdentifier;
@property (nonatomic, copy) void (^configurationBlock)(id cell, id item, NSIndexPath *indexPath);

@property (nonatomic) UITableView *tableView;

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableDictionary *objectChanges;
@property (nonatomic) NSMutableDictionary *sectionChanges;

@end

@implementation DATASource

#pragma mark - Initializers

- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                   cellIdentifier:(NSString *)cellIdentifier
                      mainContext:(NSManagedObjectContext *)mainContext
                    configuration:(void (^)(id cell,
                                            id item,
                                            NSIndexPath *indexPath))configuration
{
    self = [self initWithFetchRequest:fetchRequest
                       cellIdentifier:cellIdentifier
                          mainContext:mainContext];

    _configurationBlock = configuration;
    _tableView = tableView;
    _tableView.dataSource = self;

    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                          fetchRequest:(NSFetchRequest *)fetchRequest
                        cellIdentifier:(NSString *)cellIdentifier
                           mainContext:(NSManagedObjectContext *)mainContext
                         configuration:(void (^)(id cell,
                                                 id item,
                                                 NSIndexPath *indexPath))configuration
{
    self = [self initWithFetchRequest:fetchRequest
                       cellIdentifier:cellIdentifier
                          mainContext:mainContext];

    _configurationBlock = configuration;
    _collectionView = collectionView;
    _collectionView.dataSource = self;

    return self;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                      cellIdentifier:(NSString *)cellIdentifier
                         mainContext:(NSManagedObjectContext *)mainContext
{
    self = [super init];
    if (!self) return nil;

    _cellIdentifier = cellIdentifier;
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:mainContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching objects: %@", error);
    }

    return self;
}

#pragma mark - Public methods

- (void)changePredicate:(NSPredicate *)predicate
{
    self.fetchedResultsController.fetchRequest.predicate = predicate;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching objects after changing predicate: %@", error);
    }
    [self.tableView reloadData];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)fetch
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error fetching: %@", [error description]);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];

    return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

    return sectionInfo.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                            forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

    return sectionInfo.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                           forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.controllerIsHidden) return;

    if (self.tableView) {
        [self.tableView beginUpdates];
    } else if (self.collectionView) {
        self.objectChanges = [NSMutableDictionary new];
        self.sectionChanges = [NSMutableDictionary new];
    }
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.controllerIsHidden) {
        return;
    }

    if (self.tableView) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;

            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeMove:
            case NSFetchedResultsChangeUpdate:
                break;
        }
    } else if (self.collectionView) {
        if (type == NSFetchedResultsChangeInsert ||
            type == NSFetchedResultsChangeDelete) {
            NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
            if (changeSet) {
                [changeSet addIndex:sectionIndex];
            } else {
                self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
            }
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.controllerIsHidden) return;

    if (self.tableView) {
        switch(type) {
            case NSFetchedResultsChangeInsert: {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                if ([self.delegate respondsToSelector:@selector(dataSource:didInsertObject:withIndexPath:)]) {
                    [self.delegate dataSource:self
                              didInsertObject:anObject
                                withIndexPath:indexPath];
                }
            } break;

            case NSFetchedResultsChangeDelete: {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                if ([self.delegate respondsToSelector:@selector(dataSource:didDeleteObject:withIndexPath:)]) {
                    [self.delegate dataSource:self
                              didDeleteObject:anObject
                                withIndexPath:indexPath];
                }
            } break;

            case NSFetchedResultsChangeUpdate:
                if ([self.tableView.indexPathsForVisibleRows indexOfObject:indexPath] != NSNotFound) {
                    [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                            atIndexPath:indexPath];
                    if ([self.delegate respondsToSelector:@selector(dataSource:didUpdateObject:withIndexPath:)]) {
                        [self.delegate dataSource:self
                                  didUpdateObject:anObject
                                    withIndexPath:indexPath];
                    }
                } break;

            case NSFetchedResultsChangeMove: {
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                        atIndexPath:indexPath];
                [self configureCell:[self.tableView cellForRowAtIndexPath:newIndexPath]
                        atIndexPath:newIndexPath];

                if ([self.delegate respondsToSelector:@selector(dataSource:didMoveObject:withIndexPath:newIndexPath:)]) {
                    [self.delegate dataSource:self
                                didMoveObject:anObject
                                withIndexPath:indexPath
                                 newIndexPath:newIndexPath];
                }
            } break;
        }
    } else if (self.collectionView) {
        NSMutableArray *changeSet = self.objectChanges[@(type)];
        if (!changeSet) {
            changeSet = [[NSMutableArray alloc] init];
        }

        switch(type) {
            case NSFetchedResultsChangeInsert:
                [changeSet addObject:newIndexPath];
                break;
            case NSFetchedResultsChangeDelete:
                [changeSet addObject:indexPath];
                break;
            case NSFetchedResultsChangeUpdate:
                [changeSet addObject:indexPath];
                break;
            case NSFetchedResultsChangeMove:
                [changeSet addObject:@[indexPath, newIndexPath]];
                break;
        }

        self.objectChanges[@(type)] = changeSet;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.tableView) {
        if (self.controllerIsHidden) {
            NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
            for (NSIndexPath *indexPath in indexPaths) {
                [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                        atIndexPath:indexPath];
            }
        } else {
            [self.tableView endUpdates];
        }
    } else if (self.collectionView) {
        NSMutableArray *moves = self.objectChanges[@(NSFetchedResultsChangeMove)];
        if (moves.count) {
            NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];

            NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
            NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
            for (NSArray *move in moves) {
                NSIndexPath *fromIndexPath = move[0];
                NSIndexPath *toIndexPath = move[1];

                if ([deleteSections containsIndex:fromIndexPath.section]) {
                    if (![insertSections containsIndex:toIndexPath.section]) {
                        NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeInsert)];
                        if (!changeSet) {
                            changeSet = [[NSMutableArray alloc] initWithObjects:toIndexPath, nil];
                            self.objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                        } else {
                            [changeSet addObject:toIndexPath];
                        }
                    }
                } else if ([insertSections containsIndex:toIndexPath.section]) {
                    NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeDelete)];
                    if (!changeSet) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:fromIndexPath, nil];
                        self.objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                    } else {
                        [changeSet addObject:fromIndexPath];
                    }
                } else {
                    [updatedMoves addObject:move];
                }
            }

            if (updatedMoves.count) {
                self.objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
            } else {
                [self.objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
            }
        }

        NSMutableArray *deletes = self.objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletes.count) {
            NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
            [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
                return ![deletedSections containsIndex:evaluatedObject.section];
            }]];
        }

        NSMutableArray *inserts = self.objectChanges[@(NSFetchedResultsChangeInsert)];
        if (inserts.count) {
            NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
            [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
                return ![insertedSections containsIndex:evaluatedObject.section];
            }]];
        }

        UICollectionView *collectionView = self.collectionView;
        [collectionView performBatchUpdates:^{
            NSIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
            if (deletedSections.count) {
                [collectionView deleteSections:deletedSections];
            }

            NSIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
            if (insertedSections.count) {
                [collectionView insertSections:insertedSections];
            }

            NSArray *deletedItems = self.objectChanges[@(NSFetchedResultsChangeDelete)];
            if (deletedItems.count) {
                [collectionView deleteItemsAtIndexPaths:deletedItems];
            }

            NSArray *insertedItems = self.objectChanges[@(NSFetchedResultsChangeInsert)];
            if (insertedItems.count) {
                [collectionView insertItemsAtIndexPaths:insertedItems];
            }

            NSArray *reloadItems = self.objectChanges[@(NSFetchedResultsChangeUpdate)];
            if (reloadItems.count) {
                [collectionView reloadItemsAtIndexPaths:reloadItems];
            }

            NSArray *moveItems = self.objectChanges[@(NSFetchedResultsChangeMove)];
            for (NSArray *paths in moveItems) {
                [collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
            }
        } completion:nil];
    }
}

#pragma mark - Private methods

- (void)configureCell:(id)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    id item;

    BOOL rowIsInsideBounds = ((NSUInteger)indexPath.row < self.fetchedResultsController.fetchedObjects.count);
    if (rowIsInsideBounds) {
        item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    if (self.configurationBlock) {
        self.configurationBlock(cell, item, indexPath);
    }
}

@end
