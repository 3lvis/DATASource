import UIKit
import DATAStack
import CoreData

class TableViewControllerCRUDAndReorder: UITableViewController {
    unowned let dataStack: DATAStack

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext)
        dataSource.delegate = self

        return dataSource
    }()

    init(dataStack: DATAStack) {
        self.dataStack = dataStack

        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TableViewController.saveAction))
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        self.tableView.dataSource = self.dataSource
    }

    func saveAction() {
        print("created index: \(self.dataSource.count)")
        Helper.addNewUser(index: self.dataSource.count, dataStack: self.dataStack)
    }
}

extension TableViewControllerCRUDAndReorder: DATASourceDelegate {

    func dataSource(_ dataSource: DATASource, configureTableViewCell cell: UITableViewCell, withItem item: NSManagedObject, atIndexPath indexPath: IndexPath) {
        let name = item.value(forKey: "name") as? String ?? ""
        let index = item.value(forKey: "index") as? Int ?? 0
        cell.textLabel?.text = "\(name) — \(index)"
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let object = self.dataSource.object(indexPath)!
            self.dataStack.mainContext.delete(object)
            try! self.dataStack.mainContext.save()
        case .insert: break
        case .none: break
        }
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        print("sourceIndexPath: \(sourceIndexPath) — destinationIndexPath: \(destinationIndexPath)")

        let movedUser = self.dataSource.object(sourceIndexPath)!
        let movedName = movedUser.value(forKey: "name")! as! String

        self.dataStack.performInNewBackgroundContext { backgroundContext in
            let request = NSFetchRequest<NSManagedObject>(entityName: "User")
            request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
            let users = try! backgroundContext.fetch(request)

            var beforeAssignedIndex = 0
            var afterAssignedIndex = destinationIndexPath.row + 1
            for (index, updatedUser) in users.enumerated() {
                let updatedUserName = updatedUser.value(forKey: "name")! as! String
                if updatedUserName == movedName {
                    updatedUser.setValue(destinationIndexPath.row, forKey: "index")
                    print("first change. object from name: \(movedName) \(updatedUser.value(forKey: "index")!) to \(destinationIndexPath.row)")
                } else {
                    if index > destinationIndexPath.row {
                        print("changed after: \(afterAssignedIndex) — \(updatedUser.value(forKey: "name")!)")
                        updatedUser.setValue(afterAssignedIndex, forKey: "index")
                        afterAssignedIndex += 1
                    } else {
                        print("changed before: \(beforeAssignedIndex) — \(updatedUser.value(forKey: "name")!)")
                        updatedUser.setValue(beforeAssignedIndex, forKey: "index")
                        beforeAssignedIndex += 1
                    }
                }
            }

            try! backgroundContext.save()

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
