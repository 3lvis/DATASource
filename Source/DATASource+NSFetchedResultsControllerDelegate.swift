import UIKit
import CoreData

extension DATASource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
            self.sectionChanges = [NSFetchedResultsChangeType : NSMutableIndexSet]()
            self.objectChanges = [NSFetchedResultsChangeType : Set<NSIndexPath>]()
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        self.cachedSectionNames.removeAll()

        if let tableView = self.tableView {
            let rowAnimationType = self.animations?[type] ?? .Automatic
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: rowAnimationType)
                break
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: rowAnimationType)
                break
            case .Move, .Update:
                tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: rowAnimationType)
                break
            }
        } else if let _ = self.collectionView {
            switch type {
            case .Insert, .Delete:
                if let changeSet = self.sectionChanges[type] {
                    changeSet.addIndex(sectionIndex)
                    self.sectionChanges[type] = changeSet
                } else {
                    self.sectionChanges[type] = NSMutableIndexSet(index: sectionIndex)
                }
                break
            case .Move, .Update:
                break
            }
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if let tableView = self.tableView {
            let rowAnimationType = self.animations?[type] ?? .Automatic
            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath, anObject = anObject as? NSManagedObject {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: rowAnimationType)
                    self.delegate?.dataSource?(self, didInsertObject: anObject, atIndexPath: newIndexPath)
                }
                break
            case .Delete:
                if let indexPath = indexPath, anObject = anObject as? NSManagedObject {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimationType)
                    self.delegate?.dataSource?(self, didDeleteObject: anObject, atIndexPath: indexPath)
                }
                break
            case .Update:
                if let indexPath = indexPath {
                    if tableView.indexPathsForVisibleRows?.indexOf(indexPath) != nil {
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                            self.configure(cell: cell, indexPath: indexPath)
                        }

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didUpdateObject: anObject, atIndexPath: indexPath)
                        }
                    }
                }
                break
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: rowAnimationType)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: rowAnimationType)

                    if let anObject = anObject as? NSManagedObject {
                        self.delegate?.dataSource?(self, didMoveObject: anObject, fromIndexPath: indexPath, toIndexPath: newIndexPath)
                    }
                }
                break
            }
        } else if let _ = self.collectionView {
            var changeSet = self.objectChanges[type] ?? Set<NSIndexPath>()

            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath {
                    changeSet.insert(newIndexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .Delete, .Update:
                if let indexPath = indexPath {
                    changeSet.insert(indexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    // Workaround: Updating a UICollectionView element sometimes will trigger a .Move change
                    // where both indexPaths are the same, as a workaround if this happens, DATASource
                    // will treat this change as an .Update
                    if indexPath == newIndexPath {
                        changeSet.insert(indexPath)
                        self.objectChanges[.Update] = changeSet
                    } else {
                        changeSet.insert(indexPath)
                        changeSet.insert(newIndexPath)
                        self.objectChanges[type] = changeSet
                    }
                }
                break
            }
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.endUpdates()
        } else if let _ = self.collectionView {
            if let moves = self.objectChanges[.Move] {
                if moves.count > 0 {
                    var updatedMoves = Set<NSIndexPath>()
                    if let insertSections = self.sectionChanges[.Insert], deleteSections = self.sectionChanges[.Delete] {
                        var generator = moves.generate()
                        guard let fromIndexPath = generator.next() else { fatalError("fromIndexPath not found. Moves: \(moves), inserted sections: \(insertSections), deleted sections: \(deleteSections)") }
                        guard let toIndexPath = generator.next() else { fatalError("toIndexPath not found. Moves: \(moves), inserted sections: \(insertSections), deleted sections: \(deleteSections)") }

                        if deleteSections.containsIndex(fromIndexPath.section) {
                            if insertSections.containsIndex(toIndexPath.section) == false {
                                if var changeSet = self.objectChanges[.Insert] {
                                    changeSet.insert(toIndexPath)
                                    self.objectChanges[.Insert] = changeSet
                                } else {
                                    self.objectChanges[.Insert] = [toIndexPath]
                                }
                            }
                        } else if insertSections.containsIndex(toIndexPath.section) {
                            if var changeSet = self.objectChanges[.Delete] {
                                changeSet.insert(fromIndexPath)
                                self.objectChanges[.Delete] = changeSet
                            } else {
                                self.objectChanges[.Delete] = [fromIndexPath]
                            }
                        } else {
                            for move in moves {
                                updatedMoves.insert(move)
                            }
                        }
                    }

                    if updatedMoves.count > 0 {
                        self.objectChanges[.Move] = updatedMoves
                    } else {
                        self.objectChanges.removeValueForKey(.Move)
                    }
                }
            }

            if let collectionView = self.collectionView {
                collectionView.performBatchUpdates({
                    if let deletedSections = self.sectionChanges[.Delete] {
                        collectionView.deleteSections(deletedSections)
                    }

                    if let insertedSections = self.sectionChanges[.Insert] {
                        collectionView.insertSections(insertedSections)
                    }

                    if let deleteItems = self.objectChanges[.Delete] {
                        collectionView.deleteItemsAtIndexPaths(Array(deleteItems))
                    }

                    if let insertedItems = self.objectChanges[.Insert] {
                        collectionView.insertItemsAtIndexPaths(Array(insertedItems))
                    }

                    if let reloadItems = self.objectChanges[.Update] {
                        collectionView.reloadItemsAtIndexPaths(Array(reloadItems))
                    }

                    if let moveItems = self.objectChanges[.Move] {
                        var generator = moveItems.generate()
                        guard let fromIndexPath = generator.next() else { fatalError("fromIndexPath not found. Move items: \(moveItems)") }
                        guard let toIndexPath = generator.next() else { fatalError("toIndexPath not found. Move items: \(moveItems)") }
                        collectionView.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
                    }

                    }, completion: nil)
            }
        }
        self.delegate?.dataSourceDidChangeContent?(self)
    }
}
