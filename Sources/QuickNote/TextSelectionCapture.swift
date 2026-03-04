import AppKit

struct TextSelectionCapture {
    func getSelectedText() -> String? {
        let systemElement = AXUIElementCreateSystemWide()

        var focusedElement: CFTypeRef?
        let focusResult = AXUIElementCopyAttributeValue(
            systemElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        guard focusResult == .success, let element = focusedElement else { return nil }

        var selectedText: CFTypeRef?
        let textResult = AXUIElementCopyAttributeValue(
            element as! AXUIElement,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        guard textResult == .success else { return nil }
        return selectedText as? String
    }
}
