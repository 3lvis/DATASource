import UIKit

class TableCellData {
    var title: String
    let cellIdentifier: String
    let icon: UIImage?
    var action: ((Void) -> Void)
    let configuration: ((_ cell: TableResponding) -> Void)

    init(title: String, cellIdentifier: String, icon: UIImage?, action: @escaping ((Void) -> Void), configuration: @escaping ((_ cell: TableResponding) -> Void)) {
        self.title = title
        self.cellIdentifier = cellIdentifier
        self.icon = icon
        self.action = action
        self.configuration = configuration
    }
}
