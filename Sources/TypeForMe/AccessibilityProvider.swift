import AppKit
import ApplicationServices
import TypeForMeCore

enum AccessibilityError: Error {
    case noFocusedElement
    case unableToReadElementProperties
    case unableToGetActiveWindow
}

class AccessibilityProvider: AccessibilityProviding {
    
    func focusedContext() throws -> FocusedElementContext {
        // Check if we have accessibility permissions first
        guard AXIsProcessTrusted() else {
            throw AccessibilityError.unableToReadElementProperties
        }
        
        // Get the focused element
        guard let focusedElement = getFocusedElement() else {
            throw AccessibilityError.noFocusedElement
        }
        
        // Get selection text
        let selection = getSelectedText(from: focusedElement)
        
        // Get element bounds
        let elementBounds = getElementBounds(focusedElement) ?? Rect.zero
        
        // Get caret bounds if available
        let caretBounds = getCaretBounds(from: focusedElement)
        
        // Get window bounds
        let windowBounds = getActiveWindowBounds() ?? elementBounds
        
        // Check if field is secure
        let isSecure = isSecureField(focusedElement)
        
        return FocusedElementContext(
            selection: selection,
            caretBounds: caretBounds,
            elementBounds: elementBounds,
            windowBounds: windowBounds,
            isSecure: isSecure
        )
    }
    
    private func getFocusedElement() -> AXUIElement? {
        // Get the focused application
        guard let focusedApp = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let appElement = AXUIElementCreateApplication(focusedApp.processIdentifier)
        
        // Get the focused UI element
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result == .success, let element = focusedElement {
            return (element as! AXUIElement)
        }
        
        return nil
    }
    
    private func getSelectedText(from element: AXUIElement) -> String? {
        var selectedText: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if result == .success, let text = selectedText as? String, !text.isEmpty {
            return text
        }
        
        return nil
    }
    
    private func getElementBounds(_ element: AXUIElement) -> Rect? {
        var position: CFTypeRef?
        var size: CFTypeRef?
        
        let positionResult = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &position)
        let sizeResult = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &size)
        
        guard positionResult == .success, sizeResult == .success,
              let positionValue = position, let sizeValue = size else {
            return nil
        }
        
        var point = CGPoint.zero
        var sizeStruct = CGSize.zero
        
        if AXValueGetValue(positionValue as! AXValue, .cgPoint, &point) &&
           AXValueGetValue(sizeValue as! AXValue, .cgSize, &sizeStruct) {
            return Rect(x: point.x, y: point.y, width: sizeStruct.width, height: sizeStruct.height)
        }
        
        return nil
    }
    
    private func getCaretBounds(from element: AXUIElement) -> Rect? {
        // Try to get selected text range first
        var selectedRange: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedRange)
        
        if rangeResult == .success, let range = selectedRange {
            // Get bounds for the range
            var bounds: CFTypeRef?
            let boundsResult = AXUIElementCopyParameterizedAttributeValue(
                element,
                kAXBoundsForRangeParameterizedAttribute as CFString,
                range,
                &bounds
            )
            
            if boundsResult == .success, let boundsValue = bounds {
                var rect = CGRect.zero
                if AXValueGetValue(boundsValue as! AXValue, .cgRect, &rect) {
                    return Rect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
                }
            }
        }
        
        return nil
    }
    
    private func getActiveWindowBounds() -> Rect? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let appElement = AXUIElementCreateApplication(frontmostApp.processIdentifier)
        
        // Get focused window
        var focusedWindow: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        if result == .success, let window = focusedWindow {
            return getElementBounds(window as! AXUIElement)
        }
        
        return nil
    }
    
    private func isSecureField(_ element: AXUIElement) -> Bool {
        // Check if the element has secure text entry
        var roleDescription: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(element, kAXRoleDescriptionAttribute as CFString, &roleDescription)
        
        if result == .success, let description = roleDescription as? String {
            return description.lowercased().contains("secure") || description.lowercased().contains("password")
        }
        
        // Also check role
        var role: CFTypeRef?
        let roleResult = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        if roleResult == .success, let roleString = role as? String {
            return roleString.contains("secure") || roleString.contains("password")
        }
        
        return false
    }
}
