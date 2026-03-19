import Foundation

enum PreviewNavigationDestination: Equatable {
    case allowInPreview
    case openMarkdownDocument(URL)
    case openFile(URL)
    case openExternal(URL)
}

struct PreviewLinkRouter {
    private let markdownExtensions: Set<String> = ["md", "markdown", "mdown"]

    func destination(for url: URL, relativeTo documentURL: URL?) -> PreviewNavigationDestination {
        let resolvedURL = resolve(url, relativeTo: documentURL)

        if isSameDocumentAnchor(resolvedURL, documentURL: documentURL) {
            return .allowInPreview
        }

        if let scheme = resolvedURL.scheme?.lowercased(), ["http", "https"].contains(scheme) {
            return .openExternal(resolvedURL)
        }

        if resolvedURL.isFileURL || resolvedURL.scheme == nil {
            let standardized = resolvedURL.standardizedFileURL
            let pathExtension = standardized.pathExtension.lowercased()

            if markdownExtensions.contains(pathExtension) {
                return .openMarkdownDocument(standardized)
            }

            return .openFile(standardized)
        }

        return .openExternal(resolvedURL)
    }

    func resolve(_ url: URL, relativeTo documentURL: URL?) -> URL {
        guard url.scheme == nil, !url.isFileURL, let documentURL else {
            return url
        }

        let baseURL = documentURL.deletingLastPathComponent()
        return URL(string: url.relativeString, relativeTo: baseURL)?.absoluteURL ?? url
    }

    private func isSameDocumentAnchor(_ url: URL, documentURL: URL?) -> Bool {
        guard let documentURL,
              let fragment = url.fragment,
              !fragment.isEmpty else {
            return false
        }

        return url.removingFragment?.standardizedFileURL == documentURL.standardizedFileURL
    }
}

private extension URL {
    var removingFragment: URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }

        components.fragment = nil
        return components.url
    }
}
