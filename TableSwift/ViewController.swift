import UIKit
import DATAStack
import DATASource
import CoreData

class ViewController: UITableViewController {
    var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(tableView: self.tableView, fetchRequest: request, mainContext: self.dataStack!.mainContext, configuration: { (cell, item, indexPath) -> () in
            if let cell = cell as? CustomCell {
                cell.label.text = item.valueForKey("name") as? String
            }
            }, cellIdentifier: { (indexPath) -> (String) in
                return CustomCell.Identifier
        })

        return dataSource
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(CustomCell.self, forCellReuseIdentifier: CustomCell.Identifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "saveAction")
        self.tableView.dataSource = self.dataSource
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)

                let name = self.randomString()
                let firstLetter = String(Array(name.characters)[0])
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter, forKey: "firstLetterOfName")

                do {
                    try backgroundContext.save()
                } catch let savingError as NSError {
                    print("Could not save \(savingError)")
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
        let letters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZÅØÆ"
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
