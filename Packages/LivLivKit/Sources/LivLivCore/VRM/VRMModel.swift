// The VRM extensions of a glTF, 0.x (`VRM`) and 1.0 (`VRMC_vrm`, `VRMC_springBone`), read into one shape: the humanoid
// bones, the expressions and their morph-target binds, the look-at, the spring bones and their colliders, and the
// licence terms (vrm.ts vrmTerms).
import Foundation

public struct VRMExpression: Sendable {
    public struct Bind: Sendable { public var mesh: Int; public var index: Int; public var weight: Float }
    public enum Override: String, Sendable { case none, block, blend }
    public var name: String
    public var binds: [Bind]
    public var isBinary: Bool
    public var overrideBlink = Override.none, overrideMouth = Override.none, overrideLookAt = Override.none
}

public struct VRMSpringJoint: Sendable {
    public var node: Int
    /// the tail: the next joint's node, or for a VRM 0.x leaf a point past the bone
    public var tailNode: Int?
    public var hitRadius: Float, stiffness: Float, gravityPower: Float, gravityDir: V3, dragForce: Float
}

public struct VRMSpring: Sendable { public var joints: [VRMSpringJoint]; public var colliderGroups: [Int]; public var center: Int? }

public struct VRMCollider: Sendable {
    public var node: Int
    public var offset: V3
    public var radius: Float
    /// a capsule's other end (nil: a sphere)
    public var tail: V3?
}

public struct VRMLookAt: Sendable {
    public enum Kind: Sendable { case bone, expression }
    public var kind: Kind = .bone
    public var horizontalOuter: (input: Float, output: Float) = (90, 10)
    public var horizontalInner: (input: Float, output: Float) = (90, 10)
    public var verticalDown: (input: Float, output: Float) = (90, 10)
    public var verticalUp: (input: Float, output: Float) = (90, 10)
}

/// a VRM's licence terms (vrm.ts VrmTerms)
public struct VRMTerms: Sendable {
    public var spec: String
    public var name: String?
    public var author: String?
    public var licenseName: String?, licenseURL: String?
    public var use: String?
    public var commercial: String?
    public var violence: Bool?, sexual: Bool?, redistribution: Bool?
    public var modification: String?
}

public struct VRMInfo: Sendable {
    public var spec: String
    public var humanBones: [String: Int]
    public var expressions: [String: VRMExpression]
    /// names the file gives its own expressions, by the id the app shows
    public var custom: [String: String]
    public var springs: [VRMSpring]
    public var colliders: [VRMCollider]
    public var colliderGroups: [[Int]]
    public var lookAt: VRMLookAt
    public var terms: VRMTerms
    /// 0.x leaf joints' virtual tails: per joint node, the tail's offset in the bone's own space
    public var virtualTails: [Int: V3]

    /// reads the VRM extensions; throws when the glTF has none
    public static func read(_ doc: GLTFDocument, name: String) throws -> VRMInfo {
        let ext = doc.json["extensions"] as? JObj ?? [:]
        if let v1 = ext["VRMC_vrm"] as? JObj { return read1(doc, v1, ext["VRMC_springBone"] as? JObj) }
        if let v0 = ext["VRM"] as? JObj { return read0(doc, v0) }
        throw LivLivError(.notAModel, "LivLiv: \(name) is a glTF without VRM data (exported as plain glTF? VRM exporters write a .vrm)")
    }

    private static func v3(_ v: Any?, flipZ: Bool = false) -> V3 {
        if let a = jnums(v), a.count >= 3 { return V3(Float(a[0]), Float(a[1]), Float(a[2])) }
        if let o = v as? JObj { return V3(Float(jnum(o["x"]) ?? 0), Float(jnum(o["y"]) ?? 0), Float(jnum(o["z"]) ?? 0) * (flipZ ? -1 : 1)) }
        return V3(0, 0, 0)
    }

    private static func read1(_ doc: GLTFDocument, _ v: JObj, _ sb: JObj?) -> VRMInfo {
        var bones: [String: Int] = [:]
        for (k, b) in ((v["humanoid"] as? JObj)?["humanBones"] as? JObj) ?? [:] {
            if let n = jnum((b as? JObj)?["node"]).map({ Int($0) }), n >= 0, n < doc.nodes.count { bones[k] = n }
        }
        var exprs: [String: VRMExpression] = [:], custom: [String: String] = [:]
        func expression(_ name: String, _ e: JObj) -> VRMExpression {
            let binds = (e["morphTargetBinds"] as? [Any] ?? []).compactMap { $0 as? JObj }.compactMap { b -> VRMExpression.Bind? in
                guard let node = jnum(b["node"]).map({ Int($0) }), let mesh = doc.nodes[safe: node]?.mesh, let idx = jnum(b["index"]) else { return nil }
                return .init(mesh: mesh, index: Int(idx), weight: Float(jnum(b["weight"]) ?? 1))
            }
            var x = VRMExpression(name: name, binds: binds, isBinary: jbool(e["isBinary"]) ?? false)
            x.overrideBlink = .init(rawValue: e["overrideBlink"] as? String ?? "none") ?? .none
            x.overrideMouth = .init(rawValue: e["overrideMouth"] as? String ?? "none") ?? .none
            x.overrideLookAt = .init(rawValue: e["overrideLookAt"] as? String ?? "none") ?? .none
            return x
        }
        let E = v["expressions"] as? JObj ?? [:]
        for (k, e) in E["preset"] as? JObj ?? [:] { if let e = e as? JObj { exprs[k] = expression(k, e) } }
        for (k, e) in E["custom"] as? JObj ?? [:] {
            guard let e = e as? JObj else { continue }
            let lower = k.lowercased(), id = feelings.contains(lower) && exprs[lower] == nil ? lower : k
            exprs[k] = expression(k, e)
            custom[id] = k
        }
        var la = VRMLookAt()
        if let l = v["lookAt"] as? JObj {
            la.kind = (l["type"] as? String) == "expression" ? .expression : .bone
            func range(_ key: String, _ def: (Float, Float)) -> (input: Float, output: Float) {
                guard let r = l[key] as? JObj else { return def }
                return (Float(jnum(r["inputMaxValue"]) ?? Double(def.0)), Float(jnum(r["outputScale"]) ?? Double(def.1)))
            }
            let d: (Float, Float) = la.kind == .bone ? (90, 10) : (90, 1)
            la.horizontalInner = range("rangeMapHorizontalInner", d); la.horizontalOuter = range("rangeMapHorizontalOuter", d)
            la.verticalDown = range("rangeMapVerticalDown", d); la.verticalUp = range("rangeMapVerticalUp", d)
        }
        var colliders: [VRMCollider] = [], groups: [[Int]] = [], springs: [VRMSpring] = []
        if let sb {
            for cAny in sb["colliders"] as? [Any] ?? [] {
                guard let c = cAny as? JObj, let node = jnum(c["node"]).map({ Int($0) }), node >= 0, node < doc.nodes.count else { colliders.append(VRMCollider(node: 0, offset: V3(0, 0, 0), radius: 0)); continue }
                let shape = c["shape"] as? JObj ?? [:]
                if let s = shape["sphere"] as? JObj {
                    colliders.append(VRMCollider(node: node, offset: v3(s["offset"]), radius: Float(jnum(s["radius"]) ?? 0)))
                } else if let s = shape["capsule"] as? JObj {
                    colliders.append(VRMCollider(node: node, offset: v3(s["offset"]), radius: Float(jnum(s["radius"]) ?? 0), tail: v3(s["tail"])))
                } else { colliders.append(VRMCollider(node: node, offset: V3(0, 0, 0), radius: 0)) }
            }
            groups = (sb["colliderGroups"] as? [Any] ?? []).map { g in ((g as? JObj)?["colliders"] as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } } }
            for sAny in sb["springs"] as? [Any] ?? [] {
                guard let s = sAny as? JObj else { continue }
                let js = (s["joints"] as? [Any] ?? []).compactMap { $0 as? JObj }
                var joints: [VRMSpringJoint] = []
                for (i, j) in js.enumerated() where i + 1 < js.count {
                    guard let node = jnum(j["node"]).map({ Int($0) }), node >= 0, node < doc.nodes.count,
                          let tail = jnum(js[i + 1]["node"]).map({ Int($0) }), tail >= 0, tail < doc.nodes.count else { continue }
                    joints.append(VRMSpringJoint(node: node, tailNode: tail, hitRadius: Float(jnum(j["hitRadius"]) ?? 0), stiffness: Float(jnum(j["stiffness"]) ?? 1),
                                                 gravityPower: Float(jnum(j["gravityPower"]) ?? 0), gravityDir: j["gravityDir"] != nil ? v3(j["gravityDir"]) : V3(0, -1, 0),
                                                 dragForce: Float(jnum(j["dragForce"]) ?? 0.5)))
                }
                springs.append(VRMSpring(joints: joints, colliderGroups: (s["colliderGroups"] as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } },
                                         center: jnum(s["center"]).map { Int($0) }))
            }
        }
        let m = v["meta"] as? JObj ?? [:]
        func text(_ x: Any?) -> String? { guard let s = x as? String else { return nil }; let t = s.trimmingCharacters(in: .whitespaces); return t.isEmpty || t == "undefined" ? nil : t }
        func yes(_ x: Any?) -> Bool? { if let b = jbool(x) { return b }; if let s = x as? String { return s == "Allow" ? true : s == "Disallow" ? false : nil }; return nil }
        let authors = (m["authors"] as? [Any] ?? []).compactMap(text)
        let terms = VRMTerms(spec: "1", name: text(m["name"]), author: authors.isEmpty ? nil : authors.joined(separator: ", "), licenseName: nil,
                             licenseURL: text(m["licenseUrl"]), use: text(m["avatarPermission"]), commercial: text(m["commercialUsage"]),
                             violence: yes(m["allowExcessivelyViolentUsage"]), sexual: yes(m["allowExcessivelySexualUsage"]),
                             redistribution: yes(m["allowRedistribution"]), modification: text(m["modification"]))
        return VRMInfo(spec: "1", humanBones: bones, expressions: exprs, custom: custom, springs: springs, colliders: colliders,
                       colliderGroups: groups, lookAt: la, terms: terms, virtualTails: [:])
    }

    private static let presets0: [String: String] = [
        "joy": "happy", "angry": "angry", "sorrow": "sad", "fun": "relaxed", "surprised": "surprised",
        "a": "aa", "i": "ih", "u": "ou", "e": "ee", "o": "oh", "blink": "blink", "blink_l": "blinkLeft", "blink_r": "blinkRight",
        "lookup": "lookUp", "lookdown": "lookDown", "lookleft": "lookLeft", "lookright": "lookRight", "neutral": "neutral",
    ]
    static let feelings = ["happy", "angry", "sad", "relaxed", "surprised"]

    private static func read0(_ doc: GLTFDocument, _ v: JObj) -> VRMInfo {
        var bones: [String: Int] = [:]
        for b in ((v["humanoid"] as? JObj)?["humanBones"] as? [Any] ?? []).compactMap({ $0 as? JObj }) {
            if let name = b["bone"] as? String, let n = jnum(b["node"]).map({ Int($0) }), n >= 0, n < doc.nodes.count { bones[name] = n }
        }
        var exprs: [String: VRMExpression] = [:], custom: [String: String] = [:]
        for g in ((v["blendShapeMaster"] as? JObj)?["blendShapeGroups"] as? [Any] ?? []).compactMap({ $0 as? JObj }) {
            let name = g["name"] as? String ?? ""
            let preset = (g["presetName"] as? String ?? "unknown").lowercased()
            let binds = (g["binds"] as? [Any] ?? []).compactMap { $0 as? JObj }.compactMap { b -> VRMExpression.Bind? in
                guard let mesh = jnum(b["mesh"]), let idx = jnum(b["index"]) else { return nil }
                return .init(mesh: Int(mesh), index: Int(idx), weight: Float((jnum(b["weight"]) ?? 100) / 100))
            }
            let x = VRMExpression(name: name, binds: binds, isBinary: jbool(g["isBinary"]) ?? false)
            if let p = presets0[preset] { exprs[p] = x }
            else if !name.isEmpty {
                let lower = name.lowercased(), id = feelings.contains(lower) ? lower : name
                exprs[name] = x
                custom[id] = name
            }
        }
        var la = VRMLookAt()
        if let fp = v["firstPerson"] as? JObj {
            la.kind = (fp["lookAtTypeName"] as? String) == "BlendShape" ? .expression : .bone
            func range(_ key: String) -> (input: Float, output: Float) {
                guard let r = fp[key] as? JObj else { return la.kind == .bone ? (90, 10) : (90, 1) }
                return (Float(jnum(r["xRange"]) ?? 90), Float(jnum(r["yRange"]) ?? 10))
            }
            la.horizontalInner = range("lookAtHorizontalInner"); la.horizontalOuter = range("lookAtHorizontalOuter")
            la.verticalDown = range("lookAtVerticalDown"); la.verticalUp = range("lookAtVerticalUp")
            if la.kind == .expression {  // a blend shape's range is a weight: 0..1
                for k in [\VRMLookAt.horizontalInner, \.horizontalOuter, \.verticalDown, \.verticalUp] { la[keyPath: k].output = min(1, la[keyPath: k].output) }
            }
        }
        var colliders: [VRMCollider] = [], groups: [[Int]] = [], springs: [VRMSpring] = [], tails: [Int: V3] = [:]
        let sa = v["secondaryAnimation"] as? JObj ?? [:]
        for gAny in sa["colliderGroups"] as? [Any] ?? [] {
            let g = gAny as? JObj ?? [:]
            let node = Int(jnum(g["node"]) ?? -1)
            var ids: [Int] = []
            if node >= 0 && node < doc.nodes.count {
                for c in (g["colliders"] as? [Any] ?? []).compactMap({ $0 as? JObj }) {
                    ids.append(colliders.count)
                    colliders.append(VRMCollider(node: node, offset: v3(c["offset"], flipZ: true), radius: Float(jnum(c["radius"]) ?? 0)))
                }
            }
            groups.append(ids)
        }
        for bAny in sa["boneGroups"] as? [Any] ?? [] {
            guard let b = bAny as? JObj else { continue }
            let stiff = Float(jnum(b["stiffiness"]) ?? jnum(b["stiffness"]) ?? 1), grav = Float(jnum(b["gravityPower"]) ?? 0)
            let dir = b["gravityDir"] != nil ? v3(b["gravityDir"], flipZ: true) : V3(0, -1, 0)
            let drag = Float(jnum(b["dragForce"]) ?? 0.4), hit = Float(jnum(b["hitRadius"]) ?? 0.02)
            let center = jnum(b["center"]).map { Int($0) }.flatMap { $0 >= 0 ? $0 : nil }
            let cg = (b["colliderGroups"] as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } }
            for root in (b["bones"] as? [Any] ?? []).compactMap({ jnum($0).map { Int($0) } }) where root >= 0 && root < doc.nodes.count {
                // every bone under the root swings: a chain per path, each bone's tail its first child (or a point past it)
                var joints: [VRMSpringJoint] = []
                func walk(_ n: Int, _ depth: Int) {
                    if depth > 64 { return }
                    let kids = doc.nodes[n].children
                    let tail = kids.first
                    if tail == nil {
                        let t = doc.nodes[n].translation
                        tails[n] = length3(t) > 1e-6 ? normalize3(t) * 0.07 : V3(0, -0.07, 0)
                    }
                    joints.append(VRMSpringJoint(node: n, tailNode: tail, hitRadius: hit, stiffness: stiff, gravityPower: grav, gravityDir: dir, dragForce: drag))
                    for c in kids { walk(c, depth + 1) }
                }
                walk(root, 0)
                springs.append(VRMSpring(joints: joints, colliderGroups: cg, center: center))
            }
        }
        let m = v["meta"] as? JObj ?? [:]
        func text(_ x: Any?) -> String? { guard let s = x as? String else { return nil }; let t = s.trimmingCharacters(in: .whitespaces); return t.isEmpty || t == "undefined" ? nil : t }
        func yes(_ x: Any?) -> Bool? { if let s = x as? String { return s == "Allow" ? true : s == "Disallow" ? false : nil }; return nil }
        let terms = VRMTerms(spec: "0", name: text(m["title"]), author: text(m["author"]), licenseName: text(m["licenseName"]), licenseURL: text(m["otherLicenseUrl"]),
                             use: text(m["allowedUserName"]), commercial: text(m["commercialUssageName"]), violence: yes(m["violentUssageName"]),
                             sexual: yes(m["sexualUssageName"]), redistribution: nil, modification: nil)
        return VRMInfo(spec: "0", humanBones: bones, expressions: exprs, custom: custom, springs: springs, colliders: colliders,
                       colliderGroups: groups, lookAt: la, terms: terms, virtualTails: tails)
    }
}
