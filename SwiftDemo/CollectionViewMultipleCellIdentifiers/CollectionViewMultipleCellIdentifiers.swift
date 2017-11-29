import UIKit

import DATAStack
import CoreData

class CollectionViewMultipleCellIdentifiers: UICollectionViewController {
    let dataStack: DATAStack

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
        ]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: "", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            let role = item.value(forKey: "role") as! String
            if role == "manager" {
                let collectionCell = cell as! AlternativeCell
                collectionCell.textLabel.text = item.value(forKey: "name") as? String
            } else {
                let collectionCell = cell as! CollectionCell
                collectionCell.textLabel.text = item.value(forKey: "name") as? String
            }
        })
        dataSource.delegate = self

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

        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.identifier)
        collectionView.register(AlternativeCell.self, forCellWithReuseIdentifier: AlternativeCell.Identifier)
        collectionView.dataSource = self.dataSource
        collectionView.backgroundColor = UIColor.white
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveAction))
    }

    @objc func saveAction() {
        Helper.addNewUser(dataStack: self.dataStack)
    }
}

extension CollectionViewMultipleCellIdentifiers: DATASourceDelegate {
    func dataSource(_ dataSource: DATASource, cellIdentifierFor indexPath: IndexPath) -> String {
        let object = dataSource.object(indexPath)
        let role = object!.value(forKey: "role") as! String
        if role == "manager" {
            return AlternativeCell.Identifier
        } else {
            return CollectionCell.identifier
        }
    }
}
