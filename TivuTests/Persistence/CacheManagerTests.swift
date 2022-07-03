import XCTest
import CoreData
@testable import Tivu

class CacheManagerTests: XCTestCase {
    func testRefreshSave() async throws {
        let cacheManager = CacheManager(inMemory: true)
        try await cacheManager.refresh { context in
            for _ in 1...3 {
                self.randomEntity(context: context)
            }
        }
        
        XCTAssertEqual(storedEntities(cacheManager: cacheManager).count, 3)
    }
    
    func testRefreshClear() async throws {
        let cacheManager = CacheManager(inMemory: true)
        try await cacheManager.refresh { context in
            for _ in 1...7 {
                self.randomEntity(context: context)
            }
        }
        try await cacheManager.refresh { context in
            for _ in 1...4 {
                self.randomEntity(context: context)
            }
        }

        XCTAssertEqual(storedEntities(cacheManager: cacheManager).count, 4)
    }

    func testInplaceUpdate() async throws {
        var firstChannel: CachedChannel {
            return storedEntities(cacheManager: cacheManager).first! as! CachedChannel
        }

        let cacheManager = CacheManager(inMemory: true)

        try await cacheManager.refresh { context in
            let channel = CachedChannel(context: context)
            channel.id = "bd7dc4dde067f0bf01343a7998653cb2"
            channel.name = "original"
            channel.number = "10.0"
        }
        let objectID1 = firstChannel.objectID.uriRepresentation()

        try await cacheManager.refresh { context in
            let channel = CachedChannel(context: context)
            channel.id = "bd7dc4dde067f0bf01343a7998653cb2"
            channel.name = "updated"
            channel.number = nil
        }
        let objectID2 = firstChannel.objectID.uriRepresentation()

        XCTAssertEqual(storedEntities(cacheManager: cacheManager).count, 1)
        XCTAssertEqual(objectID1, objectID2)
    }

    func testRollback() async throws {
        let cacheManager = CacheManager(inMemory: true)

        try await cacheManager.refresh { context in
            for _ in 1...4 {
                self.randomEntity(context: context)
            }
            context.rollback()
            self.randomEntity(context: context)
        }

        XCTAssertEqual(storedEntities(cacheManager: cacheManager).count, 1)
    }
    
    // MARK: - Helpers
    
    func storedEntities(cacheManager: CacheManager) -> [CachedEntity] {
        cacheManager.container.viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<CachedEntity>(entityName: CachedEntity.entity().name!)
            let result = try! cacheManager.container.viewContext.fetch(fetchRequest)
            return result
        }
    }

    func randomEntity(context: NSManagedObjectContext) {
        let channel = CachedChannel(context: context)
        channel.id = UUID().uuidString
        channel.name = UUID().uuidString
    }
}
