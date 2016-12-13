import UIKit
import CoreData

extension DATASource: UICollectionViewDataSource {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItemsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfItemsInSection = sections[section].numberOfObjects
        }

        return numberOfItemsInSection
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier = self.cellIdentifier

        if let value = self.delegate?.dataSource?(self, cellIdentifierFor: indexPath) {
            cellIdentifier = value
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)

        self.configure(cell, indexPath: indexPath)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let keyPath = self.fetchedResultsController.sectionNameKeyPath {
            if self.cachedSectionNames.isEmpty || indexPath.section >= self.cachedSectionNames.count {
                self.cacheSectionNames(using: keyPath)
            }

            var title: Any?
            if self.cachedSectionNames.count > 0 && indexPath.section < self.cachedSectionNames.count {
                title = self.cachedSectionNames[indexPath.section]
            }
            if let view = self.delegate?.dataSource?(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath, withTitle: title) {
                return view
            }

            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: DATASourceCollectionViewHeader.Identifier, for: indexPath) as? DATASourceCollectionViewHeader {
                headerView.title = title != nil ? String(describing: title!) : ""
                return headerView
            }
        } else if let view = self.delegate?.dataSource?(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath, withTitle: nil) {
            return view
        }

        fatalError("Couldn't find supplementary view for kind: \(kind) at indexPath: \(indexPath), if you don't expect any headers to be used, consider removing the `headerReferenceSize` from your UICollectionViewLayout.")
    }

    func cacheSectionNames(using keyPath: String) {
        var ascending: Bool? = nil

        if let sortDescriptors = self.fetchedResultsController.fetchRequest.sortDescriptors {
            for sortDescriptor in sortDescriptors where sortDescriptor.key == keyPath {
                ascending = sortDescriptor.ascending
            }

            if ascending == nil {
                fatalError("KeyPath: \(keyPath) should be included in the fetchRequest's sortDescriptors. This is necessary so we can know if the keyPath is ascending or descending. Current descriptors are: \(sortDescriptors)")
            }
        }

        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = self.fetchedResultsController.fetchRequest.entity
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = [keyPath]
        request.predicate = self.fetchedResultsController.fetchRequest.predicate
        request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: ascending!)]

        let objects = try! self.fetchedResultsController.managedObjectContext.fetch(request) as! [NSDictionary]
        for object in objects {
            self.cachedSectionNames.append(contentsOf: object.allValues)
        }
    }
}
