import Foundation
import XCTest

@testable import SwiftDex

func assertActionSequence<A: Action & Equatable>(
    elementID: ElementID,
    actionContainer: ActionContainer,
    expectedSequence: ExpectedSequence<A>,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    for (i, expectedNode) in expectedSequence.nodes.enumerated() {
        let node: ActionSequenceNode<A>? = actionContainer[elementID, i]
        switch expectedNode {
        case .dynamic(let previous, let current, let next):
            assertActionSequenceNodeDynamic(
                node: node,
                previous: previous,
                current: current,
                next: next,
                file: file,
                line: line
            )

        case .static(let previous, let next):
            assertActionSequenceNodeStatic(
                node: node,
                previous: previous,
                next: next,
                file: file,
                line: line
            )
        }
    }
}

struct ExpectedSequence<A: Action> {
    enum Node {
        case `static`(previous: A?, next: A?)
        case dynamic(previous: A?, current: A, next: A?)
    }

    private(set) var nodes: [Node]
}

extension ExpectedSequence {
    static func `static`(
        previous: A? = nil,
        next: A? = nil
    ) -> Self {
        return self.init(
            nodes: [
                .static(
                    previous: previous,
                    next: next
                )
            ]
        )
    }

    static func dynamic(
        previous: A? = nil,
        current: A,
        next: A? = nil
    ) -> Self {
        return self.init(
            nodes: [
                .dynamic(
                    previous: previous,
                    current: current,
                    next: next
                )
            ]
        )
    }

    func addStatic(
        previous: A? = nil,
        next: A? = nil
    ) -> Self {
        var nodes = nodes
        nodes.append(
            .static(
                previous: previous,
                next: next
            )
        )
        return Self.init(nodes: nodes)
    }

    func addDynamic(
        previous: A? = nil,
        current: A,
        next: A? = nil
    ) -> Self {
        var nodes = nodes
        nodes.append(
            .dynamic(
                previous: previous,
                current: current,
                next: next
            )
        )
        return Self.init(nodes: nodes)
    }
}

func assertActionSequenceNodeDynamic<A: Action & Equatable>(
    node: ActionSequenceNode<A>?,
    previous: A? = nil,
    current: A,
    next: A? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch node {
    case .dynamic(let node):
        XCTAssertEqual(node.previous?.action, previous, file: file, line: line)
        XCTAssertEqual(node.current.action, current, file: file, line: line)
        XCTAssertEqual(node.next?.action, next, file: file, line: line)

    case .static:
        XCTFail("The node is static.", file: file, line: line)

    case .none:
        XCTFail("The node is nil.", file: file, line: line)
    }
}

func assertActionSequenceNodeStatic<A: Action & Equatable>(
    node: ActionSequenceNode<A>?,
    previous: A? = nil,
    next: A? = nil,
    file: StaticString = #filePath,
    line: UInt = #line
) {
    switch node {
    case .static(let node):
        XCTAssertEqual(node.previous?.action, previous, file: file, line: line)
        XCTAssertEqual(node.next?.action, next, file: file, line: line)

    case .dynamic:
        XCTFail("The node is dynamic.", file: file, line: line)

    case .none:
        XCTFail("The node is nil.", file: file, line: line)
    }
}
