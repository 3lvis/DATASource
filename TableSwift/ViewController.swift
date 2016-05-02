import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    weak var dataStack: DATAStack?

    var rowSelectedCount = 0

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "firstLetterOfName", ascending: true)
        ]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: CustomCell.Identifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            if let cell = cell as? CustomCell {
                cell.label.text = item.valueForKey("name") as? String
            }
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.saveAction))
        self.tableView.dataSource = self.dataSource
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)

                let name = self.randomString()
                let firstLetter = "0"
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter, forKey: "firstLetterOfName")

                do {
                    try backgroundContext.save()
                } catch let savingError as NSError {
                    print("Could not save \(savingError)")
                } catch {
                    fatalError()
                }

                self.dataStack!.persist(nil)
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = self.dataSource.objectAtIndexPath(indexPath)
        self.dataStack?.performInNewBackgroundContext { backgroundContext in
            guard let objectID = user?.objectID else { fatalError() }
            let user = backgroundContext.objectWithID(objectID)
            let name = user.valueForKey("name") as! String
            self.rowSelectedCount += 1
            user.setValue("\(self.rowSelectedCount)-\(name)", forKey: "name")
            try! backgroundContext.save()
        }
    }
}