import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Settings.ensureDirectoryExists()
        requestAccessibilityPermissions()
        statusBarController = StatusBarController()
        statusBarController?.onOpenSettings = { [weak self] in
            self?.openSettings()
        }
    }

    private func requestAccessibilityPermissions() {
        // Permission 1: Accessibility (for AXUIElement selected text reading)
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        AXIsProcessTrustedWithOptions(options)

        // Permission 2: Input Monitoring (for CGEventTap global keyboard capture)
        // These are two separate permissions in System Settings → Privacy & Security
        if !CGPreflightListenEventAccess() {
            CGRequestListenEventAccess()
        }
    }

    private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
