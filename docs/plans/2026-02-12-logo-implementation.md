# Browseroo Logo Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a kangaroo-themed app icon and menu bar icon to Browseroo.

**Architecture:** Generate a white kangaroo silhouette via AI, composite it onto a blue-to-teal gradient for the app icon at all required sizes, and use the raw silhouette as a monochrome template image for the menu bar. Wire both into the Xcode asset catalog.

**Tech Stack:** AI image generation (external), sips/ImageMagick for resizing, Xcode asset catalog (JSON + PNGs), SwiftUI MenuBarExtra.

---

### Task 1: Generate the kangaroo silhouette

**Files:**
- Create: `assets/kangaroo-silhouette-1024.png` (working file, not checked in)

**Step 1: Generate the image**

Use an AI image generator (DALL-E, Midjourney, etc.) with this prompt:

> Minimal flat kangaroo silhouette, side profile leaping to the right, clean smooth vector curves, white on transparent background, no detail just the outline shape, suitable for an app icon, centered

Generate at 1024x1024 or larger. Save as `assets/kangaroo-silhouette-1024.png`.

**Step 2: Verify the image**

Open it and confirm:
- White silhouette on transparent background
- Clean edges, no artifacts
- Centered with some margin
- Recognizable as a kangaroo at small sizes (zoom out to check)

If not satisfactory, regenerate with adjusted prompt.

---

### Task 2: Create app icon images

**Files:**
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_16.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_32.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_64.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_128.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_256.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_512.png`
- Create: `Browseroo/Assets.xcassets/AppIcon.appiconset/icon_1024.png`

**Step 1: Create the 1024px composite**

Using an image editor or ImageMagick, composite the kangaroo silhouette onto a gradient background:
- Background: Linear gradient from #1a3a8a (bottom-left) to #00b4d8 (top-right)
- Foreground: White kangaroo silhouette, centered, ~15% margin on each side
- Output: 1024x1024 PNG

Example with ImageMagick:
```bash
# Create gradient background
magick -size 1024x1024 gradient:'#00b4d8'-'#1a3a8a' -rotate 135 bg.png

# Resize silhouette to fit with margin (~700px wide within 1024)
magick assets/kangaroo-silhouette-1024.png -resize 700x700 -gravity center silhouette_resized.png

# Composite
magick bg.png silhouette_resized.png -gravity center -composite icon_1024.png
```

**Step 2: Resize to all required sizes**

```bash
cd Browseroo/Assets.xcassets/AppIcon.appiconset/
for size in 16 32 64 128 256 512; do
    sips -z $size $size icon_1024.png --out icon_${size}.png
done
```

**Step 3: Verify icons look good at all sizes**

Open each file. The silhouette should be recognizable even at 16x16 and 32x32. If not, consider simplifying the silhouette for the smallest sizes.

---

### Task 3: Update AppIcon.appiconset Contents.json

**Files:**
- Modify: `Browseroo/Assets.xcassets/AppIcon.appiconset/Contents.json`

**Step 1: Replace Contents.json with filename references**

Replace the entire file with:

```json
{
  "images" : [
    {
      "filename" : "icon_16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_1024.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**Step 2: Verify in Xcode**

Open the project in Xcode and navigate to Assets.xcassets > AppIcon. All slots should show the kangaroo icon with no warnings.

**Step 3: Commit**

```bash
git add Browseroo/Assets.xcassets/AppIcon.appiconset/
git commit -m "feat: add kangaroo app icon"
```

---

### Task 4: Create menu bar template icon

**Files:**
- Create: `Browseroo/Assets.xcassets/MenuBarIcon.imageset/Contents.json`
- Create: `Browseroo/Assets.xcassets/MenuBarIcon.imageset/MenuBarIconTemplate.png`
- Create: `Browseroo/Assets.xcassets/MenuBarIcon.imageset/MenuBarIconTemplate@2x.png`

**Step 1: Create the template images**

Menu bar icons on macOS should be:
- Black silhouette on transparent background (macOS inverts for dark mode when it's a template image)
- 18x18 @1x, 36x36 @2x
- The `template` rendering mode is set in Contents.json

Starting from the white silhouette, invert to black and resize:

```bash
# Invert white to black
magick assets/kangaroo-silhouette-1024.png -negate kangaroo_black.png

# Resize for menu bar
magick kangaroo_black.png -resize 18x18 MenuBarIconTemplate.png
magick kangaroo_black.png -resize 36x36 MenuBarIconTemplate@2x.png
```

Move the files into the imageset directory.

**Step 2: Create Contents.json**

Create `Browseroo/Assets.xcassets/MenuBarIcon.imageset/Contents.json`:

```json
{
  "images" : [
    {
      "filename" : "MenuBarIconTemplate.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "MenuBarIconTemplate@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "template-rendering-intent" : "template"
  }
}
```

The `template-rendering-intent` tells macOS to treat this as a template image (auto light/dark mode).

**Step 3: Commit**

```bash
git add Browseroo/Assets.xcassets/MenuBarIcon.imageset/
git commit -m "feat: add kangaroo menu bar template icon"
```

---

### Task 5: Wire up the menu bar icon in code

**Files:**
- Modify: `Browseroo/BrowserooApp.swift:8`

**Step 1: Change the MenuBarExtra initializer**

In `Browseroo/BrowserooApp.swift`, line 8, change:

```swift
MenuBarExtra("Browseroo", systemImage: "globe") {
```

to:

```swift
MenuBarExtra("Browseroo", image: "MenuBarIcon") {
```

**Step 2: Build and verify**

```bash
xcodebuild -project Browseroo.xcodeproj -scheme Browseroo -configuration Debug build
open build/Debug/Browseroo.app
```

Verify:
- Menu bar shows the kangaroo silhouette (not the globe)
- Icon adapts to light/dark mode
- App icon in Finder/Dock shows the kangaroo on gradient background

**Step 3: Commit**

```bash
git add Browseroo/BrowserooApp.swift
git commit -m "feat: use kangaroo icon in menu bar"
```
