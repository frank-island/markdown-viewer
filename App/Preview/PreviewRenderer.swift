import Foundation
import JavaScriptCore

enum PreviewRendererError: LocalizedError {
    case missingResource(String)
    case javaScriptFailure(String)
    case rendererUnavailable

    var errorDescription: String? {
        switch self {
        case .missingResource(let name):
            return "Missing preview resource: \(name)"
        case .javaScriptFailure(let message):
            return "Markdown renderer failed: \(message)"
        case .rendererUnavailable:
            return "Markdown renderer is unavailable."
        }
    }
}

final class PreviewRenderer {
    private struct Assets {
        let markedSource: String
        let stylesheet: String
    }

    private let bundle: Bundle
    private var cachedAssets: Assets?

    init(bundle: Bundle = .markdownPreviewResources) {
        self.bundle = bundle
    }

    func render(markdown: String, documentURL: URL?) throws -> String {
        let assets = try loadAssets()
        let body = try renderBody(markdown: markdown, markedSource: assets.markedSource)
        let baseHref = documentURL?.deletingLastPathComponent().absoluteString ?? ""

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <base href="\(htmlEscapedAttribute(baseHref))">
          <style>
        \(assets.stylesheet)
          </style>
        </head>
        <body>
          <article class="markdown-body">
        \(body)
          </article>
        </body>
        </html>
        """
    }

    func errorHTML(message: String) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            :root { color-scheme: light dark; }
            body {
              margin: 0;
              padding: 24px;
              font: 14px/1.5 -apple-system, BlinkMacSystemFont, sans-serif;
              background: transparent;
            }
            .error {
              padding: 16px 18px;
              border-radius: 12px;
              background: rgba(255, 149, 0, 0.12);
              color: inherit;
            }
          </style>
        </head>
        <body>
          <div class="error">\(htmlEscapedText(message))</div>
        </body>
        </html>
        """
    }

    private func loadAssets() throws -> Assets {
        if let cachedAssets {
            return cachedAssets
        }

        let markedSource = try loadTextResource(named: "marked.min", extension: "js")
        let githubStyles = try loadTextResource(named: "github-markdown.min", extension: "css")
        let previewStyles = try loadTextResource(named: "preview", extension: "css")
        let assets = Assets(markedSource: markedSource, stylesheet: githubStyles + "\n" + previewStyles)
        cachedAssets = assets
        return assets
    }

    private func renderBody(markdown: String, markedSource: String) throws -> String {
        let context = JSContext()
        var javaScriptError: PreviewRendererError?

        context?.exceptionHandler = { _, exception in
            javaScriptError = .javaScriptFailure(exception?.toString() ?? "Unknown JavaScript error")
        }

        context?.evaluateScript(markedSource)

        if let javaScriptError {
            throw javaScriptError
        }

        guard let parse = context?
            .objectForKeyedSubscript("marked")?
            .objectForKeyedSubscript("parse") else {
            throw PreviewRendererError.rendererUnavailable
        }

        let options = JSValue(newObjectIn: context)
        options?.setObject(true, forKeyedSubscript: "gfm" as NSString)
        options?.setObject(false, forKeyedSubscript: "breaks" as NSString)

        guard let html = parse.call(withArguments: [markdown, options as Any])?.toString() else {
            throw javaScriptError ?? PreviewRendererError.rendererUnavailable
        }

        return html
    }

    private func loadTextResource(named name: String, extension ext: String) throws -> String {
        let resourceURL =
            bundle.url(forResource: name, withExtension: ext)
            ?? resourceOverrideURL(named: name, extension: ext)

        guard let url = resourceURL else {
            throw PreviewRendererError.missingResource("\(name).\(ext)")
        }

        return try String(contentsOf: url, encoding: .utf8)
    }

    private func resourceOverrideURL(named name: String, extension ext: String) -> URL? {
        guard let root = ProcessInfo.processInfo.environment["MARKDOWN_RESOURCE_ROOT"] else {
            return nil
        }

        return URL(fileURLWithPath: root)
            .appendingPathComponent(name)
            .appendingPathExtension(ext)
    }

    private func htmlEscapedAttribute(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func htmlEscapedText(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
