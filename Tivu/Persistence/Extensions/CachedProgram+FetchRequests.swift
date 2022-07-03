import CoreData

extension CachedProgram {
    class func fetchRequest(channel: Channel, interval: DateInterval) -> NSFetchRequest<CachedProgram> {
        let request: NSFetchRequest<CachedProgram> = CachedProgram.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K >= %@ AND %K < %@",
            #keyPath(CachedProgram.channelID), channel.id,
            #keyPath(CachedProgram.endTime), interval.start as NSDate,
            #keyPath(CachedProgram.startTime), interval.end as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CachedProgram.startTime), ascending: true)
        ]
        return request
    }
    
    class func fetchRequest(channel: Channel, endingBefore: Date, limit: Int) -> NSFetchRequest<CachedProgram> {
        let request: NSFetchRequest<CachedProgram> = CachedProgram.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K > %@",
            #keyPath(CachedProgram.channelID), channel.id,
            #keyPath(CachedProgram.endTime), endingBefore as NSDate
        )
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CachedProgram.startTime), ascending: true)
        ]
        request.fetchLimit = limit
        return request
    }
}
