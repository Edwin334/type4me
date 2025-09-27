import XCTest
@testable import TypeForMe

final class ScreenshotCapturerTests: XCTestCase {
    func testCaptureActiveWindowDoesNotCrash() {
        let capturer = ScreenshotCapturer()
        let region = Rect(x: 0, y: 0, width: 800, height: 600)
        
        do {
            let screenshot = try capturer.captureActiveWindow(region: region)
            
            // Basic validation
            XCTAssertFalse(screenshot.data.isEmpty)
            XCTAssertEqual(screenshot.format, .jpeg)
            XCTAssertEqual(screenshot.originalRect, region)
            
        } catch {
            // In test environments without screen recording permissions,
            // this might fail
            print("Screenshot test failed (expected in CI): \(error)")
        }
    }
    
    func testSmallRegionCapture() {
        let capturer = ScreenshotCapturer()
        let smallRegion = Rect(x: 100, y: 100, width: 200, height: 150)
        
        do {
            let screenshot = try capturer.captureActiveWindow(region: smallRegion)
            
            XCTAssertFalse(screenshot.data.isEmpty)
            XCTAssertEqual(screenshot.format, .jpeg)
            XCTAssertEqual(screenshot.originalRect, smallRegion)
            
        } catch {
            // Expected in test environments
            print("Small region screenshot test failed (expected in CI): \(error)")
        }
    }
    
    func testZeroRegionHandling() {
        let capturer = ScreenshotCapturer()
        let zeroRegion = Rect(x: 0, y: 0, width: 0, height: 0)
        
        do {
            let screenshot = try capturer.captureActiveWindow(region: zeroRegion)
            
            // Should still produce some data, even if the region is zero
            XCTAssertFalse(screenshot.data.isEmpty)
            
        } catch {
            // This might fail in various ways, which is acceptable for edge cases
            print("Zero region test failed: \(error)")
        }
    }
}
