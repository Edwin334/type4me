import Foundation

public protocol PermissionChecking {
    func hasRequiredPermissions() -> Bool
    func promptForMissingPermissions()
}

public protocol AccessibilityProviding {
    func focusedContext() throws -> FocusedElementContext
}

public protocol ScreenshotCapturing {
    func captureActiveWindow(region: Rect) throws -> Screenshot
}

public protocol PromptBuilding {
    func makePrompt(mode: InteractionMode, selection: String?, style: StylePreferences) throws -> PromptPayload
}

public protocol GeminiClientProtocol: Sendable {
    func generateText(prompt: PromptPayload, screenshot: Screenshot) async throws -> String
}

public protocol TextInserting {
    func insert(text: String, replaceSelection: Bool) throws
}

public protocol PasteboardProviding {
    func readString() throws -> String?
    func writeString(_ string: String) throws
    func restoreString(_ string: String?) throws
}

public protocol PasteCommandPerforming {
    func performPaste(replacingSelection: Bool) throws
    func type(text: String) throws
}

@MainActor
public protocol HUDPresenting {
    func show(status: HUDStatus)
    func hide()
}

public protocol Logger {
    func info(_ message: String)
    func error(_ message: String)
}

public enum HUDStatus: Equatable {
    case drafting
    case rewriting
    case unavailable(String)
}

public protocol FeedbackNotifying {
    func notifyUserFailure()
}
