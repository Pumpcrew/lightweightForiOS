#if canImport(Metal) && canImport(SwiftUI)
import LivLivCore
import Metal
import QuartzCore
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// the SwiftUI view a LivLiv model or a PNGTuber plays in: a CAMetalLayer, driven by the display's refresh
public struct StageView: View {
    @ObservedObject var stage: CharacterStage
    public init(stage: CharacterStage) { self.stage = stage }
    public var body: some View { StageRepresentable(stage: stage) }
}

#if canImport(UIKit)
struct StageRepresentable: UIViewRepresentable {
    let stage: CharacterStage
    func makeUIView(context: Context) -> StageMetalView { StageMetalView(stage: stage) }
    func updateUIView(_ v: StageMetalView, context: Context) { v.stage = stage }
    static func dismantleUIView(_ v: StageMetalView, coordinator: ()) { v.stop() }
}

final class StageMetalView: UIView {
    override class var layerClass: AnyClass { CAMetalLayer.self }
    var stage: CharacterStage
    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0
    private var metal: CAMetalLayer { layer as! CAMetalLayer }

    init(stage: CharacterStage) {
        self.stage = stage
        super.init(frame: .zero)
        isOpaque = false
        backgroundColor = .clear
        metal.isOpaque = false
        metal.pixelFormat = .bgra8Unorm
        metal.framebufferOnly = true
        metal.device = stage.renderer?.device
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dragged(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        addGestureRecognizer(UIHoverGestureRecognizer(target: self, action: #selector(hovered(_:))))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinched(_:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    /// the app is in the background (or going there): iOS refuses GPU work then, so nothing is drawn until it is back
    private var backgrounded = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && link == nil {
            last = 0
            backgrounded = UIApplication.shared.applicationState == .background
            let l = CADisplayLink(target: self, selector: #selector(step(_:)))
            l.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
            l.isPaused = backgrounded
            l.add(to: .main, forMode: .common)
            link = l
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(toBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            nc.addObserver(self, selector: #selector(toForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        } else if window == nil { stop() }
    }
    func stop() {
        link?.invalidate(); link = nil
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func toBackground() { backgrounded = true; link?.isPaused = true }
    @objc private func toForeground() { backgrounded = false; last = 0; link?.isPaused = false }

    private var scale: CGFloat {
        #if os(visionOS)
        let s: CGFloat = traitCollection.displayScale > 0 ? traitCollection.displayScale : 2
        #else
        let s: CGFloat = window?.screen.scale ?? traitCollection.displayScale
        #endif
        return min(CGFloat(stage.maxPixelRatio), max(1, s))
    }

    @objc private func step(_ l: CADisplayLink) {
        let now = l.timestamp
        let dt = last == 0 ? 1.0 / 60 : now - last
        last = now
        let s = scale
        let size = CGSize(width: max(2, (bounds.width * s).rounded()), height: max(2, (bounds.height * s).rounded()))
        if metal.drawableSize != size { metal.drawableSize = size; metal.contentsScale = s }
        stage.tick(dt)
        // (a frame can still come between the app leaving the screen and the notification)
        guard !backgrounded, UIApplication.shared.applicationState != .background else { return }
        guard bounds.width > 1, bounds.height > 1, let d = metal.nextDrawable() else { return }
        stage.render(into: d, scale: Double(s))
    }

    private func share(_ p: CGPoint) -> (Double, Double) { (Double(p.x / max(1, bounds.width)), Double(p.y / max(1, bounds.height))) }
    @objc private func dragged(_ g: UIPanGestureRecognizer) {
        let (u, v) = share(g.location(in: self))
        if g.state == .ended || g.state == .cancelled { stage.pointer(u: u, v: v, on: false) } else { stage.pointer(u: u, v: v, on: true) }
    }
    @objc private func hovered(_ g: UIHoverGestureRecognizer) {
        let (u, v) = share(g.location(in: self))
        switch g.state {
        case .began, .changed: stage.pointer(u: u, v: v, on: true)
        default: stage.pointerLeft()
        }
    }
    @objc private func tapped(_ g: UITapGestureRecognizer) {
        let (u, v) = share(g.location(in: self))
        stage.tap(u: u, v: v, viewSize: bounds.size)
    }
    private var pinchStart = 1.0
    @objc private func pinched(_ g: UIPinchGestureRecognizer) {
        if g.state == .began { pinchStart = stage.view.zoom }
        stage.view.zoom = min(4, max(0.4, pinchStart * Double(g.scale)))
    }
}

#elseif canImport(AppKit)
struct StageRepresentable: NSViewRepresentable {
    let stage: CharacterStage
    func makeNSView(context: Context) -> StageMetalView { StageMetalView(stage: stage) }
    func updateNSView(_ v: StageMetalView, context: Context) { v.stage = stage }
    static func dismantleNSView(_ v: StageMetalView, coordinator: ()) { v.stop() }
}

final class StageMetalView: NSView {
    var stage: CharacterStage
    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0
    private let metal = CAMetalLayer()

    init(stage: CharacterStage) {
        self.stage = stage
        super.init(frame: .zero)
        wantsLayer = true
        metal.isOpaque = false
        metal.pixelFormat = .bgra8Unorm
        metal.framebufferOnly = true
        metal.device = stage.renderer?.device
        metal.backgroundColor = .clear
        let tap = NSClickGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tap)
        addGestureRecognizer(NSMagnificationGestureRecognizer(target: self, action: #selector(pinched(_:))))
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func makeBackingLayer() -> CALayer { metal }
    override var isFlipped: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil && link == nil {
            last = 0
            let l = displayLink(target: self, selector: #selector(step(_:)))
            l.add(to: .main, forMode: .common)
            link = l
        } else if window == nil { stop() }
    }
    func stop() { link?.invalidate(); link = nil }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        for t in trackingAreas { removeTrackingArea(t) }
        addTrackingArea(NSTrackingArea(rect: bounds, options: [.mouseMoved, .mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self))
    }
    private func share(_ e: NSEvent) -> (Double, Double) {
        let p = convert(e.locationInWindow, from: nil)
        return (Double(p.x / max(1, bounds.width)), Double(p.y / max(1, bounds.height)))
    }
    override func mouseMoved(with e: NSEvent) { let (u, v) = share(e); stage.pointer(u: u, v: v, on: true) }
    override func mouseDragged(with e: NSEvent) { let (u, v) = share(e); stage.pointer(u: u, v: v, on: true) }
    override func mouseExited(with e: NSEvent) { stage.pointerLeft() }
    override func scrollWheel(with e: NSEvent) { stage.view.zoom = min(4, max(0.4, stage.view.zoom * (1 + Double(e.scrollingDeltaY) * 0.01))) }

    @objc private func step(_ l: CADisplayLink) {
        let now = l.timestamp
        let dt = last == 0 ? 1.0 / 60 : now - last
        last = now
        let s = min(CGFloat(stage.maxPixelRatio), max(1, window?.backingScaleFactor ?? 2))
        let size = CGSize(width: max(2, (bounds.width * s).rounded()), height: max(2, (bounds.height * s).rounded()))
        if metal.drawableSize != size { metal.drawableSize = size; metal.contentsScale = s }
        metal.frame = bounds
        stage.tick(dt)
        guard bounds.width > 1, bounds.height > 1, let d = metal.nextDrawable() else { return }
        stage.render(into: d, scale: Double(s))
    }
    @objc private func tapped(_ g: NSClickGestureRecognizer) {
        let p = g.location(in: self)
        stage.tap(u: Double(p.x / max(1, bounds.width)), v: Double(p.y / max(1, bounds.height)), viewSize: bounds.size)
    }
    private var pinchStart = 1.0
    @objc private func pinched(_ g: NSMagnificationGestureRecognizer) {
        if g.state == .began { pinchStart = stage.view.zoom }
        stage.view.zoom = min(4, max(0.4, pinchStart * (1 + Double(g.magnification))))
    }
}
#endif
#endif
