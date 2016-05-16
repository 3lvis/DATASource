#import "AppDelegate.h"

@import DATAStack;
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic) DATAStack *dataStack;

@end

@implementation AppDelegate

#pragma mark - Getters

- (DATAStack *)dataStack {
    if (_dataStack) return _dataStack;

    _dataStack = [[DATAStack alloc] initWithModelName:@"DataModel"];

    return _dataStack;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:bounds];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(120.0, 120.0);
    layout.sectionInset = UIEdgeInsetsMake(15.0, 0.0, 15.0, 0.0);
    layout.headerReferenceSize = CGSizeMake(bounds.size.width, 60.0);
    layout.footerReferenceSize = CGSizeMake(bounds.size.width, 60.0);

    ViewController *mainController = [[ViewController alloc] initWithLayout:layout andDataStack:self.dataStack];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
