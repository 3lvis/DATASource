import Foundation
import CoreData

extension User {
    @NSManaged var count: NSNumber
    @NSManaged var createdDate: NSDate?
    @NSManaged var name: String?

}
