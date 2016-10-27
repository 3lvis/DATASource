import UIKit

class SwitchCell: UITableViewCell, TableResponding {
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

    static let identifier = String(describing: SwitchCell.self)

    lazy var `switch`: UISwitch = {
        let `switch` = UISwitch()
        `switch`.addTarget(self, action: #selector(self.valueChanged), for: .valueChanged)

        return `switch`
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none

        self.backgroundColor = .clear

        self.contentView.addSubview(self.switch)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func valueChanged() {
        self.respondingDelegate?.tableResponding(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let parentWidth = self.contentView.frame.width
        let parentHeight = self.contentView.frame.height
        let containerWidth = CGFloat(310)
        let horizontalMargin = CGFloat(18)

        var labelFrame: CGRect {
            let switchWidth = self.switch.frame.width
            let width = parentWidth - switchWidth - (horizontalMargin * 2)
            return CGRect(x: horizontalMargin, y: 0, width: width, height: parentHeight)
        }
        self.textLabel?.frame = labelFrame

        var switchFrame: CGRect {
            let switchHeight = self.switch.frame.height
            let switchWidth = self.switch.frame.width
            let y = (parentHeight - switchHeight) / 2
            let x = parentWidth - switchWidth - horizontalMargin
            return CGRect(x: x, y: y, width: switchWidth, height: switchHeight)
        }
        self.switch.frame = switchFrame
    }
}
