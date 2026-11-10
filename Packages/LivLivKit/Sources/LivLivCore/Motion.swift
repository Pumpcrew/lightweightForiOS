// Talking without a camera (runtime/talk.ts) and one-shot actions (runtime/actions.ts).
import Foundation

/// the voice also moves the head, brows and eyes, the way people move while they speak
public final class TalkMotion {
    public var amount = 1.0
    public var bounce = false
    public private(set) var pauseBlink = false
    public private(set) var act = 0.0
    public private(set) var hop = 0.0
    private var armed = true, valley = 0.0, peak = 0.0, quiet = 10.0, sinceNod = 10.0, sinceBrow = 10.0
    private var nod = (x: 0.0, v: 0.0), lift = (x: 0.0, v: 0.0)
    private var browAge = 10.0
    private var dir = (x: 0.0, y: 0.0), aim = (x: 0.0, y: 0.0)
    private var phase: [Double]
    private var t = 0.0
    private var rng: SplitMix
    private static let rise = 0.25, onset = 0.35, fall = 0.15, quietLevel = 0.2

    public init(seed: UInt64 = UInt64.random(in: 0...UInt64.max)) {
        rng = SplitMix(seed: seed)
        phase = [rng.unit() * 9, rng.unit() * 9, rng.unit() * 9]
    }

    private static func step(_ s: inout (x: Double, v: Double), _ k: Double, _ c: Double, _ dt: Double) {
        s.v += (-k * s.x - c * s.v) * dt; s.x += s.v * dt
    }

    /// level: the mouth openness the voice drives (0..1), once per frame. Returns offsets to add to the idle pose
    public func update(_ level: Double, _ dt: Double, _ P: Params) -> ParamOffsets {
        t += dt; quiet += dt; sinceNod += dt; sinceBrow += dt
        pauseBlink = false
        let was = act
        if level > Self.quietLevel { quiet = 0 }
        act += ((quiet < 0.35 ? 1 : 0) - act) * min(1, dt * (quiet < 0.35 ? 6 : 1.2))
        if was > 0.6 && act <= 0.6 && quiet > 0.4 { pauseBlink = true }
        if !armed {
            peak = max(peak, level)
            if level < peak - Self.fall { armed = true; valley = level }
        } else {
            valley = min(valley, level)
            if level - valley > Self.rise && level > Self.onset {
                armed = false; peak = level
                let phrase = act < 0.3
                if phrase { aim = ((rng.unit() * 2 - 1) * 5, (rng.unit() - 0.3) * 2.5) }
                if sinceNod > 0.35 && (phrase || rng.unit() < 0.35) {
                    nod.v -= (phrase ? 70 : 35 + rng.unit() * 30) * amount; sinceNod = 0
                }
                if sinceBrow > 1.2 && rng.unit() < (phrase ? 0.5 : 0.18) { browAge = 0; sinceBrow = 0 }
                if bounce { lift.v += (0.3 + rng.unit() * 0.12) * amount }
            }
        }
        let n = max(1, Int((dt / (1.0 / 120)).rounded(.up)))
        for _ in 0..<n { Self.step(&nod, 150, 15, dt / Double(n)); Self.step(&lift, 230, 19, dt / Double(n)) }
        browAge += dt
        let a = act * amount, ph = phase
        let talking = quiet < 0.35, back = min(1, dt * (talking ? 3 : 0.45))
        dir.x += ((talking ? aim.x : 0) - dir.x) * back
        dir.y += ((talking ? aim.y : 0) - dir.y) * back
        let driftX = (sin(t * 0.9 + ph[0]) * 0.6 + sin(t * 1.7 + ph[1]) * 0.4) * 3.5 * a
        let driftZ = (sin(t * 0.7 + ph[2]) * 0.6 + sin(t * 1.3 + ph[0]) * 0.4) * 2.5 * a
        var o: ParamOffsets = [:]
        o[.angleX] = dir.x * amount + driftX
        o[.angleY] = nod.x + dir.y * amount
        o[.angleZ] = driftZ
        o[.bodyX] = o[.angleX]! * 0.15
        let brow = smooth(0, 0.12, browAge) * (1 - smooth(0.3, 0.65, browAge)) * 0.55 * amount
        o[.browLY] = brow; o[.browRY] = brow
        o[.eyeBallX] = -P.eyeBallX * 0.7 * act
        o[.eyeBallY] = -P.eyeBallY * 0.7 * act
        let cap = 0.02 * amount
        hop = bounce ? min(cap, max(0, lift.x)) - cap : 0
        return o
    }

    public func reset() {
        act = 0; hop = 0; armed = true; valley = 0; peak = 0; quiet = 10; browAge = 10
        nod = (0, 0); lift = (0, 0); dir = (0, 0); aim = (0, 0)
    }
}

public enum ActionID: String, CaseIterable, Sendable { case nod, shake, tilt, hop, shy }

/// short moves on top of whatever drives the character, each a curve of parameter offsets that fades in and out
/// (runtime/actions.ts), tuned so each reads as its button says:
///  - nod: the head dips down twice (22° then 10°: the original's 11° moved the face ~6 px, hard to see)
///  - shake: the head turns side to side (21°) while the torso stays put
///  - tilt: the head tilts on the neck while the torso stays put
///  - hop: a crouch, then up; a half-body character (cut off at the bottom edge, which must never lift into view) springs
///    toward the viewer instead (a quick swell of its size), so the jump shows
///  - shy: looks down and away, with the model's own shy face where it has one
/// The rig turns and leans the torso with the head (rig.body.yaw / roll); for a LivLiv model the shares come in
/// bodyYawShare / bodyRollShare and the moves that are the head's alone cancel them
public final class ActionPlayer {
    private var playing: [(id: ActionID, t: Double, out: Double)] = []
    public var away = false
    /// the share of the head's turn (angleX) and tilt (angleZ) the torso follows: rig.body.yaw / roll x tuning.turn
    public var bodyYawShare = 0.0
    public var bodyRollShare = 0.0
    /// the picture is cut off at its bottom edge (half-body): it cannot move up
    public var halfBody = false
    public private(set) var awayW = 0.0
    /// the picture's vertical move (share of its height, up) and scale
    public private(set) var y = 0.0
    public private(set) var s = 1.0
    /// expressions an action shows while it plays (by standard expression id)
    public private(set) var expr: [String: Double] = [:]

    private static func dur(_ id: ActionID) -> Double {
        switch id { case .nod: return 1.0; case .shake: return 1.05; case .tilt: return 1.8; case .hop: return 0.65; case .shy: return 2.4 }
    }
    private static func envelope(_ t: Double, _ d: Double) -> Double { smooth(0, 0.18, t) * (1 - smooth(d - 0.22, d, t)) }

    private func curve(_ id: ActionID, _ t: Double) -> (ParamOffsets, Double, Double, [String: Double]) {
        let d = Self.dur(id), e = Self.envelope(t, d)
        var o: ParamOffsets = [:]
        var y = 0.0, sc = 1.0
        var ex: [String: Double] = [:]
        switch id {
        case .nod:
            // down (angleY < 0), back, a smaller second dip
            o[.angleY] = -(t < 0.45 ? 22 * sin(.pi * t / 0.45) : 10 * sin(.pi * min(t - 0.45, 0.42) / 0.42)) * e
            o[.eyeBallY] = -0.15 * e
        case .shake:
            o[.angleX] = 21 * sin(2 * .pi * t / 0.5) * e
            o[.bodyX] = -o[.angleX]! * bodyYawShare
        case .tilt:
            o[.angleZ] = 11 * e; o[.angleX] = 3 * e; o[.angleY] = 2 * e
        case .hop:
            if halfBody {
                y = t < 0.2 ? -0.02 * sin(.pi * t / 0.2) : 0
                sc = t > 0.15 && t < 0.6 ? 1 + 0.045 * sin(.pi * (t - 0.15) / 0.45) : 1
            } else {
                y = t < 0.2 ? -0.025 * sin(.pi * t / 0.2) : t < 0.6 ? 0.04 * sin(.pi * (t - 0.2) / 0.4) : 0
            }
            o[.angleY] = t > 0.2 && t < 0.6 ? 5 * sin(.pi * (t - 0.2) / 0.4) * e : 0
        case .shy:
            o[.angleY] = -12 * e; o[.angleX] = 9 * e; o[.angleZ] = -4 * e; o[.eyeBallX] = 0.7 * e; o[.eyeBallY] = -0.5 * e
            ex["shy"] = e
        }
        // the head's tilt is the head's: the torso does not lean with it
        if let z = o[.angleZ], bodyRollShare != 0 { o[.bodyZ, default: 0] -= z * bodyRollShare }
        return (o, y, sc, ex)
    }

    public init() {}

    public func play(_ id: ActionID) {
        for i in playing.indices where playing[i].id == id && playing[i].out < 0 { playing[i].out = 0 }
        playing.append((id, 0, -1))
    }
    public var busy: Bool { !playing.isEmpty || awayW > 0 }

    public func update(_ dt: Double) -> ParamOffsets {
        var o: ParamOffsets = [:]
        y = 0; s = 1; expr = [:]
        for i in playing.indices {
            playing[i].t += dt
            if playing[i].out >= 0 { playing[i].out += dt }
            let p = playing[i]
            let (off, my, ms, ex) = curve(p.id, min(p.t, Self.dur(p.id)))
            let f = p.out < 0 ? 1 : 1 - smooth(0, 0.15, p.out)
            for (k, v) in off { o[k, default: 0] += v * f }
            y += my * f
            s *= 1 + (ms - 1) * f
            for (k, v) in ex { expr[k] = max(expr[k] ?? 0, v * f) }
        }
        playing.removeAll { !($0.t < Self.dur($0.id) && $0.out < 0.15) }
        awayW += ((away ? 1 : 0) - awayW) * min(1, dt * (away ? 2.2 : 4))
        if awayW < 0.002 && !away { awayW = 0 }
        return o
    }

    /// the away pose at time t: eyes closed, head down and a little to one side, a slow breath
    public func awayPose(_ t: Double) -> ParamOffsets {
        [.eyeLOpen: 0, .eyeROpen: 0, .angleY: -14, .angleZ: 5, .angleX: 0, .mouthOpen: 0, .smile: 0, .eyeBallX: 0, .eyeBallY: -0.3,
         .breath: 0.5 + 0.5 * sin(t * 1.15)]
    }
}
