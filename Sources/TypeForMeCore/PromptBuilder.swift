import Foundation

public final class PromptBuilder: PromptBuilding {
    public struct Configuration {
        public let systemInstruction: String

        public init(systemInstruction: String = Self.defaultInstruction) {
            self.systemInstruction = systemInstruction
        }

        public static let defaultInstruction = """
You are an intelligent writing assistant that analyzes screenshots to provide contextually appropriate text.

CORE BEHAVIOR:
- If "mode" is "edit": Rewrite the "selection" text to be clearer and better aligned with style_prefs
- If "mode" is "autowrite": Generate appropriate new text for the current context

CONTEXT ANALYSIS:
Look at the screenshot and determine the appropriate response based on what you see:
- Email/messaging apps: Draft natural, contextual replies or messages
- Text editors/documents: Provide relevant content, ideas, or continuations
- Forms/input fields: Fill with appropriate, realistic information
- Development environments: Suggest meaningful code, comments, or documentation
- Social media: Compose engaging, platform-appropriate content
- Any other context: Generate text that genuinely helps the user's workflow

IMPORTANT GUIDELINES:
- Never just echo or repeat what's visible on screen
- Generate genuinely useful content that advances the user's task
- Infer the appropriate tone and style from visual context
- Keep responses concise but meaningful
- Honor the provided style_prefs for tone, brevity, and formatting
- Return ONLY the final text - no explanations or meta-commentary
- Do not invent facts, but do provide helpful, contextually appropriate content
"""
    }

    private let encoder: JSONEncoder
    private let configuration: Configuration

    public init(configuration: Configuration = .init(), encoder: JSONEncoder = JSONEncoder()) {
        self.configuration = configuration
        self.encoder = encoder
        encoder.outputFormatting = [.sortedKeys]
    }

    public func makePrompt(mode: InteractionMode, selection: String?, style: StylePreferences) throws -> PromptPayload {
        let payload = Payload(mode: mode.rawValue, selection: selection, stylePrefs: .init(from: style))
        let data = try encoder.encode(payload)
        return PromptPayload(systemInstruction: configuration.systemInstruction, json: data)
    }

    private struct Payload: Encodable, Equatable {
        let mode: String
        let selection: String?
        let stylePrefs: StylePrefs

        enum CodingKeys: String, CodingKey {
            case mode
            case selection
            case stylePrefs = "style_prefs"
        }
    }

    private struct StylePrefs: Encodable, Equatable {
        let tone: String
        let brevity: String
        let greetings: String
        let signOff: String
        let avoid: [String]

        enum CodingKeys: String, CodingKey {
            case tone
            case brevity
            case greetings
            case signOff = "sign_off"
            case avoid
        }

        init(from style: StylePreferences) {
            tone = style.tone.rawValue
            brevity = style.brevity.rawValue
            greetings = {
                switch style.greetings {
                case .auto: return "auto"
                case .none: return "none"
                case .custom(let value): return value
                }
            }()
            signOff = {
                switch style.signOff {
                case .auto: return "auto"
                case .none: return "none"
                case .custom(let value): return value
                }
            }()
            avoid = style.avoid
        }
    }
}
