import SwiftUI
import UIKit

/// Design tokens from constitution §4.3. Light/dark pairs resolve at render time.
enum Token {
    static let surfaceBase = dynamic(0xF7F7F5, 0x111315)
    static let surfaceCard = dynamic(0xFFFFFF, 0x1B1E20)
    static let textPrimary = dynamic(0x17191B, 0xF5F6F6)
    static let textSecondary = dynamic(0x667078, 0xACB4B8)
    static let brandInk = dynamic(0x283D46, 0x8DAFBE)
    static let accentWarm = dynamic(0xCEB79C, 0xB69A7B)
    static let borderHairline = dynamic(0xE7E8E5, 0x303638)
    static let statusOK = dynamic(0x217354, 0x83D3AE)
    static let statusCaution = dynamic(0x946A23, 0xE9C077)
    static let statusError = dynamic(0xA23738, 0xF1A09E)

    enum Radius {
        static let small: CGFloat = 12
        static let card: CGFloat = 20
        static let preview: CGFloat = 24
    }

    enum Space {
        static let gutter: CGFloat = 20
        static let card: CGFloat = 16
        static let tight: CGFloat = 8
    }

    private static func dynamic(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}

/// Status is never colour-only (§4.3): every badge has an icon and text.
enum StatusTone {
    case ok, caution, error, neutral

    var color: Color {
        switch self {
        case .ok: Token.statusOK
        case .caution: Token.statusCaution
        case .error: Token.statusError
        case .neutral: Token.textSecondary
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
