import Foundation

public final class PromptBuilder: PromptBuilding {
    public struct Configuration {
        public let systemInstruction: String

        public init(systemInstruction: String = Self.defaultInstruction) {
            self.systemInstruction = systemInstruction
        }

        public static let defaultInstruction = "You write or edit text based solely on the provided screenshot of the user's current window. If \"mode\" is \"edit\", rewrite only the \"selection\" to be clearer and aligned with style_prefs. If \"mode\" is \"autowrite\", compose an appropriate, concise message for the visible context. Infer channel and conventions from the screenshot. Do not include explanations; return only final text. Honor style_prefs. Do not invent facts beyond what is visible."
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
