import AppKit
import TypeForMeCore

/// Simplified settings window controller to avoid MainActor issues
class SimpleSettingsWindowController: NSWindowController {
    private let styleStore = StylePreferenceStore()
    
    init() {
        super.init(window: nil)
        setupWindow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "TypeForMe Settings"
        window.center()
        window.isReleasedWhenClosed = false
        
        // Create simple content
        let contentView = NSView(frame: window.contentView!.bounds)
        
        let label = NSTextField(labelWithString: "TypeForMe Settings")
        label.font = NSFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        let infoLabel = NSTextField(labelWithString: "Set GEMINI_API_KEY environment variable\nor configure through Settings menu.")
        infoLabel.font = NSFont.systemFont(ofSize: 12)
        infoLabel.textColor = NSColor.secondaryLabelColor
        infoLabel.isEditable = false
        infoLabel.isSelectable = false
        infoLabel.isBordered = false
        infoLabel.backgroundColor = NSColor.clear
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoLabel)
        
        let closeButton = NSButton(title: "Close", target: self, action: #selector(closeWindow))
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            
            infoLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            infoLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        window.contentView = contentView
        self.window = window
    }
    
    @objc private func closeWindow() {
        window?.close()
    }
}
