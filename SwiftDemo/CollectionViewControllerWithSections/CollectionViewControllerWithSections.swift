import UIKit

import DATAStack
import CoreData

class CollectionViewControllerWithSections: UICollectionViewController {
    unowned let dataStack: DATAStack

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "firstLetterOfName", ascending: true),
        ]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: CollectionCell.Identifier, fetchRequest: request, mainContext: self.dataStack.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            let collectionCell = cell as! CollectionCell
            collectionCell.textLabel.text = item.value(forKey: "name") as? String
        })

        return dataSource
    }()

    init(layout: UICollectionViewLayout, dataStack: DATAStack) {
        self.dataStack = dataStack

        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.Identifier)
        collectionView.dataSource = self.dataSource
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CollectionViewController.saveAction))
    }

    func saveAction() {
        Helper.addNewUser(dataStack: self.dataStack)
    }
}
