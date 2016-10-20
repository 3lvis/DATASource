#import "TableViewControllerWithSections.h"

@import DATAStack;
@import CoreData;

#import "ObjectiveCDemo-Swift.h"


static NSString *CellIdentifier = @"CellIdentifier";

@interface TableViewControllerWithSections ()

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;

@end

@implementation TableViewControllerWithSections

- (instancetype)initWithDataStack:(DATAStack *)dataStack {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _dataStack = dataStack;
    }

    return self;
}

- (DATASource *)dataSource {
    if (!_dataSource) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"firstLetterOfName" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

        _dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                             cellIdentifier:CellIdentifier
                                               fetchRequest:request
                                                mainContext:self.dataStack.mainContext
                                                sectionName:@"firstLetterOfName"
                                              configuration:^(UITableViewCell * _Nonnull cell, NSManagedObject * _Nonnull item, NSIndexPath * _Nonnull indexPath) {
                                                  cell.textLabel.text = [item valueForKey:@"name"];
                                              }];
    }

    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];

    self.tableView.dataSource = self.dataSource;

    NSManagedObject *object = [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    NSLog(@"object: %@", object);
}

- (void)addAction {
    [Helper addNewUserWithDataStack:self.dataStack];
}

@end
