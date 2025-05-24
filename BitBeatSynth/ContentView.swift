//
//  ContentView.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 22.05.2025.
//
import SwiftUI


// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var audio: BytebeatAudioEngine
    @State private var code = "t*(t>>5|t>>8)&255"

    var body: some View {
        VStack(spacing: 20) {
            Text("BitBeat Synth")
                .font(.largeTitle)
            
            TextEditor(text: $code)
                .border(Color.gray)
                .frame(height: 150)
                .onChange(of: code) {
                    debounceExpressionUpdate(code)
                }
            
            XYPad(x: $audio.variableX, y: $audio.variableY)

            Button(audio.isPlaying ? "Stop" : "Play") {
                if audio.isPlaying {
                    audio.stop()
                } else {
                    audio.start()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            WaveformView(samples: audio.waveformBuffer)
                .padding(.top)
        }
        .padding()
    }
    
    @State private var debounceTimer: Timer?

    private func debounceExpressionUpdate(_ newCode: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            DispatchQueue.main.async {
                audio.expression = BytebeatCompiler.compile(expression: code, engine: audio)
            }
        }
    }
}
