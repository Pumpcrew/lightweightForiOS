import Foundation
import LivLivCore

/// Face tracking (tracking.ts startFaceTracking) with ARKit's TrueDepth face tracking on iOS: ARKit's blendshapes carry
/// the same names MediaPipe's do, and the face's transform its pose; FaceMapper turns them into the character's params as
/// the original does. Camera pictures stay on the device and are never stored.
@MainActor
public protocol FaceTrackingControl: AnyObject {
    var mapper: FaceMapper { get }
    func start(_ composer: PoseComposer) throws
    func stop()
}

#if os(iOS) && canImport(ARKit)
import ARKit
import QuartzCore
import UIKit

@MainActor
public final class FaceTracking: NSObject, FaceTrackingControl {
    public static var isSupported: Bool { ARFaceTrackingConfiguration.isSupported }
    public let mapper = FaceMapper()
    private let session = ARSession()
    private var driver: FaceDriver?
    private weak var composer: PoseComposer?
    private let relay = Relay()

    public override init() {
        super.init()
        relay.mapper = mapper
        session.delegate = relay
        session.delegateQueue = .main
    }

    public func start(_ composer: PoseComposer) throws {
        guard ARFaceTrackingConfiguration.isSupported else {
            throw LivLivError(.missingFeature, "LivLiv: face tracking needs a TrueDepth camera, which this device does not have")
        }
        let c = ARFaceTrackingConfiguration()
        c.maximumNumberOfTrackedFaces = 1
        c.isLightEstimationEnabled = false
        session.run(c, options: [.resetTracking, .removeExistingAnchors])
        let d = FaceDriver(mapper: mapper, now: { CACurrentMediaTime() })
        composer.add(d)
        driver = d; self.composer = composer
    }

    public func stop() {
        session.pause()
        if let d = driver { composer?.remove(d) }
        driver = nil
    }

    /// ARKit's delegate, on the main queue
    final class Relay: NSObject, ARSessionDelegate {
        var mapper: FaceMapper?
        private static let names: [(ARFaceAnchor.BlendShapeLocation, String)] = [
            (.eyeBlinkLeft, "eyeBlinkLeft"), (.eyeBlinkRight, "eyeBlinkRight"), (.jawOpen, "jawOpen"),
            (.eyeLookOutLeft, "eyeLookOutLeft"), (.eyeLookInLeft, "eyeLookInLeft"), (.eyeLookOutRight, "eyeLookOutRight"), (.eyeLookInRight, "eyeLookInRight"),
            (.eyeLookUpLeft, "eyeLookUpLeft"), (.eyeLookUpRight, "eyeLookUpRight"), (.eyeLookDownLeft, "eyeLookDownLeft"), (.eyeLookDownRight, "eyeLookDownRight"),
            (.browInnerUp, "browInnerUp"), (.browOuterUpLeft, "browOuterUpLeft"), (.browOuterUpRight, "browOuterUpRight"),
            (.browDownLeft, "browDownLeft"), (.browDownRight, "browDownRight"), (.mouthSmileLeft, "mouthSmileLeft"), (.mouthSmileRight, "mouthSmileRight"),
        ]

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let face = anchors.compactMap({ $0 as? ARFaceAnchor }).first, face.isTracked, let frame = session.currentFrame else { return }
            let orientation = MainActor.assumeIsolated { () -> UIInterfaceOrientation in
                (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.effectiveGeometry.interfaceOrientation ?? .portrait
            }
            // the face in the camera's space as the screen is turned: x right, y up, z toward the viewer
            let m = frame.camera.viewMatrix(for: orientation) * face.transform
            var arr: [Double] = []
            for c in [m.columns.0, m.columns.1, m.columns.2, m.columns.3] { arr += [Double(c.x), Double(c.y), Double(c.z), Double(c.w)] }
            arr[12] *= 100; arr[13] *= 100; arr[14] *= 100  // metres to centimetres, as MediaPipe gives them
            var shapes: [String: Double] = [:]
            for (k, n) in Self.names { if let v = face.blendShapes[k] { shapes[n] = v.doubleValue } }
            MainActor.assumeIsolated { mapper?.read(FaceSample(blendshapes: shapes, matrix: arr), now: CACurrentMediaTime()) }
        }
    }
}
#endif
