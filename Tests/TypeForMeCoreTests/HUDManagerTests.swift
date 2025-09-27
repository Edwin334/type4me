import XCTest
import AppKit
@testable import TypeForMe

@MainActor
final class HUDManagerTests: XCTestCase {
    func testShowAndHideHUD() {
        let manager = HUDManager()
        
        // These should not crash
        manager.show(status: .drafting)
        manager.hide()
        
        manager.show(status: .rewriting)
        manager.hide()
        
        manager.show(status: .unavailable("Test message"))
        manager.hide()
    }
    
    func testMultipleShowCalls() {
        let manager = HUDManager()
        
        // Multiple show calls should not crash
        manager.show(status: .drafting)
        manager.show(status: .rewriting)
        manager.show(status: .unavailable("Message"))
        
        manager.hide()
    }
    
    func testHideWithoutShow() {
        let manager = HUDManager()
        
        // Hide without show should not crash
        manager.hide()
        manager.hide()
    }
    
    func testHUDStatusEquality() {
        XCTAssertEqual(HUDStatus.drafting, HUDStatus.drafting)
        XCTAssertEqual(HUDStatus.rewriting, HUDStatus.rewriting)
        XCTAssertEqual(HUDStatus.unavailable("test"), HUDStatus.unavailable("test"))
        
        XCTAssertNotEqual(HUDStatus.drafting, HUDStatus.rewriting)
        XCTAssertNotEqual(HUDStatus.unavailable("test1"), HUDStatus.unavailable("test2"))
    }
    
    func testRapidShowHide() {
        let manager = HUDManager()
        
        // Rapid show/hide cycles should not crash
        for i in 0..<10 {
            manager.show(status: i % 2 == 0 ? .drafting : .rewriting)
            manager.hide()
        }
    }
}
