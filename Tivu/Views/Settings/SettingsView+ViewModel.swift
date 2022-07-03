extension SettingsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var url = ""
        @Published var username = ""
        @Published var password = ""
        @Published var hideSchedule = false
        
        @Published private(set) var showOnlySetupSettings = true
        @Published private(set) var loading = false
        @Published private(set) var triggerDismiss = false
        @Published private(set) var error: Error? {
            didSet {
                displayError = error != nil
            }
        }
        @Published var displayError = false
        
        private let dataManager: DataManager
        private let settings: Settings
        
        init(
            dataManager: DataManager = DataManager.shared,
            settings: Settings = Settings.shared
        ) {
            self.dataManager = dataManager
            self.settings = settings
            
            let serverURL = settings.server?.url
            self.url = serverURL?.removingBasicAuth().absoluteString ?? ""
            self.username = serverURL?.user ?? ""
            self.password = serverURL?.password ?? ""
            self.hideSchedule = settings.hideSchedule
            self.showOnlySetupSettings = serverURL == nil
        }
        
        var canSave: Bool {
            newServer != nil
        }
        
        func save() async {
            guard let server = newServer else { return }
            
            defer { loading = false }
            loading = true
            
            if server != settings.server {
                do {
                    try await dataManager.refresh(withDataFrom: server.xmltvURL)
                } catch {
                    self.error = error
                    return
                }
            }
            
            settings.server = server
            settings.hideSchedule = hideSchedule
            
            triggerDismiss = true
        }
        
        private var newServer: TVHeadendServer? {
            let hasScheme = url.starts(with: "http://") || url.starts(with: "https://")
            let url = hasScheme ? url : "http://\(url)"
            
            guard var urlComponents = URLComponents(string: url),
                  let host = urlComponents.host, !host.isEmpty
            else { return nil }
            
            urlComponents.basicAuth = URL.BasicAuth(user: username, password: password)
            guard let serverURL = urlComponents.url else { return nil }
            return TVHeadendServer(url: serverURL)
        }
    }
}
