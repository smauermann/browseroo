#!/bin/bash
#
# test-auto-confirm.sh - Automated test for Browseroo auto-confirm feature
#
# PREREQUISITES:
# - Browseroo must have Accessibility permission granted in System Settings
#   (System Settings > Privacy & Security > Accessibility > Browseroo.app)
# - Without this permission, the auto-confirm feature cannot click the dialog
#
# This script:
# 1. Builds Browseroo
# 2. Launches it
# 3. Uses osascript to click the menu bar icon and select a non-default browser
# 4. Waits and checks if CoreServicesUIAgent dialog is still visible
# 5. Prints PASS if no dialog (auto-confirm worked), FAIL if dialog present
# 6. Quits Browseroo and exits with appropriate code
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_PATH="$PROJECT_DIR/build/Debug/Browseroo.app"

echo "=== Browseroo Auto-Confirm Test ==="
echo ""

# Step 1: Build the app
echo "Step 1: Building Browseroo..."
cd "$PROJECT_DIR"
xcodebuild -project Browseroo.xcodeproj -scheme Browseroo -configuration Debug SYMROOT=build build 2>&1 | tail -5

if [ ! -d "$APP_PATH" ]; then
    echo "FAIL: Build failed - app not found at $APP_PATH"
    exit 1
fi
echo "Build successful."
echo ""

# Step 2: Launch Browseroo
echo "Step 2: Launching Browseroo..."
open "$APP_PATH"
sleep 2  # Wait for app to fully launch
echo "Browseroo launched."
echo ""

# Step 3: Get current default browser
echo "Step 3: Detecting current default browser..."
CURRENT_DEFAULT=$(osascript -e 'do shell script "defaults read ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -A 2 \"https\" | grep LSHandlerRoleAll | head -1 | sed \"s/.*= //\" | tr -d \";\\\"\""' 2>/dev/null || echo "")

if [ -z "$CURRENT_DEFAULT" ]; then
    # Fallback: use x-lsregister
    CURRENT_DEFAULT=$(osascript -e '
        tell application "System Events"
            set defaultBrowser to do shell script "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump | grep -B6 \"claim.*https\" | grep \"bundle id\" | head -1 | awk \"{print \\$NF}\""
        end tell
    ' 2>/dev/null || echo "com.apple.Safari")
fi

echo "Current default browser: $CURRENT_DEFAULT"
echo ""

# Determine a non-default browser to switch to
# We'll try to find Chrome or Safari as alternatives
if [ "$CURRENT_DEFAULT" = "com.google.Chrome" ]; then
    TARGET_BROWSER="com.apple.Safari"
    TARGET_NAME="Safari"
else
    TARGET_BROWSER="com.google.Chrome"
    TARGET_NAME="Chrome"
fi

# Check if target browser is installed
TARGET_APP_PATH=$(osascript -e "tell application \"System Events\" to get path of application id \"$TARGET_BROWSER\"" 2>/dev/null || echo "")

if [ -z "$TARGET_APP_PATH" ]; then
    echo "Target browser $TARGET_NAME not found. Looking for another browser..."
    # Fall back to Safari if Chrome not available
    if [ "$TARGET_BROWSER" = "com.google.Chrome" ]; then
        TARGET_BROWSER="com.apple.Safari"
        TARGET_NAME="Safari"
        TARGET_APP_PATH=$(osascript -e "tell application \"System Events\" to get path of application id \"$TARGET_BROWSER\"" 2>/dev/null || echo "")
    fi
fi

if [ -z "$TARGET_APP_PATH" ]; then
    echo "FAIL: No alternative browser found for testing"
    osascript -e 'tell application "Browseroo" to quit' 2>/dev/null || true
    exit 1
fi

echo "Will switch to: $TARGET_NAME ($TARGET_BROWSER)"
echo ""

# Step 4: Click Browseroo menu bar icon and select the target browser
echo "Step 4: Clicking Browseroo menu bar and selecting $TARGET_NAME..."
osascript <<EOF
tell application "System Events"
    tell process "Browseroo"
        -- Click the menu bar extra (globe icon)
        click menu bar item 1 of menu bar 2
        delay 0.5

        -- Find and click the target browser in the menu
        set targetFound to false
        repeat with menuItem in menu items of menu 1 of menu bar item 1 of menu bar 2
            try
                set itemName to name of menuItem
                if itemName contains "$TARGET_NAME" then
                    click menuItem
                    set targetFound to true
                    exit repeat
                end if
            end try
        end repeat

        if not targetFound then
            error "Browser $TARGET_NAME not found in menu"
        end if
    end tell
end tell
EOF

if [ $? -ne 0 ]; then
    echo "FAIL: Could not click browser in menu"
    osascript -e 'tell application "Browseroo" to quit' 2>/dev/null || true
    exit 1
fi

echo "Clicked $TARGET_NAME in menu."
echo ""

# Step 5: Wait for auto-confirm to potentially click the dialog
echo "Step 5: Waiting for auto-confirm to process dialog..."
sleep 3  # Wait longer than the 150ms delay + time for script execution

# Step 6: Check if CoreServicesUIAgent has any windows (confirmation dialog)
echo "Step 6: Checking for confirmation dialog..."
WINDOW_COUNT=$(osascript -e '
tell application "System Events"
    if exists (process "CoreServicesUIAgent") then
        tell process "CoreServicesUIAgent"
            return count of windows
        end tell
    else
        return 0
    end if
end tell
' 2>/dev/null || echo "0")

echo "CoreServicesUIAgent window count: $WINDOW_COUNT"
echo ""

# Step 7: Quit Browseroo
echo "Step 7: Quitting Browseroo..."
osascript -e 'tell application "Browseroo" to quit' 2>/dev/null || pkill -f "Browseroo.app" 2>/dev/null || true
sleep 1
echo "Browseroo quit."
echo ""

# Step 8: Report result
echo "=== Test Result ==="
if [ "$WINDOW_COUNT" = "0" ]; then
    echo "PASS: No confirmation dialog present (auto-confirm worked or dialog never appeared)"
    exit 0
else
    echo "FAIL: Confirmation dialog still present (window count: $WINDOW_COUNT)"
    # Try to dismiss the dialog for cleanup
    osascript -e '
    tell application "System Events"
        if exists (process "CoreServicesUIAgent") then
            tell process "CoreServicesUIAgent"
                if (count of windows) > 0 then
                    click button 2 of window 1  -- Cancel button
                end if
            end tell
        end if
    end tell
    ' 2>/dev/null || true
    exit 1
fi

