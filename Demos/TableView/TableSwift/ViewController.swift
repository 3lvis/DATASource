import UIKit
import DATAStack

class ViewController: UITableViewController {

    var dataStack: DATAStack?
    var dataSource: DATASource?

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack

        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "name",
            ascending: true)]

        self.dataSource = DATASource(
            tableView: self.tableView,
            fetchRequest: request,
            cellIdentifier: "Cell",
            mainContext: self.dataStack!.mainContext,
            configuration: { (cell, item, indexPath) -> Void in
                let cell = cell as! UITableViewCell
                cell.textLabel!.text = "Hi"
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveAction")

        self.tableView.dataSource = self.dataSource
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { (backgroundContext) -> Void in
            if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)
                user.setValue("Elvis", forKey: "name")
                var error: NSError?
                if !backgroundContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
            } else {
                println("Oh no")
            }
        }
    }
}

