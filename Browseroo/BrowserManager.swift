import AppKit
import CoreServices

class BrowserManager {
    // Known browser bundle identifiers (whitelist approach for accuracy)
    private static let knownBrowserBundleIDs: Set<String> = [
        "com.apple.Safari",
        "com.google.Chrome",
        "com.google.Chrome.canary",
        "org.mozilla.firefox",
        "org.mozilla.firefoxdeveloperedition",
        "org.mozilla.nightly",
        "com.microsoft.edgemac",
        "com.microsoft.edgemac.Beta",
        "com.microsoft.edgemac.Dev",
        "com.microsoft.edgemac.Canary",
        "com.operasoftware.Opera",
        "com.operasoftware.OperaGX",
        "com.brave.Browser",
        "com.brave.Browser.beta",
        "com.brave.Browser.nightly",
        "com.vivaldi.Vivaldi",
        "com.vivaldi.Vivaldi.snapshot",
        "company.thebrowser.Browser",  // Arc
        "org.chromium.Chromium",
        "com.electron.AminoBrowser", // Amino
        "io.sigmaos.sigmaos", // SigmaOS
        "com.nickvision.nicegopher.nicegopher", // NiceGopher
        "org.torproject.torbrowser", // Tor Browser
        "com.nickvision.nicegopher", // NiceGopher
        "io.nickvision.nicegopher",
        "org.nickvision.nicegopher",
        "com.nickvision.nicegopher.macos",
        "net.imput.helium", // Helium
    ]

    /// Returns an array of installed browsers detected on the system.
    func getInstalledBrowsers() -> [Browser] {
        var browsers: [Browser] = []
        var seenBundleIDs = Set<String>()

        // Get all handlers for https scheme
        guard let handlers = LSCopyAllHandlersForURLScheme("https" as CFString)?.takeRetainedValue() as? [String] else {
            return browsers
        }

        for bundleID in handlers {
            let lowercasedID = bundleID.lowercased()

            // Skip if already processed
            guard !seenBundleIDs.contains(lowercasedID) else { continue }
            seenBundleIDs.insert(lowercasedID)

            // Only include known browsers
            guard Self.knownBrowserBundleIDs.contains(bundleID) else { continue }

            // Get app URL and info
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                continue
            }

            // Get app name from bundle
            guard let bundle = Bundle(url: appURL),
                  let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
                continue
            }

            // Get app icon
            let icon = NSWorkspace.shared.icon(forFile: appURL.path)
            icon.size = NSSize(width: 16, height: 16)

            let browser = Browser(
                bundleIdentifier: bundleID,
                name: name,
                icon: icon
            )
            browsers.append(browser)
        }

        // Sort alphabetically by name
        browsers.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return browsers
    }

    /// True if Browseroo is the system default handler for https.
    var isBrowserooDefault: Bool {
        guard let bundleID = Bundle.main.bundleIdentifier,
              let defaultID = LSCopyDefaultHandlerForURLScheme("https" as CFString)?.takeRetainedValue() as String? else {
            return false
        }
        return defaultID.caseInsensitiveCompare(bundleID) == .orderedSame
    }

    /// Asks macOS to make Browseroo the default browser.
    /// Shows the system confirmation dialog once; after that, switching
    /// browsers is handled internally and never prompts again.
    func makeBrowserooDefault() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        LSSetDefaultHandlerForURLScheme("http" as CFString, bundleID as CFString)
        LSSetDefaultHandlerForURLScheme("https" as CFString, bundleID as CFString)
    }

    /// Opens the given URLs in the browser with the given bundle ID.
    /// Falls back to Safari if that browser is not installed.
    func open(_ urls: [URL], inBrowserWithBundleID bundleID: String) {
        // Never route to ourselves to avoid an open-URL loop.
        guard bundleID.caseInsensitiveCompare(Bundle.main.bundleIdentifier ?? "") != .orderedSame else { return }

        let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
            ?? NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.Safari")
        guard let appURL else { return }

        NSWorkspace.shared.open(urls, withApplicationAt: appURL, configuration: NSWorkspace.OpenConfiguration())
    }

    /// Returns the current default browser, or nil if it cannot be determined.
    func getDefaultBrowser() -> Browser? {
        // Get the default handler for https scheme
        guard let defaultBundleID = LSCopyDefaultHandlerForURLScheme("https" as CFString)?.takeRetainedValue() as String? else {
            return nil
        }

        // Get app URL and info
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: defaultBundleID) else {
            return nil
        }

        // Get app name from bundle
        guard let bundle = Bundle(url: appURL),
              let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
            return nil
        }

        // Get app icon
        let icon = NSWorkspace.shared.icon(forFile: appURL.path)
        icon.size = NSSize(width: 16, height: 16)

        return Browser(
            bundleIdentifier: defaultBundleID,
            name: name,
            icon: icon
        )
    }
}

