import SwiftUI

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let h = rect.height
        return Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.25))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - h * 0.25))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - h * 0.25))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + h * 0.25))
            p.closeSubpath()
        }
    }
}

struct HexagonalWaveformView: View {
    var samples: [Float]
    var glowIntensity: Double = 1.0
    var cloudOpacity: Double = 0.2
    var updateSpeed: Double = 0.1

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                let count = samples.count
                guard count > 1 else { return }
                let hexWidth = size.width / CGFloat(count)
                let hexHeight = hexWidth * 0.866
                let rows = Int(size.height / hexHeight) + 1

                // Background gradient
                let bgRect = CGRect(origin: .zero, size: size)
                context.fill(Path(bgRect), with: .linearGradient(
                    Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.1)]),
                    startPoint: CGPoint(x: bgRect.midX, y: 0),
                    endPoint: CGPoint(x: bgRect.midX, y: bgRect.maxY)))
                context.fill(Path(bgRect), with: .color(Color.black.opacity(cloudOpacity)))

                func hexPath(col: Int, row: Int) -> Path {
                    let x = CGFloat(col) * hexWidth + (row % 2 == 1 ? hexWidth / 2 : 0)
                    let y = CGFloat(row) * hexHeight
                    let rect = CGRect(x: x - hexWidth / 2, y: y - hexHeight / 2, width: hexWidth, height: hexHeight)
                    return HexagonShape().path(in: rect)
                }

                // Draw grid lines
                for row in 0...rows {
                    for col in 0..<count {
                        let path = hexPath(col: col, row: row)
                        context.stroke(path, with: .color(Color.gray.opacity(0.2)), lineWidth: 0.5)
                    }
                }

                context.addFilter(.shadow(color: Color.orange.opacity(glowIntensity), radius: 6))
                context.drawLayer { layerContext in
                    for (i, sample) in samples.enumerated() {
                        let amp = max(-1, min(1, sample))
                        let row = Int((1 - (amp + 1) / 2) * Double(rows - 1))
                        let path = hexPath(col: i, row: row)
                        layerContext.fill(path, with: .color(Color.orange))
                    }
                }
            }
        }
        .animation(.linear(duration: updateSpeed), value: samples)
    }
}

#Preview {
    HexagonalWaveformView(samples: Array(repeating: 0.0, count: 64))
}
