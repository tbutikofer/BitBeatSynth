//
//  DualTouchPad.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 25.05.2025.
//

import SwiftUI

struct DualTouchPad: UIViewRepresentable {
    @Binding var x: Float
    @Binding var y: Float
    @Binding var a: Float
    @Binding var b: Float

    func makeUIView(context: Context) -> TouchPadView {
        let view = TouchPadView()
        view.onUpdate = { touch1, touch2, size in
            if let t1 = touch1 {
                x = Float(t1.x / size.width * 15)
                y = Float((1.0 - t1.y / size.height) * 15)
            }
            if let t2 = touch2 {
                a = Float(t2.x / size.width * 15)
                b = Float((1.0 - t2.y / size.height) * 15)
            }
        }
        return view
    }

    func updateUIView(_ uiView: TouchPadView, context: Context) {}
}
