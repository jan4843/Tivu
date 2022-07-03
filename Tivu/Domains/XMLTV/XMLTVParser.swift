import Foundation

protocol XMLTVParserDelegate: AnyObject {
    func parser(_ parser: XMLTVParser, didFindChannel channel: Channel)
    func parser(_ parser: XMLTVParser, didFindProgram program: Program)
    func parser(_ parser: XMLTVParser, parseErrorOccurred parseError: Error)
}

class XMLTVParser: NSObject, XMLParserDelegate {
    public var delegate: XMLTVParserDelegate?
    private let parser: XMLParser
    
    init?(contentsOf url: URL) {
        guard let parser = XMLParser(contentsOf: url) else { return nil }
        self.parser = parser
    }
    
    init(data: Data) {
        self.parser = XMLParser(data: data)
    }
    
    init(stream: InputStream) {
        self.parser = XMLParser(stream: stream)
    }
    
    func parse() {
        parser.delegate = self
        parser.parse()
        parserDidEndDocument(parser)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss Z"
        return dateFormatter
    }()
    
    private var invalidXMLTVError = NSError(
        domain: "",
        code: 0,
        userInfo: [NSLocalizedDescriptionKey: "Invalid XMLTV"]
    )
    
    // MARK: State
    private var foundRoot = false
    private var currentPath = [String]()
    private var currentContent = ""
    private var lastContentPath = [String]()
    private var currentChannel = [String: String]()
    private var currentProgram = [String: String]()
    
    // MARK: - Handle
    internal func parser(_ parser: XMLParser,
                         didStartElement elementName: String,
                         namespaceURI: String?,
                         qualifiedName qName: String?,
                         attributes attributeDict: [String: String] = [:]) {
        currentPath.append(elementName)
        
        if !foundRoot && currentPath.first != "tv" {
            didFindError(invalidXMLTVError)
        }
        foundRoot = true
        
        switch currentPath {
        case ["tv", "channel"]:
            currentChannel = [:]
            currentChannel["id"] = attributeDict["id"] ?? ""
        case ["tv", "channel", "icon"]:
            currentChannel["icon"] = attributeDict["src"] ?? ""
        case ["tv", "programme"]:
            currentProgram = [:]
            currentProgram["start"] = attributeDict["start"] ?? ""
            currentProgram["stop"] = attributeDict["stop"] ?? ""
            currentProgram["channel"] = attributeDict["channel"] ?? ""
        case ["tv", "programme", "icon"]:
            currentProgram["icon"] = attributeDict["src"] ?? ""
        default:
            break
        }
    }
    
    internal func parser(_ parser: XMLParser,
                         didEndElement elementName: String,
                         namespaceURI: String?,
                         qualifiedName qName: String?) {
        switch currentPath {
        case ["tv", "channel"]:
            didEndChannel()
        case ["tv", "channel", "display-name"]:
            currentChannel["display-name"] = currentContent
        case ["tv", "channel", "lcn"]:
            currentChannel["lcn"] = currentContent
        case ["tv", "programme"]:
            didEndProgram()
        case ["tv", "programme", "title"]:
            currentProgram["title"] = currentContent
        case ["tv", "programme", "sub-title"]:
            currentProgram["sub-title"] = currentContent
        case ["tv", "programme", "desc"]:
            currentProgram["desc"] = currentContent
        case ["tv", "programme", "episode-num"]:
            currentProgram["episode-num"] = currentContent
        default:
            break
        }
        
        currentPath.removeLast()
    }
    
    internal func parser(_ parser: XMLParser,
                         foundCharacters string: String) {
        if currentPath != lastContentPath {
            lastContentPath = currentPath
            currentContent = ""
        }
        currentContent.append(string)
    }
    
    func parser(_ parser: XMLParser,
                parseErrorOccurred parseError: Error) {
        didFindError(parseError)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if !foundRoot {
            didFindError(invalidXMLTVError)
        }
    }
    
    // MARK: - Publish
    private func didEndChannel() {
        defer { currentChannel.removeAll(keepingCapacity: true) }
        
        guard let id = currentChannel["id"],
              let name = currentChannel["display-name"]
        else { return }
        
        let channel = Channel(
            id: id,
            name: name,
            number: Channel.Number(string: currentChannel["lcn"] ?? ""),
            logoURL: URL(string: currentChannel["icon"] ?? "")
        )
        delegate?.parser(self, didFindChannel: channel)
    }
    
    private func didEndProgram() {
        defer { currentProgram.removeAll(keepingCapacity: true) }
        
        guard let startDate = dateFormatter.date(from: currentProgram["start"] ?? ""),
              let endDate = dateFormatter.date(from: currentProgram["stop"] ?? ""),
              let channel = currentProgram["channel"]
        else { return }
        
        let program = Program(
            interval: DateInterval(start: startDate, end: endDate),
            channelID: channel,
            title: currentProgram["title"],
            subtitle: currentProgram["sub-title"],
            description: currentProgram["desc"],
            imageURL: URL(string: currentProgram["icon"] ?? ""),
            number: Program.Number(xmltvString: currentProgram["episode-num"] ?? "")
        )
        delegate?.parser(self, didFindProgram: program)
    }
    
    private func didFindError(_ parseError: Error) {
        delegate?.parser(self, parseErrorOccurred: parseError)
    }
}
