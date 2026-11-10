#if canImport(AVFoundation)
import AVFoundation
import Foundation
import LivLivCore
import QuartzCore

/// Lip sync to live audio (voice.ts startLipSync): the microphone through AVAudioEngine into the VoiceMeter (speech band,
/// automatic gain, the vowel), as a driver of the character's mouth. All on the device; nothing is recorded or sent.
@MainActor
public final class MicrophoneLipSync {
    private let engine = AVAudioEngine()
    public let meter = VoiceMeter()
    private var driver: MouthDriver?
    private weak var composer: PoseComposer?
    private var lastRead = 0.0
    public private(set) var running = false

    public init() {}

    /// asks for the microphone, then drives `composer`'s mouth. Throws when the microphone is refused or unavailable
    public func start(_ composer: PoseComposer, motion: Double = 1, bounce: Bool = false) async throws {
        if running { return }
        let granted = await AVAudioApplication.requestRecordPermission()
        guard granted else { throw LivLivError(.permission, "LivLiv: the microphone is not allowed for this app (Settings > Privacy > Microphone)") }
        #if os(iOS) || os(visionOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP])
        try session.setActive(true)
        #endif
        let input = engine.inputNode
        let format = input.outputFormat(forBus: 0)
        guard format.sampleRate > 0, format.channelCount > 0 else { throw LivLivError(.unreachable, "LivLiv: no microphone input on this device") }
        input.installTap(onBus: 0, bufferSize: 1024, format: format, block: Self.tap(meter))
        engine.prepare()
        try engine.start()
        let d = MouthDriver(motion: motion, bounce: bounce, read: { [weak self] in self?.read() ?? 0 }, vowel: { [weak self] in self?.meter.vowel ?? 0 })
        composer.add(d)
        driver = d; self.composer = composer
        running = true
    }

    /// the audio thread's block: samples into the meter, nothing else
    nonisolated private static func tap(_ meter: VoiceMeter) -> AVAudioNodeTapBlock {
        { buf, _ in
            guard let ch = buf.floatChannelData else { return }
            meter.push(UnsafeBufferPointer(start: ch[0], count: Int(buf.frameLength)), sampleRate: buf.format.sampleRate)
        }
    }

    private func read() -> Double {
        let now = CACurrentMediaTime(), dt = lastRead == 0 ? 1.0 / 60 : now - lastRead
        lastRead = now
        return meter.read(dt)
    }

    public func stop() {
        if let d = driver { composer?.remove(d) }
        driver = nil
        if running { engine.inputNode.removeTap(onBus: 0); engine.stop() }
        running = false
    }
}

/// Lip sync to a speech clip the app plays (voice.ts createSpeech): the clip's mouth envelope and vowel worked out once
/// when it is decoded, read at the moment it plays
@MainActor
public final class ClipLipSync: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?
    private var envelope: [Float] = []
    private var vowels: [Float] = []
    private var driver: MouthDriver?
    private weak var composer: PoseComposer?
    public var onFinish: (() -> Void)?
    public var playing: Bool { player?.isPlaying ?? false }

    public override init() { super.init() }

    /// decodes `url` (any format AVFoundation reads), then plays it with the mouth following
    public func play(_ url: URL, on composer: PoseComposer, motion: Double = 1) async throws {
        stop()
        let (env, vow) = try await Task.detached(priority: .userInitiated) { () throws -> ([Float], [Float]) in
            let file = try AVAudioFile(forReading: url)
            let fmt = file.processingFormat
            let frames = AVAudioFrameCount(min(file.length, Int64(fmt.sampleRate * 600)))
            guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frames) else { throw LivLivError(.invalid, "LivLiv: \(url.lastPathComponent) cannot be decoded") }
            try file.read(into: buf)
            let n = Int(buf.frameLength), chs = Int(fmt.channelCount)
            var mono = [Float](repeating: 0, count: n)
            if let data = buf.floatChannelData {
                for c in 0..<chs { for i in 0..<n { mono[i] += data[c][i] / Float(chs) } }
            }
            let env = SpeechTrack.envelope(mono, sampleRate: fmt.sampleRate)
            return (env, SpeechTrack.vowels(mono, sampleRate: fmt.sampleRate, envelope: env))
        }.value
        envelope = env; vowels = vow
        #if os(iOS) || os(visionOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
        let p = try AVAudioPlayer(contentsOf: url)
        p.delegate = self
        p.prepareToPlay()
        player = p
        let d = MouthDriver(motion: motion, read: { [weak self] in self?.at(self?.envelope) ?? 0 }, vowel: { [weak self] in self?.at(self?.vowels) ?? 0 })
        composer.add(d)
        driver = d; self.composer = composer
        p.play()
    }

    private func at(_ track: [Float]?) -> Double {
        guard let p = player, p.isPlaying, let track else { return 0 }
        return SpeechTrack.value(track, at: p.currentTime)
    }

    public func stop() {
        player?.stop(); player = nil
        if let d = driver { composer?.remove(d) }
        driver = nil
    }

    nonisolated public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.stop(); self.onFinish?() }
    }
}
#endif
