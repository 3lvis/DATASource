import UIKit
import DATAStack

class ViewController: UITableViewController {

    var dataStack: DATAStack?
    var dataSource: DataSource?

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack

        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        self.dataSource = DataSource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack!.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            let cell = cell as! UITableViewCell
            cell.textLabel?.text = item.valueForKey("name") as? String
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "saveAction")
        self.tableView.dataSource = self.dataSource
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { (backgroundContext) -> Void in
            if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)

                let name = self.randomString()
                let firstLetter = String(Array(name.characters)[0])
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter.uppercaseString, forKey: "firstLetterOfName")

                var error: NSError?
                do {
                    try backgroundContext.save()
                } catch let error1 as NSError {
                    error = error1
                    print("Could not save \(error), \(error?.userInfo)")
                } catch {
                    fatalError()
                }

                self.dataStack!.persistWithCompletion({ })
            } else {
                print("Oh no")
            }
        }
    }

    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var string = ""
        for _ in 0...10 {
            let token = UInt32(letters.characters.count)
            let letterIndex = Int(arc4random_uniform(token))
            let firstChar = Array(letters.characters)[letterIndex]
            string.append(firstChar)
        }

        return string
    }
}
