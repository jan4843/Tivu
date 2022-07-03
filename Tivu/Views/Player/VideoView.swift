import SwiftUI
import MobileVLCKit

class VideoPlayer: NSObject, ObservableObject {
    @Published var playbackState = PlaybackState.stopped
    
    fileprivate var player: VLCMediaPlayer
    
    var url: URL? {
        get {
            player.media?.url
        }
        set {
            if let url = newValue {
                if player.media?.url != url {
                    player.media = VLCMedia(url: url)
                }
            } else {
                player.media = nil
            }
        }
    }
    
    init(url: URL? = nil) {
        self.player = VLCMediaPlayer()
        super.init()
        
        self.url = url
        self.player.delegate = self
    }
    
    func play() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
}

struct VideoView: UIViewRepresentable {
    let player: VideoPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        player.player.drawable = view
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoView>) {
    }
}

extension VideoPlayer {
    enum PlaybackState: String, CaseIterable {
        case stopped
        case loading
        case playing
        case error
        
        var displayName: String {
            return rawValue.capitalized
        }
    }
}

extension VideoPlayer: VLCMediaPlayerDelegate {
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        switch player.state {
        case .stopped, .ended:
            playbackState = .stopped
        case .opening, .buffering:
            playbackState = .loading
        case .error:
            playbackState = .error
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        let hasProgress = player.time.intValue > 0
        if hasProgress {
            playbackState = .playing
        }
    }
}
