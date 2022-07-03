class Settings: ObservableObject {
    private let userDefaults: UserDefaults
    
    static let shared = Settings(userDefaults: UserDefaults.standard)
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var server: TVHeadendServer? {
        get {
            guard let serverURL = userDefaults.url(forKey: "serverURL") else { return nil }
            return TVHeadendServer(url: serverURL)
        }
        set {
            if newValue != server {
                userDefaults.set(newValue?.url, forKey: "serverURL")
                objectWillChange.send()
            }
        }
    }
    
    var hideSchedule: Bool {
        get {
            userDefaults.bool(forKey: "hideSchedule")
        }
        set {
            if newValue != hideSchedule {
                userDefaults.set(newValue, forKey: "hideSchedule")
                objectWillChange.send()
            }
        }
    }
    
    var lastSync: Date {
        get {
            let timestamp = userDefaults.integer(forKey: "lastSync")
            guard timestamp > 0 else { return Date.distantPast }
            return Date(timeIntervalSince1970: TimeInterval(timestamp))
        }
        set {
            if newValue != lastSync {
                userDefaults.set(Int(newValue.timeIntervalSince1970), forKey: "lastSync")
                objectWillChange.send()
            }
        }
    }
}
