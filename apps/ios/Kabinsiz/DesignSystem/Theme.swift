import SwiftUI

/// Migration adapter (ADR-009, C-14). The old v1.5 token names stay so existing screens keep compiling,
/// but each now resolves to its Quiet Atelier role (`LegacyTokenMigration`). Redesigned screens use
/// `Atelier` directly; a name is removed once nothing uses it.
enum Token {
    static let surfaceBase = Atelier.canvas
    static let surfaceCard = Atelier.surface
    static let textPrimary = Atelier.ink
    static let textSecondary = Atelier.inkSecondary
    static let brandInk = Atelier.brand
    static let accentWarm = Atelier.sand
    static let borderHairline = Atelier.borderSoft
    static let statusOK = Atelier.success
    static let statusCaution = Atelier.warning
    static let statusError = Atelier.danger

    enum Radius {
        static let small = Atelier.Radius.small
        static let card = Atelier.Radius.card
        static let preview = Atelier.Radius.hero
    }

    enum Space {
        static let gutter = Atelier.Space.gutter
        static let card = Atelier.Space.cardPadding
        static let tight = Atelier.Space.xs
    }
}

/// Status is never colour-only (§4.3): every badge has an icon and text.
enum StatusTone {
    case ok, caution, error, neutral

    var color: Color {
        switch self {
        case .ok: Atelier.success
        case .caution: Atelier.warning
        case .error: Atelier.danger
        case .neutral: Atelier.inkSecondary
        }
    }

    var symbol: String {
        switch self {
        case .ok: "checkmark.circle"
        case .caution: "exclamationmark.triangle"
        case .error: "xmark.octagon"
        case .neutral: "info.circle"
        }
    }
}
