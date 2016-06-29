import UIKit

class CustomCell: UITableViewCell {
    static let Identifier = "CustomCellIdentifier"

    lazy var label: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center

        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(self.label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
}
