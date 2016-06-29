import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    weak var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [
            SortDescriptor(key: "firstLetterOfName", ascending: true),
            SortDescriptor(key: "count", ascending: true),
            SortDescriptor(key: "name", ascending: true)
        ]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: CustomCell.Identifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, sectionName: "firstLetterOfName") { cell, item, indexPath in
            if let cell = cell as? CustomCell {
                let name = item.value(forKey: "name") as? String ?? ""
                let count = item.value(forKey: "count") as? Int ?? 0
                cell.label.text = "\(count) — \(name)"
            }
        }

        return dataSource
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.Identifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.saveAction))
        self.tableView.dataSource = self.dataSource

        let object = self.dataSource.objectAtIndexPath(IndexPath(forRow: 0, inSection: 0))
        print(object)
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertInto: backgroundContext)

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.dataSource.objectAtIndexPath(indexPath)
        self.dataStack?.performInNewBackgroundContext { backgroundContext in
            guard let objectID = user?.objectID else { fatalError() }
            let user = backgroundContext.objectWithID(objectID)
            var count = user.valueForKey("count") as? Int ?? 0
            count += 1
            user.setValue(count, forKey: "count")
            try! backgroundContext.save()
        }
    }
}
