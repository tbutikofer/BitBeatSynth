//
//  AudioManager.swift
//  BitBeatSynth
//
//  Created by Thomas Bütikofer on 31.05.2025.
//

import Foundation
import Audiobus
import AudioToolbox

class AudioManager: ObservableObject {
    @Published var isConnectedToAudiobus = false

    var audiobusController: ABAudiobusController?
    var senderPort: ABAudioSenderPort?

    init() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "AudiobusAPIKey") as? String {
            audiobusController = ABAudiobusController(apiKey: apiKey)
        } else {
            print("AudiobusAPIKey missing from Info.plist")
        }

        let description = AudioComponentDescription(
            componentType: FourCharCode("aurg"),
            componentSubType: FourCharCode("btbt"),
            componentManufacturer: FourCharCode("SDAR"),
            componentFlags: 0,
            componentFlagsMask: 0
        )

        senderPort = ABAudioSenderPort(
            name: "BitBeatSynthPort",
            title: "BitBeat Output",
            audioComponentDescription: description
        )

        if let senderPort = senderPort {
            audiobusController?.addAudioSenderPort(senderPort)
        }

        // 🔍 4. Debug output (3 seconds after launch)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if let connected = self.audiobusController?.connected {
                    print("🔌 Audiobus connected? \(connected ? "✅ YES" : "❌ NO")")
                } else {
                    print("⚠️ Audiobus controller not initialized")
                }

                if let portName = self.senderPort?.name {
                    print("🎛️ Audiobus port registered: \(portName)")
                } else {
                    print("❌ senderPort is nil")
                }
            }

        // Observe Audiobus connection state
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let controller = self?.audiobusController else { return }

            DispatchQueue.main.async {
                self?.isConnectedToAudiobus = controller.connected
            }
        }
    }


    // FourCharCode helper
    func FourCharCode(_ string: String) -> OSType {
        var result: UInt32 = 0
        for char in string.utf8.prefix(4) {
            result = (result << 8) + UInt32(char)
        }
        return result
    }
}
