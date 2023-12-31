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
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", exact: "0.16.0")
    ],
    targets: [
        .target(
            name: "SwiftDex",
            dependencies: ["Splash"]
        ),
        .testTarget(
            name: "SwiftDexTests",
            dependencies: ["SwiftDex"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)

if ProcessInfo.processInfo.environment["SWIFT_DEX_DEVELOPMENT"] != nil {
    package.dependencies.append(contentsOf: [
        .package(url: "https://github.com/apple/swift-docc-plugin", exact: "1.3.0"),
        .package(url: "https://github.com/apple/swift-format.git", exact: "508.0.1"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", exact: "2.37.0"),
    ])
}
