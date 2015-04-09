import UIKit
import DATAStack

class ViewController: UITableViewController {
  var dataStack: DATAStack

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  init(dataStack: DATAStack) {
    self.dataStack = dataStack

    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")

    let request: NSFetchRequest = NSFetchRequest(entityName: "User")
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

    self.tableView.dataSource = DATASource(
        tableView: self.tableView,
        fetchRequest: request, cellIdentifier: "Cell",
        mainContext: self.dataStack.mainContext,
        configuration: { (<#UITableViewCell!#>, <#NSManagedObject!#>, <#NSIndexPath!#>) -> Void in
            // cell.textLabel.text = item.valueForKey("name")
    })
  }
}

