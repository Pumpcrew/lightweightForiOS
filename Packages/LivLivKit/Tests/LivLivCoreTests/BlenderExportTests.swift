import XCTest
import Foundation
@testable import LivLivCore

/// What the VRM add-on for Blender writes that VRoid Studio and UniVRM do not (upstream issue #1): checked against the
/// add-on's own exports (tests/resources/vrm/*/out of saturday06/VRM-Addon-for-Blender), here on a patched tiny file
final class BlenderExportTests: XCTestCase {
    private func fixture(_ name: String) throws -> Data {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "Fixtures/\(name)", withExtension: nil) ?? Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    /// the GLB with its JSON changed by `edit`, the binary chunk kept
    private func patched(_ name: String, _ edit: (inout [String: Any]) -> Void) throws -> Data {
        let d = try fixture(name)
        func u32(_ o: Int) -> Int { Int(d[o]) | Int(d[o + 1]) << 8 | Int(d[o + 2]) << 16 | Int(d[o + 3]) << 24 }
        let jl = u32(12)
        var json = try XCTUnwrap(try JSONSerialization.jsonObject(with: d.subdata(in: 20..<(20 + jl))) as? [String: Any])
        edit(&json)
        var j = try JSONSerialization.data(withJSONObject: json)
        while j.count % 4 != 0 { j.append(0x20) }
        let rest = d.subdata(in: (20 + jl)..<d.count)
        func le(_ v: Int) -> [UInt8] { [UInt8(v & 255), UInt8(v >> 8 & 255), UInt8(v >> 16 & 255), UInt8(v >> 24 & 255)] }
        var out = Data([0x67, 0x6C, 0x54, 0x46] + le(2) + le(12 + 8 + j.count + rest.count) + le(j.count) + [0x4A, 0x53, 0x4F, 0x4E])
        out.append(j); out.append(rest)
        return out
    }

    func testCompressionNamedButUnusedStillPlays() throws {
        // the add-on can list KHR_draco_mesh_compression in extensionsUsed with no primitive compressed
        let data = try patched("tiny1.vrm") { j in
            j["extensionsUsed"] = ["VRMC_vrm", "KHR_draco_mesh_compression", "VRMC_materials_hdr_emissiveMultiplier"]
            j["extensionsRequired"] = ["VRMC_materials_hdr_emissiveMultiplier"]
        }
        XCTAssertNoThrow(try VRMRig(data: data, fileName: "used.vrm"))
        // on a primitive it is real compression, and said so
        let real = try patched("tiny1.vrm") { j in
            var meshes = j["meshes"] as! [[String: Any]], prims = meshes[0]["primitives"] as! [[String: Any]]
            prims[0]["extensions"] = ["KHR_draco_mesh_compression": ["bufferView": 0, "attributes": ["POSITION": 0]]]
            meshes[0]["primitives"] = prims; j["meshes"] = meshes
        }
        XCTAssertThrowsError(try VRMRig(data: real, fileName: "draco.vrm")) { XCTAssertEqual(($0 as? LivLivError)?.code, .missingFeature) }
    }

    func testTextureTransformAndSampler() throws {
        let data = try patched("tiny1.vrm") { j in
            j["extensionsUsed"] = ["VRMC_vrm", "KHR_texture_transform"]
            j["samplers"] = [["wrapS": 33071, "wrapT": 33648, "magFilter": 9728], [:]]
            j["textures"] = [["sampler": 0], ["sampler": 1], [:]]
            var mats = j["materials"] as! [[String: Any]]
            var pbr = mats[0]["pbrMetallicRoughness"] as! [String: Any]
            pbr["baseColorTexture"] = ["index": 0, "extensions": ["KHR_texture_transform": ["offset": [-0.125, 0.125], "scale": [1.5, 1.0]]]]
            mats[0]["pbrMetallicRoughness"] = pbr; j["materials"] = mats
        }
        let rig = try VRMRig(data: data, fileName: "t.vrm")
        let t = try XCTUnwrap(rig.doc.materials[0].baseColorTransform)
        XCTAssertEqual(t.apply(SIMD2(0, 0)), SIMD2(-0.125, 0.125))
        XCTAssertEqual(t.apply(SIMD2(1, 1)), SIMD2(1.375, 1.125))
        XCTAssertNil(rig.doc.materials[1].baseColorTransform)
        XCTAssertEqual(rig.doc.textureSamplers.count, 3)
        XCTAssertEqual(rig.doc.textureSamplers[0].wrapS, .clamp)
        XCTAssertEqual(rig.doc.textureSamplers[0].wrapT, .mirrored)
        XCTAssertTrue(rig.doc.textureSamplers[0].nearest)
        XCTAssertEqual(rig.doc.textureSamplers[1], GLTFSampler())
        XCTAssertEqual(rig.doc.textureSamplers[2], GLTFSampler())
        // a quarter turn, as three.js turns it
        let r = GLTFUVTransform(rotation: .pi / 2).apply(SIMD2(1, 0))
        XCTAssertEqual(r.x, 0, accuracy: 1e-6); XCTAssertEqual(r.y, -1, accuracy: 1e-6)
    }

    func testPlaceholderNameFallsBackToTheFile() throws {
        // "undefined": the add-on's name until it is filled in
        let data = try patched("tiny1.vrm") { j in
            var ext = j["extensions"] as! [String: Any], v = ext["VRMC_vrm"] as! [String: Any], meta = v["meta"] as? [String: Any] ?? [:]
            meta["name"] = "undefined"; v["meta"] = meta; ext["VRMC_vrm"] = v; j["extensions"] = ext
        }
        XCTAssertEqual(try VRMRig(data: data, fileName: "Avatar.vrm").name, "Avatar")
    }
}
