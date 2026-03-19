import SwiftUI

@main
struct MarkdownApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document, fileURL: file.fileURL)
        }

        MenuBarExtra("Markdown", systemImage: "doc.text") {
            MenuBarContent()
        }
    }
}
