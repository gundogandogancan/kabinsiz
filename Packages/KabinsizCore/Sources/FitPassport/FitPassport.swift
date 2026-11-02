import DomainContracts
import Foundation

public enum FitOutcome: String, Codable, CaseIterable, Sendable {
    case fits, tight, loose, notTried

    public var displayName: String {
        switch self {
        case .fits: "Tam oldu"
        case .tight: "Dar"
        case .loose: "Bol"
        case .notTried: "Denemedim"
        }
    }
}

public enum FitRegion: String, Codable, CaseIterable, Sendable {
    case shoulder, chest, waist, hip, length, sleeve, thigh

    public var displayName: String {
        switch self {
        case .shoulder: "Omuz"
        case .chest: "Göğüs"
        case .waist: "Bel"
        case .hip: "Kalça"
        case .length: "Boy"
        case .sleeve: "Kol"
        case .thigh: "Bacak"
        }
    }
}

public enum ObservationOrigin: String, Codable, Sendable { case manuallyConfirmed, importedWithConsent }

/// One real try-on result the user chose to record (§61.4). Device-local only.
public struct FitObservation: Codable, Hashable, Identifiable, Sendable {
    public let id: UUID
    public var garmentCategory: GarmentCategory
    public var brandID: String?
    public var productVariantID: String?
    /// Model shared by colour variants. Catalog revisions are only comparable within one model.
    public var productModelID: String?
    public var catalogRevision: Int?
    public var markedSize: String?
    public var observedOutcome: FitOutcome
    public var affectedRegions: Set<FitRegion>
    public var observationDate: Date
    public var origin: ObservationOrigin
    public var fitPreferenceRevision: Int

    public init(
        id: UUID = UUID(), garmentCategory: GarmentCategory, brandID: String?, productVariantID: String? = nil,
        productModelID: String? = nil, catalogRevision: Int? = nil, markedSize: String?, observedOutcome: FitOutcome, affectedRegions: Set<FitRegion> = [],
        observationDate: Date = Date(), origin: ObservationOrigin = .manuallyConfirmed, fitPreferenceRevision: Int = 1
    ) {
        self.id = id
        self.garmentCategory = garmentCategory
        self.brandID = brandID
        self.productVariantID = productVariantID
        self.productModelID = productModelID
        self.catalogRevision = catalogRevision
        self.markedSize = markedSize
        self.observedOutcome = observedOutcome
        self.affectedRegions = affectedRegions
        self.observationDate = observationDate
        self.origin = origin
        self.fitPreferenceRevision = fitPreferenceRevision
    }
}

/// Comfort preferences, not body norms (§61.1). All optional and user-stated.
public struct FitPreferences: Codable, Hashable, Sendable {
    public var prefersRelaxedFit: Bool?
    public var dislikesTightShoulders: Bool?
    public var wantsStretch: Bool?

    public init(prefersRelaxedFit: Bool? = nil, dislikesTightShoulders: Bool? = nil, wantsStretch: Bool? = nil) {
        self.prefersRelaxedFit = prefersRelaxedFit
        self.dislikesTightShoulders = dislikesTightShoulders
        self.wantsStretch = wantsStretch
    }
}

/// The whole passport. Value type; persisted by the app through `LocalStore`.
public struct FitPassport: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public private(set) var observations: [FitObservation]
    public var preferences: FitPreferences
    /// "Bu bilgiyi sonraki önerilerimde kullan" (§61.2). Off → advice ignores observations entirely.
    public var learningEnabled: Bool
    /// Brands the user told us not to apply learning to ("Bu markaya uygulama", §61.3).
    public var excludedBrandIDs: Set<String>

    public init(observations: [FitObservation] = [], preferences: FitPreferences = .init(), learningEnabled: Bool = true, excludedBrandIDs: Set<String> = []) {
        self.observations = observations
        self.preferences = preferences
        self.learningEnabled = learningEnabled
        self.excludedBrandIDs = excludedBrandIDs
    }

    public mutating func record(_ observation: FitObservation) {
        observations.removeAll { $0.id == observation.id }
        observations.append(observation)
        observations.sort { $0.observationDate < $1.observationDate }
    }

    /// Editing replaces the record; advice is recomputed from scratch, so the old inference disappears (T-V13-016).
    public mutating func update(_ observation: FitObservation) { record(observation) }

    public mutating func delete(id: UUID) { observations.removeAll { $0.id == id } }

    /// Separate from wardrobe and travel deletion (T-V13-017).
    public mutating func reset() {
        observations = []
        preferences = .init()
        excludedBrandIDs = []
    }
}
