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

        let bounds = UIScreen.main.bounds

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        layout.headerReferenceSize = CGSize(width: bounds.size.width, height: 60)

        let viewController = CollectionController(layout: layout, dataStack: self.dataStack)
        window.rootViewController = UINavigationController(rootViewController: viewController)
        window.makeKeyAndVisible()
        
        return true
    }
}
