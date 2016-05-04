import UIKit
import CoreData

extension DATASource: UICollectionViewDataSource {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItemsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfItemsInSection = sections[section].numberOfObjects
        }

        return numberOfItemsInSection
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath)

        self.configure(cell: cell, indexPath: indexPath)

        return cell
    }

    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if let keyPath = self.fetchedResultsController.sectionNameKeyPath {
            if self.cachedSectionNames.isEmpty {
                var ascending: Bool? = nil

                if let sortDescriptors = self.fetchedResultsController.fetchRequest.sortDescriptors {
                    for sortDescriptor in sortDescriptors where sortDescriptor.key == keyPath {
                        ascending = sortDescriptor.ascending
                    }

                    if ascending == nil {
                        fatalError("KeyPath: \(keyPath) should be included in the fetchRequest's sortDescriptors. This is necessary so we can know if the keyPath is ascending or descending. Current descriptors are: \(sortDescriptors)")
                    }
                }

                let request = NSFetchRequest()
                request.entity = self.fetchedResultsController.fetchRequest.entity
                request.resultType = .DictionaryResultType
                request.returnsDistinctResults = true
                request.propertiesToFetch = [keyPath]
                request.predicate = self.fetchedResultsController.fetchRequest.predicate
                request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: ascending!)]

                let objects = try! self.fetchedResultsController.managedObjectContext.executeFetchRequest(request) as! [NSDictionary]
                for object in objects {
                    self.cachedSectionNames.appendContentsOf(object.allValues)
                }
            }

            let title = self.cachedSectionNames[indexPath.section]

            if let view = self.delegate?.dataSource?(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath, withTitle: title) {
                return view
            }

            if let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: DATASourceCollectionViewHeader.Identifier, forIndexPath: indexPath) as? DATASourceCollectionViewHeader, let title = title as? String {
                headerView.title = title
                return headerView
            }
        }

        if let view = self.delegate?.dataSource?(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath, withTitle: nil) {
            return view
        }
        
        return UICollectionReusableView()
    }
}