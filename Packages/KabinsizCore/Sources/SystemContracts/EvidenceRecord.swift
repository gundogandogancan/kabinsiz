import DomainContracts
import Foundation

/// One sourced fact about a product (§106.2). Without rights, identity and version it can never be
/// presented as verified, whatever its value.
public struct EvidenceRecord: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public enum SourceType: String, Codable, CaseIterable, Sendable {
        case licensedCatalog = "LICENSED_CATALOG", manufacturer = "MANUFACTURER", retailerListing = "RETAILER_LISTING"
        case userEntered = "USER_ENTERED", review = "REVIEW", syntheticFixture = "SYNTHETIC_FIXTURE"
    }

    public enum VerificationMethod: String, Codable, Sendable {
        case none = "NONE", manualReview = "MANUAL_REVIEW", partnerAttested = "PARTNER_ATTESTED", measured = "MEASURED"
    }

    public var schemaVersion: Int
    public var evidenceID: String
    public var factKey: String
    public var subjectProductID: String
    public var variantID: String?
    public var factValue: String
    public var unit: String?
    public var sourceType: SourceType
    public var sourceURIOrLicensedDatasetID: String
    public var licenseID: String?
    public var collectedAt: Date
    public var effectiveFrom: Date?
    public var expiresAt: Date?
    public var region: String?
    public var modelOrParserVersion: String?
    public var confidenceKind: ConfidenceKind
    public var verificationMethod: VerificationMethod
    public var userOverride: Bool
    public var revocationTombstone: Bool

    public init(
        evidenceID: String, factKey: String, subjectProductID: String, variantID: String?, factValue: String, unit: String?,
        sourceType: SourceType, sourceURIOrLicensedDatasetID: String, licenseID: String?, collectedAt: Date,
        effectiveFrom: Date? = nil, expiresAt: Date? = nil, region: String? = nil, modelOrParserVersion: String? = nil,
        confidenceKind: ConfidenceKind, verificationMethod: VerificationMethod, userOverride: Bool = false, revocationTombstone: Bool = false
    ) {
        self.schemaVersion = Self.currentSchemaVersion
        self.evidenceID = evidenceID
        self.factKey = factKey
        self.subjectProductID = subjectProductID
        self.variantID = variantID
        self.factValue = factValue
        self.unit = unit
        self.sourceType = sourceType
        self.sourceURIOrLicensedDatasetID = sourceURIOrLicensedDatasetID
        self.licenseID = licenseID
        self.collectedAt = collectedAt
        self.effectiveFrom = effectiveFrom
        self.expiresAt = expiresAt
        self.region = region
        self.modelOrParserVersion = modelOrParserVersion
        self.confidenceKind = confidenceKind
        self.verificationMethod = verificationMethod
        self.userOverride = userOverride
        self.revocationTombstone = revocationTombstone
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", evidenceID = "evidence_id", factKey = "fact_key"
        case subjectProductID = "subject_product_id", variantID = "variant_id", factValue = "fact_value", unit
        case sourceType = "source_type", sourceURIOrLicensedDatasetID = "source_uri_or_licensed_dataset_id"
        case licenseID = "license_id", collectedAt = "collected_at", effectiveFrom = "effective_from"
        case expiresAt = "expires_at", region, modelOrParserVersion = "model_or_parser_version"
        case confidenceKind = "confidence_kind", verificationMethod = "verification_method"
        case userOverride = "user_override", revocationTombstone = "revocation_tombstone"
    }

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion,
              !evidenceID.isEmpty, !factKey.isEmpty, !subjectProductID.isEmpty, !sourceURIOrLicensedDatasetID.isEmpty,
              expiresAt.map({ $0 > collectedAt }) ?? true,
              // A record may not label itself verified unless it would pass `isDisplayableAsVerified` at collection time.
              confidenceKind != .verifiedFacts || isDisplayableAsVerified(at: collectedAt)
        else { throw .schemaInvalid }
    }

    /// INV-04 / §106.2: verified needs license, variant identity, real verification, an authoritative
    /// source type, and the fact must be in force and not revoked.
    public func isDisplayableAsVerified(at now: Date) -> Bool {
        guard let licenseID, !licenseID.isEmpty, let variantID, !variantID.isEmpty else { return false }
        guard [.licensedCatalog, .manufacturer].contains(sourceType), verificationMethod != .none else { return false }
        guard !revocationTombstone else { return false }
        if let effectiveFrom, now < effectiveFrom { return false }
        if let expiresAt, now >= expiresAt { return false }
        return true
    }
}
