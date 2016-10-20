import UIKit
import DATAStack
import CoreData

class TableViewController: UITableViewController {
    unowned let dataStack: DATAStack

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]

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
        self.tableView.dataSource = self.dataSource

        let object = self.dataSource.objectAtIndexPath(IndexPath(row: 0, section: 0))
        print(object)
    }

    func saveAction() {
        Helper.addNewUser(dataStack: self.dataStack)
    }
}

extension TableViewController: DATASourceDelegate {

    func dataSource(_ dataSource: DATASource, configureTableViewCell cell: UITableViewCell, withItem item: NSManagedObject, atIndexPath indexPath: IndexPath) {
        cell.textLabel?.text = item.value(forKey: "name") as? String ?? ""
    }
}
