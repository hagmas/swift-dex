import Foundation
import XCTest

@testable import SwiftDex

func assertActionStateActivated<A: Action & Equatable>(
    actionState: ActionState<A>?,
    previous: A? = nil,
    current: A,
    next: A? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch actionState {
    case .activated(let value):
        XCTAssertEqual(value.previous, previous, file: file, line: line)
        XCTAssertEqual(value.current, current, file: file, line: line)
        XCTAssertEqual(value.next, next, file: file, line: line)

    case .static:
        XCTFail("The actionState is static.", file: file, line: line)

    case .deactivated:
        XCTFail("The actionState is deactivated.", file: file, line: line)

    case nil:
        XCTFail("The actionState is nil.", file: file, line: line)
    }
}

func assertActionStateDeactivated<A: Action & Equatable>(
    actionState: ActionState<A>?,
    previous: A? = nil,
    current: A,
    next: A? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch actionState {
    case .deactivated(let value):
        XCTAssertEqual(value.previous, previous, file: file, line: line)
        XCTAssertEqual(value.current, current, file: file, line: line)
        XCTAssertEqual(value.next, next, file: file, line: line)

    case .activated:
        XCTFail("The actionState is activated.", file: file, line: line)

    case .static:
        XCTFail("The actionState is static.", file: file, line: line)

    case nil:
        XCTFail("The actionState is nil.", file: file, line: line)
    }
}

func assertActionStateStatic<A: Action & Equatable>(
    actionState: ActionState<A>?,
    previous: A? = nil,
    next: A? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch actionState {
    case .static(let value):
        XCTAssertEqual(value.previous, previous, file: file, line: line)
        XCTAssertEqual(value.next, next, file: file, line: line)

    case .activated:
        XCTFail("The actionState is activated.", file: file, line: line)

    case .deactivated:
        XCTFail("The actionState is deactivated.", file: file, line: line)

    case nil:
        XCTFail("The actionState is nil.", file: file, line: line)
    }
}
