// swift-tools-version:5.9

import Foundation
import PackageDescription

let package = Package(
    name: "swift-dex",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "SwiftDex", targets: ["SwiftDex"])
    ],
    targets: [
        .target(
            name: "SwiftDex",
            resources: [.process("Shader/Dissolve.metal")]
        ),
        .testTarget(
            name: "SwiftDexTests",
            dependencies: ["SwiftDex"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

// swift-format is no longer a dependency: it ships with the Swift toolchain
// (Xcode 16+) as the `swift format` subcommand.
if ProcessInfo.processInfo.environment["SWIFT_DEX_DEVELOPMENT"] != nil {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/apple/swift-docc-plugin", exact: "1.5.0"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", exact: "2.46.0"),
    ])
}
