import LivLivCore
import LivLivKit
import LivLivSamples
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var model: AppModel
    @State private var showImport = false
    @State private var showSettings = false
    @State private var showInfo = false
    @State private var pickingClip = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    StageContainer(stage: model.stage)
                    if model.stage.loading {
                        ProgressView().controlSize(.large).padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Controls(pickingClip: $pickingClip)
            }
            .navigationTitle(Text(verbatim: model.stage.title.isEmpty ? "livlivIOSPlayer" : model.stage.title))
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Menu {
                        ForEach(model.featured) { c in
                            Button {
                                model.selectFeatured(c)
                            } label: {
                                if model.currentFeatured == c.id { Label { Text(verbatim: c.name + " (\(c.id))") } icon: { Image(systemName: "checkmark") } } else { Text(verbatim: c.name + " (\(c.id))") }
                            }
                        }
                    } label: {
                        Label("Characters", systemImage: "person.crop.square")
                    }
                    .accessibilityIdentifier("menu.characters")
                }
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { showImport = true } label: { Label("Import", systemImage: "square.and.arrow.down") }
                        .accessibilityIdentifier("menu.import")
                    Button { showInfo = true } label: { Label("Character Info", systemImage: "info.circle") }
                        .disabled(model.stage.isEmpty)
                    Button { showSettings = true } label: { Label("Settings", systemImage: "gearshape") }
                        .accessibilityIdentifier("menu.settings")
                }
            }
        }
        .sheet(isPresented: $showImport) { ImportView().environmentObject(model) }
        .sheet(isPresented: $showSettings) { SettingsView().environmentObject(model) }
        .sheet(isPresented: $showInfo) { CharacterInfoView().environmentObject(model) }
        .fileImporter(isPresented: $pickingClip, allowedContentTypes: [.audio], allowsMultipleSelection: false) { r in
            if case .success(let urls) = r, let u = urls.first { model.playClip(u, securityScoped: true) }
        }
        .failureAlert($model.failure)
        .task { model.loadInitial() }
    }
}

/// the stage: Metal for LivLiv models and PNGTubers, RealityKit for a VRM
struct StageContainer: View {
    @ObservedObject var stage: CharacterStage
    var body: some View {
        Group {
            if stage.kind == .vrm {
                VRMStageView(stage: stage)
            } else {
                StageView(stage: stage)
            }
        }
        .overlay {
            if stage.isEmpty && !stage.loading {
                ContentUnavailableView("No Character", systemImage: "person.crop.square", description: Text("Pick one from the Characters menu, or open one with Import."))
            }
        }
    }
}

struct Controls: View {
    @EnvironmentObject var model: AppModel
    @Binding var pickingClip: Bool

    var body: some View {
        let stage = model.stage
        VStack(spacing: 10) {
            if !stage.expressions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(stage.expressions) { e in
                            Button(LocalizedStringKey(e.label)) { stage.setExpression(e.id) }
                                .buttonStyle(.bordered)
                                .tint(stage.currentExpression == e.id ? .accentColor : .gray)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ActionID.allCases, id: \.self) { a in
                        Button(actionLabel(a)) { stage.act(a) }.buttonStyle(.bordered)
                    }
                    Toggle(isOn: Binding(get: { stage.away }, set: { stage.away = $0 })) { Label("Doze", systemImage: "moon.zzz") }
                        .toggleStyle(.button)
                    Divider().frame(height: 24)
                    Toggle(isOn: Binding(get: { model.micOn }, set: { _ in model.toggleMic() })) { Label("Microphone", systemImage: "mic") }
                        .toggleStyle(.button)
                    Button {
                        if model.clipPlaying { model.stopClip() } else { pickingClip = true }
                    } label: { Label(model.clipPlaying ? LocalizedStringKey("Stop") : LocalizedStringKey("Audio File"), systemImage: model.clipPlaying ? "stop.fill" : "waveform") }
                        .buttonStyle(.bordered)
                    if model.faceTrackingSupported {
                        Toggle(isOn: Binding(get: { model.faceOn }, set: { _ in model.toggleFace() })) { Label("Face Tracking", systemImage: "face.smiling") }
                            .toggleStyle(.button)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(.bar)
        .disabled(stage.isEmpty)
    }

    private func actionLabel(_ a: ActionID) -> LocalizedStringKey {
        switch a { case .nod: return "Nod"; case .shake: return "Shake"; case .tilt: return "Tilt"; case .hop: return "Hop"; case .shy: return "Shy" }
    }
}

/// the loaded character's details: name, origin, author and licence terms
struct CharacterInfoView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(model.stage.info.rows.enumerated()), id: \.offset) { _, r in
                    LabeledContent {
                        Group { if r.translated { Text(LocalizedStringKey(r.value)) } else { Text(verbatim: r.value) } }
                            .textSelection(.enabled).multilineTextAlignment(.trailing)
                    } label: {
                        Text(LocalizedStringKey(r.label))
                    }
                }
            }
            .navigationTitle(Text(verbatim: model.stage.title))
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Close") { dismiss() } } }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 360)
        #endif
    }
}
