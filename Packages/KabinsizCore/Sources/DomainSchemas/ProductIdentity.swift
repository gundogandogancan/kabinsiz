import Foundation
import SystemContracts

/// Which exact product a scan or a search landed on (v1.7 §4, §5.2). A size label alone ("M") never
/// identifies a product: brand, model, colour and market are always part of the identity.
public struct ProductIdentityV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum MatchKind: String, Codable, CaseIterable, Sendable {
        /// GTIN or retailer SKU matched a licensed source and the variant was verified.
        case exactVerified = "EXACT_VERIFIED"
        /// The user confirmed the variant themselves. True for them, never served as brand fact.
        case exactUserConfirmed = "EXACT_USER_CONFIRMED"
        /// A visual or text guess. A candidate to show, never a recognised product.
        case candidateOnly = "CANDIDATE_ONLY"
        case notFound = "NOT_FOUND"
        case ambiguous = "AMBIGUOUS"

        public var isExact: Bool { self == .exactVerified || self == .exactUserConfirmed }
    }

    /// What the source's licence lets the app do with this product's data.
    public enum LicensingRight: String, Codable, CaseIterable, Sendable {
        case displayFacts = "DISPLAY_FACTS"
        case displayMedia = "DISPLAY_MEDIA"
        case fitComputation = "FIT_COMPUTATION"
        case offlineCache = "OFFLINE_CACHE"
        case commerceLink = "COMMERCE_LINK"
    }

    /// V18-00.1 claim levels for identity alone.
    public enum IdentityLevel: String, Codable, Sendable {
        case none = "NONE"
        case brandIdentifiable = "BRAND_IDENTIFIABLE"
        case variantVerified = "VARIANT_VERIFIED"
    }

    public var schemaVersion: Int
    public var identityID: String
    /// Canonical GTIN-14 (`GTIN.normalized`), never a raw scan string.
    public var gtin: String?
    public var retailerSku: String?
    public var brandID: String
    public var brandProductCode: String
    public var modelID: String
    public var colorID: String
    public var sizeLabel: String
    public var season: String?
    public var patternRevision: String?
    public var market: String
    public var sourceRef: String
    public var matchKind: MatchKind
    public var verifiedAt: Date?
    public var expiresAt: Date?
    public var evidenceIDs: [String]
    public var licensingRights: [LicensingRight]
    public var catalogVersion: String

    public init(
        identityID: String, gtin: String?, retailerSku: String?, brandID: String, brandProductCode: String, modelID: String,
        colorID: String, sizeLabel: String, season: String? = nil, patternRevision: String? = nil, market: String,
        sourceRef: String, matchKind: MatchKind, verifiedAt: Date?, expiresAt: Date?, evidenceIDs: [String],
        licensingRights: [LicensingRight], catalogVersion: String
    ) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.gtin = gtin
        self.retailerSku = retailerSku
        self.brandID = brandID
        self.brandProductCode = brandProductCode
        self.modelID = modelID
        self.colorID = colorID
        self.sizeLabel = sizeLabel
        self.season = season
        self.patternRevision = patternRevision
        self.market = market
        self.sourceRef = sourceRef
        self.matchKind = matchKind
        self.verifiedAt = verifiedAt
        self.expiresAt = expiresAt
        self.evidenceIDs = evidenceIDs
        self.licensingRights = licensingRights
        self.catalogVersion = catalogVersion
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", gtin, retailerSku = "retailer_sku"
        case brandID = "brand_id", brandProductCode = "brand_product_code", modelID = "model_id", colorID = "color_id"
        case sizeLabel = "size_label", season, patternRevision = "pattern_revision", market, sourceRef = "source_ref"
        case matchKind = "match_kind", verifiedAt = "verified_at", expiresAt = "expires_at", evidenceIDs = "evidence_ids"
        case licensingRights = "licensing_rights", catalogVersion = "catalog_version"
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion)
        try require(allNonBlank([identityID, brandID, brandProductCode, modelID, colorID, sizeLabel, sourceRef, catalogVersion]))
        try require(isMarketCode(market))
        if let gtin { try require(GTIN.normalized(gtin) == gtin) }
        if let retailerSku { try require(!retailerSku.isBlank) }
        try require(allNonBlank(evidenceIDs) && allUnique(evidenceIDs) && allUnique(licensingRights))
        if let verifiedAt, let expiresAt { try require(expiresAt > verifiedAt) }
        if matchKind.isExact {
            // An exact match names the code it matched on, the evidence, and when it was checked.
            try require(gtin != nil || retailerSku != nil)
            try require(!evidenceIDs.isEmpty && verifiedAt != nil)
        } else {
            try require(verifiedAt == nil)
        }
        if matchKind == .exactVerified {
            // Verified-for-everyone needs the right to show the facts at all (§4 licence rule).
            try require(licensingRights.contains(.displayFacts))
        }
    }

    /// Verified and still in force: the only state that may be shown as a recognised exact variant.
    public func isVerified(at now: Date) -> Bool {
        guard matchKind == .exactVerified, licensingRights.contains(.displayFacts), let verifiedAt, now >= verifiedAt else { return false }
        if let expiresAt, now >= expiresAt { return false }
        return true
    }

    public func identityLevel(at now: Date) -> IdentityLevel {
        if isVerified(at: now) { return .variantVerified }
        switch matchKind {
        case .exactVerified, .exactUserConfirmed, .candidateOnly: return .brandIdentifiable
        case .notFound, .ambiguous: return .none
        }
    }
}

/// Garment regions shared by product specs and fit results (§5.3).
public enum GarmentRegion: String, Codable, CaseIterable, Sendable {
    case neck = "NECK", shoulder = "SHOULDER", chest = "CHEST", waist = "WAIST", hip = "HIP"
    case sleeve = "SLEEVE", totalLength = "TOTAL_LENGTH", rise = "RISE", thigh = "THIGH"
    case inseam = "INSEAM", legOpening = "LEG_OPENING"
}

/// Measured points of a product (§5.4). A body size chart (the people a size is meant for) and finished
/// garment measurements (the garment itself) are different evidence and never mixed in one spec.
public struct ProductPhysicalSpecV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum MeasurementType: String, Codable, CaseIterable, Sendable {
        case bodySizeChart = "BODY_SIZE_CHART"
        case finishedGarment = "FINISHED_GARMENT"
    }

    public enum Dimension: String, Codable, CaseIterable, Sendable {
        case circumference = "CIRCUMFERENCE"
        /// Laid flat, side to side (e.g. armpit to armpit). Half a circumference at best, never the same thing.
        case flatHalfWidth = "FLAT_HALF_WIDTH"
        case length = "LENGTH"
    }

    public enum Method: String, Codable, CaseIterable, Sendable {
        case flatLayTape = "FLAT_LAY_TAPE", onForm = "ON_FORM", cadPattern = "CAD_PATTERN"
        case brandDeclared = "BRAND_DECLARED", userTape = "USER_TAPE", unknown = "UNKNOWN"
    }

    public enum Cut: String, Codable, CaseIterable, Sendable {
        case slim = "SLIM", regular = "REGULAR", relaxed = "RELAXED", oversize = "OVERSIZE", unknown = "UNKNOWN"
    }

    public enum UnitSystem: String, Codable, CaseIterable, Sendable {
        /// The unit the source published in. Values here are always centimetres.
        case metric = "METRIC", imperial = "IMPERIAL"
    }

    public struct Point: Codable, Hashable, Sendable {
        public var size: String
        public var region: GarmentRegion
        public var dimension: Dimension
        public var cm: Double
        public var toleranceCm: Double?
        public var method: Method
        public var sourceEvidenceID: String
        public var revision: Int

        public init(size: String, region: GarmentRegion, dimension: Dimension, cm: Double, toleranceCm: Double? = nil,
                    method: Method, sourceEvidenceID: String, revision: Int) {
            self.size = size
            self.region = region
            self.dimension = dimension
            self.cm = cm
            self.toleranceCm = toleranceCm
            self.method = method
            self.sourceEvidenceID = sourceEvidenceID
            self.revision = revision
        }

        enum CodingKeys: String, CodingKey {
            case size, region, dimension, cm, toleranceCm = "tolerance_cm", method
            case sourceEvidenceID = "source_evidence_id", revision
        }
    }

    public var schemaVersion: Int
    public var identityID: String
    public var measurementType: MeasurementType
    public var pointsBySize: [Point]
    public var cut: Cut
    public var closure: String?
    public var lining: Bool?
    public var stretchTestRefs: [String]
    public var seamAllowanceKnown: Bool?
    public var unitSystem: UnitSystem
    public var sizeSystem: String
    public var revision: Int

    public init(identityID: String, measurementType: MeasurementType, pointsBySize: [Point], cut: Cut, closure: String? = nil,
                lining: Bool? = nil, stretchTestRefs: [String] = [], seamAllowanceKnown: Bool? = nil, unitSystem: UnitSystem,
                sizeSystem: String, revision: Int) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.measurementType = measurementType
        self.pointsBySize = pointsBySize
        self.cut = cut
        self.closure = closure
        self.lining = lining
        self.stretchTestRefs = stretchTestRefs
        self.seamAllowanceKnown = seamAllowanceKnown
        self.unitSystem = unitSystem
        self.sizeSystem = sizeSystem
        self.revision = revision
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", measurementType = "measurement_type"
        case pointsBySize = "points_by_size", cut, closure, lining, stretchTestRefs = "stretch_test_refs"
        case seamAllowanceKnown = "seam_allowance_known", unitSystem = "unit_system", sizeSystem = "size_system", revision
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion)
        try require(!identityID.isBlank && !sizeSystem.isBlank && revision >= 1)
        try require(!pointsBySize.isEmpty)
        try require(allNonBlank(stretchTestRefs) && allUnique(stretchTestRefs))
        if let closure { try require(!closure.isBlank) }
        for p in pointsBySize {
            try require(!p.size.isBlank && !p.sourceEvidenceID.isBlank)
            try require(p.cm.isFinite(in: 0.1...400))
            if let t = p.toleranceCm { try require(t.isFinite(in: 0...50)) }
            try require((1...revision).contains(p.revision))
            // A person has no "flat half width": that dimension only exists on a garment.
            if measurementType == .bodySizeChart { try require(p.dimension != .flatHalfWidth) }
        }
        // One value per size, region and dimension; two would be a silent conflict.
        try require(allUnique(pointsBySize.map { "\($0.size)|\($0.region.rawValue)|\($0.dimension.rawValue)" }))
    }

    public var sizes: [String] {
        var seen = Set<String>()
        return pointsBySize.map(\.size).filter { seen.insert($0).inserted }
    }

    public func point(size: String, region: GarmentRegion, dimension: Dimension) -> Point? {
        pointsBySize.first { $0.size == size && $0.region == region && $0.dimension == dimension }
    }
}
