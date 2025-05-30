//
//  Untitled.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 29.05.2025.
//

import SwiftUI

struct TouchPad: UIViewRepresentable {
    @Binding var x: Float
    @Binding var y: Float
    @Binding var a: Float
    @Binding var b: Float

    func makeUIView(context: Context) -> TouchPadView {
        let view = TouchPadView()
        view.onUpdate = { t1, t2, size in
            // Values already updated inside the view
            self.x = view.x
            self.y = view.y
            self.a = view.a
            self.b = view.b
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
