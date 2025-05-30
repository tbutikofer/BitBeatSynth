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

    private var touchOrder: [UITouch] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isMultipleTouchEnabled = true
        self.backgroundColor = UIColor.clear // transparent background
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if !touchOrder.contains(touch) {
                touchOrder.append(touch)
            }
        }
        updateTouchPositions()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouchPositions()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchOrder.removeAll { $0 == touch }
        }
        if !touchOrder.contains(where: { $0 == touchOrder.first }) {
            point1 = nil
        }
        if !touchOrder.contains(where: { $0 == touchOrder.dropFirst().first }) {
            point2 = nil
        }
        updateTouchPositions()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func updateTouchPositions() {
        let height = bounds.height
        let width = bounds.width
        let usableXRange = width - 20

        if let t1 = touchOrder.first {
            let loc = t1.location(in: self)
            point1 = loc
            let clampedX = min(max(loc.x, 10), width - 10)
            x = Float((clampedX - 10) / usableXRange * 15)
            let clampedY = min(max(loc.y, 0), height)
            y = Float((1.0 - clampedY / height) * 15)
        }

        if touchOrder.count >= 2 {
            let t2 = touchOrder[1]
            let loc = t2.location(in: self)
            point2 = loc
            let clampedX = min(max(loc.x, 10), width - 10)
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

        func clamp(_ val: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
            return Swift.max(min, Swift.min(val, max))
        }

        let usableXRange = rect.width - 20

        // Blue disk
        let bluePt: CGPoint = {
            if let pt = point1 {
                return pt
            } else {
                let xPos = CGFloat(x / 15) * usableXRange + 10
                let yPos = CGFloat(1.0 - y / 15) * rect.height
                return CGPoint(x: xPos, y: yPos)
            }
        }()
        let blueX = clamp(bluePt.x, min: 10, max: rect.width - 10)
        let blueY = clamp(bluePt.y, min: 10, max: rect.height - 10)
        let blueRect = CGRect(x: blueX - 10, y: blueY - 10, width: 20, height: 20)
        UIColor.systemBlue.setFill()
        ctx.fillEllipse(in: blueRect)

        // Orange disk
        let orangePt: CGPoint = {
            if let pt = point2 {
                return pt
            } else {
                let xPos = CGFloat(a / 15) * usableXRange + 10
                let yPos = CGFloat(1.0 - b / 15) * rect.height
                return CGPoint(x: xPos, y: yPos)
            }
        }()
        let orangeX = clamp(orangePt.x, min: 10, max: rect.width - 10)
        let orangeY = clamp(orangePt.y, min: 10, max: rect.height - 10)
        let orangeRect = CGRect(x: orangeX - 10, y: orangeY - 10, width: 20, height: 20)
        UIColor.systemOrange.setFill()
        ctx.fillEllipse(in: orangeRect)

        // Top-right value label boxes
        let labelWidth: CGFloat = 100
        let boxHeight: CGFloat = 40
        let spacing: CGFloat = 8

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let labelFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)

        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph
        ]

        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: valueFont,
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraph
        ]

        // x/y label
        let xyHeader = "x / y"
        let xyValue = String(format: "%.0f / %.0f", x, y)
        let xyBox = CGRect(x: rect.width - labelWidth - 8, y: 8, width: labelWidth, height: boxHeight)
        UIColor.black.withAlphaComponent(0.4).setFill()
        UIBezierPath(roundedRect: xyBox, cornerRadius: 6).fill()
        xyHeader.draw(in: CGRect(x: xyBox.origin.x, y: xyBox.origin.y + 2, width: labelWidth, height: 14), withAttributes: labelAttributes)
        xyValue.draw(in: CGRect(x: xyBox.origin.x, y: xyBox.origin.y + 18, width: labelWidth, height: 20), withAttributes: valueAttributes)

        // a/b label below
        let abHeader = "a / b"
        let abValue = String(format: "%.0f / %.0f", a, b)
        let abBox = CGRect(x: rect.width - labelWidth - 8, y: xyBox.maxY + spacing, width: labelWidth, height: boxHeight)
        UIColor.black.withAlphaComponent(0.4).setFill()
        UIBezierPath(roundedRect: abBox, cornerRadius: 6).fill()
        abHeader.draw(in: CGRect(x: abBox.origin.x, y: abBox.origin.y + 2, width: labelWidth, height: 14), withAttributes: labelAttributes)
        abValue.draw(in: CGRect(x: abBox.origin.x, y: abBox.origin.y + 18, width: labelWidth, height: 20), withAttributes: valueAttributes)
    }
}
