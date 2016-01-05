import UIKit

class LoadingView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)

        return loadingIndicator
    }()

    lazy var loadingLabel: UILabel = {
        let loadingLabel = UILabel()
        loadingLabel.textAlignment = .Center
        loadingLabel.textColor = UIColor.whiteColor()
        loadingLabel.font = UIFont.systemFontOfSize(14)

        return loadingLabel
    }()

    init() {
        let bounds = UIScreen.mainScreen().bounds
        let width = CGFloat(150)
        let height = CGFloat(35)
        let bottomMargin = CGFloat(25)
        let x = (bounds.width - width) / 2
        let y = bounds.height - height - bottomMargin
        let frame = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frame)

        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.layer.cornerRadius = height / 2

        let rightMargin = CGFloat(15)
        var loadingIndicatorFrame = self.loadingIndicator.frame
        loadingIndicatorFrame.origin.x = width - loadingIndicatorFrame.width - rightMargin
        loadingIndicatorFrame.origin.y = (height - loadingIndicatorFrame.height) / 2
        self.loadingIndicator.frame = loadingIndicatorFrame
        self.addSubview(self.loadingIndicator)

        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.addSubview(self.loadingLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        self.loadingIndicator.startAnimating()
        self.loadingLabel.text = "Loading"

        if self.superview == nil {
            let window = UIApplication.sharedApplication().keyWindow!
            window.addSubview(self)
        }
    }

    func dismiss() {
        self.loadingIndicator.stopAnimating()
        self.loadingLabel.text = "Done"

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if self.superview != nil {
                self.removeFromSuperview()
            }
        }
    }
}
