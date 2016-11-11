import UIKit

import DATAStack

class OptionsController: UITableViewController {
    let dataStack: DATAStack

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
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator

        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "CollectionViewController"
        case 1:
            cell.textLabel?.text = "CollectionViewControllerWithSections"
        case 2:
            cell.textLabel?.text = "CollectionViewMultipleCellIdentifiers"
        case 3:
            cell.textLabel?.text = "TableViewController"
        case 4:
            cell.textLabel?.text = "TableViewControllerWithSections"
        case 5:
            cell.textLabel?.text = "TableViewControllerWithSectionsWithoutIndex"
        case 6:
            cell.textLabel?.text = "TableViewControllerCRUDAndReorder"
        default: break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 120, height: 120)
            layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            let controller = CollectionViewController(layout: layout, dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            let bounds = UIScreen.main.bounds
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 120, height: 120)
            layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            layout.headerReferenceSize = CGSize(width: bounds.size.width, height: 60)
            let controller = CollectionViewControllerWithSections(layout: layout, dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 2:
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 120, height: 120)
            layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
            let controller = CollectionViewMultipleCellIdentifiers(layout: layout, dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 3:
            let controller = TableViewController(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 4:
            let controller = TableViewControllerWithSections(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 5:
            let controller = TableViewControllerWithSectionsWithoutIndex(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        case 6:
            let controller = TableViewControllerCRUDAndReorder(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        default: break
        }
    }
}
