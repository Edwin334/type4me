# TypeForMe

A local macOS companion that captures your screen context and generates AI-powered text using Gemini 2.5 Flash.

## Features

- **Global Hotkey**: Activate with ⌥⌘A (Option+Command+A)
- **Smart Context**: Screenshots active window for AI context
- **Two Modes**: 
  - Autowrite: Generate text when no text is selected
  - Edit: Rewrite selected text
- **Local & Private**: Runs entirely on your Mac, no external servers
- **Customizable Style**: Configure tone, brevity, greetings, and sign-offs
- **Menu Bar App**: Unobtrusive menu bar presence

## Quick Start

1. **Get a Gemini API Key**: Visit [Google AI Studio](https://makersuite.google.com/app/apikey) to get your free API key

2. **Build & Install**:
   ```bash
   # Build the Swift package
   swift build

   # Run the placeholder CLI (for smoke testing dependencies)
   swift run TypeForMeCLI

   # To integrate with a macOS AppKit target, open the package in Xcode
   open Package.swift
   ```

3. **Grant Permissions**: When prompted, grant:
   - Accessibility (read focused elements)
   - Screen Recording (capture context)
   - Input Monitoring (global hotkey)

4. **Configure**: Click the TypeForMe menu bar icon → Settings:
   - Enter your Gemini API key
   - Customize writing style preferences

5. **Use**: Press ⌥⌘A in any text field to generate or edit text

## How It Works

### Autowrite Mode (No Selection)
1. Press ⌥⌘A with cursor in empty text field
2. TypeForMe captures a screenshot of the active window
3. Sends image + style preferences to Gemini 2.5 Flash
4. Inserts generated text at cursor position

### Edit Mode (Text Selected) 
1. Select text you want to improve
2. Press ⌥⌘A 
3. TypeForMe captures screenshot + selected text
4. Gemini rewrites the selection according to your style preferences
5. Selected text is replaced with the improved version

## System Requirements

- macOS 13.0 or later
- Intel or Apple Silicon Mac
- Internet connection for Gemini API calls

## Privacy & Security

- **Local Processing**: All logic runs on your Mac
- **No Data Storage**: Screenshots and text aren't saved locally
- **Secure Fields**: Automatically blocked (password fields, etc.)
- **API Only**: Only sends data to Google's Gemini API
- **Open Source**: Full source code available for review

## Configuration

### Style Preferences
- **Tone**: Neutral, Warm, or Direct
- **Brevity**: Short, Medium, or Long responses
- **Greetings**: Auto, None, or Custom
- **Sign-offs**: Auto, None, or Custom
- **Avoid Terms**: Custom list of words/phrases to avoid

### Settings Location
Preferences are stored locally at:
```
~/Library/Application Support/TypeForMe/style.json
```

## Troubleshooting

### Permissions Issues
If hotkey doesn't work or text insertion fails:
1. Open System Settings → Privacy & Security
2. Grant permissions for:
   - Accessibility → TypeForMe
   - Screen Recording → TypeForMe  
   - Input Monitoring → TypeForMe

### API Key Issues
- Verify key is entered correctly in Settings
- Check internet connection
- Ensure Gemini API quota isn't exceeded

### Text Insertion Issues
- Some apps may block programmatic text insertion
- Try clicking in the text field first
- Use Cmd+Z to undo if needed

## Building from Source

Requirements:
- Xcode 15.0+ or Swift 5.9+
- macOS 13.0+ deployment target

```bash
# Clone and build
git clone <repository>
cd type4me
swift build -c release
swift test
```

## Automated Tests

All core modules have unit tests that can be executed locally:

```bash
swift test
```

Tests cover:
- Style preference persistence
- Prompt construction for both autowrite and edit modes
- Capture region heuristics
- Pasteboard insertion with fallback typing
- The full invocation controller, including permission, secure-field, and empty-response flows

## Architecture

TypeForMe follows the simplified MVP design:

1. **HotkeyManager**: Global hotkey registration (⌥⌘A)
2. **ContextGrabber**: Screenshot capture + accessibility integration
3. **GeminiClient**: Single API call to Gemini 2.5 Flash
4. **InsertionEngine**: Text insertion via pasteboard or typing simulation
5. **HUDManager**: Minimal status overlay
6. **StylePreferences**: Local configuration storage

## API Usage

TypeForMe uses Gemini 2.5 Flash with:
- Single request per activation (no chains)
- Screenshots resized to max 1024px width
- JPEG compression at 85% quality
- Temperature: 0.2 for consistent output
- Max tokens: 512

## License

MIT License - see LICENSE file for details

## Support

For issues, feature requests, or questions:
- Open an issue in the repository
- Check troubleshooting section above
- Verify system requirements and permissions

---

**Note**: TypeForMe requires a Gemini API key which may incur costs based on Google's pricing. The app is designed to minimize API usage with efficient image compression and single-call architecture.
# type4me
