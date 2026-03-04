import XCTest
@testable import QuickNoteCore

final class NoteWriterTests: XCTestCase {
    var tempDir: URL!
    var writer: NoteWriter!

    override func setUp() {
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        writer = NoteWriter(directory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func testTodayFileNameFormat() {
        let name = writer.todayFilePath().lastPathComponent
        // Should be "note_YYYY_MM_DD.md"
        XCTAssertTrue(name.hasPrefix("note_"))
        XCTAssertTrue(name.hasSuffix(".md"))
        XCTAssertEqual(name.count, "note_2026_03_04.md".count)
    }

    func testEnsureFileCreatesWithDateHeader() throws {
        let path = try writer.ensureFileExists()
        let content = try String(contentsOf: path, encoding: .utf8)
        // Header should be exactly "# YYYY-MM-DD"
        let lines = content.components(separatedBy: "\n")
        XCTAssertEqual(lines.first?.count, "# 2026-03-04".count)
        XCTAssertTrue(lines.first?.hasPrefix("# ") == true)
        XCTAssertTrue(lines.first?.dropFirst(2).contains("-") == true)
    }

    func testEnsureFileDoesNotOverwriteExisting() throws {
        _ = try writer.ensureFileExists()
        try writer.appendItem("first item", number: 1)
        _ = try writer.ensureFileExists() // call again
        let content = try String(contentsOf: writer.todayFilePath(), encoding: .utf8)
        XCTAssertTrue(content.contains("first item"))
    }

    func testAppendItemWritesNumberedLine() throws {
        _ = try writer.ensureFileExists()
        try writer.appendItem("git clone https://example.com", number: 1)
        try writer.appendItem("ls -la", number: 2)
        let content = try String(contentsOf: writer.todayFilePath(), encoding: .utf8)
        XCTAssertTrue(content.contains("1. git clone https://example.com"))
        XCTAssertTrue(content.contains("2. ls -la"))
    }

    func testAppendSessionHeaderWritesTimestamp() throws {
        _ = try writer.ensureFileExists()
        try writer.appendSessionHeader()
        let content = try String(contentsOf: writer.todayFilePath(), encoding: .utf8)
        // Should contain "### HH:mm" pattern
        XCTAssertTrue(content.contains("### "))
        let hasTimePattern = content.range(of: "### \\d{2}:\\d{2}", options: .regularExpression) != nil
        XCTAssertTrue(hasTimePattern, "Session header should contain HH:mm timestamp")
    }

    func testAppendSelectedTextWritesBlockquote() throws {
        try writer.appendSelectedText("This is selected text")
        let content = try String(contentsOf: writer.todayFilePath(), encoding: .utf8)
        XCTAssertTrue(content.contains("✂️"))
        XCTAssertTrue(content.contains("> This is selected text"))
    }
}
