#import "ViewController.h"

#import "DATAStack.h"
#import "DATASource.h"
#import "User.h"

static NSString *CellIdentifier = @"AFCollectionViewCell";

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;

@end

@implementation ViewController

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout andDataStack:(DATAStack *)dataStack
{
    self = [super initWithCollectionViewLayout:layout];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

- (DATASource *)dataSource
{
    if (_dataSource) return _dataSource;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    _dataSource = [[DATASource alloc] initWithCollectionView:self.collectionView
                                                fetchRequest:request
                                              cellIdentifier:CellIdentifier
                                                 mainContext:self.dataStack.mainContext
                                                   configure:^(UICollectionViewCell *cell, id item, NSIndexPath *indexPath) {
                                                       cell.backgroundColor = [UIColor redColor];
                                                   }];

    return _dataSource;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.collectionView.dataSource = self.dataSource;
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

@end
