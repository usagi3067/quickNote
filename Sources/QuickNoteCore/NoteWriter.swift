import Foundation

public enum NoteWriterError: Error {
    case encodingFailed
}

public struct NoteWriter {
    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    public func todayFilePath() -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        let filename = "note_\(formatter.string(from: Date())).md"
        return directory.appendingPathComponent(filename)
    }

    public func todayFileName() -> String {
        todayFilePath().lastPathComponent
    }

    @discardableResult
    public func ensureFileExists() throws -> URL {
        let path = todayFilePath()
        if !FileManager.default.fileExists(atPath: path.path) {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let header = "# \(formatter.string(from: Date()))\n\n"
            try header.write(to: path, atomically: true, encoding: .utf8)
        }
        return path
    }

    public func appendSessionHeader() throws {
        let path = try ensureFileExists()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let header = "\n### \(formatter.string(from: Date()))\n"
        try appendText(header, to: path)
    }

    public func appendItem(_ text: String, number: Int) throws {
        let path = try ensureFileExists()
        let line = "\(number). \(text)\n"
        try appendText(line, to: path)
    }

    public func appendSelectedText(_ text: String) throws {
        let path = try ensureFileExists()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let content = "\n### \(formatter.string(from: Date())) ✂️\n> \(text)\n"
        try appendText(content, to: path)
    }

    private func appendText(_ text: String, to url: URL) throws {
        guard let data = text.data(using: .utf8) else { throw NoteWriterError.encodingFailed }
        let handle = try FileHandle(forWritingTo: url)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: data)
    }
}
