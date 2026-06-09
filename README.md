# Browseroo

A macOS menu bar app for switching your browser in one click.

Browseroo registers itself as your default browser and routes every link to the browser you've selected in the menu bar. Switching is instant — no system dialogs, no extra permissions.

## Features

- Switch between installed browsers from the menu bar
- No confirmation dialogs and no Accessibility permission needed
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

Click the icon and choose **Set Browseroo as Default Browser…**, then confirm the system dialog. This is the only prompt you'll ever see — from then on, Browseroo forwards every clicked link to whichever browser you've selected in the menu.

> **Note:** System Settings will show Browseroo as your default browser. That's how the routing works — your selected browser still opens all links.

## License

MIT
