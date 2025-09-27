import XCTest
@testable import TypeForMeCore

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

final class TypeForMeControllerTests: XCTestCase {
    func testPromptsForPermissionsWhenMissing() async {
        let permission = MockPermissionChecker()
        permission.hasPermission = false
        let controller = TypeForMeController(
            permissionChecker: permission,
            accessibilityProvider: MockAccessibilityProvider(),
            screenshotCapturer: MockScreenshotCapturer(),
            promptBuilder: MockPromptBuilder(),
            geminiClient: MockGeminiClient(),
            textInserter: MockTextInserter(),
            hud: MockHUD(),
            styleStore: StylePreferenceStore(fileManager: .default, url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)),
            logger: MockLogger(),
            feedback: MockFeedback()
        )

        await controller.handleHotkeyInvocation()

        XCTAssertEqual(permission.promptCallCount, 1)
    }

    func testSecureFieldSkipsInvocation() async {
        let permission = MockPermissionChecker()
        let accessibility = MockAccessibilityProvider()
        accessibility.context = FocusedElementContext(
            selection: nil,
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: true
        )
        let hud = MockHUD()
        let gemini = MockGeminiClient()
        let controller = TypeForMeController(
            permissionChecker: permission,
            accessibilityProvider: accessibility,
            screenshotCapturer: MockScreenshotCapturer(),
            promptBuilder: MockPromptBuilder(),
            geminiClient: gemini,
            textInserter: MockTextInserter(),
            hud: hud,
            styleStore: StylePreferenceStore(fileManager: .default, url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)),
            logger: MockLogger(),
            feedback: MockFeedback()
        )

        await controller.handleHotkeyInvocation()

        XCTAssertEqual(gemini.calls, 0)
        XCTAssertEqual(hud.statuses, [.unavailable("Unavailable in secure field")])
        XCTAssertEqual(hud.hideCallCount, 1)
    }

    func testAutowriteFlowInsertsText() async throws {
        let permission = MockPermissionChecker()
        let accessibility = MockAccessibilityProvider()
        accessibility.context = FocusedElementContext(
            selection: nil,
            caretBounds: Rect(x: 100, y: 100, width: 5, height: 20),
            elementBounds: Rect(x: 0, y: 0, width: 200, height: 40),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )
        let screenshotter = MockScreenshotCapturer()
        let promptBuilder = MockPromptBuilder()
        let gemini = MockGeminiClient()
        gemini.result = .success("  Draft text  ")
        let inserter = MockTextInserter()
        let hud = MockHUD()
        let logger = MockLogger()
        let styleURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("style.json")
        let styleStore = StylePreferenceStore(fileManager: .default, url: styleURL)
        try styleStore.save(StylePreferences(tone: .warm, brevity: .medium))
        let controller = TypeForMeController(
            permissionChecker: permission,
            accessibilityProvider: accessibility,
            screenshotCapturer: screenshotter,
            promptBuilder: promptBuilder,
            geminiClient: gemini,
            textInserter: inserter,
            hud: hud,
            styleStore: styleStore,
            logger: logger,
            feedback: MockFeedback()
        )

        await controller.handleHotkeyInvocation()

        XCTAssertEqual(promptBuilder.modes, [.autowrite])
        if case .some(let selection) = promptBuilder.selections.first {
            XCTAssertNil(selection)
        } else {
            XCTFail("Selection should have been captured")
        }
        XCTAssertEqual(gemini.calls, 1)
        XCTAssertEqual(inserter.insertedTexts.first?.0, "Draft text")
        XCTAssertEqual(inserter.insertedTexts.first?.1, false)
        XCTAssertEqual(hud.statuses, [.drafting])
        XCTAssertEqual(hud.hideCallCount, 1)
        XCTAssertTrue(logger.infos.contains { $0.contains("Inserted generated text") })
    }

    func testEmptyResponseNotifiesFeedback() async {
        let permission = MockPermissionChecker()
        let accessibility = MockAccessibilityProvider()
        accessibility.context = FocusedElementContext(
            selection: "Selected",
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 800, height: 600),
            isSecure: false
        )
        let gemini = MockGeminiClient()
        gemini.result = .success("   ")
        let inserter = MockTextInserter()
        let feedback = MockFeedback()
        let hud = MockHUD()
        let controller = TypeForMeController(
            permissionChecker: permission,
            accessibilityProvider: accessibility,
            screenshotCapturer: MockScreenshotCapturer(),
            promptBuilder: MockPromptBuilder(),
            geminiClient: gemini,
            textInserter: inserter,
            hud: hud,
            styleStore: StylePreferenceStore(fileManager: .default, url: FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)),
            logger: MockLogger(),
            feedback: feedback
        )

        await controller.handleHotkeyInvocation()

        XCTAssertTrue(inserter.insertedTexts.isEmpty)
        XCTAssertEqual(feedback.calls, 1)
        XCTAssertEqual(hud.hideCallCount, 1)
    }
}
