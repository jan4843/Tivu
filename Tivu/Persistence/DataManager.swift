import CoreData

actor DataManager {
    static let shared = DataManager(
        cacheManager: CacheManager.shared,
        settings: Settings.shared
    )
    
    private static let refreshInterval = 15 * minute
    
    private var cacheManager: CacheManager
    private var settings: Settings
    
    init(
        cacheManager: CacheManager,
        settings: Settings
    ) {
        self.cacheManager = cacheManager
        self.settings = settings
    }
    
    func refreshIfNeeded() async throws {
        if !settings.lastSync.withinLast(Self.refreshInterval) {
            try await refresh()
        }
    }
    
    func refresh() async throws {
        guard let server = settings.server else { return }
        try await refresh(withDataFrom: server.xmltvURL)
        settings.lastSync = Date.now
    }
    
    func refresh(withDataFrom url: URL) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        try await cacheManager.refresh { context in
            let parser = XMLTVParser(data: data)
            let delegate = XMLTVCacher(context: context)
            parser.delegate = delegate
            parser.parse()
            if let parseError = delegate.parseError {
                throw parseError
            }
        }
    }
}

fileprivate class XMLTVCacher: XMLTVParserDelegate {
    let context: NSManagedObjectContext
    var parseError: Error?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func parser(_ parser: XMLTVParser, didFindChannel channel: Channel) {
        channel.persist(context: context)
    }
    
    func parser(_ parser: XMLTVParser, didFindProgram program: Program) {
        program.persist(context: context)
    }
    
    func parser(_ parser: XMLTVParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
}

fileprivate let minute = 60.0
