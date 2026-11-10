#if canImport(CoreGraphics) && canImport(ImageIO)
import CoreGraphics
import Foundation
import ImageIO
import LivLivCore

/// a picture decoded once: its premultiplied RGBA8 bytes for the GPU (as the original's UNPACK_PREMULTIPLY_ALPHA) and,
/// when the rig needs to measure it, the straight-alpha copy
public struct DecodedImage: @unchecked Sendable {
    public let width: Int
    public let height: Int
    /// width * height * 4, premultiplied RGBA
    public let premultiplied: [UInt8]
    public let cgImage: CGImage

    /// the straight-alpha pixels (what the browser's getImageData gives)
    public func straight() -> RGBAImage {
        var px = premultiplied
        for i in stride(from: 0, to: px.count, by: 4) {
            let a = Int(px[i + 3])
            if a == 0 || a == 255 { continue }
            px[i] = UInt8(min(255, (Int(px[i]) * 255 + a / 2) / a))
            px[i + 1] = UInt8(min(255, (Int(px[i + 1]) * 255 + a / 2) / a))
            px[i + 2] = UInt8(min(255, (Int(px[i + 2]) * 255 + a / 2) / a))
        }
        return RGBAImage(width: width, height: height, pixels: px)
    }
}

public enum ImageDecoder {
    /// WebP, PNG, JPEG (whatever ImageIO reads). Throws with the file's name when it is not a picture
    public static func decode(_ data: Data, name: String, maxSide: Int = Limits.texture) throws -> DecodedImage {
        guard let src = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let img = CGImageSourceCreateImageAtIndex(src, 0, [kCGImageSourceShouldCacheImmediately: true] as CFDictionary) else {
            throw LivLivError(.invalid, "LivLiv: \(name) is not a picture this device can read")
        }
        return try render(img, name: name, maxSide: maxSide)
    }

    public static func render(_ img: CGImage, name: String, maxSide: Int = Limits.texture) throws -> DecodedImage {
        let w = img.width, h = img.height
        guard w > 0, h > 0 else { throw LivLivError(.invalid, "LivLiv: \(name) is an empty picture") }
        if w > maxSide || h > maxSide { throw LivLivError(.tooLarge, "LivLiv: \(name) is too large (\(w) x \(h): \(maxSide) px a side at most)") }
        var px = [UInt8](repeating: 0, count: w * h * 4)
        let space = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let ok = px.withUnsafeMutableBytes { buf -> Bool in
            guard let ctx = CGContext(data: buf.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return false }
            ctx.interpolationQuality = .none
            ctx.setBlendMode(.copy)
            ctx.draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))
            return true
        }
        guard ok else { throw LivLivError(.invalid, "LivLiv: \(name) could not be decoded") }
        let cg = px.withUnsafeBytes { buf -> CGImage? in
            guard let provider = CGDataProvider(data: Data(buf) as CFData) else { return nil }
            return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4, space: space,
                           bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
                           provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        } ?? img
        return DecodedImage(width: w, height: h, premultiplied: px, cgImage: cg)
    }

    /// a picture's size from its header alone (nothing decoded)
    public static func size(_ data: Data) -> (Int, Int)? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let p = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any],
              let w = p[kCGImagePropertyPixelWidth] as? Int, let h = p[kCGImagePropertyPixelHeight] as? Int else { return nil }
        return (w, h)
    }
}
#endif
