#import "OptionsController.h"
#import "UICollectionViewControllerDemo.h"

@interface OptionsController ()

@property (nonnull, strong) DATAStack *dataStack;

@end

@implementation OptionsController

- (instancetype)initWithDataStack:(DATAStack *)dataStack {
    self = [super initWithStyle:UITableViewStylePlain];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"UICollectionViewController";
            break;

        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            CGRect bounds = [UIScreen mainScreen].bounds;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(120.0, 120.0);
            layout.sectionInset = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0);
            layout.headerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
            layout.footerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
            UICollectionViewControllerDemo *controller = [[UICollectionViewControllerDemo alloc] initWithLayout:layout andDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;

        default:
            break;
    }
}

@end
