import SwiftUI
import WebKit

struct MarkdownPreview: NSViewRepresentable {
    let html: String
    let documentURL: URL?
    let navigationPolicy: (URL) -> WKNavigationActionPolicy

    func makeCoordinator() -> Coordinator {
        Coordinator(documentURL: documentURL, navigationPolicy: navigationPolicy)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.isElementFullscreenEnabled = false
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        webView.setAccessibilityIdentifier("markdown-preview")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let baseURL = documentURL?.deletingLastPathComponent()
        context.coordinator.documentURL = documentURL
        context.coordinator.navigationPolicy = navigationPolicy

        guard context.coordinator.lastHTML != html || context.coordinator.lastBaseURL != baseURL else {
            return
        }

        context.coordinator.lastHTML = html
        context.coordinator.lastBaseURL = baseURL
        webView.loadHTMLString(html, baseURL: baseURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var documentURL: URL?
        var navigationPolicy: (URL) -> WKNavigationActionPolicy
        var lastHTML = ""
        var lastBaseURL: URL?

        init(documentURL: URL?, navigationPolicy: @escaping (URL) -> WKNavigationActionPolicy) {
            self.documentURL = documentURL
            self.navigationPolicy = navigationPolicy
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            decisionHandler(navigationPolicy(url))
        }
    }
}
