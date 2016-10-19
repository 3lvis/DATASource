import UIKit
import CoreData

extension DATASource: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfRowsInSection = sections[section].numberOfObjects
        }

        return numberOfRowsInSection
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cellIdentifier = self.cellIdentifier

        if let value = self.delegate?.dataSource?(self, cellIdentifierFor: indexPath) {
            cellIdentifier = value
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        self.configure(cell, indexPath: indexPath)

        return cell
    }

    // Sections and Headers

    #if os(iOS)

        public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            if let titles = self.delegate?.sectionIndexTitlesForDataSource?(self, tableView: tableView) {
                return titles
            } else if let keyPath = self.fetchedResultsController.sectionNameKeyPath {
                let request = NSFetchRequest<NSFetchRequestResult>()
                request.entity = self.fetchedResultsController.fetchRequest.entity
                request.resultType = .dictionaryResultType
                request.returnsDistinctResults = true
                request.propertiesToFetch = [keyPath]
                request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: true)]
                var names = [String]()
                var objects: [NSDictionary]?

                do {
                    objects = try self.fetchedResultsController.managedObjectContext.fetch(request) as? [NSDictionary]
                } catch {
                    print("Error")
                }

                if let objects = objects {
                    for object in objects {
                        names.append(contentsOf: object.allValues as! [String])
                    }
                }

                return names
            }

            return nil
        }

        public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
            return self.delegate?.dataSource?(self, tableView: tableView, sectionForSectionIndexTitle: title, atIndex: index) ?? index
        }
    #endif

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var resultTitle: String?

        if self.delegate?.responds(to: #selector(DATASourceDelegate.dataSource(_:tableView:titleForHeaderInSection:))) == true {
            resultTitle = self.delegate?.dataSource?(self, tableView: tableView, titleForHeaderInSection: section)
        } else if let sections = self.fetchedResultsController.sections {
            resultTitle = sections[section].name
        }

        return resultTitle
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.delegate?.dataSource?(self, tableView: tableView, titleForFooterInSection: section)
    }

    // Editing

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canEditRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }

    // Moving or Reordering

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canMoveRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
