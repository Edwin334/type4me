import AppKit
import TypeForMeCore
import UserNotifications

class FeedbackManager: FeedbackNotifying {
    func notifyUserFailure() {
        DispatchQueue.main.async {
            NSSound.beep()
            
            // For modern macOS, we should use UserNotifications framework
            // For now, just beep as the primary feedback
        }
    }
}
