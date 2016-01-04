import UIKit
import DATAStack
import DATASource
import CoreData

class ViewController: UITableViewController {
    static let Identifier = "Identifier"
    var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: ViewController.Identifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, configuration: { cell, item, indexPath in
            cell.textLabel?.text = item.valueForKey("name") as? String
        })

        return dataSource
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ViewController.Identifier)
        self.tableView.dataSource = self.dataSource

        if self.dataSource.isEmpty {
            self.loadItems(0, completion: nil)
        }
    }

    var loading = false
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let tableView = self.tableView else { return }
        guard self.loading == false else { return }

        let offset = tableView.contentOffset.y + UIScreen.mainScreen().bounds.height
        if offset > scrollView.contentSize.height {
            if let item = self.dataSource.objects.last {
                self.loading = true
                let initialIndex = Int(item.valueForKey("name") as! String)! + 1
                self.loadItems(initialIndex, completion: {
                    self.loading = false
                    print("loaded items starting at \(item.valueForKey("name"))")
                })
            }
        }
    }

    func loadItems(initialIndex: Int, completion: (Void -> Void)?) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.dataStack!.performInNewBackgroundContext { backgroundContext in
                if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                    for i in initialIndex..<initialIndex + 20 {
                        let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)
                        user.setValue(String(format: "%04d", i), forKey: "name")
                    }

                    do {
                        try backgroundContext.save()
                    } catch let savingError as NSError {
                        print("Could not save \(savingError)")
                    } catch {
                        fatalError()
                    }

                    self.dataStack!.persistWithCompletion({
                        completion?()
                    })
                } else {
                    print("Oh no")
                }
            }
        }
    }
}
