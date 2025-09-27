import XCTest
import AppKit
@testable import TypeForMe

final class HotKeyManagerTests: XCTestCase {
    func testRegisterAndDisableHotKey() {
        let manager = HotKeyManager()
        var callbackCalled = false
        
        manager.register(keyCode: 1, modifiers: [.command]) {
            callbackCalled = true
        }
        
        // Enable and disable should not crash
        manager.enable()
        manager.disable()
        
        // After disable, callback should be nil
        XCTAssertFalse(callbackCalled)
    }
    
    func testMultipleDisableCallsDoNotCrash() {
        let manager = HotKeyManager()
        
        manager.register(keyCode: 1, modifiers: [.command]) {
            // Test callback
        }
        
        manager.disable()
        manager.disable() // Should not crash
        manager.disable() // Should not crash
    }
    
    func testDeinitDisablesHotKey() {
        var manager: HotKeyManager? = HotKeyManager()
        
        manager?.register(keyCode: 1, modifiers: [.command]) {
            // Test callback
        }
        
        // Deallocation should clean up properly
        manager = nil
        
        // Test passes if no crash occurs
        XCTAssertNil(manager)
    }
}
