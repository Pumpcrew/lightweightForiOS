// Lip sync analysis (runtime/vowel.ts, runtime/voice.ts, runtime/speech.ts envelope): the mouth's openness from a voice's
// loudness, and its vowel (o / u round, i / e wide) from where its energy sits in the spectrum. The audio comes from the
// platform (LivLivKit: AVAudioEngine, AVAudioFile); everything measured is here.
import Foundation

/// which mouth shape the voice is making: -1 (round: o / u) .. +1 (wide: i / e), 0 for a and anything unsure
public final class VowelCue {
    static let back = (300.0, 900.0, 1800.0, 3500.0), close = (250.0, 650.0, 650.0, 1300.0)
    static let prior = 15.0, roundAt = 10.0, wideAt = 3.0, closeAt = 8.0
    public var center = prior
    public private(set) var value = 0.0
    private var seen = 0.0
    public init() {}

    /// one frame: `power` the linear power spectrum (bin k at k * hz), `level` its loudness 0..1
    public func push(_ power: UnsafeBufferPointer<Float>, hz: Double, level: Double, dt: Double) -> Double {
        func sum(_ a: Double, _ b: Double) -> Double {
            var s = 1e-12
            var k = Int((a / hz).rounded(.up))
            while Double(k) * hz < b && k < power.count { s += Double(power[k]); k += 1 }
            return s
        }
        let back = 10 * log10(sum(Self.back.0, Self.back.1) / sum(Self.back.2, Self.back.3))
        let close = 10 * log10(sum(Self.close.0, Self.close.1) / sum(Self.close.2, Self.close.3))
        var target = 0.0
        if level > 0.15 {
            if level > 0.3 {
                seen += dt
                let k = min(1, dt / min(3, 0.3 + seen))
                center += (min(24, max(8, back)) - center) * k
            }
            let round = (back - center) / Self.roundAt
            let wide = ((center - back) / Self.wideAt) * min(1, max(0, (close - Self.closeAt + 4) / 4))
            target = max(-1, min(1, wide > 0 ? wide : -max(0, round)))
        }
        value += (target - value) * min(1, dt / 0.035)
        return value
    }
    public func reset() { value = 0 }
}

/// a Blackman window of n points (Web Audio's analyser divides by n, vowel.ts's clip window by n - 1)
func blackman(_ n: Int, denominator: Int) -> [Float] {
    var out = [Float](repeating: 0, count: n)
    let d = Double(denominator)
    for i in 0..<n {
        let x = Double(i) / d
        let a: Double = 0.42 - 0.5 * cos(2 * Double.pi * x)
        let b: Double = 0.08 * cos(4 * Double.pi * x)
        out[i] = Float(a + b)
    }
    return out
}

/// in-place radix-2 FFT of re / im (length a power of two)
func fft(_ re: inout [Float], _ im: inout [Float]) {
    let n = re.count
    var j = 0
    for i in 1..<n {
        var bit = n >> 1
        while j & bit != 0 { j ^= bit; bit >>= 1 }
        j ^= bit
        if i < j { re.swapAt(i, j); im.swapAt(i, j) }
    }
    var len = 2
    while len <= n {
        let a = -2 * Double.pi / Double(len), wr = cos(a), wi = sin(a)
        var i = 0
        while i < n {
            var cr = 1.0, ci = 0.0
            for k in 0..<(len / 2) {
                let p = i + k, q = p + len / 2
                let tr = Double(re[q]) * cr - Double(im[q]) * ci, ti = Double(re[q]) * ci + Double(im[q]) * cr
                re[q] = re[p] - Float(tr); im[q] = im[p] - Float(ti); re[p] += Float(tr); im[p] += Float(ti)
                let c2 = cr * wr - ci * wi; ci = cr * wi + ci * wr; cr = c2
            }
            i += len
        }
        len <<= 1
    }
}

/// a speech clip's mouth envelope at 100 frames a second, LEAD frames ahead of the sound (speech.ts envelope)
public enum SpeechTrack {
    public static let fps = 100.0, lead = 3

    public static func envelope(_ x: [Float], sampleRate sr: Double) -> [Float] {
        let hop = max(1, Int((sr / fps).rounded())), n = (x.count + hop - 1) / hop
        guard n > 0 else { return [] }
        let lp = 1 - exp(-2 * Double.pi * 1500 / sr), hp = 1 - exp(-2 * Double.pi * 150 / sr)
        var sum = [Double](repeating: 0, count: n)
        var a = 0.0, b = 0.0
        for i in 0..<x.count {
            a += (Double(x[i]) - a) * lp; b += (a - b) * hp
            let v = a - b
            sum[i / hop] += v * v
        }
        var e = [Double](repeating: 0, count: n)
        var mx = 0.0
        for i in 0..<n { e[i] = ((sum[i] + (i + 1 < n ? sum[i + 1] : 0)) / Double(2 * hop)).squareRoot(); mx = max(mx, e[i]) }
        if mx == 0 { return [Float](repeating: 0, count: n) }
        let voiced = e.filter { $0 > mx * 0.05 }.sorted()
        let ref = voiced.isEmpty ? mx : voiced[min(voiced.count - 1, Int(Double(voiced.count) * 0.9))], gate = ref * 0.1
        let lv = e.map { pow(min(1, max(0, ($0 - gate) / max(ref - gate, 1e-6))), 0.75) }
        let K = 10
        var out = [Double](repeating: 0, count: n)
        var s = 0.0
        for i in 0..<n {
            var avg = 0.0
            for j in (i - K)...(i + K) { avg += lv[min(n - 1, max(0, j))] }
            avg /= Double(2 * K + 1)
            let o = min(1, max(0, lv[i] * 0.6 + (lv[i] - avg) * 1.2))
            s += (o - s) * (o > s ? 0.6 : 0.45)
            out[i] = s
        }
        return (0..<n).map { i in i + lead < n ? Float(out[i + lead]) : 0 }
    }

    /// the vowel cue for each envelope frame (vowel.ts vowelTrack): Blackman window ~21 ms, like the microphone's analyser
    public static func vowels(_ x: [Float], sampleRate sr: Double, envelope env: [Float], cue: VowelCue = VowelCue()) -> [Float] {
        let hop = sr / fps
        let size = 1 << Int(log2(0.0213 * sr).rounded())
        let win = blackman(size, denominator: size - 1)
        var re = [Float](repeating: 0, count: size), im = re, pw = [Float](repeating: 0, count: size / 2)
        var out = [Float](repeating: 0, count: env.count)
        for f in 0..<env.count {
            let c = Int((Double(f + lead) * hop).rounded())
            for i in 0..<size { let j = c - size / 2 + i; re[i] = (j >= 0 && j < x.count ? x[j] : 0) * win[i]; im[i] = 0 }
            fft(&re, &im)
            for k in 0..<(size / 2) { pw[k] = re[k] * re[k] + im[k] * im[k] }
            out[f] = Float(pw.withUnsafeBufferPointer { cue.push($0, hz: sr / Double(size), level: Double(env[f]), dt: 1 / fps) })
        }
        return out
    }

    /// the track's value at `seconds` into the clip, between its frames
    public static func value(_ track: [Float], at seconds: Double) -> Double {
        let f = seconds * fps, i = Int(f.rounded(.down)), k = f - Double(i)
        guard i >= 0, i < track.count else { return 0 }
        let a = Double(track[i]), b = i + 1 < track.count ? Double(track[i + 1]) : 0
        return a + (b - a) * k
    }
}

/// RBJ band-pass (constant 0 dB peak), as Web Audio's BiquadFilterNode 'bandpass'
struct Biquad {
    var b0 = 0.0, b1 = 0.0, b2 = 0.0, a1 = 0.0, a2 = 0.0
    var x1 = 0.0, x2 = 0.0, y1 = 0.0, y2 = 0.0
    init(bandpass f: Double, q: Double, sampleRate sr: Double) {
        let w0 = 2 * Double.pi * f / sr, alpha = sin(w0) / (2 * q), a0 = 1 + alpha
        b0 = alpha / a0; b1 = 0; b2 = -alpha / a0; a1 = -2 * cos(w0) / a0; a2 = (1 - alpha) / a0
    }
    mutating func process(_ x: Double) -> Double {
        let y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2 = x1; x1 = x; y2 = y1; y1 = y
        return y
    }
}

/// live audio -> mouth open (PNGTuber-style lip sync): speech band only, automatic gain, the vowel from the spectrum.
/// `push` takes samples from the audio thread; `read` runs once per frame
public final class VoiceMeter: @unchecked Sendable {
    public static let size = 1024
    public var gain = 1.0
    public private(set) var level = 0.0
    public private(set) var vowel = 0.0
    private let lock = NSLock()
    private var band: Biquad?
    private var rate = 48000.0
    private var filtered = [Float](repeating: 0, count: size), raw = [Float](repeating: 0, count: size)
    private var head = 0
    private var floor = 0.004, peak = 0.05
    private let cue = VowelCue()
    private let win: [Float] = blackman(size, denominator: size)
    public init() {}

    public func push(_ samples: UnsafeBufferPointer<Float>, sampleRate: Double) {
        lock.lock(); defer { lock.unlock() }
        if band == nil || sampleRate != rate { rate = sampleRate; band = Biquad(bandpass: 650, q: 0.55, sampleRate: sampleRate) }
        for s in samples {
            raw[head] = s
            filtered[head] = Float(band!.process(Double(s)))
            head = (head + 1) % Self.size
        }
    }

    /// 0..1 mouth openness, smoothed; call once per frame
    public func read(_ dtIn: Double) -> Double {
        let dt = min(0.1, dtIn > 0 ? dtIn : 1.0 / 60)
        lock.lock()
        let n = Self.size
        var f = [Float](repeating: 0, count: n), r = [Float](repeating: 0, count: n)
        for i in 0..<n { f[i] = filtered[(head + i) % n]; r[i] = raw[(head + i) % n] }
        let sr = rate
        lock.unlock()
        var s = 0.0
        for v in f { s += Double(v) * Double(v) }
        let rms = (s / Double(n)).squareRoot()
        floor = rms < floor ? floor + (rms - floor) * min(1, dt * 4) : floor + (rms - floor) * dt * 0.05
        floor = max(0.0005, floor)
        let gate = floor * 2.2
        peak = max(rms, gate * 3, 0.012, peak * exp(-dt / 3))
        let x = min(1, max(0, (rms - gate) / (peak - gate)))
        let target = min(1, pow(x, 0.8) * 1.1 * gain)
        level += (target - level) * min(1, dt * (target > level ? 30 : 14))
        var re = [Float](repeating: 0, count: n), im = re
        for i in 0..<n { re[i] = r[i] * win[i] }
        fft(&re, &im)
        var pw = [Float](repeating: 0, count: n / 2)
        for k in 0..<(n / 2) { pw[k] = re[k] * re[k] + im[k] * im[k] }
        vowel = pw.withUnsafeBufferPointer { cue.push($0, hz: sr / Double(n), level: level, dt: dt) }
        return level
    }
}
