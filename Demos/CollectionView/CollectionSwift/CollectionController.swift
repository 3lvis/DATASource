import UIKit

import DATAStack
import DATASource

class CollectionController: UICollectionViewController {
    var dataStack: DATAStack?

    lazy var dataSource: DATASource = {
        guard let collectionView = self.collectionView, mainContext = self.dataStack?.mainContext else { fatalError("CollectionView is nil") }

        let request: NSFetchRequest = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let dataSource = DATASource(collectionView: collectionView, cellIdentifier: CollectionCell.Identifier, fetchRequest: request, mainContext: mainContext, sectionName: "firstLetterOfName", configuration: { cell, item, indexPath in
            let collectionCell = cell as! CollectionCell
            collectionCell.textLabel.text = item.valueForKey("name") as? String
        })

        return dataSource
        }()

    init(layout: UICollectionViewLayout, dataStack: DATAStack) {
        super.init(collectionViewLayout: layout)

        self.dataStack = dataStack
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

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "saveAction")
    }

    func saveAction() {
        self.dataStack?.performInNewBackgroundContext { backgroundContext in
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

                self.dataStack?.persistWithCompletion({ })
            } else {
                print("Oh no")
            }
        }
    }

    func randomString() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var string = ""
        for _ in 0...10 {
            let token = UInt32(letters.characters.count)
            let letterIndex = Int(arc4random_uniform(token))
            let firstChar = Array(letters.characters)[letterIndex]
            string.append(firstChar)
        }
        
        return string
    }
}
