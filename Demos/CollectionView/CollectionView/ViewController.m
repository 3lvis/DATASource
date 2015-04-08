#import "ViewController.h"

#import "DATAStack.h"
#import "User.h"

static NSString *CellIdentifier = @"AFCollectionViewCell";

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) DATAStack *dataStack;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSMutableDictionary *objectChanges;
@property (nonatomic) NSMutableDictionary *sectionChanges;

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

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                    managedObjectContext:self.dataStack.mainContext
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        abort();
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.objectChanges = [NSMutableDictionary new];
    self.sectionChanges = [NSMutableDictionary new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
        if (changeSet) {
            [changeSet addIndex:sectionIndex];
        } else {
            self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
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

@end
