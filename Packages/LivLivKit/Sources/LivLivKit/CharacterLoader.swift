#if canImport(CoreGraphics) && canImport(ImageIO)
import Foundation
import LivLivCore

/// what a folder or a file the user picked holds, once looked through (nothing decoded yet)
public struct CharacterSource: Sendable, Hashable {
    public enum Kind: String, Sendable { case livliv, livlivPackage, png, vrm }
    public let kind: Kind
    /// the folder holding model.json, the package file, the PNGTuber's folder, or the .vrm
    public let url: URL
    public let name: String
    public init(kind: Kind, url: URL, name: String) { self.kind = kind; self.url = url; self.name = name }
}

/// a model's files by path: a folder on disk or an unzipped package
public struct PackageFiles: Sendable {
    private let folder: URL?
    private let files: [String: Data]
    /// the directory inside the package that holds model.json ("" at its root)
    let dir: String

    public init(folder: URL) { self.folder = folder; files = [:]; dir = "" }
    init(files: [String: Data], dir: String) { folder = nil; self.files = files; self.dir = dir }

    public func data(_ path: String) -> Data? {
        let p = path.replacingOccurrences(of: "\\", with: "/")
        if let folder {
            guard isPackagePath(p) else { return nil }
            return try? Data(contentsOf: folder.appendingPathComponent(p), options: .mappedIfSafe)
        }
        if let d = files[dir + p] { return d }
        let name = p.split(separator: "/").last.map(String.init) ?? p
        return files.first { $0.key.split(separator: "/").last.map(String.init) == name }?.value
    }
    public func exists(_ path: String) -> Bool {
        if let folder { return isPackagePath(path) && FileManager.default.fileExists(atPath: folder.appendingPathComponent(path).path) }
        return data(path) != nil
    }

    /// a .livliv / .zip package, unzipped (its files inside one folder or not)
    public static func package(_ zip: Data) throws -> PackageFiles {
        guard Zip.isZip(zip) else {
            if zip.count >= 4, zip.prefix(4) == Data([0x67, 0x6c, 0x54, 0x46]) {
                throw LivLivError(.notAModel, "LivLiv: this is a VRM or glTF file, not a .livliv package")
            }
            throw LivLivError(.notAModel, "LivLiv: this file is not a .livliv package (not a ZIP)")
        }
        let files = try Zip.unzip(zip)
        let json = files.keys.filter { $0 == "model.json" || $0.hasSuffix("/model.json") }.sorted { $0.count < $1.count }.first
        guard let json else { throw LivLivError(.missingFile, "LivLiv: no model.json among the package's files") }
        return PackageFiles(files: files, dir: String(json.dropLast("model.json".count)))
    }
}

/// a LivLiv model with its pictures decoded: what the puppet measures and what the GPU draws
public struct LoadedModel: @unchecked Sendable {
    public struct Textures: @unchecked Sendable {
        public var main: DecodedImage
        public var frames: [DecodedImage]
        public var mask: DecodedImage?
        public var talk: DecodedImage?
        public var brows: DecodedImage?
    }
    public let model: ModelDef
    public let images: [LayerImages]
    public let textures: [Textures]
    public let keyforms: KeyformFile?
    public let warnings: [String]
}

public struct LoadedPNG: @unchecked Sendable {
    public let name: String
    public var pictures: [String: DecodedImage]
}

public enum CharacterLoader {
    static let pngSlots = ["closed", "open", "blink", "blink-open"]
    static let imageExts: Set<String> = ["png", "webp", "jpg", "jpeg", "gif", "heic", "bmp"]

    /// reads model.json and decodes every picture it names (on any thread)
    public static func loadModel(_ files: PackageFiles, lang: String = uiLanguage()) throws -> LoadedModel {
        guard let json = files.data("model.json") else { throw LivLivError(.missingFile, "LivLiv: no model.json among the files") }
        if json.count > Limits.modelJson { throw LivLivError(.tooLarge, "LivLiv: model.json is larger than \(Limits.modelJson) bytes") }
        let model: ModelDef
        do { model = try readModel(try parseJSON(json), lang: lang) } catch let e as LivLivError {
            throw LivLivError(e.code, e.message.hasPrefix("LivLiv") ? e.message : "LivLiv: \(e.message)")
        }
        var warnings: [String] = []
        func image(_ L: LayerDef, _ p: String) throws -> DecodedImage {
            let path = L.webp && p.hasSuffix(".png") ? String(p.dropLast(4)) + ".webp" : p
            guard let d = files.data(path) ?? files.data(p) else { throw LivLivError(.missingFile, "LivLiv: \(path) is not among the files") }
            return try ImageDecoder.decode(d, name: path)
        }
        var images: [LayerImages] = [], textures: [LoadedModel.Textures] = []
        var texels = 0
        for L in model.layers {
            let main = try image(L, L.texture)
            let frames = try (L.frames ?? []).map { try image(L, $0) }
            let mask = try L.mask.map { try image(L, $0) }, talk = try L.talk.map { try image(L, $0) }, brows = try L.browTex.map { try image(L, $0) }
            for d in [main] + frames + [mask, talk, brows].compactMap({ $0 }) {
                texels += d.width * d.height
                if texels > Limits.texels { throw LivLivError(.tooLarge, "LivLiv: this model's images are too large (\(Limits.texels) pixels in all at most)") }
            }
            textures.append(.init(main: main, frames: frames, mask: mask, talk: talk, brows: brows))
            // the rig measures only these: every main picture (eyes, lids, bangs, brows) and the frames' and masks' alpha
            images.append(LayerImages(main: main.straight(), frames: frames.map { $0.straight() }, mask: mask?.straight(), talk: nil, brows: brows?.straight()))
        }
        var keyforms: KeyformFile?
        if let kfPath = model.keyforms {
            if let d = files.data(kfPath), let k = KeyformFile.read(d) { keyforms = k }
            else { warnings.append("\(kfPath) is missing or unreadable; the character plays on the rig alone") }
        }
        return LoadedModel(model: model, images: images, textures: textures, keyforms: keyforms, warnings: warnings)
    }

    /// a PNGTuber's pictures by slot: closed and open at least, blink and blink-open if there (png.ts)
    public static func loadPNG(folder: URL) throws -> LoadedPNG {
        let items = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
        var pics: [String: DecodedImage] = [:]
        var pixels = 0
        for u in items {
            let base = u.deletingPathExtension().lastPathComponent.lowercased()
            guard pngSlots.contains(base), imageExts.contains(u.pathExtension.lowercased()) else { continue }
            let d = try ImageDecoder.decode(try Data(contentsOf: u), name: u.lastPathComponent)
            pixels += d.width * d.height
            if pixels > Limits.texels { throw LivLivError(.tooLarge, "LivLiv: \(u.lastPathComponent) is too large (\(d.width) x \(d.height))") }
            pics[base] = d
        }
        guard pics["closed"] != nil, pics["open"] != nil else {
            throw LivLivError(.missingFile, "LivLiv: a PNGTuber needs at least the closed and the open picture (closed.png, open.png)")
        }
        var name = folder.lastPathComponent
        if let t = try? String(contentsOf: folder.appendingPathComponent("name.txt"), encoding: .utf8) {
            let s = String(t.prefix(200)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !s.isEmpty { name = s }
        }
        return LoadedPNG(name: name, pictures: pics)
    }
}

/// looks through what the user picked before anything loads: what it is, and whether it can open
public enum CharacterInspector {
    public static func inspect(_ url: URL) throws -> CharacterSource {
        let fm = FileManager.default
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: url.path, isDirectory: &isDir) else {
            throw LivLivError(.missingFile, "LivLiv: \(url.lastPathComponent) is not there any more")
        }
        guard fm.isReadableFile(atPath: url.path) else { throw LivLivError(.permission, "LivLiv: \(url.lastPathComponent) cannot be read (no permission)") }
        if !isDir.boolValue { return try inspectFile(url) }
        let items = (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])) ?? []
        // a LivLiv model's folder (model.json here, or in the one folder a "compress folder" made)
        var modelDir: URL?
        if fm.fileExists(atPath: url.appendingPathComponent("model.json").path) { modelDir = url }
        else {
            let subs = items.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }
            if subs.count == 1, fm.fileExists(atPath: subs[0].appendingPathComponent("model.json").path) { modelDir = subs[0] }
        }
        if let modelDir {
            try checkModel(PackageFiles(folder: modelDir), where: modelDir.lastPathComponent)
            return CharacterSource(kind: .livliv, url: modelDir, name: url.lastPathComponent)
        }
        let names = Set(items.map { $0.deletingPathExtension().lastPathComponent.lowercased() })
        if names.contains("closed") || names.contains("open") {
            guard names.contains("closed") && names.contains("open") else {
                throw LivLivError(.missingFile, "LivLiv: a PNGTuber folder needs both closed.png and open.png (found only \(names.contains("closed") ? "closed" : "open"))")
            }
            return CharacterSource(kind: .png, url: url, name: url.lastPathComponent)
        }
        let vrms = items.filter { ["vrm", "glb"].contains($0.pathExtension.lowercased()) }
        if vrms.count == 1 { return try inspectFile(vrms[0]) }
        let packages = items.filter { ["livliv", "zip"].contains($0.pathExtension.lowercased()) }
        if packages.count == 1 { return try inspectFile(packages[0]) }
        if vrms.count > 1 || packages.count > 1 {
            throw LivLivError(.invalid, "LivLiv: this folder holds several characters (\(vrms.count + packages.count) files): pick one of them")
        }
        throw LivLivError(.notAModel, "LivLiv: this folder holds no character: no model.json, no closed.png / open.png, no .vrm and no .livliv")
    }

    static func inspectFile(_ url: URL) throws -> CharacterSource {
        let ext = url.pathExtension.lowercased()
        let data: Data
        do { data = try Data(contentsOf: url, options: .mappedIfSafe) } catch {
            throw LivLivError(.permission, "LivLiv: \(url.lastPathComponent) cannot be read (\(error.localizedDescription))")
        }
        let base = url.deletingPathExtension().lastPathComponent
        if ["vrm", "glb"].contains(ext) || (data.count >= 4 && data.prefix(4) == Data([0x67, 0x6c, 0x54, 0x46])) {
            let doc = try GLTFDocument.read(data, name: url.lastPathComponent)
            _ = try VRMInfo.read(doc, name: url.lastPathComponent)
            if !doc.nodes.contains(where: { $0.mesh != nil }) {
                throw LivLivError(.invalid, "LivLiv: \(url.lastPathComponent) has a skeleton but no mesh, so there is nothing to draw")
            }
            return CharacterSource(kind: .vrm, url: url, name: base)
        }
        if ["livliv", "zip"].contains(ext) || Zip.isZip(data) {
            try checkModel(try PackageFiles.package(data), where: url.lastPathComponent)
            return CharacterSource(kind: .livlivPackage, url: url, name: base)
        }
        if ext == "json" && url.lastPathComponent == "model.json" { return try inspect(url.deletingLastPathComponent()) }
        throw LivLivError(.notAModel, "LivLiv: \(url.lastPathComponent) is not a character this player opens (.livliv, .vrm, or a folder)")
    }

    /// model.json reads, and every picture it names is there
    static func checkModel(_ files: PackageFiles, where place: String) throws {
        guard let json = files.data("model.json") else { throw LivLivError(.missingFile, "LivLiv: no model.json in \(place)") }
        if json.count > Limits.modelJson { throw LivLivError(.tooLarge, "LivLiv: model.json is larger than \(Limits.modelJson) bytes") }
        let m = try readModel(try parseJSON(json))
        var missing: [String] = []
        for L in m.layers {
            for p in [L.texture] + (L.frames ?? []) + [L.mask, L.talk, L.browTex].compactMap({ $0 }) {
                let alt = L.webp && p.hasSuffix(".png") ? String(p.dropLast(4)) + ".webp" : p
                if !files.exists(alt) && !files.exists(p) { missing.append(alt) }
            }
        }
        if !missing.isEmpty {
            let list = missing.prefix(5).joined(separator: ", ") + (missing.count > 5 ? " … (\(missing.count) in all)" : "")
            throw LivLivError(.missingFile, "LivLiv: pictures the model names are missing: \(list)")
        }
    }
}
#endif
