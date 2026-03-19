import Foundation
import XCTest
@testable import Markdown

final class PreviewRendererTests: XCTestCase {
    func testRendersGitHubFlavoredMarkdownFeatures() throws {
        let renderer = PreviewRenderer()
        let markdown = """
        # Title

        - [x] done

        | Name | Value |
        | --- | --- |
        | A | B |

        ```swift
        print("hello")
        ```
        """

        let html = try renderer.render(markdown: markdown, documentURL: URL(fileURLWithPath: "/tmp/docs/readme.md"))

        XCTAssertTrue(html.contains("<h1>Title</h1>"))
        XCTAssertTrue(html.contains("checkbox"))
        XCTAssertTrue(html.contains("checked"))
        XCTAssertTrue(html.contains("<table>"))
        XCTAssertTrue(html.contains("language-swift"))
        XCTAssertTrue(html.contains("<base href=\"file:///tmp/docs/\">"))
    }

    func testPreservesRelativeLinksAndImagesAgainstDocumentBase() throws {
        let renderer = PreviewRenderer()
        let markdown = """
        ![Chart](./images/chart.png)

        [Appendix](./appendix.md)
        """

        let html = try renderer.render(markdown: markdown, documentURL: URL(fileURLWithPath: "/tmp/docs/readme.md"))

        XCTAssertTrue(html.contains("src=\"./images/chart.png\""))
        XCTAssertTrue(html.contains("href=\"./appendix.md\""))
    }
}
