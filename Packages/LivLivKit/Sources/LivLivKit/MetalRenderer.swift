#if canImport(Metal) && canImport(QuartzCore)
import CoreGraphics
import Foundation
import LivLivCore
import Metal
import QuartzCore

/// The renderer: puppet.ts render() / drawLayer() / drawMasks() and mark.ts on Metal. One shader with three modes
/// (a layer; an eye's whites as coverage into the mask texture; an iris times its whites), premultiplied alpha
/// blending (ONE, ONE_MINUS_SRC_ALPHA), the stencil that keeps an iris inside its eye at rest, and the mask pass that
/// cuts it softly once it moves. The puppet (LivLivCore) says what to draw; this executes it.
@MainActor
public final class MetalRenderer {
    public let device: MTLDevice
    let queue: MTLCommandQueue
    private let mainPipe: MTLRenderPipelineState
    private let stencilPipe: MTLRenderPipelineState
    private let maskPipes: [MTLRenderPipelineState]
    private let noStencil: MTLDepthStencilState
    private let writeStencil: MTLDepthStencilState
    private let testStencil: MTLDepthStencilState
    private let sampler: MTLSamplerState
    public let colorFormat: MTLPixelFormat = .bgra8Unorm
    private var stencilTex: MTLTexture?
    private var maskTex: MTLTexture?
    private var ring: [MTLBuffer] = []
    private var ringIndex = 0
    private let inFlight = DispatchSemaphore(value: 3)

    public struct Uniforms {
        public var view: SIMD4<Float>
        public var maskSel: SIMD4<Float>
        public var alpha: Float
        public var cut: Float
        public var soft: Float
        public var mode: Int32
        public init(view: SIMD4<Float>, maskSel: SIMD4<Float>, alpha: Float, cut: Float, soft: Float, mode: Int32) {
            self.view = view; self.maskSel = maskSel; self.alpha = alpha; self.cut = cut; self.soft = soft; self.mode = mode
        }
    }

    static let shaderSource = """
    #include <metal_stdlib>
    using namespace metal;
    struct Uniforms { float4 view; float4 maskSel; float alpha; float cut; float soft; int mode; };
    struct VOut { float4 position [[position]]; float2 uv; };
    vertex VOut livliv_vertex(uint vid [[vertex_id]], const device float2 *pos [[buffer(0)]], const device float2 *uv [[buffer(1)]],
                              constant Uniforms &u [[buffer(2)]]) {
        VOut o;
        float2 p = pos[vid] * u.view.xy + u.view.zw;
        o.position = float4(p.x, -p.y, 0.0, 1.0);
        o.uv = uv[vid];
        return o;
    }
    fragment float4 livliv_fragment(VOut in [[stage_in]], texture2d<float> tex [[texture(0)]], texture2d<float> mask [[texture(1)]],
                                    sampler s [[sampler(0)]], constant Uniforms &u [[buffer(0)]]) {
        float4 c = tex.sample(s, in.uv);
        if (c.a < u.cut) discard_fragment();
        if (u.mode == 1) return float4(c.a);
        if (u.mode == 2) {
            uint2 q = uint2(in.position.xy);
            float m = 0.0;
            if (q.x < mask.get_width() && q.y < mask.get_height()) m = dot(mask.read(q), u.maskSel);
            c *= mix(step(0.5, m), m, u.soft);
        }
        return c * u.alpha;
    }
    """

    public init() throws {
        guard let device = MTLCreateSystemDefaultDevice(), let queue = device.makeCommandQueue() else {
            throw LivLivError(.noMetal, "LivLiv: this device has no Metal GPU")
        }
        self.device = device; self.queue = queue
        let lib = try device.makeLibrary(source: Self.shaderSource, options: nil)
        let vfn = lib.makeFunction(name: "livliv_vertex"), ffn = lib.makeFunction(name: "livliv_fragment")
        func pipe(_ format: MTLPixelFormat, stencil: Bool, blend: Bool, write: MTLColorWriteMask) throws -> MTLRenderPipelineState {
            let d = MTLRenderPipelineDescriptor()
            d.vertexFunction = vfn; d.fragmentFunction = ffn
            d.colorAttachments[0].pixelFormat = format
            d.colorAttachments[0].writeMask = write
            if blend {
                let a = d.colorAttachments[0]!
                a.isBlendingEnabled = true
                a.rgbBlendOperation = .add; a.alphaBlendOperation = .add
                a.sourceRGBBlendFactor = .one; a.sourceAlphaBlendFactor = .one
                a.destinationRGBBlendFactor = .oneMinusSourceAlpha; a.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            }
            if stencil { d.stencilAttachmentPixelFormat = .stencil8 }
            return try device.makeRenderPipelineState(descriptor: d)
        }
        mainPipe = try pipe(colorFormat, stencil: true, blend: true, write: .all)
        stencilPipe = try pipe(colorFormat, stencil: true, blend: true, write: [])
        maskPipes = try [MTLColorWriteMask.red, .green, .blue, .alpha].map { try pipe(.rgba8Unorm, stencil: false, blend: false, write: $0) }
        func ds(_ f: MTLCompareFunction, _ pass: MTLStencilOperation, enabled: Bool) -> MTLDepthStencilState {
            let d = MTLDepthStencilDescriptor()
            if enabled {
                let s = MTLStencilDescriptor()
                s.stencilCompareFunction = f
                s.stencilFailureOperation = .keep; s.depthFailureOperation = .keep; s.depthStencilPassOperation = pass
                s.readMask = 0xff; s.writeMask = 0xff
                d.frontFaceStencil = s; d.backFaceStencil = s
            }
            return device.makeDepthStencilState(descriptor: d)!
        }
        noStencil = ds(.always, .keep, enabled: false)
        writeStencil = ds(.always, .replace, enabled: true)
        testStencil = ds(.equal, .keep, enabled: true)
        let sd = MTLSamplerDescriptor()
        sd.minFilter = .linear; sd.magFilter = .linear; sd.mipFilter = .linear
        sd.sAddressMode = .clampToEdge; sd.tAddressMode = .clampToEdge
        sampler = device.makeSamplerState(descriptor: sd)!
    }

    // MARK: Resources

    /// a premultiplied RGBA picture as a mipmapped texture (the original's texImage2D + generateMipmap)
    public func texture(_ img: DecodedImage, mipmapped: Bool = true) -> MTLTexture? {
        let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: img.width, height: img.height, mipmapped: mipmapped)
        d.usage = [.shaderRead]
        d.storageMode = .shared
        guard let t = device.makeTexture(descriptor: d) else { return nil }
        img.premultiplied.withUnsafeBytes { buf in
            t.replace(region: MTLRegionMake2D(0, 0, img.width, img.height), mipmapLevel: 0, withBytes: buf.baseAddress!, bytesPerRow: img.width * 4)
        }
        if mipmapped && t.mipmapLevelCount > 1, let cb = queue.makeCommandBuffer(), let blit = cb.makeBlitCommandEncoder() {
            blit.generateMipmaps(for: t)
            blit.endEncoding()
            cb.commit()
        }
        return t
    }

    public func buffer<T>(_ a: [T]) -> MTLBuffer? {
        guard !a.isEmpty else { return device.makeBuffer(length: 16, options: .storageModeShared) }
        return a.withUnsafeBytes { device.makeBuffer(bytes: $0.baseAddress!, length: $0.count, options: .storageModeShared) }
    }

    /// a frame's vertex data, in one of three buffers that grow as needed
    private func vertexRing(_ bytes: Int) -> MTLBuffer {
        if ring.count < 3 { ring = (0..<3).map { _ in device.makeBuffer(length: 1 << 20, options: .storageModeShared)! } }
        ringIndex = (ringIndex + 1) % 3
        if ring[ringIndex].length < bytes {
            ring[ringIndex] = device.makeBuffer(length: max(bytes, ring[ringIndex].length * 2), options: .storageModeShared)!
        }
        return ring[ringIndex]
    }

    private func attachments(_ w: Int, _ h: Int, mask: Bool) {
        if stencilTex == nil || stencilTex!.width != w || stencilTex!.height != h {
            let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .stencil8, width: w, height: h, mipmapped: false)
            d.usage = .renderTarget
            d.storageMode = .private
            stencilTex = device.makeTexture(descriptor: d)
        }
        if mask && (maskTex == nil || maskTex!.width != w || maskTex!.height != h) {
            let d = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: w, height: h, mipmapped: false)
            d.usage = [.renderTarget, .shaderRead]
            d.storageMode = .private
            maskTex = device.makeTexture(descriptor: d)
        }
    }

    // MARK: Drawing

    /// one textured mesh to draw this frame
    public struct Item {
        public var positions: [Float]
        public var uvs: MTLBuffer
        public var indices: MTLBuffer
        public var indexCount: Int
        public var texture: MTLTexture
        public var uniforms: Uniforms
        public var stencil: DrawCommand.Stencil
    }

    /// draws a puppet's frame (and the mark, and anything after) into `drawable`'s texture
    public func draw(to target: MTLTexture, background: SIMD4<Double>, frame: PuppetFrame?, gpu: PuppetGPU?, puppet: Puppet?,
                     extra: [Item] = [], overlay: MTLTexture? = nil, present: MTLDrawable?) {
        let w = target.width, h = target.height
        _ = inFlight.wait(timeout: .now() + 0.25)
        guard let cb = queue.makeCommandBuffer() else { inFlight.signal(); return }
        let sem = inFlight
        cb.addCompletedHandler { _ in sem.signal() }
        let view = frame.map { SIMD4<Float>($0.sx, $0.sy, $0.ox, $0.oy) } ?? SIMD4<Float>(1, 1, 0, 0)
        let needMask = !(frame?.maskEyes.isEmpty ?? true)
        attachments(w, h, mask: needMask)

        // every vertex this frame, into one buffer
        var items: [(Item, Int)] = []
        var mouthCopies: [[Float]] = []
        var total = 0
        func add(_ it: Item) { items.append((it, total)); total += it.positions.count * 4 }
        var maskItems: [(Item, Int, Int)] = []
        if let frame, let gpu, let puppet {
            for e in frame.maskEyes {
                let L = puppet.layers[e.layer], G = gpu.layers[e.layer]
                guard let tex = G.mask else { continue }
                let it = Item(positions: L.out, uvs: G.uvs, indices: G.indices, indexCount: G.indexCount, texture: tex,
                              uniforms: Uniforms(view: view, maskSel: .zero, alpha: 1, cut: 0, soft: 0, mode: 1), stencil: .none)
                maskItems.append((it, total, e.channel)); total += it.positions.count * 4
            }
            for c in frame.commands {
                let L = puppet.layers[c.layer], G = gpu.layers[c.layer]
                let tex: MTLTexture?
                switch c.texture {
                case .main: tex = G.main
                case .frame(let k): tex = k < G.frames.count ? G.frames[k] : G.main
                case .mask: tex = G.mask
                case .talk: tex = G.talk ?? G.main
                case .browTex: tex = G.brows
                }
                guard let tex, G.indexCount > 0 else { continue }
                let pos: [Float]
                switch c.vertices {
                case .out: pos = L.out
                case .outB: pos = L.outB ?? L.out
                case .custom(let v): pos = v; mouthCopies.append(v)
                }
                let sel = SIMD4<Float>(c.maskChannel == 0 ? 1 : 0, c.maskChannel == 1 ? 1 : 0, c.maskChannel == 2 ? 1 : 0, c.maskChannel == 3 ? 1 : 0)
                add(Item(positions: pos, uvs: G.uvs, indices: G.indices, indexCount: G.indexCount, texture: tex,
                         uniforms: Uniforms(view: view, maskSel: sel, alpha: c.alpha, cut: c.cut, soft: c.soft, mode: c.mode), stencil: c.stencil))
            }
        }
        for it in extra { add(it) }
        var overlayItem: Item?
        if let overlay, let quad = fullScreenQuad() {
            overlayItem = Item(positions: [-1, -1, 1, -1, -1, 1, 1, 1], uvs: quad.uvs, indices: quad.indices, indexCount: 6, texture: overlay,
                               uniforms: Uniforms(view: SIMD4(1, 1, 0, 0), maskSel: .zero, alpha: 1, cut: 0, soft: 0, mode: 0), stencil: .none)
            add(overlayItem!)
        }
        let vb = vertexRing(max(16, total))
        let base = vb.contents()
        for (it, off) in items { it.positions.withUnsafeBytes { base.advanced(by: off).copyMemory(from: $0.baseAddress!, byteCount: $0.count) } }
        for (it, off, _) in maskItems { it.positions.withUnsafeBytes { base.advanced(by: off).copyMemory(from: $0.baseAddress!, byteCount: $0.count) } }

        // the mask pass: the whites of the eyes whose iris moved, a channel each
        if needMask, let maskTex, !maskItems.isEmpty {
            let rp = MTLRenderPassDescriptor()
            rp.colorAttachments[0].texture = maskTex
            rp.colorAttachments[0].loadAction = .clear
            rp.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            rp.colorAttachments[0].storeAction = .store
            if let enc = cb.makeRenderCommandEncoder(descriptor: rp) {
                enc.setFragmentSamplerState(sampler, index: 0)
                for (it, off, ch) in maskItems {
                    enc.setRenderPipelineState(maskPipes[min(3, ch)])
                    encode(enc, it, vb, off)
                }
                enc.endEncoding()
            }
        }
        let rp = MTLRenderPassDescriptor()
        rp.colorAttachments[0].texture = target
        rp.colorAttachments[0].loadAction = .clear
        rp.colorAttachments[0].clearColor = MTLClearColor(red: background.x, green: background.y, blue: background.z, alpha: background.w)
        rp.colorAttachments[0].storeAction = .store
        rp.stencilAttachment.texture = stencilTex
        rp.stencilAttachment.loadAction = .clear
        rp.stencilAttachment.clearStencil = 0
        rp.stencilAttachment.storeAction = .dontCare
        guard let enc = cb.makeRenderCommandEncoder(descriptor: rp) else { cb.commit(); return }
        enc.setFragmentSamplerState(sampler, index: 0)
        enc.setFragmentTexture(needMask ? maskTex : nil, index: 1)
        if !needMask, let any = items.first?.0.texture { enc.setFragmentTexture(any, index: 1) }
        for (it, off) in items {
            switch it.stencil {
            case .none: enc.setRenderPipelineState(mainPipe); enc.setDepthStencilState(noStencil)
            case .write(let r): enc.setRenderPipelineState(stencilPipe); enc.setDepthStencilState(writeStencil); enc.setStencilReferenceValue(UInt32(r))
            case .test(let r): enc.setRenderPipelineState(mainPipe); enc.setDepthStencilState(testStencil); enc.setStencilReferenceValue(UInt32(r))
            }
            encode(enc, it, vb, off)
        }
        enc.endEncoding()
        if let present { cb.present(present) }
        cb.commit()
        _ = mouthCopies
    }

    private func encode(_ enc: MTLRenderCommandEncoder, _ it: Item, _ vb: MTLBuffer, _ off: Int) {
        var u = it.uniforms
        enc.setVertexBuffer(vb, offset: off, index: 0)
        enc.setVertexBuffer(it.uvs, offset: 0, index: 1)
        enc.setVertexBytes(&u, length: MemoryLayout<Uniforms>.stride, index: 2)
        enc.setFragmentBytes(&u, length: MemoryLayout<Uniforms>.stride, index: 0)
        enc.setFragmentTexture(it.texture, index: 0)
        enc.drawIndexedPrimitives(type: .triangle, indexCount: it.indexCount, indexType: .uint32, indexBuffer: it.indices, indexBufferOffset: 0)
    }

    private var quad: (uvs: MTLBuffer, indices: MTLBuffer)?
    /// two triangles over the whole frame (positions in clip space with y flipped, as the vertex shader expects)
    func fullScreenQuad() -> (uvs: MTLBuffer, indices: MTLBuffer)? {
        if quad == nil, let u = buffer([Float(0), 0, 1, 0, 0, 1, 1, 1]), let i = buffer([UInt32(0), 1, 2, 1, 3, 2]) { quad = (u, i) }
        return quad
    }

    /// a textured quad at four corners given in drawing-buffer pixels (top-left origin), for a PNGTuber's picture
    public func quadItem(corners c: [SIMD2<Float>], width w: Int, height h: Int, texture: MTLTexture) -> Item? {
        guard let q = fullScreenQuad(), c.count == 4 else { return nil }
        let pos = c.flatMap { [$0.x, $0.y] }
        return Item(positions: pos, uvs: q.uvs, indices: q.indices, indexCount: 6, texture: texture,
                    uniforms: Uniforms(view: SIMD4(2 / Float(w), 2 / Float(h), -1, -1), maskSel: .zero, alpha: 1, cut: 0, soft: 0, mode: 0), stencil: .none)
    }
}

/// a loaded puppet's GPU side: per layer its textures, texture coordinates and triangles
@MainActor
public final class PuppetGPU {
    public struct Layer {
        public var main: MTLTexture?
        public var frames: [MTLTexture]
        public var mask: MTLTexture?
        public var talk: MTLTexture?
        public var brows: MTLTexture?
        public var uvs: MTLBuffer
        public var indices: MTLBuffer
        public var indexCount: Int
    }
    public let layers: [Layer]

    public init(renderer: MetalRenderer, puppet: Puppet, textures: [LoadedModel.Textures]) throws {
        var out: [Layer] = []
        for (i, L) in puppet.layers.enumerated() {
            let t = textures[i]
            guard let uvs = renderer.buffer(L.uv), let idx = renderer.buffer(L.tri) else {
                throw LivLivError(.tooLarge, "LivLiv: the GPU ran out of memory for this model")
            }
            let main = renderer.texture(t.main)
            if main == nil { throw LivLivError(.tooLarge, "LivLiv: the GPU ran out of memory for this model") }
            out.append(Layer(main: main, frames: t.frames.compactMap { renderer.texture($0) }, mask: t.mask.flatMap { renderer.texture($0) },
                             talk: t.talk.flatMap { renderer.texture($0) }, brows: t.brows.flatMap { renderer.texture($0) },
                             uvs: uvs, indices: idx, indexCount: L.tri.count))
        }
        layers = out
    }
}
#endif
