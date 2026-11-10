// The pose and face a character takes (runtime/params.ts): what the drivers, the idle motion and the bodies that are not
// a puppet (a PNGTuber, a VRM) work with.
import Foundation

public enum ParamKey: String, CaseIterable, Sendable {
    case angleX, angleY, angleZ, eyeLOpen, eyeROpen, eyeBallX, eyeBallY, browLY, browRY
    case mouthOpen, smile, vowel, bodyX, bodyZ, breath

    public var range: ClosedRange<Double> {
        switch self {
        case .angleX, .angleY, .angleZ: return -30...30
        case .eyeLOpen, .eyeROpen, .mouthOpen, .smile, .breath: return 0...1
        case .eyeBallX, .eyeBallY, .browLY, .browRY, .vowel: return -1...1
        case .bodyX, .bodyZ: return -10...10
        }
    }
}

public struct Params: Equatable, Sendable {
    public var angleX = 0.0, angleY = 0.0, angleZ = 0.0
    public var eyeLOpen = 1.0, eyeROpen = 1.0, eyeBallX = 0.0, eyeBallY = 0.0
    public var browLY = 0.0, browRY = 0.0
    public var mouthOpen = 0.0, smile = 0.0
    /// the voice's vowel: -1 round (o, u) .. +1 wide (i, e), 0 neither
    public var vowel = 0.0
    public var bodyX = 0.0, bodyZ = 0.0, breath = 0.0

    public init() {}

    public subscript(_ k: ParamKey) -> Double {
        get {
            switch k {
            case .angleX: return angleX
            case .angleY: return angleY
            case .angleZ: return angleZ
            case .eyeLOpen: return eyeLOpen
            case .eyeROpen: return eyeROpen
            case .eyeBallX: return eyeBallX
            case .eyeBallY: return eyeBallY
            case .browLY: return browLY
            case .browRY: return browRY
            case .mouthOpen: return mouthOpen
            case .smile: return smile
            case .vowel: return vowel
            case .bodyX: return bodyX
            case .bodyZ: return bodyZ
            case .breath: return breath
            }
        }
        set {
            switch k {
            case .angleX: angleX = newValue
            case .angleY: angleY = newValue
            case .angleZ: angleZ = newValue
            case .eyeLOpen: eyeLOpen = newValue
            case .eyeROpen: eyeROpen = newValue
            case .eyeBallX: eyeBallX = newValue
            case .eyeBallY: eyeBallY = newValue
            case .browLY: browLY = newValue
            case .browRY: browRY = newValue
            case .mouthOpen: mouthOpen = newValue
            case .smile: smile = newValue
            case .vowel: vowel = newValue
            case .bodyX: bodyX = newValue
            case .bodyZ: bodyZ = newValue
            case .breath: breath = newValue
            }
        }
    }
}

/// A partial set of params: offsets a driver or an action adds, or a pose to ease toward
public typealias ParamOffsets = [ParamKey: Double]

@inline(__always) public func smooth(_ a: Double, _ b: Double, _ x: Double) -> Double {
    let t = min(1, max(0, (x - a) / (b - a)))
    return t * t * (3 - 2 * t)
}

@inline(__always) public func clamp(_ v: Double, _ a: Double, _ b: Double) -> Double { min(b, max(a, v)) }

/// One Euro filter (Casiez, Roussel, Vogel, CHI 2012): smooths hard while the signal holds still and less as it moves
public final class OneEuro {
    public var minCutoff: Double
    public var beta: Double
    private var x: Double?
    private var dx = 0.0
    public init(minCutoff: Double, beta: Double) { self.minCutoff = minCutoff; self.beta = beta }
    public func reset() { x = nil; dx = 0 }
    public func filter(_ v: Double, _ dt: Double) -> Double {
        guard let x0 = x, dt > 0 else { x = v; return v }
        func alpha(_ cutoff: Double) -> Double { let r = 2 * Double.pi * cutoff * dt; return r / (r + 1) }
        dx += ((v - x0) / dt - dx) * alpha(1)
        let nx = x0 + (v - x0) * alpha(minCutoff + beta * abs(dx))
        x = nx
        return nx
    }
}

/// A small deterministic random source (the idle motion's), so tests can seed it
public struct SplitMix: RandomNumberGenerator {
    private var state: UInt64
    public init(seed: UInt64 = UInt64.random(in: 0...UInt64.max)) { state = seed }
    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    public mutating func unit() -> Double { Double(next() >> 11) / Double(1 << 53) }
}
