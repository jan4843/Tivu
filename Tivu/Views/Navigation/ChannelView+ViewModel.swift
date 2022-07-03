import CoreData
import Combine

extension ChannelView {
    @MainActor class ViewModel: NSObject, ObservableObject {
        let channel: Channel
        
        @Published private(set) var programs = MappedFetchResults<Program>()
        @Published private(set) var hideSchedule: Bool
        
        private let controller: NSFetchedResultsController<CachedProgram>
        private let settings: Settings
        private var settingsChangedSink: AnyCancellable?
        
        init(
            channel: Channel,
            context: NSManagedObjectContext = CacheManager.shared.viewContext,
            settings: Settings = Settings.shared
        ) {
            self.channel = channel
            self.controller = NSFetchedResultsController(
                fetchRequest: Self.fetchRequest(channel: channel),
                managedObjectContext: context,
                sectionNameKeyPath: nil, cacheName: nil
            )
            self.settings = settings
            self.hideSchedule = settings.hideSchedule
            super.init()
            
            settingsChangedSink = settings.objectWillChange.sink {
                Task {
                    await MainActor.run {
                        self.hideSchedule = settings.hideSchedule
                    }
                }
            }
            controller.delegate = self
            fetchPrograms()
        }
        
        var streamURL: URL? {
            settings.server?.streamURL(for: channel)
        }
        
        func fetchPrograms() {
            controller.fetchRequest.predicate = Self.fetchRequest(channel: self.channel).predicate
            Task.detached(priority: .background) {
                try? self.controller.performFetch()
                await self.reloadPrograms()
            }
        }
        
        @MainActor private func reloadPrograms() async {
            let results = (controller.fetchedObjects as NSArray?) ?? NSArray()
            self.programs = MappedFetchResults<Program>(results)
        }
        
        private class func fetchRequest(channel: Channel) -> NSFetchRequest<CachedProgram> {
            CachedProgram.fetchRequest(
                channel: channel,
                interval: DateInterval(start: Date.now, duration: 1 * day)
            )
        }
    }
}

extension ChannelView.ViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        Task {
            await self.reloadPrograms()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}

fileprivate let day: TimeInterval = 60 * 60 * 24
