import XCTest
@testable import LivLivCore

final class LivLivCoreTests: XCTestCase {
    static let featured = ["char06", "char07", "d01", "d02", "d03", "d03ft", "k01", "k02", "p01", "p02", "p03", "q02", "q03", "s01",
                           "v01", "v03", "v04", "v05", "v06", "v07", "w01"]

    func fixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Fixtures/\(name)", withExtension: nil) ?? Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
    func model(_ id: String) throws -> ModelDef { try readModel(try parseJSON(try fixture("\(id).model.json")), lang: "ko") }

    /// stand-in pictures for a layer: opaque inside an ellipse filling the box; the closed lid draws a dark arc
    func images(for m: ModelDef) -> [LayerImages] {
        func picture(_ L: LayerDef, dark: Bool = false) -> RGBAImage {
            let w = max(1, Int(L.w)), h = max(1, Int(L.h))
            var px = [UInt8](repeating: 0, count: w * h * 4)
            for y in 0..<h {
                for x in 0..<w {
                    let u = (Double(x) + 0.5) / Double(w) * 2 - 1, v = (Double(y) + 0.5) / Double(h) * 2 - 1
                    guard u * u + v * v <= 1 else { continue }
                    let k = 4 * (y * w + x)
                    let lash = dark && abs(v - 0.2 * u * u) < 0.15
                    px[k] = lash ? 20 : 220; px[k + 1] = lash ? 20 : 200; px[k + 2] = lash ? 20 : 190; px[k + 3] = 255
                }
            }
            return RGBAImage(width: w, height: h, pixels: px)
        }
        return m.layers.map { L in
            LayerImages(main: picture(L, dark: (L.role ?? "").hasPrefix("lid_")), frames: (L.frames ?? []).map { _ in picture(L) },
                        mask: L.mask.map { _ in picture(L) }, talk: L.talk.map { _ in picture(L) }, brows: L.browTex.map { _ in picture(L) })
        }
    }

    func testEveryFeaturedModelReads() throws {
        for id in Self.featured + ["example-k01"] {
            let m = try model(id)
            XCTAssertFalse(m.layers.isEmpty, id)
            XCTAssertGreaterThan(m.canvas.w, 0, id)
            if id != "example-k01" { XCTAssertEqual(m.markKind, .livliv, id); XCTAssertFalse(m.markCenter, id) }
        }
        let k = try model("k01")
        XCTAssertEqual(k.format, "livliv-model")
        XCTAssertTrue(k.expressions?.contains { $0.id == "smile" } ?? false)
    }

    func testFormatRefusesWhatItShould() {
        XCTAssertThrowsError(try readModel([1, 2])) { XCTAssertEqual(($0 as? LivLivError)?.code, .notAModel) }
        XCTAssertThrowsError(try readModel(["format": "livliv-model", "version": 9])) { XCTAssertEqual(($0 as? LivLivError)?.code, .newerFormat) }
        XCTAssertThrowsError(try readModel(["format": "livliv-model", "version": 4, "requires": ["warp"]])) { XCTAssertEqual(($0 as? LivLivError)?.code, .missingFeature) }
        XCTAssertThrowsError(try readModel(["format": "other"])) { XCTAssertEqual(($0 as? LivLivError)?.code, .notAModel) }
    }

    func testPickLabel() {
        let l = ["zh": "笑", "zh-Hant": "笑", "en": "Smile", "ja": "笑顔"]
        XCTAssertEqual(pickLabel(l, lang: "ja-JP", fallback: "x"), "笑顔")
        XCTAssertEqual(pickLabel(l, lang: "ko-KR", fallback: "x"), "Smile")
        XCTAssertEqual(pickLabel(l, lang: "zh-TW", fallback: "x"), "笑")
        XCTAssertEqual(langOf("ほほえみ"), "ja"); XCTAssertEqual(langOf("미소"), "ko"); XCTAssertEqual(langOf("smile"), "en")
    }

    func testPuppetPlaysEveryFeaturedModel() throws {
        for id in Self.featured {
            let m = try model(id)
            let kf = id == "d03ft" ? KeyformFile.read(try fixture("d03ft.keyforms.json")) : nil
            if id == "d03ft" { XCTAssertNotNil(kf, "keyforms") }
            let p = Puppet()
            try p.load(m, images: images(for: m), keyforms: kf)
            let c = PoseComposer(seed: 7)
            c.available = (m.expressions ?? []).map(\.id)
            var sawStencil = false, sawFrame = false
            for i in 0..<240 {
                if i == 60 { c.setExpression(m.expressions?.first?.id) }
                if i == 100 { c.actions.play(.shake) }
                c.params.mouthOpen = i % 30 < 15 ? 0.8 : 0
                let pose = c.compose(1.0 / 60)
                p.params = pose.params
                p.expr = pose.expr.filter { $0.key != "smile" }
                p.move = pose.move
                p.update(1.0 / 60)
                let f = p.frame(width: 1080, height: 1440)
                XCTAssertFalse(f.commands.isEmpty, id)
                if f.commands.contains(where: { if case .write = $0.stencil { return true }; return false }) { sawStencil = true }
                if f.commands.contains(where: { if case .frame(let k) = $0.texture { return k > 0 }; return false }) { sawFrame = true }
            }
            for L in p.layers { XCTAssertTrue(L.out.allSatisfy { $0.isFinite }, "\(id) \(L.def.id)") }
            XCTAssertTrue(sawStencil, "\(id): no iris stencil")
            XCTAssertTrue(sawFrame, "\(id): the mouth never opened")
        }
    }

    func testKeyformsMoveTheTurn() throws {
        let m = try model("d03ft")
        let kf = try XCTUnwrap(KeyformFile.read(try fixture("d03ft.keyforms.json")))
        func turned(_ k: KeyformFile?) throws -> [Float] {
            let p = Puppet()
            try p.load(m, images: images(for: m), keyforms: k)
            p.params.angleX = 25
            p.update(1.0 / 60)
            return p.layers.first { $0.def.id == "face" }?.out ?? p.layers[0].out
        }
        let a = try turned(nil), b = try turned(kf)
        XCTAssertEqual(a.count, b.count)
        XCTAssertGreaterThan(zip(a, b).map { abs($0 - $1) }.max() ?? 0, 0.5)
    }

    /// the tilt action tilts the head on the neck: the torso's own lean (rig.body.roll) is cancelled
    func testTiltLeavesTheBodyStill() throws {
        let m = try model("k01")
        let p = Puppet()
        try p.load(m, images: images(for: m))
        let a = ActionPlayer()
        a.bodyRollShare = m.rig.body.roll * m.tuning.turn
        a.play(.tilt)
        var bodyMove = 0.0, faceMove = 0.0
        for _ in 0..<54 {
            var P = Params()
            for (k, v) in a.update(1.0 / 60) { P[k] += v }
            p.params = P
            p.update(1.0 / 60)
            let body = p.layers.first { $0.def.id == "body" }!, face = p.layers.first { $0.def.id == "face" }!
            func mean(_ L: PuppetLayer) -> Double { zip(L.out, L.rest).reduce(0) { $0 + abs(Double($1.0 - $1.1)) } / Double(L.rest.count) }
            bodyMove = max(bodyMove, mean(body)); faceMove = max(faceMove, mean(face))
        }
        XCTAssertLessThan(bodyMove, 3, "the torso stays put")
        XCTAssertGreaterThan(faceMove, 8, "the head tilts")
    }

    func testPokeThrowsAChain() throws {
        let m = try model("d03ft")
        let p = Puppet()
        try p.load(m, images: images(for: m))
        guard let chain = m.rig.chains.first else { return }
        XCTAssertGreaterThan(p.poke(chain.points[1][0], chain.points[1][1]), 0)
    }

    func testZipStoredRoundTrip() throws {
        let files: [(String, Data)] = [("pkg/model.json", Data("{}".utf8)), ("pkg/textures/a.webp", Data([1, 2, 3])), ("__MACOSX/._x", Data([9]))]
        var out = [UInt8](), central = [UInt8]()
        func w16(_ b: inout [UInt8], _ v: Int) { b.append(UInt8(v & 255)); b.append(UInt8(v >> 8 & 255)) }
        func w32(_ b: inout [UInt8], _ v: Int) { w16(&b, v & 0xffff); w16(&b, v >> 16) }
        for (name, d) in files {
            let off = out.count, n = [UInt8](name.utf8)
            w32(&out, 0x04034b50); for v in [20, 0, 0, 0, 0] { w16(&out, v) }
            w32(&out, 0); w32(&out, d.count); w32(&out, d.count); w16(&out, n.count); w16(&out, 0)
            out += n; out += [UInt8](d)
            w32(&central, 0x02014b50); for v in [20, 20, 0, 0, 0, 0] { w16(&central, v) }
            w32(&central, 0); w32(&central, d.count); w32(&central, d.count)
            for v in [n.count, 0, 0, 0, 0] { w16(&central, v) }
            w32(&central, 0); w32(&central, off); central += n
        }
        let cdOff = out.count
        out += central
        w32(&out, 0x06054b50); for v in [0, 0, files.count, files.count] { w16(&out, v) }
        w32(&out, central.count); w32(&out, cdOff); w16(&out, 0)
        let zipData = Data(out)
        XCTAssertTrue(Zip.isZip(zipData))
        let got = try Zip.unzip(zipData)
        XCTAssertEqual(Set(got.keys), ["pkg/model.json", "pkg/textures/a.webp"])
        XCTAssertEqual(got["pkg/textures/a.webp"], Data([1, 2, 3]))
    }

    func testLipSyncAnalysis() {
        let sr = 24000.0
        var x = [Float](repeating: 0, count: Int(sr))
        for i in 0..<x.count where i > 6000 && i < 18000 { x[i] = Float(0.5 * sin(2 * Double.pi * 300 * Double(i) / sr)) }
        let env = SpeechTrack.envelope(x, sampleRate: sr)
        XCTAssertEqual(env.count, 100)
        XCTAssertGreaterThan(env[50], 0.3)
        XCTAssertLessThan(env[5], 0.05)
        let vowels = SpeechTrack.vowels(x, sampleRate: sr, envelope: env)
        XCTAssertLessThan(vowels[60], -0.3, "a low tone is round")
        let meter = VoiceMeter()
        var level = 0.0
        for k in 0..<30 {
            let chunk = (0..<800).map { i in Float(0.3 * sin(2 * Double.pi * 650 * Double(k * 800 + i) / 48000)) }
            chunk.withUnsafeBufferPointer { meter.push($0, sampleRate: 48000) }
            level = meter.read(1.0 / 60)
        }
        XCTAssertGreaterThan(level, 0.5)
    }

    func testIdleAndActionsStayInRange() {
        let c = PoseComposer(seed: 3)
        c.actions.play(.nod); c.actions.play(.hop)
        for i in 0..<1200 {
            if i == 400 { c.actions.away = true }
            if i == 800 { c.actions.away = false }
            c.idler.pointer(u: 0.7, v: 0.3, head: HeadOnView(x: 0.5, y: 0.3, rx: 0.12, ry: 0.1), on: i % 300 < 200)
            let pose = c.compose(1.0 / 60).params
            for k in ParamKey.allCases { XCTAssertTrue(k.range.contains(pose[k]), "\(k) \(pose[k])") }
        }
    }

    func testTinyVRMs() throws {
        for (file, spec) in [("tiny1.vrm", "1"), ("tiny0.vrm", "0")] {
            let rig = try VRMRig(data: try fixture(file), fileName: file)
            XCTAssertEqual(rig.info.spec, spec)
            XCTAssertNotNil(rig.info.humanBones["head"])
            XCTAssertTrue(rig.expressions.contains { $0.id == "happy" }, file)
            var P = Params(); P.angleX = 20; P.mouthOpen = 1; P.eyeBallX = 1
            for _ in 0..<30 { rig.update(params: P, expr: ["sad": 1], dt: 1.0 / 60) }
            XCTAssertTrue(rig.drawables.allSatisfy { $0.positions.allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite } })
            XCTAssertGreaterThan(rig.frame.height, 0.2)
        }
        XCTAssertThrowsError(try VRMRig(data: try fixture("tiny-nomesh.vrm"), fileName: "x.vrm")) { XCTAssertEqual(($0 as? LivLivError)?.code, .invalid) }
        XCTAssertThrowsError(try VRMRig(data: try fixture("tiny-draco.vrm"), fileName: "x.vrm")) { XCTAssertEqual(($0 as? LivLivError)?.code, .missingFeature) }
        XCTAssertThrowsError(try VRMRig(data: try fixture("tiny-big.vrm"), fileName: "x.vrm")) { XCTAssertEqual(($0 as? LivLivError)?.code, .tooLarge) }
        XCTAssertThrowsError(try VRMRig(data: Data("not a vrm at all".utf8), fileName: "x.vrm")) { XCTAssertEqual(($0 as? LivLivError)?.code, .notAModel) }
    }

    func testSkinnedVRMMorphsAndSprings() throws {
        let rig = try VRMRig(data: try fixture("skinned1.vrm"), fileName: "skinned1.vrm")
        XCTAssertEqual(rig.info.springs.count, 1)
        XCTAssertEqual(rig.info.springs[0].joints.count, 2)
        let rest = rig.drawables[0].positions
        var P = Params()
        rig.update(params: P, expr: [:], dt: 1.0 / 60)
        let still = rig.drawables[0].positions
        XCTAssertLessThan(zip(rest, still).map { length3($0 - $1) }.max()!, 0.02, "rest pose stays put")
        P.mouthOpen = 1
        rig.update(params: P, expr: [:], dt: 1.0 / 60)
        let open = rig.drawables[0].positions
        XCTAssertGreaterThan(zip(still, open).map { length3($0 - $1) }.max()!, 0.03, "aa moves the strip")
        P.mouthOpen = 0; P.angleX = 30
        for _ in 0..<90 { rig.update(params: P, expr: [:], dt: 1.0 / 60) }
        let turned = rig.drawables[0].positions
        XCTAssertTrue(turned.allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite })
        // the hair keeps its length while it swings
        let a = (turned[2] + turned[3]) / 2, b = (turned[4] + turned[5]) / 2
        XCTAssertEqual(length3(a - b), 0.1, accuracy: 0.01)
    }

    func testFrameCost() throws {
        let m = try model("k01")
        let p = Puppet()
        try p.load(m, images: images(for: m))
        let start = Date()
        for i in 0..<120 { p.params.angleX = Double(i % 60) - 30; p.params.mouthOpen = 0.6; p.update(1.0 / 60); _ = p.frame(width: 1080, height: 1440) }
        let ms = Date().timeIntervalSince(start) / 120 * 1000
        let verts = p.layers.reduce(0) { $0 + $1.rest.count / 2 }
        print("PERF k01: \(verts) vertices, \(String(format: "%.2f", ms)) ms a frame")
    }
}
