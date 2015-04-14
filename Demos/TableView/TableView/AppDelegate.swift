import UIKit
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var dataStack = DATAStack()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

    let viewController = ViewController(dataStack: self.dataStack)
    self.window?.rootViewController = UINavigationController(rootViewController: viewController)
    self.window?.makeKeyAndVisible()

    return true
  }
}

