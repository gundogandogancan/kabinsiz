import DomainContracts
import Foundation
import WardrobeDomain

/// "Do I need this?" (§66). Works only from the local wardrobe; nothing here leaves the device.
public enum WardrobeComparison: Hashable, Sendable {
    /// No wardrobe yet: we must not say "you don't own anything like it" (T-V13-008).
    case wardrobeNotAdded
    /// Same category and colour. Called "benzer", never "aynısı" (T-V13-045).
    case similarOwned([Garment])
    /// Same category, different colour or formality.
    case sameTypeOwned([Garment])
    /// Nothing of this type in the closet.
    case realGap
}

public struct ShoppingGuardResult: Hashable, Sendable {
    public let comparison: WardrobeComparison
    /// Owned pieces that form an outfit with the product.
    public let pairsWith: [Garment]

    public var headline: String {
        switch comparison {
        case .wardrobeNotAdded: "Dolabın eklenmedi"
        case .similarOwned(let g): g.count == 1 ? "Dolabında benzeri var: \(g[0].name)" : "Dolabında \(g.count) benzer parça var"
        case .sameTypeOwned(let g): "Bu türde \(g.count) parçan var, renk veya stil farklı"
        case .realGap: "Dolabında bu türde parça yok"
        }
    }
}

public enum ShoppingGuard {
    static let complementary: [GarmentCategory: [GarmentCategory]] = [
        .top: [.bottom, .shoes, .outerwear],
        .bottom: [.top, .shoes, .outerwear],
        .dress: [.shoes, .outerwear],
        .outerwear: [.top, .bottom, .dress],
        .shoes: [.bottom, .dress],
    ]

    public static func evaluate(
        category: GarmentCategory, colorName: String, formality: ClosedRange<Formality>, wardrobe: Wardrobe
    ) -> ShoppingGuardResult {
        guard !wardrobe.isEmpty else { return ShoppingGuardResult(comparison: .wardrobeNotAdded, pairsWith: []) }
        let owned = wardrobe.garments.filter { $0.category == category && $0.condition != .unavailable }
        let similar = owned.filter { $0.colorName.lowercased() == colorName.lowercased() && $0.formalityRange.overlaps(formality) }
        let comparison: WardrobeComparison
        if !similar.isEmpty { comparison = .similarOwned(similar) }
        else if !owned.isEmpty { comparison = .sameTypeOwned(owned) }
        else { comparison = .realGap }

        let partnerCategories = complementary[category] ?? []
        let pairs = wardrobe.garments
            .filter { partnerCategories.contains($0.category) && $0.formalityRange.overlaps(formality) && $0.condition.isPlannable }
            .sorted { ($0.isNeutralColor ? 0 : 1, $0.category, $0.id) < ($1.isNeutralColor ? 0 : 1, $1.category, $1.id) }
        return ShoppingGuardResult(comparison: comparison, pairsWith: Array(pairs.prefix(3)))
    }
}
