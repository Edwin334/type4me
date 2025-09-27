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
        let previous = try pasteboard.readString()
        var pasteError: Error?
        do {
            try pasteboard.writeString(text)
            try pastePerformer.performPaste(replacingSelection: replaceSelection)
        } catch {
            pasteError = error
        }

        do {
            try pasteboard.restoreString(previous)
        } catch {
            // Best-effort restoration; loggable by caller but not fatal for insertion success.
        }

        if pasteError == nil {
            return
        }

        do {
            try pastePerformer.type(text: text)
        } catch {
            throw InsertionError.typingFailed
        }
    }
}
