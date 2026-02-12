# Browseroo

A macOS menu bar app for switching your default browser in one click.

## Features

- Switch between installed browsers from the menu bar
- Auto-confirms the macOS default browser dialog (no manual clicking)
- Launch at Login support
- Lightweight — lives in the menu bar, no Dock icon

## Install

### Download

1. Grab `Browseroo-vX.X.X.dmg` from the [latest release](https://github.com/smauermann/browseroo/releases/latest)
2. Open the DMG and drag Browseroo to Applications
3. Launch Browseroo from Applications

> **Note:** macOS will block the first launch because the app is not signed with an Apple Developer certificate. To allow it:
> 1. Try to open Browseroo (it will be blocked)
> 2. Open **System Settings > Privacy & Security**
> 3. Scroll down to find *"Browseroo was blocked from use because it is not from an identified developer"*
> 4. Click **Open Anyway** and enter your password
>
> This only needs to be done once.

### Build from source

```bash
git clone https://github.com/smauermann/browseroo.git
cd browseroo
xcodebuild -project Browseroo.xcodeproj -scheme Browseroo -configuration Release SYMROOT=build build
open build/Release/Browseroo.app
```

## Setup

On first launch, Browseroo will appear in your menu bar as a kangaroo icon.

### Accessibility Permission (recommended)

For auto-confirm to work (automatically dismissing the "Use [Browser]?" dialog), grant Browseroo Accessibility permission:

1. Open **System Settings > Privacy & Security > Accessibility**
2. Click the **+** button and add Browseroo
3. Toggle it on

Without this permission, Browseroo still switches browsers — you'll just need to manually click the confirmation dialog each time.

## License

MIT
