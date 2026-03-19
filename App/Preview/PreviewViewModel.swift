import Foundation

@MainActor
final class PreviewViewModel: ObservableObject {
    @Published private(set) var html: String

    private let renderer: PreviewRenderer
    private var renderTask: Task<Void, Never>?

    init(renderer: PreviewRenderer = PreviewRenderer()) {
        self.renderer = renderer
        self.html = renderer.errorHTML(message: "Preview is preparing.")
    }

    deinit {
        renderTask?.cancel()
    }

    func scheduleRender(markdown: String, documentURL: URL?) {
        renderTask?.cancel()
        renderTask = Task { [renderer] in
            do {
                try await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else {
                    return
                }

                let html = try renderer.render(markdown: markdown, documentURL: documentURL)
                guard !Task.isCancelled else {
                    return
                }

                self.html = html
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                self.html = renderer.errorHTML(message: error.localizedDescription)
            }
        }
    }
}
