#if canImport(CoreGraphics) && canImport(CoreText)
import CoreGraphics
import CoreText
import Foundation
import LivLivCore

/// The mark a model package asks the player to draw (mark.ts, runtime/brand.ts), drawn into the player's own frame so a
/// screenshot or a recording carries it: the LivLiv logo (light over the character and solid in the corner, or the corner
/// alone), the owner's own corner text, or nothing. A request of the package and a condition of its licence, not copy
/// protection: a conforming player draws the mark a package asks for and never adds it to one that does not.
public enum WatermarkPainter {
    static let logoBox = (x: 27.0, y: 44.0, w: 430.0, h: 133.0)
    static let coral = CGColor(srgbRed: 1, green: 0x4d / 255.0, blue: 0x5e / 255.0, alpha: 1)
    static let center = 0.38, centerY = 0.62, centerAlpha = 0.18, centerBlur = 0.06
    static let corner = 0.13, cornerMin = 64.0, margin = 0.035, textShare = 0.026

    /// how open the logo's eye is at `ms` (1 = open), on the same 5.5 s cycle as livliv.ai's
    public static func eyeOpen(_ ms: Double) -> Double {
        let f = ms.truncatingRemainder(dividingBy: 5500) / 5500
        if f < 0.93 { return 1 }
        return f < 0.955 ? 1 - (f - 0.93) / 0.025 * 0.88 : 0.12 + (f - 0.955) / 0.045 * 0.88
    }

    /// the frame's mark as a premultiplied RGBA picture of w x h, or nil when there is nothing to draw
    public static func render(kind: Watermark.Kind, text: String?, center drawCenter: Bool, width w: Int, height h: Int,
                              ms: Double, pixelsPerPoint px: Double) -> CGImage? {
        guard kind != .none, w > 0, h > 0 else { return nil }
        if kind == .text && (text ?? "").isEmpty { return nil }
        let space = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        guard let g = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: space,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { return nil }
        // the canvas's coordinates: origin top left, y down
        g.translateBy(x: 0, y: CGFloat(h)); g.scaleBy(x: 1, y: -1)
        let W = Double(w), H = Double(h)
        switch kind {
        case .livliv:
            if drawCenter { drawCenterLogo(g, W, H, ms) }
            drawCornerLogo(g, W, H, ms, px)
        case .text: drawMarkText(g, W, H, String((text ?? "").prefix(24)), px)
        case .none: break
        }
        return g.makeImage()
    }

    static func cornerSpot(_ w: Double, _ h: Double, _ px: Double) -> (right: Double, y: Double, logo: Double, text: Double) {
        let s = min(w, h), m = max(12 * px, s * margin)
        return (w - m, h - m, max(cornerMin * px, s * corner) * logoBox.h / logoBox.w, max(12 * px, s * textShare))
    }

    static func letters() -> CGPath {
        let p = CGMutablePath()
        func stem(_ x: Double) {
            p.move(to: CGPoint(x: x, y: 62.5)); p.addLine(to: CGPoint(x: x, y: 141.5))
            p.addQuadCurve(to: CGPoint(x: x + 14, y: 158.5), control: CGPoint(x: x, y: 158.5))
        }
        func i(_ x: Double) { p.move(to: CGPoint(x: x, y: 107.5)); p.addLine(to: CGPoint(x: x, y: 158.5)) }
        func v(_ x: Double) {
            p.move(to: CGPoint(x: x, y: 107.5)); p.addLine(to: CGPoint(x: x + 24.2, y: 158.5)); p.addLine(to: CGPoint(x: x + 48.4, y: 107.5))
        }
        stem(101.5); i(145); v(176.3); stem(257.5); i(303); v(335.3)
        return p
    }
    static func blush() -> CGPath {
        let p = CGMutablePath()
        for (a, b) in [((40.5, 122.0), (49.5, 142.1)), ((60.5, 122.0), (69.5, 142.1)), ((421.5, 122.0), (412.5, 142.1)), ((441.5, 122.0), (432.5, 142.1))] {
            p.move(to: CGPoint(x: a.0, y: a.1)); p.addLine(to: CGPoint(x: b.0, y: b.1))
        }
        return p
    }

    /// the mark with its bottom-right corner at (right, bottom), `height` tall
    static func drawLogo(_ g: CGContext, right: Double, bottom: Double, height: Double, color: CGColor, ms: Double, accent: CGColor) {
        let k = height / logoBox.h
        g.saveGState()
        g.translateBy(x: right - logoBox.w * k, y: bottom - height)
        g.scaleBy(x: k, y: k)
        g.translateBy(x: -logoBox.x, y: -logoBox.y)
        g.setLineCap(.round); g.setLineJoin(.round)
        g.setStrokeColor(color); g.setLineWidth(25); g.addPath(letters()); g.strokePath()
        g.setStrokeColor(accent); g.setLineWidth(12.5); g.addPath(blush()); g.strokePath()
        g.setFillColor(accent)
        let r = 13.5, ry = r * eyeOpen(ms)
        g.fillEllipse(in: CGRect(x: 145 - r, y: 67 - ry, width: 2 * r, height: 2 * ry))
        g.addPath(CGPath(roundedRect: CGRect(x: 285.5, y: 69, width: 35, height: 16), cornerWidth: 8, cornerHeight: 8, transform: nil))
        g.fillPath()
        g.restoreGState()
    }

    static func drawCornerLogo(_ g: CGContext, _ w: Double, _ h: Double, _ ms: Double, _ px: Double) {
        let c = cornerSpot(w, h, px)
        g.saveGState()
        g.setShadow(offset: .zero, blur: c.logo * 0.12, color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.55))
        drawLogo(g, right: c.right, bottom: c.y, height: c.logo, color: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.95), ms: ms, accent: coral)
        g.restoreGState()
    }

    static func drawCenterLogo(_ g: CGContext, _ w: Double, _ h: Double, _ ms: Double) {
        let cw = min(w, h) * center, ch = cw * logoBox.h / logoBox.w
        g.saveGState()
        g.setAlpha(centerAlpha)
        g.setShadow(offset: .zero, blur: ch * centerBlur, color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.25))
        let white = CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1)
        drawLogo(g, right: (w + cw) / 2, bottom: h * centerY + ch / 2, height: ch, color: white, ms: ms, accent: white)
        g.restoreGState()
    }

    static func drawMarkText(_ g: CGContext, _ w: Double, _ h: Double, _ text: String, _ px: Double) {
        let c = cornerSpot(w, h, px)
        let font = CTFontCreateUIFontForLanguage(.system, c.text, nil) ?? CTFontCreateWithName("Helvetica" as CFString, c.text, nil)
        let bold = CTFontCreateCopyWithSymbolicTraits(font, c.text, nil, .traitBold, .traitBold) ?? font
        let attrs: [CFString: Any] = [kCTFontAttributeName: bold, kCTForegroundColorAttributeName: CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 0.85)]
        guard let s = CFAttributedStringCreate(nil, text as CFString, attrs as CFDictionary) else { return }
        let line = CTLineCreateWithAttributedString(s)
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        var descent: CGFloat = 0
        _ = CTLineGetTypographicBounds(line, nil, &descent, nil)
        g.saveGState()
        g.setShadow(offset: .zero, blur: c.text * 0.25, color: CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.6))
        // y is down here: the text matrix flips the glyphs back upright
        g.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
        g.textPosition = CGPoint(x: c.right - width, y: c.y - Double(descent))
        CTLineDraw(line, g)
        g.restoreGState()
    }
}
#endif
