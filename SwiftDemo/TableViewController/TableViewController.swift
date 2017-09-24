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

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: CustomTableViewCell.Identifier, fetchRequest: request, mainContext: self.dataStack.mainContext) { cell, item, indexPath in
            let cell = cell as! CustomTableViewCell
            cell.textLabel?.text = item.value(forKey: "name") as? String ?? ""
        }

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

        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.Identifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TableViewController.saveAction))
        self.tableView.dataSource = self.dataSource

        _ = self.dataSource.objectAtIndexPath(IndexPath(row: 0, section: 0))
    }

    @objc func saveAction() {
        Helper.addNewUser(dataStack: self.dataStack)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.dataSource.object(indexPath)

        let name = item?.value(forKey: "name") as? String ?? ""
        let alert = UIAlertController(title: "Selected object", message: name, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
