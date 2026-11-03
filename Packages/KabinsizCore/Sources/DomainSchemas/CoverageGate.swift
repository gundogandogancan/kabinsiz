import DomainContracts
import Foundation
import SystemContracts

/// The rights a catalogue source granted (V18-04.3). A claim is only as good as the licence behind it:
/// outside its window, market or field set it says nothing.
public struct CatalogRightsV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public struct License: Codable, Hashable, Sendable {
        public var licenseID: String
        /// Brand owner or merchant ID that granted it.
        public var grantorID: String
        public var allowedAttributes: [ClaimEvidence.Attribute]
        public var countryScope: [String]
        public var validFrom: Date
        public var validUntil: Date
        public var imageRights: Bool
        public var derivative3DRights: Bool
        public var affiliateLinkRights: Bool
        public var offlineCacheRights: Bool
        public var revoked: Bool

        public init(licenseID: String, grantorID: String, allowedAttributes: [ClaimEvidence.Attribute], countryScope: [String],
                    validFrom: Date, validUntil: Date, imageRights: Bool = false, derivative3DRights: Bool = false,
                    affiliateLinkRights: Bool = false, offlineCacheRights: Bool = false, revoked: Bool = false) {
            self.licenseID = licenseID
            self.grantorID = grantorID
            self.allowedAttributes = allowedAttributes
            self.countryScope = countryScope
            self.validFrom = validFrom
            self.validUntil = validUntil
            self.imageRights = imageRights
            self.derivative3DRights = derivative3DRights
            self.affiliateLinkRights = affiliateLinkRights
            self.offlineCacheRights = offlineCacheRights
            self.revoked = revoked
        }

        enum CodingKeys: String, CodingKey {
            case licenseID = "license_id", grantorID = "grantor_id", allowedAttributes = "allowed_attributes"
            case countryScope = "country_scope", validFrom = "valid_from", validUntil = "valid_until", imageRights = "image_rights"
            case derivative3DRights = "derivative_3d_rights", affiliateLinkRights = "affiliate_link_rights"
            case offlineCacheRights = "offline_cache_rights", revoked
        }

        /// In force for this attribute in this market at `now`.
        public func covers(_ attribute: ClaimEvidence.Attribute, market: String, at now: Date) -> Bool {
            !revoked && now >= validFrom && now < validUntil && allowedAttributes.contains(attribute) && countryScope.contains(market)
                && (attribute != .media || imageRights)
        }

        public func isInForce(at now: Date) -> Bool { !revoked && now >= validFrom && now < validUntil }
    }

    public var schemaVersion: Int
    public var rightsRevision: Int
    public var licenses: [License]

    public init(rightsRevision: Int, licenses: [License]) {
        schemaVersion = Self.currentSchemaVersion
        self.rightsRevision = rightsRevision
        self.licenses = licenses
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", rightsRevision = "rights_revision", licenses
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && rightsRevision >= 1)
        try require(allUnique(licenses.map(\.licenseID)))
        for l in licenses {
            try require(allNonBlank([l.licenseID, l.grantorID]) && l.validUntil > l.validFrom)
            try require(!l.allowedAttributes.isEmpty && allUnique(l.allowedAttributes))
            try require(!l.countryScope.isEmpty && l.countryScope.allSatisfy(isMarketCode) && allUnique(l.countryScope))
            // A 3D derivative of a product image needs the image right first.
            if l.derivative3DRights { try require(l.imageRights) }
        }
    }

    public func license(_ id: String?) -> License? { id.flatMap { id in licenses.first { $0.licenseID == id } } }
}

/// R18-WP03: which product statements may be said, to whom, right now (V18-04.2, V18-08.1). Fails closed:
/// no source, an expired or out-of-scope licence, a revoked claim or two sources that disagree all mean
/// the statement is not made. `UNKNOWN` (nothing known) and `BLOCKED` (known but not sayable) stay apart.
public struct EvidenceCoverageGate: Sendable {
    public enum BlockReason: String, Codable, Sendable {
        case claimRevoked = "CLAIM_REVOKED", claimExpired = "CLAIM_EXPIRED", noLicense = "NO_LICENSE"
        case licenseExpiredOrRevoked = "LICENSE_EXPIRED_OR_REVOKED", outsideLicenseScope = "OUTSIDE_LICENSE_SCOPE"
        case evidenceMissing = "EVIDENCE_MISSING", evidenceWithdrawn = "EVIDENCE_WITHDRAWN", otherMarket = "OTHER_MARKET"
    }

    public enum AttributeStatus: Hashable, Sendable {
        /// Tier A/B, licensed, in force: may be stated as the product's fact.
        case fact(value: String, tier: SourceTier, claimIDs: [String])
        /// GS1 identity only (V18-T-003 VERIFIED_BASIC_IDENTITY).
        case basicIdentity(value: String, claimIDs: [String])
        /// The user's own reading; shown to them as theirs, never as brand truth.
        case userEvidence(value: String, claimIDs: [String])
        /// Demo data; always labelled SYNTHETIC_DEMO_ONLY.
        case synthetic(value: String, claimIDs: [String])
        /// V18-T-010: sources disagree → nothing is said and fit stops.
        case conflicting(claimIDs: [String])
        case blocked(BlockReason)
        case unknown

        public var confidence: ConfidenceKind {
            switch self {
            case .fact: .verifiedFacts
            case .basicIdentity, .userEvidence: .partial
            case .synthetic: .heuristic
            case .conflicting, .blocked, .unknown: .abstain
            }
        }

        public var sayableValue: String? {
            switch self {
            case .fact(let v, _, _), .basicIdentity(let v, _), .userEvidence(let v, _), .synthetic(let v, _): v
            case .conflicting, .blocked, .unknown: nil
            }
        }

        var isFact: Bool { if case .fact = self { true } else { false } }
        /// A fact, or GS1 basic identity: enough to name the variant, not to describe the garment.
        var namesVariant: Bool {
            switch self {
            case .fact, .basicIdentity: true
            default: false
            }
        }
        var isConflicting: Bool { if case .conflicting = self { true } else { false } }
    }

    /// V18-00.1 levels (plus V18-T-003's basic identity). `LIVE_PARTNER` is never derived from data:
    /// it needs a signed contract and a field test, so the gate does not produce it.
    public enum CoverageLevel: String, Codable, CaseIterable, Sendable {
        case universalSchemaSupported = "UNIVERSAL_SCHEMA_SUPPORTED", brandIdentifiable = "BRAND_IDENTIFIABLE"
        case verifiedBasicIdentity = "VERIFIED_BASIC_IDENTITY", variantVerified = "VARIANT_VERIFIED", fitEligible = "FIT_ELIGIBLE"
        case tryOnAssetReady = "TRYON_ASSET_READY", commerceEligible = "COMMERCE_ELIGIBLE"
    }

    public enum OfferStatus: String, Codable, Sendable {
        /// Price and stock are current facts; buying may be offered.
        case purchasable = "PURCHASABLE"
        /// V18-T-015: the offer aged out; shown as stale and closed for buying.
        case stale = "STALE"
        case notVerified = "NOT_VERIFIED"
    }

    public struct OfferCoverage: Hashable, Sendable {
        public let offerID: String
        public let status: OfferStatus
        /// V18-T-020: the affiliate link may be used. False → plain link or none; the style advice is unchanged.
        public let affiliateLinkAllowed: Bool
    }

    public struct Report: Sendable {
        public let variantID: String
        public let market: String
        public let attributes: [ClaimEvidence.Attribute: AttributeStatus]
        public let levels: Set<CoverageLevel>
        public let offers: [OfferCoverage]
        public let mayCacheOffline: Set<ClaimEvidence.Attribute>

        public func status(_ a: ClaimEvidence.Attribute) -> AttributeStatus { attributes[a] ?? .unknown }
        public var conflicts: [ClaimEvidence.Attribute] {
            attributes.filter(\.value.isConflicting).keys.sorted { $0.rawValue < $1.rawValue }
        }
    }

    public enum Revocation: Hashable, Sendable {
        /// V18-T-011: purge the cached value (and any image/3D derived from it) now.
        case purgeCachedClaim(claimID: String)
        case disableAffiliateLink(offerID: String)
    }

    public let graph: CommerceGraphV1
    public let registry: BrandRegistryV1
    public let rights: CatalogRightsV1
    private let evidence: [String: EvidenceRecord]

    /// Every input is validated first; one invalid input refuses the whole gate (fail closed).
    public init(graph: CommerceGraphV1, registry: BrandRegistryV1, rights: CatalogRightsV1, evidence: [EvidenceRecord]) throws(FaultCode) {
        try graph.validate(against: registry)
        try rights.validate()
        for e in evidence { try e.validate() }
        try require(allUnique(evidence.map(\.evidenceID)))
        self.graph = graph
        self.registry = registry
        self.rights = rights
        self.evidence = Dictionary(uniqueKeysWithValues: evidence.map { ($0.evidenceID, $0) })
    }

    // MARK: Claim evaluation

    private enum Verdict { case usable(String), blocked(BlockReason) }

    /// One claim on its own: is it in force, licensed for this attribute and market, and backed by evidence?
    private func verdict(_ c: ClaimEvidence, market: String, at now: Date) -> Verdict {
        switch c.revocationStatus {
        case .active: break
        case .revoked, .superseded: return .blocked(.claimRevoked)
        }
        if now < c.observedAt { return .blocked(.claimExpired) }
        if let until = c.validUntil, now >= until { return .blocked(.claimExpired) }
        if let m = c.market, m != market { return .blocked(.otherMarket) }
        guard let record = evidence[c.evidenceID] else { return .blocked(.evidenceMissing) }
        if record.revocationTombstone { return .blocked(.evidenceWithdrawn) }
        if let from = record.effectiveFrom, now < from { return .blocked(.evidenceWithdrawn) }
        if let until = record.expiresAt, now >= until { return .blocked(.evidenceWithdrawn) }
        // Brand, retailer and GS1 data are only usable under a licence; the user's own reading and demo data are not licensed data.
        if c.sourceTier <= .c {
            guard let license = rights.license(c.licenseID) else { return .blocked(.noLicense) }
            guard license.isInForce(at: now) else { return .blocked(.licenseExpiredOrRevoked) }
            guard license.covers(c.attribute, market: market, at: now) else { return .blocked(.outsideLicenseScope) }
        }
        return .usable(Self.normalized(record))
    }

    static func normalized(_ r: EvidenceRecord) -> String {
        let value = r.factValue.split(whereSeparator: \.isWhitespace).joined(separator: " ").uppercased(with: Locale(identifier: "en_US_POSIX"))
        return r.unit.map { "\(value) \($0.lowercased())" } ?? value
    }

    /// The variant's own claims plus those on its colourway and style model (composition is usually stated per model).
    private func claims(for variant: CommerceGraphV1.SizeVariant) -> [ClaimEvidence] {
        let colorway = graph.colorways.first { $0.colorwayID == variant.colorwayID }
        let subjects = Set([variant.variantID, variant.colorwayID] + (colorway.map { [$0.styleModelID] } ?? []))
        return graph.claims.filter { subjects.contains($0.subjectID) && $0.level != .offer }
    }

    private func status(of claims: [ClaimEvidence], market: String, at now: Date) -> AttributeStatus {
        guard !claims.isEmpty else { return .unknown }
        var usable: [(ClaimEvidence, String)] = []
        var reasons: [BlockReason] = []
        for c in claims {
            switch verdict(c, market: market, at: now) {
            case .usable(let v): usable.append((c, v))
            case .blocked(let r): reasons.append(r)
            }
        }
        guard !usable.isEmpty else { return .blocked(reasons.first!) }
        // Any two live sources that disagree, whoever they are, stop the statement (V18-04.4).
        if Set(usable.map(\.1)).count > 1 { return .conflicting(claimIDs: usable.map(\.0.claimID).sorted()) }
        let value = usable[0].1
        let best = usable.map(\.0.sourceTier).min()!
        let ids = usable.filter { $0.0.sourceTier == best }.map(\.0.claimID).sorted()
        switch best {
        case .a, .b: return .fact(value: value, tier: best, claimIDs: ids)
        case .c: return .basicIdentity(value: value, claimIDs: ids)
        case .d: return .userEvidence(value: value, claimIDs: ids)
        case .synthetic: return .synthetic(value: value, claimIDs: ids)
        }
    }

    // MARK: Report

    public func coverage(variantID: String, market: String, at now: Date) throws(FaultCode) -> Report {
        try require(isMarketCode(market))
        guard let variant = graph.sizeVariants.first(where: { $0.variantID == variantID }) else { throw .schemaInvalid }
        let all = claims(for: variant)
        var attributes: [ClaimEvidence.Attribute: AttributeStatus] = [:]
        var cache = Set<ClaimEvidence.Attribute>()
        for a in ClaimEvidence.Attribute.allCases where a != .price && a != .stock {
            let s = status(of: all.filter { $0.attribute == a }, market: market, at: now)
            attributes[a] = s
            if case .fact(_, _, let ids) = s,
               ids.allSatisfy({ id in rights.license(graph.claims.first { $0.claimID == id }?.licenseID)?.offlineCacheRights ?? false }) {
                cache.insert(a)
            }
        }

        var levels: Set<CoverageLevel> = [.universalSchemaSupported, .brandIdentifiable]
        let identity = attributes[.identity] ?? .unknown
        if case .basicIdentity = identity { levels.insert(.verifiedBasicIdentity) }
        let named = [ClaimEvidence.Attribute.sizeLabel, .color].allSatisfy { attributes[$0]?.namesVariant ?? false }
        if identity.isFact && named { levels.insert(.variantVerified) }
        let measured = [ClaimEvidence.Attribute.finishedMeasurement, .bodySizeChart].contains { attributes[$0]?.isFact ?? false }
        let anyConflict = [ClaimEvidence.Attribute.finishedMeasurement, .bodySizeChart, .composition].contains { attributes[$0]?.isConflicting ?? false }
        if levels.contains(.variantVerified) && measured && !anyConflict { levels.insert(.fitEligible) }
        if case .fact(_, _, let ids) = attributes[.media] ?? .unknown,
           ids.allSatisfy({ id in rights.license(graph.claims.first { $0.claimID == id }?.licenseID)?.derivative3DRights ?? false }) {
            levels.insert(.tryOnAssetReady)
        }

        let offers = graph.offers(for: variantID).filter { $0.market == market }.map { offerCoverage($0, at: now) }
        if levels.contains(.variantVerified) && offers.contains(where: { $0.status == .purchasable }) { levels.insert(.commerceEligible) }
        return Report(variantID: variantID, market: market, attributes: attributes, levels: levels, offers: offers, mayCacheOffline: cache)
    }

    private func offerCoverage(_ o: Offer, at now: Date) -> OfferCoverage {
        let claims = o.claimIDs.compactMap { id in graph.claims.first { $0.claimID == id } }
        let price = status(of: claims.filter { $0.attribute == .price }, market: o.market, at: now)
        let stock = status(of: claims.filter { $0.attribute == .stock }, market: o.market, at: now)
        let current = o.isPriceCurrent(at: now) && [.availableVerified, .limitedVerified].contains(o.stock(at: now))
        let status: OfferStatus
        if price.isFact && stock.isFact && current {
            status = .purchasable
        } else if o.validUntil.map({ now >= $0 }) ?? false {
            status = .stale
        } else {
            status = .notVerified
        }
        let affiliate = o.isAffiliateLink && status == .purchasable && claims.contains { c in
            rights.license(c.licenseID).map { $0.affiliateLinkRights && $0.isInForce(at: now) } ?? false
        }
        return OfferCoverage(offerID: o.offerID, status: status, affiliateLinkAllowed: affiliate)
    }

    /// Everything that must be undone now because a licence or claim ended (V18-T-011, V18-T-020).
    public func revocations(at now: Date) -> [Revocation] {
        var out: [Revocation] = []
        for c in graph.claims where c.sourceTier <= .c {
            let license = rights.license(c.licenseID)
            let ended = c.revocationStatus != .active || c.validUntil.map { now >= $0 } ?? false || license.map { !$0.isInForce(at: now) } ?? true
            if ended { out.append(.purgeCachedClaim(claimID: c.claimID)) }
        }
        for o in graph.offers where o.isAffiliateLink {
            if !offerCoverage(o, at: now).affiliateLinkAllowed { out.append(.disableAffiliateLink(offerID: o.offerID)) }
        }
        return out
    }
}
