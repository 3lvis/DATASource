#import "DATASource.h"

@interface DATASource () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSString *cellIdentifier;
@property (nonatomic, copy) DATAConfigureCell configureCellBlock;

@property (nonatomic) UITableView *tableView;

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *objectChanges;
@property (nonatomic) NSMutableArray *sectionChanges;

@end

@implementation DATASource

#pragma mark - Initializers

- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                   cellIdentifier:(NSString *)cellIdentifier
                      mainContext:(NSManagedObjectContext *)mainContext
                        configure:(DATAConfigureCell)configure
{
    self = [self initWithFetchRequest:fetchRequest
                       cellIdentifier:cellIdentifier
                          mainContext:mainContext
                            configure:configure];

    _tableView = tableView;
    _tableView.dataSource = self;

    return self;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                          fetchRequest:(NSFetchRequest *)fetchRequest
                        cellIdentifier:(NSString *)cellIdentifier
                           mainContext:(NSManagedObjectContext *)mainContext
                             configure:(DATAConfigureCell)configure
{
    self = [self initWithFetchRequest:fetchRequest
                       cellIdentifier:cellIdentifier
                          mainContext:mainContext
                            configure:configure];

    _collectionView = collectionView;
    _collectionView.dataSource = self;

    return self;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest
                      cellIdentifier:(NSString *)cellIdentifier
                         mainContext:(NSManagedObjectContext *)mainContext
                           configure:(DATAConfigureCell)configure
{
    self = [super init];
    if (!self) return nil;

    _cellIdentifier = cellIdentifier;
    _configureCellBlock = configure;
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

#pragma mark - Getters

- (NSMutableArray *)objectChanges
{
    if (_objectChanges) return _objectChanges;

    _objectChanges = [NSMutableArray new];

    return _objectChanges;
}

- (NSMutableArray *)sectionChanges
{
    if (_sectionChanges) return _sectionChanges;

    _sectionChanges = [NSMutableArray new];

    return _sectionChanges;
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
        NSMutableDictionary *change = [NSMutableDictionary new];

        switch(type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = @(sectionIndex);
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = @(sectionIndex);
                break;
            case NSFetchedResultsChangeMove:
            case NSFetchedResultsChangeUpdate:
                break;
        }

        [self.sectionChanges addObject:change];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.controllerIsHidden) return;

    if (self.tableView) {
        [self.tableView beginUpdates];
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
        if ([self.sectionChanges count] > 0) {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary *change in self.sectionChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeMove:
                                break;
                        }
                    }];
                }
            } completion:nil];
        }

        if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0){
            if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
                // Workaround: This is to prevent a bug in UICollectionView from occurring.
                // The bug presents itself when inserting the first object or deleting the last object in a UICollectionView.
                // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
                // This code should be removed once the bug has been fixed, it is tracked in Open Radar
                // http://openradar.appspot.com/12954582
                [self.collectionView reloadData];
            } else {
                [self.collectionView performBatchUpdates:^{
                    for (NSDictionary *change in self.objectChanges) {
                        [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                            switch (type) {
                                case NSFetchedResultsChangeInsert:
                                    [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeDelete:
                                    [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeUpdate:
                                    [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                    break;
                                case NSFetchedResultsChangeMove:
                                    [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                    break;
                            }
                        }];
                    }
                } completion:nil];
            }
        }

        [self.sectionChanges removeAllObjects];
        [self.objectChanges removeAllObjects];
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
        NSMutableDictionary *change = [NSMutableDictionary new];

        switch(type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = newIndexPath;
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeUpdate:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeMove:
                change[@(type)] = @[indexPath, newIndexPath];
                break;
        }

        [self.objectChanges addObject:change];
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

    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item, indexPath);
    }
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, NSIndexPath *indexPath, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }

    return shouldReload;
}

@end
