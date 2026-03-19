import AppKit
import SwiftUI
import WebKit

struct ContentView: View {
    @Binding var document: MarkdownDocument
    let fileURL: URL?

    @Environment(\.openDocument) private var openDocument
    @StateObject private var previewModel = PreviewViewModel()
    private let linkRouter = PreviewLinkRouter()

    var body: some View {
        HSplitView {
            editorPane
            previewPane
        }
        .frame(minWidth: 960, minHeight: 640)
        .onAppear {
            syncFileURL()
            schedulePreviewRender()
        }
        .onChange(of: fileURL, initial: false) { _, _ in
            syncFileURL()
            schedulePreviewRender()
        }
        .onChange(of: document.text, initial: false) { _, _ in
            schedulePreviewRender()
        }
    }

    private var editorPane: some View {
        VStack(alignment: .leading, spacing: 0) {
            paneHeader("Markdown")

            TextEditor(text: $document.text)
                .font(.system(.body, design: .monospaced))
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .accessibilityIdentifier("markdown-editor")
        }
        .frame(minWidth: 360, idealWidth: 460, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var previewPane: some View {
        VStack(alignment: .leading, spacing: 0) {
            paneHeader("Preview")

            MarkdownPreview(
                html: previewModel.html,
                documentURL: fileURL
            ) { url in
                handleNavigation(for: url)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 360, idealWidth: 500, maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func paneHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if let fileURL {
                Text(fileURL.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func schedulePreviewRender() {
        previewModel.scheduleRender(markdown: document.text, documentURL: fileURL)
    }

    private func syncFileURL() {
        if document.fileURL != fileURL {
            document.updateFileURL(fileURL)
        }
    }

    private func handleNavigation(for url: URL) -> WKNavigationActionPolicy {
        switch linkRouter.destination(for: url, relativeTo: fileURL) {
        case .allowInPreview:
            return .allow
        case .openMarkdownDocument(let documentURL):
            Task {
                try? await openDocument(at: documentURL)
            }
            return .cancel
        case .openFile(let fileURL):
            NSWorkspace.shared.open(fileURL)
            return .cancel
        case .openExternal(let externalURL):
            NSWorkspace.shared.open(externalURL)
            return .cancel
        }
    }
}
