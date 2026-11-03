import DomainContracts
import Foundation
import SystemContracts

/// Region-by-region fit for one product and one body revision (v1.7 §4, §5.7). An unknown critical region
/// blocks a single-size answer; "fits" is only said where evidence covers it.
public struct RegionalFitV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }
    public static let dataClassification = DataClassification.localSensitive

    public enum Evaluation: String, Codable, CaseIterable, Sendable {
        case fitEvidence = "FIT_EVIDENCE", possiblyTight = "POSSIBLY_TIGHT", possiblyLoose = "POSSIBLY_LOOSE", unknown = "UNKNOWN"
    }

    public enum Recommendation: String, Codable, CaseIterable, Sendable {
        case trySize = "TRY_SIZE", compareTwoSizes = "COMPARE_TWO_SIZES", insufficientData = "INSUFFICIENT_DATA"

        var sizeCount: Int {
            switch self {
            case .trySize: 1
            case .compareTwoSizes: 2
            case .insufficientData: 0
            }
        }
    }

    public struct RegionResult: Codable, Hashable, Sendable {
        public var region: GarmentRegion
        public var evaluation: Evaluation
        public var usableMeasurements: [BodyProfileV2.Region]
        public var garmentEaseCm: Double?
        public var uncertaintyCm: Double?
        public var evidenceIDs: [String]
        public var explanation: String

        public init(region: GarmentRegion, evaluation: Evaluation, usableMeasurements: [BodyProfileV2.Region], garmentEaseCm: Double? = nil,
                    uncertaintyCm: Double? = nil, evidenceIDs: [String], explanation: String) {
            self.region = region
            self.evaluation = evaluation
            self.usableMeasurements = usableMeasurements
            self.garmentEaseCm = garmentEaseCm
            self.uncertaintyCm = uncertaintyCm
            self.evidenceIDs = evidenceIDs
            self.explanation = explanation
        }

        enum CodingKeys: String, CodingKey {
            case region, evaluation, usableMeasurements = "usable_measurements", garmentEaseCm = "garment_ease_cm"
            case uncertaintyCm = "uncertainty_cm", evidenceIDs = "evidence_ids", explanation
        }
    }

    public var schemaVersion: Int
    public var identityID: String
    public var profileRevision: Int
    public var chartRevision: Int
    public var regions: [RegionResult]
    public var recommendation: Recommendation
    /// One size for TRY_SIZE, two for COMPARE_TWO_SIZES, none otherwise.
    public var recommendedSizes: [String]
    public var isProductSpecificFitProven: Bool
    public var limitations: [String]

    public init(identityID: String, profileRevision: Int, chartRevision: Int, regions: [RegionResult], recommendation: Recommendation,
                recommendedSizes: [String], isProductSpecificFitProven: Bool, limitations: [String]) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.profileRevision = profileRevision
        self.chartRevision = chartRevision
        self.regions = regions
        self.recommendation = recommendation
        self.recommendedSizes = recommendedSizes
        self.isProductSpecificFitProven = isProductSpecificFitProven
        self.limitations = limitations
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", profileRevision = "profile_revision"
        case chartRevision = "chart_revision", regions, recommendation, recommendedSizes = "recommended_sizes"
        case isProductSpecificFitProven = "is_product_specific_fit_proven", limitations
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && !identityID.isBlank && profileRevision >= 1 && chartRevision >= 1)
        try require(allUnique(regions.map(\.region)) && allNonBlank(limitations))
        for r in regions {
            try require(!r.explanation.isBlank && allNonBlank(r.evidenceIDs) && allUnique(r.usableMeasurements))
            if let e = r.garmentEaseCm { try require(e.isFinite(in: -50...100)) }
            if let u = r.uncertaintyCm { try require(u.isFinite(in: 0...50)) }
            if r.evaluation == .unknown {
                try require(r.garmentEaseCm == nil)
            } else {
                // A verdict about a region needs a measurement of it and a source to compare against.
                try require(!r.usableMeasurements.isEmpty && !r.evidenceIDs.isEmpty)
            }
        }
        try require(recommendedSizes.count == recommendation.sizeCount && allNonBlank(recommendedSizes) && allUnique(recommendedSizes))
        switch recommendation {
        case .trySize:
            // §5.7: one size only when every region in play is evaluated.
            try require(!regions.isEmpty && regions.allSatisfy { $0.evaluation != .unknown })
        case .compareTwoSizes:
            try require(regions.contains { $0.evaluation != .unknown })
        case .insufficientData:
            break
        }
        if isProductSpecificFitProven {
            try require(recommendation == .trySize && regions.allSatisfy { $0.evaluation == .fitEvidence })
        } else {
            // Not proven → say what is missing.
            try require(!limitations.isEmpty)
        }
    }

    /// Cross-check with the body it was computed for: same revision, and every measurement a region used
    /// is one size advice may use (approved, typed by the user). A slider shape or a photo estimate can
    /// never stand behind a fit verdict.
    public func validate(against body: BodyProfileV2) throws(FaultCode) {
        try validate()
        try body.validate()
        try require(body.profileRevision == profileRevision, .staleRevision)
        let usable = Set(body.sizingMeasurements.keys)
        try require(regions.allSatisfy { $0.usableMeasurements.allSatisfy(usable.contains) })
    }

    public var confidence: ConfidenceKind {
        switch recommendation {
        case .insufficientData: .abstain
        case .compareTwoSizes: .partial
        case .trySize: isProductSpecificFitProven ? .verifiedFacts : .heuristic
        }
    }
}

/// What to wear for the weather around a product (v1.7 §6 B). A comfort interval in degrees exists only
/// with measured thermal data and weather evidence; the care label's wash temperature rides along as
/// care information and never shapes the advice.
public struct ThermalAdviceV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum Advice: String, Codable, CaseIterable, Sendable {
        case layeringSuggestion = "LAYERING_SUGGESTION", weatherUncertain = "WEATHER_UNCERTAIN", noData = "NO_DATA"
    }

    public enum Activity: String, Codable, CaseIterable, Sendable {
        case resting = "RESTING", walking = "WALKING", active = "ACTIVE"
    }

    public enum ColdPreference: String, Codable, CaseIterable, Sendable {
        case runsCold = "RUNS_COLD", neutral = "NEUTRAL", runsWarm = "RUNS_WARM"
    }

    public struct Context: Codable, Hashable, Sendable {
        public var airTempC: Double?
        public var apparentTempC: Double?
        public var windMps: Double?
        public var humidityPct: Double?
        public var precipitationMm: Double?
        public var activity: Activity?
        public var durationMin: Int?
        public var layers: Int?
        public var userColdPreference: ColdPreference?

        public init(airTempC: Double? = nil, apparentTempC: Double? = nil, windMps: Double? = nil, humidityPct: Double? = nil,
                    precipitationMm: Double? = nil, activity: Activity? = nil, durationMin: Int? = nil, layers: Int? = nil,
                    userColdPreference: ColdPreference? = nil) {
            self.airTempC = airTempC
            self.apparentTempC = apparentTempC
            self.windMps = windMps
            self.humidityPct = humidityPct
            self.precipitationMm = precipitationMm
            self.activity = activity
            self.durationMin = durationMin
            self.layers = layers
            self.userColdPreference = userColdPreference
        }

        /// Any value that can only come from a weather source.
        public var hasWeatherValues: Bool {
            airTempC != nil || apparentTempC != nil || windMps != nil || humidityPct != nil || precipitationMm != nil
        }

        enum CodingKeys: String, CodingKey {
            case airTempC = "air_temp_c", apparentTempC = "apparent_temp_c", windMps = "wind_mps", humidityPct = "humidity_pct"
            case precipitationMm = "precipitation_mm", activity, durationMin = "duration_min", layers
            case userColdPreference = "user_cold_preference"
        }
    }

    public struct Interval: Codable, Hashable, Sendable {
        public var lowC: Double
        public var highC: Double
        public init(lowC: Double, highC: Double) {
            self.lowC = lowC
            self.highC = highC
        }
        enum CodingKeys: String, CodingKey { case lowC = "low_c", highC = "high_c" }
    }

    public var schemaVersion: Int
    public var identityID: String
    public var weatherEvidenceID: String?
    public var context: Context
    public var advice: Advice
    public var estimatedComfortIntervalC: Interval?
    public var verifiedMeasurementIDs: [String]
    public var text: String
    public var limitations: [String]
    /// Care label wash temperature. Independent care information only (§6 A ≠ §6 B).
    public var washCareTempC: Int?

    public init(identityID: String, weatherEvidenceID: String?, context: Context, advice: Advice, estimatedComfortIntervalC: Interval? = nil,
                verifiedMeasurementIDs: [String] = [], text: String, limitations: [String], washCareTempC: Int? = nil) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.weatherEvidenceID = weatherEvidenceID
        self.context = context
        self.advice = advice
        self.estimatedComfortIntervalC = estimatedComfortIntervalC
        self.verifiedMeasurementIDs = verifiedMeasurementIDs
        self.text = text
        self.limitations = limitations
        self.washCareTempC = washCareTempC
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", weatherEvidenceID = "weather_evidence_id", context, advice
        case estimatedComfortIntervalC = "estimated_comfort_interval_c", verifiedMeasurementIDs = "verified_measurement_ids"
        case text, limitations, washCareTempC = "wash_care_temp_c"
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && !identityID.isBlank && !text.isBlank)
        // Comfort always depends on the person; there is always at least one limitation to say.
        try require(!limitations.isEmpty && allNonBlank(limitations) && allNonBlank(verifiedMeasurementIDs) && allUnique(verifiedMeasurementIDs))
        if let w = weatherEvidenceID { try require(!w.isBlank) }
        let c = context
        // No weather numbers without a weather source: never a made-up temperature (§4 provenance).
        if c.hasWeatherValues { try require(weatherEvidenceID != nil && advice != .noData) }
        if let t = c.airTempC { try require(t.isFinite(in: -60...60)) }
        if let t = c.apparentTempC { try require(t.isFinite(in: -80...70)) }
        if let w = c.windMps { try require(w.isFinite(in: 0...80)) }
        if let h = c.humidityPct { try require(h.isFinite(in: 0...100)) }
        if let p = c.precipitationMm { try require(p.isFinite(in: 0...500)) }
        if let d = c.durationMin { try require((1...1440).contains(d)) }
        if let l = c.layers { try require((1...8).contains(l)) }
        if let wash = washCareTempC { try require((0...95).contains(wash)) }
        if let interval = estimatedComfortIntervalC {
            try require(advice == .layeringSuggestion && weatherEvidenceID != nil && !verifiedMeasurementIDs.isEmpty)
            try require(interval.lowC.isFinite(in: -40...45) && interval.highC.isFinite(in: -40...45) && interval.lowC < interval.highC)
        } else {
            // Without a measured interval the sentence carries no numbers or degrees at all.
            try require(!text.contains { $0.isNumber || $0 == "°" || $0 == "%" })
        }
        if advice == .noData { try require(weatherEvidenceID == nil) }
    }
}

/// How a product is shown on the body (v1.7 §3.2, §5.9). A picture is never fit evidence, whatever its
/// fidelity; only G2 may claim a validated simulation, and a generated image (G3) always says it is one.
public struct VisualTryOnV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }
    /// §5.9: generative or rendered try-on never feeds the size decision.
    public static let mayInformSizeAdvice = false

    /// v1.7 §3.2 ladder. G0 = no product-specific 3D (a product card, or the neutral body without the garment).
    public enum Fidelity: String, Codable, CaseIterable, Comparable, Sendable {
        case g0 = "G0", g1 = "G1", g2 = "G2", g3 = "G3"
        public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }

        /// The app's render tiers (§25.2) on this ladder: a generic mesh is still G0 for the product.
        public init(_ tier: VisualFidelityTier) {
            switch tier {
            case .flat2D, .genericMesh: self = .g0
            case .productAsset: self = .g1
            }
        }
    }

    public enum AssetLicense: String, Codable, CaseIterable, Sendable {
        case none = "NONE", ownProcedural = "OWN_PROCEDURAL", brandLicensed = "BRAND_LICENSED"
        case marketplaceLicensed = "MARKETPLACE_LICENSED", syntheticDemo = "SYNTHETIC_DEMO"

        var coversProductAsset: Bool { self == .brandLicensed || self == .marketplaceLicensed || self == .syntheticDemo }
    }

    public enum RenderingMethod: String, Codable, CaseIterable, Sendable {
        case productPhotoCard = "PRODUCT_PHOTO_CARD", genericMesh = "GENERIC_MESH", preparedProductMesh = "PREPARED_PRODUCT_MESH"
        case validatedDrape = "VALIDATED_DRAPE", generativeImage = "GENERATIVE_IMAGE"
    }

    public var schemaVersion: Int
    public var identityID: String
    public var profileRevision: Int
    public var assetRevision: Int?
    public var fidelity: Fidelity
    public var assetLicense: AssetLicense
    public var renderingMethod: RenderingMethod
    public var simulationValidated: Bool
    public var previewLatencyMs: Double?
    public var confidenceExplanations: [String]
    public var limitations: [String]

    public init(identityID: String, profileRevision: Int, assetRevision: Int?, fidelity: Fidelity, assetLicense: AssetLicense,
                renderingMethod: RenderingMethod, simulationValidated: Bool, previewLatencyMs: Double? = nil,
                confidenceExplanations: [String], limitations: [String]) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.profileRevision = profileRevision
        self.assetRevision = assetRevision
        self.fidelity = fidelity
        self.assetLicense = assetLicense
        self.renderingMethod = renderingMethod
        self.simulationValidated = simulationValidated
        self.previewLatencyMs = previewLatencyMs
        self.confidenceExplanations = confidenceExplanations
        self.limitations = limitations
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", profileRevision = "profile_revision"
        case assetRevision = "asset_revision", fidelity, assetLicense = "asset_license", renderingMethod = "rendering_method"
        case simulationValidated = "simulation_validated", previewLatencyMs = "preview_latency_ms"
        case confidenceExplanations = "confidence_explanations", limitations
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && !identityID.isBlank && profileRevision >= 1)
        try require(!confidenceExplanations.isEmpty && allNonBlank(confidenceExplanations))
        try require(!limitations.isEmpty && allNonBlank(limitations))
        if let ms = previewLatencyMs { try require(ms.isFinite(in: 0...600_000)) }
        if let a = assetRevision { try require(a >= 1) }
        // Only a validated drape is a validated simulation (§3.2 G1 "fiziksel simülasyon değildir").
        try require(simulationValidated == (fidelity == .g2))
        switch fidelity {
        case .g0:
            try require([.productPhotoCard, .genericMesh].contains(renderingMethod) && assetRevision == nil)
            try require(assetLicense == .none || assetLicense == .ownProcedural)
        case .g1:
            try require(renderingMethod == .preparedProductMesh && assetRevision != nil && assetLicense.coversProductAsset)
        case .g2:
            try require(renderingMethod == .validatedDrape && assetRevision != nil && assetLicense.coversProductAsset)
        case .g3:
            try require(renderingMethod == .generativeImage)
        }
        if renderingMethod == .generativeImage { try require(fidelity == .g3) }
    }
}
