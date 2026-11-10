// A binary glTF 2.0 (.glb / .vrm) reader: what a VRM needs to be drawn (nodes, skins, meshes with morph targets,
// materials, embedded images), with the limits vrm.ts held a file to before parsing it (checkGlb).
import Foundation

public enum VRMLimits {
    public static let json = 32 * (1 << 20), textureSide = 8192, texels = 512 * (1 << 20), vertices = 16 * (1 << 20)
    public static let fileBytes = 256 * (1 << 20)
}

public struct GLTFNode: Sendable {
    public var name: String
    public var children: [Int]
    public var mesh: Int?
    public var skin: Int?
    public var translation: V3
    public var rotation: Quat
    public var scale: V3
}

public struct GLTFPrimitive: Sendable {
    public var positions: [V3]
    public var normals: [V3]?
    public var uvs: [SIMD2<Float>]?
    public var joints: [SIMD4<UInt16>]?
    public var weights: [V4]?
    public var indices: [UInt32]
    public var material: Int?
    /// morph targets: position deltas per vertex
    public var targets: [[V3]]
}

public struct GLTFMaterial: Sendable {
    public enum AlphaMode: String, Sendable { case opaque = "OPAQUE", mask = "MASK", blend = "BLEND" }
    public var name: String
    public var baseColor: V4
    public var baseColorTexture: Int?
    /// KHR_texture_transform on the base colour (the VRM add-on for Blender writes it from a Mapping node)
    public var baseColorTransform: GLTFUVTransform?
    public var alphaMode: AlphaMode
    public var alphaCutoff: Float
    public var doubleSided: Bool
    public var emissive: V3
    /// MToon's shade colour, where the material has one (VRMC_materials_mtoon, or VRM 0.x's materialProperties)
    public var shadeColor: V3?
    public var unlit: Bool
}

/// KHR_texture_transform: offset, rotation (radians) and scale of a texture's UVs
public struct GLTFUVTransform: Sendable, Equatable {
    public var offset = SIMD2<Float>(0, 0)
    public var rotation: Float = 0
    public var scale = SIMD2<Float>(1, 1)
    public init(offset: SIMD2<Float> = .init(0, 0), rotation: Float = 0, scale: SIMD2<Float> = .init(1, 1)) {
        self.offset = offset; self.rotation = rotation; self.scale = scale
    }
    public var isIdentity: Bool { self == GLTFUVTransform() }
    /// as three.js applies it (Matrix3.setUvTransform with the centre at 0), so a file looks as it does in the original player
    public func apply(_ uv: SIMD2<Float>) -> SIMD2<Float> {
        let c = cos(rotation), s = sin(rotation)
        return SIMD2(scale.x * (c * uv.x + s * uv.y) + offset.x, scale.y * (-s * uv.x + c * uv.y) + offset.y)
    }
}

/// a texture's sampler; glTF's default is REPEAT both ways with linear filtering
public struct GLTFSampler: Sendable, Equatable {
    public enum Wrap: Sendable { case repeating, mirrored, clamp }
    public var wrapS = Wrap.repeating, wrapT = Wrap.repeating
    /// NEAREST (9728) asked for magnification: pixel art
    public var nearest = false
    public init() {}
}

public struct GLTFSkin: Sendable { public var joints: [Int]; public var inverseBindMatrices: [Mat4] }

public struct GLTFDocument {
    public let json: JObj
    public let bin: Data
    public var nodes: [GLTFNode] = []
    public var meshes: [[GLTFPrimitive]] = []
    public var skins: [GLTFSkin] = []
    public var materials: [GLTFMaterial] = []
    /// texture index -> image index
    public var textureSources: [Int?] = []
    /// texture index -> its sampler
    public var textureSamplers: [GLTFSampler] = []
    public var images: [(data: Data, mime: String)] = []
    public var sceneRoots: [Int] = []
    public var parents: [Int?] = []
    public var extensionsUsed: [String] = []

    /// reads a .glb / .vrm file. Throws LivLivError with a message saying what is wrong
    public static func read(_ data: Data, name: String) throws -> GLTFDocument {
        func bad(_ why: String, _ code: LivLivError.Code = .invalid) -> LivLivError { LivLivError(code, "LivLiv: \(name) \(why)") }
        let b = [UInt8](data.prefix(20))
        func u32(_ bytes: [UInt8], _ o: Int) -> Int { Int(bytes[o]) | Int(bytes[o + 1]) << 8 | Int(bytes[o + 2]) << 16 | Int(bytes[o + 3]) << 24 }
        if data.count > VRMLimits.fileBytes { throw bad("is larger than \(VRMLimits.fileBytes) bytes", .tooLarge) }
        guard b.count >= 20, u32(b, 0) == 0x46546c67 else { throw bad("is not a VRM: it should begin as a binary glTF does", .notAModel) }
        guard u32(b, 4) == 2 else { throw bad("is a glTF of version \(u32(b, 4)), and VRM uses 2", .notAModel) }
        let jsonLen = u32(b, 12)
        guard u32(b, 16) == 0x4e4f534a else { throw bad("is damaged (no JSON where a binary glTF has it)") }
        if jsonLen > VRMLimits.json { throw bad("is not one this player reads: its JSON has \(jsonLen) bytes, more than \(VRMLimits.json)", .tooLarge) }
        if 20 + jsonLen > data.count { throw bad("is damaged or cut short") }
        let jdata = data.subdata(in: (data.startIndex + 20)..<(data.startIndex + 20 + jsonLen))
        guard let json = (try? JSONSerialization.jsonObject(with: jdata)) as? JObj else { throw bad("is damaged (its JSON does not parse)") }
        var bin = Data()
        let binStart = 20 + jsonLen
        if binStart + 8 <= data.count {
            let h = [UInt8](data.subdata(in: (data.startIndex + binStart)..<(data.startIndex + binStart + 8)))
            let len = u32(h, 0)
            if u32(h, 4) == 0x004E4942, binStart + 8 + len <= data.count {
                bin = data.subdata(in: (data.startIndex + binStart + 8)..<(data.startIndex + binStart + 8 + len))
            }
        }
        var doc = GLTFDocument(json: json, bin: bin)
        try doc.parse(name: name)
        return doc
    }

    private mutating func parse(name: String) throws {
        func bad(_ why: String, _ code: LivLivError.Code = .invalid) -> LivLivError { LivLivError(code, "LivLiv: \(name) \(why)") }
        extensionsUsed = (json["extensionsUsed"] as? [Any] ?? []).compactMap { $0 as? String }
        // compression the file needs: required, or on a primitive / buffer view / texture. A name only in extensionsUsed
        // (an exporter's leftover, as the VRM add-on for Blender can write) does not stop it
        let required = (json["extensionsRequired"] as? [Any] ?? []).compactMap { $0 as? String }
        func onAny(_ key: String, _ ext: String) -> Bool {
            (json[key] as? [Any] ?? []).contains { ((($0 as? JObj)?["extensions"] as? JObj)?[ext]) != nil }
        }
        func onPrimitive(_ ext: String) -> Bool {
            (json["meshes"] as? [Any] ?? []).contains { m in
                (((m as? JObj)?["primitives"] as? [Any]) ?? []).contains { ((($0 as? JObj)?["extensions"] as? JObj)?[ext]) != nil }
            }
        }
        let compressed: [(String, String, Bool)] = [
            ("KHR_draco_mesh_compression", "Draco", onPrimitive("KHR_draco_mesh_compression")),
            ("EXT_meshopt_compression", "Meshopt", onAny("bufferViews", "EXT_meshopt_compression")),
            ("KHR_meshopt_compression", "Meshopt", onAny("bufferViews", "KHR_meshopt_compression")),
            ("KHR_texture_basisu", "KTX2", onAny("textures", "KHR_texture_basisu")),
        ]
        for (ext, what, used) in compressed where required.contains(ext) || used {
            throw bad("is compressed with \(what), and this player has no decoder for that. Export it uncompressed", .missingFeature)
        }
        // other required extensions are VRM's own or change only how a material looks; the file still plays
        for o in (json["buffers"] as? [Any] ?? []) + (json["images"] as? [Any] ?? []) {
            if let uri = (o as? JObj)?["uri"] as? String, !uri.hasPrefix("data:") {
                throw bad("names a file outside itself (\(uri.prefix(80))), and a .vrm has to hold everything it needs")
            }
        }
        let accessors = json["accessors"] as? [Any] ?? []
        let views = json["bufferViews"] as? [Any] ?? []
        // vertices, by POSITION accessor, before reading any of them
        var positionsSeen = Set<Int>(), total = 0
        for m in json["meshes"] as? [Any] ?? [] {
            for p in ((m as? JObj)?["primitives"] as? [Any]) ?? [] {
                if let i = jnum(((p as? JObj)?["attributes"] as? JObj)?["POSITION"]).map({ Int($0) }), positionsSeen.insert(i).inserted {
                    total += Int(jnum((accessors[safe: i] as? JObj)?["count"]) ?? 0)
                }
            }
        }
        if total > VRMLimits.vertices { throw bad("has \(total) vertices, more than \(VRMLimits.vertices)", .tooLarge) }

        func viewBytes(_ vi: Int) throws -> (Data, Int?) {
            guard let v = views[safe: vi] as? JObj else { throw bad("is damaged (a buffer view is missing)") }
            let off = Int(jnum(v["byteOffset"]) ?? 0), len = Int(jnum(v["byteLength"]) ?? 0)
            if (jnum(v["buffer"]) ?? 0) != 0 { throw bad("uses a second buffer, which a binary glTF does not have") }
            guard off >= 0, len >= 0, off + len <= bin.count else { throw bad("is damaged (a buffer view runs past the data)") }
            return (bin.subdata(in: (bin.startIndex + off)..<(bin.startIndex + off + len)), jnum(v["byteStride"]).map { Int($0) })
        }
        func comps(_ type: String) -> Int {
            switch type { case "SCALAR": return 1; case "VEC2": return 2; case "VEC3": return 3; case "VEC4": return 4; case "MAT4": return 16; default: return 0 }
        }
        func componentSize(_ ct: Int) -> Int { switch ct { case 5120, 5121: return 1; case 5122, 5123: return 2; case 5125, 5126: return 4; default: return 0 } }
        func readComponent(_ d: UnsafeRawBufferPointer, _ o: Int, _ ct: Int, _ normalized: Bool) -> Float {
            switch ct {
            case 5126: return d.loadUnaligned(fromByteOffset: o, as: Float.self)
            case 5121: let v = d[o]; return normalized ? Float(v) / 255 : Float(v)
            case 5120: let v = Int8(bitPattern: d[o]); return normalized ? max(Float(v) / 127, -1) : Float(v)
            case 5123: let v = d.loadUnaligned(fromByteOffset: o, as: UInt16.self); return normalized ? Float(v) / 65535 : Float(v)
            case 5122: let v = d.loadUnaligned(fromByteOffset: o, as: Int16.self); return normalized ? max(Float(v) / 32767, -1) : Float(v)
            case 5125: return Float(d.loadUnaligned(fromByteOffset: o, as: UInt32.self))
            default: return 0
            }
        }
        /// an accessor as floats, n components per element (sparse values applied)
        func floats(_ ai: Int) throws -> (values: [Float], n: Int, count: Int) {
            guard let a = accessors[safe: ai] as? JObj, let type = a["type"] as? String, let ctD = jnum(a["componentType"]) else { throw bad("is damaged (an accessor is missing)") }
            let ct = Int(ctD), n = comps(type), cs = componentSize(ct), count = Int(jnum(a["count"]) ?? 0)
            guard n > 0, cs > 0, count >= 0 else { throw bad("is damaged (an accessor has an unknown type)") }
            let normalized = jbool(a["normalized"]) ?? false
            var out = [Float](repeating: 0, count: count * n)
            if let vi = jnum(a["bufferView"]).map({ Int($0) }) {
                let (d, strideOpt) = try viewBytes(vi)
                let off = Int(jnum(a["byteOffset"]) ?? 0), stride = strideOpt ?? n * cs
                guard count == 0 || off + (count - 1) * stride + n * cs <= d.count else { throw bad("is damaged (an accessor runs past its view)") }
                d.withUnsafeBytes { p in
                    for i in 0..<count { for k in 0..<n { out[i * n + k] = readComponent(p, off + i * stride + k * cs, ct, normalized) } }
                }
            }
            if let sp = a["sparse"] as? JObj, let sc = jnum(sp["count"]).map({ Int($0) }), sc > 0,
               let si = sp["indices"] as? JObj, let sv = sp["values"] as? JObj,
               let ivi = jnum(si["bufferView"]).map({ Int($0) }), let vvi = jnum(sv["bufferView"]).map({ Int($0) }) {
                let ict = Int(jnum(si["componentType"]) ?? 5125), ics = componentSize(ict)
                let (id, _) = try viewBytes(ivi), (vd, _) = try viewBytes(vvi)
                let ioff = Int(jnum(si["byteOffset"]) ?? 0), voff = Int(jnum(sv["byteOffset"]) ?? 0)
                guard ioff + sc * ics <= id.count, voff + sc * n * cs <= vd.count else { throw bad("is damaged (a sparse accessor runs past its view)") }
                var idx = [Int](repeating: 0, count: sc)
                id.withUnsafeBytes { p in for i in 0..<sc { idx[i] = Int(readComponent(p, ioff + i * ics, ict, false)) } }
                vd.withUnsafeBytes { p in
                    for i in 0..<sc where idx[i] < count {
                        for k in 0..<n { out[idx[i] * n + k] = readComponent(p, voff + (i * n + k) * cs, ct, normalized) }
                    }
                }
            }
            return (out, n, count)
        }
        func vec3s(_ ai: Int) throws -> [V3] {
            let f = try floats(ai)
            guard f.n == 3 else { throw bad("is damaged (a VEC3 attribute has \(f.n) components)") }
            return (0..<f.count).map { V3(f.values[3 * $0], f.values[3 * $0 + 1], f.values[3 * $0 + 2]) }
        }

        // nodes
        for nAny in json["nodes"] as? [Any] ?? [] {
            let n = nAny as? JObj ?? [:]
            var t = V3(0, 0, 0), r = Quat.identity, s = V3(1, 1, 1)
            if let m = jnums(n["matrix"]), m.count == 16 {
                let M = Mat4(columnMajor: m.map(Float.init))
                t = M.translation; r = M.rotation
                s = V3(length3(V3(M.c0.x, M.c0.y, M.c0.z)), length3(V3(M.c1.x, M.c1.y, M.c1.z)), length3(V3(M.c2.x, M.c2.y, M.c2.z)))
            } else {
                if let v = jnums(n["translation"]), v.count == 3 { t = V3(Float(v[0]), Float(v[1]), Float(v[2])) }
                if let v = jnums(n["rotation"]), v.count == 4 { r = Quat(x: Float(v[0]), y: Float(v[1]), z: Float(v[2]), w: Float(v[3])).normalized }
                if let v = jnums(n["scale"]), v.count == 3 { s = V3(Float(v[0]), Float(v[1]), Float(v[2])) }
            }
            nodes.append(GLTFNode(name: n["name"] as? String ?? "", children: (n["children"] as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } },
                                  mesh: jnum(n["mesh"]).map { Int($0) }, skin: jnum(n["skin"]).map { Int($0) }, translation: t, rotation: r, scale: s))
        }
        parents = [Int?](repeating: nil, count: nodes.count)
        for (i, n) in nodes.enumerated() {
            for c in n.children {
                guard c >= 0, c < nodes.count, c != i, parents[c] == nil else { throw bad("is damaged (its node tree is not a tree)") }
                parents[c] = i
            }
        }
        let scenes = json["scenes"] as? [Any] ?? []
        let si = Int(jnum(json["scene"]) ?? 0)
        sceneRoots = (((scenes[safe: si] as? JObj)?["nodes"]) as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } }.filter { $0 >= 0 && $0 < nodes.count }
        if sceneRoots.isEmpty { sceneRoots = nodes.indices.filter { parents[$0] == nil } }

        // meshes
        for mAny in json["meshes"] as? [Any] ?? [] {
            var prims: [GLTFPrimitive] = []
            for pAny in ((mAny as? JObj)?["primitives"] as? [Any]) ?? [] {
                guard let p = pAny as? JObj, let at = p["attributes"] as? JObj, let pi = jnum(at["POSITION"]).map({ Int($0) }) else { continue }
                let mode = Int(jnum(p["mode"]) ?? 4)
                if mode != 4 { continue }  // triangles only
                let pos = try vec3s(pi)
                var prim = GLTFPrimitive(positions: pos, normals: nil, uvs: nil, joints: nil, weights: nil, indices: [], material: jnum(p["material"]).map { Int($0) }, targets: [])
                if let ni = jnum(at["NORMAL"]).map({ Int($0) }) { prim.normals = try vec3s(ni) }
                if let ti = jnum(at["TEXCOORD_0"]).map({ Int($0) }) {
                    let f = try floats(ti)
                    if f.n == 2 { prim.uvs = (0..<f.count).map { SIMD2(f.values[2 * $0], f.values[2 * $0 + 1]) } }
                }
                if let ji = jnum(at["JOINTS_0"]).map({ Int($0) }), let wi = jnum(at["WEIGHTS_0"]).map({ Int($0) }) {
                    let j = try floats(ji), w = try floats(wi)
                    if j.n == 4 && w.n == 4 {
                        prim.joints = (0..<j.count).map { SIMD4(UInt16(j.values[4 * $0]), UInt16(j.values[4 * $0 + 1]), UInt16(j.values[4 * $0 + 2]), UInt16(j.values[4 * $0 + 3])) }
                        prim.weights = (0..<w.count).map { V4(w.values[4 * $0], w.values[4 * $0 + 1], w.values[4 * $0 + 2], w.values[4 * $0 + 3]) }
                    }
                }
                if let ii = jnum(p["indices"]).map({ Int($0) }) {
                    let f = try floats(ii)
                    prim.indices = f.values.map { UInt32($0) }
                } else {
                    prim.indices = (0..<UInt32(pos.count)).map { $0 }
                }
                let vc = UInt32(pos.count)
                if prim.indices.contains(where: { $0 >= vc }) { throw bad("is damaged (a triangle names a vertex that is not there)") }
                for tAny in p["targets"] as? [Any] ?? [] {
                    if let t = tAny as? JObj, let tp = jnum(t["POSITION"]).map({ Int($0) }) {
                        let d = try vec3s(tp)
                        prim.targets.append(d.count == pos.count ? d : [V3](repeating: V3(0, 0, 0), count: pos.count))
                    } else {
                        prim.targets.append([V3](repeating: V3(0, 0, 0), count: pos.count))
                    }
                }
                prims.append(prim)
            }
            meshes.append(prims)
        }
        // skins
        for sAny in json["skins"] as? [Any] ?? [] {
            let s = sAny as? JObj ?? [:]
            let joints = (s["joints"] as? [Any] ?? []).compactMap { jnum($0).map { Int($0) } }
            var ibm = [Mat4](repeating: .identity, count: joints.count)
            if let ai = jnum(s["inverseBindMatrices"]).map({ Int($0) }) {
                let f = try floats(ai)
                if f.n == 16 { for i in 0..<min(f.count, joints.count) { ibm[i] = Mat4(columnMajor: Array(f.values[(16 * i)..<(16 * i + 16)])) } }
            }
            if joints.contains(where: { $0 < 0 || $0 >= nodes.count }) { throw bad("is damaged (a skin names a node that is not there)") }
            skins.append(GLTFSkin(joints: joints, inverseBindMatrices: ibm))
        }
        // images and their sizes, against the limits
        var texels = 0
        for imAny in json["images"] as? [Any] ?? [] {
            let im = imAny as? JObj ?? [:]
            var d = Data(), mime = im["mimeType"] as? String ?? ""
            if let vi = jnum(im["bufferView"]).map({ Int($0) }) { d = try viewBytes(vi).0 }
            else if let uri = im["uri"] as? String, uri.hasPrefix("data:"), let comma = uri.firstIndex(of: ",") {
                d = Data(base64Encoded: String(uri[uri.index(after: comma)...])) ?? Data()
                if mime.isEmpty { mime = String(uri.dropFirst(5).prefix { $0 != ";" }) }
            }
            if let size = pictureSize(d) {
                texels += size.0 * size.1
                if size.0 > VRMLimits.textureSide || size.1 > VRMLimits.textureSide || texels > VRMLimits.texels {
                    throw bad("has pictures too large for this player (\(size.0) x \(size.1); \(VRMLimits.textureSide) px a side and \(VRMLimits.texels) pixels in all at most)", .tooLarge)
                }
            }
            images.append((d, mime))
        }
        textureSources = (json["textures"] as? [Any] ?? []).map { t in jnum((t as? JObj)?["source"]).map { Int($0) } }
        let samplers = json["samplers"] as? [Any] ?? []
        textureSamplers = (json["textures"] as? [Any] ?? []).map { t in
            var out = GLTFSampler()
            guard let si = jnum((t as? JObj)?["sampler"]).map({ Int($0) }), let s = samplers[safe: si] as? JObj else { return out }
            func wrap(_ v: Any?) -> GLTFSampler.Wrap { switch jnum(v).map({ Int($0) }) { case 33071: .clamp; case 33648: .mirrored; default: .repeating } }
            out.wrapS = wrap(s["wrapS"]); out.wrapT = wrap(s["wrapT"])
            out.nearest = jnum(s["magFilter"]).map { Int($0) } == 9728
            return out
        }
        func uvTransform(_ info: Any?) -> GLTFUVTransform? {
            guard let t = ((info as? JObj)?["extensions"] as? JObj)?["KHR_texture_transform"] as? JObj else { return nil }
            var x = GLTFUVTransform()
            if let o = jnums(t["offset"]), o.count >= 2 { x.offset = SIMD2(Float(o[0]), Float(o[1])) }
            if let r = jnum(t["rotation"]) { x.rotation = Float(r) }
            if let sc = jnums(t["scale"]), sc.count >= 2 { x.scale = SIMD2(Float(sc[0]), Float(sc[1])) }
            let finite = x.offset.x.isFinite && x.offset.y.isFinite && x.rotation.isFinite && x.scale.x.isFinite && x.scale.y.isFinite
            return finite && !x.isIdentity ? x : nil
        }
        // materials (and VRM 0.x's MToon properties, by material name)
        let v0props = (((json["extensions"] as? JObj)?["VRM"] as? JObj)?["materialProperties"] as? [Any] ?? []).compactMap { $0 as? JObj }
        for mAny in json["materials"] as? [Any] ?? [] {
            let m = mAny as? JObj ?? [:]
            let pbr = m["pbrMetallicRoughness"] as? JObj ?? [:]
            let bc = jnums(pbr["baseColorFactor"]) ?? [1, 1, 1, 1]
            let ext = m["extensions"] as? JObj ?? [:]
            let em = jnums(m["emissiveFactor"]) ?? [0, 0, 0]
            var mat = GLTFMaterial(name: m["name"] as? String ?? "", baseColor: V4(bc.map(Float.init).padded(to: 4, with: 1)),
                                   baseColorTexture: jnum((pbr["baseColorTexture"] as? JObj)?["index"]).map { Int($0) },
                                   baseColorTransform: nil,
                                   alphaMode: GLTFMaterial.AlphaMode(rawValue: m["alphaMode"] as? String ?? "OPAQUE") ?? .opaque,
                                   alphaCutoff: Float(jnum(m["alphaCutoff"]) ?? 0.5), doubleSided: jbool(m["doubleSided"]) ?? false,
                                   emissive: V3(Float(em[safe: 0] ?? 0), Float(em[safe: 1] ?? 0), Float(em[safe: 2] ?? 0)),
                                   shadeColor: nil, unlit: ext["KHR_materials_unlit"] != nil)
            mat.baseColorTransform = uvTransform(pbr["baseColorTexture"])
            if let mt = ext["VRMC_materials_mtoon"] as? JObj, let sc = jnums(mt["shadeColorFactor"]), sc.count >= 3 {
                mat.shadeColor = V3(Float(sc[0]), Float(sc[1]), Float(sc[2]))
            }
            if let p = v0props.first(where: { ($0["name"] as? String) == mat.name }), (p["shader"] as? String)?.contains("MToon") == true {
                let vec = p["vectorProperties"] as? JObj ?? [:], fl = p["floatProperties"] as? JObj ?? [:], tx = p["textureProperties"] as? JObj ?? [:]
                if let c = jnums(vec["_Color"]), c.count == 4 { mat.baseColor = V4(c.map(Float.init)) }
                if let s = jnums(vec["_ShadeColor"]), s.count >= 3 { mat.shadeColor = V3(Float(s[0]), Float(s[1]), Float(s[2])) }
                if let t = jnum(tx["_MainTex"]) { mat.baseColorTexture = Int(t) }
                let blend = jnum(fl["_BlendMode"]) ?? 0  // 0 opaque, 1 cutout, 2 transparent, 3 transparent with z-write
                mat.alphaMode = blend == 1 ? .mask : blend >= 2 ? .blend : .opaque
                if let c = jnum(fl["_Cutoff"]) { mat.alphaCutoff = Float(c) }
                if let cull = jnum(fl["_CullMode"]) { mat.doubleSided = cull == 0 }
            }
            materials.append(mat)
        }
    }

    /// each node's index in an order where parents come first
    public var topologicalOrder: [Int] {
        var out: [Int] = [], stack = sceneRoots.reversed().map { $0 }
        var seen = Set<Int>()
        while let n = stack.popLast() {
            if !seen.insert(n).inserted { continue }
            out.append(n)
            for c in nodes[n].children.reversed() { stack.append(c) }
        }
        for i in nodes.indices where !seen.contains(i) { out.append(i) }
        return out
    }
}

/// a PNG's or JPEG's size from its first bytes
func pictureSize(_ d: Data) -> (Int, Int)? {
    let b = [UInt8](d.prefix(64 * 1024))
    if b.count >= 24 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4e && b[3] == 0x47 {
        func be32(_ o: Int) -> Int { Int(b[o]) << 24 | Int(b[o + 1]) << 16 | Int(b[o + 2]) << 8 | Int(b[o + 3]) }
        return (be32(16), be32(20))
    }
    guard b.count >= 4, b[0] == 0xff, b[1] == 0xd8 else { return nil }
    var i = 2
    while i + 9 < b.count {
        if b[i] != 0xff { i += 1; continue }
        let m = b[i + 1]
        if m >= 0xc0 && m <= 0xcf && m != 0xc4 && m != 0xc8 && m != 0xcc {
            return (Int(b[i + 7]) << 8 | Int(b[i + 8]), Int(b[i + 5]) << 8 | Int(b[i + 6]))
        }
        i += 2 + (Int(b[i + 2]) << 8 | Int(b[i + 3]))
    }
    return nil
}

extension Array {
    /// the element at i, or nil past either end
    public subscript(safe i: Int) -> Element? { i >= 0 && i < count ? self[i] : nil }
    func padded(to n: Int, with v: Element) -> [Element] { count >= n ? Array(prefix(n)) : self + [Element](repeating: v, count: n - count) }
}
