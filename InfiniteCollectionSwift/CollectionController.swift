import UIKit

import DATAStack
import DATASource
import CoreData

class CollectionController: UICollectionViewController {
    unowned var dataStack: DATAStack

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "firstLetterOfName", ascending: true)
        ]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: CollectionCell.Identifier, fetchRequest: request, mainContext: self.dataStack.mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            let collectionCell = cell as! CollectionCell
            collectionCell.textLabel.text = item.valueForKey("name") as? String
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
        collectionView.registerClass(CollectionCell.self, forCellWithReuseIdentifier: CollectionCell.Identifier)
        collectionView.dataSource = self.dataSource
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        if self.dataSource.isEmpty {
            self.infiniteLoadingIndicator.present()
            self.loadItems(0, completion: {
                self.infiniteLoadingIndicator.dismiss()
            })
        }
    }

    var loading = false
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        guard let collectionView = self.collectionView else { return }
        guard self.loading == false else { return }

        let offset = collectionView.contentOffset.y + UIScreen.mainScreen().bounds.height
        if offset >= scrollView.contentSize.height {
            if let item = self.dataSource.objects.last {
                self.loading = true
                self.infiniteLoadingIndicator.present()
                let initialIndex = Int(item.valueForKey("name") as! String)! + 1
                self.loadItems(initialIndex, completion: {
                    self.loading = false
                    self.infiniteLoadingIndicator.dismiss()
                    print("loaded items starting at \(item.valueForKey("name"))")
                })
            }
        }
    }

    func loadItems(initialIndex: Int, completion: (Void -> Void)?) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.dataStack.performInNewBackgroundContext { backgroundContext in
                if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                    for i in initialIndex..<initialIndex + 18 {
                        let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)
                        user.setValue(String(format: "%04d", i), forKey: "name")

                        let tens = Int(floor(Double(i) / 10.0) * 10)
                        user.setValue(String(tens), forKey: "firstLetterOfName")
                    }

                    do {
                        try backgroundContext.save()
                    } catch let savingError as NSError {
                        print("Could not save \(savingError)")
                    } catch {
                        fatalError()
                    }

                    self.dataStack.persistWithCompletion({
                        completion?()
                    })
                } else {
                    print("Oh no")
                }
            }
        }
    }
}

extension CollectionController {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let numberOfItems = self.collectionView?.numberOfItemsInSection(indexPath.section) else { return }
        var items = [NSManagedObject]()
        for i in 0..<numberOfItems {
            let newIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
            if let item = self.dataSource.objectAtIndexPath(newIndexPath) {
                items.append(item)
            }
        }

        self.dataStack.performInNewBackgroundContext { backgroundContext in
            for item in items {
                let safeItem = backgroundContext.objectWithID(item.objectID)
                backgroundContext.deleteObject(safeItem)
            }

            try! backgroundContext.save()

            self.dataStack.persistWithCompletion(nil)
        }
    }
}
