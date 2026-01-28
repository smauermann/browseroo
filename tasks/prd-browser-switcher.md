# PRD: Browseroo - macOS Default Browser Switcher

## Introduction

Browseroo is a lightweight macOS menu bar application that allows users to quickly switch their default browser with a single click. Unlike complex browser management tools, Browseroo focuses on doing one thing well: making it effortless to change which browser opens when you click links in other applications.

This solves the pain of navigating through System Settings → Desktop & Dock → Default web browser every time you want to switch browsers—a common need for developers, designers, and power users who use different browsers for different contexts (work vs personal, testing, etc.).

## Goals

- Provide one-click default browser switching from the menu bar
- Display currently active default browser at a glance
- Auto-detect all installed browsers on the system
- Minimal resource footprint (< 20MB memory, negligible CPU)
- Native macOS experience using SwiftUI
- Open source and community-driven

## User Stories

### US-001: Create menu bar application shell
**Description:** As a user, I want the app to live in my menu bar so it doesn't clutter my dock or desktop.

**Acceptance Criteria:**
- [ ] App appears in menu bar with a browser icon
- [ ] App does not appear in the Dock
- [ ] App launches as a menu bar-only application (LSUIElement)
- [ ] Clicking the menu bar icon opens a dropdown menu
- [ ] App builds and runs without errors

### US-002: Detect installed browsers
**Description:** As a user, I want the app to automatically find all browsers installed on my Mac so I don't have to configure anything.

**Acceptance Criteria:**
- [ ] Detects browsers registered as HTTP/HTTPS handlers
- [ ] Retrieves browser name and icon for each detected browser
- [ ] Handles common browsers: Safari, Chrome, Firefox, Arc, Brave, Edge, Opera
- [ ] Gracefully handles browsers being installed/uninstalled
- [ ] App builds and runs without errors

### US-003: Display current default browser
**Description:** As a user, I want to see which browser is currently my default so I know the current state before switching.

**Acceptance Criteria:**
- [ ] Menu bar icon reflects current default browser (optional: use browser's icon)
- [ ] Dropdown menu shows checkmark next to current default browser
- [ ] Current default is determined on app launch and when menu opens
- [ ] App builds and runs without errors

### US-004: Switch default browser
**Description:** As a user, I want to click a browser name to make it my default so I can switch quickly.

**Acceptance Criteria:**
- [ ] Clicking a browser in the list sets it as the system default
- [ ] Visual feedback confirms the switch (checkmark moves)
- [ ] Switch happens without requiring System Settings interaction
- [ ] Uses LSSetDefaultHandlerForURLScheme or equivalent modern API
- [ ] App builds and runs without errors

### US-005: Add quit and about options
**Description:** As a user, I want standard app controls so I can quit the app or learn more about it.

**Acceptance Criteria:**
- [ ] Menu includes "About Browseroo" option
- [ ] About shows app version and link to GitHub repository
- [ ] Menu includes "Quit" option with keyboard shortcut (⌘Q)
- [ ] Separator divides browser list from utility options
- [ ] App builds and runs without errors

### US-006: Launch at login option
**Description:** As a user, I want Browseroo to start automatically when I log in so it's always available.

**Acceptance Criteria:**
- [ ] Menu includes "Launch at Login" toggle option
- [ ] Toggle state persists across app restarts
- [ ] Uses SMAppService (modern macOS) or LSSharedFileList for login item management
- [ ] Checkmark indicates current state
- [ ] App builds and runs without errors

### US-007: Keyboard navigation support
**Description:** As a user, I want to use keyboard shortcuts so I can switch browsers without using the mouse.

**Acceptance Criteria:**
- [ ] Arrow keys navigate the browser list when menu is open
- [ ] Enter/Return selects the highlighted browser
- [ ] Escape closes the menu
- [ ] Accessibility labels present for VoiceOver support
- [ ] App builds and runs without errors

## Functional Requirements

- FR-1: App must run as a menu bar agent (no Dock icon) using LSUIElement in Info.plist
- FR-2: App must query the system for all applications registered as HTTP/HTTPS URL handlers
- FR-3: App must retrieve the current default browser using LSCopyDefaultHandlerForURLScheme
- FR-4: App must set the default browser using LSSetDefaultHandlerForURLScheme for both http and https schemes
- FR-5: App must display each browser's icon and name in the dropdown menu
- FR-6: App must indicate the current default browser with a checkmark
- FR-7: App must support "Launch at Login" functionality using SMAppService (macOS 13+)
- FR-8: App must persist user preferences (launch at login state) using UserDefaults
- FR-9: App must refresh the browser list when the menu is opened to catch newly installed browsers

## Non-Goals

- No URL-based routing rules (route specific domains to specific browsers)
- No browser profiles or container support
- No link interception or "pick browser" prompts
- No browser usage statistics or tracking
- No sync across devices
- No preferences window—all settings in the menu
- No support for macOS versions before Ventura (13.0)

## Technical Considerations

- **Minimum macOS Version:** 13.0 (Ventura) for modern SwiftUI and SMAppService APIs
- **Architecture:** Universal binary (Apple Silicon + Intel)
- **Framework:** SwiftUI for UI, AppKit for menu bar integration where needed
- **APIs:**
  - `LSCopyDefaultHandlerForURLScheme` / `LSSetDefaultHandlerForURLScheme` for browser management
  - `NSWorkspace` for querying installed applications
  - `SMAppService` for login item management
- **Signing:** Developer ID signing for direct distribution (not sandboxed to allow setting default browser)
- **Build System:** Xcode project with Swift Package Manager for any dependencies

## Success Metrics

- App launches in under 1 second
- Memory usage stays under 20MB during normal operation
- Browser switch completes in under 500ms
- Zero crashes reported in first month of release
- Positive community reception (GitHub stars, forks)

## Open Questions

- Should the menu bar icon be the Browseroo logo or dynamically show the current browser's icon?
- Should there be a global keyboard shortcut to open the menu (requires accessibility permissions)?
- Should we support macOS 12 (Monterey) or require 13+ for cleaner APIs?

