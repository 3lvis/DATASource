@import UIKit;

@class DATAStack;

@interface CollectionViewControllerWithSections : UICollectionViewController

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout andDataStack:(DATAStack *)dataStack;

@end

