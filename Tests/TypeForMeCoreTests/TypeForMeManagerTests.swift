import XCTest
@testable import TypeForMe

final class TypeForMeManagerTests: XCTestCase {
    func testManagerInitialization() {
        // Set a test API key to avoid initialization failure
        UserDefaults.standard.set("test-api-key", forKey: "GEMINI_API_KEY")
        
        let manager = TypeForMeManager()
        
        XCTAssertNotNil(manager)
        XCTAssertFalse(manager.isPaused)
    }
    
    func testStartAndStop() {
        UserDefaults.standard.set("test-api-key", forKey: "GEMINI_API_KEY")
        
        let manager = TypeForMeManager()
        
        // These should not crash
        manager.start()
        manager.stop()
    }
    
    func testPauseAndResume() {
        UserDefaults.standard.set("test-api-key", forKey: "GEMINI_API_KEY")
        
        let manager = TypeForMeManager()
        
        XCTAssertFalse(manager.isPaused)
        
        manager.pause()
        XCTAssertTrue(manager.isPaused)
        
        manager.resume()
        XCTAssertFalse(manager.isPaused)
    }
    
    func testShowSettings() {
        UserDefaults.standard.set("test-api-key", forKey: "GEMINI_API_KEY")
        
        let manager = TypeForMeManager()
        
        // This might show UI in interactive tests, but should not crash
        // In CI, it should handle the lack of UI gracefully
        Task { @MainActor in
            manager.showSettings()
        }
        
        // Test passes if no crash occurs
        XCTAssertNotNil(manager)
    }
    
    override func tearDown() {
        // Clean up test API key
        UserDefaults.standard.removeObject(forKey: "GEMINI_API_KEY")
        super.tearDown()
    }
}
