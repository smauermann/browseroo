import AppKit

struct Browser: Identifiable, Equatable {
    let bundleIdentifier: String
    let name: String
    let icon: NSImage

    var id: String { bundleIdentifier }

    static func == (lhs: Browser, rhs: Browser) -> Bool {
        lhs.bundleIdentifier == rhs.bundleIdentifier
    }
}
