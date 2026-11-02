import DomainContracts
import FitPassport
import Foundation

/// A sellable variant. P0 data is fictional and says so (ADR-004). No stock or price fields exist on purpose.
public struct CatalogProduct: Codable, Hashable, Identifiable, Sendable {
    public var id: String { code }
    /// Exact variant code printed on the tag, e.g. `KB-JKT-01-NVY`.
    public let code: String
    /// Model code shared by colour variants, e.g. `KB-JKT-01`.
    public let modelCode: String
    public let brandID: String
    public let brandName: String
    public let name: String
    public let category: GarmentCategory
    public let colorName: String
    public let isNeutralColor: Bool
    public let formalityLow: Formality
    public let formalityHigh: Formality
    public let catalogRevision: Int
    public let sizeChart: SizeChart?
    public let materialClaims: [MaterialClaim]
    public let isSponsored: Bool
    public let provenance: Provenance

    public var formalityRange: ClosedRange<Formality> { formalityLow ... formalityHigh }
}

public enum ProductResolution: Hashable, Sendable {
    case found(CatalogProduct)
    /// Several variants share the code the user typed; the user must pick (T-V13-004).
    case ambiguous([CatalogProduct])
    /// Nothing matches. Never replaced by a "similar" product (T-V13-003).
    case notFound(normalizedCode: String)
    /// Input rejected before lookup (§64.2: too long, odd characters, embedded URLs).
    case invalidInput
}

/// Fail-closed resolver over a local catalog.
public struct ProductResolver: Sendable {
    public let products: [CatalogProduct]

    public init(products: [CatalogProduct]) {
        self.products = products.sorted { $0.code < $1.code }
    }

    /// The bundled synthetic catalog.
    public static func syntheticCatalog() throws -> ProductResolver {
        guard let url = Bundle.module.url(forResource: "SyntheticCatalog", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let products = try JSONDecoder().decode([CatalogProduct].self, from: Data(contentsOf: url))
        return ProductResolver(products: products)
    }

    public static let maxInputLength = 40

    public static func normalize(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty, trimmed.count <= maxInputLength else { return nil }
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
        guard trimmed.unicodeScalars.allSatisfy(allowed.contains) else { return nil }
        return trimmed
    }

    public func resolve(_ raw: String) -> ProductResolution {
        guard let code = Self.normalize(raw) else { return .invalidInput }
        if let exact = products.first(where: { $0.code == code }) { return .found(exact) }
        let variants = products.filter { $0.modelCode == code }
        switch variants.count {
        case 0: return .notFound(normalizedCode: code)
        case 1: return .found(variants[0])
        default: return .ambiguous(variants)
        }
    }
}
