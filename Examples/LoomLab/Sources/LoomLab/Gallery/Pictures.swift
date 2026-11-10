import Loom
import SwiftUI

extension Scenario {
    /// Nodes drawn as pictures rather than boxes — a house, a relay mast, a
    /// server — with a request going out from the house and the answer coming
    /// back.
    ///
    /// It starts out still. Each step sets the next part of the journey
    /// flowing, and stills the one before.
    static let pictures = Scenario(name: "Pictures", steps: 3) { step in
        AnyView(
            FigureView(Journey(step: step), spacing: 16, routing: .curved)
                .nodeStyle(.picture)
                .lineStyle(.plain)
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
    /// Room enough all round that lines stop well clear of the pictures and
    /// their captions, so each picture stands on its own.
    static let picture = NodeStyle(
        shape: .none,
        textColor: Color(white: 0.2),
        fontSize: 15,
        padding: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24),
        minWidth: 0
    )
}

private extension LineStyle {
    static let plain = LineStyle(color: Color(white: 0.25), width: 3, labelBackground: .white)

    /// The request on its way, dots travelling out along it.
    static let travelling = LineStyle(color: Color(white: 0.25), width: 3, flow: .dots, labelBackground: .white)

    /// The answer, dashed whether or not it is on its way, so that setting
    /// off changes nothing but that its dashes start marching.
    static let answer = LineStyle(color: Color(white: 0.25), width: 3, dash: [9, 9], labelBackground: .white)

    /// The answer on its way, its dashes marching back.
    static let marching = LineStyle(
        color: Color(white: 0.25),
        width: 3,
        dash: [9, 9],
        flow: .dashes(speed: 40),
        labelBackground: .white
    )
}

private struct Journey: Figure {
    /// Which part of the journey is under way: none yet, the request reaching
    /// the relay, the relay passing it on, or the answer coming back.
    var step: Int

    var arrangement: some FigureElement {
        Row(spacing: 168) {
            Picture(id: .home, caption: "Home", tint: .orange) { House() }
            Picture(id: .relay, caption: "Relay", tint: .purple) { Mast() }
            Picture(id: .server, caption: "Server", tint: .teal) { Rack() }
        }
    }

    var lines: [Line] {
        // The same lines at every step, only flowing or not: a line's style
        // is not part of which line it is, so none of them is drawn in anew.
        Line(from: .home, to: .relay, label: "request", style: step == 1 ? .travelling : .plain)
        Line(from: .relay, to: .server, style: step == 2 ? .travelling : .plain)
        // Back underneath, the long way round, so it does not lie on the way
        // out.
        Line(from: .server.bottom, to: .home.bottom, label: "response", style: step == 3 ? .marching : .answer)
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
                .frame(width: 100, height: 100)
                .shadow(color: tint.opacity(0.3), radius: 9, y: 5)
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
            cornerSize: CGSize(width: 5, height: 5)
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
            cornerSize: CGSize(width: 3, height: 3)
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
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
        }
    }
}

private struct MastShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let middle = rect.minX + w / 2
        let beacon = CGPoint(x: middle, y: rect.minY + h * 0.22 + w * 0.08)
        let radius = w * 0.08
        var path = Path()
        // The tower, wide at the foot and narrow at the top, standing a little
        // clear of the beacon: its top is cupped round the beacon, the same
        // distance from it all the way across.
        let cup = radius * 2
        let topHalf = w * 0.05
        let top = beacon.y + (cup * cup - topHalf * topHalf).squareRoot()
        path.move(to: CGPoint(x: middle - topHalf, y: top))
        let from = atan2(top - beacon.y, -topHalf)
        let to = atan2(top - beacon.y, topHalf)
        for step in 1...12 {
            let angle = from + (to - from) * CGFloat(step) / 12
            path.addLine(to: CGPoint(x: beacon.x + cup * cos(angle), y: beacon.y + cup * sin(angle)))
        }
        path.addLine(to: CGPoint(x: middle + w * 0.2, y: rect.minY + h * 0.95))
        path.addLine(to: CGPoint(x: middle - w * 0.2, y: rect.minY + h * 0.95))
        path.closeSubpath()
        // The beacon on top.
        path.addEllipse(
            in: CGRect(x: beacon.x - radius, y: beacon.y - radius, width: radius * 2, height: radius * 2)
        )
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
        VStack(spacing: 6) {
            ForEach(0..<3) { unit in
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: 88, height: 23)
                    .overlay(alignment: .leading) {
                        HStack(spacing: 6) {
                            Circle().fill(.white).frame(width: 8, height: 8)
                            Circle().fill(.white.opacity(unit == 1 ? 1 : 0.5)).frame(width: 8, height: 8)
                            Capsule().fill(.white.opacity(0.6)).frame(width: 32, height: 5)
                        }
                        .padding(.leading, 11)
                    }
            }
        }
        // Standing on the same ground as the house and the mast.
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}
