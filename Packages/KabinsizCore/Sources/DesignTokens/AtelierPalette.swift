import Foundation

/// v2.0 "Quiet Atelier" design tokens (constitution v2.0 §03–§05, ADR-009). Pure data, no UI framework,
/// so every colour pair the app may draw can be contrast-checked on macOS. The app reads colours,
/// spacing and radii only from here (through `AtelierTokens.swift`); screens never carry their own hex.

/// One sRGB colour.
public struct RGB: Hashable, Sendable, CustomStringConvertible {
    public let red: UInt8, green: UInt8, blue: UInt8

    public init(_ hex: UInt32) {
        red = UInt8((hex >> 16) & 0xFF)
        green = UInt8((hex >> 8) & 0xFF)
        blue = UInt8(hex & 0xFF)
    }

    public var hex: UInt32 { UInt32(red) << 16 | UInt32(green) << 8 | UInt32(blue) }
    public var description: String { "#" + String(hex, radix: 16, uppercase: true).leftPadded(to: 6) }

    /// WCAG 2.x relative luminance.
    public var relativeLuminance: Double {
        func channel(_ v: UInt8) -> Double {
            let c = Double(v) / 255
            return c <= 0.04045 ? c / 12.92 : Foundation.pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }

    /// WCAG contrast ratio, 1…21, symmetric.
    public func contrast(with other: RGB) -> Double {
        let (a, b) = (relativeLuminance, other.relativeLuminance)
        return (max(a, b) + 0.05) / (min(a, b) + 0.05)
    }
}

/// The appearance the system asks for: light or dark, with or without Increase Contrast.
public enum AtelierAppearance: String, CaseIterable, Sendable {
    case light, dark, lightIncreasedContrast, darkIncreasedContrast

    public init(dark: Bool, increasedContrast: Bool) {
        switch (dark, increasedContrast) {
        case (false, false): self = .light
        case (true, false): self = .dark
        case (false, true): self = .lightIncreasedContrast
        case (true, true): self = .darkIncreasedContrast
        }
    }

    public var isIncreasedContrast: Bool { self == .lightIncreasedContrast || self == .darkIncreasedContrast }
}

/// Semantic colour roles. Raw values are the v2.0 §03 token names.
public enum ColorRole: String, CaseIterable, Sendable {
    case canvas = "canvas.primary"
    case surfacePrimary = "surface.primary"
    case surfaceSecondary = "surface.secondary"
    case surfaceSand = "surface.sand"
    /// Decorative 1 px separators. Not a control boundary (that is `borderControl`).
    case borderSoft = "border.soft"
    /// Outline that identifies a control (text field, stepper); meets the 3:1 non-text rule.
    case borderControl = "border.control"
    case textPrimary = "text.primary"
    case textSecondary = "text.secondary"
    case brandPrimary = "brand.primary"
    case brandSecondary = "brand.secondary"
    case accentCopper = "accent.copper"
    /// Graphite mannequin. Shaded in 3D, so it is not held to a flat contrast rule.
    case avatarNeutral = "avatar.neutral"
    case statusSuccess = "status.success"
    case statusWarning = "status.warning"
    case statusDanger = "status.danger"
    /// Label drawn on a `brandPrimary` fill. Dark mode's brand is light, so this flips.
    case onBrand = "on.brand"
}

public enum AtelierPalette {
    public static func color(_ role: ColorRole, _ appearance: AtelierAppearance) -> RGB {
        RGB(table[appearance]![role]!)
    }

    // Light "Fildişi" and dark "Espresso" follow the brand board (2026-11-03: Fildişi #F7F1E7, Taş #D6C4B3,
    // Zeytin #7A8461, Bakır #B3714E, Espresso #2B1E18), deepened where text sits on them so every pair
    // still meets AA. Earlier values were the §03.1/§03.2 "Atelier Linen" / "After Hours". Roles §03 leaves open
    // (dark sand/avatar/status, on-brand, control border) and every Increase Contrast value are ADR-009 choices,
    // checked by `AtelierContrastRules`.
    private static let light: [ColorRole: UInt32] = [
        .canvas: 0xF7F1E7, .surfacePrimary: 0xFFFBF4, .surfaceSecondary: 0xF1E8DA, .surfaceSand: 0xE6D8C6,
        .borderSoft: 0xDCCDBB, .borderControl: 0x8C7A6A, .textPrimary: 0x2B1E18, .textSecondary: 0x5E4E43,
        .brandPrimary: 0x93562F, .brandSecondary: 0x5D6845, .accentCopper: 0x9A5D3C, .avatarNeutral: 0xA8A49F,
        .statusSuccess: 0x35694B, .statusWarning: 0x825A1C, .statusDanger: 0x9E3B3D, .onBrand: 0xFFFBF4,
    ]
    private static let dark: [ColorRole: UInt32] = [
        .canvas: 0x1B1410, .surfacePrimary: 0x2B1E18, .surfaceSecondary: 0x35271F, .surfaceSand: 0x3F2F26,
        .borderSoft: 0x524036, .borderControl: 0x948272, .textPrimary: 0xF7F1E7, .textSecondary: 0xCDBDAE,
        .brandPrimary: 0xD8A07A, .brandSecondary: 0xB3BB97, .accentCopper: 0xDDA585, .avatarNeutral: 0x8E8A85,
        .statusSuccess: 0x8CC7A1, .statusWarning: 0xE0B36A, .statusDanger: 0xEE9A9C, .onBrand: 0x1B1410,
    ]
    private static let lightIncreased = light.merging([
        .textPrimary: 0x1F1511, .textSecondary: 0x46392F, .borderSoft: 0xA0968A, .borderControl: 0x6E655B,
        .brandPrimary: 0x6A3A1E, .brandSecondary: 0x434D30, .accentCopper: 0x6E3F2B,
        .statusSuccess: 0x285239, .statusWarning: 0x6A4914, .statusDanger: 0x832E30,
    ]) { $1 }
    private static let darkIncreased = dark.merging([
        .textPrimary: 0xFBF7F1, .textSecondary: 0xE4D8CB, .borderSoft: 0x6A6156, .borderControl: 0xA89D90,
        .brandPrimary: 0xEEC9A8, .brandSecondary: 0xCDD3B6, .accentCopper: 0xF0C8B0,
        .statusSuccess: 0xA6DDB9, .statusWarning: 0xF0C985, .statusDanger: 0xF5B5B6,
    ]) { $1 }

    private static let table: [AtelierAppearance: [ColorRole: UInt32]] = [
        .light: light, .dark: dark, .lightIncreasedContrast: lightIncreased, .darkIncreasedContrast: darkIncreased,
    ]
}

/// Which colour may be drawn on which, and how much contrast that needs (WCAG 2.2 1.4.3 / 1.4.6 / 1.4.11).
/// A pair not listed here is not an allowed combination.
public struct ContrastRule: Hashable, Sendable {
    public enum Kind: String, Sendable {
        /// Any size of text: 4.5:1, and 7:1 (AAA) under Increase Contrast.
        case text
        /// Control boundaries and fills that carry meaning: 3:1, and 4.5:1 under Increase Contrast.
        case nonText
    }

    public let foreground: ColorRole
    public let background: ColorRole
    public let kind: Kind

    public func minimum(for appearance: AtelierAppearance) -> Double {
        switch (kind, appearance.isIncreasedContrast) {
        case (.text, false): 4.5
        case (.text, true): 7
        case (.nonText, false): 3
        case (.nonText, true): 4.5
        }
    }

    public func ratio(_ appearance: AtelierAppearance) -> Double {
        AtelierPalette.color(foreground, appearance).contrast(with: AtelierPalette.color(background, appearance))
    }
}

public enum AtelierContrastRules {
    public static let all: [ContrastRule] = {
        var rules: [ContrastRule] = []
        func text(_ fg: ColorRole, on bgs: [ColorRole]) { rules += bgs.map { ContrastRule(foreground: fg, background: $0, kind: .text) } }
        func nonText(_ fg: ColorRole, on bgs: [ColorRole]) { rules += bgs.map { ContrastRule(foreground: fg, background: $0, kind: .nonText) } }
        text(.textPrimary, on: [.canvas, .surfacePrimary, .surfaceSecondary, .surfaceSand])
        text(.textSecondary, on: [.canvas, .surfacePrimary, .surfaceSecondary])
        text(.brandPrimary, on: [.canvas, .surfacePrimary])
        text(.onBrand, on: [.brandPrimary])
        text(.accentCopper, on: [.canvas, .surfacePrimary])
        text(.brandSecondary, on: [.canvas])
        for status in [ColorRole.statusSuccess, .statusWarning, .statusDanger] { text(status, on: [.canvas, .surfacePrimary]) }
        nonText(.borderControl, on: [.canvas, .surfacePrimary])
        nonText(.brandPrimary, on: [.canvas, .surfacePrimary])
        return rules
    }()

    /// Roles that are never text and never a meaningful boundary, so no rule applies to them.
    public static let decorativeOnly: Set<ColorRole> = [.borderSoft, .avatarNeutral]
}

/// §05 geometry and motion. Spacing is a 4 pt grid.
public enum AtelierMetrics {
    public static let spacingScale: [Double] = [4, 8, 12, 16, 20, 24, 32, 40]
    public static let gutter: Double = 20
    public static let cardPadding: Double = 16
    public static let minTapTarget: Double = 44
    public enum Radius {
        public static let small: Double = 8
        public static let chip: Double = 14
        public static let card: Double = 20
        public static let hero: Double = 24
    }
    /// Seconds. Micro interactions 160–220 ms, state changes 240–360 ms; none under Reduce Motion.
    public static let microMotion: ClosedRange<Double> = 0.16...0.22
    public static let stateMotion: ClosedRange<Double> = 0.24...0.36
}

/// Old `Theme.swift` token → v2.0 role (C-14). Screens keep the old names through the adapter until
/// they are redesigned; the colour they get is already the new one.
public enum LegacyTokenMigration {
    public struct Entry: Hashable, Sendable {
        public let legacyName: String
        public let legacyLight: RGB
        public let legacyDark: RGB
        public let role: ColorRole
    }

    public static let entries: [Entry] = [
        Entry(legacyName: "surfaceBase", legacyLight: RGB(0xF7F7F5), legacyDark: RGB(0x111315), role: .canvas),
        Entry(legacyName: "surfaceCard", legacyLight: RGB(0xFFFFFF), legacyDark: RGB(0x1B1E20), role: .surfacePrimary),
        Entry(legacyName: "textPrimary", legacyLight: RGB(0x17191B), legacyDark: RGB(0xF5F6F6), role: .textPrimary),
        Entry(legacyName: "textSecondary", legacyLight: RGB(0x667078), legacyDark: RGB(0xACB4B8), role: .textSecondary),
        Entry(legacyName: "brandInk", legacyLight: RGB(0x283D46), legacyDark: RGB(0x8DAFBE), role: .brandPrimary),
        Entry(legacyName: "accentWarm", legacyLight: RGB(0xCEB79C), legacyDark: RGB(0xB69A7B), role: .surfaceSand),
        Entry(legacyName: "borderHairline", legacyLight: RGB(0xE7E8E5), legacyDark: RGB(0x303638), role: .borderSoft),
        Entry(legacyName: "statusOK", legacyLight: RGB(0x217354), legacyDark: RGB(0x83D3AE), role: .statusSuccess),
        Entry(legacyName: "statusCaution", legacyLight: RGB(0x946A23), legacyDark: RGB(0xE9C077), role: .statusWarning),
        Entry(legacyName: "statusError", legacyLight: RGB(0xA23738), legacyDark: RGB(0xF1A09E), role: .statusDanger),
    ]
}

/// The markdown contrast report kept in `docs/design/COLOR_CONTRAST_REPORT.md` (a golden: tests fail if it drifts).
public enum AtelierContrastReport {
    public static func markdown() -> String {
        var out = """
        # Renk kontrast raporu (UI20-WP02, ADR-009)

        Üretildi: `DesignTokensTests` (`REGENERATE_DESIGN_REPORT=1 swift test --filter DesignTokensTests`). \
        Elle düzenlemeyin; test bu dosyayı koddan yeniden üretip karşılaştırır.

        Hesap: WCAG 2.x göreli parlaklık, düz (opak) zemin. Saydamlık, fotoğraf üzeri metin ve \
        sistem malzemeleri (Liquid Glass) bu tabloya dahil değildir; bunlar cihazda ölçülür (UI20-T-003, cihaz BLOCKED).

        Eşikler: metin 4.5:1 (Increase Contrast'ta 7:1), metin dışı öğe 3:1 (Increase Contrast'ta 4.5:1).


        """
        for appearance in AtelierAppearance.allCases {
            out += "## \(appearance.rawValue)\n\n| Ön plan | Zemin | Tür | Oran | Eşik | Sonuç |\n|---|---|---|---:|---:|---|\n"
            for rule in AtelierContrastRules.all {
                let r = rule.ratio(appearance), min = rule.minimum(for: appearance)
                out += "| `\(rule.foreground.rawValue)` \(AtelierPalette.color(rule.foreground, appearance)) "
                    + "| `\(rule.background.rawValue)` \(AtelierPalette.color(rule.background, appearance)) "
                    + "| \(rule.kind.rawValue) | \(r.formatted2) | \(min.formatted2) | \(r >= min ? "PASS" : "FAIL") |\n"
            }
            out += "\n"
        }
        out += "## Eski → yeni token eşlemesi (C-14)\n\n| Eski ad | Eski açık | Eski koyu | Yeni rol | Yeni açık | Yeni koyu |\n|---|---|---|---|---|---|\n"
        for e in LegacyTokenMigration.entries {
            out += "| `\(e.legacyName)` | \(e.legacyLight) | \(e.legacyDark) | `\(e.role.rawValue)` "
                + "| \(AtelierPalette.color(e.role, .light)) | \(AtelierPalette.color(e.role, .dark)) |\n"
        }
        return out
    }
}

private extension Double {
    /// Two decimals, locale-free, rounded half up.
    var formatted2: String {
        let hundredths = Int((self * 100).rounded())
        let frac = hundredths % 100
        return "\(hundredths / 100).\(frac < 10 ? "0" : "")\(frac)"
    }
}

private extension String {
    func leftPadded(to n: Int) -> String { String(repeating: "0", count: max(0, n - count)) + self }
}

/// v2.8 Figma role names → code roles (ADR-011 Karar 4). The values stay the brand board's; Figma
/// variables are generated from this map once Figma can be written to (BLOCKED_EXTERNAL_FIGMA).
public enum FigmaTokenMap {
    public static let colorRoles: [String: ColorRole] = [
        "canvas": .canvas, "surface": .surfacePrimary, "sand": .surfaceSand, "stone": .borderSoft,
        "ink": .textPrimary, "secondaryInk": .textSecondary, "espresso": .brandPrimary, "olive": .brandSecondary,
        "copper": .accentCopper, "hairline": .borderSoft, "success": .statusSuccess, "warning": .statusWarning,
        "danger": .statusDanger,
    ]
    /// Scene scrim: not a palette role, a fixed dark used under text that sits on the 3D scene.
    public static let scrim = RGB(0x221913)
    /// Names that are not colour roles in code, with the reason.
    public static let unmapped: [String: String] = ["scrim": "fixed scene scrim, see FigmaTokenMap.scrim"]
}
