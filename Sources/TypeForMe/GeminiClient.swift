import Foundation
import GoogleGenerativeAI
import TypeForMeCore
import UniformTypeIdentifiers

enum GeminiClientError: Error, LocalizedError {
    case noAPIKey
    case invalidImageData
    case emptyResponse
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Gemini API key not found. Please set GEMINI_API_KEY environment variable."
        case .invalidImageData:
            return "Invalid image data provided to Gemini."
        case .emptyResponse:
            return "Gemini returned an empty response."
        case .apiError(let message):
            return "Gemini API error: \(message)"
        }
    }
}

final class GeminiClient: GeminiClientProtocol, @unchecked Sendable {
    private let model: GenerativeModel
    
    init() throws {
        // Get API key from UserDefaults or environment variable
        let apiKey = UserDefaults.standard.string(forKey: "GEMINI_API_KEY") ?? 
                    ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw GeminiClientError.noAPIKey
        }
        
        // Initialize Gemini 2.0 Flash model
        self.model = GenerativeModel(
            name: "gemini-2.0-flash-exp",
            apiKey: apiKey,
            generationConfig: GenerationConfig(
                temperature: 0.2,
                maxOutputTokens: 512
            )
        )
    }
    
    // Convenience initializer for testing
    init(apiKey: String) {
        self.model = GenerativeModel(
            name: "gemini-2.0-flash-exp",
            apiKey: apiKey,
            generationConfig: GenerationConfig(
                temperature: 0.2,
                maxOutputTokens: 512
            )
        )
    }
    
    func generateText(prompt: PromptPayload, screenshot: Screenshot) async throws -> String {
        // Create image data from screenshot
        guard let image = createImageData(from: screenshot) else {
            throw GeminiClientError.invalidImageData
        }
        
        // Convert JSON prompt to string
        let jsonString = String(data: prompt.json, encoding: .utf8) ?? ""
        
        // Create the full prompt
        let fullPrompt = """
        \(prompt.systemInstruction)
        
        User data: \(jsonString)
        """
        
        do {
            // Generate content with image and text
            let response = try await model.generateContent(fullPrompt, image)
            
            guard let text = response.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                  !text.isEmpty else {
                throw GeminiClientError.emptyResponse
            }
            
            return text
        } catch {
            throw GeminiClientError.apiError(error.localizedDescription)
        }
    }
    
    private func createImageData(from screenshot: Screenshot) -> ModelContent.Part? {
        let mimeType: String
        switch screenshot.format {
        case .jpeg:
            mimeType = "image/jpeg"
        case .png:
            mimeType = "image/png"
        }
        
        return .data(mimetype: mimeType, screenshot.data)
    }
}
