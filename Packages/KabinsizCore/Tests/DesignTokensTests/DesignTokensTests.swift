@testable import DesignTokens
import Foundation
import Testing

@Suite("UI20-WP02 Quiet Atelier tokens")
struct DesignTokensTests {
    @Test("WCAG formula matches known reference values")
    func formula() {
        #expect(RGB(0x000000).contrast(with: RGB(0xFFFFFF)) == 21)
        #expect(RGB(0x777777).contrast(with: RGB(0x777777)) == 1)
        #expect(abs(RGB(0x767676).contrast(with: RGB(0xFFFFFF)) - 4.54) < 0.01, "#767676 on white is the classic 4.54:1")
        #expect(RGB(0x123456).contrast(with: RGB(0xABCDEF)) == RGB(0xABCDEF).contrast(with: RGB(0x123456)))
        #expect(RGB(0x0A0B0C).description == "#0A0B0C")
    }

    @Test("v2.0 §03.1 and §03.2 values are used exactly, and §03.1's stated ratios hold")
    func specValues() {
        let light: [(ColorRole, UInt32)] = [(.canvas, 0xF8F6F1), (.surfacePrimary, 0xFFFCF8), (.surfaceSecondary, 0xF0EAE2), (.surfaceSand, 0xE8DED1),
                                            (.borderSoft, 0xD9D0C4), (.textPrimary, 0x26221E), (.textSecondary, 0x5C544C), (.brandPrimary, 0x654632),
                                            (.brandSecondary, 0x62684B), (.accentCopper, 0x9C6048), (.avatarNeutral, 0xA8A49F),
                                            (.statusSuccess, 0x35694B), (.statusWarning, 0x825A1C), (.statusDanger, 0x9E3B3D)]
        for (role, hex) in light { #expect(AtelierPalette.color(role, .light) == RGB(hex), "\(role)") }
        let dark: [(ColorRole, UInt32)] = [(.canvas, 0x151411), (.surfacePrimary, 0x201D19), (.surfaceSecondary, 0x2A251F), (.borderSoft, 0x494238),
                                           (.textPrimary, 0xF6F0E7), (.textSecondary, 0xC4B9AC), (.brandPrimary, 0xC99D7A),
                                           (.brandSecondary, 0xADB598), (.accentCopper, 0xD4A18B)]
        for (role, hex) in dark { #expect(AtelierPalette.color(role, .dark) == RGB(hex), "\(role)") }
        let canvas = AtelierPalette.color(.canvas, .light)
        #expect(abs(AtelierPalette.color(.brandPrimary, .light).contrast(with: canvas) - 7.85) < 0.01)
        #expect(abs(AtelierPalette.color(.textSecondary, .light).contrast(with: canvas) - 6.88) < 0.01)
        #expect(abs(AtelierPalette.color(.accentCopper, .light).contrast(with: canvas) - 4.65) < 0.01)
    }

    @Test("UI20-T-003: every allowed pair passes in light, dark and both Increase Contrast variants")
    func everyPairPasses() {
        for appearance in AtelierAppearance.allCases {
            for rule in AtelierContrastRules.all {
                #expect(rule.ratio(appearance) >= rule.minimum(for: appearance),
                        "\(appearance) \(rule.foreground.rawValue) on \(rule.background.rawValue): \(rule.ratio(appearance))")
            }
        }
    }

    @Test("Every role is either covered by a rule or declared decorative; old cold blue-grey brand is gone")
    func coverage() {
        let used = Set(AtelierContrastRules.all.flatMap { [$0.foreground, $0.background] })
        for role in ColorRole.allCases {
            #expect(used.contains(role) != AtelierContrastRules.decorativeOnly.contains(role), "\(role) must be exactly one of: ruled, decorative")
        }
        for appearance in AtelierAppearance.allCases {
            for role in ColorRole.allCases { #expect(AtelierPalette.color(role, appearance) != RGB(0x283D46)) }
        }
    }

    @Test("Increase Contrast never lowers contrast against the canvas, and dark mode's CTA label flips to dark")
    func increasedContrastIsStronger() {
        for (base, increased) in [(AtelierAppearance.light, AtelierAppearance.lightIncreasedContrast), (.dark, .darkIncreasedContrast)] {
            for rule in AtelierContrastRules.all {
                #expect(rule.ratio(increased) >= rule.ratio(base) - 0.0001, "\(rule.foreground.rawValue) on \(rule.background.rawValue)")
            }
        }
        #expect(AtelierPalette.color(.onBrand, .dark).relativeLuminance < 0.05)
        #expect(AtelierPalette.color(.onBrand, .light).relativeLuminance > 0.9)
        #expect(AtelierAppearance(dark: true, increasedContrast: true) == .darkIncreasedContrast)
        #expect(AtelierAppearance(dark: false, increasedContrast: false) == .light)
    }

    @Test("C-14: every old Theme token has exactly one new role")
    func migrationMap() {
        let names = LegacyTokenMigration.entries.map(\.legacyName)
        #expect(Set(names).count == names.count)
        #expect(Set(names) == ["surfaceBase", "surfaceCard", "textPrimary", "textSecondary", "brandInk", "accentWarm",
                               "borderHairline", "statusOK", "statusCaution", "statusError"])
        #expect(LegacyTokenMigration.entries.first { $0.legacyName == "brandInk" }?.legacyLight == RGB(0x283D46))
    }

    @Test("§05 geometry: 4 pt grid, 44 pt targets, radii 8/14/20/24")
    func metrics() {
        #expect(AtelierMetrics.spacingScale.allSatisfy { $0.truncatingRemainder(dividingBy: 4) == 0 })
        #expect(AtelierMetrics.minTapTarget >= 44)
        #expect([AtelierMetrics.Radius.small, AtelierMetrics.Radius.chip, AtelierMetrics.Radius.card, AtelierMetrics.Radius.hero] == [8, 14, 20, 24])
        #expect(AtelierMetrics.microMotion.upperBound < AtelierMetrics.stateMotion.lowerBound)
    }

    @Test("docs/design/COLOR_CONTRAST_REPORT.md is exactly what the tokens produce")
    func reportGolden() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appendingPathComponent("docs/design/COLOR_CONTRAST_REPORT.md")
        let report = AtelierContrastReport.markdown()
        if ProcessInfo.processInfo.environment["REGENERATE_DESIGN_REPORT"] == "1" {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try report.write(to: url, atomically: true, encoding: .utf8)
        }
        #expect(try String(contentsOf: url, encoding: .utf8) == report)
        #expect(!report.contains("FAIL"))
    }
}
