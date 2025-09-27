import Foundation

public struct Rect: Equatable, Codable, Sendable {
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public static let zero = Rect(x: 0, y: 0, width: 0, height: 0)

    public var minX: Double { x }
    public var minY: Double { y }
    public var maxX: Double { x + width }
    public var maxY: Double { y + height }

    public var isEmpty: Bool { width <= 0 || height <= 0 }

    public func insetBy(dx: Double, dy: Double) -> Rect {
        Rect(x: x + dx, y: y + dy, width: width - dx * 2, height: height - dy * 2)
    }

    public func expandedBy(dx: Double, dy: Double) -> Rect {
        Rect(x: x - dx, y: y - dy, width: width + dx * 2, height: height + dy * 2)
    }

    public func intersection(_ other: Rect) -> Rect {
        let newX = max(minX, other.minX)
        let newY = max(minY, other.minY)
        let newMaxX = min(maxX, other.maxX)
        let newMaxY = min(maxY, other.maxY)
        let newWidth = max(0, newMaxX - newX)
        let newHeight = max(0, newMaxY - newY)
        return Rect(x: newX, y: newY, width: newWidth, height: newHeight)
    }

    public func clamped(to boundary: Rect) -> Rect {
        let newX = max(boundary.minX, min(maxX - width, boundary.maxX - width))
        let newY = max(boundary.minY, min(maxY - height, boundary.maxY - height))
        let newWidth = min(width, boundary.width)
        let newHeight = min(height, boundary.height)
        return Rect(x: newX, y: newY, width: newWidth, height: newHeight)
    }

    public func padded(with padding: Double, within boundary: Rect) -> Rect {
        let expanded = expandedBy(dx: padding, dy: padding)
        let clamped = Rect(
            x: max(boundary.minX, min(expanded.x, boundary.maxX - expanded.width)),
            y: max(boundary.minY, min(expanded.y, boundary.maxY - expanded.height)),
            width: min(expanded.width, boundary.width),
            height: min(expanded.height, boundary.height)
        )
        return clamped
    }
}
