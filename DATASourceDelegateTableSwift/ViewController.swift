import UIKit
import DATAStack
import CoreData

class ViewController: UITableViewController {
    static let CellIdentifier = "CellIdentifier"
    var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: ViewController.CellIdentifier, fetchRequest: request, mainContext: self.dataStack!.mainContext, configuration: { cell, item, indexPath in
            let date = item.valueForKey("createdDate") as? NSDate
            cell.textLabel?.text = date?.description
        })

        dataSource.delegate = self

        return dataSource
    }()

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ViewController.CellIdentifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ViewController.saveAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ViewController.editAction))
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self
    }

    func saveAction() {
        self.dataStack!.performInNewBackgroundContext { backgroundContext in
            let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext)!
            let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)
            user.setValue(NSDate(), forKey: "createdDate")
            try! backgroundContext.save()
            self.dataStack!.persist(nil)
        }
    }

    func editAction() {
        self.setEditing(!self.editing, animated: true)
    }
}

extension ViewController: DATASourceDelegate {
    func dataSource(dataSource: DATASource, tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // This doesn't seem to be needed when implementing tableView(_:editActionsForRowAtIndexPath).
    func dataSource(dataSource: DATASource, tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
}

// MARK: - UITableViewDelegate

extension ViewController {
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Default, title: "Delete") { action, indexPath in
            let item = self.dataSource.objectAtIndexPath(indexPath)!
            self.dataStack!.mainContext.deleteObject(item)
        }

        return [delete]
    }
}