import AppKit
import TypeForMeCore

let appDelegate = AppDelegate()
NSApplication.shared.delegate = appDelegate
NSApplication.shared.run()

class AppDelegate: NSObject, NSApplicationDelegate {
    private var typeForMeManager: TypeForMeManager?
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon since this is a menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        // Setup menu bar
        setupMenuBar()
        
        // Initialize TypeForMe manager
        typeForMeManager = TypeForMeManager()
        typeForMeManager?.start()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        typeForMeManager?.stop()
    }
    
    @MainActor private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        guard let statusItem = statusItem else { return }
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.cursor", accessibilityDescription: "TypeForMe")
            button.toolTip = "TypeForMe"
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Pause", action: #selector(togglePause), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit TypeForMe", action: #selector(quit), keyEquivalent: "q"))
        
        menu.items.forEach { $0.target = self }
        statusItem.menu = menu
    }
    
    @MainActor @objc private func openSettings() {
        typeForMeManager?.showSettings()
    }
    
    @objc private func togglePause() {
        guard let manager = typeForMeManager else { return }
        
        if manager.isPaused {
            manager.resume()
            statusItem?.menu?.item(withTitle: "Resume")?.title = "Pause"
        } else {
            manager.pause()
            statusItem?.menu?.item(withTitle: "Pause")?.title = "Resume"
        }
    }
    
    @MainActor @objc private func quit() {
        NSApp.terminate(nil)
    }
}
