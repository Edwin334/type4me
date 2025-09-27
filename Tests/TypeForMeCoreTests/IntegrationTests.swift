import XCTest
@testable import TypeForMe
@testable import TypeForMeCore

final class IntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Set test API key
        UserDefaults.standard.set("test-api-key", forKey: "GEMINI_API_KEY")
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "GEMINI_API_KEY")
        super.tearDown()
    }
    
    func testCompleteAutowriteWorkflow() async {
        // Create a complete mock workflow
        let permissionChecker = MockPermissionChecker()
        let accessibilityProvider = MockAccessibilityProvider()
        let screenshotCapturer = MockScreenshotCapturer()
        let promptBuilder = MockPromptBuilder()
        let geminiClient = MockGeminiClient()
        let textInserter = MockTextInserter()
        let hud = MockHUD()
        let styleStore = StylePreferenceStore(
            fileManager: .default,
            url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        )
        let logger = MockLogger()
        let feedback = MockFeedback()
        
        // Set up successful scenario
        permissionChecker.hasPermission = true
        accessibilityProvider.context = FocusedElementContext(
            selection: nil, // No selection = autowrite mode
            caretBounds: Rect(x: 100, y: 100, width: 2, height: 20),
            elementBounds: Rect(x: 0, y: 0, width: 300, height: 40),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )
        geminiClient.result = .success("Generated autowrite text")
        
        let controller = TypeForMeController(
            permissionChecker: permissionChecker,
            accessibilityProvider: accessibilityProvider,
            screenshotCapturer: screenshotCapturer,
            promptBuilder: promptBuilder,
            geminiClient: geminiClient,
            textInserter: textInserter,
            hud: hud,
            styleStore: styleStore,
            logger: logger,
            feedback: feedback
        )
        
        await controller.handleHotkeyInvocation()
        
        // Verify the complete workflow
        XCTAssertEqual(permissionChecker.promptCallCount, 0) // Permissions were available
        XCTAssertEqual(screenshotCapturer.captureRegions.count, 1) // Screenshot was captured
        XCTAssertEqual(promptBuilder.modes, [.autowrite]) // Correct mode used
        XCTAssertEqual(geminiClient.calls, 1) // Gemini was called
        XCTAssertEqual(textInserter.insertedTexts.count, 1) // Text was inserted
        XCTAssertEqual(textInserter.insertedTexts.first?.0, "Generated autowrite text")
        XCTAssertEqual(textInserter.insertedTexts.first?.1, false) // Not replacing selection
        XCTAssertEqual(hud.statuses, [.drafting]) // Correct HUD status
        XCTAssertEqual(hud.hideCallCount, 1) // HUD was hidden
        XCTAssertEqual(feedback.calls, 0) // No failure feedback
    }
    
    func testCompleteEditWorkflow() async {
        let permissionChecker = MockPermissionChecker()
        let accessibilityProvider = MockAccessibilityProvider()
        let screenshotCapturer = MockScreenshotCapturer()
        let promptBuilder = MockPromptBuilder()
        let geminiClient = MockGeminiClient()
        let textInserter = MockTextInserter()
        let hud = MockHUD()
        let styleStore = StylePreferenceStore(
            fileManager: .default,
            url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        )
        
        // Set up edit scenario
        permissionChecker.hasPermission = true
        accessibilityProvider.context = FocusedElementContext(
            selection: "Original text to edit", // Selection present = edit mode
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 300, height: 40),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )
        geminiClient.result = .success("Edited and improved text")
        
        let controller = TypeForMeController(
            permissionChecker: permissionChecker,
            accessibilityProvider: accessibilityProvider,
            screenshotCapturer: screenshotCapturer,
            promptBuilder: promptBuilder,
            geminiClient: geminiClient,
            textInserter: textInserter,
            hud: hud,
            styleStore: styleStore,
            logger: MockLogger(),
            feedback: MockFeedback()
        )
        
        await controller.handleHotkeyInvocation()
        
        // Verify edit workflow
        XCTAssertEqual(promptBuilder.modes, [.edit])
        XCTAssertEqual(promptBuilder.selections.first as? String, "Original text to edit")
        XCTAssertEqual(textInserter.insertedTexts.first?.0, "Edited and improved text")
        XCTAssertEqual(textInserter.insertedTexts.first?.1, true) // Replacing selection
        XCTAssertEqual(hud.statuses, [.rewriting])
    }
    
    func testErrorHandlingWorkflow() async {
        let permissionChecker = MockPermissionChecker()
        let accessibilityProvider = MockAccessibilityProvider()
        let geminiClient = MockGeminiClient()
        let feedback = MockFeedback()
        let hud = MockHUD()
        
        // Set up error scenario
        permissionChecker.hasPermission = true
        accessibilityProvider.context = FocusedElementContext(
            selection: nil,
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 800, height: 600),
            isSecure: false
        )
        geminiClient.result = .failure(MockGeminiClient.MockError.failure)
        
        let controller = TypeForMeController(
            permissionChecker: permissionChecker,
            accessibilityProvider: accessibilityProvider,
            screenshotCapturer: MockScreenshotCapturer(),
            promptBuilder: MockPromptBuilder(),
            geminiClient: geminiClient,
            textInserter: MockTextInserter(),
            hud: hud,
            styleStore: StylePreferenceStore(
                fileManager: .default,
                url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            ),
            logger: MockLogger(),
            feedback: feedback
        )
        
        await controller.handleHotkeyInvocation()
        
        // Verify error handling
        XCTAssertEqual(feedback.calls, 1) // Failure was reported
        XCTAssertEqual(hud.hideCallCount, 1) // HUD was hidden even on error
    }
    
    func testSecureFieldWorkflow() async {
        let permissionChecker = MockPermissionChecker()
        let accessibilityProvider = MockAccessibilityProvider()
        let geminiClient = MockGeminiClient()
        let hud = MockHUD()
        
        // Set up secure field scenario
        permissionChecker.hasPermission = true
        accessibilityProvider.context = FocusedElementContext(
            selection: nil,
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 800, height: 600),
            isSecure: true // Secure field
        )
        
        let controller = TypeForMeController(
            permissionChecker: permissionChecker,
            accessibilityProvider: accessibilityProvider,
            screenshotCapturer: MockScreenshotCapturer(),
            promptBuilder: MockPromptBuilder(),
            geminiClient: geminiClient,
            textInserter: MockTextInserter(),
            hud: hud,
            styleStore: StylePreferenceStore(
                fileManager: .default,
                url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            ),
            logger: MockLogger(),
            feedback: MockFeedback()
        )
        
        await controller.handleHotkeyInvocation()
        
        // Verify secure field handling
        XCTAssertEqual(geminiClient.calls, 0) // Gemini should not be called
        XCTAssertEqual(hud.statuses, [.unavailable("Unavailable in secure field")])
        XCTAssertEqual(hud.hideCallCount, 1)
    }
}

// MARK: - Mock classes for integration tests

private final class MockPermissionChecker: PermissionChecking {
    var hasPermission = true
    private(set) var promptCallCount = 0

    func hasRequiredPermissions() -> Bool { hasPermission }
    func promptForMissingPermissions() { promptCallCount += 1 }
}

private final class MockAccessibilityProvider: AccessibilityProviding {
    var context: FocusedElementContext?
    var error: Error?

    func focusedContext() throws -> FocusedElementContext {
        if let error {
            throw error
        }
        return context ?? FocusedElementContext(
            selection: nil,
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 1000, height: 700),
            isSecure: false
        )
    }
}

private final class MockScreenshotCapturer: ScreenshotCapturing {
    private(set) var captureRegions: [Rect] = []
    var screenshot = Screenshot(data: Data([0x00]), format: .jpeg, originalRect: Rect(x: 0, y: 0, width: 1, height: 1))

    func captureActiveWindow(region: Rect) throws -> Screenshot {
        captureRegions.append(region)
        return screenshot
    }
}

private final class MockPromptBuilder: PromptBuilding {
    private(set) var modes: [InteractionMode] = []
    private(set) var selections: [String?] = []
    var payload = PromptPayload(systemInstruction: "test", json: Data("{}".utf8))

    func makePrompt(mode: InteractionMode, selection: String?, style: StylePreferences) throws -> PromptPayload {
        modes.append(mode)
        selections.append(selection)
        return payload
    }
}

private final class MockGeminiClient: GeminiClientProtocol {
    enum MockError: Error { case failure }
    var result: Result<String, Error> = .success("Generated text")
    private(set) var calls: Int = 0

    func generateText(prompt: PromptPayload, screenshot: Screenshot) async throws -> String {
        calls += 1
        return try result.get()
    }
}

private final class MockTextInserter: TextInserting {
    private(set) var insertedTexts: [(String, Bool)] = []

    func insert(text: String, replaceSelection: Bool) throws {
        insertedTexts.append((text, replaceSelection))
    }
}

private final class MockHUD: HUDPresenting {
    private(set) var statuses: [HUDStatus] = []
    private(set) var hideCallCount = 0

    func show(status: HUDStatus) {
        statuses.append(status)
    }

    func hide() {
        hideCallCount += 1
    }
}

private final class MockLogger: Logger {
    private(set) var infos: [String] = []
    private(set) var errors: [String] = []

    func info(_ message: String) { infos.append(message) }
    func error(_ message: String) { errors.append(message) }
}

private final class MockFeedback: FeedbackNotifying {
    private(set) var calls = 0
    func notifyUserFailure() { calls += 1 }
}
