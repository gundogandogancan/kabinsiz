import SwiftUI

/// v2.0 §04.2 type scale. Serif (system New York) only for short editorial headings; everything that
/// carries a number, an action or an explanation is SF Pro. All styles follow Dynamic Type.
enum AtelierType {
    static let display: Font = .system(.largeTitle, design: .serif, weight: .regular)
    static let screenTitle: Font = .system(.title, design: .serif, weight: .semibold)
    static let sectionTitle: Font = .system(.title2, design: .serif, weight: .medium)
    static let wordmark: Font = .system(.title, design: .serif, weight: .medium)
    static let cardTitle: Font = .headline
    static let body: Font = .body
    static let secondary: Font = .subheadline
    static let caption: Font = .footnote
    static let eyebrow: Font = .caption.weight(.medium)
    /// Sizes, prices, dates: tabular digits so columns line up.
    static let figure: Font = .body.monospacedDigit()
}

extension View {
    /// Text that may wrap to any number of lines at large Dynamic Type sizes instead of truncating.
    func atelierWrapping() -> some View { fixedSize(horizontal: false, vertical: true) }
}

/// "BUGÜN SENİN İÇİN": the only place text is upper-cased, and only for 1–3 words (§04.1.4).
/// Turkish locale so i → İ, never I.
struct Eyebrow: View {
    let text: String

    var body: some View {
        Text(text.uppercased(with: Locale(identifier: "tr_TR")))
            .font(AtelierType.eyebrow)
            .tracking(0.6)
            .foregroundStyle(Atelier.copper)
            .accessibilityLabel(text)
            .accessibilityAddTraits(.isHeader)
    }
}
