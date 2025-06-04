import SwiftUI

struct LiveCodingManualView: View {
    private let text: String

    init() {
        if let url = Bundle.main.url(forResource: "livecoding", withExtension: "txt"),
           let contents = try? String(contentsOf: url, encoding: .utf8) {
            self.text = contents
        } else {
            self.text = "Live coding manual not available."
        }
    }

    var body: some View {
        ScrollView {
            Text(text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, 80)
        .background(Color.black.opacity(0.15))
        .cornerRadius(8)
    }
}
