import UIKit
import CoreData
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataStack: DATAStack?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let bounds = UIScreen.mainScreen().bounds
        self.window = UIWindow(frame: bounds)

        self.dataStack = DATAStack(modelName: "CollectionSwift")

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        layout.headerReferenceSize = CGSize(width: bounds.size.width, height: 60)

        let viewController = CollectionController(layout: layout, dataStack: self.dataStack!)
        self.window?.rootViewController = UINavigationController(rootViewController: viewController)
        self.window?.makeKeyAndVisible()

        return true
    }
}
