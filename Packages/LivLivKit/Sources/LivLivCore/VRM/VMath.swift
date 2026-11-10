// Small 3D maths for the VRM rig, on the standard library's SIMD types so it builds everywhere (no `simd` module).
import Foundation

public typealias V3 = SIMD3<Float>
public typealias V4 = SIMD4<Float>

@inline(__always) func dot3(_ a: V3, _ b: V3) -> Float { (a * b).sum() }
@inline(__always) func cross3(_ a: V3, _ b: V3) -> V3 { V3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x) }
@inline(__always) func length3(_ a: V3) -> Float { dot3(a, a).squareRoot() }
@inline(__always) func normalize3(_ a: V3) -> V3 { let l = length3(a); return l > 1e-12 ? a / l : V3(0, 0, 0) }

public struct Quat: Sendable, Equatable {
    public var x: Float, y: Float, z: Float, w: Float
    public init(x: Float, y: Float, z: Float, w: Float) { self.x = x; self.y = y; self.z = z; self.w = w }
    public static let identity = Quat(x: 0, y: 0, z: 0, w: 1)
    public init(axis: V3, angle: Float) {
        let a = normalize3(axis), s = sin(angle / 2)
        self.init(x: a.x * s, y: a.y * s, z: a.z * s, w: cos(angle / 2))
    }
    /// three.js Euler order 'XYZ' (the matrix is Rx * Ry * Rz)
    public init(eulerXYZ x: Float, _ y: Float, _ z: Float) {
        self = Quat(axis: V3(1, 0, 0), angle: x) * Quat(axis: V3(0, 1, 0), angle: y) * Quat(axis: V3(0, 0, 1), angle: z)
    }
    public static func * (a: Quat, b: Quat) -> Quat {
        Quat(x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
             y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
             z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
             w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z)
    }
    public var conjugate: Quat { Quat(x: -x, y: -y, z: -z, w: w) }
    public var normalized: Quat {
        let l = (x * x + y * y + z * z + w * w).squareRoot()
        return l > 1e-12 ? Quat(x: x / l, y: y / l, z: z / l, w: w / l) : .identity
    }
    public func rotate(_ v: V3) -> V3 {
        let u = V3(x, y, z)
        let t = 2 * cross3(u, v)
        return v + w * t + cross3(u, t)
    }
    /// the shortest rotation taking direction a onto b
    public static func fromTo(_ a: V3, _ b: V3) -> Quat {
        let na = normalize3(a), nb = normalize3(b)
        let d = dot3(na, nb)
        if d < -0.999999 {
            var axis = cross3(V3(1, 0, 0), na)
            if length3(axis) < 1e-6 { axis = cross3(V3(0, 1, 0), na) }
            return Quat(axis: axis, angle: .pi)
        }
        let c = cross3(na, nb)
        return Quat(x: c.x, y: c.y, z: c.z, w: 1 + d).normalized
    }
}

/// a column-major 4x4 matrix (glTF's order)
public struct Mat4: Sendable, Equatable {
    public var c0: V4, c1: V4, c2: V4, c3: V4
    public init(_ c0: V4, _ c1: V4, _ c2: V4, _ c3: V4) { self.c0 = c0; self.c1 = c1; self.c2 = c2; self.c3 = c3 }
    public static let identity = Mat4(V4(1, 0, 0, 0), V4(0, 1, 0, 0), V4(0, 0, 1, 0), V4(0, 0, 0, 1))
    public init(columnMajor m: [Float]) {
        self.init(V4(m[0], m[1], m[2], m[3]), V4(m[4], m[5], m[6], m[7]), V4(m[8], m[9], m[10], m[11]), V4(m[12], m[13], m[14], m[15]))
    }
    public init(t: V3, r: Quat, s: V3) {
        let x = r.x, y = r.y, z = r.z, w = r.w
        let x2 = x + x, y2 = y + y, z2 = z + z
        let xx = x * x2, xy = x * y2, xz = x * z2, yy = y * y2, yz = y * z2, zz = z * z2, wx = w * x2, wy = w * y2, wz = w * z2
        self.init(V4((1 - (yy + zz)) * s.x, (xy + wz) * s.x, (xz - wy) * s.x, 0),
                  V4((xy - wz) * s.y, (1 - (xx + zz)) * s.y, (yz + wx) * s.y, 0),
                  V4((xz + wy) * s.z, (yz - wx) * s.z, (1 - (xx + yy)) * s.z, 0),
                  V4(t.x, t.y, t.z, 1))
    }
    @inline(__always) public static func * (a: Mat4, b: Mat4) -> Mat4 {
        Mat4(a.mul(b.c0), a.mul(b.c1), a.mul(b.c2), a.mul(b.c3))
    }
    @inline(__always) public func mul(_ v: V4) -> V4 { c0 * v.x + c1 * v.y + c2 * v.z + c3 * v.w }
    @inline(__always) public func point(_ p: V3) -> V3 { let r = c0 * p.x + c1 * p.y + c2 * p.z + c3; return V3(r.x, r.y, r.z) }
    @inline(__always) public func vector(_ p: V3) -> V3 { let r = c0 * p.x + c1 * p.y + c2 * p.z; return V3(r.x, r.y, r.z) }
    public var translation: V3 { V3(c3.x, c3.y, c3.z) }

    /// the rotation of a matrix without shear (its scale divided out)
    public var rotation: Quat {
        let sx = length3(V3(c0.x, c0.y, c0.z)), sy = length3(V3(c1.x, c1.y, c1.z)), sz = length3(V3(c2.x, c2.y, c2.z))
        let m00 = c0.x / sx, m10 = c0.y / sx, m20 = c0.z / sx
        let m01 = c1.x / sy, m11 = c1.y / sy, m21 = c1.z / sy
        let m02 = c2.x / sz, m12 = c2.y / sz, m22 = c2.z / sz
        let tr = m00 + m11 + m22
        var q: Quat
        if tr > 0 {
            let s = (tr + 1).squareRoot() * 2
            q = Quat(x: (m21 - m12) / s, y: (m02 - m20) / s, z: (m10 - m01) / s, w: 0.25 * s)
        } else if m00 > m11 && m00 > m22 {
            let s = (1 + m00 - m11 - m22).squareRoot() * 2
            q = Quat(x: 0.25 * s, y: (m01 + m10) / s, z: (m02 + m20) / s, w: (m21 - m12) / s)
        } else if m11 > m22 {
            let s = (1 + m11 - m00 - m22).squareRoot() * 2
            q = Quat(x: (m01 + m10) / s, y: 0.25 * s, z: (m12 + m21) / s, w: (m02 - m20) / s)
        } else {
            let s = (1 + m22 - m00 - m11).squareRoot() * 2
            q = Quat(x: (m02 + m20) / s, y: (m12 + m21) / s, z: 0.25 * s, w: (m10 - m01) / s)
        }
        return q.normalized
    }

    public var inverse: Mat4 {
        let m = [c0.x, c0.y, c0.z, c0.w, c1.x, c1.y, c1.z, c1.w, c2.x, c2.y, c2.z, c2.w, c3.x, c3.y, c3.z, c3.w]
        var inv = [Float](repeating: 0, count: 16)
        inv[0] = m[5] * m[10] * m[15] - m[5] * m[11] * m[14] - m[9] * m[6] * m[15] + m[9] * m[7] * m[14] + m[13] * m[6] * m[11] - m[13] * m[7] * m[10]
        inv[4] = -m[4] * m[10] * m[15] + m[4] * m[11] * m[14] + m[8] * m[6] * m[15] - m[8] * m[7] * m[14] - m[12] * m[6] * m[11] + m[12] * m[7] * m[10]
        inv[8] = m[4] * m[9] * m[15] - m[4] * m[11] * m[13] - m[8] * m[5] * m[15] + m[8] * m[7] * m[13] + m[12] * m[5] * m[11] - m[12] * m[7] * m[9]
        inv[12] = -m[4] * m[9] * m[14] + m[4] * m[10] * m[13] + m[8] * m[5] * m[14] - m[8] * m[6] * m[13] - m[12] * m[5] * m[10] + m[12] * m[6] * m[9]
        inv[1] = -m[1] * m[10] * m[15] + m[1] * m[11] * m[14] + m[9] * m[2] * m[15] - m[9] * m[3] * m[14] - m[13] * m[2] * m[11] + m[13] * m[3] * m[10]
        inv[5] = m[0] * m[10] * m[15] - m[0] * m[11] * m[14] - m[8] * m[2] * m[15] + m[8] * m[3] * m[14] + m[12] * m[2] * m[11] - m[12] * m[3] * m[10]
        inv[9] = -m[0] * m[9] * m[15] + m[0] * m[11] * m[13] + m[8] * m[1] * m[15] - m[8] * m[3] * m[13] - m[12] * m[1] * m[11] + m[12] * m[3] * m[9]
        inv[13] = m[0] * m[9] * m[14] - m[0] * m[10] * m[13] - m[8] * m[1] * m[14] + m[8] * m[2] * m[13] + m[12] * m[1] * m[10] - m[12] * m[2] * m[9]
        inv[2] = m[1] * m[6] * m[15] - m[1] * m[7] * m[14] - m[5] * m[2] * m[15] + m[5] * m[3] * m[14] + m[13] * m[2] * m[7] - m[13] * m[3] * m[6]
        inv[6] = -m[0] * m[6] * m[15] + m[0] * m[7] * m[14] + m[4] * m[2] * m[15] - m[4] * m[3] * m[14] - m[12] * m[2] * m[7] + m[12] * m[3] * m[6]
        inv[10] = m[0] * m[5] * m[15] - m[0] * m[7] * m[13] - m[4] * m[1] * m[15] + m[4] * m[3] * m[13] + m[12] * m[1] * m[7] - m[12] * m[3] * m[5]
        inv[14] = -m[0] * m[5] * m[14] + m[0] * m[6] * m[13] + m[4] * m[1] * m[14] - m[4] * m[2] * m[13] - m[12] * m[1] * m[6] + m[12] * m[2] * m[5]
        inv[3] = -m[1] * m[6] * m[11] + m[1] * m[7] * m[10] + m[5] * m[2] * m[11] - m[5] * m[3] * m[10] - m[9] * m[2] * m[7] + m[9] * m[3] * m[6]
        inv[7] = m[0] * m[6] * m[11] - m[0] * m[7] * m[10] - m[4] * m[2] * m[11] + m[4] * m[3] * m[10] + m[8] * m[2] * m[7] - m[8] * m[3] * m[6]
        inv[11] = -m[0] * m[5] * m[11] + m[0] * m[7] * m[9] + m[4] * m[1] * m[11] - m[4] * m[3] * m[9] - m[8] * m[1] * m[7] + m[8] * m[3] * m[5]
        inv[15] = m[0] * m[5] * m[10] - m[0] * m[6] * m[9] - m[4] * m[1] * m[10] + m[4] * m[2] * m[9] + m[8] * m[1] * m[6] - m[8] * m[2] * m[5]
        let det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12]
        if abs(det) < 1e-20 { return .identity }
        return Mat4(columnMajor: inv.map { $0 / det })
    }
}
