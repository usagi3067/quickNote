import AppKit

class SettingsWindowController: NSWindowController {
    private var directoryLabel: NSTextField!

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 120),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "QuickNote Settings"
        window.center()
        self.init(window: window)
        setupUI()
    }

    private func setupUI() {
        guard let contentView = window?.contentView else { return }

        let label = NSTextField(labelWithString: "Notes Directory:")
        label.frame = NSRect(x: 20, y: 80, width: 140, height: 20)
        contentView.addSubview(label)

        directoryLabel = NSTextField(labelWithString: Settings.noteDirectory.path)
        directoryLabel.frame = NSRect(x: 20, y: 55, width: 380, height: 20)
        directoryLabel.lineBreakMode = .byTruncatingMiddle
        directoryLabel.isEditable = false
        contentView.addSubview(directoryLabel)

        let button = NSButton(title: "Choose Folder...", target: self, action: #selector(chooseFolder))
        button.frame = NSRect(x: 20, y: 15, width: 150, height: 30)
        contentView.addSubview(button)
    }

    @objc private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose where to save your daily notes"
        panel.begin { [weak self] result in
            if result == .OK, let url = panel.url {
                Settings.noteDirectory = url
                Settings.ensureDirectoryExists()
                self?.directoryLabel.stringValue = url.path
            }
        }
    }
}
