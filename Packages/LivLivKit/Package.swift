// swift-tools-version:6.0
// LivLivKit: a Swift / Metal / RealityKit port of LivLiv Player (https://github.com/livliv-dev/player, Apache-2.0).
//  - LivLivCore: the format, the rig, the motion, lip-sync analysis, the glTF / VRM reader and its pose maths. Pure Swift
//    (Foundation only), so it builds and its tests run on any platform Swift runs on
//  - LivLivKit: what draws and listens on Apple platforms: the Metal renderer, the RealityKit VRM view, image decoding,
//    the microphone, audio clips, ARKit face tracking, and SwiftUI views
//  - LivLivSamples: the 21 featured characters (their own licence: Characters/LICENSE.md, Characters/CREDITS.md)
import PackageDescription

let package = Package(
    name: "LivLivKit",
    platforms: [.iOS(.v18), .macOS(.v15), .visionOS(.v2)],
    products: [
        .library(name: "LivLivCore", targets: ["LivLivCore"]),
        .library(name: "LivLivKit", targets: ["LivLivKit"]),
        .library(name: "LivLivSamples", targets: ["LivLivSamples"]),
    ],
    targets: [
        // the rig moves tens of thousands of vertices a frame: optimized in Debug too (about 8x faster than -Onone)
        .target(name: "LivLivCore", swiftSettings: [.unsafeFlags(["-O"], .when(configuration: .debug))]),
        .target(name: "LivLivKit", dependencies: ["LivLivCore"]),
        .target(name: "LivLivSamples", resources: [.copy("Characters")]),
        .testTarget(name: "LivLivCoreTests", dependencies: ["LivLivCore"], resources: [.copy("Fixtures")]),
    ],
    swiftLanguageModes: [.v5]
)
