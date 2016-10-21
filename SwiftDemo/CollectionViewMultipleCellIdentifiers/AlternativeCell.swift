import UIKit

public class AlternativeCell: UICollectionViewCell {
    public static let Identifier = "AlternativeCell"

    public lazy var textLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        label.textAlignment = .center

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.red.cgColor
        self.contentView.layer.cornerRadius = 20

        addSubview(textLabel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
