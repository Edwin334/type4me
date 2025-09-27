import AppKit
import TypeForMeCore

@MainActor
class HUDManager: HUDPresenting {
    private var hudWindow: NSWindow?
    private var hudLabel: NSTextField?
    private let animationDuration: TimeInterval = 0.3
    
    func show(status: HUDStatus) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.show(status: status)
            }
            return
        }
        createHUDIfNeeded()
        updateHUDText(for: status)
        animateHUDIn()
    }
    
    func hide() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.hide()
            }
            return
        }
        animateHUDOut()
    }
    
    @MainActor private func createHUDIfNeeded() {
        guard hudWindow == nil else { return }
        
        // Create HUD window
        let hudFrame = NSRect(x: 0, y: 0, width: 200, height: 40)
        hudWindow = NSWindow(
            contentRect: hudFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        guard let window = hudWindow else { return }
        
        window.backgroundColor = NSColor.black.withAlphaComponent(0.8)
        window.level = .floating
        window.hasShadow = true
        window.isMovable = false
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Make window rounded
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 8
        window.contentView?.layer?.masksToBounds = true
        
        // Create label
        hudLabel = NSTextField(frame: hudFrame)
        guard let label = hudLabel else { return }
        
        label.isEditable = false
        label.isSelectable = false
        label.isBordered = false
        label.backgroundColor = NSColor.clear
        label.textColor = NSColor.white
        label.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        window.contentView?.addSubview(label)
        
        // Add constraints
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: window.contentView!.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: window.contentView!.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: window.contentView!.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(lessThanOrEqualTo: window.contentView!.trailingAnchor, constant: -8)
        ])
        
        // Position near cursor
        positionHUDNearCursor()
    }
    
    @MainActor private func updateHUDText(for status: HUDStatus) {
        let text: String
        switch status {
        case .drafting:
            text = "Drafting..."
        case .rewriting:
            text = "Rewriting..."
        case .unavailable(let message):
            text = message
        }
        
        hudLabel?.stringValue = text
        
        // Resize window to fit text
        guard let window = hudWindow, let label = hudLabel else { return }
        
        let textSize = label.attributedStringValue.size()
        let windowWidth = max(textSize.width + 32, 120)
        let windowHeight: CGFloat = 40
        
        var frame = window.frame
        frame.size.width = windowWidth
        frame.size.height = windowHeight
        
        // Re-center the window
        if let screen = NSScreen.main {
            frame.origin.x = (screen.frame.width - windowWidth) / 2
            frame.origin.y = (screen.frame.height - windowHeight) / 2
        }
        
        window.setFrame(frame, display: true)
    }
    
    @MainActor private func positionHUDNearCursor() {
        guard let window = hudWindow else { return }
        
        // Get cursor position
        let mouseLocation = NSEvent.mouseLocation
        
        // Position HUD slightly below cursor
        var hudFrame = window.frame
        hudFrame.origin.x = mouseLocation.x - hudFrame.width / 2
        hudFrame.origin.y = mouseLocation.y - hudFrame.height - 20
        
        // Ensure HUD stays on screen
        if let screen = NSScreen.main {
            if hudFrame.maxX > screen.frame.maxX {
                hudFrame.origin.x = screen.frame.maxX - hudFrame.width
            }
            if hudFrame.minX < screen.frame.minX {
                hudFrame.origin.x = screen.frame.minX
            }
            if hudFrame.minY < screen.frame.minY {
                hudFrame.origin.y = mouseLocation.y + 20
            }
        }
        
        window.setFrame(hudFrame, display: false)
    }
    
    @MainActor private func animateHUDIn() {
        guard let window = hudWindow else { return }
        
        window.alphaValue = 0.0
        window.orderFront(nil)
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().alphaValue = 1.0
        }
    }
    
    @MainActor private func animateHUDOut() {
        guard let window = hudWindow else { return }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().alphaValue = 0.0
        }) { [weak self] in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                window.orderOut(nil)
                self.hudWindow = nil
                self.hudLabel = nil
            }
        }
    }
}
