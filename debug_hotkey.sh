#!/bin/bash

echo "🔍 TypeForMe Hotkey Debug Test"
echo "=============================="
echo

echo "Starting TypeForMe in debug mode..."
echo "Please press ⌥⌘A when the app is running to test the hotkey."
echo "The app will show detailed error output if it crashes."
echo

# Set a dummy API key to test the workflow
export GEMINI_API_KEY="test-key-for-debugging"

# Run with debug output
.build/release/TypeForMe &
APP_PID=$!

echo "✅ App started with PID: $APP_PID"
echo "📋 Status: Ready to test hotkey (⌥⌘A)"
echo "⚠️  Note: You may see permission dialogs - this is normal"
echo

# Wait for user to test
read -p "Press Enter after testing the hotkey to continue..."

# Check if app is still running
if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ App is still running - no crash detected!"
    kill $APP_PID
    echo "🛑 App terminated cleanly"
else
    echo "❌ App crashed during hotkey test"
    echo "💡 Check Console.app for crash logs: TypeForMe"
fi

echo
echo "🔍 Debug Summary:"
echo "- If app crashed: Check accessibility and screen recording permissions"  
echo "- If permissions dialog appeared: Grant them and try again"
echo "- If no crash: The hotkey safety improvements worked!"
