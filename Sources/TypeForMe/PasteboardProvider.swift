import AppKit
import TypeForMeCore

enum PasteboardError: Error {
    case unableToReadPasteboard
    case unableToWritePasteboard
}

class PasteboardProvider: PasteboardProviding {
    private let pasteboard = NSPasteboard.general
    
    func readString() throws -> String? {
        return pasteboard.string(forType: .string)
    }
    
    func writeString(_ string: String) throws {
        pasteboard.clearContents()
        let success = pasteboard.setString(string, forType: .string)
        if !success {
            throw PasteboardError.unableToWritePasteboard
        }
    }
    
    func restoreString(_ string: String?) throws {
        pasteboard.clearContents()
        if let string = string {
            let success = pasteboard.setString(string, forType: .string)
            if !success {
                throw PasteboardError.unableToWritePasteboard
            }
        }
    }
}
