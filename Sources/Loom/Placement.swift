import Foundation

/// The direction a container runs in.
public enum Axis: Hashable, Sendable {
    /// Left to right — a ``Row``.
    case horizontal
    /// Top to bottom — a ``Column``.
    case vertical
}

/// What an element contributes to the shape of the arrangement.
///
/// The arrangement is closed precisely so that it can be read back, and this is
/// the form it is read back in. Where two nodes sit relative to one another is a
/// fact about the tree, not about the pixels they happened to land on, so lines
/// are routed from this rather than from measured rectangles.
public enum Placement: Hashable, Sendable {
    /// A node, at this position in its container.
    case node(NodeID)

    /// A hole, which holds a position without being a node.
    case gap

    /// A nested run of elements, and the direction it runs in.
    case group(Axis, [Placement])
}

public extension Placement {
    /// Every node identity here, in arrangement order.
    var nodeIDs: [NodeID] {
        switch self {
        case .node(let id):
            [id]
        case .gap:
            []
        case .group(_, let children):
            children.flatMap(\.nodeIDs)
        }
    }
}

/// One container a node sits inside, and where it sits in it.
struct PathStep: Hashable {
    /// The direction the container runs in.
    let axis: Axis

    /// The node's position among that container's elements.
    let index: Int
}

/// The containers a node sits inside, outermost first.
///
/// Two nodes' paths agree until the container they share, which is what says
/// how a line between them should leave and arrive.
typealias NodePath = [PathStep]

extension Placement {
    /// Where every node sits in the tree.
    ///
    /// The outermost container is vertical, matching how ``FigureView`` stacks
    /// an arrangement whose root holds more than one element.
    static func paths(in placements: [Placement]) -> [NodeID: NodePath] {
        var paths: [NodeID: NodePath] = [:]

        func walk(_ placements: [Placement], axis: Axis, prefix: NodePath) {
            for (index, placement) in placements.enumerated() {
                let path = prefix + [PathStep(axis: axis, index: index)]
                switch placement {
                case .node(let id):
                    paths[id] = path
                case .gap:
                    break
                case .group(let axis, let children):
                    walk(children, axis: axis, prefix: path)
                }
            }
        }

        walk(placements, axis: .vertical, prefix: [])
        return paths
    }
}
