import UIKit
import CoreData

extension DATASource: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
            self.sectionChanges = [NSFetchedResultsChangeType : NSMutableIndexSet]()
            self.objectChanges = [NSFetchedResultsChangeType : [NSIndexPath]]()
        }
    }

    public func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        self.cachedSectionNames.removeAll()

        if let tableView = self.tableView {
            switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
                break
            case .Move, .Update:
                tableView.reloadSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
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
            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath, anObject = anObject as? NSManagedObject {
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
                    self.delegate?.dataSource?(self, didInsertObject: anObject, atIndexPath: newIndexPath)
                }
                break
            case .Delete:
                if let indexPath = indexPath, anObject = anObject as? NSManagedObject {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    self.delegate?.dataSource?(self, didDeleteObject: anObject, atIndexPath: indexPath)
                }
                break
            case .Update:
                if let indexPath = indexPath {
                    if tableView.indexPathsForVisibleRows?.indexOf(indexPath) != nil {
                        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                            self.configureCell(cell, indexPath: indexPath)
                        }

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didUpdateObject: anObject, atIndexPath: indexPath)
                        }
                    }
                }
                break
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)

                    if let oldCell = tableView.cellForRowAtIndexPath(indexPath), newCell = tableView.cellForRowAtIndexPath(newIndexPath) {
                        self.configureCell(oldCell, indexPath: indexPath)
                        self.configureCell(newCell, indexPath: newIndexPath)

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didMoveObject: anObject, fromIndexPath: indexPath, toIndexPath: newIndexPath)
                        }
                    }
                }
                break
            }
        } else if let _ = self.collectionView {
            var changeSet = self.objectChanges[type] ?? [NSIndexPath]()

            switch type {
            case .Insert:
                if let newIndexPath = newIndexPath {
                    changeSet.append(newIndexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .Delete, .Update:
                if let indexPath = indexPath {
                    changeSet.append(indexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .Move:
                if let indexPath = indexPath, newIndexPath = newIndexPath {
                    // Workaround: Updating a UICollectionView element sometimes will trigger a .Move change
                    // where both indexPaths are the same, as a workaround if this happens, DATASource
                    // will treat this change as an .Update
                    if indexPath == newIndexPath {
                        changeSet.append(indexPath)
                        self.objectChanges[.Update] = changeSet
                    } else {
                        changeSet.append(indexPath)
                        changeSet.append(newIndexPath)
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
                    var updatedMoves = [NSIndexPath]()
                    if let insertSections = self.sectionChanges[.Insert], deleteSections = self.sectionChanges[.Delete] {
                        let fromIndexPath = moves[0]
                        let toIndexPath = moves[1]

                        if deleteSections.containsIndex(fromIndexPath.section) {
                            if insertSections.containsIndex(toIndexPath.section) == false {
                                if var changeSet = self.objectChanges[.Insert] {
                                    changeSet.append(toIndexPath)
                                    self.objectChanges[.Insert] = changeSet
                                } else {
                                    self.objectChanges[.Insert] = [toIndexPath]
                                }
                            }
                        } else if insertSections.containsIndex(toIndexPath.section) {
                            if var changeSet = self.objectChanges[.Delete] {
                                changeSet.append(fromIndexPath)
                                self.objectChanges[.Delete] = changeSet
                            } else {
                                self.objectChanges[.Delete] = [fromIndexPath]
                            }
                        } else {
                            updatedMoves.appendContentsOf(moves)
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
                        collectionView.deleteItemsAtIndexPaths(deleteItems)
                    }

                    if let insertedItems = self.objectChanges[.Insert] {
                        collectionView.insertItemsAtIndexPaths(insertedItems)
                    }

                    if let reloadItems = self.objectChanges[.Update] {
                        collectionView.reloadItemsAtIndexPaths(reloadItems)
                    }

                    if let moveItems = self.objectChanges[.Move] {
                        collectionView.moveItemAtIndexPath(moveItems[0], toIndexPath: moveItems[1])
                    }

                    }, completion: nil)
            }
        }
        self.delegate?.dataSourceDidChangeContent?(self)
    }
}
