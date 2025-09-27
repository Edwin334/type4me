import AppKit
import ApplicationServices
import TypeForMeCore

class PermissionChecker: PermissionChecking {
    
    func hasRequiredPermissions() -> Bool {
        return hasAccessibilityPermission() && 
               hasScreenRecordingPermission() && 
               hasInputMonitoringPermission()
    }
    
    func promptForMissingPermissions() {
        let message = getMissingPermissionsMessage()
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "TypeForMe Requires Permissions"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                PermissionChecker().openSystemSettings()
            }
        }
    }
    
    private func hasAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }
    
    private func hasScreenRecordingPermission() -> Bool {
        // Test screen recording by attempting to capture a tiny screenshot
        let displayID = CGMainDisplayID()
        let image = CGDisplayCreateImage(displayID)
        return image != nil
    }
    
    private func hasInputMonitoringPermission() -> Bool {
        // Attempt to create a simple event tap. If this fails, it's likely due to
        // missing Input Monitoring permissions. The system will prompt the user
        // automatically the first time this is called.
        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, _, _, _ in return nil },
            userInfo: nil
        ) else {
            // If tap creation fails, we likely don't have permissions.
            return false
        }
        
        // If we successfully created a tap, it means we have permissions.
        // We should disable it immediately as we don't need it.
        CFMachPortInvalidate(tap)
        
        return true
    }
    
    private func getMissingPermissionsMessage() -> String {
        var message = "TypeForMe needs the following permissions to work:\n\n"
        
        if !hasAccessibilityPermission() {
            message += "• Accessibility - to read text selection and insert text\n"
        }
        
        if !hasScreenRecordingPermission() {
            message += "• Screen Recording - to capture screenshots for context\n"
        }
        
        if !hasInputMonitoringPermission() {
            message += "• Input Monitoring - to listen for global hotkeys and insert text\n"
        }
        
        message += "\nPlease grant these permissions in System Settings > Privacy & Security."
        return message
    }
    
    private func openSystemSettings() {
        // Open System Settings to Security & Privacy
        if #available(macOS 13.0, *) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_InputMonitoring")!)
        } else {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security")!)
        }
    }
}
