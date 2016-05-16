import UIKit

import DATAStack
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(CollectionController.saveAction))
    }

    func saveAction() {
        self.dataStack.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertIntoManagedObjectContext: backgroundContext)

                let name = self.randomString()
                let firstLetter = String(Array(name.characters)[0])
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter.uppercaseString, forKey: "firstLetterOfName")

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
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let object = self.dataSource.objectAtIndexPath(indexPath) else { return }

        if let name = object.valueForKey("name") as? String where name.characters.first == "A" {
            self.dataStack.performInNewBackgroundContext({ backgroundContext in
                let backgroundObject = backgroundContext.objectWithID(object.objectID)
                backgroundObject.setValue(name + "+", forKey: "name")
                try! backgroundContext.save()
            })
        } else {
            self.dataStack.performInNewBackgroundContext({ backgroundContext in
                let backgroundObject = backgroundContext.objectWithID(object.objectID)
                backgroundContext.deleteObject(backgroundObject)
                try! backgroundContext.save()
            })
        }
    }
}
