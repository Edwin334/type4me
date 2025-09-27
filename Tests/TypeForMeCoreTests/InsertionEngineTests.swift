import XCTest
@testable import TypeForMeCore

private final class MockPasteboard: PasteboardProviding {
    var storedString: String?
    var readCallCount = 0
    var writeCallCount = 0
    var restoreCallCount = 0

    func readString() throws -> String? {
        readCallCount += 1
        return storedString
    }

    func writeString(_ string: String) throws {
        writeCallCount += 1
        storedString = string
    }

    func restoreString(_ string: String?) throws {
        restoreCallCount += 1
        storedString = string
    }
}

private final class MockPastePerformer: PasteCommandPerforming {
    enum Mode {
        case succeed
        case failPaste
    }

    var mode: Mode = .succeed
    var performPasteCallCount = 0
    var typeCallCount = 0

    func performPaste(replacingSelection: Bool) throws {
        performPasteCallCount += 1
        if mode == .failPaste {
            throw InsertionError.typingFailed
        }
    }

    func type(text: String) throws {
        typeCallCount += 1
        if mode != .failPaste {
            XCTFail("Typing should not be used when paste succeeds")
        }
    }
}

final class InsertionEngineTests: XCTestCase {
    func testInsertionUsesPasteboardAndPaste() throws {
        let pasteboard = MockPasteboard()
        let performer = MockPastePerformer()
        performer.mode = .succeed
        let engine = InsertionEngine(pasteboard: pasteboard, pastePerformer: performer)

        try engine.insert(text: "Hello", replaceSelection: true)

        XCTAssertEqual(pasteboard.writeCallCount, 1)
        XCTAssertEqual(pasteboard.restoreCallCount, 1)
        XCTAssertEqual(performer.performPasteCallCount, 1)
        XCTAssertEqual(performer.typeCallCount, 0)
    }

    func testInsertionFallsBackToTypingWhenPasteFails() throws {
        let pasteboard = MockPasteboard()
        let performer = MockPastePerformer()
        performer.mode = .failPaste
        let engine = InsertionEngine(pasteboard: pasteboard, pastePerformer: performer)

        try engine.insert(text: "Fallback", replaceSelection: false)

        XCTAssertEqual(performer.performPasteCallCount, 1)
        XCTAssertEqual(performer.typeCallCount, 1)
        XCTAssertEqual(pasteboard.restoreCallCount, 1)
    }
}
