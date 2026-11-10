import LivLivKit
import SwiftUI
import UniformTypeIdentifiers

/// the import menu: what the user put in the app's Documents folder (a character's folder, a .livliv, a .vrm), to pick
/// one; or a file or folder from anywhere else
struct ImportView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var pickingOther = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if model.documents.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("The Documents folder is empty").font(.headline)
                            Text(hint).font(.footnote).foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    ForEach(model.documents) { e in
                        Button {
                            dismiss()
                            model.open(e.url)
                        } label: {
                            Label { Text(verbatim: e.name) } icon: { Image(systemName: e.symbol) }
                        }
                        .accessibilityIdentifier("import.\(e.name)")
                    }
                } header: {
                    Text(verbatim: "Documents")
                } footer: {
                    Text(hint)
                }
                Section {
                    Button { model.revealDocuments() } label: {
                        #if os(macOS)
                        Label("Open the Documents Folder in Finder", systemImage: "folder.badge.plus")
                        #else
                        Label("Open the Documents Folder in Files", systemImage: "folder.badge.plus")
                        #endif
                    }
                    Button { pickingOther = true } label: { Label("Choose from Another Location…", systemImage: "square.and.arrow.down") }
                }
            }
            .navigationTitle("Import")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { model.refreshDocuments() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
                }
            }
            .refreshable { model.refreshDocuments() }
            .onAppear { model.refreshDocuments() }
            .fileImporter(isPresented: $pickingOther, allowedContentTypes: [.folder, .item], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    guard let u = urls.first else { return }
                    dismiss()
                    model.open(u, securityScoped: true)
                case .failure(let e):
                    model.show(e, about: String(localized: "File Selection"))
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 420, minHeight: 420)
        #endif
    }

    private var hint: LocalizedStringKey {
        #if os(macOS)
        "Put a character in this app's Documents folder in Finder (a character folder with model.json and textures/, a .livliv, a .vrm, or a PNGTuber folder with closed.png and open.png), then choose it here."
        #else
        "In the Files app, open On My iPhone (or iPad) › livlivIOSPlayer and put a character there (a character folder with model.json and textures/, a .livliv, a .vrm, or a PNGTuber folder with closed.png and open.png), then choose it here."
        #endif
    }
}
