import SwiftUI
import CoreData

struct ChannelView: View {
    let channel: Channel
    
    @StateObject private var viewModel: ViewModel
    
    @ScaledMetric private var logoSize: CGFloat = 32
    @State private var updateTimer: Timer?
    @State private var showingPlayer = false
    
    init(channel: Channel) {
        self.channel = channel
        self._viewModel = StateObject(wrappedValue: ViewModel(channel: channel))
    }
    
    var body: some View {
        VStack {
            HStack {
                CachedImage(
                    url: channel.logoURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    },
                    placeholder: {
                        Text(channel.number?.description ?? channel.name)
                            .lineLimit(1)
                            .font(.caption.monospaced().bold())
                            .foregroundColor(.secondary)
                            .minimumScaleFactor(0.01)
                    }
                )
                .frame(width: logoSize, height: logoSize)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
                
                VStack(alignment: .leading) {
                    Text(channel.name)
                        .font(.headline)
                    
                    if let number = channel.number {
                        Text("Channel \(number.description)")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button {
                    showingPlayer.toggle()
                } label: {
                    Label("Play", systemImage: "play")
                        .symbolVariant(.fill)
                        .labelStyle(.iconOnly)
                }
                .fullScreenCover(isPresented: $showingPlayer) {
                    if let streamURL = viewModel.streamURL {
                        PlayerView(channel: channel, streamURL: streamURL)
                    }
                }
            }
            .padding(.horizontal)
            
            if !viewModel.hideSchedule {
                Group {
                    if viewModel.programs.isEmpty {
                        Text("No program schedule available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(viewModel.programs, id: \.interval.start) { program in
                                    ProgramCard(program: program)
                                }
                            }
                            .padding()
                        }
                    }
                }
                .padding(.top, -8)
            }
        }
        .animation(.default, value: viewModel.programs)
        .onAppear {
            viewModel.fetchPrograms()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { timer in
                viewModel.fetchPrograms()
            }
        }
        .onDisappear {
            updateTimer?.invalidate()
        }
    }
}
