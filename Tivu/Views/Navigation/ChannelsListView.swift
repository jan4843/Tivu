import SwiftUI

struct ChannelsListView: View {
    @StateObject private var viewModel: ViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: ViewModel())
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(viewModel.channels, id: \.id) { channel in
                    ChannelView(channel: channel)
                    
                    Divider()
                        .padding(.leading)
                }
            }
        }
        .animation(.default, value: viewModel.channels)
        .onAppear {
            withAnimation(.none) {
                viewModel.fetchChannels()
            }
        }
    }
}
