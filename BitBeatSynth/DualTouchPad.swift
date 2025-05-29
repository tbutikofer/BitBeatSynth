//
//  DualTouchPad.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 25.05.2025.
//

import SwiftUI
import UIKit

struct DualTouchPad: UIViewRepresentable {
    @Binding var x: Float
    @Binding var y: Float
    @Binding var a: Float
    @Binding var b: Float

    func makeUIView(context: Context) -> TouchPadView {
        let view = TouchPadView()

        view.onUpdate = { t1, t2, size in
            let half = size.width / 2

            if let p1 = t1 {
                // LEFT half → full 0…15
                x = Float(p1.x / half * 15)
                y = Float((1 - p1.y / size.height) * 15)
            }

            if let p2 = t2 {
                // RIGHT half → subtract midX, then full 0…15
                let localX = p2.x - half
                a = Float(localX / half * 15)
                b = Float((1 - p2.y / size.height) * 15)
            }
        }

        return view
    }

    func updateUIView(_ uiView: TouchPadView, context: Context) {
        uiView.x = x
        uiView.y = y
        uiView.a = a
        uiView.b = b
        uiView.setNeedsDisplay()
    }
}
