// The idle motion the players play when nothing else drives the character (runtime/idle.ts LivelyIdle with IDLE_STYLE,
// follow.ts Idle): smooth value-noise wander through damped springs, uneven breaths, double blinks, idle moves every
// 10-20 s, and the 'attend' pointer style (the eyes lead, the head turns a little, the face reacts).
import Foundation

private func knee(_ v: Double, _ k: Double, _ cap: Double) -> Double {
    let a = abs(v)
    return a <= k ? v : (v < 0 ? -1 : 1) * (k + (cap - k) * tanh((a - k) / (cap - k)))
}
private func env(_ s: Double, _ a: Double, _ h: Double, _ d: Double) -> Double {
    s < 0 || s > a + h + d ? 0 : s < a ? smooth(0, a, s) : 1 - smooth(a + h, a + h + d, s)
}
private func noise(_ t: Double, _ seed: Double) -> Double {
    func hh(_ n: Double) -> Double { let x = sin(n * 127.1 + seed * 311.7) * 43758.5453; return x - x.rounded(.down) }
    let i = t.rounded(.down), f = t - i, u = f * f * (3 - 2 * f)
    return (hh(i) * (1 - u) + hh(i + 1) * u) * 2 - 1
}
private func fbm(_ t: Double, _ seed: Double) -> Double { noise(t, seed) * 0.7 + noise(t * 2.3, seed + 17) * 0.3 }

typealias Track = [(Double, Double)]
private func sample(_ k: Track, _ t: Double) -> Double {
    if t <= k[0].0 { return k[0].1 }
    let n = k.count - 1
    if t >= k[n].0 { return k[n].1 }
    var i = 0
    while t > k[i + 1].0 { i += 1 }
    func slope(_ j: Int) -> Double { j <= 0 || j >= n ? 0 : (k[j + 1].1 - k[j - 1].1) / (k[j + 1].0 - k[j - 1].0) }
    let h = k[i + 1].0 - k[i].0, u = (t - k[i].0) / h, u2 = u * u, u3 = u2 * u
    return (2 * u3 - 3 * u2 + 1) * k[i].1 + (u3 - 2 * u2 + u) * slope(i) * h + (-2 * u3 + 3 * u2) * k[i + 1].1 + (u3 - u2) * slope(i + 1) * h
}

enum MoveTrack: String { case angleX, angleY, angleZ, bodyX, bodyZ, eyeBallX, eyeBallY, eye, brow, breath }
struct IdleMove { let dur: Double; let tracks: [MoveTrack: Track] }

let idleMoves: [String: IdleMove] = [
    "glance": IdleMove(dur: 4.0, tracks: [
        .eyeBallX: [(0, 0), (0.15, 0.8), (2.5, 0.75), (2.8, 0)], .eyeBallY: [(0, 0), (0.15, 0.25), (2.5, 0.2), (2.8, 0)],
        .angleX: [(0, 0), (0.6, 11), (2.5, 10), (3.4, 0)], .angleY: [(0, 0), (0.6, 4), (2.5, 3), (3.4, 0)], .angleZ: [(0, 0), (0.7, -4), (2.5, -3), (3.4, 0)],
        .bodyX: [(0, 0), (1.0, 2), (2.6, 1.5), (3.8, 0)], .brow: [(0, 0), (0.4, 0.25), (2.5, 0.2), (3.2, 0)],
        .breath: [(0, 0.1), (0.6, 0.7), (2.6, 0.6), (3.6, 0), (4.0, 0.15)]]),
    "lookAround": IdleMove(dur: 5.0, tracks: [
        .eyeBallX: [(0, 0), (0.2, -0.8), (1.4, -0.75), (1.7, 0.1), (2.0, 0.8), (3.2, 0.75), (3.5, 0)],
        .angleX: [(0, 0), (0.7, -15), (1.5, -14), (2.4, 15), (3.3, 14), (4.2, 0)], .angleY: [(0, 0), (0.8, 3), (2.4, 3), (4.2, 0)],
        .angleZ: [(0, 0), (0.8, 3), (1.7, 0), (2.5, -3), (4.2, 0)], .bodyX: [(0, 0), (1.0, -3), (2.7, 3), (4.4, 0)],
        .brow: [(0, 0), (0.5, 0.3), (3.4, 0.25), (4.2, 0)], .breath: [(0, 0.2), (0.6, 0.8), (3.4, 0.7), (4.4, 0), (5.0, 0.1)]]),
    "sway": IdleMove(dur: 6.0, tracks: [
        .bodyZ: [(0, 0), (1.5, 3.5), (3.0, -3.5), (4.5, 3), (6.0, 0)], .bodyX: [(0, 0), (1.5, 2), (3.0, -2), (4.5, 1.5), (6.0, 0)],
        .angleZ: [(0, 0), (1.6, -7), (3.1, 7), (4.6, -6), (6.0, 0)], .angleX: [(0, 0), (1.6, 4), (3.1, -4), (4.6, 3), (6.0, 0)],
        .eyeBallX: [(0, 0), (1.6, -0.25), (3.1, 0.25), (4.6, -0.2), (6.0, 0)], .eye: [(0, 1), (0.8, 0.88), (5.2, 0.88), (6.0, 1)],
        .breath: [(0, 0), (0.75, 1), (1.5, 0), (2.25, 1), (3.0, 0), (3.75, 1), (4.5, 0), (5.25, 0.8), (6.0, 0)]]),
    "think": IdleMove(dur: 4.4, tracks: [
        .eyeBallX: [(0, 0), (0.3, -0.6), (3.4, -0.55), (3.8, 0)], .eyeBallY: [(0, 0), (0.3, 0.6), (3.4, 0.55), (3.8, 0)],
        .angleX: [(0, 0), (0.8, -9), (3.4, -8), (4.2, 0)], .angleY: [(0, 0), (0.8, 6), (3.4, 5), (4.2, 0)], .angleZ: [(0, 0), (0.9, 6), (3.4, 5), (4.2, 0)],
        .brow: [(0, 0), (0.6, 0.35), (3.4, 0.3), (4.2, 0)], .eye: [(0, 1), (0.6, 0.92), (3.4, 0.92), (4.0, 1)]]),
    "lookDown": IdleMove(dur: 2.4, tracks: [
        .eyeBallY: [(0, 0), (0.2, -0.85), (1.4, -0.8), (1.65, 0)], .eyeBallX: [(0, 0), (0.2, -0.1), (1.4, -0.1), (1.65, 0)],
        .angleY: [(0, 0), (0.45, -8), (1.4, -7), (1.9, 1), (2.4, 0)], .angleZ: [(0, 0), (0.5, 2), (1.5, 2), (2.4, 0)],
        .eye: [(0, 1), (0.3, 0.8), (1.4, 0.8), (1.65, 1)]]),
]
private let moveOrder = ["glance", "lookAround", "sway", "think", "lookDown"]

private enum SK: Int, CaseIterable { case angleX, angleY, angleZ, bodyX, bodyZ }
private let springK: [SK: (Double, Double)] = [.angleX: (55, 0.72), .angleY: (55, 0.72), .angleZ: (45, 0.75), .bodyX: (14, 0.9), .bodyZ: (12, 0.9)]

public struct IdleStyle: Sendable {
    public var wander = 1.0, look = 1.0, moves = 1.0, bodyTurn = 0.0, bodyTilt = 0.0
    public var attend = true
    public var smile = 0.4
    public init() {}
}

private enum Attend {
    static let yaw = 9.0, yawKnee = 10.0, yawCap = 13.0
    static let pitch = 5.0, pitchKnee = 6.0, pitchCap = 10.0
    static let roll = 2.0, rollKnee = 8.0, rollCap = 12.0, lean = 0.0, bodyTurn = 1.5
    static let eyeX = 1.0, eyeY = 0.8, eyeXCap = 0.78, eyeYCap = 0.55, eyeKnee = 0.7
    static let hold = 2.2
}

public final class LivelyIdle {
    public var nextBlink = 2.0
    var blinkT = -1.0, blinkAt = -99.0
    public var look = (x: 0.0, y: 0.0)
    public var blinkRate = 1.0
    var nextSaccade = 1.0
    var gaze = (x: 0.0, y: 0.0)
    public var busy = false
    public var moves = 1.0
    public var style = IdleStyle()
    public var shown = (x: 0.0, z: 0.0)
    public var pointer = (x: 0.0, y: 0.0, d: 99.0, on: false, keep: false)
    public var tracked = false
    public var faceFree = true
    private var smiling = false
    private struct Att {
        var px = 0.0, py = 0.0, on = false, moved = -99.0, speed = 0.0, engaged = false, since = 0.0, x = 0.0, y = 0.0
        var slow = (x: 0.0, y: 0.0), soft = 0.0, side = 1.0, notice = -99.0, back = -99.0, smile = -99.0, smiled = -99.0
        var jitter = (x: 0.0, y: 0.0)
    }
    private var att = Att()
    private var fol = (x: 0.0, z: 0.0, x2: 0.0, z2: 0.0)
    var move: (id: String, t: Double, side: Double, fade: Double)?
    var nextMove = 6.0
    var last = ""
    private var s: [SK: (x: Double, v: Double)] = Dictionary(uniqueKeysWithValues: SK.allCases.map { ($0, (0.0, 0.0)) })
    private var aim: [SK: Double]?
    private var breathPhase = 0.0, breathPeriod = 3.8
    private var double = false
    private var rng: SplitMix
    private let seed: Double

    public init(seed: UInt64 = UInt64.random(in: 0...UInt64.max)) {
        rng = SplitMix(seed: seed)
        var r = SplitMix(seed: seed ^ 0xABCDEF)
        self.seed = r.unit() * 100
    }
    private func random() -> Double { rng.unit() }

    private func breath(_ dt: Double) -> Double {
        breathPhase += dt / breathPeriod
        if breathPhase >= 1 { breathPhase -= 1; breathPeriod = 3.2 + random() * 1.4 }
        let x = breathPhase
        return x < 0.4 ? smooth(0, 0.4, x) : x < 0.88 ? 1 - smooth(0.4, 0.88, x) : 0
    }

    public func apply(_ P: inout Params, _ t: Double, _ dtIn: Double) {
        let dt = dtIn > 0 ? min(dtIn, 0.1) : 0
        let st = style
        let A = st.attend && !tracked
        if A { attend(t, dt) }
        let quiet = busy || (A && att.engaged)
        if var m = move {
            m.t += dt
            if quiet { m.fade = max(0, m.fade - dt / 0.4) }
            move = m.t >= idleMoves[m.id]!.dur || m.fade <= 0 ? nil : m
        } else if quiet { nextMove = max(nextMove, t + 3) }
        else if moves > 0 && t > nextMove {
            let ids = moveOrder.filter { $0 != last }
            let id = ids[min(ids.count - 1, Int(random() * Double(ids.count)))]
            move = (id, 0, random() < 0.5 ? -1 : 1, 1)
            last = id
            nextMove = t + idleMoves[id]!.dur + 10 + random() * 10
        }
        let M = move.map { idleMoves[$0.id]! }
        let w = move.map { m in m.fade * smooth(0, 0.15, m.t) * (1 - smooth(M!.dur - 0.25, M!.dur, m.t)) } ?? 0
        func mv(_ k: MoveTrack, _ rest: Double = 0) -> Double {
            guard let m = move, let tr = M?.tracks[k] else { return rest }
            let v = sample(tr, m.t)
            let mirrored = [.angleX, .angleZ, .bodyX, .bodyZ, .eyeBallX].contains(k) ? m.side : 1
            let body = k.rawValue.hasPrefix("angle") || k.rawValue.hasPrefix("body")
            return rest + (v * mirrored - rest) * w * moves * (body ? st.moves : 1)
        }
        var open = 1.0
        if blinkT < 0 && t > nextBlink { blinkT = 0; blinkAt = t }
        if blinkT >= 0 {
            blinkT += dt
            let b = blinkT / 0.075
            open = clamp(b < 1 ? 1 - b : b < 2.6 ? (b - 1) / 1.6 : 1, 0, 1)
            if b >= 2.6 {
                blinkT = -1
                if !double && random() < 0.18 { double = true; nextBlink = t + 0.08 }
                else { double = false; nextBlink = t + (1.8 + random() * 3.8) / max(0.2, blinkRate) }
            }
        }
        let eye = clamp(mv(.eye, 1), 0, 1) * open
        P.eyeLOpen = A ? eye * (1 - 0.16 * att.soft) : eye
        P.eyeROpen = P.eyeLOpen
        let sd = seed, L = look, lk = st.look, wd = st.wander
        var gx: Double, gy: Double
        var target: [SK: Double]
        if A {
            if t > nextSaccade {
                att.jitter = ((random() - 0.5) * 0.2, (random() - 0.5) * 0.16)
                nextSaccade = t + 0.6 + random() * 1.6
            }
            gaze = (Attend.eyeX * att.x + att.jitter.x, Attend.eyeY * att.y + att.jitter.y)
            let ex = gaze.x + mv(.eyeBallX), ey = gaze.y + mv(.eyeBallY), e = hypot(ex / Attend.eyeXCap, ey / Attend.eyeYCap)
            let k = e > Attend.eyeKnee ? knee(e, Attend.eyeKnee, 1) / e : 1
            gx = ex * k; gy = ey * k
            if hypot(gx - att.slow.x, gy - att.slow.y) > 0.5 {
                if blinkT < 0 && t - blinkAt > 1.2 { nextBlink = min(nextBlink, t) }
                att.slow = (gx, gy)
            }
            att.slow.x += (gx - att.slow.x) * min(1, dt / 0.35); att.slow.y += (gy - att.slow.y) * min(1, dt / 0.35)
            let nod = moves > 0 ? 3 * env(t - att.notice, 0.12, 0.15, 0.5) - 2.5 * env(t - att.back, 0.15, 0.1, 0.45) : 0
            target = [
                .angleX: knee(att.x * Attend.yaw * lk + fbm(t * 0.17, sd) * 4 * wd + gaze.x * 2 + mv(.angleX), Attend.yawKnee, Attend.yawCap),
                .angleY: knee(att.y * Attend.pitch * lk + fbm(t * 0.13, sd + 1) * 3 * wd + gaze.y * 2 + nod + mv(.angleY), Attend.pitchKnee, Attend.pitchCap),
                .angleZ: knee(att.x * Attend.roll * lk + att.side * 3 * att.soft + fbm(t * 0.11, sd + 2) * 5 * wd + mv(.angleZ), Attend.rollKnee, Attend.rollCap),
                .bodyX: att.x * Attend.bodyTurn * lk + fbm(t * 0.09, sd + 3) * 3 * wd + mv(.bodyX),
                .bodyZ: att.x * Attend.lean * lk + fbm(t * 0.08, sd + 4) * 2.5 * wd + mv(.bodyZ),
            ]
        } else {
            if t > nextSaccade {
                gaze = (look.x + (random() - 0.5) * 0.25, look.y * 0.8 + (random() - 0.5) * 0.2)
                nextSaccade = t + 0.6 + random() * 1.6
            }
            gx = clamp(gaze.x * 1.2 + mv(.eyeBallX), -1, 1); gy = clamp(gaze.y + mv(.eyeBallY), -1, 1)
            target = [
                .angleX: L.x * 20 * lk + fbm(t * 0.17, sd) * 7 * wd + gaze.x * 5 + mv(.angleX),
                .angleY: L.y * 13 * lk + fbm(t * 0.13, sd + 1) * 4 * wd + gaze.y * 3 + mv(.angleY),
                .angleZ: -L.x * 4 * lk + fbm(t * 0.11, sd + 2) * 6 * wd + mv(.angleZ),
                .bodyX: L.x * 4 * lk + fbm(t * 0.09, sd + 3) * 3 * wd + mv(.bodyX),
                .bodyZ: fbm(t * 0.08, sd + 4) * 2.5 * wd + mv(.bodyZ),
            ]
        }
        P.eyeBallX += (gx - P.eyeBallX) * min(1, dt * 18)
        P.eyeBallY += (gy - P.eyeBallY) * min(1, dt * 18)
        let n = max(1, Int((dt / (1.0 / 120)).rounded(.up)))
        if aim == nil { aim = target }
        for k in SK.allCases {
            let (K, z) = springK[k]!, c = 2 * K.squareRoot() * z
            var sp = s[k]!
            for _ in 0..<n {
                aim![k]! += (target[k]! - aim![k]!) * min(1, dt / Double(n) / 0.12)
                sp.v += (K * (aim![k]! - sp.x) - c * sp.v) * (dt / Double(n)); sp.x += sp.v * (dt / Double(n))
            }
            s[k] = sp
            switch k {
            case .angleX: P.angleX = sp.x
            case .angleY: P.angleY = sp.x
            case .angleZ: P.angleZ = sp.x
            case .bodyX: P.bodyX = sp.x
            case .bodyZ: P.bodyZ = sp.x
            }
        }
        let a = min(1, dt / 0.12)
        fol.x += (st.bodyTurn * shown.x - fol.x) * a; fol.x2 += (fol.x - fol.x2) * a
        fol.z += (st.bodyTilt * shown.z - fol.z) * a; fol.z2 += (fol.z - fol.z2) * a
        if st.bodyTurn != 0 || st.bodyTilt != 0 { P.bodyX = clamp(P.bodyX + fol.x2, -10, 10); P.bodyZ = clamp(P.bodyZ + fol.z2, -10, 10) }
        P.breath = clamp(mv(.breath, breath(dt)), 0, 1)
        let bt = (A ? attendBrow(t) : L.y > 0.4 ? 0.5 : 0) - (1 - open) * 0.15 + mv(.brow)
        P.browLY += (bt - P.browLY) * min(1, dt * 10); P.browRY = P.browLY
        if A { P.smile = t >= att.smile && t < att.smile + 1.6 ? 1 : 0; smiling = P.smile > 0 }
        else if smiling { P.smile = 0; smiling = false }
    }

    private func attend(_ t: Double, _ dt: Double) {
        let q = pointer
        if q.on && !att.on { att.notice = t; att.moved = t; att.px = q.x; att.py = q.y; att.side = random() < 0.5 ? -1 : 1 }
        if q.on {
            let step = hypot(q.x - att.px, q.y - att.py)
            att.speed += (step / max(dt, 1e-3) - att.speed) * min(1, dt / 0.15)
            if step > 0.003 { att.moved = t }
            att.px = q.x; att.py = q.y
        } else { att.speed *= max(0, 1 - dt / 0.15) }
        att.on = q.on
        let onFace = q.on && q.d < 1
        let engaged = q.on && (onFace || q.keep || t - att.moved < Attend.hold)
        if engaged != att.engaged {
            if !engaged && t - att.since > 0.8 { att.back = t; nextMove = max(nextMove, t + 6) }
            att.since = t; att.engaged = engaged
        }
        let sm = style.smile
        if onFace && t - att.moved > 1.2 && sm > 0 && faceFree && !busy && t - att.smiled > 25 && t > att.smile + 1.6 {
            if att.smiled < 0 || random() < sm { att.smile = t }
            att.smiled = t
        }
        let smilingNow = t >= att.smile && t < att.smile + 1.6
        let soft = smilingNow ? 0 : max(onFace && t - att.moved > 0.5 ? 1 : 0, env(t - att.back, 0.2, 0.6, 0.6))
        att.soft += (soft - att.soft) * min(1, dt / 0.25)
        att.x = engaged ? q.x : 0; att.y = engaged ? q.y : 0
    }

    private func attendBrow(_ t: Double) -> Double {
        let q = pointer
        let near = q.on && t - att.moved < 0.3 ? 1 - smooth(1, 2.2, q.d) : 0
        return min(0.7, 0.4 * smooth(0.35, 0.9, att.y) + 0.3 * smooth(1.5, 5, att.speed) + 0.15 * near
            + 0.45 * env(t - att.notice, 0.08, 0.25, 0.35) + 0.2 * env(t - att.back, 0.15, 0.3, 0.5) + 0.12 * att.soft)
    }
}

/// where the head is drawn in the view, in shares of it (0..1 from the top-left): what the pointer follow measures from
public struct HeadOnView: Sendable {
    public var x: Double, y: Double, rx: Double, ry: Double
    public init(x: Double, y: Double, rx: Double, ry: Double) { self.x = x; self.y = y; self.rx = rx; self.ry = ry }
}

/// what both players hand the idle motion each frame (follow.ts Idle)
public final class IdleController {
    public let lv: LivelyIdle
    private var P = Params()
    private var turn = (x: 0.0, y: 0.0)
    private var held = false
    static let keys: [ParamKey] = [.angleX, .angleY, .angleZ, .eyeLOpen, .eyeROpen, .eyeBallX, .eyeBallY, .browLY, .browRY, .bodyX, .bodyZ, .breath]

    public init(seed: UInt64 = UInt64.random(in: 0...UInt64.max)) { lv = LivelyIdle(seed: seed) }

    public func apply(_ out: inout Params, _ t: Double, _ dt: Double, busy: Bool, tracked: Bool, faceFree: Bool) {
        lv.busy = busy; lv.tracked = tracked; lv.faceFree = faceFree
        lv.look = turn
        lv.apply(&P, t, dt)
        for k in Self.keys { out[k] = P[k] }
        out.smile = max(out.smile, P.smile)
    }

    public func shown(_ P: Params) { lv.shown = (P.angleX, P.angleZ) }

    /// the pointer at (u, v), shares of the view from its top-left; `head`: where the face is drawn
    public func pointer(u: Double, v: Double, head: HeadOnView, on: Bool) {
        if held { return }
        lv.pointer = (clamp((u - head.x) * 2, -1, 1), clamp(-(v - head.y) * 1.6, -1, 1), hypot((u - head.x) / head.rx, (v - head.y) / head.ry), on, lv.pointer.keep)
        if on { turn = (clamp((u - 0.5) * 2, -1, 1), clamp(-(v - 0.3) * 1.6, -1, 1)) }
    }

    public func leave() { if !held { lv.pointer.on = false }; turn = (0, 0) }

    /// looks toward (x, y), each -1..1 from the view's center (y up); nil goes back to following the pointer
    public func lookAt(_ x: Double?, _ y: Double, head: HeadOnView) {
        held = false
        guard let x else { lv.pointer.on = false; lv.pointer.keep = false; turn = (0, 0); return }
        pointer(u: (x + 1) / 2, v: (1 - y) / 2, head: head, on: true)
        lv.pointer.keep = true
        held = true
        turn = (x, y)
    }

    public func blink(_ t: Double) { lv.nextBlink = min(lv.nextBlink, t) }
}
