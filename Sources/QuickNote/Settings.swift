import Foundation

enum Settings {
    private static let directoryKey = "noteDirectory"

    static var noteDirectory: URL {
        get {
            if let path = UserDefaults.standard.string(forKey: directoryKey) {
                return URL(fileURLWithPath: path)
            }
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return docs.appendingPathComponent("QuickNotes")
        }
        set {
            UserDefaults.standard.set(newValue.path, forKey: directoryKey)
        }
    }

    static func ensureDirectoryExists() {
        try? FileManager.default.createDirectory(
            at: noteDirectory,
            withIntermediateDirectories: true
        )
    }
}
