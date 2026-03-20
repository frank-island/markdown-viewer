# Markdown

A native macOS Markdown editor with a live side-by-side preview.

## Overview

This app lets you open and edit Markdown documents in a split view:

- a plain text Markdown editor on the left
- a rendered preview on the right
- a menu bar shortcut for quickly opening Markdown files

The preview is rendered locally using bundled assets, so the app does not depend on a web service to display Markdown.

## Features

- Native macOS app built with SwiftUI and WebKit
- Live preview as you type
- GitHub-flavored Markdown rendering via `marked`
- Support for relative links and images
- Smart link routing for:
  - in-document anchors
  - other Markdown files
  - local file assets
  - external URLs
- Basic unit and UI test coverage

## Project Structure

```text
App/
  ContentView.swift              Main split-view editor UI
  MarkdownApp.swift              App entry point
  MarkdownDocument.swift         FileDocument model for Markdown files
  MenuBarContent.swift           Menu bar actions
  Preview/
    MarkdownPreview.swift        WebKit bridge for HTML preview
    PreviewLinkRouter.swift      Link handling rules
    PreviewRenderer.swift        Markdown-to-HTML rendering
    PreviewViewModel.swift       Preview update scheduling
  Resources/
    github-markdown.min.css      GitHub-style Markdown CSS
    marked.min.js                Bundled Markdown parser
    preview.css                  App-specific preview styling
MarkdownTests/                   Unit tests
MarkdownUITests/                 UI tests
scripts/                         Build and install helpers
```

## Requirements

- macOS 14+
- Xcode with Swift 5 support
- Command line developer tools

## Running the App

### In Xcode

1. Open `Markdown.xcodeproj`.
2. Select the `Markdown` scheme.
3. Build and run the app.

### From the command line

Build the app bundle:

```bash
./scripts/build_app.sh
```

Install the built app into `/Applications`:

```bash
./scripts/install_app.sh
```

The build script creates:

```text
build/Markdown.app
```

## Testing

Run tests from Xcode, or use `xcodebuild` with the project:

```bash
xcodebuild test -project Markdown.xcodeproj -scheme Markdown -destination 'platform=macOS'
```

Current tests cover:

- Markdown document encoding and decoding
- preview rendering behavior
- link routing behavior
- basic application launch UI coverage

## How Preview Rendering Works

The preview pipeline is intentionally simple:

1. Markdown text is read from the document model.
2. `PreviewRenderer` loads bundled CSS and the bundled `marked` JavaScript parser.
3. The Markdown is converted to HTML.
4. The generated HTML is displayed in a `WKWebView`.
5. Link clicks are intercepted and routed based on destination type.

Relative links are resolved against the current document location, which keeps linked Markdown files and image assets working as expected.

## Notes

- The app defines its own exported markdown UTI: `com.elsiepiao.markdown.document`.
- Preview resources can be overridden in some environments using the `MARKDOWN_RESOURCE_ROOT` environment variable.
- Third-party asset notices are included in `App/Resources/THIRD_PARTY_NOTICES.md`.

## Scripts

- `scripts/build_app.sh` — builds a standalone macOS app bundle with `swiftc`
- `scripts/install_app.sh` — builds and copies the app into `/Applications`
- `scripts/generate_xcodeproj.rb` — regenerates the Xcode project structure

## License / Third-Party Assets

This repository includes third-party frontend assets used for Markdown rendering and styling. See:

- `App/Resources/THIRD_PARTY_NOTICES.md`

