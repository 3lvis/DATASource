@import UIKit;
@import CoreData;

@class DATAStack;

@interface ANDYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) DATAStack *dataStack;

extern ANDYAppDelegate *appDelegate;

@end
