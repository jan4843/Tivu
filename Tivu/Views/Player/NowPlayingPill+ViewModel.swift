import CoreData

extension NowPlayingPill {
    @MainActor class ViewModel: ObservableObject {
        @Published private(set) var currentProgram: Program?
        @Published private(set) var upcomingProgram: Program?
        
        private let channel: Channel
        private let context: NSManagedObjectContext
        
        init(
            channel: Channel,
            context: NSManagedObjectContext = CacheManager.shared.viewContext
        ) {
            self.channel = channel
            self.context = context
            updatePrograms()
        }
        
        func updatePrograms() {
            guard let results = try? context.fetch(fetchRequest) else { return }
            
            if results.count > 0 {
                currentProgram = Program(result: results[0])
                if results.count > 1 {
                    upcomingProgram = Program(result: results[1])
                } else {
                    upcomingProgram = nil
                }
                return
            }
            currentProgram = nil
            upcomingProgram = nil
        }
        
        private var fetchRequest: NSFetchRequest<CachedProgram> {
            CachedProgram.fetchRequest(
                channel: channel,
                endingBefore: Date.now,
                limit: 2
            )
        }
    }
}
