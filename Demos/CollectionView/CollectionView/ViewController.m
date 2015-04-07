#import "ViewController.h"

#import "DATAStack.h"
#import "User.h"

static NSString *CellIdentifier = @"AFCollectionViewCell";

@interface ViewController () <NSFetchedResultsControllerDelegate>
{
    NSMutableDictionary *_objectChanges;
    NSMutableDictionary *_sectionChanges;
}

@property (nonatomic, weak) DATAStack *dataStack;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout andDataStack:(DATAStack *)dataStack
{
    self = [super initWithCollectionViewLayout:layout];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)addAction
{
    [self.dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:backgroundContext];
        User *user = [[User alloc] initWithEntity:entity insertIntoManagedObjectContext:backgroundContext];
        user.name = @"The name";
        [backgroundContext save:nil];

        [self.dataStack persistWithCompletion:^{
            [self.fetchedResultsController performFetch:nil];
            [self.collectionView reloadData];
        }];
    }];
}

#pragma mark - UICollectionVIew

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.backgroundColor = [UIColor redColor];

    return cell;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                                managedObjectContext:self.dataStack.mainContext
                                                                                                  sectionNameKeyPath:nil
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    _objectChanges = [NSMutableDictionary dictionary];
    _sectionChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = _sectionChanges[@(type)];
        if (changeSet != nil) {
            [changeSet addIndex:sectionIndex];
        } else {
            _sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableArray *changeSet = _objectChanges[@(type)];
    if (changeSet == nil) {
        changeSet = [[NSMutableArray alloc] init];
        _objectChanges[@(type)] = changeSet;
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
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSMutableArray *moves = _objectChanges[@(NSFetchedResultsChangeMove)];
    if (moves.count > 0) {
        NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];

        NSMutableIndexSet *insertSections = _sectionChanges[@(NSFetchedResultsChangeInsert)];
        NSMutableIndexSet *deleteSections = _sectionChanges[@(NSFetchedResultsChangeDelete)];
        for (NSArray *move in moves) {
            NSIndexPath *fromIP = move[0];
            NSIndexPath *toIP = move[1];

            if ([deleteSections containsIndex:fromIP.section]) {
                if (![insertSections containsIndex:toIP.section]) {
                    NSMutableArray *changeSet = _objectChanges[@(NSFetchedResultsChangeInsert)];
                    if (changeSet == nil) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
                        _objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                    } else {
                        [changeSet addObject:toIP];
                    }
                }
            } else if ([insertSections containsIndex:toIP.section]) {
                NSMutableArray *changeSet = _objectChanges[@(NSFetchedResultsChangeDelete)];
                if (changeSet == nil) {
                    changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
                    _objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                } else {
                    [changeSet addObject:fromIP];
                }
            } else {
                [updatedMoves addObject:move];
            }
        }

        if (updatedMoves.count > 0) {
            _objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
        } else {
            [_objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
        }
    }

    NSMutableArray *deletes = _objectChanges[@(NSFetchedResultsChangeDelete)];
    if (deletes.count > 0) {
        NSMutableIndexSet *deletedSections = _sectionChanges[@(NSFetchedResultsChangeDelete)];
        [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![deletedSections containsIndex:evaluatedObject.section];
        }]];
    }

    NSMutableArray *inserts = _objectChanges[@(NSFetchedResultsChangeInsert)];
    if (inserts.count > 0) {
        NSMutableIndexSet *insertedSections = _sectionChanges[@(NSFetchedResultsChangeInsert)];
        [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![insertedSections containsIndex:evaluatedObject.section];
        }]];
    }

    UICollectionView *collectionView = self.collectionView;

    [collectionView performBatchUpdates:^{
        NSIndexSet *deletedSections = _sectionChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedSections.count > 0) {
            [collectionView deleteSections:deletedSections];
        }

        NSIndexSet *insertedSections = _sectionChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedSections.count > 0) {
            [collectionView insertSections:insertedSections];
        }

        NSArray *deletedItems = _objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedItems.count > 0) {
            [collectionView deleteItemsAtIndexPaths:deletedItems];
        }

        NSArray *insertedItems = _objectChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedItems.count > 0) {
            [collectionView insertItemsAtIndexPaths:insertedItems];
        }

        NSArray *reloadItems = _objectChanges[@(NSFetchedResultsChangeUpdate)];
        if (reloadItems.count > 0) {
            [collectionView reloadItemsAtIndexPaths:reloadItems];
        }

        NSArray *moveItems = _objectChanges[@(NSFetchedResultsChangeMove)];
        for (NSArray *paths in moveItems) {
            [collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
        }
    } completion:nil];

    _objectChanges = nil;
    _sectionChanges = nil;
}

@end
