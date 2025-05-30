import SwiftUI

struct ContentView: View {
    @EnvironmentObject var audio: BytebeatAudioEngine
    @State private var code = "t & 255"
    @State private var isEditingExpression = false
    @State private var compileError: String? = nil
    @State private var cursorVisible = true
    @State private var cursorTimer: Timer? = nil
    @State private var cursorIndex = 0 // optional: you can later move this with arrow keys
    @State private var x: Float = 5
    @State private var y: Float = 8
    @State private var a: Float = 3
    @State private var b: Float = 11
    @State private var activePanel: SidebarMenu.Panel? = nil


    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {

                // 1. Expression Editor (always on top)
                Group {
                        let before = String(code.prefix(cursorIndex))
                        let after = String(code.suffix(code.count - cursorIndex))

                        (
                            Text(before)
                            + (isEditingExpression && cursorVisible
                                ? Text("|").foregroundColor(.accentColor)
                                : Text(" "))
                            + Text(after)
                        )
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.white)
                    }
                    .padding()
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.15))
                    .cornerRadius(8)
                    .onTapGesture {
                        isEditingExpression = true
                        cursorIndex = code.count // 👈 place cursor at end
                    }
                    .onChange(of: code) {
                        debounceExpressionUpdate(code)
                    }

                if let error = compileError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                // 3. XYPad or Custom Keyboard
                if isEditingExpression {
                    VStack(spacing: 8) {
                        CustomKeyboardView { key in
                            switch key {
                            case "DELETE":
                                guard cursorIndex > 0, cursorIndex <= code.count else { break }
                                code.remove(at: code.index(code.startIndex, offsetBy: cursorIndex - 1))
                                cursorIndex -= 1
                                cursorIndex = min(max(0, cursorIndex), code.count)
                            case "RETURN":
                                isEditingExpression = false
                            case "◀︎":
                                if cursorIndex > 0 {
                                    cursorIndex -= 1
                                }
                            case "▶︎":
                                if cursorIndex < code.count {
                                    cursorIndex += 1
                                }
                            default:
                                // Insert character at cursor
                                let index = code.index(code.startIndex, offsetBy: cursorIndex)
                                code.insert(contentsOf: key, at: index)
                                cursorIndex += key.count
                                cursorIndex = min(max(0, cursorIndex), code.count)
                            }
                        }

                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 8) {
                        ZStack {
                            WaveformView(samples: audio.waveformBuffer)
                                .opacity(0.25) // ✅ make it subtle
                                .edgesIgnoringSafeArea(.all)

                            TouchPad(
                                x: $audio.variableX,
                                y: $audio.variableY,
                                a: $audio.variableA,
                                b: $audio.variableB
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                audio.start()
                cursorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    if isEditingExpression {
                        cursorVisible.toggle()
                    } else {
                        cursorVisible = false
                    }
                }
            }
            .onDisappear {
                cursorTimer?.invalidate()
                cursorVisible = false
            }
                
            // Add the sidebar overlay
            SidebarMenu(activePanel: $activePanel)
        }
        .sheet(item: $activePanel) { panel in
            switch panel {
            case .help: HelpPanel()
            case .settings: SettingsPanel()
            case .midi: MIDIPanel()
            case .performance: PerformancePanel()
            }
        }
    }

    // debounce as before
    @State private var debounceTimer: Timer?

    private func debounceExpressionUpdate(_ newCode: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                let (compiled, error) = BytebeatCompiler.compile(expression: newCode, engine: audio)

                if let error = error, !error.isEmpty {
                    compileError = error  // 🟥 Show error
                    // 🛑 Don't update audio.expression if invalid
                } else {
                    compileError = nil    // ✅ Clear on success
                    audio.expression = compiled
                }

            }
        }
    }

}

