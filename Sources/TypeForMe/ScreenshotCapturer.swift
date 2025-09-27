import AppKit
import ApplicationServices
import CoreGraphics
import TypeForMeCore
import UniformTypeIdentifiers

enum ScreenshotError: Error {
    case unableToCreateImage
    case unableToGetActiveWindow
    case unableToConvertImage
}

class ScreenshotCapturer: ScreenshotCapturing {
    private let maxWidth: CGFloat = 1024
    private let jpegQuality: CGFloat = 0.85
    
    func captureActiveWindow(region: Rect) throws -> Screenshot {
        // Check for screen recording permission by testing image creation
        let testDisplayID = CGMainDisplayID()
        guard CGDisplayCreateImage(testDisplayID) != nil else {
            throw ScreenshotError.unableToCreateImage
        }
        
        // Get the active window - capture full window, no cropping
        guard let windowImage = captureActiveWindowImage() else {
            throw ScreenshotError.unableToCreateImage
        }
        
        // Skip cropping for now to get full context
        // let croppedImage = cropImage(windowImage, to: region)
        
        // Resize to fit within maxWidth but keep it larger
        let resizedImage = resizeImage(windowImage, maxWidth: 1600) // Increased from 1024
        
        // Convert to JPEG data
        guard let jpegData = convertToJPEG(resizedImage, quality: jpegQuality) else {
            throw ScreenshotError.unableToConvertImage
        }
        
        return Screenshot(
            data: jpegData,
            format: .jpeg,
            originalRect: region
        )
    }
    
    private func captureActiveWindowImage() -> CGImage? {
        // Get window list for active application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let windowListInfo = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[String: Any]]
        
        // Find the frontmost window of the active application
        var targetWindowID: CGWindowID?
        
        for windowInfo in windowListInfo ?? [] {
            if let pid = windowInfo[kCGWindowOwnerPID as String] as? Int32,
               pid == frontmostApp.processIdentifier,
               let layer = windowInfo[kCGWindowLayer as String] as? Int,
               layer == 0, // Main window layer
               let windowID = windowInfo[kCGWindowNumber as String] as? CGWindowID {
                targetWindowID = windowID
                break
            }
        }
        
        guard let windowID = targetWindowID else {
            // Fallback to capturing main display
            return CGDisplayCreateImage(CGMainDisplayID())
        }
        
        // Capture the specific window
        return CGWindowListCreateImage(
            CGRect.null,
            .optionIncludingWindow,
            windowID,
            [.boundsIgnoreFraming, .bestResolution]
        )
    }
    
    private func cropImage(_ image: CGImage, to region: Rect) -> CGImage {
        // Convert Rect to CGRect
        let cropRect = CGRect(x: region.x, y: region.y, width: region.width, height: region.height)
        
        // Ensure crop rect is within image bounds
        let imageRect = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let clampedCropRect = cropRect.intersection(imageRect)
        
        if clampedCropRect.isEmpty {
            return image
        }
        
        return image.cropping(to: clampedCropRect) ?? image
    }
    
    private func resizeImage(_ image: CGImage, maxWidth: CGFloat) -> CGImage {
        let currentWidth = CGFloat(image.width)
        let currentHeight = CGFloat(image.height)
        
        // If image is already smaller than maxWidth, return as-is
        if currentWidth <= maxWidth {
            return image
        }
        
        // Calculate new dimensions maintaining aspect ratio
        let scale = maxWidth / currentWidth
        let newWidth = Int(currentWidth * scale)
        let newHeight = Int(currentHeight * scale)
        
        // Create graphics context
        guard let colorSpace = image.colorSpace,
              let context = CGContext(
                data: nil,
                width: newWidth,
                height: newHeight,
                bitsPerComponent: image.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: image.bitmapInfo.rawValue
              ) else {
            return image
        }
        
        // Draw resized image
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        return context.makeImage() ?? image
    }
    
    private func convertToJPEG(_ image: CGImage, quality: CGFloat) -> Data? {
        let mutableData = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(
            mutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }
        
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        
        CGImageDestinationAddImage(destination, image, options as CFDictionary)
        
        if CGImageDestinationFinalize(destination) {
            return mutableData as Data
        }
        
        return nil
    }
}
