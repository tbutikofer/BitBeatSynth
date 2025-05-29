//
//  TouchPadView.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 25.05.2025.
//

import UIKit

class TouchPadView: UIView {
    var x: Float = 0
    var y: Float = 0
    var a: Float = 0
    var b: Float = 0

    var onUpdate: ((_ touch1: CGPoint?, _ touch2: CGPoint?, _ size: CGSize) -> Void)?

    private var point1: CGPoint?
    private var point2: CGPoint?

    private var leftTouch: UITouch?
    private var rightTouch: UITouch?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = true
        self.backgroundColor = UIColor.darkGray
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        assignTouches(touches)
        updateTouchPositions()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouchPositions()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == leftTouch { leftTouch = nil; point1 = nil }
            if touch == rightTouch { rightTouch = nil; point2 = nil }
        }
        setNeedsDisplay()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func assignTouches(_ touches: Set<UITouch>) {
        for touch in touches {
            let loc = touch.location(in: self)
            let isLeft = loc.x < bounds.midX

            if isLeft && leftTouch == nil {
                leftTouch = touch
            } else if !isLeft && rightTouch == nil {
                rightTouch = touch
            }
        }
    }

    private func updateTouchPositions() {
        let halfWidth = bounds.width / 2
        let height = bounds.height
        let usableXRange = halfWidth - 20

        if let lt = leftTouch {
            let loc = lt.location(in: self)
            point1 = loc

            let clampedX = min(max(loc.x, 10), halfWidth - 10 - 0.001)
            x = Float((clampedX - 10) / usableXRange * 15)

            let clampedY = min(max(loc.y, 0), height)
            y = Float((1.0 - clampedY / height) * 15)
        }

        if let rt = rightTouch {
            let loc = rt.location(in: self)
            point2 = loc

            let localX = loc.x - halfWidth
            let clampedX = min(max(localX, 10), usableXRange - 0.001)
            a = Float((clampedX - 10) / usableXRange * 15)

            let clampedY = min(max(loc.y, 0), height)
            b = Float((1.0 - clampedY / height) * 15)
        }

        onUpdate?(point1, point2, bounds.size)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.clear(rect)

        // Split line
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        ctx.setLineWidth(1)
        ctx.move(to: CGPoint(x: rect.midX, y: 0))
        ctx.addLine(to: CGPoint(x: rect.midX, y: rect.height))
        ctx.strokePath()

        // Clamp helper
        func clamp(_ val: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
            return Swift.max(min, Swift.min(val, max))
        }

        let usableXRange = rect.width / 2 - 20

        // Blue disk (x/y)
        let bluePt: CGPoint = {
            if let pt = point1 {
                return pt
            } else {
                let xPos = CGFloat(x / 15) * usableXRange + 10
                let yPos = CGFloat(1.0 - y / 15) * rect.height
                return CGPoint(x: xPos, y: yPos)
            }
        }()
        let blueX = clamp(bluePt.x, min: 10, max: rect.width / 2 - 10)
        let blueY = clamp(bluePt.y, min: 10, max: rect.height - 10)
        let blueRect = CGRect(x: blueX - 10, y: blueY - 10, width: 20, height: 20)
        UIColor.systemBlue.setFill()
        ctx.fillEllipse(in: blueRect)

        // Orange disk (a/b)
        let orangePt: CGPoint = {
            if let pt = point2 {
                return pt
            } else {
                let xPos = rect.midX + CGFloat(a / 15) * usableXRange + 10
                let yPos = CGFloat(1.0 - b / 15) * rect.height
                return CGPoint(x: xPos, y: yPos)
            }
        }()
        let orangeX = clamp(orangePt.x, min: rect.midX + 10, max: rect.width - 10)
        let orangeY = clamp(orangePt.y, min: 10, max: rect.height - 10)
        let orangeRect = CGRect(x: orangeX - 10, y: orangeY - 10, width: 20, height: 20)
        UIColor.systemOrange.setFill()
        ctx.fillEllipse(in: orangeRect)

        // Value overlays
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph
        ]

        let xyString = String(format: "x/y: %.0f/%.0f", x, y)
        let abString = String(format: "a/b: %.0f/%.0f", a, b)

        let boxXY = CGRect(x: 8, y: 8, width: rect.width / 2 - 16, height: 20)
        UIColor.black.withAlphaComponent(0.4).setFill()
        UIBezierPath(roundedRect: boxXY, cornerRadius: 6).fill()
        xyString.draw(at: CGPoint(x: 12, y: 10), withAttributes: attributes)

        let boxAB = CGRect(x: rect.midX + 8, y: 8, width: rect.width / 2 - 16, height: 20)
        UIColor.black.withAlphaComponent(0.4).setFill()
        UIBezierPath(roundedRect: boxAB, cornerRadius: 6).fill()
        abString.draw(at: CGPoint(x: rect.midX + 12, y: 10), withAttributes: attributes)
    }
}
