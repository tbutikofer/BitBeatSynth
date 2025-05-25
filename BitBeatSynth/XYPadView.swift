//
//  XYPadView.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 24.05.2025.
//
import SwiftUI

struct XYPad: View {
    @Binding var x: Float
    @Binding var y: Float

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.blue.opacity(0.8))

                // Overlay label in top-left
                VStack(alignment: .leading, spacing: 2) {
                    Text("x: \(Int(x))")
                    Text("y: \(Int(y))")
                }
                .font(.caption)
                .padding(6)
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(8)

                // Draggable marker
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 20, height: 20)
                    .position(
                        x: CGFloat(x / 15) * geo.size.width,
                        y: CGFloat(1.0 - y / 15) * geo.size.height
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let pos = value.location
                        x = min(max(0, Float(pos.x / geo.size.width * 15)), 15)
                        y = min(max(0, Float((1.0 - pos.y / geo.size.height) * 15)), 15)
                    }
            )
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
}
