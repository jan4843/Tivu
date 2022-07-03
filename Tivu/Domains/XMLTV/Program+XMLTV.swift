import Foundation

extension Program.Number {
    internal init?(xmltvString: String) {
        let components = xmltvString
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ".")
        guard components.count > 1 else { return nil }
        
        self.init(
            season: Self.parseComponent(components[0]),
            episode: Self.parseComponent(components[1])
        )
    }
    
    fileprivate static func parseComponent(_ xmltvComponent: String) -> Int? {
        let value = xmltvComponent
            .components(separatedBy: "/")
            .first ?? ""
        guard let value = Int(value) else { return nil }
        return value + 1
    }
}
