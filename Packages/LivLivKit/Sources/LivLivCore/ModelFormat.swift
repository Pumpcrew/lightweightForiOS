// model.json as the player reads it (runtime/format.ts): the public format `livliv-model` version 4, lowered to the shape
// the runtime has always drawn from (the v3 `livemaker-puppet` layout), and v3 itself, read as it is.
import Foundation

public enum ModelFormat {
    public static let format = "livliv-model"
    public static let version = 4
    public static let legacyFormat = "livemaker-puppet"
    public static let legacyVersion = 3
    /// features a v4 file may require (none are defined in 4.0)
    public static let features: [String] = []
}

/// limits a package is held to before anything is decoded (format.ts LIMITS)
public enum Limits {
    public static let canvas = 8192.0, layers = 512, images = 2048, expressions = 256, eyes = 16, chains = 64, points = 256
    public static let texture = 8192, texels = 64 * (1 << 20)
    public static let modelJson = 4 * (1 << 20), keyforms = 32 * (1 << 20)
    public static let vertices = 1 << 21, skinned = 1 << 20
}

/// the lattice every layer's mesh sits on, in model px
@inline(__always) public func latticeCell(_ w: Double, _ h: Double) -> Double { max(6, (max(w, h) / 128).rounded(.toNearestOrAwayFromZero)) }

// MARK: - The model, as the runtime draws it

public enum LayerGroup: String, Sendable { case head, body, hair_back, hair_side, hair_front, hair_inner }

public struct BrowLine: Sendable { public var x: [Double], bottom: [Double], lid: [Double], cap: [Double]? }
public struct Ellipse: Sendable { public var cx, cy, rx, ry: Double }
public struct Jaw: Sendable {
    public var top, chin, half, open: Double
    public var round: Double?, wide: Double?
    public subscript(kind: String) -> Double? {
        switch kind {
        case "top": return top
        case "chin": return chin
        case "half": return half
        case "open": return open
        case "round": return round
        case "wide": return wide
        default: return nil
        }
    }
}

public struct Anchors: Sendable {
    public var head: Ellipse
    public var face: [Double]
    public var neckY, topY, bottomY, hairRootY: Double
    public var collarY: Double?
    public var eyes: [[Double]]?
    public var brows: [[Double]?]?
    public var browLines: [BrowLine?]?
    public var jaw: Jaw?
    public var chest: Ellipse?
}

public struct LayerDef: Sendable {
    public var id: String, name: String, texture: String
    public var frames: [String]?, mask: String?, visemes: [String]?, talk: String?
    public var x, y, w, h: Double
    public var group: LayerGroup
    public var depth: Double
    public var role: String?
    public var pivot: [Double]?, clip: String?, range: [Double]?, param: String?
    public var brows: String?, browTex: String?
    public var webp: Bool
    public var bones: [String]?
    public var rigid: [Double]?
    public var blush: [String: Double]?, show: [String: Double]?, hide: [String: Double]?
    public var fall: Double?, fallEnd: Double?
    public var roleString: String { role ?? "" }
}

public struct ChainDef: Sendable {
    public var id: String
    public var attachBody: Bool
    public var depth: Double?
    public var points: [[Double]]
    public var k: [Double]
    public var damp, drive, hang, wind: Double
    public var freq: Double?, limit: Double?, sigma: Double?, reach: Double?
    public var bias: [String: Double]?
}

public struct BodyRig: Sendable { public var yaw = 0.35, roll = 0.3, breath = 1.0, bust = 0.0 }
public struct NeckRig: Sendable { public var twist: Double; public var reach: Double? }

/// the rig with the player's defaults filled in (defaultRig)
public struct Rig: Sendable {
    public var yaw = 0.27, pitch = 0.22, roll = 0.5, bulge = 0.6
    public var hairFront: [Double] = [140, 11, 0.022, 70, 7]
    public var hairBack: [Double] = [48, 5.5, 0.06, 24, 3.5]
    public var hairSide: [Double]?
    public var hairLimit = 0.25
    public var hairDrive: [Double]?
    public var wind = 1.0, breath = 1.0, sway = 1.0, brow = 0.06
    public var body = BodyRig()
    public var chains: [ChainDef] = []
    public var pitchEase: Double?
    public var bulgeShape: Double?
    public var drift: [Double]?
    public var bulgeExtent: [Double]?
    public var neck: NeckRig?
    public var jaw: Double?
    public init() {}
}

public struct Tuning: Sendable {
    public var turn = 1.0, nod = 1.0, hair = 1.0, blink = 1.0, expr = 1.0, mouth = 1.0, breath = 1.0
    public var hairFront: Double?, hairBack: Double?
    public var gaze = 1.0
    public init() {}
}

public struct ExpressionDef: Sendable {
    public var id: String
    public var label: String
    public var labels: [String: String]?
    public var key: String?
}

public struct Profile: Sendable { public var id: String; public var facing: String?; public var glasses: Bool? }

public struct Watermark: Sendable {
    public enum Kind: String, Sendable { case livliv, text, none }
    public var kind: Kind
    public var text: String?
    public var center: Bool?
}

public struct ModelMeta: Sendable {
    public var generatorName: String
    public var generatorBuild: String?
    public var created: String?
    public var authorName: String?, authorURL: String?
    public var licenseID: String?, licenseURL: String?, licenseText: String?
    public var watermark: Watermark?
}

public struct ModelDef: Sendable {
    public var format: String
    public var version: Int
    public var name: String
    public var canvas: (w: Double, h: Double)
    public var anchors: Anchors
    public var layers: [LayerDef]
    public var rig: Rig
    /// whether the file gave a rig.jaw (procJaw's override) and rig.neck
    public var tuning: Tuning
    public var expressions: [ExpressionDef]?
    public var profile: Profile?
    public var tex: String?
    public var keyforms: String?
    /// the corner mark: "LivLiv" (the logo), the owner's text, or nil
    public var watermark: String?
    public var meta: ModelMeta?
    public var files: [String: String]?

    /// the mark the player draws (v4: meta.watermark; before it the text "LivLiv" meant the logo)
    public var markKind: Watermark.Kind {
        if let meta { return meta.watermark?.kind ?? .none }
        if watermark == "LivLiv" { return .livliv }
        return watermark != nil ? .text : .none
    }
    public var markCenter: Bool { meta?.watermark?.center != false }
}

// MARK: - Reading

private let bigNumber = 1e6
private let groups: Set<String> = ["head", "body", "hair_back", "hair_side", "hair_front", "hair_inner"]
// swiftlint:disable force_try
private let imageRE = try! NSRegularExpression(pattern: "^textures/[A-Za-z0-9_][A-Za-z0-9_.-]*\\.(?:webp|png)$")
private let fileRE = try! NSRegularExpression(pattern: "^(?!.*(?:^|/)\\.\\.(?:/|$))[A-Za-z0-9_][A-Za-z0-9_.-]*(?:/[A-Za-z0-9_][A-Za-z0-9_.-]*)*$")
// swiftlint:enable force_try
private func matches(_ re: NSRegularExpression, _ s: String) -> Bool {
    re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
}
public func isPackagePath(_ s: String) -> Bool { matches(fileRE, s) }

private func coded(_ code: LivLivError.Code, _ message: String) -> LivLivError { LivLivError(code, message) }

/// model.json as the runtime draws it: v3 as it is, v4 lowered. Throws on anything else, a newer version, or a feature in
/// `requires` this player does not have. `lang` picks the expressions' `label`
public func readModel(_ raw: Any, lang: String = uiLanguage()) throws -> ModelDef {
    guard let m = raw as? JObj else { throw coded(.notAModel, "not a LivLiv model (model.json is not an object)") }
    let fmt = m["format"]
    if isNull(fmt) || (fmt as? String) == ModelFormat.legacyFormat {
        let v = jnum(m["version"]).map { Int($0) } ?? ModelFormat.legacyVersion
        if v > ModelFormat.legacyVersion { throw coded(.notAModel, "this model says format \"\(ModelFormat.legacyFormat)\" version \(v), which never existed") }
        try check(m)
        return try decode(m, lang: lang)
    }
    guard (fmt as? String) == ModelFormat.format else { throw coded(.notAModel, "not a LivLiv model (format \"\(String(describing: fmt!))\")") }
    guard let v = jnum(m["version"]), Int(v) <= ModelFormat.version else {
        throw coded(.newerFormat, "this model is format version \(jnum(m["version"]).map { String(Int($0)) } ?? "?"); this player reads up to \(ModelFormat.version): update the player")
    }
    let missing = (m["requires"] as? [Any] ?? []).compactMap { $0 as? String }.filter { !ModelFormat.features.contains($0) }
    if !missing.isEmpty { throw coded(.missingFeature, "this model needs \(missing.joined(separator: ", ")), which this player does not have: update the player") }
    let low = try lower(m, lang: lang)
    try check(low)
    return try decode(low, lang: lang)
}

/// what any model must be before it is drawn, whatever wrote it (format.ts check)
func check(_ m: JObj) throws {
    func bad(_ why: String, _ code: LivLivError.Code = .invalid) -> LivLivError { coded(code, "this model is not valid: \(why)") }
    func inRange(_ v: Any?) -> Bool { if let d = jnum(v) { return abs(d) <= bigNumber } ; return false }
    func list(_ v: Any?, _ most: Int, _ what: String) throws -> [Any] {
        if isNull(v) { return [] }
        guard let a = v as? [Any], a.count <= most else { throw bad("\(what) is not a list of at most \(most)") }
        return a
    }
    func sane(_ v: Any?, _ what: String) throws { if !isNull(v) && !inRange(v) { throw bad("\(what) is not a number in range") } }
    func nums(_ v: Any?, _ lo: Int, _ hi: Int, _ what: String) throws {
        if isNull(v) { return }
        guard let a = v as? [Any], a.count >= lo, a.count <= hi, a.allSatisfy(inRange) else { throw bad("\(what) is not a list of \(lo) to \(hi) numbers") }
    }
    func fields(_ o: Any?, _ names: String, _ what: String) throws {
        if isNull(o) { return }
        guard let d = o as? JObj else { throw bad("\(what) is not an object") }
        for n in names.split(separator: " ") { try sane(d[String(n)], "\(what).\(n)") }
    }
    func weights(_ o: Any?, _ what: String) throws {
        if isNull(o) { return }
        guard let d = o as? JObj else { throw bad("\(what) is not an object") }
        for (k, v) in d { try sane(v, "\(what).\(k.prefix(60))") }
    }
    let canvas = m["canvas"] as? [Any] ?? []
    let w = canvas.count > 0 ? jnum(canvas[0]) ?? .nan : .nan, h = canvas.count > 1 ? jnum(canvas[1]) ?? .nan : .nan
    if !(w > 0 && h > 0 && w <= Limits.canvas && h <= Limits.canvas) {
        throw bad("its canvas \(w) x \(h) is out of range", w > Limits.canvas || h > Limits.canvas ? .tooLarge : .invalid)
    }
    guard let layers = m["layers"] as? [Any], !layers.isEmpty else { throw bad("it has no layers") }
    if layers.count > Limits.layers { throw bad("it has \(layers.count) layers, more than \(Limits.layers)", .tooLarge) }
    let A = jobj(m["anchors"]), hd = jobj(A?["head"])
    let face = A?["face"] as? [Any]
    if hd == nil || !["cx", "cy", "rx", "ry"].allSatisfy({ inRange(hd![$0]) }) || !["neck_y", "top_y", "bottom_y", "hair_root_y"].allSatisfy({ inRange(A![$0]) })
        || !((jnum(hd!["rx"]) ?? 0) > 1e-3 && (jnum(hd!["ry"]) ?? 0) > 1e-3) || face == nil || face!.count != 4 || !face!.allSatisfy(inRange) {
        throw bad("its anchors are missing or not numbers")
    }
    let anchors = A!
    try sane(anchors["collar_y"], "anchors.collar_y")
    try fields(anchors["jaw"], "top chin half open round wide", "anchors.jaw")
    try fields(anchors["chest"], "cx cy rx ry", "anchors.chest")
    for b in try list(anchors["eyes"], Limits.eyes, "anchors.eyes") {
        if isNull(b) { throw bad("anchors.eyes has an empty entry") }
        try nums(b, 4, 4, "anchors.eyes")
    }
    for b in try list(anchors["brows"], Limits.eyes, "anchors.brows") { try nums(b, 4, 4, "anchors.brows") }
    for line in try list(anchors["brow_lines"], Limits.eyes, "anchors.brow_lines") {
        if isNull(line) { continue }
        guard let l = line as? JObj else { throw bad("a brow line is not an object") }
        let n = try list(l["x"], Limits.points, "a brow line").count
        if n == 0 { throw bad("a brow line has no points") }
        try nums(l["x"], n, n, "a brow line"); try nums(l["bottom"] ?? [Any](), n, n, "a brow line"); try nums(l["lid"] ?? [Any](), n, n, "a brow line")
        if !isNull(l["cap"]) { try nums(l["cap"], n, n, "a brow line") }
    }
    try fields(m["tuning"], "turn nod hair blink expr mouth breath hairFront hairBack", "tuning")
    let R = jobj(m["rig"])
    try fields(m["rig"], "yaw pitch roll bulge bulge_shape hair_limit wind breath sway brow pitch_ease jaw", "rig")
    try nums(R?["bulge_extent"], 3, 5, "rig.bulge_extent"); try nums(R?["drift"], 2, 2, "rig.drift"); try nums(R?["hair_drive"], 3, 3, "rig.hair_drive")
    try fields(R?["body"], "yaw roll breath bust", "rig.body"); try fields(R?["neck"], "twist reach", "rig.neck")
    if let hair = R?["hair"], !isNull(hair) {
        guard let hd = hair as? JObj else { throw bad("rig.hair is not an object") }
        for k in ["front", "back", "side"] { try nums(hd[k], 5, 5, "rig.hair.\(k)") }
    }
    for c in try list(R?["chains"], Limits.chains, "rig.chains") {
        guard let c = c as? JObj, let cid = c["id"] as? String else { throw bad("a chain has no id") }
        let what = "chain \(cid.prefix(60))"
        let points = try list(c["points"], Limits.points, "\(what)'s points")
        if points.count < 2 { throw bad("\(what) has fewer than two points") }
        for q in points { if isNull(q) { throw bad("\(what) has an empty point") }; try nums(q, 2, 2, "\(what)'s points") }
        if isNull(c["k"]) { throw bad("\(what) has no k") }
        try nums(c["k"], 2, 2, "\(what)'s k")
        for n in ["damp", "drive", "hang", "wind"] where jnum(c[n]) == nil { throw bad("\(what) has no \(n)") }
        try fields(c, "depth damp drive hang wind freq limit sigma reach", what)
        try weights(c["bias"], "\(what)'s bias")
    }
    let cell = latticeCell(w, h)
    let bangs = (layers.first { (jobj($0)?["group"] as? String) == "hair_front" } as? JObj)?["bones"] as? [Any]
    var images = 0, vertices = 0, skinned = 0, read = 0.0
    for Lany in layers {
        guard let L = Lany as? JObj, let lid = L["id"] as? String else { throw bad("a layer has no id") }
        let what = "layer \(lid.prefix(60))"
        guard let x = jnum(L["x"]), let y = jnum(L["y"]), let lw = jnum(L["w"]), let lh = jnum(L["h"]), lw > 0, lh > 0,
              x >= -w, y >= -h, x + lw <= 2 * w, y + lh <= 2 * h else { throw bad("\(what)'s box is out of range") }
        guard L["texture"] is String else { throw bad("\(what) has no texture") }
        var paths: [Any?] = [L["texture"]]
        paths += try list(L["frames"], Limits.images, "\(what)'s frames").map { Optional($0) }
        paths += [L["mask"], L["talk"], L["brow_tex"]]
        for p in paths {
            if isNull(p) { continue }
            guard let s = p as? String, matches(fileRE, s) else { throw bad("\(what): \"\(String(describing: p!).prefix(80))\" is not a path inside the package") }
            images += 1
            if images > Limits.images { throw bad("it names more than \(Limits.images) images") }
        }
        guard let g = L["group"] as? String, groups.contains(g) else { throw bad("\(what)'s group is not one a player knows") }
        for n in ["role", "clip", "param"] where !isNull(L[n]) && !(L[n] is String) { throw bad("\(what)'s \(n) is not text") }
        if !isNull(L["visemes"]) && !((L["visemes"] as? [Any])?.allSatisfy { $0 is String } ?? false) { throw bad("\(what)'s visemes are not text") }
        try sane(L["depth"], "\(what)'s depth"); try sane(L["fall"], "\(what)'s fall"); try sane(L["fall_end"], "\(what)'s fall_end")
        try nums(L["pivot"], 2, 2, "\(what)'s pivot"); try nums(L["range"], 2, 2, "\(what)'s range"); try nums(L["rigid"], 2, 2, "\(what)'s rigid")
        try weights(L["blush"], "\(what)'s blush"); try weights(L["show"], "\(what)'s show"); try weights(L["hide"], "\(what)'s hide")
        let bones = try list(L["bones"], Limits.chains, "\(what)'s bones")
        guard bones.allSatisfy({ $0 is String }) else { throw bad("\(what)'s bones are not chain ids") }
        if Set(bones.compactMap { $0 as? String }).count != bones.count { throw bad("\(what) names a chain twice") }
        let cols = Int((ceil((x + lw) / cell) - floor(x / cell)) + 1), rows = Int((ceil((y + lh) / cell) - floor(y / cell)) + 1)
        let verts = cols * rows
        let overBangs = lid == "brows" || (L["role"] as? String) == "expr_brows" || !isNull(L["brow_tex"])
        vertices += verts
        skinned += verts * (bones.count + (overBangs ? (bangs?.count ?? 0) : 0))
        if overBangs { read += lw * lh }
    }
    if vertices > Limits.vertices { throw bad("its layers' meshes would have \(vertices) vertices, more than \(Limits.vertices)", .tooLarge) }
    if skinned > Limits.skinned { throw bad("its chains would bend \(skinned) vertices, more than \(Limits.skinned)", .tooLarge) }
    if read > Double(Limits.texels) { throw bad("its brows layers cover \(Int(read)) pixels, more than \(Limits.texels)", .tooLarge) }
    for e in try list(m["expressions"], Limits.expressions, "expressions") {
        guard let e = e as? JObj, e["id"] is String else { throw bad("an expression has no id") }
    }
    if !isNull(m["keyforms"]) && !((m["keyforms"] as? String).map { matches(fileRE, $0) } ?? false) { throw bad("keyforms is not a path inside the package") }
    if !isNull(m["watermark"]) && !(m["watermark"] is String) { throw bad("its watermark is not text") }
}

/// v4 lowered to the v3 layout (format.ts lower)
func lower(_ m: JObj, lang: String) throws -> JObj {
    guard let layers = m["layers"] as? [Any], !layers.isEmpty else { throw coded(.invalid, "this model has no layers") }
    if layers.count > Limits.layers { throw coded(.tooLarge, "this model has \(layers.count) layers, more than \(Limits.layers)") }
    let canvas = m["canvas"] as? [Any] ?? []
    let w = canvas.count > 0 ? jnum(canvas[0]) ?? 0 : 0, h = canvas.count > 1 ? jnum(canvas[1]) ?? 0 : 0
    if !(w > 0 && h > 0 && w <= Limits.canvas && h <= Limits.canvas) {
        throw coded(w > Limits.canvas || h > Limits.canvas ? .tooLarge : .invalid, "this model's canvas \(w) x \(h) is out of range")
    }
    var outLayers: [Any] = []
    for Lany in layers {
        guard var L = Lany as? JObj else { throw coded(.invalid, "a layer is not an object") }
        var paths: [Any?] = [L["texture"]]
        paths += (L["frames"] as? [Any] ?? []).map { Optional($0) }
        paths += [L["mask"], L["talk"], L["brow_tex"]]
        for p in paths where !isNull(p) {
            guard let s = p as? String, matches(imageRE, s) else { throw coded(.invalid, "layer \(L["id"] as? String ?? "?"): \"\(String(describing: p!))\" is not an image path of the package") }
        }
        let label = jlabels(L["label"]), expression = L["expression"] as? String
        L["label"] = nil; L["expression"] = nil
        if isNull(L["depth"]) { L["depth"] = 0.0 }
        let id = L["id"] as? String ?? ""
        L["name"] = label.map { pickLabel($0, lang: "en", fallback: id) } ?? id
        if let expression { L["param"] = expression }
        outLayers.append(L)
    }
    if let files = m["files"] as? JObj {
        for (k, p) in files where !k.hasPrefix("x-") {
            guard let s = p as? String, matches(fileRE, s) else { throw coded(.invalid, "files.\(k): \"\(String(describing: p))\" is not a path in the package") }
        }
    }
    var tuning: JObj?
    if var t = m["tuning"] as? JObj {
        if let f = t["hair_front"] { t["hairFront"] = f; t["hair_front"] = nil }
        if let b = t["hair_back"] { t["hairBack"] = b; t["hair_back"] = nil }
        tuning = t
    }
    var out: JObj = [
        "format": m["format"] as Any, "version": m["version"] as Any, "name": m["name"] as Any, "canvas": m["canvas"] as Any,
        "anchors": m["anchors"] as Any, "layers": outLayers,
    ]
    if let r = m["rig"] { out["rig"] = r }
    if let tuning { out["tuning"] = tuning }
    if let p = m["profile"] as? JObj {
        var input: JObj = [:]
        if let f = p["facing"] { input["facing"] = f }
        if let g = p["glasses"] { input["glasses"] = g }
        out["profile"] = ["id": p["id"] as Any, "label": "", "class": ["input": input]] as JObj
    }
    let exprs = (m["expressions"] as? [Any] ?? []).compactMap { $0 as? JObj }.map { e -> JObj in
        let labels = jlabels(e["label"]) ?? [:], id = e["id"] as? String ?? ""
        var x: JObj = ["id": id, "label": pickLabel(labels, lang: lang, fallback: id), "labels": labels]
        if let hk = e["hotkey"] as? String, !hk.isEmpty { x["key"] = hk }
        return x
    }
    out["expressions"] = exprs
    if let kf = (m["files"] as? JObj)?["keyforms"] { out["keyforms"] = kf }
    let mark = (m["meta"] as? JObj)?["watermark"] as? JObj
    switch mark?["kind"] as? String {
    case "livliv": out["watermark"] = "LivLiv"
    case "text": out["watermark"] = (mark?["text"] as? String) ?? NSNull()
    default: out["watermark"] = NSNull()
    }
    if let meta = m["meta"] { out["meta"] = meta }
    if let files = m["files"] { out["files"] = files }
    return out
}

/// the checked dictionary as Swift values
func decode(_ m: JObj, lang: String) throws -> ModelDef {
    let canvas = m["canvas"] as! [Any]
    let A = m["anchors"] as! JObj, hd = A["head"] as! JObj
    func ellipse(_ o: JObj) -> Ellipse { Ellipse(cx: jnum(o["cx"]) ?? 0, cy: jnum(o["cy"]) ?? 0, rx: jnum(o["rx"]) ?? 1, ry: jnum(o["ry"]) ?? 1) }
    var anchors = Anchors(head: ellipse(hd), face: jnums(A["face"]) ?? [0, 0, 1, 1],
                          neckY: jnum(A["neck_y"]) ?? 0, topY: jnum(A["top_y"]) ?? 0, bottomY: jnum(A["bottom_y"]) ?? 0,
                          hairRootY: jnum(A["hair_root_y"]) ?? 0)
    anchors.collarY = jnum(A["collar_y"])
    anchors.eyes = (A["eyes"] as? [Any])?.compactMap { jnums($0) }
    anchors.brows = (A["brows"] as? [Any])?.map { jnums($0) }
    anchors.browLines = (A["brow_lines"] as? [Any])?.map { v -> BrowLine? in
        guard let l = v as? JObj, let x = jnums(l["x"]) else { return nil }
        return BrowLine(x: x, bottom: jnums(l["bottom"]) ?? [], lid: jnums(l["lid"]) ?? [], cap: jnums(l["cap"]))
    }
    if let j = A["jaw"] as? JObj {
        anchors.jaw = Jaw(top: jnum(j["top"]) ?? 0, chin: jnum(j["chin"]) ?? 0, half: jnum(j["half"]) ?? 0, open: jnum(j["open"]) ?? 0,
                          round: jnum(j["round"]), wide: jnum(j["wide"]))
    }
    if let c = A["chest"] as? JObj { anchors.chest = ellipse(c) }

    var layers: [LayerDef] = []
    for case let L as JObj in m["layers"] as! [Any] {
        let id = L["id"] as! String
        layers.append(LayerDef(
            id: id, name: (L["name"] as? String) ?? id, texture: L["texture"] as! String,
            frames: (L["frames"] as? [Any])?.compactMap { $0 as? String }, mask: L["mask"] as? String,
            visemes: (L["visemes"] as? [Any])?.compactMap { $0 as? String }, talk: L["talk"] as? String,
            x: jnum(L["x"])!, y: jnum(L["y"])!, w: jnum(L["w"])!, h: jnum(L["h"])!,
            group: LayerGroup(rawValue: L["group"] as! String)!, depth: jnum(L["depth"]) ?? 0, role: L["role"] as? String,
            pivot: jnums(L["pivot"]), clip: L["clip"] as? String, range: jnums(L["range"]), param: L["param"] as? String,
            brows: L["brows"] as? String, browTex: L["brow_tex"] as? String, webp: jbool(L["webp"]) ?? false,
            bones: (L["bones"] as? [Any])?.compactMap { $0 as? String }, rigid: jnums(L["rigid"]),
            blush: jweights(L["blush"]), show: jweights(L["show"]), hide: jweights(L["hide"]),
            fall: jnum(L["fall"]), fallEnd: jnum(L["fall_end"])))
    }

    var rig = Rig()
    if let R = m["rig"] as? JObj {
        if let v = jnum(R["yaw"]) { rig.yaw = v }
        if let v = jnum(R["pitch"]) { rig.pitch = v }
        if let v = jnum(R["roll"]) { rig.roll = v }
        if let v = jnum(R["bulge"]) { rig.bulge = v }
        if let hair = R["hair"] as? JObj {
            if let v = jnums(hair["front"]) { rig.hairFront = v }
            if let v = jnums(hair["back"]) { rig.hairBack = v }
            rig.hairSide = jnums(hair["side"])
        }
        if let v = jnum(R["hair_limit"]) { rig.hairLimit = v }
        rig.hairDrive = jnums(R["hair_drive"])
        if let v = jnum(R["wind"]) { rig.wind = v }
        if let v = jnum(R["breath"]) { rig.breath = v }
        if let v = jnum(R["sway"]) { rig.sway = v }
        if let v = jnum(R["brow"]) { rig.brow = v }
        if let b = R["body"] as? JObj {
            if let v = jnum(b["yaw"]) { rig.body.yaw = v }
            if let v = jnum(b["roll"]) { rig.body.roll = v }
            if let v = jnum(b["breath"]) { rig.body.breath = v }
            if let v = jnum(b["bust"]) { rig.body.bust = v }
        }
        rig.chains = (R["chains"] as? [Any] ?? []).compactMap { $0 as? JObj }.map { c in
            ChainDef(id: c["id"] as! String, attachBody: (c["attach"] as? String) == "body", depth: jnum(c["depth"]),
                     points: (c["points"] as? [Any] ?? []).compactMap { jnums($0) }, k: jnums(c["k"]) ?? [1, 1],
                     damp: jnum(c["damp"]) ?? 0, drive: jnum(c["drive"]) ?? 0, hang: jnum(c["hang"]) ?? 0, wind: jnum(c["wind"]) ?? 0,
                     freq: jnum(c["freq"]), limit: jnum(c["limit"]), sigma: jnum(c["sigma"]), reach: jnum(c["reach"]), bias: jweights(c["bias"]))
        }
        rig.pitchEase = jnum(R["pitch_ease"])
        rig.bulgeShape = jnum(R["bulge_shape"])
        rig.drift = jnums(R["drift"])
        rig.bulgeExtent = jnums(R["bulge_extent"])
        if let n = R["neck"] as? JObj, let t = jnum(n["twist"]) { rig.neck = NeckRig(twist: t, reach: jnum(n["reach"])) }
        rig.jaw = jnum(R["jaw"])
    }
    var tuning = Tuning()
    if let t = m["tuning"] as? JObj {
        if let v = jnum(t["turn"]) { tuning.turn = v }
        if let v = jnum(t["nod"]) { tuning.nod = v }
        if let v = jnum(t["hair"]) { tuning.hair = v }
        if let v = jnum(t["blink"]) { tuning.blink = v }
        if let v = jnum(t["expr"]) { tuning.expr = v }
        if let v = jnum(t["mouth"]) { tuning.mouth = v }
        if let v = jnum(t["breath"]) { tuning.breath = v }
        tuning.hairFront = jnum(t["hairFront"]); tuning.hairBack = jnum(t["hairBack"])
        if let v = jnum(t["gaze"]) { tuning.gaze = v }
    }
    let exprs: [ExpressionDef]? = (m["expressions"] as? [Any])?.compactMap { $0 as? JObj }.map { e in
        let id = e["id"] as! String
        return ExpressionDef(id: id, label: (e["label"] as? String) ?? id, labels: jlabels(e["labels"]), key: (e["key"] as? String) ?? (e["hotkey"] as? String))
    }
    var profile: Profile?
    if let p = m["profile"] as? JObj, let id = p["id"] as? String {
        let input = ((p["class"] as? JObj)?["input"] as? JObj) ?? [:]
        profile = Profile(id: id, facing: input["facing"] as? String, glasses: jbool(input["glasses"]))
    }
    var meta: ModelMeta?
    if let mm = m["meta"] as? JObj {
        let gen = mm["generator"] as? JObj, author = mm["author"] as? JObj, lic = mm["license"] as? JObj, wm = mm["watermark"] as? JObj
        meta = ModelMeta(generatorName: (gen?["name"] as? String) ?? "", generatorBuild: gen?["build"] as? String, created: mm["created"] as? String,
                         authorName: author?["name"] as? String, authorURL: author?["url"] as? String,
                         licenseID: lic?["id"] as? String, licenseURL: lic?["url"] as? String, licenseText: lic?["text"] as? String,
                         watermark: wm.map { Watermark(kind: Watermark.Kind(rawValue: ($0["kind"] as? String) ?? "none") ?? .none, text: $0["text"] as? String, center: jbool($0["center"])) })
    }
    return ModelDef(format: (m["format"] as? String) ?? ModelFormat.legacyFormat, version: jnum(m["version"]).map { Int($0) } ?? 3,
                    name: (m["name"] as? String) ?? "", canvas: (jnum(canvas[0])!, jnum(canvas[1])!), anchors: anchors, layers: layers,
                    rig: rig, tuning: tuning, expressions: exprs, profile: profile, tex: m["tex"] as? String, keyforms: m["keyforms"] as? String,
                    watermark: m["watermark"] as? String, meta: meta, files: (m["files"] as? JObj)?.compactMapValues { $0 as? String })
}

// MARK: - Names by language

/// the device's language, for picking names
public func uiLanguage() -> String { Locale.preferredLanguages.first ?? "en" }

/// a name in `lang`: that tag, its script (zh-TW -> zh-Hant), its language, then English, Chinese, any, `fallback`
public func pickLabel(_ labels: [String: String]?, lang: String, fallback: String) -> String {
    guard let labels, !labels.isEmpty else { return fallback }
    let keys = labels.keys.sorted()
    func find(_ t: String) -> String? { keys.first { $0.lowercased() == t.lowercased() } }
    let tag = lang.isEmpty ? "en" : lang
    let base = String(tag.split(separator: "-").first ?? "en").lowercased()
    let lower = tag.lowercased()
    let hant = base == "zh" && ["-hant", "-tw", "-hk", "-mo"].contains { lower.contains($0) }
    var order = [tag]
    if base == "zh" { order.append(hant ? "zh-Hant" : "zh-Hans") }
    order.append(base)
    if hant { order.append("zh") }
    order += ["en", "zh"]
    for t in order { if let k = find(t), let v = labels[k], !v.isEmpty { return v } }
    return labels[keys[0]] ?? fallback
}

/// the language a name was written in: kana ja, hangul ko, han zh, anything else en
public func langOf(_ text: String) -> String {
    for s in text.unicodeScalars {
        if (0x3040...0x30FF).contains(s.value) { return "ja" }
    }
    for s in text.unicodeScalars where (0xAC00...0xD7AF).contains(s.value) { return "ko" }
    for s in text.unicodeScalars where (0x4E00...0x9FFF).contains(s.value) { return "zh" }
    return "en"
}
