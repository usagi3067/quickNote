import AppKit

struct TextSelectionCapture {
    // Virtual key code for 'C' (kVK_ANSI_C = 0x08)
    private let kVK_ANSI_C: CGKeyCode = 0x08

    /// Captures selected text from the frontmost app using clipboard simulation.
    /// Works across all apps (browsers, Electron, native) unlike AXUIElement.
    /// Calls completion on the main thread.
    func captureSelectedText(completion: @escaping (String?) -> Void) {
        let pasteboard = NSPasteboard.general

        // Save current clipboard content
        let savedString = pasteboard.string(forType: .string)

        // Clear clipboard so we can detect if copy worked
        pasteboard.clearContents()

        // Simulate Cmd+C posted at .cgAnnotatedSessionEventTap — this level is
        // AFTER our CGEventTap (which sits at .cgSessionEventTap), so our tap
        // won't intercept it, but the focused app will still receive it.
        let source = CGEventSource(stateID: .hidSystemState)
        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: kVK_ANSI_C, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: kVK_ANSI_C, keyDown: false) else {
            completion(nil)
            return
        }
        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cgAnnotatedSessionEventTap)
        keyUp.post(tap: .cgAnnotatedSessionEventTap)

        // Wait on background thread for clipboard to update, then call completion
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.15) {
            let captured = pasteboard.string(forType: .string)

            // Restore original clipboard on main thread
            DispatchQueue.main.async {
                pasteboard.clearContents()
                if let saved = savedString {
                    pasteboard.setString(saved, forType: .string)
                }
                let result = (captured?.isEmpty == false) ? captured : nil
                completion(result)
            }
        }
    }
}
