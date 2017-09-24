#import "CollectionViewControllerWithSections.h"

@import DATAStack;
@import CoreData;

#import "FooterExampleView.h"
#import "ObjectiveCDemo-Swift.h"

@interface CollectionViewControllerWithSections () <NSFetchedResultsControllerDelegate, DATASourceDelegate>

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;

@end

@implementation CollectionViewControllerWithSections

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout
                  andDataStack:(DATAStack *)dataStack {
    self = [super initWithCollectionViewLayout:layout];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

- (DATASource *)dataSource {
    if (_dataSource) return _dataSource;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstLetterOfName" ascending:YES],
                                [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

    _dataSource = [[DATASource alloc] initWithCollectionView:self.collectionView
                                              cellIdentifier:[CollectionCell identifier]
                                                fetchRequest:request
                                                 mainContext:self.dataStack.mainContext
                                                 sectionName:@"firstLetterOfName"
                                               configuration:^(UICollectionViewCell * _Nonnull cell, NSManagedObject * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                                                   CollectionCell *collectionCell = (CollectionCell *)cell;
                                                   collectionCell.textLabel.text = [item valueForKey:@"name"];
                                               }];
    _dataSource.delegate = self;

    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:[CollectionCell identifier]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
}

- (void)addAction {
    [Helper addNewUserWithDataStack:self.dataStack];
}

@end
