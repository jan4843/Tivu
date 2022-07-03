import SwiftUI

struct NowPlayingPill: View {
    @StateObject var viewModel: ViewModel
    
    @State private var progress = 0.0
    @State private var updateTimer: Timer?
    @ScaledMetric private var programImageWidth = 125
    @ScaledMetric private var programImageHeight = 78
    
    init(channel: Channel) {
        self._viewModel = StateObject(wrappedValue: ViewModel(channel: channel))
    }
    
    var body: some View {
        Group {
            if let program = viewModel.currentProgram {
                VStack(spacing: 0) {
                    HStack(alignment: .center) {
                        CachedImage(
                            url: program.imageURL,
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: programImageWidth, height: programImageHeight)
                                    .clipped()
                            },
                            placeholder: {
                                Rectangle()
                                    .frame(width: 0, height: 0)
                                    .padding(.trailing, 8)
                            }
                        )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            if let title = program.title {
                                Text(title)
                                    .foregroundColor(.white)
                                    .bold()
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            if let subtitle = program.formattedSubtitle {
                                Text(subtitle)
                                    .foregroundColor(.white)
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Text(program.formattedInterval)
                                .foregroundColor(.gray)
                                .font(.caption.monospacedDigit().bold())
                        }
                        .padding(.vertical, 8)
                        
                        Spacer()
                        
                        if let program = viewModel.upcomingProgram,
                           let title = program.title {
                            VStack(alignment: .trailing) {
                                Text(title)
                                    .lineLimit(2)
                                    .truncationMode(.middle)
                                    .multilineTextAlignment(.trailing)
                                    .font(.caption.leading(.tight))
                                Text("in \(program.interval.start.formattedTimeLeft)")
                                    .foregroundColor(.gray)
                                    .font(.caption.bold().monospacedDigit())
                            }
                            .padding(8)
                        }
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .foregroundColor(progress == 0 ? .clear : .gray)
                        Rectangle()
                            .foregroundColor(.white)
                            .scaleEffect(x: progress, y: 1, anchor: .leading)
                    }
                    .frame(height: 3)
                    .opacity(0.5)
                }
                .background(.thinMaterial)
                .cornerRadius(16)
                .shadow(radius: 8)
            }
        }
        .onAppear {
            update()
            updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                update()
            }
        }
        .onDisappear {
            updateTimer?.invalidate()
        }
    }
    
    private func update() {
        progress = viewModel.currentProgram?.interval.currentProgress ?? 0
        viewModel.updatePrograms()
    }
}
