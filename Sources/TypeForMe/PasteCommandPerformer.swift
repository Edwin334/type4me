import AppKit
import ApplicationServices
import Carbon
import TypeForMeCore

enum PasteCommandError: Error {
    case unableToSendPasteCommand
    case unableToSendKeyEvents
}

class PasteCommandPerformer: PasteCommandPerforming {
    
    func performPaste(replacingSelection: Bool) throws {
        // Ensure we're not in a restricted context
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            throw PasteCommandError.unableToSendPasteCommand
        }
        
        print("DEBUG: Sending paste command to app: \(frontmostApp.localizedName ?? "unknown")")
        
        // Send Cmd+V to paste
        try sendKeyCommand(keyCode: CGKeyCode(kVK_ANSI_V), modifiers: [.command])
        
        print("DEBUG: Paste key events posted successfully")
    }
    
    func type(text: String) throws {
        // Type each character individually using Core Graphics events
        for character in text {
            try typeCharacter(character)
        }
    }
    
    private func sendKeyCommand(keyCode: CGKeyCode, modifiers: NSEvent.ModifierFlags) throws {
        let flags = modifiers.cgEventFlags
        
        // Create event source
        let eventSource = CGEventSource(stateID: .hidSystemState)
        
        // Create key down event
        guard let keyDownEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true) else {
            throw PasteCommandError.unableToSendPasteCommand
        }
        keyDownEvent.flags = flags
        
        // Create key up event
        guard let keyUpEvent = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false) else {
            throw PasteCommandError.unableToSendPasteCommand
        }
        keyUpEvent.flags = flags
        
        // Post events with error checking
        keyDownEvent.post(tap: .cghidEventTap)
        // Add small delay between key down and up
        usleep(1000) // 1ms delay
        keyUpEvent.post(tap: .cghidEventTap)
    }
    
    private func typeCharacter(_ character: Character) throws {
        
        // Convert character to key events
        // This is a simplified approach - a full implementation would handle
        // special characters, international keyboards, etc.
        guard let keyCode = keyCodeForCharacter(character) else {
            return // Skip unsupported characters
        }
        
        let flags: NSEvent.ModifierFlags = character.isUppercase ? [.shift] : []
        
        try sendKeyCommand(keyCode: keyCode, modifiers: flags)
    }
    
    private func keyCodeForCharacter(_ character: Character) -> CGKeyCode? {
        // Map common characters to virtual key codes
        // This is a basic implementation - real apps would use more sophisticated mapping
        switch character.lowercased().first {
        case "a": return CGKeyCode(kVK_ANSI_A)
        case "b": return CGKeyCode(kVK_ANSI_B)
        case "c": return CGKeyCode(kVK_ANSI_C)
        case "d": return CGKeyCode(kVK_ANSI_D)
        case "e": return CGKeyCode(kVK_ANSI_E)
        case "f": return CGKeyCode(kVK_ANSI_F)
        case "g": return CGKeyCode(kVK_ANSI_G)
        case "h": return CGKeyCode(kVK_ANSI_H)
        case "i": return CGKeyCode(kVK_ANSI_I)
        case "j": return CGKeyCode(kVK_ANSI_J)
        case "k": return CGKeyCode(kVK_ANSI_K)
        case "l": return CGKeyCode(kVK_ANSI_L)
        case "m": return CGKeyCode(kVK_ANSI_M)
        case "n": return CGKeyCode(kVK_ANSI_N)
        case "o": return CGKeyCode(kVK_ANSI_O)
        case "p": return CGKeyCode(kVK_ANSI_P)
        case "q": return CGKeyCode(kVK_ANSI_Q)
        case "r": return CGKeyCode(kVK_ANSI_R)
        case "s": return CGKeyCode(kVK_ANSI_S)
        case "t": return CGKeyCode(kVK_ANSI_T)
        case "u": return CGKeyCode(kVK_ANSI_U)
        case "v": return CGKeyCode(kVK_ANSI_V)
        case "w": return CGKeyCode(kVK_ANSI_W)
        case "x": return CGKeyCode(kVK_ANSI_X)
        case "y": return CGKeyCode(kVK_ANSI_Y)
        case "z": return CGKeyCode(kVK_ANSI_Z)
        case "0": return CGKeyCode(kVK_ANSI_0)
        case "1": return CGKeyCode(kVK_ANSI_1)
        case "2": return CGKeyCode(kVK_ANSI_2)
        case "3": return CGKeyCode(kVK_ANSI_3)
        case "4": return CGKeyCode(kVK_ANSI_4)
        case "5": return CGKeyCode(kVK_ANSI_5)
        case "6": return CGKeyCode(kVK_ANSI_6)
        case "7": return CGKeyCode(kVK_ANSI_7)
        case "8": return CGKeyCode(kVK_ANSI_8)
        case "9": return CGKeyCode(kVK_ANSI_9)
        case " ": return CGKeyCode(kVK_Space)
        case "\n": return CGKeyCode(kVK_Return)
        case "\t": return CGKeyCode(kVK_Tab)
        case ".": return CGKeyCode(kVK_ANSI_Period)
        case ",": return CGKeyCode(kVK_ANSI_Comma)
        case ";": return CGKeyCode(kVK_ANSI_Semicolon)
        case "'": return CGKeyCode(kVK_ANSI_Quote)
        case "/": return CGKeyCode(kVK_ANSI_Slash)
        case "\\": return CGKeyCode(kVK_ANSI_Backslash)
        case "[": return CGKeyCode(kVK_ANSI_LeftBracket)
        case "]": return CGKeyCode(kVK_ANSI_RightBracket)
        case "-": return CGKeyCode(kVK_ANSI_Minus)
        case "=": return CGKeyCode(kVK_ANSI_Equal)
        default: return nil
        }
    }
}

extension NSEvent.ModifierFlags {
    var cgEventFlags: CGEventFlags {
        var flags = CGEventFlags()
        
        if contains(.command) { flags.insert(.maskCommand) }
        if contains(.option) { flags.insert(.maskAlternate) }
        if contains(.control) { flags.insert(.maskControl) }
        if contains(.shift) { flags.insert(.maskShift) }
        if contains(.function) { flags.insert(.maskSecondaryFn) }
        
        return flags
    }
}
