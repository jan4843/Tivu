import CoreData

protocol Persistable {
    func persist(context: NSManagedObjectContext)
}
