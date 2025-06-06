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
            HexagonalCanvas(
                samples: samples,
                glowIntensity: glowIntensity,
                cloudOpacity: cloudOpacity
            )
        }
        .animation(.linear(duration: updateSpeed), value: samples)
    }
}

private struct HexagonalCanvas: View {
    var samples: [Float]
    var glowIntensity: Double
    var cloudOpacity: Double

    var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
    }

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let count = samples.count
        guard count > 1 else { return }
        let hexWidth = size.width / CGFloat(count)
        let hexHeight = hexWidth * 0.866
        let rows = Int(size.height / hexHeight) + 1

        drawBackground(context: &context, size: size)
        drawGrid(context: &context, count: count, rows: rows, hexWidth: hexWidth, hexHeight: hexHeight)
        drawWaveform(context: &context, rows: rows, hexWidth: hexWidth, hexHeight: hexHeight)
    }

    private func drawBackground(context: inout GraphicsContext, size: CGSize) {
        let gradient = Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.1)])
        let bgRect = CGRect(origin: .zero, size: size)
        let start = CGPoint(x: bgRect.midX, y: 0)
        let end = CGPoint(x: bgRect.midX, y: bgRect.maxY)
        context.fill(Path(bgRect), with: .linearGradient(gradient, startPoint: start, endPoint: end))
        context.fill(Path(bgRect), with: .color(Color.black.opacity(cloudOpacity)))
    }

    private func hexPath(col: Int, row: Int, hexWidth: CGFloat, hexHeight: CGFloat) -> Path {
        let x = CGFloat(col) * hexWidth + (row % 2 == 1 ? hexWidth / 2 : 0)
        let y = CGFloat(row) * hexHeight
        let rect = CGRect(x: x - hexWidth / 2, y: y - hexHeight / 2, width: hexWidth, height: hexHeight)
        return HexagonShape().path(in: rect)
    }

    private func drawGrid(context: inout GraphicsContext, count: Int, rows: Int, hexWidth: CGFloat, hexHeight: CGFloat) {
        for row in 0...rows {
            for col in 0..<count {
                let path = hexPath(col: col, row: row, hexWidth: hexWidth, hexHeight: hexHeight)
                context.stroke(path, with: .color(Color.gray.opacity(0.2)), lineWidth: 0.5)
            }
        }
    }

    private func drawWaveform(context: inout GraphicsContext, rows: Int, hexWidth: CGFloat, hexHeight: CGFloat) {
        context.addFilter(
            .shadow(
                color: Color.orange.opacity(glowIntensity),
                radius: 6
            )
        )

        let paths: [Path] = samples.enumerated().map { index, sample in
            let clamped = max(-1, min(1, sample))
            let normalized = (clamped + 1) / 2
            let rowIndex = Int((1 - normalized) * Double(rows - 1))
            return hexPath(
                col: index,
                row: rowIndex,
                hexWidth: hexWidth,
                hexHeight: hexHeight
            )
        }

        context.drawLayer { layer in
            for path in paths {
                layer.fill(path, with: .color(Color.orange))
            }
        }
    }
}

#Preview {
    HexagonalWaveformView(samples: Array(repeating: 0.0, count: 64))
}
