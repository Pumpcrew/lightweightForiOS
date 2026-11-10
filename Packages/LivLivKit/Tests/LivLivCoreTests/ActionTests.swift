import XCTest
@testable import LivLivCore

extension LivLivCoreTests {
    /// a tracked head tilt tilts the character's head on its neck; the torso stays upright
    func testTrackedTiltLeavesTheBodyStill() throws {
        let m = try model("k01")
        let p = Puppet()
        try p.load(m, images: images(for: m))
        func run(_ cancel: Bool) -> (Double, Double) {
            p.resetPhysics()
            let c = PoseComposer(seed: 1)
            c.idle = false
            if cancel { c.bodyRollShare = m.rig.body.roll * m.tuning.turn }
            let mapper = FaceMapper()
            var now = 0.0
            let d = FaceDriver(mapper: mapper, now: { now })
            c.add(d)
            // the head tilted 20 degrees about the camera's axis
            let a = 20 * Double.pi / 180
            let M = [cos(a), sin(a), 0, 0, -sin(a), cos(a), 0, 0, 0, 0, 1, 0, 0, 0, -40, 1]
            var bodyMove = 0.0, faceMove = 0.0
            for _ in 0..<120 {
                now += 1.0 / 60
                mapper.read(FaceSample(blendshapes: ["jawOpen": 0], matrix: M), now: now)
                let pose = c.compose(1.0 / 60)
                p.params = pose.params
                p.update(1.0 / 60)
                func mean(_ id: String) -> Double {
                    let L = p.layers.first { $0.def.id == id }!
                    return zip(L.out, L.rest).reduce(0) { $0 + abs(Double($1.0 - $1.1)) } / Double(L.rest.count)
                }
                bodyMove = max(bodyMove, mean("body")); faceMove = max(faceMove, mean("face"))
            }
            return (bodyMove, faceMove)
        }
        let before = run(false), after = run(true)
        print(String(format: "TRACK tilt: body %.1f -> %.1f px, face %.1f -> %.1f px", before.0, after.0, before.1, after.1))
        XCTAssertGreaterThan(before.0, 10, "without the fix the torso leans")
        XCTAssertLessThan(after.0, 3, "the torso stays upright")
        XCTAssertGreaterThan(after.1, 10, "the head still tilts")
    }

    /// each action button does what it says on a half-body LivLiv model
    func testActionsMatchTheirButtons() throws {
        let m = try model("k01")
        let p = Puppet()
        try p.load(m, images: images(for: m))
        let canvasH = 1440.0
        for id in ActionID.allCases {
            let a = ActionPlayer()
            a.bodyRollShare = m.rig.body.roll * m.tuning.turn
            a.bodyYawShare = m.rig.body.yaw * m.tuning.turn
            a.halfBody = p.cutBottom
            var sMax = 1.0, shy = 0.0
            p.resetPhysics()
            a.play(id)
            var bodyMax = 0.0, faceMax = 0.0, yMin = 0.0, yMax = 0.0, faceDy = 0.0, faceDx = 0.0
            for _ in 0..<160 {
                var P = Params()
                for (k, v) in a.update(1.0 / 60) { P[k] += v }
                p.params = P; p.move = (0, a.y, a.s); sMax = max(sMax, a.s); shy = max(shy, a.expr["shy"] ?? 0)
                p.update(1.0 / 60)
                let f = p.frame(width: 1080, height: canvasH)
                let body = p.layers.first { $0.def.id == "body" }!, face = p.layers.first { $0.def.id == "face" }!
                func mean(_ L: PuppetLayer) -> (Double, Double, Double) {
                    var s = 0.0, dx = 0.0, dy = 0.0
                    for i in stride(from: 0, to: L.rest.count, by: 2) {
                        let x = Double(L.out[i] - L.rest[i]), y = Double(L.out[i+1] - L.rest[i+1])
                        s += hypot(x, y); dx += x; dy += y
                    }
                    let n = Double(L.rest.count / 2); return (s / n, dx / n, dy / n)
                }
                let b = mean(body), fc = mean(face)
                bodyMax = max(bodyMax, b.0); if fc.0 > faceMax { faceMax = fc.0; faceDx = fc.1; faceDy = fc.2 }
                // where the picture's bottom sits on screen (clip y of model bottom; -1 is the screen's bottom edge)
                let screenY = -(Float(m.canvas.h) * f.sy + f.oy)
                yMin = min(yMin, Double(screenY) + 1); yMax = max(yMax, Double(screenY) + 1)
            }
            switch id {
            case .nod: XCTAssertGreaterThan(faceDy, 9, "nod: the head goes down"); XCTAssertLessThan(bodyMax, 2)
            case .shake: XCTAssertGreaterThan(abs(faceDx), 12, "shake: the head turns"); XCTAssertLessThan(bodyMax, 2)
            case .tilt: XCTAssertGreaterThan(abs(faceDx), 20, "tilt: the head tilts"); XCTAssertLessThan(bodyMax, 3)
            case .hop: XCTAssertGreaterThan(sMax, 1.03, "hop: a half-body character springs toward the viewer"); XCTAssertGreaterThanOrEqual(yMin, -0.06)
            case .shy: XCTAssertGreaterThan(shy, 0.9, "shy: the shy face shows")
            }
            print(String(format: "ACT %@: body %.1f px, face %.1f px (dx %.1f dy %.1f), picture moved %.3f..%.3f, scale up to %.3f, shy face %.2f", id.rawValue, bodyMax, faceMax, faceDx, faceDy, yMin, yMax, sMax, shy))
        }
    }
}
