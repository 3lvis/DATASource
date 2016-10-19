#import "CollectionViewControllerWithFooter.h"

@import DATAStack;
@import CoreData;

#import "FooterExampleView.h"
#import "ObjectiveCDemo-Swift.h"

@interface CollectionViewControllerWithFooter () <NSFetchedResultsControllerDelegate, DATASourceDelegate>

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;

@end

@implementation CollectionViewControllerWithFooter

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
                                              cellIdentifier:[CollectionCell Identifier]
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

    [self.collectionView registerClass:[CollectionCell class] forCellWithReuseIdentifier:[CollectionCell Identifier]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                          target:self
                                                                          action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = item;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);

    [self.collectionView registerClass:[FooterExampleView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterExampleViewIdentifier];
}

- (void)addAction {
    [Helper addNewUserWithDataStack:self.dataStack];
}

#pragma mark - DATASourceDelegate

- (UICollectionReusableView * __nullable)dataSource:(DATASource * __nonnull)dataSource
                                     collectionView:(UICollectionView * __nonnull)collectionView
                  viewForSupplementaryElementOfKind:(NSString * __nonnull)kind
                                        atIndexPath:(NSIndexPath * __nonnull)indexPath withTitle:(id __nullable)title {
    if (kind == UICollectionElementKindSectionFooter) {
        FooterExampleView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                     withReuseIdentifier:FooterExampleViewIdentifier
                                                                            forIndexPath:indexPath];
        return view;
    }

    return nil;
}

- (void)dataSourceDidChangeContent:(DATASource * __nonnull)dataSource {
    NSLog(@"DATASource finished doing it's thing");
}

@end
