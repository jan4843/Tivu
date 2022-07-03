import CoreData

extension NSManagedObjectContext {
    func merge(changes: [AnyHashable: [NSManagedObjectID]]) {
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self])
    }
}
