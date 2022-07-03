struct Program {
    struct Number {
        let season: Int?
        let episode: Int?
        
        init?(season: Int? = nil, episode: Int? = nil) {
            if season == nil && episode == nil {
                return nil
            }
            self.season = season
            self.episode = episode
        }
    }
    
    let interval: DateInterval
    let channelID: String
    let title: String?
    let subtitle: String?
    let description: String?
    let imageURL: URL?
    let number: Number?
}

extension Program: Equatable {
}

extension Program.Number: Equatable {
}

extension Program.Number: CustomStringConvertible {
    var description: String {
        var result = ""
        if let season = season {
            result += "S\(season)"
        }
        if let episode = episode {
            if !result.isEmpty {
                result += " " // Thin Space U+2009
            }
            result += "E\(episode)"
        }
        return result
    }
    
    init?(string: String) {
        let regex = try! NSRegularExpression(pattern: #"S(?<season>\d+)\s*E(?<episode>\d+)"#, options: [.caseInsensitive])
        let matches = regex.matches(in: string, range: NSRange(string.startIndex..<string.endIndex, in: string))
        guard let match = matches.first else { return nil }
        
        var season, episode: Int?
        
        let seasonMatchRange = match.range(withName: "season")
        if let seasonSubstringRange = Range(seasonMatchRange, in: string) {
            season = Int(String(string[seasonSubstringRange]))
        }
        
        let episodeMatchRange = match.range(withName: "episode")
        if let episodeSubstringRange = Range(episodeMatchRange, in: string) {
            episode = Int(String(string[episodeSubstringRange]))
        }
        
        self.init(season: season, episode: episode)
    }
}
