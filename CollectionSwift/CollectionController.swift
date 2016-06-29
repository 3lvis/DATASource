import UIKit

import DATAStack
import CoreData

class CollectionController: UICollectionViewController {
    unowned var dataStack: DATAStack

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(CollectionController.saveAction))
    }

    func saveAction() {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertInto: backgroundContext)

                let name = self.randomString()
                let firstLetter = String(name[name.startIndex])
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter.uppercased(), forKey: "firstLetterOfName")
                do {
                    try backgroundContext.save()
                } catch let savingError as NSError {
                    print("Could not save \(savingError)")
                } catch {
                    fatalError()
                }
            } else {
                print("Oh no")
            }
        }
    }

    func randomString() -> String {
        let letters = "ABCDEFGHIJKL"
        var string = ""
        for _ in 0...5 {
            let token = UInt32(letters.characters.count)
            let letterIndex = Int(arc4random_uniform(token))
            let firstChar = Array(letters.characters)[letterIndex]
            string.append(firstChar)
        }
        
        return string
    }
}

extension CollectionController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let object = self.dataSource.objectAtIndexPath(indexPath) else { return }

        if let name = object.value(forKey: "name") as? String where name.characters.first == "A" {
            self.dataStack.performInNewBackgroundContext({ backgroundContext in
                let backgroundObject = backgroundContext.object(with: object.objectID)
                backgroundObject.setValue(name + "+", forKey: "name")
                try! backgroundContext.save()
            })
        } else {
            self.dataStack.performInNewBackgroundContext({ backgroundContext in
                let backgroundObject = backgroundContext.object(with: object.objectID)
                backgroundContext.delete(backgroundObject)
                try! backgroundContext.save()
            })
        }
    }
}
