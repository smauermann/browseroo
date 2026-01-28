import SwiftUI
import AppKit

@main
struct BrowserooApp: App {
    var body: some Scene {
        MenuBarExtra("Browseroo", systemImage: "globe") {
            BrowserMenuView()
        }
    }
}

struct BrowserMenuView: View {
    @State private var browsers: [Browser] = []
    @State private var defaultBrowserID: String?

    private let browserManager = BrowserManager()

    var body: some View {
        Group {
            ForEach(browsers) { browser in
                Button(action: {
                    switchToBrowser(browser)
                }) {
                    HStack {
                        Image(nsImage: browser.icon)
                        Text(browser.name)
                        Spacer()
                        if browser.bundleIdentifier == defaultBrowserID {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            Divider()

            Button("About Browseroo") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.orderFrontStandardAboutPanel(options: [
                    .applicationName: "Browseroo",
                    .applicationVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0",
                    .version: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1",
                    .copyright: "© 2026 Browseroo. All rights reserved."
                ])
            }

            Button("Quit Browseroo") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .onAppear {
            refreshBrowserList()
        }
    }

    private func refreshBrowserList() {
        browsers = browserManager.getInstalledBrowsers()
        defaultBrowserID = browserManager.getDefaultBrowser()?.bundleIdentifier
    }

    private func switchToBrowser(_ browser: Browser) {
        browserManager.setDefaultBrowser(bundleIdentifier: browser.bundleIdentifier)
        defaultBrowserID = browser.bundleIdentifier
    }
}
