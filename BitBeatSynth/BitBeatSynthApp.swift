// BitBeatSynthApp.swift
// A basic BitWiz-style iOS app project template

import SwiftUI
import AVFoundation

@main
struct BitBeatSynthApp: App {
    @StateObject private var audioManager = AudioManager()
    @StateObject private var audioEngine = BytebeatAudioEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .environmentObject(audioEngine)
        }
    }
}
