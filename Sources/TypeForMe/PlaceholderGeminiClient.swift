import Foundation
import TypeForMeCore

/// A placeholder Gemini client that provides helpful error messages when the real client can't be initialized
final class PlaceholderGeminiClient: GeminiClientProtocol, @unchecked Sendable {
    
    func generateText(prompt: PromptPayload, screenshot: Screenshot) async throws -> String {
        // Throw a descriptive error that will be shown to the user
        struct NoAPIKeyError: LocalizedError {
            var errorDescription: String? {
                return "Gemini API key not found. Please set GEMINI_API_KEY environment variable or configure it in Settings."
            }
        }
        throw NoAPIKeyError()
    }
}
