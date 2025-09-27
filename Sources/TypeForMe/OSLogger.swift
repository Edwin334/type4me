import Foundation
import os.log
import TypeForMeCore

class OSLogger: TypeForMeCore.Logger {
    private let osLog = os.Logger(subsystem: "com.typeformen.app", category: "main")
    
    func info(_ message: String) {
        osLog.info("\(message)")
    }
    
    func error(_ message: String) {
        osLog.error("\(message)")
    }
}
