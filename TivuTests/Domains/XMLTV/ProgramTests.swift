import XCTest
@testable import Tivu

class ProgramTests: XCTestCase {
    func testNumber() {
        let number = Program.Number(xmltvString: "0 . 5 . ")!
        XCTAssertEqual(number.season, 1)
        XCTAssertEqual(number.episode, 6)
    }
    
    func testNumberWithPart() {
        let number = Program.Number(xmltvString: "2 . 7 . 9")!
        XCTAssertEqual(number.season, 3)
        XCTAssertEqual(number.episode, 8)
    }
    
    func testNumberWithSeasonOnly() {
        let number = Program.Number(xmltvString: "2 .   . ")!
        XCTAssertEqual(number.season, 3)
        XCTAssertEqual(number.episode, nil)
    }
    
    func testNumberWithEpisodeOnly() {
        let number = Program.Number(xmltvString: " . 4 . ")!
        XCTAssertEqual(number.season, nil)
        XCTAssertEqual(number.episode, 5)
    }
}
