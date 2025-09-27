import AppKit
import Carbon
import TypeForMeCore

class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var callback: (() -> Void)?
    
    deinit {
        disable()
    }
    
    func register(keyCode: UInt16, modifiers: NSEvent.ModifierFlags, callback: @escaping () -> Void) {
        // Disable any existing hotkey first
        disable()
        
        self.callback = callback
        
        // Convert NSEvent modifiers to Carbon modifiers
        var carbonModifiers: UInt32 = 0
        if modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if modifiers.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if modifiers.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }
        
        // Create hotkey ID
        let hotKeyID = EventHotKeyID(signature: OSType(0x54464D45), id: 1) // 'TFME'
        
        // Register the hotkey
        let result = RegisterEventHotKey(
            UInt32(keyCode),
            carbonModifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        if result != noErr {
            print("Failed to register hotkey: \(result)")
            return
        }
        
        // Install event handler
        let eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        var eventSpecArray = [eventSpec]
        
        InstallEventHandler(
            GetEventDispatcherTarget(),
            { (eventHandlerCallRef, eventRef, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handleHotKeyEvent()
                return noErr
            },
            1,
            &eventSpecArray,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }
    
    func enable() {
        // Hotkey is enabled when registered
    }
    
    func disable() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        
        callback = nil
    }
    
    private func handleHotKeyEvent() {
        callback?()
    }
}
