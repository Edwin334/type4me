import Foundation

public final class TypeForMeController: @unchecked Sendable {
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

    private var isProcessing = false
    
    @MainActor public func handleHotkeyInvocation() async {
        // Prevent multiple simultaneous invocations
        guard !isProcessing else {
            print("DEBUG: Already processing, ignoring hotkey")
            return
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        print("DEBUG: Starting hotkey invocation")
        logger?.info("Handling hotkey invocation...")
        guard permissionChecker.hasRequiredPermissions() else {
            logger?.info("Requesting permissions")
            permissionChecker.promptForMissingPermissions()
            return
        }

        do {
            logger?.info("Getting focused context...")
            let context = try accessibilityProvider.focusedContext()
            logger?.info("Successfully got focused context.")
            guard !context.isSecure else {
                logger?.info("Secure field detected; aborting invocation")
                hud.show(status: .unavailable("Unavailable in secure field"))
                hud.hide()
                return
            }

            let style = try styleStore.load()
            let mode = context.mode
            
            // For now, always capture the full window for better context
            let captureRect = context.windowBounds
            print("DEBUG: Capture rect: \(captureRect)")
            
            logger?.info("Capturing screenshot...")
            let screenshot = try screenshotCapturer.captureActiveWindow(region: captureRect)
            logger?.info("Successfully captured screenshot.")
            
            // Debug: Save screenshot locally to see what we're sending
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileExtension = screenshot.format == .jpeg ? "jpg" : "png"
            let screenshotPath = documentsPath.appendingPathComponent("debug_screenshot.\(fileExtension)")
            try screenshot.data.write(to: screenshotPath)
            print("DEBUG: Screenshot saved to: \(screenshotPath.path)")
            
            let prompt = try promptBuilder.makePrompt(mode: mode, selection: context.selection, style: style)
            
            // Debug: Log the prompt being sent
            print("DEBUG: Mode: \(mode)")
            print("DEBUG: Selection: \(context.selection ?? "none")")
            print("DEBUG: System instruction: \(prompt.systemInstruction)")
            print("DEBUG: JSON payload: \(String(data: prompt.json, encoding: .utf8) ?? "invalid")")

            hud.show(status: mode == .edit ? .rewriting : .drafting)
            logger?.info("Generating text from Gemini...")
            let response = try await geminiClient.generateText(prompt: prompt, screenshot: screenshot)
            logger?.info("Successfully generated text from Gemini.")
            
            // Debug: Log the response from Gemini
            print("DEBUG: Gemini response: '\(response)'")
            hud.hide()

            let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                logger?.info("Received empty response from Gemini")
                feedback?.notifyUserFailure()
                return
            }

            logger?.info("Inserting text...")
            try textInserter.insert(text: trimmed, replaceSelection: mode == .edit)
            logger?.info("Inserted generated text")
        } catch {
            hud.hide()
            logger?.error("Invocation failed: \(error)")
            feedback?.notifyUserFailure()
        }
    }
}
