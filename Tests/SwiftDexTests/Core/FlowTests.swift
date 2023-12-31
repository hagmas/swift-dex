import Foundation
import SwiftUI
import XCTest

@testable import SwiftDex

final class FlowTests: XCTestCase {
    func test_single_flow() {
        let slide01 = Slide01()
        let flatten = slide01.flatten()
        XCTAssertEqual(flatten.count, 1)
        XCTAssertTrue(flatten[0].0 is Slide01)
    }

    func test_subflow() {
        let slide01 = Slide01()
        let slide02 = Slide02()
        let flatten =
            slide01
            .next(slide02)
            .flatten()
        XCTAssertEqual(flatten.count, 2)
        XCTAssertTrue(flatten[0].0 is Slide01)
        XCTAssertTrue(flatten[1].0 is Slide02)
    }

    func test_concatinating_subflows() {
        let slide01 = Slide01()
        let slide02 = Slide02()
        let slide03 = Slide03()
        let slide04 = Slide04()
        let subflow01 = slide01.next(slide02)
        let subflow02 = slide03.next(slide04)
        let flatten = subflow01.next(subflow02).flatten()
        XCTAssertEqual(flatten.count, 4)
        XCTAssertTrue(flatten[0].0 is Slide01)
        XCTAssertTrue(flatten[1].0 is Slide02)
        XCTAssertTrue(flatten[2].0 is Slide03)
        XCTAssertTrue(flatten[3].0 is Slide04)
    }
}

private struct Slide01: Slide {
    var content: some View {
        EmptyView()
    }
}

private struct Slide02: Slide {
    var content: some View {
        EmptyView()
    }
}

private struct Slide03: Slide {
    var content: some View {
        EmptyView()
    }
}

private struct Slide04: Slide {
    var content: some View {
        EmptyView()
    }
}
