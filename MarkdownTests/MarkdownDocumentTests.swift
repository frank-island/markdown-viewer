import SwiftUI
import XCTest
@testable import Markdown

final class MarkdownDocumentTests: XCTestCase {
    func testDecodesUTF8Markdown() throws {
        let value = try MarkdownDocument.decode(Data("# Hello\n".utf8))
        XCTAssertEqual(value, "# Hello\n")
    }

    func testRejectsInvalidUTF8Markdown() {
        XCTAssertThrowsError(try MarkdownDocument.decode(Data([0xFF, 0xFE, 0xFD])))
    }

    func testEncodesUTF8Markdown() throws {
        let data = try MarkdownDocument.encode("- item")
        XCTAssertEqual(data, Data("- item".utf8))
    }

    func testTracksFileURLContext() {
        var document = MarkdownDocument(text: "# Hello")
        let fileURL = URL(fileURLWithPath: "/tmp/docs/readme.md")

        document.updateFileURL(fileURL)

        XCTAssertEqual(document.fileURL, fileURL)
    }
}
