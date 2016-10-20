@import UIKit;

@class DATAStack;

@interface CollectionViewController : UICollectionViewController

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout andDataStack:(DATAStack *)dataStack;

@end

