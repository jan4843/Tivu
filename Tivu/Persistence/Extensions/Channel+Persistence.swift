import CoreData

extension Channel: Fetchable {
    init(result: CachedChannel) {
        self.init(
            id: result.id!,
            name: result.name!,
            number: Channel.Number(string: result.number ?? ""),
            logoURL: result.logoURL
        )
    }
}

extension Channel: Persistable {
    func persist(context: NSManagedObjectContext) {
        let managedObject = CachedChannel(context: context)
        managedObject.id = self.id
        managedObject.name = self.name
        managedObject.number = self.number?.description
        managedObject.logoURL = self.logoURL
    }
}
