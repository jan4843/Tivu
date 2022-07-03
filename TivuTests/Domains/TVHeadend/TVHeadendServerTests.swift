import XCTest
@testable import Tivu

class TVHeadendServerTests: XCTestCase {
    let server = TVHeadendServer(url: URL(string: "http://example.com/tvh/?client=Tivu")!)
    
    func testXMLTVURL() {
        let expectedXMLTVURL = URL(string: "http://example.com/tvh/xmltv/channels?client=Tivu&lcn=1")!
        XCTAssertEqual(server.xmltvURL, expectedXMLTVURL)
    }
    
    func testStreamURL() {
        let channel = Channel(id: "743dac58ccb8d8cac5f87f88482a3d72", name: "Rai 1", number: nil, logoURL: nil)
        let expectedStreamURL = URL(string: "http://example.com/tvh/stream/channel/743dac58ccb8d8cac5f87f88482a3d72?client=Tivu")!
        XCTAssertEqual(server.streamURL(for: channel), expectedStreamURL)
    }
}
