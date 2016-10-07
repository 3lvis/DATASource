import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    static let Identifier = "Identifier"
    weak var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "firstLetterOfName", ascending: true)
        ]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: ViewController.Identifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            cell.textLabel?.text = item.value(forKey: "name") as? String
        })

        dataSource.delegate = self

        return dataSource
    }()

    lazy var infiniteLoadingIndicator: InfiniteLoadingIndicator = {
        let infiniteLoadingIndicator = InfiniteLoadingIndicator(parentController: self.parent!)

        return infiniteLoadingIndicator
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.Identifier)
        self.tableView.dataSource = self.dataSource

        if self.dataSource.isEmpty {
            self.infiniteLoadingIndicator.present()
            self.loadItems(0, completion: {
                self.infiniteLoadingIndicator.dismiss()
            })
        }
    }

    var loading = false
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let tableView = self.tableView else { return }
        guard self.loading == false else { return }

        let offset = tableView.contentOffset.y + UIScreen.main.bounds.height
        if offset >= scrollView.contentSize.height {
            if let item = self.dataSource.objects.last {
                self.loading = true
                self.infiniteLoadingIndicator.present()
                let initialIndex = Int(item.value(forKey: "name") as! String)! + 1
                self.loadItems(initialIndex, completion: {
                    self.loading = false
                    self.infiniteLoadingIndicator.dismiss()
                    print("loaded items starting at \(item.value(forKey: "name")!)")
                })
            }
        }
    }

    func loadItems(_ initialIndex: Int, completion: ((Void) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dataStack!.performInNewBackgroundContext { backgroundContext in
                let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext)!
                for i in initialIndex..<initialIndex + 18 {
                    let user = NSManagedObject(entity: entity, insertInto: backgroundContext)
                    user.setValue(String(format: "%04d", i), forKey: "name")

                    let tens = Int(floor(Double(i) / 10.0) * 10)
                    user.setValue(String(tens), forKey: "firstLetterOfName")
                }

                try! backgroundContext.save()
                DispatchQueue.main.async {
                    completion?()
                }
            }
        }
    }
}

extension ViewController: DATASourceDelegate {
    func sectionIndexTitlesForDataSource(_ dataSource: DATASource, tableView: UITableView) -> [String] {
        return [String]()
    }
}
