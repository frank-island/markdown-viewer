import Foundation

private final class MarkdownPreviewBundleToken {}

extension Bundle {
    static var markdownPreviewResources: Bundle {
        Bundle(for: MarkdownPreviewBundleToken.self)
    }
}
