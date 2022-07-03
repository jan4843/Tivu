struct TVHeadendServer: Equatable {
    let url: URL
    
    var xmltvURL: URL {
        let url = url.appendingPathComponents(["xmltv", "channels"])
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = urlComponents.queryItems ?? []
        urlComponents.queryItems?.append(URLQueryItem(name: "lcn", value: "1"))
        return urlComponents.url!
    }
    
    func streamURL(for channel: Channel) -> URL {
        url.appendingPathComponents(["stream", "channel", channel.id])
    }
}
