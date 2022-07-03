extension URL {
    func appendingPathComponents(_ pathComponents: [String]) -> URL {
        var url = self
        for pathComponent in pathComponents {
            url = url.appendingPathComponent(pathComponent)
        }
        return url
    }
}
