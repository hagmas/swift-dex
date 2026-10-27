import XCTest

@testable import Loom

private extension NodeID {
    static let a = NodeID("a")
    static let b = NodeID("b")
}

/// Lines written once, at file scope, for any number of figures to share.
///
/// Swift 6 only allows a global constant whose type is `Sendable`, so this
/// compiling is the test.
private let sharedLines = [
    Line(from: .a, to: .b, label: "uses", style: LineStyle(dash: [4, 2]))
]

final class SendableTests: XCTestCase {
    func test_linesCanBeSharedAsAGlobalConstant() {
        XCTAssertEqual(sharedLines.count, 1)
    }
}
