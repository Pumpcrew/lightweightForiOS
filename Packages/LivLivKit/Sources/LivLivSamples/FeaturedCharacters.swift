// The 21 featured characters of LivLiv Player, as its repository ships them (characters/). They are NOT covered by the
// Apache License: free for personal, non-commercial use with credit ("Characters: LivLiv (livliv.ai)"); Kujira, Kujira Q
// and Pen adapt other people's characters under their own terms. See Characters/LICENSE.md and Characters/CREDITS.md.
import Foundation

public struct FeaturedCharacter: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    /// the credit a character from someone else's work asks for (Kujira, Kujira Q, Pen)
    public let credit: String?
    /// the character's folder (model.json, textures/, cover.webp, avatar.webp)
    public let folder: URL
    public var cover: URL { folder.appendingPathComponent("cover.webp") }
    public var avatar: URL { folder.appendingPathComponent("avatar.webp") }
}

public enum FeaturedCharacters {
    /// the folder holding every featured character, LICENSE.md and CREDITS.md
    public static var root: URL? { Bundle.module.url(forResource: "Characters", withExtension: nil) }

    public static var all: [FeaturedCharacter] {
        guard let root, let data = try? Data(contentsOf: root.appendingPathComponent("index.json")),
              let list = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else { return [] }
        return list.compactMap { e in
            guard let id = e["id"] as? String, let name = e["name"] as? String else { return nil }
            let folder = root.appendingPathComponent(id, isDirectory: true)
            guard FileManager.default.fileExists(atPath: folder.appendingPathComponent("model.json").path) else { return nil }
            return FeaturedCharacter(id: id, name: name, credit: e["credit"] as? String, folder: folder)
        }
    }

    /// characters/LICENSE.md: the featured characters' licence
    public static var licenseText: String {
        root.flatMap { try? String(contentsOf: $0.appendingPathComponent("LICENSE.md"), encoding: .utf8) } ?? ""
    }

    /// characters/CREDITS.md: the sources and credits of Kujira, Kujira Q and Pen
    public static var creditsText: String {
        root.flatMap { try? String(contentsOf: $0.appendingPathComponent("CREDITS.md"), encoding: .utf8) } ?? ""
    }
}
