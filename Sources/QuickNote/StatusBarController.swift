import AppKit
import QuickNoteCore

class StatusBarController {
    private let statusItem: NSStatusItem
    private let keyboardMonitor: KeyboardMonitor
    private var listenMenuItem: NSMenuItem!

    var onOpenSettings: (() -> Void)?

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        keyboardMonitor = KeyboardMonitor(noteWriterProvider: {
            NoteWriter(directory: Settings.noteDirectory)
        })

        keyboardMonitor.onStateChanged = { [weak self] isListening in
            DispatchQueue.main.async {
                self?.updateState(isListening: isListening)
            }
        }

        setupMenu()
        updateState(isListening: false)
    }

    private func setupMenu() {
        let menu = NSMenu()

        listenMenuItem = NSMenuItem(
            title: "Start Listening  ⌘D",
            action: #selector(toggleListening),
            keyEquivalent: ""
        )
        listenMenuItem.target = self
        menu.addItem(listenMenuItem)

        let appendItem = NSMenuItem(
            title: "Append Selection  ⌘⇧D",
            action: nil,
            keyEquivalent: ""
        )
        appendItem.isEnabled = false
        menu.addItem(appendItem)

        menu.addItem(.separator())

        let openItem = NSMenuItem(
            title: "Open Today's Note",
            action: #selector(openNoteFile),
            keyEquivalent: ""
        )
        openItem.target = self
        menu.addItem(openItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let quitItem = NSMenuItem(
            title: "Quit QuickNote",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func updateState(isListening: Bool) {
        if let button = statusItem.button {
            button.title = isListening ? "●" : "○"
            button.contentTintColor = isListening ? .systemRed : .labelColor
        }
        listenMenuItem.title = isListening
            ? "Stop Listening  ⌘D"
            : "Start Listening  ⌘D"
    }

    @objc private func toggleListening() {
        keyboardMonitor.toggle()
    }

    @objc private func openNoteFile() {
        let writer = NoteWriter(directory: Settings.noteDirectory)
        let path = writer.todayFilePath()
        try? writer.ensureFileExists()
        NSWorkspace.shared.open(path)
    }

    @objc private func openSettings() {
        onOpenSettings?()
    }
}
