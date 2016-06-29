import UIKit

import DATAStack
import CoreData

class CollectionController: UICollectionViewController {
    unowned var dataStack: DATAStack

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [
            SortDescriptor(key: "name", ascending: true),
            SortDescriptor(key: "firstLetterOfName", ascending: true)
        ]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: CollectionCell.Identifier, fetchRequest: request, mainContext: self.dataStack.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            let collectionCell = cell as! CollectionCell
            collectionCell.textLabel.text = item.value(forKey: "name") as? String
        })

        return dataSource
    }()

    lazy var infiniteLoadingIndicator: InfiniteLoadingIndicator = {
        let infiniteLoadingIndicator = InfiniteLoadingIndicator(parentController: self)

        return infiniteLoadingIndicator
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
        collectionView.backgroundColor = UIColor.white()
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        if self.dataSource.isEmpty {
            self.infiniteLoadingIndicator.present()
            self.loadItems(0, completion: {
                self.infiniteLoadingIndicator.dismiss()
            })
        }
    }

    var loading = false
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = self.collectionView else { return }
        guard self.loading == false else { return }

        let offset = collectionView.contentOffset.y + UIScreen.main().bounds.height
        if offset >= scrollView.contentSize.height {
            if let item = self.dataSource.objects.last {
                self.loading = true
                self.infiniteLoadingIndicator.present()
                let initialIndex = Int(item.value(forKey: "name") as! String)! + 1
                self.loadItems(initialIndex, completion: {
                    self.loading = false
                    self.infiniteLoadingIndicator.dismiss()
                    print("loaded items starting at \(item.value(forKey: "name"))")
                })
            }
        }
    }

    func loadItems(_ initialIndex: Int, completion: ((Void) -> Void)?) {
        DispatchQueue.main.after(when: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.dataStack.performInNewBackgroundContext { backgroundContext in
                let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext)!
                for i in initialIndex..<initialIndex + 18 {
                    let user = NSManagedObject(entity: entity, insertInto: backgroundContext)
                    user.setValue(String(format: "%04d", i), forKey: "name")

                    let tens = Int(floor(Double(i) / 10.0) * 10)
                    user.setValue(String(tens), forKey: "firstLetterOfName")
                }

                try! backgroundContext.save()
                DispatchQueue.main().asynchronously(DispatchQueue.main) {
                    completion?()
                }
            }
        }
    }
}

extension CollectionController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let numberOfItems = self.collectionView?.numberOfItems(inSection: (indexPath as NSIndexPath).section) else { return }
        var items = [NSManagedObject]()
        for i in 0..<numberOfItems {
            let newIndexPath = IndexPath(row: i, section: (indexPath as NSIndexPath).section)
            if let item = self.dataSource.objectAtIndexPath(newIndexPath) {
                items.append(item)
            }
        }

        self.dataStack.performInNewBackgroundContext { backgroundContext in
            for item in items {
                let safeItem = backgroundContext.object(with: item.objectID)
                backgroundContext.delete(safeItem)
            }
            try! backgroundContext.save()
        }
    }
}
