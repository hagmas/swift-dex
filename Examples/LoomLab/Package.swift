// swift-tools-version:6.2

import PackageDescription

// A workbench for Loom: figures played through their changes, with a meter
// for dropped frames. A package of its own so that it can depend on the
// repository by path without the library depending on it.
let package = Package(
    name: "LoomLab",
    platforms: [
        .macOS(.v26)
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "LoomLab",
            dependencies: [.product(name: "Loom", package: "swift-dex")]
        )
    ],
    swiftLanguageModes: [.v6]
)
