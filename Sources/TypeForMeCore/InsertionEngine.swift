import Foundation

public enum InsertionError: Error, Equatable {
    case typingFailed
}

public final class InsertionEngine: TextInserting {
    private let pasteboard: PasteboardProviding
    private let pastePerformer: PasteCommandPerforming

    public init(pasteboard: PasteboardProviding, pastePerformer: PasteCommandPerforming) {
        self.pasteboard = pasteboard
        self.pastePerformer = pastePerformer
    }

    public func insert(text: String, replaceSelection: Bool) throws {
        print("DEBUG: Inserting text: '\(text)'")
        let previous = try pasteboard.readString()
        print("DEBUG: Previous pasteboard content: '\(previous ?? "nil")'")
        var pasteError: Error?
        do {
            try pasteboard.writeString(text)
            
            // Verify the pasteboard was updated
            let verification = try pasteboard.readString()
            print("DEBUG: Pasteboard after write: '\(verification ?? "nil")'")
            
            // Longer delay to ensure pasteboard is ready and application has processed hotkey
            usleep(100000) // 100ms delay
            
            print("DEBUG: About to send paste command...")
            try pastePerformer.performPaste(replacingSelection: replaceSelection)
            print("DEBUG: Paste command sent successfully")
            
            // Wait for the paste to actually happen before restoring pasteboard
            print("DEBUG: Waiting for paste to complete...")
            usleep(500000) // 500ms delay to let paste complete
            print("DEBUG: Paste should be complete now")
            
        } catch {
            print("DEBUG: Paste failed: \(error)")
            pasteError = error
        }

        do {
            print("DEBUG: Restoring original pasteboard content...")
            try pasteboard.restoreString(previous)
            print("DEBUG: Pasteboard restored successfully")
        } catch {
            print("DEBUG: Failed to restore pasteboard: \(error)")
            // Best-effort restoration; loggable by caller but not fatal for insertion success.
        }

        if pasteError == nil {
            return
        }

        do {
            try pastePerformer.type(text: text)
            print("DEBUG: Typing fallback successful")
        } catch {
            print("DEBUG: Typing fallback failed: \(error)")
            throw InsertionError.typingFailed
        }
    }
}
