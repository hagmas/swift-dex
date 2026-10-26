import AppKit
import SwiftUI

// Run with `swift run --package-path Examples/LoomLab LoomLab`, adding
// `--autoplay` to play every way of appearing, print what the frame meter
// saw, and quit.

private final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

MainActor.assumeIsolated {
    let autoplay = CommandLine.arguments.contains("--autoplay")
    let delegate = AppDelegate()

    let app = NSApplication.shared
    app.delegate = delegate
    app.setActivationPolicy(.regular)

    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 1000, height: 800),
        styleMask: [.titled, .closable, .resizable, .miniaturizable],
        backing: .buffered,
        defer: false
    )
    window.title = "Loom Lab"
    window.contentView = NSHostingView(rootView: LabView(autoplay: autoplay))
    window.center()
    window.makeKeyAndOrderFront(nil)
    app.activate()

    withExtendedLifetime(delegate) {
        app.run()
    }
}
