#if canImport(Metal) && canImport(SwiftUI)
import Combine
import CoreGraphics
import Foundation
import LivLivCore
import Metal
import QuartzCore
import SwiftUI

public struct ExpressionItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let label: String
}

/// what to show about the loaded character: its name, where it comes from, who made it and on what terms. Labels are
/// English keys the app's String Catalog translates; a value is translated too when `translated` says so (else it is
/// the file's own text: a name, a path, a licence id)
public struct CharacterInfo: Sendable {
    public struct Row: Sendable, Hashable {
        public let label: String
        public let value: String
        public let translated: Bool
        public init(_ label: String, _ value: String, translated: Bool = false) { self.label = label; self.value = value; self.translated = translated }
    }
    public var rows: [Row] = []
}

/// a loaded thing that moved off the main thread to be built (it is used by one thread at a time)
struct Handoff<T>: @unchecked Sendable { let value: T }

/// One character on stage, whatever it is (Player / BodyPlayer in index.ts and body.ts): it loads LivLiv models,
/// PNGTubers and VRMs, puts the pose together each frame (PoseComposer), moves the character and draws it.
@MainActor
public final class CharacterStage: ObservableObject {
    public enum Content {
        case none
        case puppet(Puppet, PuppetGPU)
        case png(LoadedPNG, [String: MTLTexture])
        case vrm(VRMRig, [Int: CGImage])
    }
    @Published public private(set) var title = ""
    @Published public private(set) var kind: CharacterSource.Kind?
    @Published public private(set) var expressions: [ExpressionItem] = []
    @Published public private(set) var currentExpression: String?
    @Published public private(set) var loading = false
    @Published public private(set) var info = CharacterInfo()
    /// changes when a new VRM is in, so its view rebuilds its scene
    @Published public private(set) var vrmGeneration = 0
    @Published public var away = false { didSet { composer.actions.away = away } }

    public let composer = PoseComposer()
    public private(set) var content: Content = .none
    public var view = (x: 0.0, y: 0.0, zoom: 1.0)
    public var maxPixelRatio = 2.0
    public var background = SIMD4<Double>(0, 0, 0, 0)
    public private(set) var renderer: MetalRenderer?
    public private(set) var lastPose = Params()
    public private(set) var lastMove = (x: 0.0, y: 0.0, s: 1.0)
    private var mark: (kind: Watermark.Kind, text: String?, center: Bool) = (.none, nil, true)
    private var markCache: (key: String, texture: MTLTexture)?
    private var loadToken = 0

    public init() {
        renderer = try? MetalRenderer()
    }

    public var isEmpty: Bool { if case .none = content { return true }; return false }

    // MARK: Loading

    /// loads whatever `source` is; the character before stays until this one is ready, and stays if it fails
    public func load(_ source: CharacterSource, credit: String? = nil, featured: Bool = false) async throws {
        loadToken += 1
        let token = loadToken
        loading = true
        defer { if token == loadToken { loading = false } }
        let lang = uiLanguage()
        switch source.kind {
        case .livliv, .livlivPackage:
            let url = source.url, isPackage = source.kind == .livlivPackage
            let built = try await Task.detached(priority: .userInitiated) { () throws -> Handoff<(LoadedModel, Puppet)> in
                let files = isPackage ? try PackageFiles.package(try Data(contentsOf: url, options: .mappedIfSafe)) : PackageFiles(folder: url)
                let loaded = try CharacterLoader.loadModel(files, lang: lang)
                let p = Puppet()
                try p.load(loaded.model, images: loaded.images, keyforms: loaded.keyforms)
                return Handoff(value: (loaded, p))
            }.value.value
            guard token == loadToken else { return }
            try install(built.0, built.1, credit: credit, featured: featured, source: source)
        case .png:
            let url = source.url
            let png = try await Task.detached(priority: .userInitiated) { Handoff(value: try CharacterLoader.loadPNG(folder: url)) }.value.value
            guard token == loadToken else { return }
            guard let r = renderer else { throw LivLivError(.noMetal, "LivLiv: this device has no Metal GPU") }
            var tex: [String: MTLTexture] = [:]
            for (k, d) in png.pictures { tex[k] = r.texture(d) }
            content = .png(png, tex)
            composer.bodyRollShare = 0
            composer.actions.bodyYawShare = 0
            composer.actions.halfBody = false
            title = png.name
            kind = .png
            setExpressions([])
            mark = (.none, nil, true)
            info = CharacterInfo(rows: [.init("Type", "PNGTuber"), .init("Folder", source.url.lastPathComponent),
                                        .init("Pictures", png.pictures.keys.sorted().joined(separator: ", "))])
            composer.neutral()
        case .vrm:
            let url = source.url
            let built = try await Task.detached(priority: .userInitiated) { () throws -> Handoff<(VRMRig, [Int: CGImage])> in
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                let rig = try VRMRig(data: data, fileName: url.lastPathComponent)
                var images: [Int: CGImage] = [:]
                for (i, im) in rig.doc.images.enumerated() where !im.data.isEmpty {
                    if let d = try? ImageDecoder.decode(im.data, name: "image \(i)", maxSide: VRMLimits.textureSide) { images[i] = d.cgImage }
                }
                return Handoff(value: (rig, images))
            }.value.value
            guard token == loadToken else { return }
            content = .vrm(built.0, built.1)
            composer.bodyRollShare = 0
            composer.actions.bodyYawShare = 0
            composer.actions.halfBody = false
            title = built.0.name
            kind = .vrm
            setExpressions([ExpressionItem(id: "smile", label: localizedSmile())] + built.0.expressions.map { ExpressionItem(id: $0.id, label: $0.label) })
            mark = (.none, nil, true)
            let t = built.0.info.terms
            var rows: [CharacterInfo.Row] = [.init("Type", "VRM \(t.spec == "0" ? "0.x" : "1.0")"), .init("File", source.url.lastPathComponent)]
            if let a = t.author { rows.append(.init("Author", a)) }
            if let l = t.licenseName ?? t.licenseURL { rows.append(.init("License", l)) }
            if let u = t.use { rows.append(.init("Permission", u)) }
            if let c = t.commercial { rows.append(.init("Commercial use", c)) }
            if let r = t.redistribution { rows.append(.init("Redistribution", r ? "Allowed" : "Not allowed", translated: true)) }
            if let m = t.modification { rows.append(.init("Modification", m)) }
            info = CharacterInfo(rows: rows)
            composer.neutral()
            vrmGeneration += 1
        }
    }

    private func install(_ loaded: LoadedModel, _ p: Puppet, credit: String?, featured: Bool, source: CharacterSource) throws {
        guard let r = renderer else { throw LivLivError(.noMetal, "LivLiv: this device has no Metal GPU") }
        let gpu = try PuppetGPU(renderer: r, puppet: p, textures: loaded.textures)
        let m = loaded.model
        content = .puppet(p, gpu)
        composer.bodyRollShare = m.rig.body.roll * m.tuning.turn
        composer.actions.bodyYawShare = m.rig.body.yaw * m.tuning.turn
        composer.actions.halfBody = p.cutBottom
        title = m.name.isEmpty ? source.name : m.name
        kind = source.kind
        var ex = (m.expressions ?? []).map { ExpressionItem(id: $0.id, label: pickLabel($0.labels ?? [langOf($0.label): $0.label], lang: uiLanguage(), fallback: $0.id)) }
        if m.expressions == nil && m.layers.contains(where: { $0.id == "expr_smile" }) { ex = [ExpressionItem(id: "smile", label: localizedSmile())] }
        setExpressions(ex)
        mark = (m.markKind, m.watermark, m.markCenter)
        markCache = nil
        var rows: [CharacterInfo.Row] = [.init("Type", "LivLiv model", translated: true), .init("Format", "\(m.format) v\(m.version)"), .init("Name", m.name),
                                          .init("Canvas", "\(Int(m.canvas.w)) × \(Int(m.canvas.h))"), .init("Layers", "\(m.layers.count)")]
        if let a = m.meta?.authorName { rows.append(.init("Author", a)) }
        if let l = m.meta?.licenseID { rows.append(.init("License", l)) }
        if let u = m.meta?.licenseURL { rows.append(.init("License URL", u)) }
        if let g = m.meta?.generatorName, !g.isEmpty { rows.append(.init("Made with", g)) }
        if featured { rows.append(.init("Credit", "Characters: LivLiv (livliv.ai)")) }
        if let credit { rows.append(.init("Original credit", credit)) }
        switch m.markKind {
        case .livliv: rows.append(.init("Watermark", "LivLiv mark (asked for by the package; a license condition)", translated: true))
        case .text: rows.append(.init("Watermark", m.watermark ?? ""))
        case .none: rows.append(.init("Watermark", "None", translated: true))
        }
        for w in loaded.warnings { rows.append(.init("Warning", w)) }
        info = CharacterInfo(rows: rows)
        composer.neutral()
    }

    /// an English key the app's String Catalog translates (as are a VRM's Happy, Angry, Sad, Relaxed, Surprised)
    private func localizedSmile() -> String { "Smile" }

    private func setExpressions(_ ex: [ExpressionItem]) {
        expressions = ex
        composer.available = ex.map(\.id)
        currentExpression = nil
    }

    public func unload() {
        loadToken += 1
        content = .none; title = ""; kind = nil; setExpressions([]); info = CharacterInfo(); mark = (.none, nil, true)
    }

    // MARK: Control

    public func setExpression(_ id: String?) {
        let id = id == currentExpression ? nil : id
        if composer.setExpression(id) || id == nil { currentExpression = id }
    }
    public func act(_ a: ActionID) { composer.actions.play(a) }

    /// a pointer over the view: u, v shares from its top-left
    public func pointer(u: Double, v: Double, on: Bool) {
        composer.idler.pointer(u: u, v: v, head: headOnView(), on: on)
    }
    public func pointerLeft() { composer.idler.leave() }

    /// a tap on the view: a flick at that point of the character (its swinging pieces)
    public func tap(u: Double, v: Double, viewSize: CGSize) {
        if case .puppet(let p, _) = content {
            let m = p.viewToModel(u * Double(viewSize.width), v * Double(viewSize.height), viewWidth: Double(viewSize.width), viewHeight: Double(viewSize.height))
            if p.poke(m.0, m.1) == 0 { composer.actions.play(.nod) }
        } else { composer.actions.play(.hop) }
    }

    public func headOnView() -> HeadOnView {
        switch content {
        case .puppet(let p, _):
            guard let hd = p.headInfo, p.lastView.w > 1 else { return HeadOnView(x: 0.5, y: 0.3, rx: 0.12, ry: 0.1) }
            let v = p.lastView
            return HeadOnView(x: (hd.cx * v.sx + v.ox + 1) / 2, y: (hd.cy * v.sy + v.oy + 1) / 2, rx: abs(hd.rx * v.sx) / 2, ry: abs(hd.ry * v.sy) / 2)
        case .png: return HeadOnView(x: 0.5, y: 0.26, rx: 0.16, ry: 0.13)
        default: return HeadOnView(x: 0.5, y: 0.25, rx: 0.14, ry: 0.1)
        }
    }

    // MARK: Each frame

    /// puts the pose together and moves the character `dt` seconds on
    public func tick(_ dtIn: Double) {
        let dt = min(0.05, max(0, dtIn))
        if isEmpty { return }
        let pose = composer.compose(dt)
        lastPose = pose.params; lastMove = pose.move
        switch content {
        case .puppet(let p, _):
            p.params = pose.params
            p.expr = pose.expr
            p.view = (view.x, view.y, view.zoom)
            p.move = pose.move
            p.update(dt)
        case .vrm(let rig, _):
            rig.update(params: pose.params, expr: pose.expr, dt: dt)
        default: break
        }
    }

    /// draws the frame into `drawable` (w x h pixels; `scale` pixels per point)
    public func render(into drawable: CAMetalDrawable, scale: Double) {
        guard let r = renderer else { return }
        let tex = drawable.texture, w = tex.width, h = tex.height
        switch content {
        case .puppet(let p, let gpu):
            let f = p.frame(width: Double(w), height: Double(h))
            r.draw(to: tex, background: background, frame: f, gpu: gpu, puppet: p, overlay: markTexture(w, h, scale), present: drawable)
        case .png(let png, let textures):
            var extra: [MetalRenderer.Item] = []
            if let q = pngQuad(png, w, h), let t = textures[q.0], let it = r.quadItem(corners: q.1, width: w, height: h, texture: t) {
                extra.append(it)
            }
            r.draw(to: tex, background: background, frame: nil, gpu: nil, puppet: nil, extra: extra, present: drawable)
        default:
            r.draw(to: tex, background: background, frame: nil, gpu: nil, puppet: nil, present: drawable)
        }
    }

    /// png.ts render: one picture by mouth and eyes, fitted into the view standing on its bottom, swaying with the head
    private func pngQuad(_ png: LoadedPNG, _ wI: Int, _ hI: Int) -> (String, [SIMD2<Float>])? {
        let P = lastPose, move = lastMove, w = Double(wI), h = Double(hI)
        let talk = P.mouthOpen > 0.18, shut = min(P.eyeLOpen, P.eyeROpen) < 0.35
        let x = png.pictures
        let slot = shut && talk ? (x["blink-open"] != nil ? "blink-open" : x["blink"] != nil ? "blink" : "open")
            : shut ? (x["blink"] != nil ? "blink" : "closed") : talk ? "open" : "closed"
        guard let img = x[slot] else { return nil }
        let s = move.s * view.zoom
        let k = min(w / Double(img.width), h / Double(img.height)) * s, dw = Double(img.width) * k, dh = Double(img.height) * k
        let dx = (P.angleX / 30) * 0.025 * w + (P.bodyX / 10) * 0.015 * w + (move.x + view.x) * w * 0.5
        let dy = (P.angleY / 30) * 0.012 * h + P.breath * 0.006 * h + (move.y + view.y) * h * 0.5
        let a = (P.angleZ * 0.25 + P.bodyZ * 0.4) * .pi / 180, c = cos(a), sn = sin(a)
        let ox = w / 2 + dx, oy = h - dy
        func pt(_ px: Double, _ py: Double) -> SIMD2<Float> { SIMD2(Float(ox + px * c - py * sn), Float(oy + px * sn + py * c)) }
        return (slot, [pt(-dw / 2, -dh), pt(dw / 2, -dh), pt(-dw / 2, 0), pt(dw / 2, 0)])
    }

    private func markTexture(_ w: Int, _ h: Int, _ scale: Double) -> MTLTexture? {
        guard mark.kind != .none, let r = renderer else { return nil }
        let ms = CACurrentMediaTime() * 1000
        let eye = mark.kind == .livliv ? Int((WatermarkPainter.eyeOpen(ms) * 10).rounded()) : 0
        let key = "\(w)x\(h):\(scale):\(eye):\(mark.kind):\(mark.center):\(mark.text ?? "")"
        if let c = markCache, c.key == key { return c.texture }
        guard let cg = WatermarkPainter.render(kind: mark.kind, text: mark.text, center: mark.center, width: w, height: h, ms: ms, pixelsPerPoint: scale),
              let d = try? ImageDecoder.render(cg, name: "mark"), let t = r.texture(d, mipmapped: false) else { return nil }
        markCache = (key, t)
        return t
    }
}
#endif
