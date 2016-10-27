import UIKit

protocol TableRespondingDelegate: class {
    func tableResponding(_ tableResponding: TableResponding)
}

protocol TableResponding {
    weak var respondingDelegate: TableRespondingDelegate? { get set }
    var imageView: UIImageView? { get }
    var textLabel: UILabel? { get }
    var detailTextLabel: UILabel? { get }
    var indexPath: IndexPath? { get set }
}
