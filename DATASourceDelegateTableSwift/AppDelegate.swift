import UIKit
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?

    var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "DataModel")

        return dataStack
    }()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = self.window else { fatalError("Window not found") }

        let viewController = ViewController(dataStack: self.dataStack)
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
        
        return true
    }
}
