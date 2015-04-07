#import "AppDelegate.h"

#import "DATAStack.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic) DATAStack *dataStack;

@end

@implementation AppDelegate

#pragma mark - Getters

- (DATAStack *)dataStack
{
    if (_dataStack) return _dataStack;

    _dataStack = [[DATAStack alloc] init];

    return _dataStack;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10.0f;
    layout.minimumInteritemSpacing = 10.0f;
    layout.itemSize = CGSizeMake(50.0f, 50.0f);

    ViewController *mainController = [[ViewController alloc] initWithLayout:layout andDataStack:self.dataStack];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark - Core Data stack

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.dataStack persistWithCompletion:nil];
}

@end
