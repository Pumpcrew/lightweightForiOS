// keyforms.json: for each key pose (angleX or angleY at `value`) one displacement field per layer group on a `cell` px
// grid, int16 dx, dy in `units` px, rows x cols, base64 (puppet.ts KeyformFile, keyformsFit)
import Foundation

public struct KeyformKey: Sendable {
    public enum Param: String, Sendable { case angleX, angleY, diag }
    public var param: Param
    public var value: Double
    public var fields: [String: String]
    public var same: [String]?
}

public struct KeyformFile: Sendable {
    public var version: Int
    public var cell: Double, cols: Int, rows: Int, units: Double, turn: Double, nod: Double
    public var keys: [KeyformKey]
    public var mask: [String: String]?
    public var hermite: Bool

    /// a keyforms.json the runtime can read safely (an untrusted file: a field of the wrong size would be read past its
    /// end): version 1, its grid in range, at most 32 keys, every field and mask exactly the grid's size in base64
    public static func read(_ data: Data) -> KeyformFile? {
        guard data.count <= Limits.keyforms, let K = (try? parseJSON(data)) as? JObj else { return nil }
        func int(_ v: Any?, _ lo: Int, _ hi: Int) -> Int? {
            guard let d = jnum(v), d == d.rounded(), d >= Double(lo), d <= Double(hi) else { return nil }
            return Int(d)
        }
        func pos(_ v: Any?) -> Double? { guard let d = jnum(v), d > 0 else { return nil }; return d }
        guard jnum(K["version"]) == 1, let cols = int(K["cols"], 2, 4096), let rows = int(K["rows"], 2, 4096), cols * rows <= (1 << 22),
              let cell = pos(K["cell"]), let units = pos(K["units"]), let turn = pos(K["turn"]), let nod = pos(K["nod"]),
              let rawKeys = K["keys"] as? [Any], rawKeys.count <= 32 else { return nil }
        func b64(_ bytes: Int) -> Int { Int((Double(bytes) / 3).rounded(.up)) * 4 }
        let field = b64(cols * rows * 4), maskLen = b64(cols * rows)
        var keys: [KeyformKey] = []
        for k in rawKeys {
            guard let k = k as? JObj, let ps = k["param"] as? String, let p = KeyformKey.Param(rawValue: ps), let v = jnum(k["value"]) else { return nil }
            if p != .diag && v == 0 { return nil }
            guard let f = k["fields"] as? JObj else { return nil }
            var fields: [String: String] = [:]
            for (name, s) in f {
                guard let s = s as? String, s.utf8.count == field else { return nil }
                fields[name] = s
            }
            var same: [String]?
            if let s = k["same"], !isNull(s) {
                guard let a = s as? [Any], a.allSatisfy({ $0 is String }) else { return nil }
                same = a.compactMap { $0 as? String }
            }
            keys.append(KeyformKey(param: p, value: v, fields: fields, same: same))
        }
        var mask: [String: String]?
        if let mo = K["mask"] as? JObj {
            var mm: [String: String] = [:]
            for (name, s) in mo {
                guard let s = s as? String, s.utf8.count == maskLen else { return nil }
                mm[name] = s
            }
            mask = mm
        }
        return KeyformFile(version: 1, cell: cell, cols: cols, rows: rows, units: units, turn: turn, nod: nod, keys: keys, mask: mask,
                           hermite: (K["interp"] as? String) == "hermite")
    }

    /// a field at (x, y), model px: bilinear between the grid points
    func sampleField(_ f: UnsafeBufferPointer<Int16>, _ x: Double, _ y: Double) -> (Double, Double) {
        let gx = min(Double(cols) - 1.001, max(0, x / cell)), gy = min(Double(rows) - 1.001, max(0, y / cell))
        let c = Int(gx.rounded(.down)), r = Int(gy.rounded(.down)), tx = gx - Double(c), ty = gy - Double(r)
        func at(_ cc: Int, _ rr: Int, _ k: Int) -> Double { Double(f[2 * (rr * cols + cc) + k]) }
        func v(_ k: Int) -> Double {
            (at(c, r, k) * (1 - tx) + at(c + 1, r, k) * tx) * (1 - ty) + (at(c, r + 1, k) * (1 - tx) + at(c + 1, r + 1, k) * tx) * ty
        }
        return (v(0) * units, v(1) * units)
    }

    /// a mask (0-1) at (x, y), model px: bilinear between the grid points
    func sampleMask(_ m: [UInt8], _ x: Double, _ y: Double) -> Double {
        let gx = min(Double(cols) - 1.001, max(0, x / cell)), gy = min(Double(rows) - 1.001, max(0, y / cell))
        let c = Int(gx.rounded(.down)), r = Int(gy.rounded(.down)), tx = gx - Double(c), ty = gy - Double(r)
        func at(_ cc: Int, _ rr: Int) -> Double { Double(m[rr * cols + cc]) }
        return ((at(c, r) * (1 - tx) + at(c + 1, r) * tx) * (1 - ty) + (at(c, r + 1) * (1 - tx) + at(c + 1, r + 1) * tx) * ty) / 255
    }
}
