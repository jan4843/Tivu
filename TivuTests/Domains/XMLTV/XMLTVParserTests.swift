import XCTest
@testable import Tivu

class XMLTVParserTests: XCTestCase {
    // MARK: - Full
    
    let xmltvFull = """
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE tv SYSTEM "xmltv.dtd">
    <tv generator-info-name="TVHeadend-4.3-2013~g90ba8b1c1" source-info-name="tvh-Tvheadend">
        <channel id="743dac58ccb8d8cac5f87f88482a3d72">
            <display-name>Rai 1</display-name>
            <lcn>1</lcn>
            <icon src="https://api.superguidatv.it/v1/channels/217/logo?theme=light" />
        </channel>
        <programme start="20220525203000 +0200" stop="20220525212500 +0200" channel="743dac58ccb8d8cac5f87f88482a3d72">
            <title>Soliti Ignoti</title>
            <sub-title>Il Ritorno</sub-title>
            <desc>Dal Teatro delle Vittorie, 8 Ignoti, con le relative identit&#224; nascoste.</desc>
            <icon src="https://api.superguidatv.it/v1/programs/953924349/backdrops/1" />
            <episode-num system="xmltv_ns">8 . 3 .   </episode-num>
        </programme>
    </tv>
    """
    
    func testParseChannelFull() {
        let spy = parse(xmltvFull)
        
        let expectedChannel = Channel(
            id: "743dac58ccb8d8cac5f87f88482a3d72",
            name: "Rai 1",
            number: Channel.Number(1),
            logoURL: URL(string: "https://api.superguidatv.it/v1/channels/217/logo?theme=light")!
        )
        XCTAssertEqual(spy.channels.count, 1)
        XCTAssertEqual(spy.channels.first!, expectedChannel)
    }
    
    func testParseProgramFull() {
        let spy = parse(xmltvFull)

        let expectedProgram = Program(
            interval: DateInterval(start: Date(timeIntervalSince1970: 1653503400), duration: 3300),
            channelID: "743dac58ccb8d8cac5f87f88482a3d72",
            title: "Soliti Ignoti",
            subtitle: "Il Ritorno",
            description: "Dal Teatro delle Vittorie, 8 Ignoti, con le relative identità nascoste.",
            imageURL: URL(string: "https://api.superguidatv.it/v1/programs/953924349/backdrops/1")!,
            number: Program.Number(season: 9, episode: 4)
        )
        XCTAssertEqual(spy.programs.count, 1)
        XCTAssertEqual(spy.programs.first!, expectedProgram)
    }
    
    // MARK: - Minimal
    
    let xmltvMinimal = """
    <?xml version="1.0" encoding="utf-8"?>
    <!DOCTYPE tv SYSTEM "xmltv.dtd">
    <tv generator-info-name="TVHeadend-4.3-2013~g90ba8b1c1" source-info-name="tvh-Tvheadend">
        <channel id="743dac58ccb8d8cac5f87f88482a3d72">
            <display-name>Rai 1</display-name>
        </channel>
        <programme start="20220525203000 +0200" stop="20220525212500 +0200" channel="743dac58ccb8d8cac5f87f88482a3d72">
        </programme>
    </tv>
    """
    
    func testParseChannelMinimal() {
        let spy = parse(xmltvMinimal)
        
        let expectedChannel = Channel(
            id: "743dac58ccb8d8cac5f87f88482a3d72",
            name: "Rai 1",
            number: nil,
            logoURL: nil
        )
        XCTAssertEqual(spy.channels.count, 1)
        XCTAssertEqual(spy.channels.first!, expectedChannel)
    }
    
    func testParseProgramMinimal() {
        let spy = parse(xmltvMinimal)
        
        let expectedProgram = Program(
            interval: DateInterval(start: Date(timeIntervalSince1970: 1653503400), duration: 3300),
            channelID: "743dac58ccb8d8cac5f87f88482a3d72",
            title: nil,
            subtitle: nil,
            description: nil,
            imageURL: nil,
            number: nil
        )
        
        XCTAssertEqual(spy.programs.count, 1)
        XCTAssertEqual(spy.programs.first!, expectedProgram)
    }
    
    // MARK: - Invalid
    
    func testParseEmpty() {
        let spy = parse("")
        XCTAssertEqual(spy.parseErrors.count, 1)
    }
    
    func testParseInvalidXML() {
        let spy = parse("foo")
        XCTAssertEqual(spy.parseErrors.count, 1)
    }
    
    func testParseInvalidXMLTV() {
        let spy = parse("<foo/>")
        XCTAssertEqual(spy.parseErrors.count, 1)
    }
    
    // MARK: - Helpers
    
    class SpyDelegate: XMLTVParserDelegate {
        var channels = [Channel]()
        var programs = [Program]()
        var parseErrors = [Error]()
        
        func parser(_ parser: XMLTVParser, didFindChannel channel: Channel) {
            channels.append(channel)
        }
        
        func parser(_ parser: XMLTVParser, didFindProgram program: Program) {
            programs.append(program)
        }
        
        func parser(_ parser: XMLTVParser, parseErrorOccurred parseError: Error) {
            parseErrors.append(parseError)
        }
    }
    
    func parse(_ xmltv: String) -> SpyDelegate {
        let parser = XMLTVParser(data: xmltv.data(using: .utf8)!)
        let delegate = SpyDelegate()
        parser.delegate = delegate
        parser.parse()
        return delegate
    }
}
