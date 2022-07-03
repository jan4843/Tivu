import CoreData

extension CachedChannel {
    class public func fetchRequest(sorted: Bool) -> NSFetchRequest<CachedChannel> {
        let request: NSFetchRequest<CachedChannel> = CachedChannel.fetchRequest()
        request.sortDescriptors = []
        if sorted {
            request.sortDescriptors = [
                NSSortDescriptor(
                    key: #keyPath(CachedChannel.number),
                    ascending: true,
                    selector: #selector(NSString.localizedStandardCompare(_:))
                )
            ]
        }
        return request
    }
}
