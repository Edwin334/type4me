import XCTest
@testable import TypeForMe

final class PasteCommandPerformerTests: XCTestCase {
    func testPerformPasteDoesNotCrash() {
        let performer = PasteCommandPerformer()
        
        // This test mainly ensures the method doesn't crash
        // In a real environment, this would send Cmd+V
        XCTAssertNoThrow(try performer.performPaste(replacingSelection: true))
        XCTAssertNoThrow(try performer.performPaste(replacingSelection: false))
    }
    
    func testTypeCharactersDoesNotCrash() {
        let performer = PasteCommandPerformer()
        
        // Test typing simple characters
        XCTAssertNoThrow(try performer.type(text: "a"))
        XCTAssertNoThrow(try performer.type(text: "A"))
        XCTAssertNoThrow(try performer.type(text: "1"))
        XCTAssertNoThrow(try performer.type(text: " "))
    }
    
    func testTypeSimpleString() {
        let performer = PasteCommandPerformer()
        
        // Test typing a simple string
        XCTAssertNoThrow(try performer.type(text: "hello"))
    }
    
    func testTypeEmptyString() {
        let performer = PasteCommandPerformer()
        
        // Empty string should not crash
        XCTAssertNoThrow(try performer.type(text: ""))
    }
    
    func testTypeStringWithSpecialCharacters() {
        let performer = PasteCommandPerformer()
        
        // Test special characters that have key mappings
        XCTAssertNoThrow(try performer.type(text: "Hello, World!"))
        XCTAssertNoThrow(try performer.type(text: "test@example.com"))
    }
    
    func testTypeStringWithUnsupportedCharacters() {
        let performer = PasteCommandPerformer()
        
        // Test characters that might not have key mappings
        // These should not crash, but might be skipped
        XCTAssertNoThrow(try performer.type(text: "🚀 emoji test"))
        XCTAssertNoThrow(try performer.type(text: "åéîøü"))
    }
}
