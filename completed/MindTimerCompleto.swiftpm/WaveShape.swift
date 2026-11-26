import SwiftUI

struct WaveShape: Shape {

    var offset: Double
    var percent: Double

    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let baseHeight = (1.0 - percent) * rect.height

        path.move(to: CGPoint(x: 0, y: baseHeight))

        for x in stride(from: 0.0, through: Double(rect.width), by: 1.0) {
            let relativeX = x / Double(rect.width)
            let seno = sin(relativeX * 2 * .pi + offset)
            let y = baseHeight + (seno * 12)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}
