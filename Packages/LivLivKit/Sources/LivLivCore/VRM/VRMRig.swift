// A VRM in motion, without the GPU: the shared params as its pose (vrm.ts VrmBody.render: head and neck turn and tilt,
// spine sways, eyes blink and look, the mouth takes the visemes, the face its expressions), the humanoid applied as
// three-vrm's normalized bones are, spring bones (hair, clothes) with their colliders, then morph targets and skinning on
// the CPU. Each frame it leaves every drawn primitive's vertices in `positions`, in the glTF scene's space; a renderer
// (LivLivKit's RealityKit view) only uploads them.
import Foundation

public struct VRMDrawable {
    public let mesh: Int
    public let primitive: Int
    public let node: Int
    public let material: Int?
    public let indices: [UInt32]
    public let uvs: [SIMD2<Float>]
    public internal(set) var positions: [V3]
}

public final class VRMRig {
    public let doc: GLTFDocument
    public let info: VRMInfo
    public let name: String
    /// the expressions an app can show (vrm.ts: the feelings the file has, happy first, then its own)
    public private(set) var expressions: [(id: String, label: String)] = []
    public private(set) var drawables: [VRMDrawable] = []
    /// VRM 0.x faces -Z: shown turned half round (rotateVRM0), and its X / Z rotations mirrored
    public var flip: Float { info.spec == "0" ? -1 : 1 }
    /// what the view frames: the head's top to the hips (model units), its centre height, and the width to keep in view
    public private(set) var frame = (height: Float(1), y: Float(1), width: Float(0.6))

    private var restT: [V3], restR: [Quat], restS: [V3]
    private var localR: [Quat]
    private var world: [Mat4]
    private let order: [Int]
    private var restWorldR: [Quat] = []
    private var parentRestWorldR: [Quat] = []
    private var morphWeights: [[Float]]
    private var has: Set<String> = []
    private var blinkBoth = false

    private struct JointState {
        var spec: VRMSpringJoint
        var boneAxis: V3
        var length: Float
        var currentTail: V3
        var prevTail: V3
        var initialLocalR: Quat
        var colliders: [Int]
    }
    private var joints: [JointState] = []

    public init(data: Data, fileName: String) throws {
        let doc = try GLTFDocument.read(data, name: fileName)
        let info = try VRMInfo.read(doc, name: fileName)
        self.doc = doc; self.info = info
        let meshCount = doc.nodes.filter { $0.mesh != nil }.count
        if meshCount == 0 {
            throw LivLivError(.invalid, "LivLiv: \(fileName) has a skeleton but no mesh, so there is nothing to draw (export the armature together with its meshes)")
        }
        restT = doc.nodes.map(\.translation); restR = doc.nodes.map(\.rotation); restS = doc.nodes.map(\.scale)
        localR = restR
        world = [Mat4](repeating: .identity, count: doc.nodes.count)
        order = doc.topologicalOrder
        morphWeights = doc.meshes.map { prims in [Float](repeating: 0, count: prims.first?.targets.count ?? 0) }
        let given = info.terms.name ?? ""
        let base = (fileName as NSString).deletingPathExtension
        name = String((given.isEmpty ? base : given).prefix(200))
        computeWorld()
        restWorldR = world.map { $0.rotation }
        parentRestWorldR = doc.nodes.indices.map { i in doc.parents[i].map { restWorldR[$0] } ?? .identity }
        for (ni, n) in doc.nodes.enumerated() {
            guard let mi = n.mesh, mi < doc.meshes.count else { continue }
            for (pi, p) in doc.meshes[mi].enumerated() {
                var uvs = p.uvs ?? [SIMD2<Float>](repeating: SIMD2(0, 0), count: p.positions.count)
                if let t = p.material.flatMap({ doc.materials[safe: $0] })?.baseColorTransform { uvs = uvs.map(t.apply) }
                drawables.append(VRMDrawable(mesh: mi, primitive: pi, node: ni, material: p.material, indices: p.indices,
                                             uvs: uvs, positions: p.positions))
            }
        }
        has = Set(info.expressions.keys)
        blinkBoth = has.contains("blink") && !(has.contains("blinkLeft") && has.contains("blinkRight"))
        let labels: [String: String] = ["happy": "Happy", "angry": "Angry", "sad": "Sad", "relaxed": "Relaxed", "surprised": "Surprised"]
        var ex: [(String, String)] = VRMInfo.feelings.filter { $0 != "happy" && has.contains($0) }.map { ($0, labels[$0]!) }
        if has.contains("happy") { ex.insert(("happy", "Happy"), at: 0) }
        for (id, n) in info.custom.sorted(by: { $0.key < $1.key }) where !ex.contains(where: { $0.0 == id }) { ex.append((id, labels[id] ?? n)) }
        expressions = ex
        armsDown()
        computeWorld()
        measureFrame()
        setupSprings()
        skin()
    }

    // MARK: Pose

    private func computeWorld() {
        for i in order { updateWorld(i) }
    }
    @inline(__always) private func updateWorld(_ i: Int) {
        let local = Mat4(t: restT[i], r: localR[i], s: restS[i])
        world[i] = doc.parents[i].map { world[$0] * local } ?? local
    }
    private func updateSubtree(_ i: Int) {
        updateWorld(i)
        for c in doc.nodes[i].children { updateSubtree(c) }
    }

    /// a humanoid bone turned by `q` in the model's own axes (three-vrm's normalized bones)
    private func setNormalized(_ bone: String, _ q: Quat) {
        guard let n = info.humanBones[bone] else { return }
        let P = parentRestWorldR[n]
        localR[n] = (P.conjugate * q * P * restR[n]).normalized
    }

    private func armsDown() {
        let s = flip
        setNormalized("leftUpperArm", Quat(eulerXYZ: 0, 0, -1.2 * s))
        setNormalized("rightUpperArm", Quat(eulerXYZ: 0, 0, 1.2 * s))
        setNormalized("leftLowerArm", Quat(eulerXYZ: 0, -0.25, 0))
        setNormalized("rightLowerArm", Quat(eulerXYZ: 0, 0.25, 0))
    }

    private func bonePosition(_ b: String) -> V3? { info.humanBones[b].map { world[$0].translation } }

    private func measureFrame() {
        let head = bonePosition("head") ?? V3(0, 1.4, 0), hips = bonePosition("hips") ?? V3(0, 0.9, 0)
        let torso = max(1e-3, head.y - hips.y)
        var crown = -Float.infinity
        for d in drawables {
            let M = world[d.node]
            let skinned = doc.nodes[d.node].skin != nil
            for p in d.positions { crown = max(crown, skinned ? p.y : M.point(p).y) }
        }
        if !crown.isFinite { crown = head.y }
        let top = max(head.y + torso / 3, min(crown + torso / 20, head.y + torso)), bottom = hips.y
        let la = bonePosition("leftUpperArm") ?? V3(0.2, 1.3, 0), ra = bonePosition("rightUpperArm") ?? V3(-0.2, 1.3, 0)
        let shoulders = length3(la - ra)
        let h = max(1e-3, top - bottom)
        frame = (h, (top + bottom) / 2, max(shoulders * 1.5, h / 2))
    }

    /// the head's position (model units), for where the face is on the view
    public var headPosition: V3 { (bonePosition("head") ?? V3(0, frame.y, 0)) + V3(0, 0.06, 0) }

    // MARK: Springs

    private func setupSprings() {
        joints = []
        for spring in info.springs {
            let cols = spring.colliderGroups.flatMap { info.colliderGroups[safe: $0] ?? [] }
            for j in spring.joints {
                let n = j.node
                let localTail: V3
                if let t = j.tailNode { localTail = restT[t] * restS[t] } else { localTail = info.virtualTails[n] ?? V3(0, -0.07, 0) }
                let tailWorld = j.tailNode.map { world[$0].translation } ?? world[n].point(localTail)
                let len = length3(tailWorld - world[n].translation)
                joints.append(JointState(spec: j, boneAxis: normalize3(localTail), length: len, currentTail: tailWorld, prevTail: tailWorld,
                                         initialLocalR: localR[n], colliders: cols))
            }
        }
    }

    private func stepSprings(_ dt: Float) {
        guard dt > 0, !joints.isEmpty else { return }
        for i in joints.indices {
            var J = joints[i]
            let n = J.spec.node
            let parentR = doc.parents[n].map { world[$0].rotation } ?? .identity
            let pos = world[n].translation
            let rotFrom = parentR * J.initialLocalR
            let stiffDir = rotFrom.rotate(J.boneAxis) * (J.spec.stiffness * dt)
            var next = J.currentTail + (J.currentTail - J.prevTail) * (1 - J.spec.dragForce) + stiffDir + J.spec.gravityDir * (J.spec.gravityPower * dt)
            next = pos + normalize3(next - pos) * J.length
            for ci in J.colliders {
                guard let c = info.colliders[safe: ci], c.radius > 0 || c.tail != nil else { continue }
                let M = world[c.node]
                let a = M.point(c.offset)
                var center = a
                if let t = c.tail {
                    let b = M.point(t), ab = b - a, l2 = dot3(ab, ab)
                    let k = l2 > 1e-12 ? max(0, min(1, dot3(next - a, ab) / l2)) : 0
                    center = a + ab * k
                }
                let scale = length3(M.vector(V3(1, 0, 0)))
                let r = c.radius * scale + J.spec.hitRadius
                let d = next - center, dl = length3(d)
                if dl < r && dl > 1e-9 {
                    next = center + d / dl * r
                    next = pos + normalize3(next - pos) * J.length
                }
            }
            J.prevTail = J.currentTail
            J.currentTail = next
            let from = rotFrom.rotate(J.boneAxis)
            let rot = Quat.fromTo(from, next - pos) * rotFrom
            localR[n] = (parentR.conjugate * rot).normalized
            joints[i] = J
            updateSubtree(n)
        }
    }

    /// springs back to rest (a new pose that should not swing in)
    public func resetSprings() { computeWorld(); setupSprings() }

    // MARK: Each frame

    /// the pose for this frame (vrm.ts render), then springs, morphs and skinning
    public func update(params P: Params, expr: [String: Double], dt: Double) {
        let s = flip, D = Float.pi / 180
        localR = restR
        armsDown()
        let ax = Float(P.angleX), ay = Float(P.angleY), az = Float(P.angleZ)
        let hasNeck = info.humanBones["neck"] != nil
        let hk: Float = hasNeck ? 0.65 : 1
        setNormalized("neck", Quat(eulerXYZ: -s * ay * D * 0.35, ax * D * 0.35, -s * az * D * 0.35))
        setNormalized("head", Quat(eulerXYZ: -s * ay * D * hk, ax * D * hk, -s * az * D * hk))
        setNormalized("spine", Quat(eulerXYZ: 0, Float(P.bodyX) * D * 0.8, -s * Float(P.bodyZ) * D * 0.8))
        setNormalized("chest", Quat(eulerXYZ: -s * (Float(P.breath) - 0.5) * 0.02, 0, 0))
        // expressions
        var w: [String: Float] = [:]
        func set(_ n: String, _ v: Double) { if has.contains(n) { w[n] = Float(max(0, min(1, v))) } }
        if blinkBoth { set("blink", 1 - max(P.eyeLOpen, P.eyeROpen)) }
        else { set("blinkLeft", 1 - P.eyeLOpen); set("blinkRight", 1 - P.eyeROpen) }
        let o = P.mouthOpen, v = P.vowel
        set("aa", o * (1 - abs(v) * 0.6))
        set(has.contains("ee") ? "ee" : "ih", o * max(0, v) * 0.7)
        set(has.contains("ou") ? "ou" : "oh", o * max(0, -v) * 0.7)
        set("happy", max(P.smile * 0.6, expr["happy"] ?? 0))
        for f in VRMInfo.feelings where f != "happy" && info.custom[f] == nil { set(f, expr[f] ?? 0) }
        for (id, n) in info.custom { set(n, expr[id] ?? 0) }
        // look at
        let yaw = Float(P.eyeBallX) * 25, pitch = Float(-P.eyeBallY) * 15  // degrees; pitch positive looking down
        if info.lookAt.kind == .bone {
            let L = info.lookAt
            let h = L.horizontalOuter
            let yv = min(abs(yaw), h.input) / max(h.input, 1e-3) * h.output * (yaw < 0 ? -1 : 1)
            let vr = pitch >= 0 ? L.verticalDown : L.verticalUp
            let pv = min(abs(pitch), vr.input) / max(vr.input, 1e-3) * vr.output * (pitch < 0 ? -1 : 1)
            let q = Quat(eulerXYZ: s * pv * D, yv * D, 0)
            setNormalized("leftEye", q); setNormalized("rightEye", q)
        } else {
            let L = info.lookAt
            func m(_ a: Float, _ r: (input: Float, output: Float)) -> Double { Double(min(abs(a), r.input) / max(r.input, 1e-3) * r.output) }
            set("lookLeft", yaw > 0 ? m(yaw, L.horizontalOuter) : 0); set("lookRight", yaw < 0 ? m(yaw, L.horizontalOuter) : 0)
            set("lookDown", pitch > 0 ? m(pitch, L.verticalDown) : 0); set("lookUp", pitch < 0 ? m(pitch, L.verticalUp) : 0)
        }
        // binary expressions, then what an expression blocks or blends away (blink, mouth, look)
        for (n, x) in w { if info.expressions[n]?.isBinary == true { w[n] = x > 0.5 ? 1 : 0 } }
        var blinkK: Float = 1, mouthK: Float = 1, lookK: Float = 1
        for (n, x) in w where x > 0 {
            guard let e = info.expressions[n] else { continue }
            func k(_ o: VRMExpression.Override) -> Float { o == .block ? 0 : o == .blend ? 1 - x : 1 }
            blinkK = min(blinkK, k(e.overrideBlink)); mouthK = min(mouthK, k(e.overrideMouth)); lookK = min(lookK, k(e.overrideLookAt))
        }
        for n in ["blink", "blinkLeft", "blinkRight"] where w[n] != nil { w[n]! *= blinkK }
        for n in ["aa", "ih", "ou", "ee", "oh"] where w[n] != nil { w[n]! *= mouthK }
        for n in ["lookLeft", "lookRight", "lookUp", "lookDown"] where w[n] != nil { w[n]! *= lookK }
        for i in morphWeights.indices { for j in morphWeights[i].indices { morphWeights[i][j] = 0 } }
        for (n, x) in w where x > 0 {
            for b in info.expressions[n]?.binds ?? [] where b.mesh < morphWeights.count && b.index < morphWeights[b.mesh].count {
                morphWeights[b.mesh][b.index] = min(1, morphWeights[b.mesh][b.index] + x * b.weight)
            }
        }
        computeWorld()
        stepSprings(Float(min(dt, 0.05)))
        skin()
    }

    /// every drawable's vertices: morph targets, then the skin (or the node's transform)
    private func skin() {
        for di in drawables.indices {
            let d = drawables[di]
            let prim = doc.meshes[d.mesh][d.primitive]
            let mw = morphWeights[d.mesh]
            var out = drawables[di].positions
            if out.count != prim.positions.count { out = prim.positions }
            let active = mw.indices.filter { mw[$0] != 0 && $0 < prim.targets.count }
            let skinIndex = doc.nodes[d.node].skin
            if let si = skinIndex, si < doc.skins.count, let J = prim.joints, let W = prim.weights {
                let sk = doc.skins[si]
                let jm = sk.joints.indices.map { world[sk.joints[$0]] * sk.inverseBindMatrices[$0] }
                for i in 0..<prim.positions.count {
                    var p = prim.positions[i]
                    for t in active { p += prim.targets[t][i] * mw[t] }
                    let j = J[i], ww = W[i]
                    var r = V3(0, 0, 0), tw: Float = 0
                    for k in 0..<4 {
                        let wk = ww[k]
                        if wk == 0 { continue }
                        let ji = Int(j[k])
                        if ji < jm.count { r += jm[ji].point(p) * wk; tw += wk }
                    }
                    out[i] = tw > 0 ? r / tw : p
                }
            } else {
                let M = world[d.node]
                for i in 0..<prim.positions.count {
                    var p = prim.positions[i]
                    for t in active { p += prim.targets[t][i] * mw[t] }
                    out[i] = M.point(p)
                }
            }
            drawables[di].positions = out
        }
    }
}
