import XCTest
@testable import TypeForMe

final class AccessibilityProviderTests: XCTestCase {
    func testFocusedContextDoesNotCrash() {
        let provider = AccessibilityProvider()
        
        do {
            let context = try provider.focusedContext()
            
            // Basic validation that we get a reasonable context
            XCTAssertTrue(context.elementBounds.width >= 0)
            XCTAssertTrue(context.elementBounds.height >= 0)
            XCTAssertTrue(context.windowBounds.width >= 0)
            XCTAssertTrue(context.windowBounds.height >= 0)
            
            // Mode should be valid
            XCTAssertTrue(context.mode == .autowrite || context.mode == .edit)
            
        } catch {
            // In test environments without accessibility permissions,
            // this is expected to fail
            XCTAssertNotNil(error)
        }
    }
    
    func testCaptureRectCalculation() {
        let provider = AccessibilityProvider()
        
        // Test with mock context since real accessibility might not be available
        let context = FocusedElementContext(
            selection: nil,
            caretBounds: Rect(x: 100, y: 100, width: 2, height: 20),
            elementBounds: Rect(x: 50, y: 90, width: 200, height: 40),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )
        
        let captureRect = context.captureRect(padding: 200)
        
        // Should be within window bounds
        XCTAssertGreaterThanOrEqual(captureRect.x, 0)
        XCTAssertGreaterThanOrEqual(captureRect.y, 0)
        XCTAssertLessThanOrEqual(captureRect.maxX, 1200)
        XCTAssertLessThanOrEqual(captureRect.maxY, 800)
        
        // Should be larger than caret
        XCTAssertGreaterThan(captureRect.width, 2)
        XCTAssertGreaterThan(captureRect.height, 20)
    }
}
