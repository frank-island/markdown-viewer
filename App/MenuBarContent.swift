import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct MenuBarContent: View {
    @Environment(\.openDocument) private var openDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button("Open Markdown File...") {
                openMarkdownFile()
            }
            .keyboardShortcut("o")

            Divider()

            Button("Quit Markdown") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .padding(12)
        .frame(width: 220)
    }

    private func openMarkdownFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.markdownDocument]
        panel.message = "Choose a Markdown file to open."

        guard panel.runModal() == .OK, let url = panel.url else {
            return
        }

        Task {
            try? await openDocument(at: url)
        }
    }
}
