import UIKit
import CoreData

extension DATASource: NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let tableView = self.tableView {
            tableView.beginUpdates()
        } else if let _ = self.collectionView {
            self.sectionChanges = [NSFetchedResultsChangeType: IndexSet]()
            self.objectChanges = [NSFetchedResultsChangeType: Set<IndexPath>]()
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        self.cachedSectionNames.removeAll()

        if let tableView = self.tableView {
            let rowAnimationType = self.animations?[type] ?? .automatic
            switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: rowAnimationType)
                break
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: rowAnimationType)
                break
            case .move, .update:
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: rowAnimationType)
                break
            }
        } else if let _ = self.collectionView {
            switch type {
            case .insert, .delete:
                if var indexSet = self.sectionChanges[type] {
                    indexSet.insert(sectionIndex)
                    self.sectionChanges[type] = indexSet
                } else {
                    self.sectionChanges[type] = IndexSet(integer: sectionIndex)
                }
                break
            case .move, .update:
                break
            }
        }
    }

    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if let tableView = self.tableView {
            let rowAnimationType = self.animations?[type] ?? .automatic
            switch type {
            case .insert:
                if let newIndexPath = newIndexPath, let anObject = anObject as? NSManagedObject {
                    tableView.insertRows(at: [newIndexPath], with: rowAnimationType)
                    self.delegate?.dataSource?(self, didInsertObject: anObject, atIndexPath: newIndexPath)
                }
                break
            case .delete:
                if let indexPath = indexPath, let anObject = anObject as? NSManagedObject {
                    tableView.deleteRows(at: [indexPath], with: rowAnimationType)
                    self.delegate?.dataSource?(self, didDeleteObject: anObject, atIndexPath: indexPath)
                }
                break
            case .update:
                if let newIndexPath = newIndexPath {
                    if tableView.indexPathsForVisibleRows?.index(of: newIndexPath) != nil {
                        if let cell = tableView.cellForRow(at: newIndexPath) {
                            self.configure(cell, indexPath: newIndexPath)
                        }

                        if let anObject = anObject as? NSManagedObject {
                            self.delegate?.dataSource?(self, didUpdateObject: anObject, atIndexPath: newIndexPath)
                        }
                    }
                }
                break
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    tableView.deleteRows(at: [indexPath], with: rowAnimationType)
                    tableView.insertRows(at: [newIndexPath], with: rowAnimationType)

                    if let anObject = anObject as? NSManagedObject {
                        self.delegate?.dataSource?(self, didMoveObject: anObject, fromIndexPath: indexPath, toIndexPath: newIndexPath)
                    }
                }
                break
            }
        } else if let _ = self.collectionView {
            var changeSet = self.objectChanges[type] ?? Set<IndexPath>()

            switch type {
            case .insert:
                if let newIndexPath = newIndexPath {
                    changeSet.insert(newIndexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .delete, .update:
                if let indexPath = indexPath {
                    changeSet.insert(indexPath)
                    self.objectChanges[type] = changeSet
                }
                break
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    // Workaround: Updating a UICollectionView element sometimes will trigger a .Move change
                    // where both indexPaths are the same, as a workaround if this happens, DATASource
                    // will treat this change as an .Update
                    if indexPath == newIndexPath {
                        changeSet.insert(indexPath)
                        self.objectChanges[.update] = changeSet
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

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let tableView = self.tableView {
            tableView.endUpdates()
        } else if let _ = self.collectionView {
            if let moves = self.objectChanges[.move] {
                if moves.count > 0 {
                    var updatedMoves = Set<IndexPath>()
                    if let insertSections = self.sectionChanges[.insert], let deleteSections = self.sectionChanges[.delete] {
                        var generator = moves.makeIterator()
                        guard let fromIndexPath = generator.next() else { fatalError("fromIndexPath not found. Moves: \(moves), inserted sections: \(insertSections), deleted sections: \(deleteSections)") }
                        guard let toIndexPath = generator.next() else { fatalError("toIndexPath not found. Moves: \(moves), inserted sections: \(insertSections), deleted sections: \(deleteSections)") }

                        if deleteSections.contains((fromIndexPath as NSIndexPath).section) {
                            if insertSections.contains((toIndexPath as NSIndexPath).section) == false {
                                if var changeSet = self.objectChanges[.insert] {
                                    changeSet.insert(toIndexPath)
                                    self.objectChanges[.insert] = changeSet
                                } else {
                                    self.objectChanges[.insert] = [toIndexPath]
                                }
                            }
                        } else if insertSections.contains((toIndexPath as NSIndexPath).section) {
                            if var changeSet = self.objectChanges[.delete] {
                                changeSet.insert(fromIndexPath)
                                self.objectChanges[.delete] = changeSet
                            } else {
                                self.objectChanges[.delete] = [fromIndexPath]
                            }
                        } else {
                            for move in moves {
                                updatedMoves.insert(move as IndexPath)
                            }
                        }
                    }

                    if updatedMoves.count > 0 {
                        self.objectChanges[.move] = updatedMoves
                    } else {
                        self.objectChanges.removeValue(forKey: .move)
                    }
                }
            }

            if let collectionView = self.collectionView {
                collectionView.performBatchUpdates({
                    if let deletedSections = self.sectionChanges[.delete] {
                        collectionView.deleteSections(deletedSections as IndexSet)
                    }

                    if let insertedSections = self.sectionChanges[.insert] {
                        collectionView.insertSections(insertedSections as IndexSet)
                    }

                    if let deleteItems = self.objectChanges[.delete] {
                        collectionView.deleteItems(at: Array(deleteItems))
                    }

                    if let insertedItems = self.objectChanges[.insert] {
                        collectionView.insertItems(at: Array(insertedItems))
                    }

                    if let reloadItems = self.objectChanges[.update] {
                        collectionView.reloadItems(at: Array(reloadItems))
                    }

                    if let moveItems = self.objectChanges[.move] {
                        var generator = moveItems.makeIterator()
                        guard let fromIndexPath = generator.next() else { fatalError("fromIndexPath not found. Move items: \(moveItems)") }
                        guard let toIndexPath = generator.next() else { fatalError("toIndexPath not found. Move items: \(moveItems)") }
                        collectionView.moveItem(at: fromIndexPath as IndexPath, to: toIndexPath as IndexPath)
                    }

                }, completion: nil)
            }
        }
        self.delegate?.dataSourceDidChangeContent?(self)
    }
}
