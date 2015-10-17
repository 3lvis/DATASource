#import "ViewController.h"

@import DATAStack;
@import DATASource;

static NSString *CellIdentifier = @"CellIdentifier";

@interface ViewController ()

@property (nonatomic, weak) DATAStack *dataStack;
@property (nonatomic) DATASource *dataSource;

@end

@implementation ViewController

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
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES]];

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
}

- (void)addAction {
    [self.dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                                  inManagedObjectContext:backgroundContext];
        NSManagedObject *user = [[NSManagedObject alloc] initWithEntity:entity
                                         insertIntoManagedObjectContext:backgroundContext];
        NSString *name = [self randomString];
        NSString *firstLetter = [[name substringToIndex:1] uppercaseString];
        [user setValue:name forKey:@"name"];
        [user setValue:firstLetter forKey:@"firstLetterOfName"];
        [backgroundContext save:nil];
    }];
}

- (NSString *)randomString {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString *randomString = [NSMutableString stringWithCapacity:10];

    for (int i = 0; i < 10; i++) {
        u_int32_t rnd = (u_int32_t)[letters length];
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform(rnd)]];
    }

    return randomString;
}

@end
