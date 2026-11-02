import DomainContracts
import FitPassport
import Foundation
import WardrobeDomain

/// The one-screen "Denemeye değer mi?" card (§60.1). Three answers: look, size, wardrobe.
public struct ShoppingDecisionCard: Hashable, Sendable {
    public let product: CatalogProduct
    public let visualTier: VisualFidelityTier
    public let size: SizeAdvice
    public let wardrobe: ShoppingGuardResult
    /// At most three short, source-backed reasons.
    public let reasons: [String]
    public let missingInformation: [String]
    /// Shown as a label only. It never changes `size` or `wardrobe` (T-V13-009, T-V13-052).
    public let sponsoredLabel: String?
    public let isSyntheticData: Bool
}

public enum DecisionComposer {
    public static func compose(
        product: CatalogProduct,
        passport: FitPassport,
        measurements: UserMeasurements?,
        wardrobe: Wardrobe
    ) -> ShoppingDecisionCard {
        // Size and need are computed before sponsorship is even looked at.
        let size = SizeAdvisor.advice(
            passport: passport, brandID: product.brandID, category: product.category, productModelID: product.modelCode,
            catalogRevision: product.catalogRevision, chart: product.sizeChart, measurements: measurements
        )
        let guardResult = ShoppingGuard.evaluate(
            category: product.category, colorName: product.colorName, formality: product.formalityRange, wardrobe: wardrobe
        )

        var missing: [String] = []
        if product.sizeChart == nil { missing.append("Beden tablosu") }
        if product.materialClaims.isEmpty { missing.append("Kumaş bilgisi") }
        missing.append("Ürüne özel 3D görünüm")
        if wardrobe.isEmpty { missing.append("Dolap") }

        var reasons: [String] = [size.headline, guardResult.headline]
        if let pair = guardResult.pairsWith.first { reasons.append("Elindeki \(pair.name.lowercased()) ile eşleşir") }

        return ShoppingDecisionCard(
            product: product,
            visualTier: .flat2D,
            size: size,
            wardrobe: guardResult,
            reasons: Array(reasons.prefix(3)),
            missingInformation: missing,
            sponsoredLabel: product.isSponsored ? "Sponsorlu" : nil,
            isSyntheticData: product.provenance.isSynthetic
        )
    }
}
