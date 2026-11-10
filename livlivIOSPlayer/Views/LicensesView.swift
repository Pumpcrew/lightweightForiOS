import LivLivSamples
import SwiftUI

/// the open source licenses menu: the "라이선스와 상표" document, then the full texts it names
struct LicensesView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    DocumentView(title: "Licenses and Trademarks", text: Legal.licensesAndTrademarks, markdown: true)
                } label: {
                    Label("Licenses and Trademarks", systemImage: "c.circle")
                }
                .accessibilityIdentifier("licenses.document")
            } footer: {
                Text("A summary of the licenses of this app's code and bundled characters, and of the trademarks involved.")
            }
            Section("Original Texts") {
                NavigationLink {
                    DocumentView(title: "Apache License 2.0", text: Legal.text("LivLivPlayer-LICENSE-Apache-2.0", "txt"), markdown: false)
                } label: { Text(verbatim: "LivLiv Player — Apache License 2.0") }
                NavigationLink {
                    DocumentView(title: "NOTICE", text: Legal.text("LivLivPlayer-NOTICE", "txt"), markdown: false)
                } label: { Text(verbatim: "LivLiv Player — NOTICE") }
                NavigationLink {
                    DocumentView(title: "Character License", text: FeaturedCharacters.licenseText, markdown: true)
                } label: { Text(verbatim: "LivLiv Featured Characters License") }
                NavigationLink("Character Sources and Credits") {
                    DocumentView(title: "Character Credits", text: FeaturedCharacters.creditsText, markdown: true)
                }
            }
            Section("Bundled Characters") {
                ForEach(FeaturedCharacters.all) { c in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: "\(c.name) (\(c.id))")
                        Text(verbatim: c.credit ?? "Characters: LivLiv (livliv.ai) — LivLiv Featured Characters License")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Open Source Licenses")
    }
}

enum Legal {
    static func text(_ name: String, _ ext: String) -> String {
        guard let u = Bundle.main.url(forResource: name, withExtension: ext) ?? Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Legal"),
              let s = try? String(contentsOf: u, encoding: .utf8) else { return String(localized: "(\(name).\(ext) could not be found)") }
        return s
    }

    /// the "Licenses and Trademarks" document: written in Korean and English (a legal summary is not machine-translated
    /// into every language); Korean for a Korean device, English everywhere else
    static var licensesAndTrademarks: String {
        let lang = Locale.preferredLanguages.first ?? "en"
        return lang.hasPrefix("ko") ? text("LicensesAndTrademarks", "md") : text("LicensesAndTrademarks-en", "md")
    }
}

/// a long text: plain (a licence's own layout) or simple Markdown (headings, lists, emphasis, links)
struct DocumentView: View {
    let title: LocalizedStringKey
    let text: String
    let markdown: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if markdown {
                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, b in block(b) }
                } else {
                    Text(text).font(.system(.footnote, design: .monospaced))
                }
            }
            .textSelection(.enabled)
            .padding()
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .navigationTitle(title)
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private enum Block { case h(Int, String), bullet(String), para(String), rule }
    private var blocks: [Block] {
        var out: [Block] = [], para: [String] = []
        func flush() { if !para.isEmpty { out.append(.para(para.joined(separator: " "))); para = [] } }
        for raw in text.components(separatedBy: .newlines) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { flush(); continue }
            if line == "---" { flush(); out.append(.rule); continue }
            if line.hasPrefix("#") {
                flush()
                let level = line.prefix { $0 == "#" }.count
                out.append(.h(level, String(line.dropFirst(level)).trimmingCharacters(in: .whitespaces)))
                continue
            }
            if line.hasPrefix("- ") || line.hasPrefix("* ") { flush(); out.append(.bullet(String(line.dropFirst(2)))); continue }
            para.append(line)
        }
        flush()
        return out
    }

    private func inline(_ s: String) -> Text {
        if let a = try? AttributedString(markdown: s, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) { return Text(a) }
        return Text(s)
    }

    @ViewBuilder private func block(_ b: Block) -> some View {
        switch b {
        case .h(let l, let s): inline(s).font(l == 1 ? .title2.bold() : l == 2 ? .title3.bold() : .headline).padding(.top, l == 1 ? 4 : 10)
        case .bullet(let s): HStack(alignment: .firstTextBaseline, spacing: 6) { Text("•"); inline(s) }.font(.callout)
        case .para(let s): inline(s).font(.callout)
        case .rule: Divider().padding(.vertical, 8)
        }
    }
}
