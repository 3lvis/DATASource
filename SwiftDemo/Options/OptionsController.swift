import UIKit

import DATAStack

enum Option: Int {
    case collection
    case collectionWithSections
    case collectionWithMultipleCellIdentifiers
    case table
    case tableWithSections
    case tableWithSectionsWithoutIndex
    case tableDeleteCells

    var title: String {
        switch self {
        case .collection: return "CollectionViewController"
        case .collectionWithSections: return "CollectionViewControllerWithSections"
        case .collectionWithMultipleCellIdentifiers: return "CollectionViewMultipleCellIdentifiers"
        case .table: return "TableViewController"
        case .tableWithSections: return "TableViewControllerWithSections"
        case .tableWithSectionsWithoutIndex: return "TableViewControllerWithSectionsWithoutIndex"
        case .tableDeleteCells: return "TableViewControllerDeleteCells"
        }
    }

    func viewController(with dataStack: DATAStack) -> UIViewController {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)

        switch self {
        case .collection:
            return CollectionViewController(layout: layout, dataStack: dataStack)
        case .collectionWithSections:
            return CollectionViewController(layout: layout, dataStack: dataStack)
        case .collectionWithMultipleCellIdentifiers:
            return CollectionViewController(layout: layout, dataStack: dataStack)
        case .table: return TableViewController(dataStack: dataStack)
        case .tableWithSections: return TableViewControllerWithSections(dataStack: dataStack)
        case .tableWithSectionsWithoutIndex: return TableViewControllerWithSectionsWithoutIndex(dataStack: dataStack)
        case .tableDeleteCells: return TableViewControllerDeleteCells(dataStack: dataStack)
        }
    }
}

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
        return Option.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if let item = Option(rawValue: indexPath.row) as Option? {
            cell.textLabel?.text = item.title
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let item = Option(rawValue: indexPath.row) as Option? {
            navigationController?.pushViewController(item.viewController(with: self.dataStack), animated: true)
        }
    }
}

public extension RawRepresentable where RawValue: Integer {
    public static var count: Int {
        var i: RawValue = 0
        while let _ = Self(rawValue: i) {
            i = i.advanced(by: 1)
        }
        return Int(i.toIntMax())
    }
}
