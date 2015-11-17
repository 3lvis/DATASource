import UIKit

class AlternativeCollectionCell: UICollectionViewCell {
    static let Identifier = "CollectionCellIdentifierAlternative"

    lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        label.textAlignment = .Center

        return label
        }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.contentView.backgroundColor = UIColor.redColor()

        addSubview(textLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
