import SwiftUI

struct CachedImage<I: View, P: View>: View {
    let url: URL?
    @ViewBuilder var content: (Image) -> I
    @ViewBuilder var placeholder: P
    
    @Environment(\.imagesURLCache) private var urlCache
    @State private var image: Image?
    
    var body: some View {
        if let image = image {
            content(image)
        } else {
            placeholder
                .onAppear {
                    loadImage()
                }
        }
    }
    
    func loadImage() {
        Task.detached(priority: .background) {
            guard let url = url else { return }
            
            let session = URLSession(configuration: .ephemeral)
            session.configuration.urlCache = urlCache
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            guard let (data, _) = try? await session.data(for: request),
                  let uiImage = UIImage(data: data) else { return }
            
            let image = Image(uiImage: uiImage)
            await MainActor.run {
                self.image = image
            }
        }
    }
}

fileprivate struct ImagesURLCacheKey: EnvironmentKey {
    static let defaultValue = URLCache.shared
}

extension EnvironmentValues {
    var imagesURLCache: URLCache {
        get { self[ImagesURLCacheKey.self] }
        set { self[ImagesURLCacheKey.self] = newValue }
    }
}
