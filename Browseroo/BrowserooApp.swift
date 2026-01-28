import SwiftUI

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
                    // TODO: Implement browser switching in US-006
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
        }
        .onAppear {
            refreshBrowserList()
        }
    }

    private func refreshBrowserList() {
        browsers = browserManager.getInstalledBrowsers()
        defaultBrowserID = browserManager.getDefaultBrowser()?.bundleIdentifier
    }
}
