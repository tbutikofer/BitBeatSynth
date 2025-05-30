import SwiftUI

struct CustomKeyboardView: View {
    var onKeyPress: (String) -> Void

    let rows: [[String]] = [
        ["x", "y", "r", "c", "i", "t", "7", "8", "9", "⎈", "⌫"],
        ["+", "-", "&", "|", "(", ")", "4", "5", "6", "ABC"],
        ["*", "/", "%", "^", "<", ">", "1", "2", "3", "◀︎", "▶︎"],
        ["!", "=", "SPACE", ",", ".", "0", "⏎"]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        GlowingKey(
                            label: key,
                            width: keyWidth(for: key),
                            onTap: {
                                switch key {
                                case "SPACE": onKeyPress(" ")
                                case "⌫": onKeyPress("DELETE")
                                case "⏎": onKeyPress("RETURN")
                                case "ABC": break
                                default: onKeyPress(key)
                                }
                            },
                            background: backgroundColor(for: key),
                            glow: glowColor(for: key)
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .cornerRadius(16)
    }

    private func keyWidth(for key: String) -> CGFloat {
        let unit: CGFloat = 50
        let spacing: CGFloat = 8

        switch key {
        case "SPACE": return 3 * unit + 2 * spacing
        case "ABC": return 2 * unit + 1 * spacing
        case "⏎": return 3 * unit + 2 * spacing
        default: return unit
        }
    }

    private func backgroundColor(for key: String) -> Color {
        if isNumber(key) {
            return Color(red: 0.0, green: 0.4, blue: 0.0)
        } else if isParameter(key) {
            return Color(red: 0.0, green: 0.4, blue: 0.4)
        } else if isSpecial(key) {
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        } else {
            return Color(red: 0.1, green: 0.05, blue: 0.2)
        }
    }

    private func glowColor(for key: String) -> Color {
        if isNumber(key) {
            return Color.green.opacity(0.8)
        } else if isParameter(key) {
            return Color.cyan.opacity(0.7)
        } else if isSpecial(key) {
            return Color.white.opacity(0.6)
        } else {
            return Color.purple.opacity(0.7)
        }
    }

    private func isNumber(_ key: String) -> Bool {
        return Int(key) != nil
    }

    private func isParameter(_ key: String) -> Bool {
        return ["x", "y", "a", "b", "r", "c", "i", "t"].contains(key)
    }

    private func isSpecial(_ key: String) -> Bool {
        return ["SPACE", "ABC", "⏎", "⌫", "◀︎", "▶︎"].contains(key)
    }
}

// MARK: - GlowingKey

struct GlowingKey: View {
    var label: String
    var width: CGFloat
    var onTap: () -> Void
    var background: Color
    var glow: Color

    @GestureState private var isPressed = false

    var body: some View {
        Text(label)
            .font(.system(size: 20, weight: .medium, design: .monospaced))
            .frame(width: width, height: 50)
            .foregroundColor(.white.opacity(0.85))
            .background(background)
            .cornerRadius(8)
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .shadow(color: glow.opacity(isPressed ? 0.9 : 0.5), radius: isPressed ? 16 : 8)
            .gesture(
                LongPressGesture(minimumDuration: 0.001)
                    .updating($isPressed) { value, state, _ in state = value }
                    .onEnded { _ in onTap() }
            )
            .animation(.easeOut(duration: 0.2), value: isPressed)
    }
}

