//
//  TouchPadView.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 25.05.2025.
//

import UIKit

class TouchPadView: UIView {
    var onUpdate: ((_ touch1: CGPoint?, _ touch2: CGPoint?, _ size: CGSize) -> Void)?

    private var touches: [UITouch: CGPoint] = [:]
    var x: Float = 0
    var y: Float = 0
    var a: Float = 0
    var b: Float = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = true
        self.backgroundColor = UIColor.darkGray // in init
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touches[t] = t.location(in: self)
        }
        update()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touches[t] = t.location(in: self)
        }
        update()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touches.removeValue(forKey: t)
        }
        update()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touches.removeValue(forKey: t)
        }
        update()
    }

    private func update() {
        let points = Array(touches.values.prefix(2))
        let t1 = points.count > 0 ? points[0] : nil
        let t2 = points.count > 1 ? points[1] : nil
        onUpdate?(t1, t2, self.bounds.size)
        if let t1 = t1 {
            x = Float(t1.x / bounds.width * 15)
            y = Float((1.0 - t1.y / bounds.height) * 15)
        }
        if let t2 = t2 {
            a = Float(t2.x / bounds.width * 15)
            b = Float((1.0 - t2.y / bounds.height) * 15)
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.clear(rect)

        // Always show based on stored values
        let xPos = CGFloat(x / 15) * rect.width
        let yPos = CGFloat(1.0 - y / 15) * rect.height
        let aPos = CGFloat(a / 15) * rect.width
        let bPos = CGFloat(1.0 - b / 15) * rect.height

        let safeX1 = min(max(xPos, 10), rect.width - 10)
        let safeY1 = min(max(yPos, 10), rect.height - 10)
        let r1 = CGRect(x: safeX1 - 10, y: safeY1 - 10, width: 20, height: 20)
        UIColor.systemBlue.setFill()
        ctx.fillEllipse(in: r1)

        let safeX2 = min(max(aPos, 10), rect.width - 10)
        let safeY2 = min(max(bPos, 10), rect.height - 10)
        let r2 = CGRect(x: safeX2 - 10, y: safeY2 - 10, width: 20, height: 20)
        UIColor.systemOrange.setFill()
        ctx.fillEllipse(in: r2)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph
        ]

        // Compose the value strings
        let xyString = "x/y: \(Int(x)), \(Int(y))"
        let abString = "a/b: \(Int(a)), \(Int(b))"

        // Draw background box
        let box = CGRect(x: 8, y: 8, width: 100, height: 36)
        UIColor.black.withAlphaComponent(0.4).setFill()
        UIBezierPath(roundedRect: box, cornerRadius: 6).fill()

        // Draw text lines
        xyString.draw(at: CGPoint(x: 12, y: 10), withAttributes: attributes)
        abString.draw(at: CGPoint(x: 12, y: 24), withAttributes: attributes)
    }
}

