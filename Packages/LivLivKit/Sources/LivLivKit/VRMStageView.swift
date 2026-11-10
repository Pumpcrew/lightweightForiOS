#if canImport(RealityKit) && canImport(SwiftUI)
import CoreGraphics
import Foundation
import LivLivCore
import Metal
import RealityKit
import simd
import SwiftUI

/// A VRM drawn with RealityKit: one ModelEntity per glTF primitive, on a LowLevelMesh the CPU-skinned vertices are
/// written into each frame (VRMRig: humanoid pose, expressions by morph targets, look-at, spring bones). Materials are
/// MToon approximated by unlit ones (its lit colour and texture; VRoid's textures carry their own shading), with
/// glTF's alpha modes and double-sidedness. Framed from the head down to the hips, as vrm.ts frames a VRM.
@MainActor
final class VRMScene {
    let root = Entity()
    let model = Entity()
    #if !os(visionOS)
    let camera = PerspectiveCamera()
    #endif
    private var meshes: [(LowLevelMesh, Int)] = []
    let rig: VRMRig
    private let fov: Float = 20

    struct Vertex { var x, y, z, u, v: Float }

    init(rig: VRMRig, images: [Int: CGImage]) throws {
        self.rig = rig
        root.addChild(model)
        var textures: [Int: TextureResource] = [:]
        func texture(_ ti: Int?) -> TextureResource? {
            guard let ti, let src = rig.doc.textureSources[safe: ti] ?? nil, let img = images[src] else { return nil }
            if let t = textures[src] { return t }
            let t = try? TextureResource(image: img, options: .init(semantic: .color))
            textures[src] = t
            return t
        }
        let f = rig.frame
        let bounds = BoundingBox(min: [-f.height * 2, f.y - f.height * 4, -f.height * 2], max: [f.height * 2, f.y + f.height * 4, f.height * 2])
        for (di, d) in rig.drawables.enumerated() {
            let n = d.positions.count
            guard n > 0, !d.indices.isEmpty else { continue }
            var desc = LowLevelMesh.Descriptor()
            desc.vertexAttributes = [
                LowLevelMesh.Attribute(semantic: .position, format: .float3, offset: 0),
                LowLevelMesh.Attribute(semantic: .uv0, format: .float2, offset: 12),
            ]
            desc.vertexLayouts = [LowLevelMesh.Layout(bufferIndex: 0, bufferStride: MemoryLayout<Vertex>.stride)]
            desc.vertexCapacity = n
            desc.indexCapacity = d.indices.count
            desc.indexType = .uint32
            let mesh = try LowLevelMesh(descriptor: desc)
            mesh.withUnsafeMutableIndices { raw in
                let p = raw.bindMemory(to: UInt32.self)
                for i in 0..<d.indices.count { p[i] = d.indices[i] }
            }
            write(mesh, d)
            mesh.parts.replaceAll([LowLevelMesh.Part(indexCount: d.indices.count, topology: .triangle, bounds: bounds)])
            let resource = try MeshResource(from: mesh)
            let mat = material(d.material.flatMap { rig.doc.materials[safe: $0] }, texture: texture)
            let e = ModelEntity(mesh: resource, materials: [mat])
            model.addChild(e)
            meshes.append((mesh, di))
        }
        // VRM 0.x faces -Z: turned half round to face the viewer (rotateVRM0)
        if rig.flip < 0 { model.orientation = simd_quatf(angle: .pi, axis: [0, 1, 0]) }
        #if !os(visionOS)
        camera.camera.fieldOfViewInDegrees = fov
        camera.camera.near = max(0.001, f.height / 100)
        camera.camera.far = f.height * 100
        root.addChild(camera)
        place(aspect: 2.0 / 3.0)
        #else
        // in a window: the framed part about 0.36 m tall, centred, its front in the window's plane
        let k = 0.36 / max(f.height, 1e-3)
        root.scale = [k, k, k]
        root.position = [0, -f.y * k, 0.06]
        #endif
    }

    /// glTF's sampler as Metal's: REPEAT unless the file says otherwise (KHR_texture_transform offsets past 0...1 need it),
    /// linear and mipmapped unless it asks for NEAREST. Metal's own default would clamp and take the nearest texel
    private static func sampler(_ s: GLTFSampler) -> MaterialParameters.Texture.Sampler {
        func mode(_ w: GLTFSampler.Wrap) -> MTLSamplerAddressMode {
            switch w { case .repeating: .repeat; case .mirrored: .mirrorRepeat; case .clamp: .clampToEdge }
        }
        let d = MTLSamplerDescriptor()
        d.sAddressMode = mode(s.wrapS)
        d.tAddressMode = mode(s.wrapT)
        d.magFilter = s.nearest ? .nearest : .linear
        d.minFilter = s.nearest ? .nearest : .linear
        d.mipFilter = s.nearest ? .notMipmapped : .linear
        d.maxAnisotropy = s.nearest ? 1 : 4
        return MaterialParameters.Texture.Sampler(d)
    }

    private func material(_ m: GLTFMaterial?, texture: (Int?) -> TextureResource?) -> RealityKit.Material {
        var mat = UnlitMaterial()
        let c = m?.baseColor ?? V4(1, 1, 1, 1)
        #if canImport(UIKit)
        let tint = UIColor(red: CGFloat(c.x), green: CGFloat(c.y), blue: CGFloat(c.z), alpha: 1)
        #else
        let tint = NSColor(srgbRed: CGFloat(c.x), green: CGFloat(c.y), blue: CGFloat(c.z), alpha: 1)
        #endif
        if let ti = m?.baseColorTexture, let t = texture(ti) {
            mat.color = .init(tint: tint, texture: .init(t, sampler: Self.sampler(rig.doc.textureSamplers[safe: ti] ?? GLTFSampler())))
        } else {
            mat.color = .init(tint: tint)
        }
        switch m?.alphaMode ?? .opaque {
        case .opaque: break
        case .mask:
            mat.blending = .transparent(opacity: .init(floatLiteral: c.w))
            mat.opacityThreshold = m?.alphaCutoff ?? 0.5
        case .blend:
            mat.blending = .transparent(opacity: .init(floatLiteral: c.w))
        }
        if m?.doubleSided ?? false { mat.faceCulling = MaterialParameterTypes.FaceCulling.none }
        return mat
    }

    private func write(_ mesh: LowLevelMesh, _ d: VRMDrawable) {
        mesh.withUnsafeMutableBytes(bufferIndex: 0) { raw in
            let v = raw.bindMemory(to: Vertex.self)
            let n = min(v.count, d.positions.count)
            for i in 0..<n {
                let p = d.positions[i], t = d.uvs[i]
                v[i] = Vertex(x: p.x, y: p.y, z: p.z, u: t.x, v: 1 - t.y)
            }
        }
    }

    #if !os(visionOS)
    /// tall enough for the head-to-hips height, wide enough for the shoulders on narrow views
    func place(aspect: Float) {
        let f = rig.frame, half = f.height / 2
        let dist = max(half, f.width / 2 / max(aspect, 0.1)) / tan(fov * .pi / 180 / 2)
        camera.position = [0, f.y, dist]
        camera.look(at: [0, f.y, 0], from: [0, f.y, dist], relativeTo: nil)
    }
    #endif

    /// after the rig moved: the vertices into the meshes, the picture's move and scale
    func sync(move: (x: Double, y: Double, s: Double)) {
        for (mesh, di) in meshes { write(mesh, rig.drawables[di]) }
        let h = rig.frame.height
        model.position = [Float(move.x) * h * 0.5, Float(move.y) * h, 0]
        model.scale = [Float(move.s), Float(move.s), Float(move.s)]
    }
}

/// the SwiftUI view a VRM plays in
public struct VRMStageView: View {
    @ObservedObject var stage: CharacterStage
    @State private var holder = SceneHolder()
    public init(stage: CharacterStage) { self.stage = stage }

    @MainActor final class SceneHolder {
        let container = Entity()
        var scene: VRMScene?
        var generation = -1
        var subscription: EventSubscription?
        var aspect: Float = 2.0 / 3.0

        func rebuild(_ stage: CharacterStage) {
            for c in Array(container.children) { c.removeFromParent() }
            scene = nil
            generation = stage.vrmGeneration
            guard case .vrm(let rig, let images) = stage.content, let s = try? VRMScene(rig: rig, images: images) else { return }
            #if !os(visionOS)
            s.place(aspect: aspect)
            #endif
            container.addChild(s.root)
            scene = s
        }
    }

    public var body: some View {
        GeometryReader { geo in
            RealityView { content in
                #if !os(visionOS)
                content.camera = .virtual
                #endif
                content.add(holder.container)
                let h = holder, st = stage
                h.subscription = content.subscribe(to: SceneEvents.Update.self) { event in
                    MainActor.assumeIsolated {
                        st.tick(event.deltaTime)
                        h.scene?.sync(move: st.lastMove)
                    }
                }
                h.rebuild(st)
            } update: { _ in
                if holder.generation != stage.vrmGeneration { holder.rebuild(stage) }
                #if !os(visionOS)
                let a = Float(max(1, geo.size.width) / max(1, geo.size.height))
                if a != holder.aspect { holder.aspect = a; holder.scene?.place(aspect: a) }
                #endif
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { g in stage.pointer(u: g.location.x / max(1, geo.size.width), v: g.location.y / max(1, geo.size.height), on: true) }
                .onEnded { _ in stage.pointerLeft() })
            .simultaneousGesture(TapGesture().onEnded { stage.act(.hop) })
        }
    }
}
#endif
