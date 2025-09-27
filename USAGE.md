# TypeForMe Usage Guide

TypeForMe is a macOS companion app that uses AI to help you write and edit text efficiently.

## Getting Started

### First Launch

1. Launch TypeForMe
2. Grant required permissions when prompted:
   - **Accessibility**: Allows reading text selection and inserting generated text
   - **Screen Recording**: Enables capturing context screenshots
   - **Input Monitoring**: Required for global hotkey functionality

3. Set up your Gemini API key:
   - Right-click the menu bar icon → Settings
   - Enter your API key from [Google AI Studio](https://aistudio.google.com/)

### Basic Usage

TypeForMe has two main modes:

#### Autowrite Mode (No Selection)
- Place your cursor in any text field
- Press **⌥⌘A** (Option+Command+A)
- TypeForMe captures a screenshot and generates appropriate text
- The generated text is inserted at your cursor

#### Edit Mode (Text Selected)
- Select text you want to improve
- Press **⌥⌘A**
- TypeForMe analyzes the selection and context
- The selected text is replaced with an improved version

## Features

### Context-Aware Generation
TypeForMe automatically detects the type of application and context:
- Email composition
- Chat messages
- Document writing
- Form filling
- And more...

### Style Preferences
Customize your writing style through Settings:
- **Tone**: Neutral, Warm, or Direct
- **Brevity**: Short, Medium, or Long responses
- **Greetings**: Auto, None, or Custom
- **Sign-off**: Auto, None, or Custom
- **Avoid**: List phrases to avoid

### Visual Feedback
- **"Drafting..."** - Generating new text
- **"Rewriting..."** - Editing selected text
- **Error indicators** - For permission or API issues

## Menu Bar Controls

Right-click the TypeForMe menu bar icon to access:
- **Settings** - Configure API key and style preferences
- **Pause/Resume** - Temporarily disable the hotkey
- **Quit** - Exit TypeForMe

## Supported Applications

TypeForMe works with any macOS application that accepts text input:
- Mail.app
- Safari (web forms, Gmail, etc.)
- Chrome/Firefox
- Slack
- Discord
- Notes.app
- TextEdit
- Microsoft Office
- And many more...

## Privacy & Security

### Data Processing
- Screenshots are processed locally and sent only to Google's Gemini API
- No data is stored on external servers
- Original clipboard content is preserved

### Secure Fields
TypeForMe automatically detects and skips secure fields like:
- Password fields
- Credit card inputs
- Other sensitive form fields

### Local Storage
- Style preferences stored locally in `~/Library/Application Support/TypeForMe/`
- API key stored in macOS Keychain (when using Settings UI)

## Tips & Best Practices

### For Best Results
1. **Provide context**: Include relevant information in your text field
2. **Use descriptive selections**: When editing, select complete thoughts
3. **Adjust style settings**: Customize for your communication style

### Troubleshooting
- **No response**: Check your API key and internet connection
- **Wrong context**: Ensure the correct application window is active
- **Permission errors**: Verify all required permissions are granted

### Hotkey Conflicts
If ⌥⌘A conflicts with other applications:
1. Check System Settings → Keyboard → Shortcuts
2. Resolve conflicts or choose a different hotkey
3. The app will warn about potential conflicts

## Advanced Usage

### Custom Prompting
While TypeForMe doesn't expose direct prompt editing, you can influence generation by:
- Including context in nearby text
- Using consistent style patterns
- Setting appropriate style preferences

### Workflow Integration
TypeForMe works well with:
- Text expansion utilities
- Grammar checkers
- Writing assistants
- Email templates

## Limitations

### Current Limitations
- Single hotkey configuration
- No custom prompt templates
- No offline mode
- Requires active internet connection

### Known Issues
- Some applications may not support pasteboard insertion
- Hotkey may not work in certain system contexts
- Large images may take longer to process

## Support

For issues or feature requests:
1. Check the BUILD.md for troubleshooting steps
2. Verify all permissions are granted
3. Test with a simple text application like TextEdit
4. Check Console.app for error messages

## Updates

TypeForMe checks for updates through the built-in system. Future versions may include:
- Configurable hotkeys
- Additional AI models
- Enhanced context detection
- Custom prompt templates
