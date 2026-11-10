import Loom
import SwiftUI

extension Scenario {
    /// Nodes drawn as pictures rather than boxes — a house, a relay mast, a
    /// server — with a request going out from the house and the answer coming
    /// back.
    static let pictures = Scenario(name: "Pictures", steps: 0) { _ in
        AnyView(
            FigureView(Journey(), spacing: 16, routing: .curved)
                .nodeStyle(.picture)
                .lineStyle(LineStyle(color: Color(white: 0.25), width: 3, labelBackground: .white))
        )
    }
}

private extension NodeID {
    static let home = NodeID("home")
    static let relay = NodeID("relay")
    static let server = NodeID("server")
}

private extension NodeStyle {
    /// No frame, since each picture draws its own; the words are its caption.
    ///
    /// Room enough all round that lines stop well clear of the pictures: one
    /// meeting the bottom stops about as far under the caption as the caption
    /// sits under the picture.
    static let picture = NodeStyle(
        shape: .none,
        textColor: Color(white: 0.2),
        fontWeight: .semibold,
        padding: EdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18),
        minWidth: 0
    )
}

private struct Journey: Figure {
    var arrangement: some FigureElement {
        Row(spacing: 168) {
            Picture(id: .home, caption: "Home", tint: .orange) { House() }
            Picture(id: .relay, caption: "Relay", tint: .purple) { Mast() }
            Picture(id: .server, caption: "Server", tint: .teal) { Rack() }
        }
    }

    var lines: [Line] {
        Line(from: .home, to: .relay, label: "request")
        Line(from: .relay, to: .server)
        // Back underneath, the long way round, so it does not lie on the way
        // out.
        Line(from: .server.bottom, to: .home.bottom, label: "response")
    }
}

/// A picture with a caption under it.
///
/// Lines meet the rectangle around the picture and its caption together.
/// Every picture here is the same size with a caption of one line, so the
/// lines between them still run level.
private struct Picture<Art: View>: Node {
    let id: NodeID
    var caption: String
    var tint: Color
    @ViewBuilder var art: Art

    var body: some View {
        VStack(spacing: 14) {
            art
                .foregroundStyle(tint.gradient)
                .frame(width: 124, height: 124)
                .shadow(color: tint.opacity(0.3), radius: 11, y: 6)
            Text(caption)
        }
    }
}

/// A house: a roof over walls, with a door and a window.
private struct House: View {
    var body: some View {
        ZStack {
            HouseShape()
            // Door and window cut out of the walls.
            HouseOpenings()
                .fill(.white)
        }
    }
}

private struct HouseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // Roof, overhanging the walls.
        path.move(to: CGPoint(x: rect.minX + w * 0.5, y: rect.minY + h * 0.04))
        path.addLine(to: CGPoint(x: rect.minX + w * 0.98, y: rect.minY + h * 0.46))
        path.addLine(to: CGPoint(x: rect.minX + w * 0.02, y: rect.minY + h * 0.46))
        path.closeSubpath()
        // Chimney.
        path.addRect(CGRect(x: rect.minX + w * 0.68, y: rect.minY + h * 0.12, width: w * 0.1, height: h * 0.22))
        // Walls.
        path.addRoundedRect(
            in: CGRect(x: rect.minX + w * 0.14, y: rect.minY + h * 0.42, width: w * 0.72, height: h * 0.54),
            cornerSize: CGSize(width: 6, height: 6)
        )
        return path
    }
}

private struct HouseOpenings: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        // The door, arched at the top and square where it meets the ground.
        path.addPath(
            UnevenRoundedRectangle(topLeadingRadius: w * 0.09, topTrailingRadius: w * 0.09)
                .path(in: CGRect(x: rect.minX + w * 0.24, y: rect.minY + h * 0.62, width: w * 0.18, height: h * 0.34))
        )
        path.addRoundedRect(
            in: CGRect(x: rect.minX + w * 0.54, y: rect.minY + h * 0.56, width: w * 0.2, height: h * 0.18),
            cornerSize: CGSize(width: 4, height: 4)
        )
        return path
    }
}

/// A relay mast: a tapering tower sending out waves either side.
private struct Mast: View {
    var body: some View {
        ZStack {
            MastShape()
            Waves()
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
        }
    }
}

private struct MastShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let middle = rect.minX + w / 2
        var path = Path()
        // The tower, wide at the foot and narrow at the top, standing a little
        // clear of the beacon.
        path.move(to: CGPoint(x: middle - w * 0.05, y: rect.minY + h * 0.46))
        path.addLine(to: CGPoint(x: middle + w * 0.05, y: rect.minY + h * 0.46))
        path.addLine(to: CGPoint(x: middle + w * 0.2, y: rect.minY + h * 0.95))
        path.addLine(to: CGPoint(x: middle - w * 0.2, y: rect.minY + h * 0.95))
        path.closeSubpath()
        // The beacon on top.
        path.addEllipse(in: CGRect(x: middle - w * 0.08, y: rect.minY + h * 0.22, width: w * 0.16, height: w * 0.16))
        return path
    }
}

private struct Waves: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let beacon = CGPoint(x: rect.minX + w / 2, y: rect.minY + h * 0.3)
        var path = Path()
        for radius in [w * 0.22, w * 0.36] {
            for (start, end) in [(Angle.degrees(140), Angle.degrees(220)), (.degrees(-40), .degrees(40))] {
                // Each arc on its own, not joined to the one before.
                path.move(
                    to: CGPoint(
                        x: beacon.x + radius * cos(start.radians),
                        y: beacon.y + radius * sin(start.radians)
                    )
                )
                path.addArc(center: beacon, radius: radius, startAngle: start, endAngle: end, clockwise: false)
            }
        }
        return path
    }
}

/// A server: a rack of three units, each with its lights.
private struct Rack: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { unit in
                RoundedRectangle(cornerRadius: 8)
                    .overlay(alignment: .leading) {
                        HStack(spacing: 7) {
                            Circle().fill(.white).frame(width: 10, height: 10)
                            Circle().fill(.white.opacity(unit == 1 ? 1 : 0.5)).frame(width: 10, height: 10)
                            Capsule().fill(.white.opacity(0.6)).frame(width: 40, height: 6)
                        }
                        .padding(.leading, 14)
                    }
            }
        }
        .padding(.horizontal, 8)
    }
}
