import AppKit
import ApplicationServices

class AccessibilityManager {
    /// Checks if Accessibility permission has been granted.
    /// Uses AXIsProcessTrusted() from ApplicationServices framework.
    static func isAccessibilityGranted() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Shows an alert explaining why Accessibility permission is needed
    /// and provides a button to open System Settings.
    static func showAccessibilityAlert() {
        NSApplication.shared.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Browseroo needs Accessibility permission to automatically confirm the default browser change dialog. Without this permission, you'll need to manually click 'Use [Browser]' each time you switch browsers."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Not Now")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }

    /// Opens System Settings to the Accessibility section in Privacy & Security.
    static func openAccessibilitySettings() {
        // macOS 13+ uses the new System Settings URL scheme
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

