//
//  User.swift
//  Demo
//
//  Created by Dmitry Zarva on 16/05/16.
//
//

import Foundation
import CoreData


class User: NSManagedObject {

    var firstLetterOfName: String? {
        return String(Array(self.name!.characters)[0])
    }

}
