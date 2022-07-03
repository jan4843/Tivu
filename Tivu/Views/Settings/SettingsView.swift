import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    init() {
        self._viewModel = StateObject(wrappedValue: ViewModel())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    FormField("URL") {
                        TextField("http://10.0.0.1:9981", text: $viewModel.url)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                    
                    FormField("Username") {
                        TextField("admin", text: $viewModel.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                    }
                    
                    FormField("Password") {
                        SecureField("••••••••", text: $viewModel.password)
                            .textContentType(.password)
                    }
                } header: {
                    Text("TVHeadend Server")
                } footer: {
                    Text("Connection and optional authentication details")
                }
                
                if !viewModel.showOnlySetupSettings {
                    Section(header: Text("Display")) {
                        Toggle(isOn: $viewModel.hideSchedule) {
                            Text("Hide programs schedule")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(viewModel.showOnlySetupSettings ? "" : "Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.showOnlySetupSettings)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .navigationTitle(viewModel.showOnlySetupSettings ? "Setup" : "Settings")
        }
        .interactiveDismissDisabled()
        .onChange(of: viewModel.triggerDismiss) { triggerDismiss in
            if triggerDismiss {
                dismiss()
            }
        }
        .overlay {
            if viewModel.loading {
                Rectangle()
                    .background(.clear)
                    .opacity(0.02)
                
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading…")
                }
                .padding()
                .background(.background)
                .cornerRadius(8)
                .shadow(radius: 8)
            }
        }
        .alert("Server Error", isPresented: $viewModel.displayError, actions: {}) {
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
}
