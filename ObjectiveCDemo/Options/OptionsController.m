#import "OptionsController.h"

#import "CollectionViewController.h"
#import "CollectionViewControllerWithSections.h"
#import "CollectionViewControllerWithFooter.h"

#import "TableViewController.h"
#import "TableViewControllerWithSections.h"

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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"CollectionViewController";
            break;
        case 1:
            cell.textLabel.text = @"CollectionViewControllerWithSections";
            break;
        case 2:
            cell.textLabel.text = @"CollectionViewControllerWithFooter";
            break;
        case 3:
            cell.textLabel.text = @"TableViewController";
            break;
        case 4:
            cell.textLabel.text = @"TableViewControllerWithSections";
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(120.0, 120.0);
            CollectionViewController *controller = [[CollectionViewController alloc] initWithLayout:layout andDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 1: {
            CGRect bounds = [UIScreen mainScreen].bounds;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(120.0, 120.0);
            layout.sectionInset = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0);
            layout.headerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
            CollectionViewControllerWithSections *controller = [[CollectionViewControllerWithSections alloc] initWithLayout:layout andDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 2: {
            CGRect bounds = [UIScreen mainScreen].bounds;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize = CGSizeMake(120.0, 120.0);
            layout.sectionInset = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0);
            layout.headerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
            layout.footerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
            CollectionViewControllerWithFooter *controller = [[CollectionViewControllerWithFooter alloc] initWithLayout:layout andDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 3: {
            TableViewController *controller = [[TableViewController alloc] initWithDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        case 4: {
            TableViewControllerWithSections *controller = [[TableViewControllerWithSections alloc] initWithDataStack:self.dataStack];
            [self.navigationController pushViewController:controller animated:YES];
        } break;
        default:
            break;
    }
}

@end
