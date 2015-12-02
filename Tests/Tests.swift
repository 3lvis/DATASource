import UIKit
import XCTest
import DATAStack
import CoreData
import DATASource

class PodTests: XCTestCase {
    static let cellIdentifier = "CellIdentifier"
    static let entityName = "User"
    static let modelName = "DataModel"

    func userWithName(name: String, context: NSManagedObjectContext) -> NSManagedObject {
        let entity = NSEntityDescription.entityForName(PodTests.entityName, inManagedObjectContext: context)!
        let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
        user.setValue(name, forKey: "name")

        return user
    }

    func testTableViewDATASource() {
        var success = false
        let bundle = NSBundle(forClass: PodTests.self)
        let dataStack = DATAStack(modelName: PodTests.modelName, bundle: bundle, storeType: .InMemory)

        let tableView = UITableView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: PodTests.cellIdentifier)

        let request = NSFetchRequest(entityName: PodTests.entityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(tableView: tableView, cellIdentifier: PodTests.cellIdentifier, fetchRequest: request, mainContext: dataStack.mainContext) { cell, item, indexPath in
            if let name = item.valueForKey("name") as? String {
                XCTAssertEqual(name, "Elvis")
                success = true
            }
        }

        tableView.dataSource = dataSource
        tableView.reloadData()

        dataStack.performInNewBackgroundContext { backgroundContext in
            self.userWithName("Elvis", context: backgroundContext)

            do {
                try backgroundContext.save()
            } catch {
                print("Background save error")
            }
        }

        XCTAssertTrue(success)
    }
}
