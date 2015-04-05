#import "ViewController.h"
#import "DATASource.h"
#import "DATAStack.h"
#import "Task.h"
#import "AppDelegate.h"

static NSString * const ANDYCellIdentifier = @"ANDYCellIdentifier";

@interface ViewController ()

@property (nonatomic, strong) DATASource *dataSource;
@property (nonatomic, strong) DATAStack *dataStack;

@end

@implementation ViewController

- (instancetype)initWithDataStack:(DATAStack *)dataStack
{
    self = [super init];
    if (!self) return nil;

    _dataStack = dataStack;

    return self;
}

#pragma mark - Lazy Instantiation

- (DATASource *)dataSource
{
    if (_dataSource) return _dataSource;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];

    _dataSource = [[DATASource alloc] initWithTableView:self.tableView
                                           fetchRequest:fetchRequest
                                         cellIdentifier:ANDYCellIdentifier
                                            mainContext:self.dataStack.mainContext
                                              configure:^(UITableViewCell *cell, Task *task, NSIndexPath *indexPath) {
                                                  cell.textLabel.text = task.title;
                                              }];

    return _dataSource;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ANDYCellIdentifier];
    self.tableView.dataSource = self.dataSource;

    UIBarButtonItem *addTaskButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(createTask)];
    self.navigationItem.rightBarButtonItem = addTaskButton;
}

#pragma mark - Actions

- (void)createTask
{
    [self.dataStack performInNewBackgroundContext:^(NSManagedObjectContext *backgroundContext) {
        Task *task = [Task insertInManagedObjectContext:backgroundContext];
        task.title = @"Hello!";
        task.date = [NSDate date];
        [backgroundContext save:nil];
    }];
}

@end
