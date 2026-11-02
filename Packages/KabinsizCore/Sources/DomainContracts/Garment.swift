import Foundation

/// Packing-list category (§45.3). Also the canonical wardrobe category.
public enum GarmentCategory: String, Codable, CaseIterable, Sendable, Comparable {
    case top, bottom, dress, outerwear, shoes, underlayer, sleepwear, activewear, swimwear, accessory, weatherProtection

    public static func < (lhs: Self, rhs: Self) -> Bool {
        allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)!
    }

    public var displayName: String {
        switch self {
        case .top: "Üstler"
        case .bottom: "Altlar"
        case .dress: "Elbise / takım"
        case .outerwear: "Dış giyim"
        case .shoes: "Ayakkabı"
        case .underlayer: "İç çamaşırı ve çorap"
        case .sleepwear: "Pijama"
        case .activewear: "Spor giyim"
        case .swimwear: "Mayo"
        case .accessory: "Aksesuar"
        case .weatherProtection: "Hava koruması"
        }
    }
}

/// Formality is an ordered scale; a garment covers its own level and one step around it.
public enum Formality: Int, Codable, CaseIterable, Sendable, Comparable {
    case relaxed = 0, casual = 1, smart = 2, formal = 3

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    public var displayName: String {
        switch self {
        case .relaxed: "Rahat"
        case .casual: "Günlük"
        case .smart: "Şık"
        case .formal: "Resmi"
        }
    }
}

/// Wardrobe condition (§6.4, §45.3). `unknown` is the default; never assume `clean`.
public enum ItemCondition: String, Codable, CaseIterable, Sendable {
    case clean = "CLEAN", worn = "WORN", inLaundry = "IN_LAUNDRY", unavailable = "UNAVAILABLE", unknown = "UNKNOWN"

    /// Whether the planner may propose the item. `worn` is still wearable unless the user says otherwise (§45.4).
    public var isPlannable: Bool { self != .inLaundry && self != .unavailable }

    public var displayName: String {
        switch self {
        case .clean: "Temiz"
        case .worn: "Giyildi"
        case .inLaundry: "Yıkamada"
        case .unavailable: "Kullanılamaz"
        case .unknown: "Bilinmiyor"
        }
    }
}

/// Where a piece of data came from. Synthetic data must stay visibly labelled (§56).
public enum Provenance: String, Codable, Sendable {
    case userEntered = "USER_ENTERED"
    case syntheticDemo = "SYNTHETIC_DEMO_ONLY"
    case licensedCatalog = "LICENSED_CATALOG"
    case unknown = "UNKNOWN"

    public var isSynthetic: Bool { self == .syntheticDemo }
}

/// A material claim with its source. Missing claims stay absent, not "false" (§63.1).
public struct MaterialClaim: Codable, Hashable, Sendable {
    public enum Property: String, Codable, Sendable { case waterResistant, warm, breathable, stretch }
    public let property: Property
    public let source: Provenance

    public init(property: Property, source: Provenance) {
        self.property = property
        self.source = source
    }
}

public struct Garment: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public var name: String
    public var category: GarmentCategory
    /// Lowest and highest formality this piece is reasonable for.
    public var formalityRange: ClosedRange<Formality>
    public var colorName: String
    public var isNeutralColor: Bool
    public var condition: ItemCondition
    public var materialClaims: [MaterialClaim]
    /// Comfortable for long walks. `nil` = unknown, which the planner treats as "not proven".
    public var walkingComfort: Bool?
    /// Weight in kilograms only if the user weighed it. Never estimated silently (§45.1).
    public var weightKg: Double?
    public var brandID: String?
    public var markedSize: String?
    public var provenance: Provenance

    public init(
        id: String,
        name: String,
        category: GarmentCategory,
        formalityRange: ClosedRange<Formality>,
        colorName: String,
        isNeutralColor: Bool,
        condition: ItemCondition = .unknown,
        materialClaims: [MaterialClaim] = [],
        walkingComfort: Bool? = nil,
        weightKg: Double? = nil,
        brandID: String? = nil,
        markedSize: String? = nil,
        provenance: Provenance
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.formalityRange = formalityRange
        self.colorName = colorName
        self.isNeutralColor = isNeutralColor
        self.condition = condition
        self.materialClaims = materialClaims
        self.walkingComfort = walkingComfort
        self.weightKg = weightKg
        self.brandID = brandID
        self.markedSize = markedSize
        self.provenance = provenance
    }

    public func hasClaim(_ property: MaterialClaim.Property) -> Bool {
        materialClaims.contains { $0.property == property && $0.source != .unknown }
    }

    public func covers(_ formality: Formality) -> Bool { formalityRange.contains(formality) }
}
