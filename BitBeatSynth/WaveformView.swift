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
                let path = Path { path in
                    let midY = size.height / 2
                    let step = size.width / CGFloat(samples.count)

                    path.move(to: CGPoint(x: 0, y: midY))

                    for (i, sample) in samples.enumerated() {
                        let x = CGFloat(i) * step
                        let y = midY - CGFloat(sample) * midY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }

                context.stroke(path, with: .color(.green), lineWidth: 2)
            }
        }
        .frame(height: 100)
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
    }
}
