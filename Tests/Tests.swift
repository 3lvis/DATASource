import UIKit
import XCTest
import DATAStack
import CoreData

class Tests: XCTestCase {
    static let CellIdentifier = "CellIdentifier"
    static let EntityName = "User"
    static let ModelName = "DataModel"

    func userWithName(name: String, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(Tests.EntityName, inManagedObjectContext: context)!
        let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
        user.setValue(name, forKey: "name")

        return user
    }

    func testTableViewDATASource() {
        var success = false
        let bundle = NSBundle(forClass: Tests.self)
        let dataStack = DATAStack(modelName: Tests.ModelName, bundle: bundle, storeType: .InMemory)

        let tableView = UITableView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Tests.CellIdentifier)

        let request = NSFetchRequest(entityName: Tests.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(tableView: tableView, cellIdentifier: Tests.CellIdentifier, fetchRequest: request, mainContext: dataStack.mainContext) { cell, item, indexPath in
            if let name = item.valueForKey("name") as? String {
                XCTAssertEqual(name, "Elvis")
                success = true
            }
        }

        tableView.dataSource = dataSource
        tableView.reloadData()

        dataStack.performInNewBackgroundContext { backgroundContext in
            self.userWithName("Elvis", context: backgroundContext)
            try! backgroundContext.save()
        }

        XCTAssertTrue(success)
    }

    /*
    func testCollectionViewDataSouce()  {
        var success = false
        let bundle = NSBundle(forClass: Tests.self)
        let dataStack = DATAStack(modelName: Tests.ModelName, bundle: bundle, storeType: .InMemory)
        let layout = UICollectionViewLayout()
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: Tests.CellIdentifier)
        let request = NSFetchRequest(entityName: Tests.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: Tests.CellIdentifier, fetchRequest: request, mainContext: dataStack.mainContext) { cell, item, indexPath in
            success = true
        }
        collectionView.dataSource = dataSource
        collectionView.reloadData()

        dataStack.performInNewBackgroundContext { backgroundContext in
            self.userWithName("Elvis", context: backgroundContext)
            try! backgroundContext.save()
        }

        XCTAssertTrue(success)

        // Fails
        // CoreData: error: Serious application error.  An exception was caught from the delegate of NSFetchedResultsController during a call to -controllerDidChangeContent:.  
        // Invalid update: invalid number of items in section 0.  The number of items contained in an existing section after the update (1) must be equal to the number of items contained in that section before the update (1), 
        // plus or minus the number of items inserted or deleted from that section (1 inserted, 0 deleted) and plus or minus the number of items moved into or out of that section (0 moved in, 0 moved out). with userInfo (null)
    }
     */
}
