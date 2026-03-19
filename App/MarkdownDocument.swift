import SwiftUI
import UniformTypeIdentifiers

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.markdownDocument]
    }

    var text: String
    var fileURL: URL?

    init(text: String = "") {
        self.text = text
        self.fileURL = nil
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.text = try Self.decode(data)
        self.fileURL = nil
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: try Self.encode(text))
    }

    mutating func updateFileURL(_ newValue: URL?) {
        fileURL = newValue
    }

    static func decode(_ data: Data) throws -> String {
        guard let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadInapplicableStringEncoding)
        }

        return string
    }

    static func encode(_ text: String) throws -> Data {
        Data(text.utf8)
    }
}
