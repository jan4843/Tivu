import SwiftUI

struct PlayerView: View {
    let channel: Channel
    let streamURL: URL
    
    @ScaledMetric private var channelImageHeight = 32
    @State private var interfaceVisible = true
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var player = VideoPlayer()
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VideoView(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        interfaceVisible = !interfaceVisible
                    }
                
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Label("Close", systemImage: "xmark")
                                .foregroundColor(.primary)
                                .labelStyle(.iconOnly)
                                .font(.body.bold())
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                        
                        Spacer()
                        
                        CachedImage(
                            url: channel.logoURL,
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: channelImageHeight)
                            },
                            placeholder: {
                                Text(channel.name)
                                    .font(.caption)
                                    .padding(8)
                            }
                        )
                        .padding(8)
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .shadow(radius: 8)
                    }
                    
                    Spacer()
                    
                    NowPlayingPill(channel: channel)
                }
                .frame(maxWidth: geo.size.height * 16/9)
                .padding(8)
                .opacity(interfaceVisible ? 1 : 0)
                
                switch player.playbackState {
                case .loading:
                    ProgressView()
                        .scaleEffect(2)
                case .stopped, .error:
                    Text("Playback Error")
                        .font(.headline.bold())
                        .foregroundColor(.secondary)
                case .playing:
                    EmptyView()
                }
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: !interfaceVisible)
        .animation(.easeInOut(duration: 0.1), value: interfaceVisible)
        .onAppear {
            player.url = streamURL
            player.play()
        }
    }
}
