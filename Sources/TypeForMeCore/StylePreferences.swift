import Foundation

public struct StylePreferences: Codable, Equatable {
    public enum Tone: String, Codable, CaseIterable {
        case neutral
        case warm
        case direct
    }

    public enum Brevity: String, Codable, CaseIterable {
        case short
        case medium
        case long
    }

    public enum Greetings: Codable, Equatable {
        case auto
        case none
        case custom(String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                switch value {
                case "auto": self = .auto
                case "none": self = .none
                default: self = .custom(value)
                }
            } else {
                self = .auto
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .auto: try container.encode("auto")
            case .none: try container.encode("none")
            case .custom(let value): try container.encode(value)
            }
        }
    }

    public enum SignOff: Codable, Equatable {
        case auto
        case none
        case custom(String)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let value = try? container.decode(String.self) {
                switch value {
                case "auto": self = .auto
                case "none": self = .none
                default: self = .custom(value)
                }
            } else {
                self = .auto
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .auto: try container.encode("auto")
            case .none: try container.encode("none")
            case .custom(let value): try container.encode(value)
            }
        }
    }

    public var tone: Tone
    public var brevity: Brevity
    public var greetings: Greetings
    public var signOff: SignOff
    public var avoid: [String]

    public init(
        tone: Tone = .neutral,
        brevity: Brevity = .short,
        greetings: Greetings = .auto,
        signOff: SignOff = .auto,
        avoid: [String] = []
    ) {
        self.tone = tone
        self.brevity = brevity
        self.greetings = greetings
        self.signOff = signOff
        self.avoid = avoid
    }
}

public protocol StylePreferenceStoreProtocol {
    func load() throws -> StylePreferences
    func save(_ preferences: StylePreferences) throws
}

public final class StylePreferenceStore: StylePreferenceStoreProtocol {
    public enum StoreError: Error, LocalizedError {
        case directoryCreationFailed

        public var errorDescription: String? {
            switch self {
            case .directoryCreationFailed:
                return "Failed to create style preference directory."
            }
        }
    }

    private let fileManager: FileManager
    private let url: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(fileManager: FileManager = .default, url: URL? = nil) {
        self.fileManager = fileManager
        if let url {
            self.url = url
        } else {
            let base = fileManager.homeDirectoryForCurrentUser
            self.url = base
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Application Support", isDirectory: true)
                .appendingPathComponent("TypeForMe", isDirectory: true)
                .appendingPathComponent("style.json", isDirectory: false)
        }
    }

    public func load() throws -> StylePreferences {
        if !fileManager.fileExists(atPath: url.path) {
            return StylePreferences()
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(StylePreferences.self, from: data)
        } catch {
            return StylePreferences()
        }
    }

    public func save(_ preferences: StylePreferences) throws {
        let directoryURL = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            } catch {
                throw StoreError.directoryCreationFailed
            }
        }
        let data = try encoder.encode(preferences)
        try data.write(to: url, options: .atomic)
    }
}
