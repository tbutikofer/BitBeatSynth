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
        audiobusController = ABAudiobusController(apiKey: "H4sIAAAAAAAAA22OQU7DMBBFr1J53dREFJpm18IBEBUrjCo7mbYjEscajxFW1bszjrpk+96fZ18V/AakrFpVb9bb7ea5bhq1VC75foCjtyOI2iPvwfIhe76ITDQcY3eB2TlkJy4WV9Wrh5VNPU4uxdZoo2UdJuKo2s+r4hzKhU10Fv5P+02mYnqIHWFgnLwMdvde9TKNwTK6ARYzW3x4LPOY3L3s2BUwWp9OtuNEQEIPr7t3oT9AcS7Wt6+lwl6M0Qyj/M9SrgjOGJlsedXob8hGPz6tG3X7A1C97mAjAQAA:dRoY0E/ropPy3IjQmUp5Mvn/+saoCeF0SSEJmz1qdCGtpAuMrJ6tXYum5Hk8RzxdPh/u4TqqAaww4A8mOaGrbhw9gIN4ho3IaFCMJWhhqANXJSwDoqrWiARUQJoXtWRM")

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
