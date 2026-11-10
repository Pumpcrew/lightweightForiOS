// What Player and BodyPlayer have in common (base.ts PlayerBase.draw, voice.ts, tracking.ts): each frame the pose is put
// together from scratch: your `params`, then the idle motion, then the drivers in order, then actions and expressions,
// kept in their ranges. Nothing added is written back to `params`.
import Foundation

/// one frame being put together, as a driver sees it
public final class FrameContext {
    public internal(set) var params = Params()
    public internal(set) var dt = 0.0
    public internal(set) var time = 0.0
    /// a face tracker drives the head this frame (lip sync then leaves the head alone)
    public var tracked = false
    /// move the picture: x, y shares of the view (y up), s a scale
    public var move = (x: 0.0, y: 0.0, s: 1.0)
    public func add(_ o: ParamOffsets) {
        for (k, v) in o where v != 0 { params[k] = clamp(params[k] + v, k.range.lowerBound, k.range.upperBound) }
    }
    public func set(_ k: ParamKey, _ v: Double) { params[k] = v }
}

/// something that moves the character each frame: face tracking (-10), yours (0), lip sync (10)
public protocol PoseDriver: AnyObject {
    var order: Int { get }
    func update(_ frame: FrameContext, _ composer: PoseComposer)
}

public final class PoseComposer {
    /// your values for the pose and face; the composer never changes them
    public var params = Params()
    public var idle = true
    public let idler: IdleController
    public let actions = ActionPlayer()
    public private(set) var drivers: [PoseDriver] = []
    private var expr: [String: Double] = [:]
    private var smile = 0.0
    private var was = (tracked: false, mouth: 0.0)
    public let frame = FrameContext()
    /// each expression's weight as shown, eased
    public private(set) var shownExpr: [String: Double] = [:]
    public private(set) var clock = 0.0
    /// the expression ids the loaded character has (setExpression accepts these)
    public var available: [String] = []
    /// the share of the head's tilt (angleZ) the character's torso follows (a LivLiv model: rig.body.roll x tuning.turn;
    /// 0 for a PNGTuber or a VRM). What tilts only the head (the tilt action, a tracked face's tilt) cancels it, so the
    /// head tilts on the neck instead of the upper body leaning with it
    public var bodyRollShare = 0.0 { didSet { actions.bodyRollShare = bodyRollShare } }

    public init(seed: UInt64 = UInt64.random(in: 0...UInt64.max)) { idler = IdleController(seed: seed) }

    public func add(_ d: PoseDriver) {
        drivers.append(d)
        drivers.sort { $0.order < $1.order }
    }
    public func remove(_ d: PoseDriver) { drivers.removeAll { $0 === d } }

    /// a new character starts on a neutral face
    public func neutral() { expr = [:]; smile = 0; shownExpr = [:]; clock = 0 }

    /// shows an expression (an id from `available`), easing over from the one before; nil goes back to neutral
    @discardableResult public func setExpression(_ id: String?, weight: Double = 1) -> Bool {
        if let id, !available.contains(id) { return false }
        let w = clamp(weight, 0, 1)
        smile = id == "smile" ? w : 0
        expr = id == nil || id == "smile" ? [:] : [id!: w]
        return true
    }
    public var currentExpression: String? { smile > 0 ? "smile" : expr.keys.first }

    public func blink() { idler.blink(clock) }

    /// the pose for this frame, `dt` seconds after the last one
    public func compose(_ dt: Double) -> (params: Params, move: (x: Double, y: Double, s: Double), expr: [String: Double]) {
        let f = frame, A = actions
        clock += dt
        let t = clock
        idler.shown(f.params)
        f.params = params
        if idle {
            idler.apply(&f.params, t, dt, busy: A.busy || was.mouth > 0.05, tracked: was.tracked,
                        faceFree: smile == 0 && !shownExpr.values.contains { $0 > 0.02 })
        }
        f.dt = dt; f.time = t; f.tracked = false
        f.move = (0, 0, 1)
        for d in drivers { d.update(f, self) }
        was = (f.tracked, f.params.mouthOpen)
        f.add(A.update(dt))
        if smile > 0 { f.params.smile = max(f.params.smile, smile) }
        if A.awayW > 0 { for (k, v) in A.awayPose(t) { f.params[k] += (v - f.params[k]) * A.awayW } }
        let defaults = Params()
        for k in ParamKey.allCases {
            let v = f.params[k]
            f.params[k] = v.isNaN ? defaults[k] : clamp(v, k.range.lowerBound, k.range.upperBound)
        }
        // what an action shows (the shy move's shy face), where the character has that expression
        let pulse = A.expr.filter { available.contains($0.key) && $0.key != "smile" }
        for k in expr.keys where shownExpr[k] == nil { shownExpr[k] = 0 }
        for k in pulse.keys where shownExpr[k] == nil { shownExpr[k] = 0 }
        for k in Array(shownExpr.keys) {
            let target = max(expr[k] ?? 0, pulse[k] ?? 0) * (1 - A.awayW)
            shownExpr[k]! += (target - shownExpr[k]!) * min(1, dt * 8)
        }
        return (f.params, (f.move.x, f.move.y + A.y, f.move.s * A.s), shownExpr)
    }
}

/// lip sync: the mouth follows a voice, and without face tracking the voice also moves the head a little (voice.ts mouth)
public final class MouthDriver: PoseDriver {
    public let order = 10
    private let read: () -> Double
    private let vowel: () -> Double
    public var motion: Double
    public var bounce: Bool
    private let talk = TalkMotion()
    public init(motion: Double = 1, bounce: Bool = false, read: @escaping () -> Double, vowel: @escaping () -> Double) {
        self.motion = motion; self.bounce = bounce; self.read = read; self.vowel = vowel
    }
    public func update(_ f: FrameContext, _ composer: PoseComposer) {
        let level = read()
        f.params.mouthOpen = max(f.params.mouthOpen, level)
        f.params.vowel = vowel()
        if !f.tracked && motion > 0 {
            talk.amount = motion; talk.bounce = bounce
            f.add(talk.update(level, f.dt, f.params))
            if talk.pauseBlink { composer.blink() }
            f.move.y += talk.hop
        } else if talk.act != 0 || talk.hop != 0 { talk.reset() }
    }
}

/// one face measurement: blendshape scores by their ARKit / MediaPipe name, and the head's 4x4 transform (column major,
/// translation in centimetres), as the camera sees it
public struct FaceSample: Sendable {
    public var blendshapes: [String: Double]
    public var matrix: [Double]?
    public init(blendshapes: [String: Double], matrix: [Double]?) { self.blendshapes = blendshapes; self.matrix = matrix }
}

/// a face as the character's params (runtime/tracking.ts FaceTracker.read / apply), for any source of blendshapes
public final class FaceMapper {
    public var mirror = true
    public var follow = 0.0
    public var mouthGain = 1.0, exprGain = 1.0
    public enum BlinkSync { case turn, always, off }
    public var blinkSync = BlinkSync.turn
    public static let lostAfter = 0.5
    private typealias Pose = (x: Double, y: Double, z: Double, px: Double, py: Double, pz: Double, bl: Double, br: Double)
    private var zero: Pose = (0, 0, 0, 0, 0, 0, 0, 0)
    private var raw = (x: 0.0, y: 0.0, z: 0.0)
    public private(set) var pos = (x: 0.0, y: 0.0, z: 0.0)
    private var calibrated = false, posKnown = false
    private var recent: [Pose] = []
    private var seenAt = -1.0
    public private(set) var lostFor = Double.infinity
    private var target: ParamOffsets = [:]
    private let fx = OneEuro(minCutoff: 0.5, beta: 0.05), fy = OneEuro(minCutoff: 0.5, beta: 0.05), fz = OneEuro(minCutoff: 0.5, beta: 0.05)
    private let fgx = OneEuro(minCutoff: 1.5, beta: 0.5), fgy = OneEuro(minCutoff: 1.5, beta: 0.5), fbrow = OneEuro(minCutoff: 1, beta: 0.5)
    private let fpx = OneEuro(minCutoff: 0.6, beta: 0.08), fpy = OneEuro(minCutoff: 0.6, beta: 0.08), fpz = OneEuro(minCutoff: 0.6, beta: 0.08)
    public init() {}

    public func setSmoothing(_ s: Double) {
        let c = s <= 0.5 ? 0.5 * pow(6, 1 - 2 * s) : 0.5 / pow(10.0 / 3, 2 * s - 1)
        for f in [fx, fy, fz] { f.minCutoff = c; f.beta = 0.05 * pow(4, 1 - 2 * s) }
    }

    /// takes the last still frames as the front
    public func calibrate() { let r = Array(recent.suffix(10)); if !r.isEmpty { setZero(r) } }

    /// a measurement at `now` seconds
    public func read(_ s: FaceSample, now: Double) {
        let dt = seenAt < 0 ? 0 : now - seenAt
        if dt == 0 || dt > Self.lostAfter { for f in [fx, fy, fz, fgx, fgy, fbrow, fpx, fpy, fpz] { f.reset() } }
        seenAt = now
        func g(_ n: String) -> Double { s.blendshapes[n] ?? 0 }
        if let m = s.matrix, m.count == 16 {
            let r00 = m[0], r10 = m[1], r20 = m[2], r21 = m[6], r22 = m[10]
            let yaw = atan2(-r20, hypot(r21, r22)), pitch = atan2(r21, r22), roll = atan2(r10, r00)
            let sg = mirror ? -1.0 : 1.0
            let deg = 180 / Double.pi
            raw = (sg * yaw * deg * 1.3, -pitch * deg * 1.3 - 4, sg * roll * deg)
            let px = sg * m[12], py = m[13], pz = m[14]
            recent.append((raw.x, raw.y, raw.z, px, py, pz, g("eyeBlinkLeft"), g("eyeBlinkRight")))
            if recent.count > 30 { recent.removeFirst() }
            if (!calibrated || !posKnown) && recent.count >= 20 {
                let r = Array(recent.suffix(20))
                func sd(_ xs: [Double]) -> Double { let mm = xs.reduce(0, +) / Double(xs.count); return (xs.reduce(0) { $0 + ($1 - mm) * ($1 - mm) } / Double(xs.count)).squareRoot() }
                if sd(r.map(\.x)) < 1.5 && sd(r.map(\.y)) < 1.5 {
                    if calibrated { let z = zero; setZero(r); zero.x = z.x; zero.y = z.y; zero.z = z.z; zero.bl = z.bl; zero.br = z.br }
                    else { setZero(r) }
                }
            }
            if posKnown { pos = (fpx.filter(px, dt) - zero.px, fpy.filter(py, dt) - zero.py, fpz.filter(pz, dt) - zero.pz) }
            let x = fx.filter(raw.x, dt) - zero.x
            target[.angleX] = clamp(x, -30, 30)
            target[.angleY] = clamp(fy.filter(raw.y, dt) - zero.y, -30, 30)
            target[.angleZ] = clamp(zero.z - fz.filter(raw.z, dt), -30, 30)
            target[.bodyX] = clamp(x * 0.2 + pos.x * 0.25 * follow, -10, 10)
        }
        if !s.blendshapes.isEmpty {
            func eye(_ blink: Double, _ rest: Double) -> Double {
                let open = clamp(rest + 0.06, 0.15, 0.5), shut = min(0.95, max(0.65, open + 0.4))
                return clamp(1 - (blink - open) / (shut - open), 0, 1)
            }
            let uL = eye(g("eyeBlinkLeft"), zero.bl), uR = eye(g("eyeBlinkRight"), zero.br)
            var l = mirror ? uR : uL, r = mirror ? uL : uR
            let turned = smooth(9, 15, abs(raw.x - zero.x))
            let k = blinkSync == .always ? 1 : blinkSync == .turn ? turned : 0
            if k > 0 {
                let avg = (l + r) / 2, both = avg + (max(l, r) - avg) * (blinkSync == .always ? turned : 1)
                l += (both - l) * k; r += (both - r) * k
            }
            target[.eyeLOpen] = l; target[.eyeROpen] = r
            target[.mouthOpen] = clamp(max((g("jawOpen") - 0.04) * 2.2, 0) * mouthGain, 0, 1)
            let lookLeft = (g("eyeLookOutLeft") + g("eyeLookInRight")) / 2
            let lookRight = (g("eyeLookInLeft") + g("eyeLookOutRight")) / 2
            let up = (g("eyeLookUpLeft") + g("eyeLookUpRight")) / 2, down = (g("eyeLookDownLeft") + g("eyeLookDownRight")) / 2
            target[.eyeBallX] = clamp(fgx.filter((lookRight - lookLeft) * 2.2 * (mirror ? 1 : -1), dt), -1, 1)
            target[.eyeBallY] = clamp(fgy.filter((up - down) * 2.2, dt), -1, 1)
            let browUp = g("browInnerUp") * 0.6 + (g("browOuterUpLeft") + g("browOuterUpRight")) * 0.2
            let browDown = (g("browDownLeft") + g("browDownRight")) / 2
            let brow = clamp(fbrow.filter((browUp - browDown * 0.8) * 2.4, dt), -1, 1)
            target[.browLY] = brow; target[.browRY] = brow
            target[.smile] = clamp(((g("mouthSmileLeft") + g("mouthSmileRight")) / 2 - 0.35 / exprGain) * 2.5 * exprGain, 0, 1)
        }
    }

    /// once per frame: how long since a face was seen
    public func poll(now: Double) -> Bool {
        lostFor = seenAt < 0 ? .infinity : now - seenAt
        return lostFor < Self.lostAfter
    }

    private func setZero(_ r: [Pose]) {
        func med(_ xs: [Double]) -> Double { let s = xs.sorted(); return s[s.count >> 1] }
        zero = (med(r.map(\.x)), med(r.map(\.y)), med(r.map(\.z)), med(r.map(\.px)), med(r.map(\.py)), med(r.map(\.pz)),
                clamp(med(r.map(\.bl)), 0, 0.5), clamp(med(r.map(\.br)), 0, 0.5))
        calibrated = true; posKnown = true
        fpx.reset(); fpy.reset(); fpz.reset()
    }

    /// eases `P` toward the face (a closing eye follows at once)
    public func apply(_ P: inout Params, _ dt: Double) {
        let a = min(1, dt * 30), fast = min(1, dt * 25)
        for (k, v) in target {
            let closing = (k == .eyeLOpen || k == .eyeROpen) && v < P[k]
            let rate = closing ? 1 : (k.rawValue.hasPrefix("eye") || k == .mouthOpen) ? fast : k == .smile ? min(1, dt * 8.4) : a
            P[k] += (v - P[k]) * rate
        }
    }
    public var targetKeys: [ParamKey] { Array(target.keys) }
}

/// the face tracker as a driver: while no face is seen the character eases back to its idle motion
public final class FaceDriver: PoseDriver {
    public let order = -10
    public let mapper: FaceMapper
    private var pose = Params()
    private var w = 0.0
    private let now: () -> Double
    public init(mapper: FaceMapper, now: @escaping () -> Double) { self.mapper = mapper; self.now = now }
    public func update(_ f: FrameContext, _ composer: PoseComposer) {
        let seen = mapper.poll(now: now())
        mapper.apply(&pose, f.dt)
        w = max(0, min(1, w + (seen ? f.dt / 0.3 : -f.dt / 0.5)))
        f.tracked = true
        let k = w * w * (3 - 2 * w)
        if k == 0 { return }
        for key in mapper.targetKeys { f.params[key] += (pose[key] - f.params[key]) * k }
        // tilting your head tilts the character's head, not its torso (the rig would lean the upper body by
        // bodyRollShare of it, up to 9 degrees at a full tilt, round a pivot below the hips)
        if composer.bodyRollShare != 0 {
            f.params.bodyZ = clamp(f.params.bodyZ - f.params.angleZ * composer.bodyRollShare, -10, 10)
        }
        let d = mapper.pos, fl = mapper.follow
        f.move.x += clamp(d.x * 0.006 * fl * k, -0.15, 0.15)
        f.move.y += clamp(d.y * 0.006 * fl * k, -0.15, 0.15)
        f.move.s *= 1 + clamp(d.z * 0.012 * fl * k, -0.15, 0.2)
    }
}
