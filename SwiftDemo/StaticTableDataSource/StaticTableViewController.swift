import UIKit
import DATAStack
import CoreData

class StaticTableViewController: UITableViewController {
    unowned let dataStack: DATAStack

    lazy var sections: [[TableCellData]] = {
        var sections = [[TableCellData]]()
        var firstSection = [TableCellData]()

        let cellData = TableCellData(title: "Option one", cellIdentifier: "Cell", icon: nil, action: {
            print("hi mom")
            }, configuration: { cell in
                cell.textLabel?.text = "Option one"
        })
        firstSection.append(cellData)

        let switchCellData = TableCellData(title: "Toggle one", cellIdentifier: "SwitchCell", icon: nil, action: {
            print("hi mom")
            }, configuration: { cell in
                cell.textLabel?.text = "Toggle one"
        })
        firstSection.append(switchCellData)

        sections.append(firstSection)

        return sections
    }()

    lazy var responder: StaticTableResponder = {
        return StaticTableResponder(sections: self.sections, tableView: self.tableView, cellIdentifier: "Cell")
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

        self.tableView.register(StaticTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TableViewController.saveAction))

        self.tableView.dataSource = self.responder
        self.tableView.delegate = self.responder
    }
}
