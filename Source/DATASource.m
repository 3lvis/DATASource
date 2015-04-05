#import "DATASource.h"

@interface DATASource () <NSFetchedResultsControllerDelegate>

@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *cellIdentifier;
@property (nonatomic, copy) DATAConfigureCell configureCellBlock;

@end

@implementation DATASource

- (instancetype)initWithTableView:(UITableView *)tableView
                     fetchRequest:(NSFetchRequest *)fetchRequest
                   cellIdentifier:(NSString *)cellIdentifier
                      mainContext:(NSManagedObjectContext *)mainContext
                        configure:(DATAConfigureCell)configure
{
    self = [super init];
    if (!self) return nil;

    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                 managedObjectContext:mainContext
                                                                                   sectionNameKeyPath:nil
                                                                                            cacheName:nil];

    _tableView = tableView;
    _fetchedResultsController = controller;
    _cellIdentifier = cellIdentifier;
    _configureCellBlock = configure;

    self.tableView.dataSource = self;
    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
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

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = self.fetchedResultsController.sections[section];

    return info.numberOfObjects;
}

- (NSString *)tableView:(UITableView*)tableView
titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> info = [self.fetchedResultsController sections][section];

    return info.name;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier
                                                             forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.controllerIsHidden) {
        [self.tableView beginUpdates];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.controllerIsHidden) {
        NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in indexPaths) {
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
        }
    } else {
        [self.tableView endUpdates];
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
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.controllerIsHidden) return;

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
}

#pragma mark - Private methods

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    id item;

    BOOL rowIsInsideBounds = ((NSUInteger)indexPath.row < self.fetchedResultsController.fetchedObjects.count);
    if (rowIsInsideBounds) {
        item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }

    return item;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)path
{
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, [self itemAtIndexPath:path], path);
    }
}

@end
