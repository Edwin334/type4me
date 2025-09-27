import AppKit
import TypeForMeCore
import GoogleGenerativeAI
import ApplicationServices
import Carbon

class TypeForMeManager {
    private let controller: TypeForMeController
    private let hotKeyManager: HotKeyManager
    private let permissionManager: PermissionChecker
    private var settingsWindowController: SimpleSettingsWindowController?
    private var isPausedInternal = false
    
    var isPaused: Bool { isPausedInternal }
    
    init() {
        // Initialize dependencies
        let permissionChecker = PermissionChecker()
        let accessibilityProvider = AccessibilityProvider()
        let screenshotCapturer = ScreenshotCapturer()

        let promptBuilder = PromptBuilder()
        
        // Try to initialize GeminiClient, use placeholder if no API key
        let geminiClient: GeminiClientProtocol
        do {
            geminiClient = try GeminiClient()
        } catch {
            // Use a placeholder client that shows helpful error messages
            geminiClient = PlaceholderGeminiClient()
        }
        
        let pasteboardProvider = PasteboardProvider()
        let pasteCommandPerformer = PasteCommandPerformer()
        let textInserter = InsertionEngine(pasteboard: pasteboardProvider, pastePerformer: pasteCommandPerformer)
        let hud = HUDManager()
        let styleStore = StylePreferenceStore()
        let logger = OSLogger()
        let feedback = FeedbackManager()
        
        // Create controller
        self.controller = TypeForMeController(
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
        
        self.hotKeyManager = HotKeyManager()
        self.permissionManager = PermissionChecker()
        
        // Don't initialize settings window controller until needed
        
        setupHotKey()
    }
    
    func start() {
        hotKeyManager.enable()
    }
    
    func stop() {
        hotKeyManager.disable()
    }
    
    func pause() {
        isPausedInternal = true
        hotKeyManager.disable()
    }
    
    func resume() {
        isPausedInternal = false
        hotKeyManager.enable()
    }
    
    @MainActor func showSettings() {
        // Lazy initialization of settings window
        if settingsWindowController == nil {
            settingsWindowController = SimpleSettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func setupHotKey() {
        // Default to Option+Command+A (⌥⌘A)
        let defaultModifiers: NSEvent.ModifierFlags = [.option, .command]
        let defaultKeyCode: UInt16 = 0 // 'A' key
        
        hotKeyManager.register(keyCode: defaultKeyCode, modifiers: defaultModifiers) { [weak self] in
            guard let self = self, !self.isPausedInternal else { return }
            
            let controller = self.controller
            Task { @MainActor in
                await controller.handleHotkeyInvocation()
            }
        }
    }
}
