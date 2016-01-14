import UIKit
import DATAStack
import DATASource
import CoreData

class ViewController: UITableViewController {
    static let Identifier = "Identifier"
    weak var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "firstLetterOfName", ascending: true)
        ]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: ViewController.Identifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            cell.textLabel?.text = item.valueForKey("name") as? String
        })

        dataSource.delegate = self

        return dataSource
    }()

    lazy var infiniteLoadingIndicator: InfiniteLoadingIndicator = {
        let infiniteLoadingIndicator = InfiniteLoadingIndicator(parentController: self.parentViewController!)

        return infiniteLoadingIndicator
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
            self.infiniteLoadingIndicator.present()
            self.loadItems(0, completion: {
                self.infiniteLoadingIndicator.dismiss()
            })
        }
    }

    var loading = false
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let tableView = self.tableView else { return }
        guard self.loading == false else { return }

        let offset = tableView.contentOffset.y + UIScreen.mainScreen().bounds.height
        if offset >= scrollView.contentSize.height {
            if let item = self.dataSource.objects.last {
                self.loading = true
                self.infiniteLoadingIndicator.present()
                let initialIndex = Int(item.valueForKey("name") as! String)! + 1
                self.loadItems(initialIndex, completion: {
                    self.loading = false
                    self.infiniteLoadingIndicator.dismiss()
                    print("loaded items starting at \(item.valueForKey("name"))")
                })
            }
        }
    }

    func loadItems(initialIndex: Int, completion: (Void -> Void)?) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.dataStack!.performInNewBackgroundContext { backgroundContext in
                if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                    for i in initialIndex..<initialIndex + 18 {
                        let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)
                        user.setValue(String(format: "%04d", i), forKey: "name")

                        let tens = Int(floor(Double(i) / 10.0) * 10)
                        user.setValue(String(tens), forKey: "firstLetterOfName")
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

extension ViewController: DATASourceDelegate {
    func sectionIndexTitlesForDataSource(dataSource: DATASource, tableView: UITableView) -> [String] {
        return [String]()
    }
}
