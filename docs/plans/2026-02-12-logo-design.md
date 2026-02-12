# Browseroo Logo Design

## Summary

Add a polished, kangaroo-themed app icon and menu bar icon to Browseroo.

## App Icon

- **Shape**: Full-bleed square image (macOS applies the rounded rectangle mask)
- **Background**: Gradient from deep blue (#1a3a8a) at bottom-left to teal (#00b4d8) at top-right
- **Foreground**: White kangaroo silhouette, leaping right, centered with ~15% margin. Clean smooth curves, no fine detail.
- **Sizes**: 16, 32, 64, 128, 256, 512, 1024 pixels (to cover all @1x and @2x slots)
- **Location**: `Assets.xcassets/AppIcon.appiconset/`

## Menu Bar Icon

- **Style**: Monochrome template image (macOS handles light/dark mode automatically)
- **Content**: Same kangaroo silhouette, simplified for clarity at 18px
- **Format**: PNG with `Template` suffix for macOS template rendering
- **Sizes**: 18x18 @1x, 36x36 @2x
- **Location**: New `Assets.xcassets/MenuBarIcon.imageset/`

## AI Generation Prompt

> Minimal flat kangaroo silhouette, side profile leaping to the right, clean smooth vector curves, white on transparent background, no detail just the outline shape, suitable for an app icon, centered

Composite onto the gradient background and resize for the app icon. Use the white silhouette directly as the menu bar template image.

## Integration

- Populate `AppIcon.appiconset/Contents.json` with filename references for each size
- Create `MenuBarIcon.imageset/` with Contents.json and template PNGs
- Change `BrowserooApp.swift` from `systemImage: "globe"` to `image: "MenuBarIcon"`
