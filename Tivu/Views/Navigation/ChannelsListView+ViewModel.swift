import CoreData

extension ChannelsListView {
    @MainActor class ViewModel: NSObject, ObservableObject {
        @Published private(set) var channels = MappedFetchResults<Channel>()
        
        private let controller: NSFetchedResultsController<CachedChannel>
        
        init(context: NSManagedObjectContext = CacheManager.shared.viewContext) {
            self.controller = NSFetchedResultsController(
                fetchRequest: CachedChannel.fetchRequest(sorted: true),
                managedObjectContext: context,
                sectionNameKeyPath: nil, cacheName: nil
            )
            super.init()
            controller.delegate = self
        }
        
        func fetchChannels() {
            try? controller.performFetch()
            controllerDidChangeContent(controller as! NSFetchedResultsController<NSFetchRequestResult>)
        }
    }
}

extension ChannelsListView.ViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let results = (controller.fetchedObjects as NSArray?) ?? NSArray()
        self.channels = MappedFetchResults(results)
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        objectWillChange.send()
    }
}
