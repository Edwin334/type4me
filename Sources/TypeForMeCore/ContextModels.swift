import Foundation

public struct FocusedElementContext: Equatable {
    public let selection: String?
    public let caretBounds: Rect?
    public let elementBounds: Rect
    public let windowBounds: Rect
    public let isSecure: Bool

    public init(selection: String?, caretBounds: Rect?, elementBounds: Rect, windowBounds: Rect, isSecure: Bool) {
        self.selection = selection?.isEmpty == false ? selection : nil
        self.caretBounds = caretBounds
        self.elementBounds = elementBounds
        self.windowBounds = windowBounds
        self.isSecure = isSecure
    }

    public var mode: InteractionMode {
        if let selection, !selection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .edit
        }
        return .autowrite
    }

    public func captureRect(padding: Double = 200) -> Rect {
        if let caretBounds {
            let padded = caretBounds.padded(with: padding, within: windowBounds)
            return padded.intersection(windowBounds)
        }
        return windowBounds
    }
}

public enum InteractionMode: String, Codable {
    case autowrite
    case edit
}

public struct Screenshot: Equatable {
    public let data: Data
    public let format: ImageFormat
    public let originalRect: Rect

    public init(data: Data, format: ImageFormat, originalRect: Rect) {
        self.data = data
        self.format = format
        self.originalRect = originalRect
    }
}

public enum ImageFormat: String, Codable {
    case jpeg
    case png
}

public struct PromptPayload: Equatable {
    public let systemInstruction: String
    public let json: Data

    public init(systemInstruction: String, json: Data) {
        self.systemInstruction = systemInstruction
        self.json = json
    }
}
