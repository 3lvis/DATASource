import UIKit
import DATAStack
import CoreData

class TableViewControllerDeleteCells: UITableViewController {
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

        self.tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.Identifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(TableViewControllerDeleteCells.toggleEdit))
        self.tableView.dataSource = self.dataSource

        Helper.addNewUser(dataStack: self.dataStack)
    }

    func toggleEdit() {
        self.setEditing(!self.isEditing, animated: true)
    }
}

extension TableViewControllerDeleteCells: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let item = self.dataSource.object(indexPath)
            dataStack.mainContext.delete(item!)
            try! dataStack.mainContext.save()
        default: break
        }
    }
}
