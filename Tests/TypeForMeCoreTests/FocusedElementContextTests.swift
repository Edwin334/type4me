import XCTest
@testable import TypeForMeCore

final class FocusedElementContextTests: XCTestCase {
    func testModeAutowriteWhenSelectionMissing() {
        let context = FocusedElementContext(
            selection: nil,
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )

        XCTAssertEqual(context.mode, .autowrite)
    }

    func testModeEditWhenSelectionPresent() {
        let context = FocusedElementContext(
            selection: "Hello",
            caretBounds: nil,
            elementBounds: Rect(x: 0, y: 0, width: 100, height: 20),
            windowBounds: Rect(x: 0, y: 0, width: 1200, height: 800),
            isSecure: false
        )

        XCTAssertEqual(context.mode, .edit)
    }

    func testCaptureRectUsesCaretWhenAvailable() {
        let window = Rect(x: 0, y: 0, width: 1000, height: 700)
        let caret = Rect(x: 400, y: 300, width: 2, height: 20)
        let context = FocusedElementContext(
            selection: nil,
            caretBounds: caret,
            elementBounds: Rect(x: 0, y: 0, width: 300, height: 40),
            windowBounds: window,
            isSecure: false
        )

        let capture = context.captureRect(padding: 100)

        XCTAssertLessThanOrEqual(capture.width, window.width)
        XCTAssertLessThanOrEqual(capture.height, window.height)
        XCTAssertGreaterThan(capture.width, caret.width)
        XCTAssertGreaterThan(capture.height, caret.height)
    }
}
