import UIKit

protocol StaticTableDataSourceDelegate: class {
    func staticTableDataSource(_ staticTableDataSource: StaticTableResponder, configure cell: TableResponding, at indexPath: IndexPath)
}

class StaticTableResponder: NSObject {
    var sections: [[TableCellData]]
    var tableView: UITableView
    weak var delegate: StaticTableDataSourceDelegate?

    init(sections: [[TableCellData]], tableView: UITableView, cellIdentifier: String) {
        self.sections = sections
        self.tableView = tableView

        super.init()
    }

    func object(at indexPath: IndexPath) -> TableCellData {
        return self.sections[indexPath.section][indexPath.row]
    }
}

extension StaticTableResponder: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> Int {
        return self.sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.object(at: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier)! as! TableResponding

        item.configuration(cell)
        cell.respondingDelegate = self
        cell.indexPath = indexPath

        return cell as! UITableViewCell
    }
}

extension StaticTableResponder: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = self.object(at: indexPath)
        item.action()
    }
}

extension StaticTableResponder: TableRespondingDelegate {
    func tableResponding(_ tableResponding: TableResponding) {
        let item = self.object(at: tableResponding.indexPath!)
        item.action()
    }
}
