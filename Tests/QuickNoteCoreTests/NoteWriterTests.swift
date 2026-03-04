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
        XCTAssertTrue(content.hasPrefix("# 20"))
        XCTAssertTrue(content.contains("-"))
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
        XCTAssertTrue(content.contains("### "))
    }

    func testAppendSelectedTextWritesBlockquote() throws {
        try writer.appendSelectedText("This is selected text")
        let content = try String(contentsOf: writer.todayFilePath(), encoding: .utf8)
        XCTAssertTrue(content.contains("✂️"))
        XCTAssertTrue(content.contains("> This is selected text"))
    }
}
