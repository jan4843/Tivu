import CoreData
import Foundation

extension Program: Fetchable {
    init(result: CachedProgram) {
        self.init(
            interval: DateInterval(start: result.startTime!, end: result.endTime!),
            channelID: result.channelID!,
            title: result.title,
            subtitle: result.subtitle,
            description: result.desc,
            imageURL: result.imageURL,
            number: Program.Number(string: result.number ?? "")
        )
    }
}

extension Program: Persistable {
    func persist(context: NSManagedObjectContext) {
        let managedObject = CachedProgram(context: context)
        managedObject.channelID = self.channelID
        managedObject.desc = self.description
        managedObject.endTime = self.interval.end
        managedObject.id = "\(self.channelID)+\(self.interval.start.timeIntervalSince1970)"
        managedObject.imageURL = self.imageURL
        managedObject.number = self.number?.description
        managedObject.startTime = self.interval.start
        managedObject.subtitle = self.subtitle
        managedObject.title = self.title
    }
}
