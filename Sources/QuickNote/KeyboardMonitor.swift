import AppKit
import CoreGraphics
import QuickNoteCore

// Key codes for macOS (hardware key codes, layout-independent)
private let kVK_Return: Int64 = 36
private let kVK_Delete: Int64 = 51
private let kVK_Escape: Int64 = 53
private let kVK_D: Int64 = 2

class KeyboardMonitor {
    private(set) var isListening = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var inputBuffer = ""
    private var itemCount = 0
    private let noteWriterProvider: () -> NoteWriter

    var onStateChanged: ((Bool) -> Void)?

    init(noteWriterProvider: @escaping () -> NoteWriter) {
        self.noteWriterProvider = noteWriterProvider
        setupEventTap()
    }

    func toggle() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }

    private func startListening() {
        isListening = true
        inputBuffer = ""
        itemCount = 0
        try? noteWriterProvider().appendSessionHeader()
        onStateChanged?(true)
    }

    private func stopListening() {
        flushBuffer()
        isListening = false
        onStateChanged?(false)
    }

    private func flushBuffer() {
        guard !inputBuffer.isEmpty else { return }
        itemCount += 1
        let item = inputBuffer
        let count = itemCount
        try? noteWriterProvider().appendItem(item, number: count)
        inputBuffer = ""
    }

    private func setupEventTap() {
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: globalKeyboardCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
        ) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.showAccessibilityAlert()
            }
            return
        }

        self.eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "QuickNote needs Accessibility permission to monitor keyboard input.\n\nPlease go to System Settings → Privacy & Security → Accessibility and enable QuickNote, then restart the app."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
        NSApp.terminate(nil)
    }

    func handleEvent(type: CGEventType, event: CGEvent) -> CGEvent? {
        guard type == .keyDown else { return event }

        let flags = event.flags
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        let cmdDown = flags.contains(.maskCommand)
        let shiftDown = flags.contains(.maskShift)

        // Cmd+Shift+D — append selected text (only when not listening)
        if cmdDown && shiftDown && keyCode == kVK_D {
            if !isListening {
                DispatchQueue.main.async { [weak self] in
                    let text = TextSelectionCapture().getSelectedText() ?? ""
                    if !text.isEmpty {
                        try? self?.noteWriterProvider().appendSelectedText(text)
                    }
                }
            }
            return nil // consume event
        }

        // Cmd+D — toggle listening
        if cmdDown && !shiftDown && keyCode == kVK_D {
            DispatchQueue.main.async { [weak self] in
                self?.toggle()
            }
            return nil // consume event
        }

        // Only process further when listening
        guard isListening else { return event }

        // Skip events with Command modifier (system shortcuts like Cmd+C, etc.)
        if cmdDown { return event }

        switch keyCode {
        case kVK_Return:
            if !inputBuffer.isEmpty {
                let item = inputBuffer
                itemCount += 1
                let count = itemCount
                inputBuffer = ""
                DispatchQueue.main.async { [weak self] in
                    try? self?.noteWriterProvider().appendItem(item, number: count)
                }
            }
        case kVK_Delete:
            if !inputBuffer.isEmpty {
                inputBuffer.removeLast()
            }
        case kVK_Escape:
            inputBuffer = ""
        default:
            var actualLength = 0
            var chars = [UniChar](repeating: 0, count: 4)
            event.keyboardGetUnicodeString(
                maxStringLength: 4,
                actualStringLength: &actualLength,
                unicodeString: &chars
            )
            if actualLength > 0 {
                let str = String(utf16CodeUnits: chars, count: actualLength)
                // Only add printable characters (value >= 32, not DEL=127)
                if let scalar = str.unicodeScalars.first,
                   scalar.value >= 32,
                   scalar.value != 127 {
                    inputBuffer += str
                }
            }
        }

        return event // pass all other events through
    }

    deinit {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
    }
}

// Must be a free function (C function pointer) — cannot capture context
private func globalKeyboardCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo = userInfo else { return Unmanaged.passRetained(event) }
    let monitor = Unmanaged<KeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()
    if let result = monitor.handleEvent(type: type, event: event) {
        return Unmanaged.passRetained(result)
    }
    return nil
}
