struct Channel {
    struct Number {
        let major: UInt
        let minor: UInt?
        
        init(_ major: UInt, _ minor: UInt? = nil) {
            self.major = major
            self.minor = minor
        }
    }
    
    let id: String
    let name: String
    let number: Number?
    let logoURL: URL?
}

extension Channel: Equatable {
}

extension Channel.Number: Equatable {
}

extension Channel.Number: CustomStringConvertible {
    var description: String {
        if let minor = minor {
            return "\(major).\(minor)"
        }
        return "\(major)"
    }
    
    init?(string: String) {
        let components = string.components(separatedBy: ".")
        switch components.count {
        case 1:
            guard let major = UInt(components[0]) else { return nil }
            self.init(major)
        case 2:
            guard let major = UInt(components[0]),
                  let minor = UInt(components[1]) else { return nil }
            self.init(major, minor)
        default:
            return nil
        }
    }
}
