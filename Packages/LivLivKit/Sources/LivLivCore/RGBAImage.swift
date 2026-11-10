// A decoded layer image (straight, not premultiplied, RGBA8) and what the rig measures in its pixels when a model loads
// (puppet.ts alphaGrid, coverAt, nasalRoom, closedLashLine). The browser drew images onto a 2D canvas and read them back;
// here the same samples are taken from the pixels directly.
import Foundation

public struct RGBAImage: Sendable {
    public let width: Int
    public let height: Int
    /// width * height * 4 bytes, straight alpha
    public let pixels: [UInt8]
    public init(width: Int, height: Int, pixels: [UInt8]) {
        precondition(pixels.count == width * height * 4)
        self.width = width; self.height = height; self.pixels = pixels
    }
    @inline(__always) public func alpha(_ x: Int, _ y: Int) -> UInt8 { pixels[4 * (y * width + x) + 3] }

    /// the image's alpha drawn into a W x H canvas at (dx, dy, dw, dh), nearest sample per canvas pixel (0 outside it)
    func alphaPlaced(dx: Double, dy: Double, dw: Double, dh: Double, W: Int, H: Int) -> [UInt8] {
        var out = [UInt8](repeating: 0, count: max(0, W * H))
        guard dw > 0, dh > 0, width > 0, height > 0 else { return out }
        let sx = Double(width) / dw, sy = Double(height) / dh
        let x0 = max(0, Int(dx.rounded(.down))), x1 = min(W, Int((dx + dw).rounded(.up)))
        let y0 = max(0, Int(dy.rounded(.down))), y1 = min(H, Int((dy + dh).rounded(.up)))
        if x0 >= x1 || y0 >= y1 { return out }
        for y in y0..<y1 {
            let v = Int(((Double(y) + 0.5 - dy) * sy).rounded(.down))
            if v < 0 || v >= height { continue }
            for x in x0..<x1 {
                let u = Int(((Double(x) + 0.5 - dx) * sx).rounded(.down))
                if u < 0 || u >= width { continue }
                out[y * W + x] = pixels[4 * (v * width + u) + 3]
            }
        }
        return out
    }
}

/// which lattice cells of a cols x rows grid the images (placed at ox, oy, w, h in cell units) cover, grown by one cell
func alphaGrid(_ imgs: [RGBAImage], cols: Int, rows: Int, ox: Double, oy: Double, w: Double, h: Double) -> [UInt8] {
    var occ = [UInt8](repeating: 0, count: cols * rows)
    for img in imgs where img.width > 0 && img.height > 0 {
        let kx = w / Double(img.width), ky = h / Double(img.height)
        for py in 0..<img.height {
            let fy0 = oy + Double(py) * ky, fy1 = fy0 + ky
            let r0 = max(0, Int(fy0.rounded(.down))), r1 = min(rows - 1, Int((fy1 - 1e-9).rounded(.down)))
            if r0 > r1 { continue }
            let rowBase = 4 * py * img.width
            for px in 0..<img.width where img.pixels[rowBase + 4 * px + 3] > 0 {
                let fx0 = ox + Double(px) * kx, fx1 = fx0 + kx
                let c0 = max(0, Int(fx0.rounded(.down))), c1 = min(cols - 1, Int((fx1 - 1e-9).rounded(.down)))
                if c0 > c1 { continue }
                for r in r0...r1 { for c in c0...c1 { occ[r * cols + c] = 1 } }
            }
        }
    }
    var out = occ
    for r in 0..<rows {
        for q in 0..<cols where occ[r * cols + q] == 0 {
            outer: for dr in -1...1 {
                for dq in -1...1 {
                    let rr = r + dr, qq = q + dq
                    if rr >= 0 && rr < rows && qq >= 0 && qq < cols && occ[rr * cols + qq] != 0 { out[r * cols + q] = 1; break outer }
                }
            }
        }
    }
    return out
}

/// per vertex of a layer (`img` at box L), how much of what it draws within one lattice cell of the vertex lies over
/// `under` (another layer's image at its box U): under's alpha, weighted by the layer's own; under's plain mean near a
/// vertex where the layer draws nothing
func coverAt(_ img: RGBAImage, _ L: LayerDef, _ under: RGBAImage, _ U: LayerDef, _ pts: [Float], _ cell: Double) -> [Float] {
    let W = Int(L.w), H = Int(L.h)
    let a = img.alphaPlaced(dx: 0, dy: 0, dw: L.w, dh: L.h, W: W, H: H)
    let b = under.alphaPlaced(dx: U.x - L.x, dy: U.y - L.y, dw: U.w, dh: U.h, W: W, H: H)
    var out = [Float](repeating: 0, count: pts.count / 2)
    for i in 0..<out.count {
        let cx = Double(pts[2 * i]) - L.x, cy = Double(pts[2 * i + 1]) - L.y
        var sa = 0.0, sab = 0.0, sb = 0.0, k = 0
        let ya = max(0, Int((cy - cell).rounded(.toNearestOrAwayFromZero))), yb = min(H, Int((cy + cell).rounded(.toNearestOrAwayFromZero)))
        let xa = max(0, Int((cx - cell).rounded(.toNearestOrAwayFromZero))), xb = min(W, Int((cx + cell).rounded(.toNearestOrAwayFromZero)))
        if ya < yb && xa < xb {
            for y in ya..<yb {
                for x in xa..<xb {
                    let j = y * W + x
                    let wa = Double(a[j]) / 255, wb = Double(b[j]) / 255
                    sa += wa; sab += wa * wb; sb += wb; k += 1
                }
            }
        }
        out[i] = Float(sa > 1 ? sab / sa : k > 0 ? sb / Double(k) : 0)
    }
    return out
}

/// an iris's room toward the nose (model px): how far its eye's whites go on past its inner visible edge, the side the
/// nose is on (+1: +x), that edge at rest, and the iris's visible width
struct Nasal { var room: Double, sign: Double, inner: Double, w: Double }

func nasalRoom(_ a: RGBAImage, _ I: LayerDef, _ m: RGBAImage, _ E: LayerDef, sign: Double) -> Nasal? {
    let ux = I.w / Double(a.width), uy = I.h / Double(a.height)
    func white(_ x: Double, _ y: Double) -> Bool {  // as the stencil tests it: mask alpha 0.5
        let u = Int((((x - E.x) / E.w) * Double(m.width)).rounded(.down)), v = Int((((y - E.y) / E.h) * Double(m.height)).rounded(.down))
        return u >= 0 && v >= 0 && u < m.width && v < m.height && m.alpha(u, v) >= 128
    }
    var rows: [(y: Double, n: Int, near: Double, far: Double)] = []
    for v in 0..<a.height {
        let y = I.y + (Double(v) + 0.5) * uy
        var n = 0, lo = Double.infinity, hi = -Double.infinity
        for u in 0..<a.width {
            let x = I.x + (Double(u) + 0.5) * ux
            if a.alpha(u, v) < 200 || !white(x, y) { continue }
            n += 1; lo = min(lo, x); hi = max(hi, x)
        }
        if n > 0 { rows.append((y, n, sign > 0 ? hi : lo, sign > 0 ? lo : hi)) }
    }
    guard !rows.isEmpty else { return nil }
    let top = rows.map(\.n).max()!
    var room: [Double] = [], inner: [Double] = [], width: [Double] = []
    for r in rows where Double(r.n) >= 0.9 * Double(top) {
        var k = 0
        while white(r.near + sign * Double(k + 1) * ux, r.y) && k < 100_000 { k += 1 }
        room.append(Double(k) * ux); inner.append(r.near + sign * ux / 2); width.append(abs(r.near - r.far) + ux)
    }
    func med(_ v: [Double]) -> Double { let s = v.sorted(); return s[s.count >> 1] }
    return Nasal(room: med(room), sign: sign, inner: med(inner), w: med(width))
}

/// the closed lash a lid layer draws, as model y by model x: in each column the darkest opaque pixel, if it is dark
/// enough to be lash, then one smooth arc through them (a parabola fitted twice). nil when fewer than a fifth of the
/// columns have lash
func closedLashLine(_ d: RGBAImage, _ L: LayerDef) -> ((Double) -> Double)? {
    let w = d.width, h = d.height
    guard w > 0, h > 0 else { return nil }
    var ys = [Double](repeating: .nan, count: w)
    for x in 0..<w {
        var best = 255.0, by = -1
        for y in 0..<h {
            let k = 4 * (y * w + x)
            if d.pixels[k + 3] < 200 { continue }
            let l = 0.3 * Double(d.pixels[k]) + 0.59 * Double(d.pixels[k + 1]) + 0.11 * Double(d.pixels[k + 2])
            if l < best { best = l; by = y }
        }
        if by >= 0 && best < 110 { ys[x] = Double(by) }
    }
    let found = ys.filter { !$0.isNaN }.count
    if Double(found) < 0.2 * Double(w) { return nil }
    var pts: [(Double, Double)] = []
    for (x, v) in ys.enumerated() where !v.isNaN {
        pts.append((L.x + (Double(x) + 0.5) * (L.w / Double(w)), L.y + (v + 0.5) * (L.h / Double(h))))
    }
    func fit(_ P: [(Double, Double)]) -> ((Double) -> Double)? {
        let m = P.reduce(0) { $0 + $1.0 } / Double(P.count), sc = max(1, (P[P.count - 1].0 - P[0].0) / 2)
        var S = [Double](repeating: 0, count: 5), T = [0.0, 0, 0]
        for (x, y) in P {
            let u = (x - m) / sc
            var q = 1.0
            for k in 0..<5 { S[k] += q; if k < 3 { T[k] += q * y }; q *= u }
        }
        let M = [[S[0], S[1], S[2]], [S[1], S[2], S[3]], [S[2], S[3], S[4]]]
        func det(_ A: [[Double]]) -> Double {
            A[0][0] * (A[1][1] * A[2][2] - A[1][2] * A[2][1]) - A[0][1] * (A[1][0] * A[2][2] - A[1][2] * A[2][0]) + A[0][2] * (A[1][0] * A[2][1] - A[1][1] * A[2][0])
        }
        let D = det(M)
        if !(abs(D) > 1e-9) { return nil }
        let co = (0..<3).map { j in det(M.enumerated().map { (i, r) in r.enumerated().map { (k, v) in k == j ? T[i] : v } }) / D }
        if !co.allSatisfy({ $0.isFinite }) { return nil }
        return { x in let u = (x - m) / sc; return co[0] + co[1] * u + co[2] * u * u }
    }
    guard var f = fit(pts) else { return nil }
    let res = pts.map { abs($0.1 - f($0.0)) }.sorted()
    let tol = max(1.5, 2.5 * res[res.count >> 1])
    var used = pts
    let ff = f
    let kept = pts.filter { abs($0.1 - ff($0.0)) <= tol }
    if Double(kept.count) >= 0.6 * Double(pts.count), let refit = fit(kept) { f = refit; used = kept }
    let x0 = used[0].0, x1 = used[used.count - 1].0, line = f
    return { x in line(min(x1, max(x0, x))) }
}
