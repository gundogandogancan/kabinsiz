import SwiftUI

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { content }
            .padding(Token.Space.card)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Token.surfaceCard, in: RoundedRectangle(cornerRadius: Token.Radius.card, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: Token.Radius.card, style: .continuous).stroke(Token.borderHairline, lineWidth: 1))
            // One container element, so an identifier names the card instead of every child.
            .accessibilityElement(children: .contain)
    }
}

struct StatusBadge: View {
    let text: String
    var tone: StatusTone = .neutral

    var body: some View {
        Label(text, systemImage: tone.symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(tone.color)
            .labelStyle(.titleAndIcon)
            .accessibilityElement(children: .combine)
    }
}

/// Visible on every screen that shows fictional data (§56).
struct SyntheticBadge: View {
    var body: some View {
        Label("Örnek veri — gerçek değil", systemImage: "flask")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(Token.statusCaution)
            .background(Token.statusCaution.opacity(0.12), in: Capsule())
            .accessibilityLabel("Örnek veri, gerçek değil")
            .accessibilityIdentifier("syntheticBadge")
    }
}

struct Chip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(Token.textPrimary)
            .background(Token.surfaceBase, in: Capsule())
            .overlay(Capsule().stroke(Token.borderHairline))
    }
}

struct ToggleChip: View {
    let text: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(text, systemImage: isOn ? "checkmark" : "plus")
                .font(.subheadline)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .foregroundStyle(isOn ? Atelier.onBrand : Token.textPrimary)
                .background(isOn ? Token.brandInk : Token.surfaceCard, in: Capsule())
                .overlay(Capsule().stroke(isOn ? Color.clear : Token.borderHairline))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(Atelier.onBrand)
            .background(Atelier.brand.opacity(configuration.isPressed ? 0.85 : 1), in: RoundedRectangle(cornerRadius: Atelier.Radius.chip, style: .continuous))
    }
}

/// Simple flow layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(maxX, width), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowHeight + spacing; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct EmptyState: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: symbol).font(.largeTitle).foregroundStyle(Token.textSecondary).accessibilityHidden(true)
            Text(title).font(.headline).foregroundStyle(Token.textPrimary)
            Text(message).font(.subheadline).foregroundStyle(Token.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
    }
}
