import UIKit
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)

        return window
        }()

    var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "TableSwift")

        return dataStack
        }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if let window = self.window = UIWindow(frame: UIScreen.mainScreen().bounds) {
            self.dataStack = DATAStack(modelName: "TableSwift")

            let viewController = ViewController(dataStack: self.dataStack!)
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
        }

        return true
    }
}
