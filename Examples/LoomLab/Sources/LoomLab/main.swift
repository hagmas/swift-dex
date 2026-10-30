import AppKit
import SwiftUI

// Run with `swift run --package-path Examples/LoomLab LoomLab`, adding
// `--autoplay` to play every way of appearing, print what the frame meter
// saw, and quit; `--frames <folder>` to play the scenario through once,
// writing it to images as often as the window can be captured, and quit; or
// `--snapshot <folder>` to draw every scenario into images there and quit.
// `--scenario <name>` says which scenario to open, play or write frames of.

/// The lab as an app: one window, so that it has a proper toolbar for the
/// sidebar's button to sit in.
private struct LoomLabApp: App {
    static var autoplay = false
    static var frames: URL?
    static var scenario: String?

    var body: some Scene {
        Window("Loom Lab", id: "lab") {
            LabView(scenario: Self.scenario, autoplay: Self.autoplay, frames: Self.frames)
                .onAppear {
                    NSApp.activate()
                }
        }
        .defaultSize(width: 1100, height: 820)
    }
}

MainActor.assumeIsolated {
    let arguments = CommandLine.arguments
    if let flag = arguments.firstIndex(of: "--snapshot"), arguments.indices.contains(flag + 1) {
        do {
            try Snapshot.write(to: URL(filePath: arguments[flag + 1]))
            exit(0)
        }
        catch {
            print(error)
            exit(1)
        }
    }

    /// The word after `flag`, if it was given.
    func value(of flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    LoomLabApp.autoplay = arguments.contains("--autoplay")
    LoomLabApp.frames = value(of: "--frames").map { URL(filePath: $0) }
    LoomLabApp.scenario = value(of: "--scenario")
    // Run from a package rather than a bundle, the app would otherwise start
    // without a Dock icon or a menu bar.
    NSApplication.shared.setActivationPolicy(.regular)
    LoomLabApp.main()
}
