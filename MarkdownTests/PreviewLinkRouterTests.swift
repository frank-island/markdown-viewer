import Foundation
import XCTest
@testable import Markdown

final class PreviewLinkRouterTests: XCTestCase {
    private let router = PreviewLinkRouter()
    private let baseURL = URL(fileURLWithPath: "/tmp/docs/guide.md")

    func testResolvesRelativeMarkdownLinksToDocuments() {
        let destination = router.destination(for: URL(string: "./appendix/next.md")!, relativeTo: baseURL)

        XCTAssertEqual(destination, .openMarkdownDocument(URL(fileURLWithPath: "/tmp/docs/appendix/next.md")))
    }

    func testRoutesRelativeAssetLinksAsFiles() {
        let destination = router.destination(for: URL(string: "./images/chart.png")!, relativeTo: baseURL)

        XCTAssertEqual(destination, .openFile(URL(fileURLWithPath: "/tmp/docs/images/chart.png")))
    }

    func testKeepsSameDocumentAnchorsInPreview() {
        let destination = router.destination(for: URL(string: "guide.md#summary")!, relativeTo: baseURL)

        XCTAssertEqual(destination, .allowInPreview)
    }

    func testRoutesExternalLinksOutOfProcess() {
        let url = URL(string: "https://example.com/docs")!
        let destination = router.destination(for: url, relativeTo: baseURL)

        XCTAssertEqual(destination, .openExternal(url))
    }
}
