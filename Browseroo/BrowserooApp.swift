import SwiftUI
import AppKit
import ServiceManagement

@main
struct BrowserooApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Browseroo", image: "MenuBarIcon") {
            BrowserMenuView()
        }
    }
}

/// Receives URLs from macOS (Browseroo is registered as a browser)
/// and forwards them to the user's selected browser.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        let selectedID = UserDefaults.standard.string(forKey: "selectedBrowserID") ?? "com.apple.Safari"
        BrowserManager().open(urls, inBrowserWithBundleID: selectedID)
    }
}

struct BrowserMenuView: View {
    @AppStorage("selectedBrowserID") private var selectedBrowserID: String = ""
    @State private var browsers: [Browser] = []
    @State private var isBrowserooDefault: Bool = false
    @State private var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    private let browserManager = BrowserManager()

    var body: some View {
        Group {
            ForEach(browsers) { browser in
                // Toggle renders the native menu checkmark; Button labels in
                // menus are flattened to icon + text, dropping any extra views.
                Toggle(isOn: Binding(
                    get: { isSelected(browser) },
                    set: { if $0 { selectedBrowserID = browser.bundleIdentifier } }
                )) {
                    Image(nsImage: browser.icon)
                        .accessibilityHidden(true)
                    Text(browser.name)
                }
                .accessibilityLabel(isSelected(browser)
                    ? "\(browser.name), current browser"
                    : browser.name)
                .accessibilityHint("Double tap to open links in this browser")
            }

            Divider()

            if !isBrowserooDefault {
                Button("Set Browseroo as Default Browser…") {
                    browserManager.makeBrowserooDefault()
                    // The system shows a one-time confirmation dialog; reflect
                    // the result shortly after the user has responded.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isBrowserooDefault = browserManager.isBrowserooDefault
                    }
                }
                .accessibilityHint("Required so Browseroo can route links to your selected browser")

                Divider()
            }

            Toggle("Launch at Login", isOn: Binding(
                get: { launchAtLogin },
                set: { _ in toggleLaunchAtLogin() }
            ))
            .accessibilityHint("Double tap to toggle")

            Divider()

            Button("About Browseroo") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.orderFrontStandardAboutPanel(options: [
                    .applicationName: "Browseroo",
                    .applicationVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
                    .version: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
                ])
            }
            .accessibilityLabel("About Browseroo")
            .accessibilityHint("Double tap to show application information")

            Button("Quit Browseroo") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .accessibilityLabel("Quit Browseroo")
            .accessibilityHint("Double tap to quit the application")
        }
        .onAppear {
            refreshState()
        }
    }

    private func refreshState() {
        browsers = browserManager.getInstalledBrowsers()
        isBrowserooDefault = browserManager.isBrowserooDefault
        launchAtLogin = SMAppService.mainApp.status == .enabled

        // First run: seed the selection from the current system default
        // (before Browseroo takes over), falling back to the first browser.
        if selectedBrowserID.isEmpty {
            let systemDefault = browserManager.getDefaultBrowser()
            if let systemDefault, browsers.contains(systemDefault) {
                selectedBrowserID = systemDefault.bundleIdentifier
            } else if let first = browsers.first {
                selectedBrowserID = first.bundleIdentifier
            }
        }
    }

    private func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
            launchAtLogin = SMAppService.mainApp.status == .enabled
        } catch {
            // Silently handle errors - the UI will reflect the actual state
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    private func isSelected(_ browser: Browser) -> Bool {
        browser.bundleIdentifier.caseInsensitiveCompare(selectedBrowserID) == .orderedSame
    }
}
