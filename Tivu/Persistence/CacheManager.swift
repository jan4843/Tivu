import CoreData

class CacheManager {
    static let shared = CacheManager()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tivu")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func refresh(fill: @escaping (_ context: NSManagedObjectContext) throws -> Void) async throws {
        try await container.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            try self.markAllExistingEntitiesAsStale(context: context)
            try fill(context)
            try context.save()
            
            let changes = try self.deleteAllStaleEntities(context: context)
            try context.save()
            
            /*
             Objects deleted via NSBatchDeleteRequest have not triggered any
             notifications because changes occurred directly in the persistent
             store, not from within a NSManagedObjectContext.
             Therefore, the viewContext should be notified about those manually.
             */
            self.container.viewContext.merge(changes: changes)
        }
    }
    
    private func markAllExistingEntitiesAsStale(context: NSManagedObjectContext) throws {
        let updateRequest = NSBatchUpdateRequest(entity: CachedEntity.entity())
        updateRequest.propertiesToUpdate = [#keyPath(CachedEntity.stale): true]
        
        updateRequest.resultType = .updatedObjectIDsResultType
        guard let result = try context.execute(updateRequest) as? NSBatchUpdateResult,
              let objectIDs = result.result as? [NSManagedObjectID] else { return }
        context.merge(changes: [NSUpdatedObjectIDsKey: objectIDs])
    }
    
    private func deleteAllStaleEntities(context: NSManagedObjectContext) throws -> [String: [NSManagedObjectID]] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == true", #keyPath(CachedEntity.stale))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        deleteRequest.resultType = .resultTypeObjectIDs
        guard let result = try context.execute(deleteRequest) as? NSBatchDeleteResult,
              let objectIDs = result.result as? [NSManagedObjectID] else { return [:] }
        return [NSDeletedObjectsKey: objectIDs]
    }
}
