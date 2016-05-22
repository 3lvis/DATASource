//
//  User+CoreDataProperties.swift
//  Demo
//
//  Created by Dmitry Zarva on 16/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var count: NSNumber
    @NSManaged var createdDate: NSDate?
    @NSManaged var name: String?

}
