import DesignTokens
import SwiftUI
import UIKit

/// SwiftUI face of the `DesignTokens` module (ADR-009). Every colour resolves at render time from the
/// trait collection: light/dark and Increase Contrast. Screens use these names, never a hex value.
enum Atelier {
    static let canvas = color(.canvas)
    static let surface = color(.surfacePrimary)
    static let surfaceSecondary = color(.surfaceSecondary)
    static let sand = color(.surfaceSand)
    static let borderSoft = color(.borderSoft)
    static let borderControl = color(.borderControl)
    static let ink = color(.textPrimary)
    static let inkSecondary = color(.textSecondary)
    static let brand = color(.brandPrimary)
    static let olive = color(.brandSecondary)
    static let copper = color(.accentCopper)
    static let avatar = color(.avatarNeutral)
    static let success = color(.statusSuccess)
    static let warning = color(.statusWarning)
    static let danger = color(.statusDanger)
    static let onBrand = color(.onBrand)

    static func uiColor(_ role: ColorRole) -> UIColor {
        UIColor { traits in
            let rgb = AtelierPalette.color(role, AtelierAppearance(
                dark: traits.userInterfaceStyle == .dark,
                increasedContrast: traits.accessibilityContrast == .high
            ))
            return UIColor(red: CGFloat(rgb.red) / 255, green: CGFloat(rgb.green) / 255, blue: CGFloat(rgb.blue) / 255, alpha: 1)
        }
    }

    private static func color(_ role: ColorRole) -> Color { Color(uiColor: uiColor(role)) }

    /// §05 spacing (4 pt grid).
    enum Space {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let gutter = CGFloat(AtelierMetrics.gutter)
        static let cardPadding = CGFloat(AtelierMetrics.cardPadding)
    }

    enum Radius {
        static let small = CGFloat(AtelierMetrics.Radius.small)
        static let chip = CGFloat(AtelierMetrics.Radius.chip)
        static let card = CGFloat(AtelierMetrics.Radius.card)
        static let hero = CGFloat(AtelierMetrics.Radius.hero)
    }

    static let minTap = CGFloat(AtelierMetrics.minTapTarget)

    /// §05 motion. Callers pass `reduceMotion`; with it on there is no animation at all.
    enum Motion {
        static func micro(reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : .easeOut(duration: AtelierMetrics.microMotion.upperBound)
        }

        static func state(reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : .smooth(duration: AtelierMetrics.stateMotion.lowerBound + 0.06)
        }
    }
}
