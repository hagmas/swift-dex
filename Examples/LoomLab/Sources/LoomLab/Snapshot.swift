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
            var renderer = FigureRenderer(
                content: scenario.figure(scenario.steps)
                    .background(.white)
            )
            renderer.margin = 40
            guard let png = renderer.pngData() else {
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
