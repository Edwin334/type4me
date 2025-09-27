import XCTest
import AppKit
@testable import TypeForMe

final class PasteboardProviderTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clear pasteboard before each test
        NSPasteboard.general.clearContents()
    }
    
    func testReadAndWriteString() throws {
        let provider = PasteboardProvider()
        let testString = "Test string for pasteboard"
        
        try provider.writeString(testString)
        let readString = try provider.readString()
        
        XCTAssertEqual(readString, testString)
    }
    
    func testRestoreString() throws {
        let provider = PasteboardProvider()
        let originalString = "Original content"
        let temporaryString = "Temporary content"
        
        // Set original content
        try provider.writeString(originalString)
        
        // Change to temporary content
        try provider.writeString(temporaryString)
        XCTAssertEqual(try provider.readString(), temporaryString)
        
        // Restore original content
        try provider.restoreString(originalString)
        XCTAssertEqual(try provider.readString(), originalString)
    }
    
    func testRestoreNilString() throws {
        let provider = PasteboardProvider()
        
        // Set some content first
        try provider.writeString("Some content")
        
        // Restore nil should clear the pasteboard
        try provider.restoreString(nil)
        
        // Pasteboard might be empty or have empty string
        let result = try provider.readString()
        XCTAssertTrue(result == nil || result == "")
    }
    
    func testReadEmptyPasteboard() throws {
        let provider = PasteboardProvider()
        
        // Clear pasteboard
        NSPasteboard.general.clearContents()
        
        let result = try provider.readString()
        XCTAssertNil(result)
    }
}
