#!/usr/bin/env ruby

require "fileutils"
require "xcodeproj"

PROJECT_NAME = "Markdown"
ROOT = File.expand_path("..", __dir__)
PROJECT_PATH = File.join(ROOT, "#{PROJECT_NAME}.xcodeproj")

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes["LastSwiftUpdateCheck"] = "1600"
project.root_object.attributes["LastUpgradeCheck"] = "1600"

app_target = project.new_target(:application, PROJECT_NAME, :osx, "14.0")
test_target = project.new_target(:unit_test_bundle, "#{PROJECT_NAME}Tests", :osx, "14.0")
ui_test_target = project.new_target(:ui_test_bundle, "#{PROJECT_NAME}UITests", :osx, "14.0")

[app_target, test_target, ui_test_target].each do |target|
  target.build_configurations.each do |config|
    config.build_settings["SWIFT_VERSION"] = "5.0"
    config.build_settings["CLANG_ENABLE_MODULES"] = "YES"
    config.build_settings["CODE_SIGN_STYLE"] = "Automatic"
    config.build_settings["MACOSX_DEPLOYMENT_TARGET"] = "14.0"
    config.build_settings["SDKROOT"] = "macosx"
    config.build_settings["ENABLE_APP_SANDBOX"] = "NO"
  end
end

app_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.elsiepiao.markdown"
  config.build_settings["INFOPLIST_FILE"] = "App/Info.plist"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "NO"
  config.build_settings["PRODUCT_NAME"] = "$(TARGET_NAME)"
  config.build_settings["SWIFT_EMIT_LOC_STRINGS"] = "NO"
  config.build_settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = ""
end

test_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.elsiepiao.markdown.tests"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["TEST_HOST"] = "$(BUILT_PRODUCTS_DIR)/Markdown.app/Contents/MacOS/Markdown"
  config.build_settings["BUNDLE_LOADER"] = "$(TEST_HOST)"
end

ui_test_target.build_configurations.each do |config|
  config.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = "com.elsiepiao.markdown.uitests"
  config.build_settings["GENERATE_INFOPLIST_FILE"] = "YES"
  config.build_settings["TEST_TARGET_NAME"] = "Markdown"
end

test_target.add_dependency(app_target)
ui_test_target.add_dependency(app_target)

main_group = project.main_group
app_group = main_group.new_group("App", "App")
preview_group = app_group.new_group("Preview", "Preview")
support_group = app_group.new_group("Support", "Support")
resources_group = app_group.new_group("Resources", "Resources")
tests_group = main_group.new_group("MarkdownTests", "MarkdownTests")
ui_tests_group = main_group.new_group("MarkdownUITests", "MarkdownUITests")

def add_sources(target, group, paths)
  refs = paths.map { |path| group.new_file(path) }
  target.add_file_references(refs)
end

def add_resources(target, refs)
  refs.each do |ref|
    target.resources_build_phase.add_file_reference(ref)
  end
end

app_sources = [
  "MarkdownApp.swift",
  "MarkdownDocument.swift",
  "ContentView.swift",
  "MenuBarContent.swift"
]

preview_sources = [
  "MarkdownPreview.swift",
  "PreviewRenderer.swift",
  "PreviewLinkRouter.swift",
  "PreviewViewModel.swift"
]

support_sources = [
  "Bundle+MarkdownResources.swift",
  "UTType+Markdown.swift"
]

resource_files = [
  "marked.min.js",
  "github-markdown.min.css",
  "preview.css",
  "THIRD_PARTY_NOTICES.md"
]

test_sources = [
  "MarkdownDocumentTests.swift",
  "PreviewLinkRouterTests.swift",
  "PreviewRendererTests.swift"
]

ui_test_sources = [
  "MarkdownUITests.swift"
]

add_sources(app_target, app_group, app_sources)
add_sources(app_target, preview_group, preview_sources)
add_sources(app_target, support_group, support_sources)
resource_refs = resource_files.map { |path| resources_group.new_file(path) }

add_resources(app_target, resource_refs)

add_sources(test_target, tests_group, test_sources)
add_resources(test_target, resource_refs)

add_sources(ui_test_target, ui_tests_group, ui_test_sources)

project.save
