import SwiftUI
import CoreData

struct ContentView: View {
    @State private var showingPreferences = false
    
    var body: some View {
        NavigationView {
            ChannelsListView()
                .navigationTitle("Tivu")
                .toolbar {
                    Button {
                        showingPreferences.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                    }
                }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showingPreferences) {
            SettingsView()
        }
        .onAppear {
            if Settings.shared.server == nil {
                showingPreferences = true
            }
        }
    }
}
