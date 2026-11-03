import Foundation
import SystemContracts

/// What a garment is made of (v1.7 §4, §6). Every value that is present names its evidence; a value with
/// no source is absent, not guessed. A picture can say "looks like denim" but never gives fibre
/// percentages, and a care-label wash temperature is never a wearing temperature.
public struct FabricSpecV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum Fiber: String, Codable, CaseIterable, Sendable {
        case cotton = "COTTON", polyester = "POLYESTER", elastane = "ELASTANE", wool = "WOOL", viscose = "VISCOSE"
        case linen = "LINEN", polyamide = "POLYAMIDE", acrylic = "ACRYLIC", silk = "SILK", cashmere = "CASHMERE"
        case lyocell = "LYOCELL", modal = "MODAL", other = "OTHER"
    }

    public struct FiberShare: Codable, Hashable, Sendable {
        public var fiber: Fiber
        public var percentage: Double
        public init(_ fiber: Fiber, _ percentage: Double) {
            self.fiber = fiber
            self.percentage = percentage
        }
    }

    /// Where the composition was read. A guess from a photo is not on this list on purpose.
    public enum CompositionOrigin: String, Codable, CaseIterable, Sendable {
        case brandLicensed = "BRAND_LICENSED"
        case retailerFeed = "RETAILER_FEED"
        case careLabelUserConfirmed = "CARE_LABEL_USER_CONFIRMED"
        /// Read by OCR, not yet confirmed: shown as "okundu, doğrula", never as material fact.
        case careLabelUnconfirmed = "CARE_LABEL_UNCONFIRMED"
        case userTyped = "USER_TYPED"
        case synthetic = "SYNTHETIC"

        /// Brand or retailer data may be shown as the product's material; user-side reads stay the user's.
        public var isProductFact: Bool { self == .brandLicensed || self == .retailerFeed }
    }

    public enum Construction: String, Codable, CaseIterable, Sendable {
        case knit = "KNIT", woven = "WOVEN", nonwoven = "NONWOVEN"
    }

    public enum StretchDirection: String, Codable, CaseIterable, Sendable {
        case none = "NONE", widthOnly = "WIDTH_ONLY", lengthOnly = "LENGTH_ONLY", both = "BOTH"
    }

    public enum Drying: String, Codable, CaseIterable, Sendable {
        case tumbleLow = "TUMBLE_LOW", tumbleNormal = "TUMBLE_NORMAL", noTumble = "NO_TUMBLE", lineDry = "LINE_DRY", flatDry = "FLAT_DRY"
    }

    public enum Uncertainty: String, Codable, CaseIterable, Sendable {
        case low = "LOW", medium = "MEDIUM", high = "HIGH", unknown = "UNKNOWN"
    }

    /// A laboratory result (e.g. ISO 11092 Rct). Only a report gives a number.
    public struct LabResult: Codable, Hashable, Sendable {
        public var standard: String
        public var value: Double
        public var unit: String
        public init(standard: String, value: Double, unit: String) {
            self.standard = standard
            self.value = value
            self.unit = unit
        }
    }

    /// Attribute names used as keys of `evidenceByAttribute`; equal to the JSON keys of the fields.
    public enum Attribute: String, CaseIterable, Sendable {
        case composition, fabricWeightGsm = "fabric_weight_gsm", knitOrWoven = "knit_or_woven"
        case stretchDirection = "stretch_direction", stretchRecovery = "stretch_recovery", layerCount = "layer_count"
        case lining, waterResistanceTest = "water_resistance_test", thermalResistanceTest = "thermal_resistance_test"
        case vapourResistanceTest = "vapour_resistance_test", washInstructionC = "wash_instruction_c"
        case dryingInstruction = "drying_instruction"
    }

    public var schemaVersion: Int
    public var identityID: String
    public var composition: [FiberShare]
    public var compositionOrigin: CompositionOrigin?
    /// Free text such as "denim görünümlü" from a picture. Appearance only; never feeds composition.
    public var visualAppearanceHint: String?
    public var fabricWeightGsm: Double?
    public var knitOrWoven: Construction?
    public var stretchDirection: StretchDirection?
    /// Percent recovered after a stretch test. Only from a test, never from a word like "super stretch".
    public var stretchRecovery: Double?
    public var layerCount: Int?
    public var lining: [FiberShare]?
    public var waterResistanceTest: LabResult?
    public var thermalResistanceTest: LabResult?
    public var vapourResistanceTest: LabResult?
    /// Care label: the maximum washing temperature. Care only (§6 A); never a weather or comfort value.
    public var washInstructionC: Int?
    public var dryingInstruction: Drying?
    public var evidenceByAttribute: [String: String]
    public var userVerifiedLabelPhoto: Bool?
    public var uncertainty: Uncertainty

    public init(identityID: String, composition: [FiberShare] = [], compositionOrigin: CompositionOrigin? = nil,
                visualAppearanceHint: String? = nil, fabricWeightGsm: Double? = nil, knitOrWoven: Construction? = nil,
                stretchDirection: StretchDirection? = nil, stretchRecovery: Double? = nil, layerCount: Int? = nil,
                lining: [FiberShare]? = nil, waterResistanceTest: LabResult? = nil, thermalResistanceTest: LabResult? = nil,
                vapourResistanceTest: LabResult? = nil, washInstructionC: Int? = nil, dryingInstruction: Drying? = nil,
                evidenceByAttribute: [String: String] = [:], userVerifiedLabelPhoto: Bool? = nil, uncertainty: Uncertainty) {
        schemaVersion = Self.currentSchemaVersion
        self.identityID = identityID
        self.composition = composition
        self.compositionOrigin = compositionOrigin
        self.visualAppearanceHint = visualAppearanceHint
        self.fabricWeightGsm = fabricWeightGsm
        self.knitOrWoven = knitOrWoven
        self.stretchDirection = stretchDirection
        self.stretchRecovery = stretchRecovery
        self.layerCount = layerCount
        self.lining = lining
        self.waterResistanceTest = waterResistanceTest
        self.thermalResistanceTest = thermalResistanceTest
        self.vapourResistanceTest = vapourResistanceTest
        self.washInstructionC = washInstructionC
        self.dryingInstruction = dryingInstruction
        self.evidenceByAttribute = evidenceByAttribute
        self.userVerifiedLabelPhoto = userVerifiedLabelPhoto
        self.uncertainty = uncertainty
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", identityID = "identity_id", composition, compositionOrigin = "composition_origin"
        case visualAppearanceHint = "visual_appearance_hint", fabricWeightGsm = "fabric_weight_gsm", knitOrWoven = "knit_or_woven"
        case stretchDirection = "stretch_direction", stretchRecovery = "stretch_recovery", layerCount = "layer_count", lining
        case waterResistanceTest = "water_resistance_test", thermalResistanceTest = "thermal_resistance_test"
        case vapourResistanceTest = "vapour_resistance_test", washInstructionC = "wash_instruction_c"
        case dryingInstruction = "drying_instruction", evidenceByAttribute = "evidence_by_attribute"
        case userVerifiedLabelPhoto = "user_verified_label_photo", uncertainty
    }

    /// Attributes that carry a value. Each must have evidence and only these may.
    public var presentAttributes: Set<Attribute> {
        var a = Set<Attribute>()
        if !composition.isEmpty { a.insert(.composition) }
        if fabricWeightGsm != nil { a.insert(.fabricWeightGsm) }
        if knitOrWoven != nil { a.insert(.knitOrWoven) }
        if stretchDirection != nil { a.insert(.stretchDirection) }
        if stretchRecovery != nil { a.insert(.stretchRecovery) }
        if layerCount != nil { a.insert(.layerCount) }
        if lining != nil { a.insert(.lining) }
        if waterResistanceTest != nil { a.insert(.waterResistanceTest) }
        if thermalResistanceTest != nil { a.insert(.thermalResistanceTest) }
        if vapourResistanceTest != nil { a.insert(.vapourResistanceTest) }
        if washInstructionC != nil { a.insert(.washInstructionC) }
        if dryingInstruction != nil { a.insert(.dryingInstruction) }
        return a
    }

    static func validShares(_ shares: [FiberShare]) -> Bool {
        guard !shares.isEmpty, allUnique(shares.map(\.fiber)) else { return false }
        guard shares.allSatisfy({ $0.percentage.isFinite && $0.percentage > 0 && $0.percentage <= 100 }) else { return false }
        // Labels round each fibre; the total may be off by a point, never more (§6 CompositionParser).
        return (99...101).contains(shares.reduce(0) { $0 + $1.percentage })
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && !identityID.isBlank)
        if composition.isEmpty {
            try require(compositionOrigin == nil)
        } else {
            try require(compositionOrigin != nil && Self.validShares(composition))
        }
        if let lining { try require(Self.validShares(lining)) }
        if let hint = visualAppearanceHint { try require(!hint.isBlank) }
        if let g = fabricWeightGsm { try require(g.isFinite(in: 1...2000)) }
        if let r = stretchRecovery {
            // A recovery figure needs the stretch it recovers from.
            try require(r.isFinite(in: 0...100) && stretchDirection != nil && stretchDirection != StretchDirection.none)
        }
        if let n = layerCount { try require((1...10).contains(n)) }
        for test in [waterResistanceTest, thermalResistanceTest, vapourResistanceTest].compactMap({ $0 }) {
            try require(!test.standard.isBlank && !test.unit.isBlank && test.value.isFinite(in: 0...100_000))
        }
        if let c = washInstructionC { try require((0...95).contains(c)) }
        // Provenance: every present value names evidence; no evidence for a value that is not there.
        let keys = Set(evidenceByAttribute.keys)
        try require(keys == Set(presentAttributes.map(\.rawValue)))
        try require(allNonBlank(evidenceByAttribute.values))
    }

    /// The composition may be shown as the product's real material.
    public var compositionIsProductFact: Bool {
        !composition.isEmpty && (compositionOrigin?.isProductFact ?? false)
    }
}
