import Foundation

/// What went wrong, to tell apart in code (errors.ts). The message is for people and is localized where the app shows it
public struct LivLivError: Error, LocalizedError, CustomStringConvertible, Sendable {
    public enum Code: String, Sendable {
        case noMetal = "no-metal"
        case unreachable
        case notAModel = "not-a-model"
        case invalid
        case tooLarge = "too-large"
        case newerFormat = "newer-format"
        case missingFeature = "missing-feature"
        case missingFile = "missing-file"
        case permission
    }
    public let code: Code
    public let message: String
    public init(_ code: Code, _ message: String) { self.code = code; self.message = message }
    public var errorDescription: String? { message }
    public var description: String { "[\(code.rawValue)] \(message)" }
}
