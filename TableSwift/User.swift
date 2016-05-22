import Foundation
import CoreData

class User: NSManagedObject {
    var firstLetterOfNameTransient: String? {
        return String(Array(self.name!.characters)[0])
    }
}
