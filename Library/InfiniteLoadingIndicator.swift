import UIKit

class InfiniteLoadingIndicator: UIView {
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingIndicator.startAnimating()

        return loadingIndicator
    }()

    unowned var parentController: UIViewController

    init(parentController: UIViewController) {
        self.parentController = parentController

        let width = CGFloat(40)
        let height = CGFloat(40)
        let bottomMargin = CGFloat(20)
        let x = (self.parentController.view.frame.width - width) / 2
        let y = self.parentController.view.frame.height - height - bottomMargin
        let frame = CGRect(x: x, y: y, width: width, height: height)
        super.init(frame: frame)

        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = height / 2
        self.layer.shadowColor = UIColor.black.cgColor
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
        self.frame.origin.y = self.parentController.view.frame.height
        if self.superview == nil {
            self.parentController.view.addSubview(self)

            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: {
                self.frame = originalFrame
                }, completion: nil)
        }
    }

    func dismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let originalFrame = self.frame
            var newFrame = self.frame
            newFrame.origin.y = self.parentController.view.frame.height + 10
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.allowUserInteraction], animations: { () -> Void in
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
