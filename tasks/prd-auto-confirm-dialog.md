# PRD: Auto-Confirm Browser Switch Dialog

## Introduction

Automatically dismiss the macOS confirmation dialog that appears when changing the default browser. When a user selects a browser in Browseroo, the app triggers the system API as normal, then uses AppleScript UI automation to click the confirmation button, providing a seamless one-click experience. Requires one-time Accessibility permission grant.

## Goals

- Eliminate manual confirmation clicks for better UX
- Provide near-instant browser switching experience
- Keep implementation simple using native AppleScript
- Gracefully handle cases where automation fails

## User Stories

### US-011: Request Accessibility permissions
**Description:** As a user, I need to grant Browseroo Accessibility permissions so it can automate the confirmation dialog.

**Acceptance Criteria:**
- [ ] Check for Accessibility permission using AXIsProcessTrusted()
- [ ] If not granted, show alert explaining why permission is needed
- [ ] Provide button to open System Settings > Privacy & Security > Accessibility
- [ ] App builds without errors using xcodebuild

### US-012: Implement AppleScript to click confirmation button
**Description:** As a developer, I need an AppleScript that finds and clicks the confirmation button in the default browser dialog.

**Acceptance Criteria:**
- [ ] Create AppleScript that targets the CoreServicesUIAgent confirmation dialog
- [ ] Script finds button containing "Use" text (e.g., "Use Chrome", "Use Safari")
- [ ] Script clicks the button to confirm the change
- [ ] Script handles case where dialog doesn't appear (already default)
- [ ] App builds without errors using xcodebuild

### US-013: Execute AppleScript after browser switch API call
**Description:** As a developer, I need to run the confirmation AppleScript immediately after calling LSSetDefaultHandlerForURLScheme.

**Acceptance Criteria:**
- [ ] After LSSetDefaultHandlerForURLScheme call, execute AppleScript via NSAppleScript
- [ ] Add small delay (100-200ms) to allow dialog to appear before running script
- [ ] Run AppleScript asynchronously to not block UI
- [ ] Handle AppleScript execution errors gracefully
- [ ] App builds without errors using xcodebuild

### US-014: Show permission status in menu
**Description:** As a user, I want to see if auto-confirm is enabled and working.

**Acceptance Criteria:**
- [ ] Add "Auto-Confirm" section or indicator in menu
- [ ] Show checkmark if Accessibility permission granted
- [ ] Show "Grant Permission..." option if not granted
- [ ] Clicking option opens permission request flow from US-011
- [ ] App builds without errors using xcodebuild

## Functional Requirements

- FR-1: Check Accessibility permission status using AXIsProcessTrusted() from ApplicationServices framework
- FR-2: Display permission request alert with explanation and button to open System Settings
- FR-3: Open System Settings directly to Accessibility pane using URL: `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`
- FR-4: Create AppleScript that:
  - Targets process "CoreServicesUIAgent" (the process that shows the dialog)
  - Finds the confirmation dialog window
  - Locates button whose name contains "Use"
  - Clicks that button
- FR-5: Execute AppleScript using NSAppleScript after LSSetDefaultHandlerForURLScheme call
- FR-6: Add 100-200ms delay before AppleScript execution to allow dialog to render
- FR-7: Run AppleScript on background thread to avoid blocking main UI
- FR-8: If AppleScript fails or permission not granted, silently fall back to manual confirmation (dialog stays visible)

## Non-Goals

- No automatic permission request on first launch (user-initiated only)
- No retry logic if AppleScript fails
- No localization of button text matching (English "Use" only for v1)
- No visual feedback during the brief automation moment

## Technical Considerations

- AppleScript execution requires `NSAppleScript` from Foundation
- Dialog is shown by `CoreServicesUIAgent` process, not by the browser or Browseroo
- Button text format is "Use [BrowserName]" - match on "Use" prefix
- Accessibility permission persists across app restarts once granted
- Consider using `DispatchQueue.main.asyncAfter` for the delay before running AppleScript
- AppleScript template:
  ```applescript
  tell application "System Events"
      tell process "CoreServicesUIAgent"
          set frontmost to true
          tell window 1
              click button 1
          end tell
      end tell
  end tell
  ```
- Alternative script targeting button by name:
  ```applescript
  tell application "System Events"
      tell process "CoreServicesUIAgent"
          click (first button of window 1 whose name starts with "Use")
      end tell
  end tell
  ```

## Success Metrics

- Confirmation dialog dismissed within 300ms of appearing
- User experiences single-click browser switching after granting permission
- Zero manual intervention required after one-time permission setup

## Open Questions

- Should we support non-English macOS localizations? (Button text varies by language)
- What's the exact delay needed for dialog to appear reliably?
- Should we verify the switch succeeded after AppleScript runs?

