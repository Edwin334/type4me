# TypeForMe Build Instructions

This document provides instructions for building and running TypeForMe on macOS.

## Prerequisites

- macOS 13.0 or later
- Swift 6.1 or later
- Xcode 15.0 or later (for development)

## Building

### Command Line Build

```bash
# Clone the repository
git clone <repository-url>
cd type4me-1

# Build the project
swift build

# Run tests (optional)
swift test
```

### Xcode Build

```bash
# Generate Xcode project
swift package generate-xcodeproj

# Open in Xcode
open TypeForMe.xcodeproj
```

## Configuration

### API Key Setup

Before running TypeForMe, you need to set up your Gemini API key:

1. Get a Gemini API key from [Google AI Studio](https://aistudio.google.com/)
2. Set the API key either:
   - As an environment variable: `export GEMINI_API_KEY="your-api-key-here"`
   - Through the Settings UI after launching the app

### Permissions

TypeForMe requires the following macOS permissions:

1. **Accessibility** - To read text selection and insert generated text
2. **Screen Recording** - To capture screenshots for context
3. **Input Monitoring** - To listen for global hotkeys

The app will prompt for these permissions on first launch.

## Running

### Development

```bash
# Run the app
swift run TypeForMe
```

### Production

```bash
# Build optimized release
swift build -c release

# Run the release build
.build/release/TypeForMe
```

## Architecture

TypeForMe is built with a modular architecture:

- **TypeForMeCore** - Core business logic and protocols
- **TypeForMe** - Platform-specific macOS implementation

### Key Components

1. **TypeForMeController** - Main orchestrator
2. **AccessibilityProvider** - Reads focused element and selection
3. **ScreenshotCapturer** - Captures active window screenshots
4. **GeminiClient** - Communicates with Gemini 2.0 Flash API
5. **InsertionEngine** - Inserts generated text via pasteboard or typing
6. **HUDManager** - Shows user feedback overlay
7. **HotKeyManager** - Handles global hotkey registration

## Default Hotkey

- **⌥⌘A** (Option+Command+A) - Trigger TypeForMe

## Troubleshooting

### Build Issues

1. Ensure you have the latest Swift toolchain
2. Clean and rebuild: `swift package clean && swift build`
3. Check for permission issues in macOS Security & Privacy settings

### Runtime Issues

1. Verify all required permissions are granted
2. Check that the Gemini API key is set correctly
3. Look for error messages in Console.app under the TypeForMe process

### Common Warnings

The build may show some warnings related to MainActor isolation. These are non-critical and don't affect functionality:

- HUD animation completion handler warnings
- Settings window controller initialization warnings
- Task capture warnings in hotkey handling

These warnings are due to strict Swift 6 concurrency checking and can be safely ignored for now.

## Testing

Run the comprehensive test suite:

```bash
swift test
```

The tests cover:
- Core business logic
- Platform-specific implementations
- Integration workflows
- Error handling scenarios

Note: Some tests that require system permissions (accessibility, screen recording) may fail in CI environments. This is expected behavior.
