import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

func assertIdle<A: Action & Equatable>(
    progress: ActionProgress<A>?,
    previous: A?,
    next: A?,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard case .idle(let actualPrevious, let actualNext) = progress else {
        XCTFail("Expected .idle but got \(String(describing: progress))", file: file, line: line)
        return
    }
    XCTAssertEqual(actualPrevious, previous, file: file, line: line)
    XCTAssertEqual(actualNext, next, file: file, line: line)
}

func assertActive<A: Action & Equatable>(
    progress: ActionProgress<A>?,
    current: A,
    step: Int,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard case .active(let actualCurrent, let actualStep) = progress else {
        XCTFail("Expected .active but got \(String(describing: progress))", file: file, line: line)
        return
    }
    XCTAssertEqual(actualCurrent, current, file: file, line: line)
    XCTAssertEqual(actualStep, step, file: file, line: line)
}

func assertCompleted<A: Action & Equatable>(
    progress: ActionProgress<A>?,
    current: A,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    guard case .completed(let actualCurrent) = progress else {
        XCTFail("Expected .completed but got \(String(describing: progress))", file: file, line: line)
        return
    }
    XCTAssertEqual(actualCurrent, current, file: file, line: line)
}

/// Holds a `SlideState` on the main actor so a test can hand a `Binding` to a
/// view model and mutate the state behind it without capturing a local `var`.
@MainActor
final class SlideStateBox {
    var value: SlideState

    init(_ value: SlideState) {
        self.value = value
    }

    var binding: Binding<SlideState> {
        Binding(get: { self.value }, set: { self.value = $0 })
    }
}
