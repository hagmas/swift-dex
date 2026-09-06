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
struct AddressStep: Hashable {
    /// The direction the container runs in.
    let axis: Axis

    /// The node's position among that container's elements.
    let index: Int
}

/// Where a node lives in the arrangement: the containers it sits inside,
/// outermost first, and its position in each.
///
/// An address, not a route — nothing here is ever drawn. It is more like a seat
/// number than a line on a page: "third row, second along" says where a node
/// sits without saying where that is on screen.
///
/// Two nodes' addresses agree until the container they share, and that
/// container's direction is the direction a line between them travels. Which is
/// the whole of what an address is for.
typealias NodeAddress = [AddressStep]

extension Placement {
    /// Where every node lives in the tree.
    ///
    /// A step records the direction of the container an item sits *in*, not any
    /// direction of its own — because that is the direction a line will travel
    /// when two nodes part company there.
    ///
    /// The outermost container is vertical, matching how ``FigureView`` stacks
    /// an arrangement whose root holds more than one element. Change one and
    /// the other has to change with it, or a line crossing the root will leave
    /// along an axis the layout does not agree with.
    static func addresses(in placements: [Placement]) -> [NodeID: NodeAddress] {
        var addresses: [NodeID: NodeAddress] = [:]

        func walk(_ placements: [Placement], axis: Axis, prefix: NodeAddress) {
            for (index, placement) in placements.enumerated() {
                let address = prefix + [AddressStep(axis: axis, index: index)]
                switch placement {
                case .node(let id):
                    addresses[id] = address
                case .gap:
                    // Skipped, but it has taken an index: a gap holds a
                    // position without being a node.
                    break
                case .group(let axis, let children):
                    walk(children, axis: axis, prefix: address)
                }
            }
        }

        walk(placements, axis: .vertical, prefix: [])
        return addresses
    }
}
