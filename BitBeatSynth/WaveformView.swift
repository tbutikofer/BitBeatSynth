//
//  WaveformView.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 23.05.2025.
//

import SwiftUI

struct WaveformView: View {
    var samples: [Float]

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                var path = Path()
                let midY = size.height / 2
                let step = size.width / CGFloat(samples.count)

                path.move(to: CGPoint(x: 0, y: midY))

                for (i, sample) in samples.enumerated() {
                    let x = CGFloat(i) * step
                    let y = midY - CGFloat(sample) * midY
                    path.addLine(to: CGPoint(x: x, y: y))
                }

                let strokeGradient = Gradient(colors: [.green, .blue])
                context.stroke(
                    path,
                    with: .linearGradient(
                        strokeGradient,
                        startPoint: .zero,
                        endPoint: CGPoint(x: size.width, y: 0)
                    ),
                    lineWidth: 2
                )

                var fillPath = Path(path)
                fillPath.addLine(to: CGPoint(x: size.width, y: midY))
                fillPath.addLine(to: CGPoint(x: 0, y: midY))

                let fillGradient = Gradient(colors: [Color.green.opacity(0.3), .clear])
                context.fill(
                    fillPath,
                    with: .linearGradient(
                        fillGradient,
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )
            }
            .shadow(color: .green.opacity(0.5), radius: 4)
        }
        .background(Color.clear)
        .cornerRadius(10)
    }
}
