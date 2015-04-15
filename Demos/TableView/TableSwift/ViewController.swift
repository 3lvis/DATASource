import UIKit
import DATAStack

class ViewController: UITableViewController {

    var dataStack: DATAStack?

    convenience init(dataStack: DATAStack) {
        self.init(style: .Plain)

        self.dataStack = dataStack
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.redColor()
    }
}

