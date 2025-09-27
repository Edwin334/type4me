import Foundation

public final class TypeForMeController {
    private let permissionChecker: PermissionChecking
    private let accessibilityProvider: AccessibilityProviding
    private let screenshotCapturer: ScreenshotCapturing
    private let promptBuilder: PromptBuilding
    private let geminiClient: GeminiClientProtocol
    private let textInserter: TextInserting
    private let hud: HUDPresenting
    private let logger: Logger?
    private let feedback: FeedbackNotifying?
    private let styleStore: StylePreferenceStoreProtocol
    private let capturePadding: Double

    public init(
        permissionChecker: PermissionChecking,
        accessibilityProvider: AccessibilityProviding,
        screenshotCapturer: ScreenshotCapturing,
        promptBuilder: PromptBuilding,
        geminiClient: GeminiClientProtocol,
        textInserter: TextInserting,
        hud: HUDPresenting,
        styleStore: StylePreferenceStoreProtocol,
        logger: Logger? = nil,
        feedback: FeedbackNotifying? = nil,
        capturePadding: Double = 200
    ) {
        self.permissionChecker = permissionChecker
        self.accessibilityProvider = accessibilityProvider
        self.screenshotCapturer = screenshotCapturer
        self.promptBuilder = promptBuilder
        self.geminiClient = geminiClient
        self.textInserter = textInserter
        self.hud = hud
        self.styleStore = styleStore
        self.logger = logger
        self.feedback = feedback
        self.capturePadding = capturePadding
    }

    public func handleHotkeyInvocation() async {
        guard permissionChecker.hasRequiredPermissions() else {
            logger?.info("Requesting permissions")
            permissionChecker.promptForMissingPermissions()
            return
        }

        do {
            let context = try accessibilityProvider.focusedContext()
            guard !context.isSecure else {
                logger?.info("Secure field detected; aborting invocation")
                hud.show(status: .unavailable("Unavailable in secure field"))
                hud.hide()
                return
            }

            let style = try styleStore.load()
            let mode = context.mode
            let captureRect = context.captureRect(padding: capturePadding)
            let screenshot = try screenshotCapturer.captureActiveWindow(region: captureRect)
            let prompt = try promptBuilder.makePrompt(mode: mode, selection: context.selection, style: style)

            hud.show(status: mode == .edit ? .rewriting : .drafting)
            let response = try await geminiClient.generateText(prompt: prompt, screenshot: screenshot)
            hud.hide()

            let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                logger?.info("Received empty response from Gemini")
                feedback?.notifyUserFailure()
                return
            }

            try textInserter.insert(text: trimmed, replaceSelection: mode == .edit)
            logger?.info("Inserted generated text")
        } catch {
            hud.hide()
            logger?.error("Invocation failed: \(error)")
            feedback?.notifyUserFailure()
        }
    }
}
