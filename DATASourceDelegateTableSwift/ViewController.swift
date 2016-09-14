import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    static let CellIdentifier = "CellIdentifier"
    var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: ViewController.CellIdentifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, configuration: { cell, item, indexPath in
            let date = item.value(forKey: "createdDate") as? NSDate
            cell.textLabel?.text = date?.description
        })

        dataSource.delegate = self

        return dataSource
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.CellIdentifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.saveAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ViewController.editAction))
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { backgroundContext in
            let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext)!
            let user = NSManagedObject(entity: entity, insertInto: backgroundContext)
            user.setValue(NSDate(), forKey: "createdDate")
            try! backgroundContext.save()
        }
    }

    func editAction() {
        self.setEditing(!self.isEditing, animated: true)
    }
}

extension ViewController: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }

    // This doesn't seem to be needed when implementing tableView(_:editActionsForRowAtIndexPath).
    func dataSource(_ dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {

    }
}

// MARK: - UITableViewDelegate

extension ViewController {
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, indexPath in
            let item = self.dataSource.objectAtIndexPath(indexPath)!
            self.dataStack!.mainContext.delete(item)
            try! self.dataStack!.mainContext.save()
        }

        return [delete]
    }
}
