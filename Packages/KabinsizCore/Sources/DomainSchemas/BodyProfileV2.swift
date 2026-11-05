import BodyGeometry
import Foundation
import SystemContracts

/// The body, version 2 (v1.7 §4). Real measurements and the picture are separate: `measurements` holds
/// only values a person measured, edited or explicitly took from an estimate, while slider shapes live in
/// `avatarMorphState` and can never be read as a measurement. Never leaves the device (`localOnly`).
public struct BodyProfileV2: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 2 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }
    public static let dataClassification = DataClassification.localSensitive

    public enum Region: String, Codable, CaseIterable, Sendable {
        case height = "HEIGHT", shoulderWidth = "SHOULDER_WIDTH", chest = "CHEST", waist = "WAIST", hip = "HIP"
        case neck = "NECK", armLength = "ARM_LENGTH", inseam = "INSEAM", thigh = "THIGH"

        /// Plausible-number check against typing errors (78 → 780), not a judgement about bodies (§5.1).
        public var entryRangeCm: ClosedRange<Double> {
            switch self {
            case .height: 50...260
            case .shoulderWidth, .neck: 15...80
            case .chest, .waist, .hip: 30...250
            case .armLength, .inseam: 20...130
            case .thigh: 20...120
            }
        }

        public init(_ p: BodyParameter) {
            switch p {
            case .height: self = .height
            case .shoulderWidth: self = .shoulderWidth
            case .chest: self = .chest
            case .waist: self = .waist
            case .hip: self = .hip
            }
        }

        public var parameter: BodyParameter? {
            switch self {
            case .height: .height
            case .shoulderWidth: .shoulderWidth
            case .chest: .chest
            case .waist: .waist
            case .hip: .hip
            default: nil
            }
        }
    }

    public enum Origin: String, Codable, CaseIterable, Sendable {
        case userMeasured = "USER_MEASURED"
        /// The user corrected a prefilled value; theirs now.
        case userEdited = "USER_EDITED"
        /// From a photo; low confidence, shown for correction, never used for size advice.
        case imageEstimate = "IMAGE_ESTIMATE"

        public var mayInformSizeAdvice: Bool { self != .imageEstimate }
    }

    public enum Method: String, Codable, CaseIterable, Sendable {
        case tapeSelf = "TAPE_SELF", tapeHelper = "TAPE_HELPER", photoEstimate = "PHOTO_ESTIMATE", unknown = "UNKNOWN"
    }

    public enum Confidence: String, Codable, CaseIterable, Sendable { case low = "LOW", medium = "MEDIUM", high = "HIGH" }

    public struct Measurement: Codable, Hashable, Sendable {
        public var region: Region
        public var cm: Double
        public var origin: Origin
        public var method: Method?
        public var confidence: Confidence?
        public var observedAt: Date

        public init(region: Region, cm: Double, origin: Origin, method: Method? = nil, confidence: Confidence? = nil, observedAt: Date) {
            self.region = region
            self.cm = cm
            self.origin = origin
            self.method = method
            self.confidence = confidence
            self.observedAt = observedAt
        }

        enum CodingKeys: String, CodingKey { case region, cm, origin, method, confidence, observedAt = "observed_at" }
    }

    public struct FitPreferences: Codable, Hashable, Sendable {
        public var prefersRelaxedFit: Bool?
        public var dislikesTightShoulders: Bool?
        public var wantsStretch: Bool?
        public init(prefersRelaxedFit: Bool? = nil, dislikesTightShoulders: Bool? = nil, wantsStretch: Bool? = nil) {
            self.prefersRelaxedFit = prefersRelaxedFit
            self.dislikesTightShoulders = dislikesTightShoulders
            self.wantsStretch = wantsStretch
        }
        enum CodingKeys: String, CodingKey {
            case prefersRelaxedFit = "prefers_relaxed_fit", dislikesTightShoulders = "dislikes_tight_shoulders", wantsStretch = "wants_stretch"
        }
    }

    /// The drawn body. Shapes for the picture only; `source` says whether a value is still the neutral start
    /// or the app's estimate from height and weight. The body template and the weight live here too
    /// (ADR-011): both shape only the picture and are never read as measurements or for size advice.
    public struct MorphState: Codable, Hashable, Sendable {
        public enum Source: String, Codable, CaseIterable, Sendable {
            case neutralStart = "NEUTRAL_START", sliderShaped = "SLIDER_SHAPED", weightEstimate = "WEIGHT_ESTIMATE"
        }
        public struct Value: Codable, Hashable, Sendable {
            public var region: Region
            public var cm: Double
            public var source: Source
            public init(region: Region, cm: Double, source: Source) {
                self.region = region
                self.cm = cm
                self.source = source
            }
        }
        public var values: [Value]
        public var preferredUnit: LengthUnit
        /// nil = neutral (records written before ADR-011).
        public var template: BodyTemplate?
        public var weightKg: Double?
        public init(values: [Value], preferredUnit: LengthUnit, template: BodyTemplate? = nil, weightKg: Double? = nil) {
            self.values = values
            self.preferredUnit = preferredUnit
            self.template = template
            self.weightKg = weightKg
        }
        enum CodingKeys: String, CodingKey { case values, preferredUnit = "preferred_unit", template, weightKg = "weight_kg" }
    }

    public enum Approval: String, Codable, CaseIterable, Sendable {
        case notAsked = "NOT_ASKED", approved = "APPROVED", declined = "DECLINED"
    }

    public var schemaVersion: Int
    public var profileRevision: Int
    public var measurements: [Measurement]
    public var fitPreferences: FitPreferences
    public var avatarMorphState: MorphState
    /// Whether the user approved using their measurements for size advice at all.
    public var userApproval: Approval
    public var localOnly: Bool

    public init(profileRevision: Int, measurements: [Measurement], fitPreferences: FitPreferences = .init(),
                avatarMorphState: MorphState, userApproval: Approval) {
        schemaVersion = Self.currentSchemaVersion
        self.profileRevision = profileRevision
        self.measurements = measurements
        self.fitPreferences = fitPreferences
        self.avatarMorphState = avatarMorphState
        self.userApproval = userApproval
        localOnly = true
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", profileRevision = "profile_revision", measurements
        case fitPreferences = "fit_preferences", avatarMorphState = "avatar_morph_state", userApproval = "user_approval"
        case localOnly = "local_only"
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && profileRevision >= 1)
        // A body file that says it may leave the device is not a body file this app wrote.
        try require(localOnly, .egressBlocked)
        try require(allUnique(measurements.map(\.region)))
        for m in measurements {
            try require(m.cm.isFinite(in: m.region.entryRangeCm))
            if m.origin == .imageEstimate {
                // An estimate always says how it was made and how sure it is.
                try require(m.method == .photoEstimate && m.confidence != nil)
            } else {
                try require(m.method != .photoEstimate)
            }
        }
        try require(allUnique(avatarMorphState.values.map(\.region)))
        try require(avatarMorphState.values.allSatisfy { $0.cm.isFinite(in: $0.region.entryRangeCm) })
        if let kg = avatarMorphState.weightKg { try require(kg.isFinite(in: BodyProfile.weightRangeKg)) }
    }

    /// Measurements size advice may use: approved, and never a photo estimate.
    public var sizingMeasurements: [Region: Double] {
        guard userApproval == .approved else { return [:] }
        return measurements.reduce(into: [:]) { out, m in
            if m.origin.mayInformSizeAdvice { out[m.region] = m.cm }
        }
    }
}

// MARK: - Migration v1 <-> v2

public enum BodyProfileMigration {
    /// v1 → v2. Only `USER_MEASURED` values become measurements; slider shapes and neutral starts stay in
    /// the morph state and are never promoted (§123 A.5). v1 has no measurement dates, so `observedAt` is
    /// the migration time. v1 had no approval either: a typed measurement there already fed size advice,
    /// so it migrates as `APPROVED`; a body with no typed measurement starts as `NOT_ASKED`.
    public static func upgrade(_ v1: BodyProfile, at observedAt: Date) throws(FaultCode) -> BodyProfileV2 {
        do { try v1.validate() } catch { throw .schemaInvalid }
        var measurements: [BodyProfileV2.Measurement] = []
        var morph: [BodyProfileV2.MorphState.Value] = []
        for p in BodyParameter.allCases {
            let v = v1[p]
            let region = BodyProfileV2.Region(p)
            switch v.source {
            case .userMeasured:
                measurements.append(.init(region: region, cm: v.length.centimeters, origin: .userMeasured, method: .unknown, observedAt: observedAt))
            case .sliderShaped:
                morph.append(.init(region: region, cm: v.length.centimeters, source: .sliderShaped))
            case .neutralStart:
                morph.append(.init(region: region, cm: v.length.centimeters, source: .neutralStart))
            case .weightEstimate:
                morph.append(.init(region: region, cm: v.length.centimeters, source: .weightEstimate))
            }
        }
        let v2 = BodyProfileV2(
            profileRevision: v1.revision, measurements: measurements,
            avatarMorphState: .init(values: morph, preferredUnit: v1.preferredUnit,
                                    template: v1.template == .neutral ? nil : v1.template, weightKg: v1.weightKg),
            userApproval: measurements.isEmpty ? .notAsked : .approved
        )
        try v2.validate()
        return v2
    }

    /// v2 → v1 for the current editor, which still speaks v1. Exact for everything v1 can hold; regions
    /// v1 has no control for (neck, arm, inseam, thigh) are left out, and an image estimate is drawn as a
    /// slider shape, never written back as a measurement.
    public static func downgrade(_ v2: BodyProfileV2) throws(FaultCode) -> BodyProfile {
        try v2.validate()
        var values: [BodyParameter: BodyValue] = [:]
        for p in BodyParameter.allCases {
            let region = BodyProfileV2.Region(p)
            if let m = v2.measurements.first(where: { $0.region == region }) {
                values[p] = BodyValue(BodyLength(m.cm, .centimeters), source: m.origin.mayInformSizeAdvice ? .userMeasured : .sliderShaped)
            } else if let shape = v2.avatarMorphState.values.first(where: { $0.region == region }) {
                let source: ValueSource = switch shape.source {
                case .neutralStart: .neutralStart
                case .sliderShaped: .sliderShaped
                case .weightEstimate: .weightEstimate
                }
                values[p] = BodyValue(BodyLength(shape.cm, .centimeters), source: source)
            } else {
                values[p] = BodyValue(BodyLength(p.neutralStartCm, .centimeters), source: .neutralStart)
            }
        }
        let morph = v2.avatarMorphState
        let v1 = BodyProfile(revision: v2.profileRevision, values: values, preferredUnit: morph.preferredUnit,
                             template: morph.template ?? .neutral, weightKg: morph.weightKg)
        do { try v1.validate() } catch { throw .schemaInvalid }
        return v1
    }

    /// Reads either version: a v2 file through the strict contract decoder, a v1 file (no
    /// `schema_version` key) through its own decoder, then upgraded. A newer file is refused.
    public static func read(_ data: Data, now: Date) throws(FaultCode) -> BodyProfileV2 {
        guard let top = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else { throw .schemaInvalid }
        if top["schema_version"] != nil { return try ContractCoder.decode(BodyProfileV2.self, from: data) }
        let keys = Set(top.keys)
        guard keys.isSuperset(of: ["revision", "values", "preferredUnit"]),
              keys.isSubset(of: ["revision", "values", "preferredUnit", "template", "weightKg"]),
              let v1 = try? JSONDecoder().decode(BodyProfile.self, from: data)
        else { throw .schemaInvalid }
        return try upgrade(v1, at: now)
    }
}
