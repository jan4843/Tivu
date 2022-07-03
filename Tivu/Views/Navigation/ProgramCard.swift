import SwiftUI

struct ProgramCard: View {
    let program: Program
    
    @State private var progress = 0.0
    @State private var updateTimer: Timer?
    
    @ScaledMetric private var width = 280
    @ScaledMetric private var height = 175
    
    var body: some View {
        ZStack {
            CachedImage(
                url: program.imageURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                },
                placeholder: {
                    Text("")
                }
            )
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    if let title = program.title {
                        Text(title)
                            .foregroundColor(.white)
                            .bold()
                            .truncationMode(.middle)
                            .shadow(radius: 1)
                    }
                    
                    if let subtitle = program.formattedSubtitle {
                        Text(subtitle)
                            .foregroundColor(.white)
                            .font(.footnote)
                            .truncationMode(.middle)
                            .shadow(radius: 1)
                    }
                    
                    Text(program.formattedInterval)
                        .foregroundColor(.gray)
                        .font(.caption.monospacedDigit())
                        .bold()
                        .shadow(radius: 1)
                }
                .padding(.horizontal, 8)
                
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
        }
        .background(.gray)
        .cornerRadius(8)
        .frame(width: width, height: height)
        .shadow(radius: 3)
        .onAppear {
            progress = program.interval.currentProgress
            updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                progress = program.interval.currentProgress
            }
        }
        .onDisappear {
            updateTimer?.invalidate()
        }
    }
}
