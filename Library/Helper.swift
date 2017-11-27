import Foundation
import DATAStack

public class Helper: NSObject {
    @objc public class func addNewUser(dataStack: DATAStack) {
        dataStack.performInNewBackgroundContext { backgroundContext in
            if let entity = NSEntityDescription.entity(forEntityName: "User", in: backgroundContext) {
                let user = NSManagedObject(entity: entity, insertInto: backgroundContext)

                let name = self.randomString()
                let firstLetter = String(name[name.startIndex])
                user.setValue(name, forKey: "name")
                user.setValue(firstLetter.uppercased(), forKey: "firstLetterOfName")
                user.setValue(Helper.isManager() ? "manager" : "employee", forKey: "role")
                do {
                    try backgroundContext.save()
                } catch let savingError as NSError {
                    print("Could not save \(savingError)")
                } catch {
                    fatalError()
                }
            } else {
                print("Oh no")
            }
        }
    }

    class func randomString() -> String {
        let letters = "ABCDEFGHIJKL"
        var string = ""
        for _ in 0 ... 5 {
            let token = UInt32(letters.count)
            let letterIndex = Int(arc4random_uniform(token))
            let firstChar = Array(letters)[letterIndex]
            string.append(firstChar)
        }

        return string
    }

    class func isManager() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
