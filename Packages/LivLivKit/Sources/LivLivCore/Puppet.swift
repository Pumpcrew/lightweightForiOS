// LivLiv puppet runtime (runtime/puppet.ts), without the GPU: loads a LivLiv model (layers + anchors) and animates it
// with the automatic rig. Each frame it moves every layer's mesh (`out`) and says what to draw, in which order, with
// which texture, opacity, stencil and mask (`frame(width:height:)`); a renderer (LivLivKit's Metal one) only executes it.
//
// Rig summary (procedural, derived from anchors written by the pipeline):
//  - head layers sit on a paraboloid "head bulge"; yaw/pitch rotate it and per-layer depth adds parallax
//  - hair is skinned between head and body by height and driven by a two-segment spring chain
//  - eyes: blank-white eye patch squashes onto the lid line over the closed patch; the iris slides inside the whites
//  - mouth: closed -> half -> open frames by loudness, and round / wide frames by the voice's vowel
//  - brows: local lift of every head layer but the irises (one field), or of the `brows` layer alone
//  - body: lags the head turn / tilt, breathes, optional chest spring
import Foundation

// MARK: - Constants

private let mouthAt = (0.12, 0.5), mouthHyst = 0.04, mouthHold = 0.055
private let neckShadow = 0.3
private let vowelIn = 0.65, vowelOut = 0.35
private let talkLatch = 0.4
private let sideAt = (0.5, 0.85)

@inline(__always) private func interp(_ xs: [Double], _ ys: [Double], _ x: Double) -> Double {
    if x <= xs[0] { return ys[0] }
    for i in 1..<xs.count where x <= xs[i] { return ys[i - 1] + ((ys[i] - ys[i - 1]) * (x - xs[i - 1])) / (xs[i] - xs[i - 1]) }
    return ys[ys.count - 1]
}
@inline(__always) private func browWx(_ b: [Double], _ x: Double) -> Double { 1 - smooth(0, (b[2] - b[0]) * 0.45, max(b[0] - x, x - b[2], 0)) }
@inline(__always) private func browUp(_ b: [Double]) -> Double { (b[3] - b[1]) * 1.6 + 6 }

/// brow lift weight at (x, y): fading out above the brow box, full down to the brow's lowest pixel in this column and
/// gone at the lash's highest
private func browWeight(_ b: [Double], _ line: BrowLine, _ x: Double, _ y: Double) -> Double {
    if y < b[1] { return browWx(b, x) * (1 - smooth(0, browUp(b), b[1] - y)) }
    let bot = interp(line.x, line.bottom, x)
    return y <= bot ? browWx(b, x) : browWx(b, x) * (1 - smooth(bot, interp(line.x, line.lid, x), y))
}

/// how far the brows may move (model px) before the mesh folds. Both brows share the smaller limit
private func browLimits(_ A: Anchors, _ amp: Double) -> (Double, Double) {
    var up = amp, down = amp, any = false
    for (side, b) in (A.brows ?? []).enumerated() {
        guard let b, let lines = A.browLines, side < lines.count, let line = lines[side] else { continue }
        any = true
        up = min(up, 0.6 * browUp(b))
        for (k, x) in line.x.enumerated() where k < line.lid.count && k < line.bottom.count {
            down = min(down, (0.6 * (line.lid[k] - line.bottom[k])) / max(1e-3, browWx(b, x)))
        }
    }
    return any ? (up, down) : (0, 0)
}

/// an eye highlight's scale at time t: a slow 3 % breath and, about every 5 s, a 0.35 s sparkle up to 12 %
private func twinkle(_ t: Double) -> Double {
    let k = (t / 5.3).rounded(.down)
    let km = (k * 7919).truncatingRemainder(dividingBy: 13)
    let u = t - k * 5.3 - km / 13 * 3.5
    let spark = u > 0 && u < 0.35 ? sin((u / 0.35) * .pi) : 0
    return 1 + 0.03 * sin(t * 2.1) + 0.12 * spark
}

/// lidCurve's models: front-view anime and painterly characters, whose closed eye is a drawn row of lashes
public func lidCurveFits(_ m: ModelDef) -> Bool {
    guard let p = m.profile else { return false }
    return (p.id == "anime_half" || p.id == "painterly") && p.facing == "front" && p.glasses != true && !m.layers.contains { $0.id == "glasses" }
}

// MARK: - Per layer and chain state

/// a layer's images as decoded, for what the rig measures in them when it loads
public struct LayerImages: Sendable {
    public var main: RGBAImage
    public var frames: [RGBAImage]
    public var mask: RGBAImage?
    public var talk: RGBAImage?
    public var brows: RGBAImage?
    public init(main: RGBAImage, frames: [RGBAImage] = [], mask: RGBAImage? = nil, talk: RGBAImage? = nil, brows: RGBAImage? = nil) {
        self.main = main; self.frames = frames; self.mask = mask; self.talk = talk; self.brows = brows
    }
}

/// per vertex and bone (n x B, flat): the chain, the segment its nearest point lies on, how far along it, the vertex's
/// offset from that point, and its weight
struct Skin {
    var B: Int
    var c: [Int], seg: [Int]
    var t: [Double], ux: [Double], uy: [Double], w: [Double]
    var sum: [Double]
}

final class ChainRun {
    let def: ChainDef
    var R: [Double], p: [Double], q: [Double], len: [Double], s: [Double]
    var disp: [Double], beta: [Double]
    var W = (0.0, 0.0), V = (0.0, 0.0), acc = (0.0, 0.0)
    var rho = 0.0
    var started = false
    let phase: Double
    var moving = false

    init(_ def: ChainDef) {
        self.def = def
        let m = def.points.count
        R = def.points.flatMap { [$0[0], $0[1]] }
        p = R; q = R
        len = [Double](repeating: 0, count: m); s = [Double](repeating: 0, count: m)
        for j in 1..<max(1, m) { len[j] = hypot(R[2 * j] - R[2 * j - 2], R[2 * j + 1] - R[2 * j - 1]); s[j] = s[j - 1] + len[j] }
        let total = s[m - 1] == 0 ? 1 : s[m - 1]
        for j in 1..<max(1, m) { s[j] /= total }
        var h = 0
        for ch in def.id.utf16 { h = (h * 31 + Int(ch)) % 997 }
        phase = Double(h) / 997 * 2 * .pi
        disp = [Double](repeating: 0, count: 2 * m); beta = [Double](repeating: 0, count: m)
    }
}

struct Spring { var x = 0.0, y = 0.0, vx = 0.0, vy = 0.0 }

public final class PuppetLayer {
    public let def: LayerDef
    public let index: Int
    /// the mesh at rest and as moved this frame (model px, x y pairs), its triangles and texture coordinates
    public let rest: [Float]
    public internal(set) var out: [Float]
    public let tri: [UInt32]
    public let uv: [Float]
    public let frameCount: Int
    public let hasMask: Bool, hasTalk: Bool, hasBrowTex: Bool
    /// the brows an expression drew, moved with the bangs where they lie over them (drawn from outB)
    public internal(set) var outB: [Float]?

    var wHead: [Float], wPhys1: [Float], wPhys2: [Float], dep: [Float], wFront: [Float]
    var wBrow: [Float], browSide: [Int8], wJaw: [Float], browCap: [Float]
    var wNeck: [Float]?, wTwist: [Float]?
    var fol: [Float]?, folB: [Float]?, alt: [Float]?
    var stencilRef = 0
    var pivY: [Float]?
    var pivC: Double?
    var soft = 0.0
    var maskCh = -1
    var kf: [[Float]?]?
    var skin: Skin?, altSkin: Skin?

    init(def: LayerDef, index: Int, rest: [Float], tri: [UInt32], uv: [Float], frameCount: Int, hasMask: Bool, hasTalk: Bool, hasBrowTex: Bool) {
        self.def = def; self.index = index; self.rest = rest; self.out = rest; self.tri = tri; self.uv = uv
        self.frameCount = frameCount; self.hasMask = hasMask; self.hasTalk = hasTalk; self.hasBrowTex = hasBrowTex
        let n = rest.count / 2
        wHead = [Float](repeating: 0, count: n); wPhys1 = wHead; wPhys2 = wHead; dep = wHead; wFront = wHead
        wBrow = wHead; browSide = [Int8](repeating: -1, count: n); wJaw = wHead; browCap = [Float](repeating: .infinity, count: n)
    }
}

// MARK: - What to draw

public struct DrawCommand: Sendable {
    public enum Texture: Sendable, Equatable { case main, frame(Int), mask, talk, browTex }
    public enum Vertices: Sendable { case out, outB, custom([Float]) }
    public enum Stencil: Sendable, Equatable { case none, write(UInt8), test(UInt8) }
    public var layer: Int
    public var texture: Texture
    public var alpha: Float
    public var vertices: Vertices
    /// fragments below this alpha are discarded (the stencil's cut)
    public var cut: Float
    /// 0: a layer; 2: an iris times its whites in the mask texture (channel `maskChannel`), from the stencil's 0.5 cut
    /// (soft 0) to their alpha (soft 1)
    public var mode: Int32
    public var maskChannel: Int
    public var soft: Float
    public var stencil: Stencil
}

public struct PuppetFrame: Sendable {
    /// clip space = model px * (sx, sy) + (ox, oy), then y negated (the original's vertex shader)
    public var sx: Float, sy: Float, ox: Float, oy: Float
    /// the whites of each eye whose iris sits off it, drawn first into a channel each of the mask texture
    public var maskEyes: [(layer: Int, channel: Int)]
    public var commands: [DrawCommand]
}

// MARK: - The puppet

public final class Puppet {
    public private(set) var model: ModelDef?
    public private(set) var layers: [PuppetLayer] = []
    var byId: [String: PuppetLayer] = [:]
    public var params = Params()
    var chains: [String: [Spring]] = ["front": [Spring(), Spring()], "back": [Spring(), Spring()], "side": [Spring(), Spring()]]
    var lastHead = (x: 0.0, y: 0.0, roll: 0.0)
    var drive = (x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, ax: 0.0, ay: 0.0, started: false)
    var body = (yaw: 0.0, roll: 0.0)
    var bust = (x: 0.0, y: 0.0, vx: 0.0, vy: 0.0, px: 0.0, py: 0.0)
    public private(set) var time = 0.0
    public var zoom = 1.0
    public var panY = 0.0
    /// where the user put the character: x, y as shares of the canvas (y up), s a scale around the canvas center
    public var view = (x: 0.0, y: 0.0, s: 1.0)
    /// automatic movement on top of that (talking hops, actions)
    public var move = (x: 0.0, y: 0.0, s: 1.0)
    public private(set) var cutBottom = false
    public var physicsScale = 1.0
    public var hidden = Set<String>()
    public private(set) var tuning = Tuning()
    public private(set) var rig = Rig()
    /// expression weights by layer param name (smile lives in params)
    public var expr: [String: Double] = [:]
    public private(set) var smileShown = 0.0
    var mouthFrame = 0
    var mouthW: [Double] = [1, 0, 0]
    var mouthHeld = 1.0
    var mouthAmp = 0
    var mouthShape = ""
    var vis: [String: Int] = [:]
    var frameKind = ["closed", "half", "open"]
    var frameJaw: [Double] = [0, 0, 0]
    public var procJaw = 0.015
    public var chinFollow = true
    public var chinNeck = 0.08
    public var chinNeckX = (0.2, 0.34)
    public var neckFollow = 0.2
    public var neckFollowY = 0.6
    public var neckFollowX = (0.6, 1.3)
    var talkLeft = 0.0
    public var focusHead = false
    var keys: [(param: KeyformKey.Param, value: Double, scale: Double)] = []
    private var kfPair: [Int]?
    var kfOff = false
    public var keyWeights: [Double]?
    public var masks = false
    public var lidCurve = true
    public var irisLid = true
    public var irisDrop = 0.3
    public var softIris = true
    public var irisNasal = true
    public var irisNasalNarrow = 0.7
    private var nasal: [String: Nasal] = [:]
    var chainRuns: [ChainRun] = []
    var chained: Bool { !chainRuns.isEmpty }
    public var bodyHidden = false
    public var headHidden = false
    /// the last frame's view transform: scale x / y, offset x / y in clip space, and the drawing buffer size
    public private(set) var lastView: (sx: Double, sy: Double, ox: Double, oy: Double, w: Double, h: Double) = (1, 1, 0, 0, 1, 1)

    public init() {}

    // MARK: Loading

    /// installs `model` with its layers' images. All or nothing: on a throw the puppet keeps the model before
    public func load(_ model: ModelDef, images: [LayerImages], keyforms: KeyformFile? = nil) throws {
        guard images.count == model.layers.count else { throw LivLivError(.invalid, "LivLiv: the model's images do not match its layers") }
        var texels = 0
        for im in images {
            for i in [im.main] + im.frames + [im.mask, im.talk, im.brows].compactMap({ $0 }) {
                texels += i.width * i.height
                if i.width > Limits.texture || i.height > Limits.texture || texels > Limits.texels {
                    throw LivLivError(.tooLarge, "LivLiv: this model's images are too large (\(i.width) x \(i.height): \(Limits.texture) px a side and \(Limits.texels) pixels in all at most)")
                }
            }
        }
        build(model, images, keyforms)
    }

    private func build(_ model: ModelDef, _ imgs: [LayerImages], _ keyforms: KeyformFile?) {
        self.model = model
        chainRuns = model.rig.chains.map(ChainRun.init)
        let mouth = model.layers.first { $0.role == "mouth" }
        let names = ["closed", "half", "open"]
        frameKind = (mouth?.frames ?? ["", "", ""]).indices.map { i in
            if let v = mouth?.visemes, i < v.count { return v[i] }
            return i < names.count ? names[i] : ""
        }
        let J = model.anchors.jaw
        frameJaw = frameKind.map { k in
            guard let J, k != "closed", k != "half" || J.open > 0 else { return 0 }
            return J[k] ?? 0
        }
        let pj = procJaw > 0 ? (model.rig.jaw ?? procJaw) : 0
        if J != nil && pj > 0 && !frameJaw.contains(where: { $0 > 0 }) {
            let fh = model.anchors.face[3] - model.anchors.face[1]
            let amt: [String: Double] = ["half": 0.45, "open": 1, "round": 0.7, "wide": 0.35]
            frameJaw = frameKind.map { pj * fh * (amt[$0] ?? 0) }
        }
        vis = [:]
        for (i, k) in frameKind.enumerated() where k == "round" || k == "wide" || k == "shut" { vis[k] = i }
        let fi = model.layers.firstIndex { $0.group == .hair_front }
        let bangs = fi.map { (img: imgs[$0].main, def: model.layers[$0]) }
        var built: [PuppetLayer] = []
        for (i, L) in model.layers.enumerated() {
            let over = L.id == "brows" || L.role == "expr_brows" || L.browTex != nil
            built.append(buildLayer(L, i, imgs[i], over ? bangs : nil))
        }
        layers = built
        byId = Dictionary(layers.map { ($0.def.id, $0) }, uniquingKeysWith: { a, _ in a })
        nasal = [:]
        if let eyes = model.anchors.eyes, eyes.count >= 2 {
            let mid = eyes.reduce(0) { $0 + ($1[0] + $1[2]) / 2 } / Double(eyes.count)
            for (i, I) in model.layers.enumerated() {
                let side = (I.role ?? "").hasPrefix("iris_") ? String((I.role ?? "").dropFirst(5)) : ""
                let j = I.clip.flatMap { c in model.layers.firstIndex { $0.id == c } } ?? -1
                let mask = j >= 0 ? imgs[j].mask : nil
                guard !side.isEmpty, I.range != nil, let mask, nasal[side] == nil else { continue }
                if let n = nasalRoom(imgs[i].main, I, mask, model.layers[j], sign: mid > I.x + I.w / 2 ? 1 : -1) { nasal[side] = n }
            }
        }
        if lidCurve && lidCurveFits(model) {
            for side in ["L", "R"] {
                guard let i = model.layers.firstIndex(where: { $0.role == "lid_\(side)" }), let line = closedLashLine(imgs[i].main, model.layers[i]) else { continue }
                for L in layers {
                    let r = L.def.roleString
                    guard r == "eye_\(side)" || r == "iris_\(side)" || r == "shine_\(side)" else { continue }
                    var piv = [Float](repeating: 0, count: L.rest.count / 2)
                    for k in 0..<piv.count { piv[k] = Float(line(Double(L.rest[2 * k]))) }
                    L.pivY = piv
                    L.pivC = line(L.def.x + L.def.w / 2)
                }
            }
        }
        tuning = model.tuning
        rig = model.rig
        expr = [:]
        resetMouth(); talkLeft = 0
        cutBottom = model.anchors.bottomY >= model.canvas.h - 4
        resetPhysics()
        keys = []; kfPair = nil
        if let keyforms { prepareKeyforms(keyforms) }
    }

    private func buildLayer(_ L: LayerDef, _ index: Int, _ im: LayerImages, _ bangs: (img: RGBAImage, def: LayerDef)?) -> PuppetLayer {
        let model = self.model!, A = model.anchors
        let browLayer = model.layers.contains { $0.id == "brows" }
        let cell = latticeCell(model.canvas.w, model.canvas.h)
        let gx0 = Int((L.x / cell).rounded(.down)), gy0 = Int((L.y / cell).rounded(.down))
        let cols = Int(((L.x + L.w) / cell).rounded(.up)) - gx0, rows = Int(((L.y + L.h) / cell).rounded(.up)) - gy0
        let occ = alphaGrid([im.main] + im.frames, cols: cols, rows: rows, ox: (L.x - Double(gx0) * cell) / cell,
                            oy: (L.y - Double(gy0) * cell) / cell, w: L.w / cell, h: L.h / cell)
        var vid = [Int32](repeating: -1, count: (cols + 1) * (rows + 1))
        var pos: [Float] = [], uv: [Float] = [], idx: [UInt32] = []
        func vert(_ c: Int, _ r: Int) -> UInt32 {
            let k = r * (cols + 1) + c
            if vid[k] < 0 {
                vid[k] = Int32(pos.count / 2)
                let X = Double(gx0 + c) * cell, Y = Double(gy0 + r) * cell
                pos.append(Float(X)); pos.append(Float(Y))
                uv.append(Float((X - L.x) / L.w)); uv.append(Float((Y - L.y) / L.h))
            }
            return UInt32(vid[k])
        }
        for r in 0..<rows {
            for c in 0..<cols where occ[r * cols + c] != 0 {
                let a = vert(c, r), b = vert(c + 1, r), d = vert(c, r + 1), e = vert(c + 1, r + 1)
                idx += [a, b, d, b, e, d]
            }
        }
        let P = PuppetLayer(def: L, index: index, rest: pos, tri: idx, uv: uv, frameCount: im.frames.count,
                            hasMask: im.mask != nil, hasTalk: im.talk != nil, hasBrowTex: im.brows != nil)
        let n = pos.count / 2
        let rest = pos
        if neckFollow > 0 && L.group == .body { P.wNeck = [Float](repeating: 0, count: n) }
        let NT = model.rig.neck
        if let NT, NT.twist > 0, L.group == .body { P.wTwist = [Float](repeating: 0, count: n) }
        if let bangs, L.id == "brows" || L.role == "expr_brows" { P.fol = coverAt(im.main, L, bangs.img, bangs.def, rest, cell) }
        if let bangs, let brows = im.brows { P.folB = coverAt(brows, L, bangs.img, bangs.def, rest, cell) }
        if P.fol != nil || P.folB != nil { P.alt = [Float](repeating: 0, count: 5 * n) }
        let fw = A.face[2] - A.face[0]
        let h = A.head
        let hairTop = A.neckY - 0.1 * h.ry
        let hairLen = max(1, A.bottomY - hairTop)
        let jawOn = frameJaw.contains { $0 > 0 }
        for i in 0..<n {
            let x = Double(rest[2 * i]), y = Double(rest[2 * i + 1])
            let rr = hypot((x - h.cx) / h.rx, (y - h.cy) / h.ry)
            switch L.group {
            case .head: P.dep[i] = Float(L.depth)
            case .hair_front: P.dep[i] = Float(L.depth * smooth(L.fallEnd ?? 1.0, L.fall ?? 0.55, rr))
            default: P.dep[i] = Float(L.depth * smooth(L.fallEnd ?? 1.0, L.fallEnd == nil ? 0.7 : (L.fall ?? 0.7), rr))
            }
            let longHead = 1 - smooth(A.neckY + 0.05 * h.ry, A.neckY + 1.1 * h.ry, y)
            let tl = min(1, max(0, (y - hairTop) / hairLen))
            let lp1 = smooth(0, 0.55, tl), lp2 = pow(smooth(0.25, 1, tl), 1.3)
            let f = smooth(0.95, 0.7, rr) * (1 - smooth(A.neckY - 0.2 * h.ry, A.neckY + 0.3 * h.ry, y))
            let tb = smooth(A.hairRootY + 0.25 * h.ry, h.cy + 0.7 * h.ry, y)
            if L.group == .head { P.wHead[i] = 1 }
            else if L.group == .body { P.wHead[i] = 0 }
            else {
                P.wHead[i] = Float(f + (1 - f) * longHead)
                P.wPhys1[i] = Float(f * tb + (1 - f) * lp1); P.wPhys2[i] = Float(f * tb * tb + (1 - f) * lp2)
                P.wFront[i] = Float(f)
                if L.group == .hair_inner { P.wHead[i] *= 0.5; P.wPhys1[i] *= 0.35; P.wPhys2[i] *= 0.35 }
            }
            if P.alt != nil, let bangs {
                let k = 5 * i
                P.alt![k] = Float(bangs.def.depth * smooth(1.0, bangs.def.fall ?? 0.55, rr)); P.alt![k + 1] = Float(f + (1 - f) * longHead)
                P.alt![k + 2] = Float(f * tb + (1 - f) * lp1); P.alt![k + 3] = Float(f * tb * tb + (1 - f) * lp2); P.alt![k + 4] = Float(f)
            }
            let hairFront = L.group == .hair_side || L.group == .hair_front
            let mouthCopy = chinFollow && L.role == "mouth"
            if (L.id == "face" || L.role == "expr" || hairFront || mouthCopy || L.role == "neck_shadow"), let jaw = A.jaw, jawOn {
                let vy = smooth(jaw.top - 0.02 * h.ry, jaw.chin, y) * (hairFront ? 1 - smooth(jaw.chin, jaw.chin + 0.15 * h.ry, y) : 1)
                let vx = 1 - smooth(0.22 * fw, 0.5 * fw, abs(x - h.cx))
                P.wJaw[i] = Float(vy * vx)
            }
            if L.role == "neck_shadow", let jaw = A.jaw {
                let k = 1 - smooth(jaw.chin, jaw.chin + neckShadow * (A.face[3] - A.face[1]), y)
                P.wHead[i] = Float(k)
                P.wJaw[i] *= Float(k)
            }
            if chinFollow && L.group == .body, let jaw = A.jaw {
                let fh = A.face[3] - A.face[1]
                let wy = 1 - smooth(jaw.chin, jaw.chin + chinNeck * fh, y)
                let wx = 1 - smooth(chinNeckX.0 * fw, chinNeckX.1 * fw, abs(x - h.cx))
                let w = wy * wx
                if w > 0 {
                    P.wHead[i] = Float(w)
                    if jawOn {
                        let vy = smooth(jaw.top - 0.02 * h.ry, jaw.chin, y)
                        P.wJaw[i] = Float(vy * (1 - smooth(0.22 * fw, 0.5 * fw, abs(x - h.cx))) * w)
                    }
                }
            }
            if P.wNeck != nil {
                let fh = A.face[3] - A.face[1]
                P.wNeck![i] = Float(max(0, neckFollow * (1 - smooth(A.neckY, A.neckY + neckFollowY * fh, y))
                    * (1 - smooth(neckFollowX.0 * fw, neckFollowX.1 * fw, abs(x - h.cx))) - Double(P.wHead[i])))
            }
            if P.wTwist != nil, let NT {
                let fh = A.face[3] - A.face[1], cy = A.jaw?.chin ?? A.neckY
                P.wTwist![i] = Float(max(0, NT.twist * (1 - smooth(cy, cy + (NT.reach ?? 0.45) * fh, y))
                    * (1 - smooth(chinNeckX.0 * fw, chinNeckX.1 * fw, abs(x - h.cx))) - Double(P.wHead[i])))
            }
            if let brows = A.brows, L.group == .head, !L.roleString.hasPrefix("iris_"), !browLayer || L.id == "brows" {
                for (side, b) in brows.enumerated() {
                    guard let b, let lines = A.browLines, side < lines.count, let line = lines[side] else { continue }
                    let w = browWeight(b, line, x, y)
                    if w > Double(P.wBrow[i]) {
                        P.wBrow[i] = Float(w); P.browSide[i] = Int8(side)
                        P.browCap[i] = line.cap.map { Float(interp(line.x, $0, x)) } ?? .infinity
                    }
                }
            }
        }
        if let bones = L.bones, !bones.isEmpty {
            P.skin = skinOf(bones, rest)
            if P.skin != nil && !bones.allSatisfy({ id in chainRuns.first { $0.def.id == id }?.def.reach != nil }) {
                P.wPhys1 = [Float](repeating: 0, count: n); P.wPhys2 = P.wPhys1
            }
        }
        if L.rigid != nil { P.wPhys1 = [Float](repeating: 0, count: n); P.wPhys2 = P.wPhys1 }
        if P.alt != nil, let bb = bangs?.def.bones, !bb.isEmpty {
            P.altSkin = skinOf(bb, rest)
            if P.altSkin != nil { for i in 0..<n { P.alt![5 * i + 2] = 0; P.alt![5 * i + 3] = 0 } }
        }
        if P.folB != nil { P.outB = rest }
        return P
    }

    /// each vertex's place on the chains `ids`: its nearest point on each chain's line, its offset from there, and a
    /// weight by distance (a Gaussian of sigma, normalised over the chains)
    private func skinOf(_ ids: [String], _ rest: [Float]) -> Skin? {
        let cs = ids.compactMap { id in chainRuns.firstIndex { $0.def.id == id } }
        if cs.isEmpty { return nil }
        let n = rest.count / 2, B = cs.count
        var S = Skin(B: B, c: [Int](repeating: 0, count: n * B), seg: [Int](repeating: 0, count: n * B), t: [Double](repeating: 0, count: n * B),
                     ux: [Double](repeating: 0, count: n * B), uy: [Double](repeating: 0, count: n * B), w: [Double](repeating: 0, count: n * B),
                     sum: [Double](repeating: 0, count: n))
        for i in 0..<n {
            let x = Double(rest[2 * i]), y = Double(rest[2 * i + 1])
            var sum = 0.0
            for (b, ci) in cs.enumerated() {
                let C = chainRuns[ci], R = C.R, m = R.count / 2
                var best = Double.infinity, bk = 0, bt = 0.0
                for k in 0..<(m - 1) {
                    let ax = R[2 * k], ay = R[2 * k + 1], dx = R[2 * k + 2] - ax, dy = R[2 * k + 3] - ay
                    let L2 = dx * dx + dy * dy == 0 ? 1 : dx * dx + dy * dy
                    var t = ((x - ax) * dx + (y - ay) * dy) / L2
                    if k > 0 { t = max(0, t) }
                    if k < m - 2 { t = min(1, t) }
                    let px = ax + dx * t, py = ay + dy * t, d = hypot(x - px, y - py)
                    if d < best { best = d; bk = k; bt = t }
                }
                let j = i * B + b, k = bk, tt = min(1, bt)
                let px = R[2 * k] + (R[2 * k + 2] - R[2 * k]) * tt, py = R[2 * k + 1] + (R[2 * k + 3] - R[2 * k + 1]) * tt
                let sg = C.def.sigma ?? 40
                S.c[j] = ci; S.seg[j] = k; S.t[j] = bt; S.ux[j] = x - px; S.uy[j] = y - py
                S.w[j] = exp(-((best / sg) * (best / sg))) + 1e-6
                sum += S.w[j]
            }
            var near = Double.infinity, reach = Double.infinity
            for b in 0..<B {
                let C = chainRuns[S.c[i * B + b]]
                S.w[i * B + b] /= sum
                if let r = C.def.reach { reach = min(reach, r) }
                near = min(near, hypot(S.ux[i * B + b], S.uy[i * B + b]))
            }
            if reach < .infinity { let k = 1 - smooth(reach, 1.6 * reach, near); for b in 0..<B { S.w[i * B + b] *= k } }
            for b in 0..<B { S.sum[i] += S.w[i * B + b] }
        }
        return S
    }

    /// each key pose's fields, as a per-vertex offset from the rig's own pose at that key: measured once here with the
    /// springs at rest, the torso settled and the face neutral
    private func prepareKeyforms(_ K: KeyformFile) {
        var seen: [String: [UInt8]] = [:]
        func bytes(_ b64: String) -> [UInt8] {
            if let o = seen[b64] { return o }
            let o = [UInt8](Data(base64Encoded: b64) ?? Data())
            seen[b64] = o
            return o
        }
        let saveParams = params, saveBody = body, saveBust = bust, saveMouthW = mouthW, saveSmile = smileShown, saveChains = chains
        let B = rig.body, tt = tuning.turn
        for (ki, key) in K.keys.enumerated() {
            var P = Params()
            switch key.param {
            case .angleX: P.angleX = key.value
            case .angleY: P.angleY = key.value
            case .diag: break
            }
            params = P
            body = (yaw: P.bodyX + P.angleX * B.yaw * tt, roll: P.bodyZ + P.angleZ * rig.body.roll * tt)
            for k in chains.keys { chains[k] = [Spring(), Spring()] }
            bust.x = 0; bust.y = 0; bust.vx = 0; bust.vy = 0
            mouthW = frameKind.indices.map { $0 == 0 ? 1 : 0 }; smileShown = 0
            kfOff = true
            deform()
            kfOff = false
            for L in layers {
                func has(_ f: String) -> Bool { key.fields[f] != nil || (key.same?.contains(f) ?? false) }
                let g: String
                if key.fields[L.def.id] != nil { g = L.def.id }
                else if L.def.group == .head { g = "head" }
                else if L.def.group.rawValue.hasPrefix("hair") { g = "hair" }
                else if L.def.group == .body && has("torso") { g = "torso" }
                else { g = L.def.id }
                let b64 = key.fields[g] ?? ((key.same?.contains(g) ?? false) ? key.fields["head"] : nil)
                if L.kf == nil { L.kf = [[Float]?](repeating: nil, count: K.keys.count) }
                guard let b64 else { L.kf![ki] = nil; continue }
                let raw = bytes(b64)
                var f = [Int16](repeating: 0, count: raw.count >> 1)
                for i in 0..<f.count { f[i] = Int16(bitPattern: UInt16(raw[2 * i]) | UInt16(raw[2 * i + 1]) << 8) }
                guard f.count >= K.cols * K.rows * 2 else { L.kf![ki] = nil; continue }
                let m = K.mask?[g].map(bytes)
                var d = [Float](repeating: 0, count: L.rest.count)
                f.withUnsafeBufferPointer { fp in
                    for i in stride(from: 0, to: d.count, by: 2) {
                        let rx = Double(L.rest[i]), ry = Double(L.rest[i + 1])
                        let (dx, dy) = K.sampleField(fp, rx, ry)
                        let w = (m != nil && m!.count >= K.cols * K.rows) ? K.sampleMask(m!, rx, ry) : 1
                        d[i] = Float((rx + dx - Double(L.out[i])) * w); d[i + 1] = Float((ry + dy - Double(L.out[i + 1])) * w)
                    }
                }
                L.kf![ki] = d
            }
            let nod = key.param == .angleY
            keys.append((key.param, key.value, (tt * (nod ? tuning.nod : 1)) / (K.turn * (nod ? K.nod : 1))))
        }
        params = saveParams; body = saveBody; bust = saveBust; mouthW = saveMouthW; smileShown = saveSmile; chains = saveChains
        kfPair = K.hermite ? keys.map { k in keys.firstIndex { o in o.param == k.param && k.param != .diag && o.value == -k.value } ?? -1 } : nil
    }

    // MARK: Expressions

    private func exprAlpha(_ d: LayerDef) -> Double {
        smooth(0.3, 0.7, d.param == "smile" || d.param == nil ? smileShown : (expr[d.param!] ?? 0))
    }
    private func exprValue(_ param: String) -> Double { param == "smile" ? smileShown : (expr[param] ?? 0) }
    private func moodAlpha(_ d: LayerDef) -> Double {
        func sum(_ m: [String: Double]?) -> Double { var a = 0.0; for (k, v) in m ?? [:] { a += v * exprValue(k) }; return min(1, a) }
        return (d.show != nil ? sum(d.show) : 1) * (d.hide != nil ? 1 - sum(d.hide) : 1)
    }
    private func shown(_ L: PuppetLayer) -> Bool {
        let d = L.def, role = d.roleString
        if hidden.contains(d.id) { return false }
        if d.group == .body ? bodyHidden : headHidden { return false }
        if (d.show != nil || d.hide != nil) && moodAlpha(d) <= 0.01 { return false }
        if role == "expr" || role == "expr_brows" { return exprAlpha(d) > 0.01 }
        if role.hasPrefix("lid_") { return 1 - smooth(0.05, 0.35, role == "lid_L" ? params.eyeLOpen : params.eyeROpen) > 0.01 }
        if role == "blush" {
            var a = 0.0
            for (k, v) in d.blush ?? [:] { a += v * exprValue(k) }
            return a > 0.01
        }
        return true
    }

    // MARK: Chains

    private func skinOffset(_ S: Skin, _ i: Int) -> (Double, Double) {
        if S.sum[i] < 1e-4 { return (0, 0) }
        var ox = 0.0, oy = 0.0
        for b in 0..<S.B {
            let j = i * S.B + b, C = chainRuns[S.c[j]], k = S.seg[j]
            if !C.moving { continue }
            let t = min(1, max(0, S.t[j])), e = S.t[j] < 0 ? 0.0 : 1.0
            let dx = (C.disp[2 * k] + (C.disp[2 * k + 2] - C.disp[2 * k]) * t) * e
            let dy = (C.disp[2 * k + 1] + (C.disp[2 * k + 3] - C.disp[2 * k + 1]) * t) * e
            let be = (C.beta[k] + (C.beta[k + 1] - C.beta[k]) * t) * e
            let c = cos(be), s = sin(be), ux = S.ux[j], uy = S.uy[j]
            let lx = dx + ux * c - uy * s - ux, ly = dy + ux * s + uy * c - uy
            let cr = cos(C.rho), sr = sin(C.rho)
            ox += S.w[j] * (lx * cr - ly * sr); oy += S.w[j] * (lx * sr + ly * cr)
        }
        return (ox, oy)
    }

    private func chainRoot(_ def: ChainDef, _ P: Params, _ nb: (Double, Double)) -> (Double, Double, Double) {
        let rx = def.points[0][0], ry = def.points[0][1], A = model!.anchors
        if def.attachBody {
            let b = bodyOffset(rx, ry, P)
            return (rx + b.0, ry + b.1, body.roll * .pi / 180 * smooth(A.bottomY, A.neckY, ry))
        }
        let h = headXform(rx, ry, def.depth ?? 0, P)
        return (h.0 + nb.0, h.1 + nb.1, P.angleZ * .pi / 180 * rig.roll * tuning.turn)
    }

    private func stepChains(_ dt: Double) {
        guard !chainRuns.isEmpty, dt > 0, let A = model?.anchors else { return }
        let P = params
        let nb = bodyOffset(A.head.cx, A.neckY, P)
        let g = physicsScale * (tuning.hairBack ?? tuning.hair)
        for C in chainRuns {
            let d = C.def, m = C.R.count / 2
            let r = chainRoot(d, P, nb)
            if !C.started { C.W = (r.0, r.1); C.V = (0, 0); C.acc = (0, 0); C.started = true }
            let vx = (r.0 - C.W.0) / dt, vy = (r.1 - C.W.1) / dt
            let ax = (vx - C.V.0) / dt, ay = (vy - C.V.1) / dt
            C.W = (r.0, r.1); C.V = (vx, vy); C.rho = r.2
            let ks = min(1, dt * 30)
            C.acc.0 += (ax - C.acc.0) * ks; C.acc.1 += (ay - C.acc.1) * ks
            let cr = cos(-C.rho), sr = sin(-C.rho)
            let lax = C.acc.0 * cr - C.acc.1 * sr, lay = C.acc.0 * sr + C.acc.1 * cr
            var bias = 0.0
            for (k, v) in d.bias ?? [:] { bias += v * exprValue(k) }
            let turn = -C.rho * d.hang + bias * .pi / 180, ct = cos(turn), st = sin(turn)
            let f = d.freq ?? 0.5, wt = 2 * .pi * f * time + C.phase
            let wind = d.wind * g * rig.wind * (sin(wt) + 0.4 * sin(1.7 * wt + 2 * C.phase))
            let damp = max(0, 1 - d.damp * dt)
            let R = C.R
            for j in 1..<m {
                let s = C.s[j], k = d.k[0] + (d.k[1] - d.k[0]) * s
                let tx = R[2 * j] - R[0], ty = R[2 * j + 1] - R[1]
                let gx = R[0] + tx * ct - ty * st + wind * s, gy = R[1] + tx * st + ty * ct
                let fx = k * (gx - C.p[2 * j]) - d.drive * g * lax, fy = k * (gy - C.p[2 * j + 1]) - d.drive * g * lay
                let nx = C.p[2 * j] + (C.p[2 * j] - C.q[2 * j]) * damp + fx * dt * dt
                let ny = C.p[2 * j + 1] + (C.p[2 * j + 1] - C.q[2 * j + 1]) * damp + fy * dt * dt
                C.q[2 * j] = C.p[2 * j]; C.q[2 * j + 1] = C.p[2 * j + 1]; C.p[2 * j] = nx; C.p[2 * j + 1] = ny
            }
            let lim = d.limit ?? .infinity
            for j in 1..<m {
                let dx = C.p[2 * j] - C.p[2 * j - 2], dy = C.p[2 * j + 1] - C.p[2 * j - 1]
                let l = hypot(dx, dy) == 0 ? 1 : hypot(dx, dy)
                C.p[2 * j] = C.p[2 * j - 2] + (dx / l) * C.len[j]; C.p[2 * j + 1] = C.p[2 * j - 1] + (dy / l) * C.len[j]
                let ex = C.p[2 * j] - R[2 * j], ey = C.p[2 * j + 1] - R[2 * j + 1], e = hypot(ex, ey)
                if e > lim { C.p[2 * j] = R[2 * j] + (ex * lim) / e; C.p[2 * j + 1] = R[2 * j + 1] + (ey * lim) / e }
            }
            var mv = 0.0
            for j in 0..<m {
                C.disp[2 * j] = C.p[2 * j] - R[2 * j]; C.disp[2 * j + 1] = C.p[2 * j + 1] - R[2 * j + 1]
                mv = max(mv, abs(C.disp[2 * j]), abs(C.disp[2 * j + 1]))
            }
            C.moving = mv > 1e-3
            var al: [Double] = []
            for k in 0..<(m - 1) {
                let rx = R[2 * k + 2] - R[2 * k], ry = R[2 * k + 3] - R[2 * k + 1], cx = C.p[2 * k + 2] - C.p[2 * k], cy = C.p[2 * k + 3] - C.p[2 * k + 1]
                al.append(atan2(rx * cy - ry * cx, rx * cx + ry * cy))
            }
            C.beta[0] = 0
            if m > 2 { for j in 1..<(m - 1) { C.beta[j] = 0.5 * (al[j - 1] + al[j]) } }
            C.beta[m - 1] = al[m - 2]
        }
    }

    // MARK: Rig

    private var hxKey = (ax: Double.nan, ay: Double.nan, az: Double.nan, t: Double.nan, n: Double.nan, ry: Double.nan, rp: Double.nan, rr: Double.nan, pe: Double.nan)
    private var hxTrig = (cy: 1.0, sy: 0.0, cp: 1.0, sp: 0.0, cr: 1.0, sr: 0.0)
    /// the head's turn, nod and roll as sines and cosines: the same for every vertex of a frame, so worked out once per pose
    @inline(__always) private func headTrig(_ P: Params) -> (cy: Double, sy: Double, cp: Double, sp: Double, cr: Double, sr: Double) {
        let R = rig, tt = tuning.turn, nd = tuning.nod, pe = R.pitchEase ?? 0.25
        let k = hxKey
        if k.ax != P.angleX || k.ay != P.angleY || k.az != P.angleZ || k.t != tt || k.n != nd || k.ry != R.yaw || k.rp != R.pitch || k.rr != R.roll || k.pe != pe {
            let py = P.angleY / 30
            let yaw = (P.angleX / 30) * R.yaw * tt, pitch = py * (1 - pe * py * py) * R.pitch * tt * nd
            let roll = P.angleZ * .pi / 180 * R.roll * tt
            hxKey = (P.angleX, P.angleY, P.angleZ, tt, nd, R.yaw, R.pitch, R.roll, pe)
            hxTrig = (cos(yaw), sin(yaw), cos(pitch), sin(pitch), cos(roll), sin(roll))
        }
        return hxTrig
    }

    @inline(__always) private func headXform(_ x: Double, _ y: Double, _ depth: Double, _ P: Params) -> (Double, Double) {
        let A = model!.anchors, h = A.head
        let u = (x - h.cx) / h.rx, v = (y - h.cy) / h.ry
        let R = rig
        let q = R.bulgeShape ?? 1
        var bu = u, bv = v
        if let E = R.bulgeExtent {
            var ex = E[0]
            if E.count > 3 && v > 0 {
                let t = min(1, v / (E[2] * (E.count > 4 ? E[4] : 1)))
                ex += (E[3] - E[0]) * t * t * (3 - 2 * t)
            }
            bu = u / ex; bv = v / (v < 0 ? E[1] : E[2])
        }
        let bulge = R.bulge * max(0, q == 1 ? 1 - bu * bu - bv * bv : 1 - pow(bu * bu + bv * bv, q))
        let z = bulge + depth
        let T = headTrig(P)
        var u2 = u * T.cy + z * T.sy
        let z2 = -u * T.sy + z * T.cy
        var v2 = v * T.cp - z2 * T.sp
        u2 += (R.drift?[0] ?? 0.12) * T.sy; v2 -= (R.drift?[1] ?? 0.08) * T.sp
        let X = h.cx + u2 * h.rx, Y = h.cy + v2 * h.ry
        let nx = h.cx, ny = A.neckY
        let dx = X - nx, dy = Y - ny
        return (nx + dx * T.cr - dy * T.sr, ny + dx * T.sr + dy * T.cr)
    }

    /// rigid torso motion at (x, y): breathing, turn-follow, lean; plus the chest bump when `withBust`
    @inline(__always) private func bodyOffset(_ x: Double, _ y: Double, _ P: Params, _ withBust: Bool = true) -> (Double, Double) {
        let A = model!.anchors, h = A.head, B = rig.body
        let t = smooth(A.bottomY, A.neckY, y)
        let fw = A.face[2] - A.face[0]
        let br = P.breath * tuning.breath * rig.breath * B.breath
        var dx = (x - h.cx) * 0.01 * br * t
        var dy = -br * 0.024 * h.ry * pow(t, 1.3)
        let yaw = body.yaw / 30
        let bw = 1.4 * fw
        let u = max(-1.6, min(1.6, (x - h.cx) / bw))
        let sgn: Double = u > 0 ? 1 : u < 0 ? -1 : 0
        dx += yaw * bw * 0.16 * pow(t, 1.2) * (1 - 0.18 * u * u) + yaw * (x - h.cx) * -0.04 * sgn * t
        let a = (body.roll * .pi / 180) * t
        if a != 0 {
            let px = h.cx, py = A.bottomY + 0.4 * (A.bottomY - A.neckY)
            let rx = x - px, ry = y - py, c = cos(a), s = sin(a)
            dx += rx * (c - 1) - ry * s; dy += rx * s + ry * (c - 1)
        }
        if let C = A.chest, withBust {
            let ux = (x - C.cx) / C.rx, uy = (y - C.cy) / C.ry, d = (ux * ux + uy * uy).squareRoot()
            let w = 1 - smooth(0.2, 1.15, d)
            if w > 0 {
                dy -= br * 0.012 * h.ry * w * (0.4 + B.bust)
                dx += bust.x * w; dy += bust.y * w
            }
        }
        return (dx, dy)
    }

    private func stepBody(_ dt: Double) {
        let P = params, B = rig.body
        let tt = tuning.turn
        let ty = P.bodyX + P.angleX * B.yaw * tt, tr = P.bodyZ + P.angleZ * B.roll * tt
        let k = min(1, dt * 5)
        body.yaw += (ty - body.yaw) * k
        body.roll += (tr - body.roll) * k
        guard let C = model?.anchors.chest, B.bust > 0 else { bust.x = 0; bust.y = 0; return }
        let o = bodyOffset(C.cx, C.cy, P, false)
        let inv = 1 / max(dt, 1e-4)
        let ax = (o.0 - bust.px) * inv, ay = (o.1 - bust.py) * inv
        bust.px = o.0; bust.py = o.1
        let s = B.bust * physicsScale
        let K = 70.0, D = 7.0
        bust.vx += (-K * bust.x - D * bust.vx - ax * 3.2 * s) * dt
        bust.vy += (-K * bust.y - D * bust.vy - ay * 4.2 * s) * dt
        bust.x += bust.vx * dt; bust.y += bust.vy * dt
        let lim = 0.035 * model!.anchors.head.ry * (0.5 + s)
        bust.x = max(-lim, min(lim, bust.x)); bust.y = max(-lim, min(lim, bust.y))
    }

    /// closed mouth, no hold pending
    public func resetMouth() {
        mouthFrame = 0; mouthAmp = 0; mouthShape = ""; mouthHeld = 1
        mouthW = frameKind.indices.map { $0 == 0 ? 1 : 0 }
    }

    private func stepMouth(_ dt: Double) {
        let m = min(1, max(0, params.mouthOpen)), v = min(1, max(-1, params.vowel))
        let (t1, t2) = mouthAt, h = mouthHyst
        mouthHeld += dt
        var a = mouthAmp
        if a == 0 && m > t1 + h { a = m > t2 + h ? 2 : 1 }
        else if a == 1 && (m < t1 - h || m > t2 + h) { a = m < t1 - h ? 0 : 2 }
        else if a == 2 && m < t2 - h { a = m < t1 - h ? 0 : 1 }
        var s = mouthShape
        if s.isEmpty || (s == "round" ? v > -vowelOut : v < vowelOut) { s = v < -vowelIn ? "round" : v > vowelIn ? "wide" : "" }
        var want = a > 0 && !s.isEmpty && vis[s] != nil ? vis[s]! : a
        if want == 0 && talkLeft > 0, let shut = vis["shut"] { want = shut }
        if want == mouthFrame { mouthAmp = a; mouthShape = s }
        else if mouthHeld >= mouthHold { mouthFrame = want; mouthAmp = a; mouthShape = s; mouthHeld = 0 }
        let f = mouthFrame
        talkLeft = f > 0 && f != vis["shut"] ? talkLatch : max(0, talkLeft - dt)
        let k = min(1, dt * 28)
        for i in mouthW.indices { mouthW[i] += ((i == f ? 1 : 0) - mouthW[i]) * k }
    }

    private func frameEase(_ i: Int, _ m: Double) -> Double {
        let (t1, t2) = mouthAt, kind = i < frameKind.count ? frameKind[i] : ""
        return kind == "half" ? smooth(t1, t2, m) : kind == "open" ? smooth(t2, 1, m) : smooth(t1, 1, m)
    }

    private func stepPhysics(_ dt: Double) {
        let P = params, A = model!.anchors
        let ht = headXform(A.head.cx, A.hairRootY, 0, P)
        let inv = 1 / max(dt, 1e-4)
        let vx = (ht.0 - lastHead.x) * inv, vy = (ht.1 - lastHead.y) * inv
        lastHead = (ht.0, ht.1, P.angleZ)
        let D = rig.hairDrive
        if D != nil {
            let fp = headXform(A.head.cx, A.head.cy, 0, P)
            if !drive.started { drive = (fp.0, fp.1, 0, 0, 0, 0, true) }
            let ks = min(1, dt * 25)
            let svx = drive.vx + ((fp.0 - drive.x) * inv - drive.vx) * ks, svy = drive.vy + ((fp.1 - drive.y) * inv - drive.vy) * ks
            drive.ax += ((svx - drive.vx) * inv - drive.ax) * ks; drive.ay += ((svy - drive.vy) * inv - drive.ay) * ks
            drive.x = fp.0; drive.y = fp.1; drive.vx = svx; drive.vy = svy
        }
        let R = rig
        let lim = A.head.ry * R.hairLimit
        for key in (R.hairSide != nil ? ["front", "back", "side"] : ["front", "back"]) {
            let cfg = key == "front" ? R.hairFront : key == "back" ? R.hairBack : R.hairSide!
            let k1 = cfg[0], c1 = cfg[1], g = cfg[2], k2 = cfg[3], c2 = cfg[4]
            var a = chains[key]![0], b = chains[key]![1]
            let s = physicsScale * ((key == "back" ? tuning.hairBack : tuning.hairFront) ?? tuning.hair)
            let wind = key == "side" ? sin(time * 1.5 + 0.7) * 1.2 * s * R.wind
                : sin(time * (key == "front" ? 1.9 : 1.15)) * (key == "front" ? 0.6 : 1.8) * s * R.wind
            let gravity = -P.angleZ * 0.2 * s
            var ax = -k1 * (a.x - wind - gravity) - c1 * a.vx - vx * g * k1 * 0.06 * s
            var ay = -k1 * a.y - c1 * a.vy - vy * g * k1 * 0.04 * s
            if let D {
                let m = (key == "front" ? D[0] : key == "back" ? D[1] : (D.count > 2 ? D[2] : D[0])) * s
                ax -= drive.ax * m; ay -= drive.ay * m
            }
            a.vx += ax * dt; a.vy += ay * dt; a.x += a.vx * dt; a.y += a.vy * dt
            let bx = -k2 * (b.x - a.x * 1.6) - c2 * b.vx
            let by = -k2 * (b.y - a.y * 1.4) - c2 * b.vy
            b.vx += bx * dt; b.vy += by * dt; b.x += b.vx * dt; b.y += b.vy * dt
            a.x = max(-lim, min(lim, a.x)); a.y = max(-lim * 0.6, min(lim * 0.6, a.y))
            b.x = max(-lim, min(lim, b.x)); b.y = max(-lim * 0.6, min(lim * 0.6, b.y))
            chains[key] = [a, b]
        }
    }

    /// one frame: time, physics, the mesh
    public func update(_ dt: Double, mesh: Bool = true) {
        guard model != nil else { return }
        time += dt
        smileShown += (params.smile - smileShown) * min(1, dt * 7)
        stepMouth(dt)
        for k in [ParamKey.angleX, .angleY, .angleZ] { params[k] = max(k.range.lowerBound, min(k.range.upperBound, params[k])) }
        let steps = max(1, Int((dt / (1.0 / 120)).rounded(.up)))
        for _ in 0..<steps { stepBody(dt / Double(steps)); stepPhysics(dt / Double(steps)); stepChains(dt / Double(steps)) }
        if mesh { deform() }
    }

    /// every layer's vertices at the current params, springs and torso: into each layer's out
    private func deform() {
        guard let model else { return }
        let P = params, A = model.anchors
        let neckBody = bodyOffset(A.head.cx, A.neckY, P)
        let (liftUp, liftDown) = browLimits(A, A.head.ry * rig.brow)
        func lift(_ v: Double) -> Double { v > 0 ? min(1, v) * liftUp : max(-1, v) * liftDown }
        let browLift = [lift(P.browLY), lift(P.browRY)]
        let mo = min(1, max(0, P.mouthOpen))
        var jawDrop = 0.0
        for (i, w) in mouthW.enumerated() where w > 0 && i < frameJaw.count && frameJaw[i] > 0 {
            jawDrop += w * frameJaw[i] * (frameKind[i] == "half" ? 0.6 + 0.4 * frameEase(i, mo) : 0.75 + 0.25 * frameEase(i, mo))
        }
        let sideOn = rig.hairSide != nil
        let front = chains["front"]!, back = chains["back"]!, side = chains["side"]!
        func place(_ x: Double, _ y: Double, _ wh: Double, _ dep: Double, _ w1: Double, _ w2: Double, _ f: Double) -> (Double, Double) {
            let bp = wh < 1 ? bodyOffset(x, y, P) : (0, 0)
            var X = x + bp.0, Y = y + bp.1
            if wh > 0 {
                let hp = headXform(x, y, dep, P)
                X = X * (1 - wh) + (hp.0 + neckBody.0) * wh
                Y = Y * (1 - wh) + (hp.1 + neckBody.1) * wh
            }
            if (w1 > 0 || w2 > 0) && sideOn {
                let sd = smooth(sideAt.0, sideAt.1, abs(x - A.head.cx) / A.head.rx), ff = f * (1 - sd), fs = f * sd
                let c0x = front[0].x * ff + side[0].x * fs + back[0].x * (1 - f), c0y = front[0].y * ff + side[0].y * fs + back[0].y * (1 - f)
                let c1x = front[1].x * ff + side[1].x * fs + back[1].x * (1 - f), c1y = front[1].y * ff + side[1].y * fs + back[1].y * (1 - f)
                X += c0x * w1 + c1x * w2; Y += c0y * w1 + c1y * w2
            } else if w1 > 0 || w2 > 0 {
                let c0x = front[0].x * f + back[0].x * (1 - f), c0y = front[0].y * f + back[0].y * (1 - f)
                let c1x = front[1].x * f + back[1].x * (1 - f), c1y = front[1].y * f + back[1].y * (1 - f)
                X += c0x * w1 + c1x * w2; Y += c0y * w1 + c1y * w2
            }
            return (X, Y)
        }
        var kw: [Double] = kfOff ? [] : keyWeights ?? keys.map { k in
            switch k.param {
            case .diag: return 0
            case .angleX: return min(2, max(0, (P.angleX * k.scale) / k.value))
            case .angleY: return min(2, max(0, (P.angleY * k.scale) / k.value))
            }
        }
        if let kfPair, !kfOff, keyWeights == nil {
            let u = kw
            for k in u.indices {
                let j = kfPair[k]
                if j < 0 || u[k] <= 0 || u[k] >= 1 { continue }
                let t = u[k], h10 = t * t * t - 2 * t * t + t
                kw[k] = 3 * t * t - 2 * t * t * t + 0.5 * h10 + t * t * t - t * t
                kw[j] -= 0.5 * h10
            }
        }
        let roll = P.angleZ * .pi / 180 * rig.roll * tuning.turn
        let g = tuning.gaze, gz = g >= 0 && g < 1 ? g : 1
        var chinDx = 0.0
        if rig.neck != nil {
            let cy = A.jaw?.chin ?? A.neckY
            let hp = headXform(A.head.cx, cy, 0, P), bp = bodyOffset(A.head.cx, cy, P)
            chinDx = hp.0 + neckBody.0 - (A.head.cx + bp.0)
        }
        let rc = cos(roll), rs = sin(roll)
        for L in layers {
            if !kfOff && !shown(L) { continue }
            let d = L.def, r = L.rest
            let n = r.count / 2
            let role = d.roleString
            let eyeSide = role.hasSuffix("_L") ? "L" : role.hasSuffix("_R") ? "R" : ""
            let isEye = role.hasPrefix("eye_") || role.hasPrefix("iris_") || role.hasPrefix("shine_")
            let open = eyeSide == "L" ? P.eyeLOpen : eyeSide == "R" ? P.eyeROpen : 1
            let squash = 0.12 + 0.88 * open
            let iris = role.hasPrefix("iris_")
            var ix = 0.0, iy = 0.0
            if iris, let range = d.range { ix = P.eyeBallX * range[0] * gz; iy = -P.eyeBallY * range[1] * gz }
            if chained && role.hasPrefix("shine_"), let range = d.range { ix = P.eyeBallX * range[0] * gz; iy = -P.eyeBallY * range[1] * gz }
            var nx = ix, nk = 0.0
            if irisNasal && ix != 0, let nz = nasal[eyeSide], ix * nz.sign > nz.room {
                let far = min(ix * nz.sign, nz.room + (1 - irisNasalNarrow) * nz.w)
                nk = -(far - nz.room) / nz.w; nx = nz.sign * nz.room - nk * nz.inner
            }
            let lidIris = iris && irisLid && d.pivot != nil && d.range != nil && (d.range![0] > 0 || d.range![1] > 0)
            if lidIris { iy += irisDrop * (1 - squash) * ((L.pivC ?? d.pivot![1]) - (d.y + d.h / 2)) }
            if iris { L.soft = min(1, hypot(ix, iy) + (lidIris ? (1 - squash) * d.h / 2 : 0)) }
            let tw = chained && role.hasPrefix("shine_") ? twinkle(time + (eyeSide == "R" ? 1.3 : 0)) : 1
            let tcx = d.x + d.w / 2, tcy = d.y + d.h / 2
            var rgx = 0.0, rgy = 0.0
            if let rigid = d.rigid { let hp = headXform(rigid[0], rigid[1], d.depth, P); rgx = hp.0 + neckBody.0; rgy = hp.1 + neckBody.1 }
            var o = [Float](); swap(&o, &L.out)
            if o.count != r.count { o = r }
            var ob: [Float]? = nil
            if L.outB != nil { ob = []; swap(&ob!, &L.outB!) }
            let wHead = L.wHead, dep = L.dep, wPhys1 = L.wPhys1, wPhys2 = L.wPhys2, wFront = L.wFront
            let browSide = L.browSide, browCap = L.browCap, wBrow = L.wBrow, wJaw = L.wJaw
            let pivY = L.pivY, wTwist = L.wTwist, wNeck = L.wNeck, fol = L.fol, folB = L.folB, alt = L.alt
            let skin = L.skin, altSkin = L.altSkin, kf = L.kf
            for i in 0..<n {
                var x = Double(r[2 * i]), y = Double(r[2 * i + 1])
                if tw != 1 { x = tcx + (x - tcx) * tw; y = tcy + (y - tcy) * tw }
                if isEye, let pivot = d.pivot {
                    let py = pivY.map { Double($0[i]) } ?? pivot[1]
                    x += nx + nk * Double(r[2 * i]); y += iy
                    if !lidIris || y > py { y = py + (y - py) * squash }
                }
                if browSide[i] >= 0 {
                    let v = browLift[Int(browSide[i])]
                    let sg: Double = v > 0 ? 1 : v < 0 ? -1 : 0
                    y -= sg * min(abs(v), Double(browCap[i])) * Double(wBrow[i])
                }
                if jawDrop > 0 && wJaw[i] > 0 { y += jawDrop * Double(wJaw[i]) }
                var pt: (Double, Double)
                if let rigid = d.rigid {
                    let vx = x - rigid[0], vy = y - rigid[1]
                    pt = (rgx + vx * rc - vy * rs, rgy + vx * rs + vy * rc)
                } else {
                    pt = place(x, y, Double(wHead[i]), Double(dep[i]), Double(wPhys1[i]), Double(wPhys2[i]), Double(wFront[i]))
                }
                if let skin { let so = skinOffset(skin, i); pt.0 += so.0; pt.1 += so.1 }
                var X = pt.0, Y = pt.1
                if let wTwist, wTwist[i] > 0 { X += chinDx * Double(wTwist[i]) }
                if let wNeck, wNeck[i] > 0 {
                    let a = roll * Double(wNeck[i]), c = cos(a), s = sin(a)
                    let nx2 = A.head.cx + neckBody.0, ny2 = A.neckY + neckBody.1, dx = X - nx2, dy = Y - ny2
                    X = nx2 + dx * c - dy * s; Y = ny2 + dx * s + dy * c
                }
                let c = fol.map { Double($0[i]) } ?? 0, cB = folB.map { Double($0[i]) } ?? 0
                if c > 0 || cB > 0, let al = alt {
                    let k = 5 * i
                    let X0 = X, Y0 = Y
                    var q = place(x, y, Double(al[k + 1]), Double(al[k]), Double(al[k + 2]), Double(al[k + 3]), Double(al[k + 4]))
                    if let altSkin { let so = skinOffset(altSkin, i); q.0 += so.0; q.1 += so.1 }
                    X += (q.0 - X0) * c; Y += (q.1 - Y0) * c
                    if ob != nil { ob![2 * i] = Float(X0 + (q.0 - X0) * cB); ob![2 * i + 1] = Float(Y0 + (q.1 - Y0) * cB) }
                } else if ob != nil { ob![2 * i] = Float(X); ob![2 * i + 1] = Float(Y) }
                if let kf {
                    var dx = 0.0, dy = 0.0
                    for k in 0..<min(kw.count, kf.count) {
                        if let f = kf[k], kw[k] != 0 { dx += kw[k] * Double(f[2 * i]); dy += kw[k] * Double(f[2 * i + 1]) }
                    }
                    if dx != 0 || dy != 0 {
                        let a = roll * Double(wHead[i]), c = cos(a), s = sin(a)
                        let ox = dx * c - dy * s, oy = dx * s + dy * c
                        X += ox; Y += oy
                        if ob != nil { ob![2 * i] += Float(ox); ob![2 * i + 1] += Float(oy) }
                    }
                }
                o[2 * i] = Float(X); o[2 * i + 1] = Float(Y)
            }
            swap(&o, &L.out)
            if ob != nil { swap(&ob!, &L.outB!) }
        }
    }

    // MARK: Draw list

    /// the frame for a drawing buffer of w x h pixels: the view transform, the eyes' mask pass and the draw commands
    public func frame(width w: Double, height h: Double) -> PuppetFrame {
        guard let model else { return PuppetFrame(sx: 1, sy: 1, ox: 0, oy: 0, maskEyes: [], commands: []) }
        let MW = model.canvas.w, MH = model.canvas.h
        let V = view, M = move, hd = model.anchors.head
        func offY(_ k: Double, _ y: Double) -> Double { (focusHead ? -(hd.cy + hd.ry * 0.15) * (2 * k) / h : -MH * k / h) + panY - 2 * y }
        func bottom(_ k: Double, _ oy: Double) -> Double { -(MH * (2 * k) / h + oy) }
        let base = min(w / MW, h / MH) * zoom
        let s = base * V.s * M.s
        let sx = (2 * s) / w, sy = (2 * s) / h
        var oy = offY(s, V.y + M.y)
        if cutBottom {
            let allowed = max(bottom(base * V.s, offY(base * V.s, V.y)), -1)
            oy += max(0, bottom(s, oy) - allowed)
        }
        let ox = (focusHead ? -hd.cx * sx : -MW * s / w) + 2 * (V.x + M.x)
        lastView = (sx, sy, ox, oy, w, h)

        // the mask pass: the whites of the eyes whose iris sits off them (softIris)
        var maskEyes: [(layer: Int, channel: Int)] = []
        for L in layers { L.maskCh = -1 }
        if softIris {
            for L in layers {
                guard L.def.roleString.hasPrefix("iris_"), let clip = L.def.clip, let parent = byId[clip], parent.hasMask, L.soft > 0,
                      parent.maskCh < 0, maskEyes.count < 4 else { continue }
                if hidden.contains(L.def.id) || hidden.contains(parent.def.id) { continue }
                parent.maskCh = maskEyes.count
                maskEyes.append((parent.index, parent.maskCh))
            }
        }

        var cmds: [DrawCommand] = []
        cmds.reserveCapacity(layers.count + 8)
        func draw(_ L: PuppetLayer, _ tex: DrawCommand.Texture, _ alpha: Double, _ verts: DrawCommand.Vertices = .out, cut: Float = 0,
                  mode: Int32 = 0, channel: Int = 0, soft: Double = 0, stencil: DrawCommand.Stencil = .none) {
            cmds.append(DrawCommand(layer: L.index, texture: tex, alpha: Float(alpha), vertices: verts, cut: cut, mode: mode,
                                    maskChannel: channel, soft: Float(soft), stencil: stencil))
        }
        let P = params
        func drawMouth(_ L: PuppetLayer) {
            let m = min(1, max(0, P.mouthOpen)), f = min(mouthFrame, L.frameCount - 1)
            let py = L.def.pivot?[1] ?? L.def.y
            let k = frameKind[f] == "half" ? 0.88 + 0.12 * frameEase(f, m) : 0.9 + 0.1 * frameEase(f, m)
            var verts: DrawCommand.Vertices = .out
            if f > 0 && f != vis["shut"] {
                var v = L.out
                let fade: [Float]? = chinFollow ? L.wJaw : nil
                for i in stride(from: 1, to: v.count, by: 2) {
                    v[i] += Float((Double(L.rest[i]) - py) * (k - 1) * (fade.map { 1 - Double($0[i >> 1]) } ?? 1))
                }
                verts = .custom(v)
            }
            draw(L, .frame(f), 1, verts)
        }
        let lastExpr = talkLeft > 0 ? (layers.lastIndex { $0.def.role == "expr" } ?? -1) : -1
        var deferred: PuppetLayer?
        let lastBrow = layers.lastIndex { $0.def.id == "brows" || $0.def.role == "expr_brows" } ?? -1
        var newBrows = lastBrow < 0
        func drawNewBrows() {
            newBrows = true
            if headHidden { return }
            for E in layers where E.hasBrowTex && E.def.role == "expr" && !hidden.contains(E.def.id) {
                let a = exprAlpha(E.def)
                if a > 0.01 { draw(E, .browTex, a, .outB) }
            }
        }
        var ref = 0
        for (li, L) in layers.enumerated() {
            let d = L.def, role = d.roleString
            if let dl = deferred, li > lastExpr { drawMouth(dl); deferred = nil }
            if !newBrows && li > lastBrow { drawNewBrows() }
            if hidden.contains(d.id) || (d.group == .body ? bodyHidden : headHidden) { continue }
            if (role == "hole" || role == "edge" || role == "edge_wide") && !masks { continue }
            if role == "mouth" && L.frameCount >= 3 {
                if li < lastExpr { deferred = L } else { drawMouth(L) }
                continue
            }
            if role == "expr" {
                let a = exprAlpha(d)
                if a > 0.01 { draw(L, talkLeft > 0 && L.hasTalk ? .talk : .main, a) }
                continue
            }
            if role == "expr_brows" {
                let a = exprAlpha(d)
                if a > 0.01 { draw(L, .main, a) }
                continue
            }
            if d.id == "brows" {
                var fade = 0.0
                for E in layers where E.def.role == "expr" && E.def.brows == "redrawn" && !hidden.contains(E.def.id) { fade = max(fade, exprAlpha(E.def)) }
                if fade < 0.99 { draw(L, .main, 1 - fade) }
                continue
            }
            if role.hasPrefix("lid_") {
                let open = role == "lid_L" ? P.eyeLOpen : P.eyeROpen
                let a = 1 - smooth(0.05, 0.35, open)
                if a > 0.01 { draw(L, .main, a) }
                continue
            }
            if role.hasPrefix("eye_") {
                let open = role == "eye_L" ? P.eyeLOpen : P.eyeROpen
                draw(L, .main, smooth(0.02, 0.2, open))
                L.stencilRef = 0
                if L.hasMask && L.maskCh < 0 {
                    ref = (ref % 250) + 1
                    L.stencilRef = ref
                    draw(L, .mask, 1, cut: 0.5, stencil: .write(UInt8(ref)))
                }
                continue
            }
            if role == "blush" {
                var a = 0.0
                for (k, v) in d.blush ?? [:] { a += v * exprValue(k) }
                if a > 0.01 { draw(L, .main, min(1, a)) }
                continue
            }
            if role.hasPrefix("iris_") || role.hasPrefix("shine_") {
                let parent = d.clip.flatMap { byId[$0] }
                let open = role.hasSuffix("_L") ? P.eyeLOpen : P.eyeROpen
                if let parent, parent.maskCh >= 0 {
                    draw(L, .main, smooth(0.02, 0.2, open), mode: 2, channel: parent.maskCh, soft: L.soft)
                } else if let parent, parent.stencilRef > 0 {
                    draw(L, .main, smooth(0.02, 0.2, open), stencil: .test(UInt8(parent.stencilRef)))
                }
                continue
            }
            let ma = d.show != nil || d.hide != nil ? moodAlpha(d) : 1
            if ma > 0.01 { draw(L, .main, ma) }
        }
        if let dl = deferred { drawMouth(dl) }
        if !newBrows { drawNewBrows() }
        return PuppetFrame(sx: Float(sx), sy: Float(sy), ox: Float(ox), oy: Float(oy), maskEyes: maskEyes, commands: cmds)
    }

    /// a point on the view (points from its top-left, in a view `size` points large) in model px, as the last frame drew it
    public func viewToModel(_ px: Double, _ py: Double, viewWidth: Double, viewHeight: Double) -> (Double, Double) {
        let v = lastView
        let cx = (2 * px) / max(1, viewWidth) - 1, cy = (2 * py) / max(1, viewHeight) - 1
        return ((cx - v.ox) / v.sx, (cy - v.oy) / v.sy)
    }

    /// a flick at model point (x, y): every chain passing near it is thrown. Returns how many chains it moved
    @discardableResult public func poke(_ x: Double, _ y: Double, strength: Double = 1) -> Int {
        var hit = 0
        for C in chainRuns {
            let R = C.R, m = R.count / 2, reach = 1.5 * (C.def.sigma ?? 40) + 20
            var near = Double.infinity
            for j in 0..<m { near = min(near, hypot(R[2 * j] - x, R[2 * j + 1] - y)) }
            if near > reach { continue }
            hit += 1
            let side: Double = x < R[0] ? 1 : -1
            for j in 1..<m {
                let k = (1 - near / reach) * C.s[j] * 9 * strength
                C.q[2 * j] -= side * k; C.q[2 * j + 1] += k * 0.3
            }
        }
        return hit
    }

    /// springs back to rest
    public func resetPhysics() {
        for C in chainRuns {
            C.p = C.R; C.q = C.R
            C.disp = [Double](repeating: 0, count: C.disp.count); C.beta = [Double](repeating: 0, count: C.beta.count)
            C.started = false; C.moving = false
        }
        for k in chains.keys { chains[k] = [Spring(), Spring()] }
        lastHead = (0, 0, 0)
        drive.started = false
        body = (0, 0)
        bust = (0, 0, 0, 0, 0, 0)
    }

    /// the head ellipse in model px, and the canvas size: what the idle motion's pointer follow needs
    public var headInfo: (cx: Double, cy: Double, rx: Double, ry: Double)? {
        guard let h = model?.anchors.head else { return nil }
        return (h.cx, h.cy, h.rx, h.ry)
    }
}
