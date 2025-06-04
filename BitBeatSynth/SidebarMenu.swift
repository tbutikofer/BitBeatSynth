//
//  SidebarMenu.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 29.05.2025.
//

// SidebarMenu.swift
import SwiftUI

struct SidebarMenu: View {
    @Binding var activePanel: Panel?
    
    enum Panel: String, Identifiable, CaseIterable {
        case help, settings, midi, performance

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .help: return "questionmark.circle"
            case .settings: return "gearshape"
            case .midi: return "pianokeys"
            case .performance: return "music.mic"
            }
        }
        var label: String {
            switch self {
            case .help: return "Help"
            case .settings: return "Settings"
            case .midi: return "MIDI"
            case .performance: return "Live Coding Mode"
            }
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            ForEach(Panel.allCases) { panel in
                Button(action: {
                    activePanel = panel
                }) {
                    Image(systemName: panel.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.blue.opacity(0.3))
                        .clipShape(Circle())
                        .help(panel.label)
                }
            }
            Spacer()
        }
        .padding(.top, 40)
        .padding(.leading, 8)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.black.opacity(0.2))
    }
}

// Placeholder Panels
struct HelpPanel: View {
    var body: some View {
        Text("Help & Instructions")
            .padding()
    }
}

struct SettingsPanel: View {
    var body: some View {
        Text("App Settings")
            .padding()
    }
}

struct MIDIPanel: View {
    var body: some View {
        Text("MIDI Bindings")
            .padding()
    }
}

struct PerformancePanel: View {
    var body: some View {
        Text("Live Coding Mode")
            .padding()
    }
}
