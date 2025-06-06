import SwiftUI

struct HexGridWaveformView: View {
    var samples: [Float]
    var style: HexGridStyle = .default
    @State private var fadeTrail: [CGPoint: CGFloat] = [:]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for (center, alpha) in fadeTrail {
                    drawHex(at: center, in: context, size: style.hexSize, glow: style.glowIntensity * alpha)
                }
            }
            .drawingGroup()
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.gray.opacity(style.cloudOpacity),
                        Color.black
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height)
                )
            )
            .onChange(of: samples) {
                updateFadeTrail(for: geo.size)
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { _ in
                    updateFadeTrail(for: geo.size)
                }
            }
        }
    }

    private func updateFadeTrail(for size: CGSize) {
        let columns = Int(size.width / (style.hexSize * 0.75))
        let midY = size.height / 2
        let step = samples.count > 1 ? CGFloat(samples.count - 1) / CGFloat(columns) : 1.0

        var newTrail = fadeTrail.mapValues { max($0 - 0.05, 0) }.filter { $0.value > 0 }

        for col in 0..<columns {
            let sampleIndex = min(Int(CGFloat(col) * step), samples.count - 1)
            let sample = samples[sampleIndex]

            let amplitude = CGFloat((sample * 20).rounded() / 20)
            let normalizedY = midY - amplitude * midY

            let hexCenterX = CGFloat(col) * style.hexSize * 0.75 + style.hexSize / 2
            let rowOffset = (col % 2 == 0) ? 0.0 : style.hexSize * sqrt(3) / 2

            let hexCenterY = (normalizedY / style.hexSize).rounded() * style.hexSize + rowOffset

            let center = CGPoint(
                x: hexCenterX.rounded(),
                y: hexCenterY.rounded()
            )

            newTrail[center] = 1.0
        }

        fadeTrail = newTrail
    }

    func drawHex(at center: CGPoint, in context: GraphicsContext, size: CGFloat, glow: CGFloat) {
        var path = Path()
        let angle = CGFloat.pi / 3

        for i in 0..<6 {
            let x = center.x + size * cos(angle * CGFloat(i))
            let y = center.y + size * sin(angle * CGFloat(i))
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        context.fill(path, with: .color(.black.opacity(0.05)))

        context.fill(
            path,
            with: .radialGradient(
                Gradient(colors: [Color.orange.opacity(glow), .clear]),
                center: center,
                startRadius: 0,
                endRadius: size
            )
        )

        context.stroke(path, with: .color(Color.orange.opacity(0.4 * glow)), lineWidth: 0.5)
    }
}

struct HexGridStyle {
    var glowIntensity: CGFloat = 0.8
    var cloudOpacity: CGFloat = 0.3
    var hexSize: CGFloat = 30.0

    static let `default` = HexGridStyle()
}

