import AppKit
import Loom
import SwiftUI

/// Draws every scenario at its last step into a folder of images, to look
/// through a whole gallery at once.
///
/// A still image shows where everything ends up, not how it got there, so
/// this is for how figures read; animation is what playing them is for.
@MainActor
enum Snapshot {
    static func write(to folder: URL) throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        for (index, scenario) in Scenario.all.enumerated() {
            let view = scenario.figure(scenario.steps)
                .figureScale(2)
                .padding(40)
                .frame(width: 1000, height: 760)
                .background(.white)

            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            guard
                let image = renderer.nsImage,
                let tiff = image.tiffRepresentation,
                let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
            else {
                print("\(scenario.name): could not be drawn")
                continue
            }

            let name = String(format: "%02d %@.png", index + 1, scenario.name)
            let file = folder.appending(path: name)
            try png.write(to: file)
            print(file.path)
        }
    }
}
