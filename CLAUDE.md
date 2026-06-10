# CLAUDE.md

macOS menu bar app (SwiftUI `MenuBarExtra`). Registers itself as the default browser and routes clicked links to the user-selected browser (Velja pattern) — it does NOT change the actual system default per browser. There is deliberately no confirmation-dialog/Accessibility hack; don't reintroduce one.

## Build & run

```bash
xcodebuild -project Browseroo.xcodeproj -scheme Browseroo build
```

## Local testing gotcha: duplicate app copies

Debug builds share the bundle ID `com.browseroo.Browseroo` with the installed `/Applications/Browseroo.app`. Because Browseroo is the default browser, LaunchServices may resolve the bundle ID to the DerivedData debug copy and launch it on the next clicked link → two menu bar instances.

After local testing, kill the debug instance and remove + unregister its bundle:

```bash
LSREG=/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister
"$LSREG" -u <DerivedData>/Build/Products/Debug/Browseroo.app && rm -rf <that path>
"$LSREG" -f /Applications/Browseroo.app
```

## Menu UI gotcha

Menu-style `MenuBarExtra` flattens `Button` labels to icon + text. Use `Toggle` for checkmark menu items; extra views (`Spacer`, conditional `Image`) are silently dropped.

## Release

Push a `v*` tag → GitHub Actions builds the DMG, creates the release, and bumps the Homebrew cask (`smauermann/homebrew-tap`) using a Costanza Bot app token minted at runtime (`GH_APP_ID` / `GH_APP_PRIVATE_KEY` secrets).
