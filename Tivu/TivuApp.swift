import SwiftUI

@main
struct TivuApp: App {
    private var imagesURLCache = URLCache(
        memoryCapacity: 128 * mb,
        diskCapacity: 256 * mb,
        directory: URL(string: "images")
    )
    private let dataManager = DataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.imagesURLCache, imagesURLCache)
                .task {
                    try? await dataManager.refresh()
                    Timer.scheduledTimer(withTimeInterval: 5 * minute, repeats: true) { timer in
                        Task {
                            try? await dataManager.refreshIfNeeded()
                        }
                    }
                }
        }
    }
}

fileprivate let mb = 1024 * 1024
fileprivate let minute = 60.0
