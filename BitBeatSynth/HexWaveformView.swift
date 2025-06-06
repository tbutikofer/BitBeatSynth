import SwiftUI

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        return Path { p in
            p.move(to: CGPoint(x: w * 0.5, y: 0))
            p.addLine(to: CGPoint(x: w, y: h * 0.25))
            p.addLine(to: CGPoint(x: w, y: h * 0.75))
            p.addLine(to: CGPoint(x: w * 0.5, y: h))
            p.addLine(to: CGPoint(x: 0, y: h * 0.75))
            p.addLine(to: CGPoint(x: 0, y: h * 0.25))
            p.closeSubpath()
        }
    }
}

struct HexWaveformView: View {
    var samples: [Float]
    var glowIntensity: Double = 1.0
    var cloudOpacity: Double = 0.25
    var updateSpeed: Double = 0.05

    private func row(for sample: Float, rows: Int) -> Int {
        // sample expected between -1...1
        let clamped = max(-1, min(1, Double(sample)))
        let normalized = (1.0 - clamped) * 0.5
        return Int(normalized * Double(rows - 1))
    }

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let hexSize: CGFloat = 12
                let hexHeight = hexSize
                let hexWidth = sqrt(3)/2 * hexHeight
                let stepX = hexWidth * 0.75
                let stepY = hexHeight * 0.75
                let columns = min(Int(size.width / stepX), samples.count)
                let rows = Int(size.height / stepY)

                // Background gradient with cloud opacity
                let backgroundRect = Path(CGRect(origin: .zero, size: size))
                context.fill(backgroundRect,
                              with: .linearGradient(
                                Gradient(colors: [
                                    Color.black,
                                    Color.black.opacity(0.7)
                                ]),
                                startPoint: .zero,
                                endPoint: CGPoint(x: 0, y: size.height)
                              ))
                context.fill(backgroundRect,
                              with: .color(Color.black.opacity(cloudOpacity)))

                // Draw grid
                for col in 0..<columns {
                    let sample = samples[samples.count - columns + col]
                    let highlightRow = row(for: sample, rows: rows)

                    for row in 0..<rows {
                        let x = CGFloat(col) * stepX + hexWidth / 2
                        let y = CGFloat(row) * stepY + ((col % 2 == 0) ? 0 : stepY / 2)
                        let rect = CGRect(x: x - hexWidth/2, y: y - hexHeight/2, width: hexWidth, height: hexHeight)
                        let hex = Hexagon().path(in: rect)
                        if row == highlightRow {
                            context.addFilter(.shadow(color: Color.orange.opacity(glowIntensity), radius: 6))
                            context.fill(hex, with: .color(Color.orange))
                            context.addFilter(.shadow(color: .clear, radius: 0))
                        } else {
                            context.fill(hex, with: .color(Color.gray.opacity(0.2)))
                        }
                    }
                }
            }
            .animation(.linear(duration: updateSpeed), value: samples)
        }
    }
}

#Preview {
    HexWaveformView(samples: (0..<64).map { _ in Float.random(in: -1...1) })
        .frame(width: 300, height: 150)
}
