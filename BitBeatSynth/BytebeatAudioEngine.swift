import SwiftUI
import AVFoundation

class BytebeatAudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!

    private var bytebeatPhase: Double = 0.0
    private let bytebeatRate: Double = 8000.0 / 44100.0

    @Published var isPlaying = false
    @Published var expression: (UInt32) -> UInt8 = { t in UInt8(t & 0xFF) }
    @Published var waveformBuffer: [Float] = Array(repeating: 0, count: 512)
    @Published var variableX: Float = 5
    @Published var variableY: Float = 8
    @Published var variableA: Float = 3
    @Published var variableB: Float = 11


    init() {
        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            var snapshot: [Float] = []

            for frame in 0..<Int(frameCount) {
                let t = UInt32(self.bytebeatPhase)
                let sampleByte = self.expression(t)
                let sample = Float32(Int(sampleByte) - 128) / 128.0

                self.bytebeatPhase += self.bytebeatRate

                if snapshot.count < self.waveformBuffer.count {
                    snapshot.append(sample)
                }

                for buffer in ablPointer {
                    let ptr = buffer.mData!.assumingMemoryBound(to: Float32.self)
                    ptr[frame] = sample
                }
            }

            DispatchQueue.main.async {
                self.waveformBuffer = snapshot
            }

            return noErr
        }

        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: 44100,
                                   channels: 1,
                                   interleaved: false)!
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
    }

    func start() {
        bytebeatPhase = 0.0
        do {
            try engine.start()
            isPlaying = true
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    func stop() {
        engine.stop()
        isPlaying = false
    }
}

