import XCTest
@testable import TypeForMe

final class GeminiClientTests: XCTestCase {
    func testGeminiClientInitializationWithoutAPIKey() {
        // Clear any existing API key
        UserDefaults.standard.removeObject(forKey: "GEMINI_API_KEY")
        
        XCTAssertThrowsError(try GeminiClient()) { error in
            XCTAssertTrue(error is GeminiClientError)
            if case .noAPIKey = error as? GeminiClientError {
                // Expected
            } else {
                XCTFail("Expected noAPIKey error")
            }
        }
    }
    
    func testGeminiClientInitializationWithAPIKey() {
        let client = GeminiClient(apiKey: "test-api-key")
        
        // Should initialize without throwing
        XCTAssertNotNil(client)
    }
    
    func testCreateImageDataFromScreenshot() {
        let jpegData = Data([0xFF, 0xD8, 0xFF, 0xE0]) // JPEG header
        let screenshot = Screenshot(
            data: jpegData,
            format: .jpeg,
            originalRect: Rect(x: 0, y: 0, width: 100, height: 100)
        )
        
        let client = GeminiClient(apiKey: "test-key")
        
        // Test internal image data creation (we'd need to make this method internal for testing)
        // For now, just test that the client can be created
        XCTAssertNotNil(client)
    }
    
    func testGenerateTextWithInvalidAPIKey() async {
        let client = GeminiClient(apiKey: "invalid-key")
        
        let prompt = PromptPayload(
            systemInstruction: "Test instruction",
            json: Data("{\"mode\":\"autowrite\"}".utf8)
        )
        
        let screenshot = Screenshot(
            data: Data([0xFF, 0xD8]),
            format: .jpeg,
            originalRect: Rect(x: 0, y: 0, width: 10, height: 10)
        )
        
        do {
            _ = try await client.generateText(prompt: prompt, screenshot: screenshot)
            XCTFail("Should have thrown an error with invalid API key")
        } catch {
            // Expected to fail with invalid API key
            XCTAssertTrue(error is GeminiClientError)
        }
    }
}
