import Foundation

/// Text from outside the user's own hands: catalog names, scanned codes, partner descriptions.
/// It can only be displayed. There is no API that turns it into a capability, a module call, a URL or
/// an egress intent, so instructions inside it stay data (V15-T-SEC-04).
public struct UntrustedText: Hashable, Sendable, CustomStringConvertible {
    public static let maxLength = 200

    /// Safe to show: control, bidi-override and zero-width characters removed, whitespace collapsed,
    /// length capped. Render with `Text(verbatim:)` so nothing is read as Markdown.
    public let displayValue: String

    public init(_ raw: String) {
        let kept = raw.unicodeScalars.filter { !Self.isHidden($0) }
        let collapsed = String(String.UnicodeScalarView(kept))
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        displayValue = collapsed.count > Self.maxLength ? String(collapsed.prefix(Self.maxLength)) + "…" : collapsed
    }

    public var description: String { displayValue }

    /// Characters that can hide or reorder what the user sees (Trojan Source style) or carry no glyph.
    static func isHidden(_ s: Unicode.Scalar) -> Bool {
        switch s.properties.generalCategory {
        case .control, .format, .privateUse, .unassigned, .surrogate: return !(s == "\n" || s == "\t")
        default: return false
        }
    }
}

/// Personal attributes the product must never infer or store about anyone (§61, §112): religion,
/// ethnicity, health, sexuality, politics. Checked on key names of anything about to be persisted, so
/// "inferred religion" in travel metadata is rejected by schema, not by review (V15-T-SEC-09).
public enum SensitiveAttributeGuard {
    /// Short words match only as whole tokens (`race` must not hit `trace_id`).
    static let forbiddenTokens: Set<String> = ["race", "racial", "faith"]
    /// Longer stems also match inside run-together keys (`HEALTHSCORE`, `religion2`, `inferredethnicity`).
    /// This over-blocks a few harmless names (`healthyDrinks`); for a privacy guard that is the right side to err on.
    static let forbiddenStems: [String] = [
        "religio", "denomination", "ethnic", "sexual", "politic",
        "health", "medical", "diagnos", "disabil", "pregnan", "biometric",
    ]

    /// Every offending key path in a JSON document. Empty means clean. Unparseable input counts as a violation.
    public static func violations(inJSON data: Data) -> [String] {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed]) else { return ["$"] }
        var found: [String] = []
        walk(object, path: "$", into: &found)
        return found
    }

    public static func isForbidden(key: String) -> Bool {
        let parts = tokens(of: key)
        if !parts.isDisjoint(with: forbiddenTokens) { return true }
        let letters = key.lowercased(with: Locale(identifier: "en_US_POSIX")).filter(\.isLetter)
        return forbiddenStems.contains { letters.contains($0) }
    }

    /// `inferredReligion`, `inferred_religion`, `INFERRED-RELIGION`, `race2` → ["inferred", "religion"], ["race", "2"].
    static func tokens(of key: String) -> Set<String> {
        var parts: [String] = []
        var current = ""
        var previousWasLower = false
        for ch in key {
            if !(ch.isLetter || ch.isNumber) {
                if !current.isEmpty { parts.append(current); current = "" }
                previousWasLower = false
                continue
            }
            let boundary = (ch.isUppercase && previousWasLower)
                || (ch.isNumber != (current.last?.isNumber ?? ch.isNumber))
            if boundary && !current.isEmpty { parts.append(current); current = "" }
            current.append(ch)
            previousWasLower = ch.isLowercase
        }
        if !current.isEmpty { parts.append(current) }
        return Set(parts.map { $0.lowercased(with: Locale(identifier: "en_US_POSIX")) })
    }

    private static func walk(_ value: Any, path: String, into found: inout [String]) {
        if let dict = value as? [String: Any] {
            for key in dict.keys.sorted() {
                let child = "\(path).\(key)"
                if isForbidden(key: key) { found.append(child) }
                walk(dict[key]!, path: child, into: &found)
            }
        } else if let array = value as? [Any] {
            for (i, element) in array.enumerated() { walk(element, path: "\(path)[\(i)]", into: &found) }
        }
    }
}
