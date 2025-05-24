import SwiftUI

struct CustomKeyboardView: View {
    var onKeyPress: (String) -> Void

    // Define the key layout
    let rows: [[String]] = [
        ["x", "y", "r", "c", "i", "t", "7", "8", "9","⎈","⌫"],
        ["+", "-", "&", "|", "(", ")", "4", "5", "6","⏎"],
        ["*", "/", "%", "^", "<", ">", "1", "2", "3","◀︎","▶︎"],
        ["!", "=", "SPACE", ",", "0", ".", "ABC"]
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                let row = rows[rowIndex]

                HStack(spacing: 8) {
                    ForEach(row.indices, id: \.self) { keyIndex in
                        let key = row[keyIndex]

                        Button(action: {
                            switch key {
                            case "SPACE":
                                onKeyPress(" ")
                            case "⌫":
                                onKeyPress("DELETE")
                            case "⏎":
                                onKeyPress("RETURN")
                            case "ABC":
                                // optional layout toggle
                                break
                            default:
                                onKeyPress(key)
                            }
                        }) {
                            Text(key)
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .frame(width: keyWidth(for: key), height: 50)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.85))
        .cornerRadius(16)
    }

    // Key width logic: wide for SPACE and ABC
    private func keyWidth(for key: String) -> CGFloat {
        let unit: CGFloat = 50
        let spacing: CGFloat = 8

        switch key {
        case "SPACE": return 4 * unit + 3 * spacing
        case "ABC": return 2 * unit + 1 * spacing
        case "⏎": return 2 * unit + 1 * spacing
        default: return unit
        }
    }
}

