import UIKit

class StaticTableViewCell: UITableViewCell, TableResponding {
    var _respondingDelegate: TableRespondingDelegate?
    weak var respondingDelegate: TableRespondingDelegate? {
        get {
            return self._respondingDelegate
        }
        set {
            self._respondingDelegate = newValue
        }
    }

    var indexPath: IndexPath?
}
