import UIKit
import CoreData

extension DATASource: UITableViewDataSource {
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0

        if let sections = self.fetchedResultsController.sections {
            numberOfRowsInSection = sections[section].numberOfObjects
        }

        return numberOfRowsInSection
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath)

        self.configure(cell: cell, indexPath: indexPath)

        return cell
    }

    // Sections and Headers

    public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if let titles = self.delegate?.sectionIndexTitlesForDataSource?(self, tableView: tableView) {
            return titles
        } else if let keyPath = self.fetchedResultsController.sectionNameKeyPath {
            let request = NSFetchRequest()
            request.entity = self.fetchedResultsController.fetchRequest.entity
            request.resultType = .DictionaryResultType
            request.returnsDistinctResults = true
            request.propertiesToFetch = [keyPath]
            request.sortDescriptors = [NSSortDescriptor(key: keyPath, ascending: true)]
            var names = [String]()
            var objects: [NSDictionary]?

            do {
                objects = try self.fetchedResultsController.managedObjectContext.executeFetchRequest(request) as? [NSDictionary]
            } catch {
                print("Error")
            }

            if let objects = objects {
                for object in objects {
                    names.appendContentsOf(object.allValues as! [String])
                }
            }

            return names
        }

        return nil
    }

    public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.delegate?.dataSource?(self, tableView: tableView, sectionForSectionIndexTitle: title, atIndex: index) ?? index
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var resultTitle: String?

        if self.delegate?.respondsToSelector(#selector(DATASourceDelegate.dataSource(_:tableView:titleForHeaderInSection:))) == true {
            resultTitle = self.delegate?.dataSource?(self, tableView: tableView, titleForHeaderInSection: section)
        } else if let sections = self.fetchedResultsController.sections {
            resultTitle = sections[section].name
        }

        return resultTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.delegate?.dataSource?(self, tableView: tableView, titleForFooterInSection: section)
    }

    // Editing

    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canEditRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }

    // Moving or Reordering

    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.delegate?.dataSource?(self, tableView: tableView, canMoveRowAtIndexPath: indexPath) ?? false
    }

    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        self.delegate?.dataSource?(self, tableView: tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
}
