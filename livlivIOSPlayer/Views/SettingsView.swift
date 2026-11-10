import LivLivKit
import SwiftUI

/// the settings menu: how the character moves and is drawn, and the open source licenses
struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Motion") {
                    Toggle("Automatic motion (breathing, blinking, looking around)", isOn: $model.idle)
                    VStack(alignment: .leading) {
                        Text("Gestures while talking: \(model.talkMotion, specifier: "%.1f")")
                        Slider(value: $model.talkMotion, in: 0...2, step: 0.1)
                    }
                    Toggle("Bounce while talking (PNGTuber style)", isOn: $model.bounce)
                    Text("Gesture and bounce settings take effect the next time lip sync is turned on.").font(.footnote).foregroundStyle(.secondary)
                }
                Section("Display") {
                    Picker("Rendering resolution", selection: $model.pixelRatio) {
                        Text("1x (power saving)").tag(1.0)
                        Text(verbatim: "2x").tag(2.0)
                        Text(verbatim: "3x").tag(3.0)
                    }
                }
                if model.faceTrackingSupported {
                    Section("Face Tracking") {
                        Toggle("Mirror mode", isOn: $model.mirror).onChange(of: model.mirror) { model.applyMirror() }
                        Button("Set the current pose as facing front") { model.calibrateFace() }.disabled(!model.faceOn)
                    }
                }
                Section("About") {
                    LabeledContent("App version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                    LabeledContent("Based on", value: String(localized: "LivLiv Player 0.3.0 (ported from TypeScript to Swift)"))
                    LabeledContent("Renderer", value: "Metal · RealityKit (VRM)")
                }
                Section("Legal") {
                    NavigationLink {
                        LicensesView()
                    } label: {
                        Label("Open Source Licenses", systemImage: "doc.text")
                    }
                    .accessibilityIdentifier("settings.licenses")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 560)
        #endif
    }
}
