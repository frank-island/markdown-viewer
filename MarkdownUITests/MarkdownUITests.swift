import XCTest

final class MarkdownUITests: XCTestCase {
    func testLaunchesSplitEditor() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.textViews.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: 5))
    }
}
