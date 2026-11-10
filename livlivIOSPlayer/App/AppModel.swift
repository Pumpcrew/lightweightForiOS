import Combine
import Foundation
import LivLivCore
import LivLivKit
import LivLivSamples
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// a failure to show: the alert's title and the text its TextView shows
struct Failure: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

/// one entry of the app's Documents folder, as the import list shows it
struct DocumentEntry: Identifiable, Hashable {
    var id: URL { url }
    let url: URL
    let isFolder: Bool
    var name: String { url.lastPathComponent }
    var symbol: String {
        if isFolder { return "folder" }
        switch url.pathExtension.lowercased() {
        case "vrm", "glb": return "cube"
        case "livliv", "zip": return "shippingbox"
        default: return "doc"
        }
    }
}

@MainActor
final class AppModel: ObservableObject {
    let stage = CharacterStage()
    let featured = FeaturedCharacters.all
    @Published var currentFeatured: String?
    @Published var failure: Failure?
    @Published var documents: [DocumentEntry] = []
    @Published var micOn = false
    @Published var faceOn = false
    @Published var clipPlaying = false

    @Published var idle = AppModel.stored("idle", true) { didSet { UserDefaults.standard.set(idle, forKey: "idle"); stage.composer.idle = idle } }
    @Published var talkMotion = AppModel.stored("talkMotion", 1.0) { didSet { UserDefaults.standard.set(talkMotion, forKey: "talkMotion") } }
    @Published var bounce = AppModel.stored("bounce", false) { didSet { UserDefaults.standard.set(bounce, forKey: "bounce") } }
    @Published var pixelRatio = AppModel.stored("pixelRatio", 2.0) { didSet { UserDefaults.standard.set(pixelRatio, forKey: "pixelRatio"); stage.maxPixelRatio = pixelRatio } }
    @Published var mirror = AppModel.stored("mirror", true) { didSet { UserDefaults.standard.set(mirror, forKey: "mirror") } }
    var lastCharacter: String {
        get { UserDefaults.standard.string(forKey: "lastCharacter") ?? "k01" }
        set { UserDefaults.standard.set(newValue, forKey: "lastCharacter") }
    }
    private static func stored<T>(_ key: String, _ fallback: T) -> T { UserDefaults.standard.object(forKey: key) as? T ?? fallback }

    private let mic = MicrophoneLipSync()
    private let clip = ClipLipSync()
    #if os(iOS)
    private var face: FaceTracking?
    #endif

    private var forward: AnyCancellable?

    init() {
        // what the stage publishes (the character, its expressions, loading) re-renders the views that read it through the model
        forward = stage.objectWillChange.sink { [weak self] _ in self?.objectWillChange.send() }
        stage.composer.idle = idle
        stage.maxPixelRatio = pixelRatio
        clip.onFinish = { [weak self] in self?.clipPlaying = false }
        prepareDocuments()
    }

    // MARK: Documents

    static var documentsURL: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    /// the Documents folder the user adds characters to (Files app on iPhone / iPad / Vision Pro, Finder on Mac), with a note
    /// on what goes there
    func prepareDocuments() {
        let fm = FileManager.default, dir = Self.documentsURL
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        // a note on what goes here, in the device's language when the folder is first made (it also makes the folder show
        // in the Files app, which lists an app's Documents only once it holds a file)
        let has = ((try? fm.contentsOfDirectory(atPath: dir.path)) ?? []).contains { $0.hasSuffix(".txt") }
        if !has {
            let note = dir.appendingPathComponent(String(localized: "Put your characters here") + ".txt")
            let text = "livlivIOSPlayer\n\n" + String(localized: "documents.note", defaultValue: """
            Put a character in this folder (the app's Documents), then choose it from Import in the app.

            • LivLiv model: a folder with model.json and textures/, or a .livliv file
            • VRM: a .vrm file (VRM 0.x / 1.0), or a folder with one .vrm in it
            • PNGTuber: a folder with closed.png and open.png (optional: blink.png, blink-open.png, name.txt)

            Use each character you add as its license says (meta.license in model.json, a VRM's terms of use).
            """)
            try? text.write(to: note, atomically: true, encoding: .utf8)
        }
        refreshDocuments()
    }

    func refreshDocuments() {
        let fm = FileManager.default
        let items = (try? fm.contentsOfDirectory(at: Self.documentsURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])) ?? []
        documents = items.filter { $0.pathExtension.lowercased() != "txt" }.map { u in
            DocumentEntry(url: u, isFolder: (try? u.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true)
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// opens the Documents folder where the user can add folders: the Files app, or Finder
    func revealDocuments() {
        let dir = Self.documentsURL
        #if os(macOS)
        NSWorkspace.shared.activateFileViewerSelecting([dir])
        #else
        if let u = URL(string: "shareddocuments://" + dir.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!) {
            UIApplication.shared.open(u)
        }
        #endif
    }

    // MARK: Loading

    func loadInitial() {
        guard stage.isEmpty else { return }
        let id = featured.contains { $0.id == lastCharacter } ? lastCharacter : featured.first?.id
        if let c = featured.first(where: { $0.id == id }) { selectFeatured(c) }
    }

    func selectFeatured(_ c: FeaturedCharacter) {
        Task {
            do {
                try await stage.load(CharacterSource(kind: .livliv, url: c.folder, name: c.name), credit: c.credit, featured: true)
                currentFeatured = c.id
                lastCharacter = c.id
            } catch { show(error, about: c.name) }
        }
    }

    /// looks through what the user picked (a folder or a file in Documents, or elsewhere), and loads it when it can open;
    /// if it cannot, says why in an alert
    func open(_ url: URL, securityScoped: Bool = false) {
        Task {
            let scoped = securityScoped && url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do {
                let source = try await Task.detached(priority: .userInitiated) { try CharacterInspector.inspect(url) }.value
                try await stage.load(source)
                currentFeatured = nil
            } catch { show(error, about: url.lastPathComponent) }
        }
    }

    // MARK: Lip sync and tracking

    func toggleMic() {
        if micOn { mic.stop(); micOn = false; return }
        Task {
            do { try await mic.start(stage.composer, motion: talkMotion, bounce: bounce); micOn = true }
            catch { show(error, about: String(localized: "Microphone")) }
        }
    }

    func playClip(_ url: URL, securityScoped: Bool) {
        Task {
            let scoped = securityScoped && url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            do { try await clip.play(url, on: stage.composer, motion: talkMotion); clipPlaying = true }
            catch { show(error, about: url.lastPathComponent) }
        }
    }
    func stopClip() { clip.stop(); clipPlaying = false }

    var faceTrackingSupported: Bool {
        #if os(iOS)
        return FaceTracking.isSupported
        #else
        return false
        #endif
    }

    func toggleFace() {
        #if os(iOS)
        if faceOn { face?.stop(); faceOn = false; return }
        do {
            let f = face ?? FaceTracking()
            f.mapper.mirror = mirror
            try f.start(stage.composer)
            face = f; faceOn = true
        } catch { show(error, about: String(localized: "Face Tracking")) }
        #endif
    }
    func calibrateFace() {
        #if os(iOS)
        face?.mapper.calibrate()
        #endif
    }
    func applyMirror() {
        #if os(iOS)
        face?.mapper.mirror = mirror
        #endif
    }

    // MARK: Failures

    func show(_ error: Error, about what: String) {
        if error is CancellationError { return }
        let e = error as? LivLivError
        let reason: String
        switch e?.code {
        case .notAModel?: reason = String(localized: "This is not a character file, or not a format this app opens (LivLiv model, .livliv, VRM, PNGTuber folder).")
        case .invalid?: reason = String(localized: "The file's contents are invalid or damaged.")
        case .tooLarge?: reason = String(localized: "The file or a picture in it is larger than this app allows.")
        case .newerFormat?: reason = String(localized: "It was made in a newer version of the format. Update the app.")
        case .missingFeature?: reason = String(localized: "It needs a feature this app (or this device) does not support.")
        case .missingFile?: reason = String(localized: "A file it needs is missing.")
        case .permission?: reason = String(localized: "There is no permission to access it.")
        case .unreachable?: reason = String(localized: "The file or the device is not available.")
        case .noMetal?: reason = String(localized: "Metal (the GPU) is not available on this device.")
        case nil: reason = String(localized: "An unknown error occurred.")
        }
        let detail = e?.message ?? error.localizedDescription
        let code = e?.code.rawValue ?? String(describing: type(of: error))
        // the details (the player's own words) stay in English: they are what a bug report needs
        let message = String(localized: "Target") + ": " + what + "\n\n" + String(localized: "Reason") + ": " + reason + "\n\n"
            + String(localized: "Details") + ":\n" + detail + "\n\n" + String(localized: "Error code") + ": " + code
        failure = Failure(title: String(localized: "Can't Open"), message: message)
    }
}
