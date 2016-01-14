import UIKit

class LoadingView: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        loadingIndicator.startAnimating()

        return loadingIndicator
    }()

    init() {
        let bounds = UIScreen.mainScreen().bounds
        let width = CGFloat(40)
        let height = CGFloat(40)
        let bottomMargin = CGFloat(25)
        let x = (bounds.width - width) / 2
        let y = bounds.height - height - bottomMargin
        let frame = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frame)

        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = height / 2
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.3

        var loadingIndicatorFrame = self.loadingIndicator.frame
        loadingIndicatorFrame.origin.x = (width - loadingIndicatorFrame.width) / 2
        loadingIndicatorFrame.origin.y = (height - loadingIndicatorFrame.height) / 2
        self.loadingIndicator.frame = loadingIndicatorFrame
        self.addSubview(self.loadingIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present() {
        let originalFrame = self.frame
        self.frame.origin.y = UIScreen.mainScreen().bounds.height
        if self.superview == nil {
            let window = UIApplication.sharedApplication().keyWindow!
            window.addSubview(self)

            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.AllowUserInteraction], animations: {
                self.frame = originalFrame
                }, completion: nil)
        }
    }

    func dismiss() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            let originalFrame = self.frame
            var newFrame = self.frame
            newFrame.origin.y = UIScreen.mainScreen().bounds.height
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.AllowUserInteraction], animations: { () -> Void in
                self.frame = newFrame
                }, completion: { finished in
                    self.frame = originalFrame
                    if self.superview != nil {
                        self.removeFromSuperview()
                    }
            })
        }
    }
}
