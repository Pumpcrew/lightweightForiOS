// A .livliv package: the model's folder as a ZIP, read here without a library (zip.ts). Stored entries everywhere;
// deflated ones where the platform has an inflater (Apple: the Compression framework). No encryption, no ZIP64, no paths
// outside the package.
import Foundation
#if canImport(Compression)
import Compression
#endif

public enum Zip {
    public static let maxEntries = 2048, maxBytes = 256 * (1 << 20)

    /// whether these bytes begin a ZIP (a local file header, or the end record of an empty one)
    public static func isZip(_ d: Data) -> Bool {
        guard d.count >= 4 else { return false }
        let h = [UInt8](d.prefix(4))
        return h[0] == 0x50 && h[1] == 0x4b && ((h[2] == 3 && h[3] == 4) || (h[2] == 5 && h[3] == 6))
    }

    public static var canInflate: Bool {
        #if canImport(Compression)
        return true
        #else
        return false
        #endif
    }

    /// the package's files by path (no folders, no __MACOSX / ._ / .DS_Store litter)
    public static func unzip(_ zip: Data) throws -> [String: Data] {
        let b = [UInt8](zip)
        func fail(_ why: String, _ code: LivLivError.Code = .invalid) -> LivLivError { LivLivError(code, "LivLiv: \(why)") }
        func u16(_ o: Int) -> Int { Int(b[o]) | Int(b[o + 1]) << 8 }
        func u32(_ o: Int) -> Int { Int(b[o]) | Int(b[o + 1]) << 8 | Int(b[o + 2]) << 16 | Int(b[o + 3]) << 24 }
        guard b.count >= 22 else { throw fail("this is not a ZIP (no end record)", .notAModel) }
        var e = -1
        var i = b.count - 22
        let stop = max(0, b.count - 22 - 0xffff)
        while i >= stop { if u32(i) == 0x06054b50 { e = i; break }; i -= 1 }
        if e < 0 { throw fail("this is not a ZIP (no end record)", .notAModel) }
        let count = u16(e + 10), cdSize = u32(e + 12), cdOff = u32(e + 16)
        if count == 0xffff || cdSize == 0xffffffff || cdOff == 0xffffffff { throw fail("ZIP64 packages are not supported", .tooLarge) }
        if count > maxEntries { throw fail("the package has \(count) entries, more than \(maxEntries)", .tooLarge) }
        guard cdOff + cdSize <= b.count else { throw fail("the package is damaged (central directory)") }
        var out: [String: Data] = [:]
        var total = 0, o = cdOff
        for _ in 0..<count {
            guard o + 46 <= cdOff + cdSize, u32(o) == 0x02014b50 else { throw fail("the package is damaged (central directory)") }
            let flags = u16(o + 8), method = u16(o + 10)
            let csize = u32(o + 20), usize = u32(o + 24)
            let nlen = u16(o + 28), elen = u16(o + 30), clen = u16(o + 32)
            let local = u32(o + 42)
            guard o + 46 + nlen <= b.count else { throw fail("the package is damaged (central directory)") }
            let raw = String(decoding: b[(o + 46)..<(o + 46 + nlen)], as: UTF8.self)
            o += 46 + nlen + elen + clen
            let name = raw.replacingOccurrences(of: "\\", with: "/")
            let base = name.split(separator: "/", omittingEmptySubsequences: false).last.map(String.init) ?? name
            if name.hasSuffix("/") || name.hasPrefix("__MACOSX/") || base.hasPrefix("._") || base == ".DS_Store" || base == "Thumbs.db" { continue }
            let drive = name.count >= 2 && name[name.index(after: name.startIndex)] == ":" && name.first!.isLetter
            if name.hasPrefix("/") || drive || name.split(separator: "/", omittingEmptySubsequences: false).contains(where: { $0 == ".." || $0 == "." }) {
                throw fail("the package holds a path outside itself: \(raw)")
            }
            if flags & 1 != 0 { throw fail("\(name) is encrypted") }
            if out[name] != nil { throw fail("\(name) is in the package twice") }
            let isKeyforms = base == "keyforms.json"
            let cap = base == "model.json" ? Limits.modelJson : isKeyforms ? Limits.keyforms : maxBytes
            total += usize
            if usize > cap || total > maxBytes { throw fail("\(name) is too large (\(usize) bytes)", .tooLarge) }
            guard local + 30 <= b.count, u32(local) == 0x04034b50 else { throw fail("the package is damaged (\(name))") }
            let start = local + 30 + u16(local + 26) + u16(local + 28)
            if start + csize > b.count { throw fail("the package is damaged (\(name) runs past its end)") }
            let data = zip.subdata(in: (zip.startIndex + start)..<(zip.startIndex + start + csize))
            if method == 0 {
                if csize != usize { throw fail("the package is damaged (\(name))") }
                out[name] = data
            } else if method == 8 {
                guard canInflate else {
                    if isKeyforms { continue }
                    throw fail("this device cannot open the compressed \(name): store it uncompressed", .missingFeature)
                }
                out[name] = try inflate(data, size: usize, name: name)
            } else {
                throw fail("\(name) uses ZIP method \(method); a package stores its files or deflates them")
            }
        }
        return out
    }

    /// a deflated entry, never past the size its directory gives (a ZIP bomb stops there)
    static func inflate(_ data: Data, size: Int, name: String) throws -> Data {
        #if canImport(Compression)
        if size == 0 { return Data() }
        var out = Data(count: size + 1)
        let n = out.withUnsafeMutableBytes { (dst: UnsafeMutableRawBufferPointer) -> Int in
            data.withUnsafeBytes { (src: UnsafeRawBufferPointer) -> Int in
                compression_decode_buffer(dst.bindMemory(to: UInt8.self).baseAddress!, size + 1,
                                          src.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_ZLIB)
            }
        }
        if n != size { throw LivLivError(.invalid, "LivLiv: the package is damaged (\(name): \(n) bytes, \(size) expected)") }
        out.removeLast()
        return out
        #else
        throw LivLivError(.missingFeature, "LivLiv: this platform cannot inflate \(name)")
        #endif
    }
}
