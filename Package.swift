// swift-tools-version:6.2

import Foundation
import PackageDescription

let package = Package(
    name: "swift-dex",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "SwiftDex", targets: ["SwiftDex"]),
        .library(name: "Loom", targets: ["Loom"]),
    ],
    targets: [
        .target(name: "SwiftDex"),
        .testTarget(
            name: "SwiftDexTests",
            dependencies: ["SwiftDex"]
        ),
        // Loom draws figures. It knows nothing about SwiftDex, and SwiftDex
        // knows nothing about it: the two meet only in a deck's own code, where
        // both can be imported. The compiler keeps that boundary honest.
        .target(name: "Loom"),
        .testTarget(
            name: "LoomTests",
            dependencies: ["Loom"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

// swift-format is no longer a dependency: it ships with the Swift toolchain
// (Xcode 16+) as the `swift format` subcommand.
if ProcessInfo.processInfo.environment["SWIFT_DEX_DEVELOPMENT"] != nil {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/apple/swift-docc-plugin", exact: "1.5.0"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", exact: "2.46.0"),
    ])
}
