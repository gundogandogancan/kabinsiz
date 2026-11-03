import Foundation
import SystemContracts

/// V18-04.2 source tiers. Tier decides what a claim may be presented as, not how it looks.
public enum SourceTier: String, Codable, CaseIterable, Comparable, Sendable {
    /// Signed, licensed data from the brand or manufacturer.
    case a = "TIER_A_BRAND_SIGNED"
    /// Contracted retailer or authorised marketplace feed.
    case b = "TIER_B_AUTHORIZED_RETAIL"
    /// GS1 identity only: never measurements, material or stock.
    case c = "TIER_C_GS1_IDENTITY"
    /// Local OCR or what the user typed: user evidence, never brand truth for anyone else.
    case d = "TIER_D_USER_OR_OCR"
    case synthetic = "SYNTHETIC_DEMO"

    private var rank: Int { [.a: 0, .b: 1, .c: 2, .d: 3, .synthetic: 4][self]! }
    public static func < (l: Self, r: Self) -> Bool { l.rank < r.rank }
}

/// Who owns which brand where (V18-01.1, V18-04.1). A brand name is not one thing: owner, local licensee
/// and sellers are separate entries and ownership can change.
public struct BrandRegistryV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public struct Owner: Codable, Hashable, Sendable {
        public var ownerID: String
        public var legalName: String
        public var sourceClaimID: String
        public init(ownerID: String, legalName: String, sourceClaimID: String) {
            self.ownerID = ownerID
            self.legalName = legalName
            self.sourceClaimID = sourceClaimID
        }
        enum CodingKeys: String, CodingKey { case ownerID = "owner_id", legalName = "legal_name", sourceClaimID = "source_claim_id" }
    }

    public struct Licensee: Codable, Hashable, Sendable {
        public var market: String
        public var ownerID: String
        public init(market: String, ownerID: String) {
            self.market = market
            self.ownerID = ownerID
        }
        enum CodingKeys: String, CodingKey { case market, ownerID = "owner_id" }
    }

    public struct Brand: Codable, Hashable, Sendable {
        public var brandID: String
        public var displayName: String
        public var ownerID: String
        public var localLicensees: [Licensee]
        public var markets: [String]
        public var sourceTier: SourceTier
        public init(brandID: String, displayName: String, ownerID: String, localLicensees: [Licensee] = [], markets: [String], sourceTier: SourceTier) {
            self.brandID = brandID
            self.displayName = displayName
            self.ownerID = ownerID
            self.localLicensees = localLicensees
            self.markets = markets
            self.sourceTier = sourceTier
        }
        enum CodingKeys: String, CodingKey {
            case brandID = "brand_id", displayName = "display_name", ownerID = "owner_id", localLicensees = "local_licensees"
            case markets, sourceTier = "source_tier"
        }
    }

    public var schemaVersion: Int
    public var registryRevision: Int
    public var owners: [Owner]
    public var brands: [Brand]

    public init(registryRevision: Int, owners: [Owner], brands: [Brand]) {
        schemaVersion = Self.currentSchemaVersion
        self.registryRevision = registryRevision
        self.owners = owners
        self.brands = brands
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", registryRevision = "registry_revision", owners, brands
    }

    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && registryRevision >= 1)
        let ownerIDs = Set(owners.map(\.ownerID))
        try require(allUnique(owners.map(\.ownerID)) && allUnique(brands.map(\.brandID)))
        try require(owners.allSatisfy { allNonBlank([$0.ownerID, $0.legalName, $0.sourceClaimID]) })
        for b in brands {
            try require(allNonBlank([b.brandID, b.displayName]) && ownerIDs.contains(b.ownerID))
            try require(!b.markets.isEmpty && b.markets.allSatisfy(isMarketCode) && allUnique(b.markets))
            try require(b.sourceTier != .d)
            // A local licensee is a different legal entity from the owner, in a market the brand is in.
            try require(allUnique(b.localLicensees.map(\.market)))
            try require(b.localLicensees.allSatisfy { ownerIDs.contains($0.ownerID) && $0.ownerID != b.ownerID && b.markets.contains($0.market) })
        }
    }

    public func brand(_ id: String) -> Brand? { brands.first { $0.brandID == id } }
}

/// Typed identifiers. GTIN, the manufacturer's style code and a merchant's SKU live in different
/// namespaces (V18-04.1); the same string in two namespaces is two different things.
public struct ProductIdentifier: Codable, Hashable, Sendable {
    public enum Namespace: String, Codable, CaseIterable, Sendable {
        case gtin = "GTIN", manufacturerStyleCode = "MANUFACTURER_STYLE_CODE", merchantSku = "MERCHANT_SKU", partnerVariantID = "PARTNER_VARIANT_ID"
        /// A merchant or partner code means something only together with who issued it.
        var needsIssuer: Bool { self == .merchantSku || self == .partnerVariantID }
    }

    public var namespace: Namespace
    public var value: String
    /// Merchant ID for a merchant SKU or partner variant ID; nil otherwise.
    public var issuer: String?

    public init(_ namespace: Namespace, _ value: String, issuer: String? = nil) {
        self.namespace = namespace
        self.value = value
        self.issuer = issuer
    }

    var key: String { "\(namespace.rawValue)|\(issuer ?? "")|\(value)" }
}

/// The claim behind one attribute of one node (V18-04.1 "Claims").
public struct ClaimEvidence: Codable, Hashable, Sendable {
    public enum Attribute: String, Codable, CaseIterable, Sendable {
        case identity = "IDENTITY", sizeLabel = "SIZE_LABEL", color = "COLOR", ownership = "OWNERSHIP"
        case bodySizeChart = "BODY_SIZE_CHART", finishedMeasurement = "FINISHED_MEASUREMENT"
        case composition = "COMPOSITION", care = "CARE", price = "PRICE", stock = "STOCK", media = "MEDIA"

        /// What GS1 data can actually carry (V18-01.3 3).
        var isIdentityLevel: Bool { [.identity, .sizeLabel, .color].contains(self) }
    }

    public enum ClaimedBy: String, Codable, CaseIterable, Sendable {
        case brandOwner = "BRAND_OWNER", brand = "BRAND", retailer = "RETAILER", marketplace = "MARKETPLACE"
        case gs1 = "GS1", user = "USER", synthetic = "SYNTHETIC"

        /// The only tier this kind of claimant can produce.
        var tier: SourceTier {
            switch self {
            case .brandOwner, .brand: .a
            case .retailer, .marketplace: .b
            case .gs1: .c
            case .user: .d
            case .synthetic: .synthetic
            }
        }
    }

    public enum Level: String, Codable, CaseIterable, Sendable {
        case brand = "BRAND", collection = "COLLECTION", styleModel = "STYLE_MODEL", colorway = "COLORWAY"
        case sizeVariant = "SIZE_VARIANT", merchant = "MERCHANT", offer = "OFFER"
    }

    public enum Revocation: String, Codable, CaseIterable, Sendable { case active = "ACTIVE", revoked = "REVOKED", superseded = "SUPERSEDED" }

    public enum Translation: String, Codable, CaseIterable, Sendable {
        case original = "ORIGINAL", humanTranslated = "HUMAN_TRANSLATED", machineTranslated = "MACHINE_TRANSLATED"
    }

    public var claimID: String
    public var subjectID: String
    public var level: Level
    public var attribute: Attribute
    public var claimedBy: ClaimedBy
    public var sourceTier: SourceTier
    public var sourceURI: String
    public var licenseID: String?
    public var market: String?
    public var observedAt: Date
    public var validUntil: Date?
    public var revision: Int
    /// The `EvidenceRecord` holding the value itself.
    public var evidenceID: String
    public var revocationStatus: Revocation
    public var translationProvenance: Translation

    public init(claimID: String, subjectID: String, level: Level, attribute: Attribute, claimedBy: ClaimedBy, sourceTier: SourceTier,
                sourceURI: String, licenseID: String?, market: String? = nil, observedAt: Date, validUntil: Date?, revision: Int,
                evidenceID: String, revocationStatus: Revocation = .active, translationProvenance: Translation = .original) {
        self.claimID = claimID
        self.subjectID = subjectID
        self.level = level
        self.attribute = attribute
        self.claimedBy = claimedBy
        self.sourceTier = sourceTier
        self.sourceURI = sourceURI
        self.licenseID = licenseID
        self.market = market
        self.observedAt = observedAt
        self.validUntil = validUntil
        self.revision = revision
        self.evidenceID = evidenceID
        self.revocationStatus = revocationStatus
        self.translationProvenance = translationProvenance
    }

    enum CodingKeys: String, CodingKey {
        case claimID = "claim_id", subjectID = "subject_id", level, attribute, claimedBy = "claimed_by", sourceTier = "source_tier"
        case sourceURI = "source_uri", licenseID = "license_id", market, observedAt = "observed_at", validUntil = "valid_until"
        case revision, evidenceID = "evidence_id", revocationStatus = "revocation_status", translationProvenance = "translation_provenance"
    }

    func validate() throws(FaultCode) {
        try require(allNonBlank([claimID, subjectID, sourceURI, evidenceID]) && revision >= 1)
        try require(claimedBy.tier == sourceTier)
        if let licenseID { try require(!licenseID.isBlank) }
        if let market { try require(isMarketCode(market)) }
        if let validUntil { try require(validUntil > observedAt) }
        if sourceTier == .c { try require(attribute.isIdentityLevel) }
    }

    /// May be shown as the brand's or seller's fact: tier A/B, licensed, active and in force.
    public func isServableAsFact(at now: Date) -> Bool {
        guard sourceTier <= .b, revocationStatus == .active, let licenseID, !licenseID.isBlank, now >= observedAt else { return false }
        if let validUntil, now >= validUntil { return false }
        return true
    }
}

/// One seller's terms for one variant (V18-04.1 "Offer"). Separate from the product: the same variant
/// has many offers, and an offer's price and stock age.
public struct Offer: Codable, Hashable, Sendable {
    public enum Stock: String, Codable, CaseIterable, Sendable {
        case availableVerified = "AVAILABLE_VERIFIED", limitedVerified = "LIMITED_VERIFIED", outOfStock = "OUT_OF_STOCK", unknown = "UNKNOWN"
        var isVerifiedPresence: Bool { self == .availableVerified || self == .limitedVerified }
    }

    public var offerID: String
    public var variantID: String
    public var merchantID: String
    public var market: String
    /// Minor units (kuruş, cent). Money is never a floating-point number.
    public var priceMinor: Int?
    public var currency: String?
    public var stock: Stock
    public var observedAt: Date
    public var validUntil: Date?
    public var isAffiliateLink: Bool
    public var isSponsored: Bool
    public var claimIDs: [String]

    public init(offerID: String, variantID: String, merchantID: String, market: String, priceMinor: Int?, currency: String?, stock: Stock,
                observedAt: Date, validUntil: Date?, isAffiliateLink: Bool, isSponsored: Bool, claimIDs: [String]) {
        self.offerID = offerID
        self.variantID = variantID
        self.merchantID = merchantID
        self.market = market
        self.priceMinor = priceMinor
        self.currency = currency
        self.stock = stock
        self.observedAt = observedAt
        self.validUntil = validUntil
        self.isAffiliateLink = isAffiliateLink
        self.isSponsored = isSponsored
        self.claimIDs = claimIDs
    }

    enum CodingKeys: String, CodingKey {
        case offerID = "offer_id", variantID = "variant_id", merchantID = "merchant_id", market, priceMinor = "price_minor", currency
        case stock, observedAt = "observed_at", validUntil = "valid_until", isAffiliateLink = "is_affiliate_link"
        case isSponsored = "is_sponsored", claimIDs = "claim_ids"
    }

    func validate() throws(FaultCode) {
        try require(allNonBlank([offerID, variantID, merchantID]) && isMarketCode(market))
        try require((priceMinor == nil) == (currency == nil))
        if let priceMinor { try require(priceMinor > 0) }
        if let currency { try require(isCurrencyCode(currency)) }
        if let validUntil { try require(validUntil > observedAt) }
        // "In stock" must carry how long it holds; an open-ended verified stock claim is refused.
        if stock.isVerifiedPresence { try require(validUntil != nil) }
        try require(allNonBlank(claimIDs) && allUnique(claimIDs))
    }

    /// Stock as it may be shown now. A verified claim that has aged out is `UNKNOWN`, never still "in stock".
    public func stock(at now: Date) -> Stock {
        guard now >= observedAt else { return .unknown }
        if let validUntil, now >= validUntil { return .unknown }
        return stock
    }

    public func isPriceCurrent(at now: Date) -> Bool {
        guard priceMinor != nil, now >= observedAt else { return false }
        if let validUntil { return now < validUntil }
        return false
    }
}

/// The canonical commerce graph (V18-04.1): Brand → Collection → StyleModel → Colorway → SizeVariant → Offer
/// ← Merchant. Each node's claims are separate `ClaimEvidence` entries with their own rights and age.
public struct CommerceGraphV1: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public struct Collection: Codable, Hashable, Sendable {
        public var collectionID: String
        public var brandID: String
        public var season: String?
        public init(collectionID: String, brandID: String, season: String? = nil) {
            self.collectionID = collectionID
            self.brandID = brandID
            self.season = season
        }
        enum CodingKeys: String, CodingKey { case collectionID = "collection_id", brandID = "brand_id", season }
    }

    public struct StyleModel: Codable, Hashable, Sendable {
        public var styleModelID: String
        public var brandID: String
        public var collectionID: String?
        public var manufacturerStyleCode: String
        public var category: String
        public init(styleModelID: String, brandID: String, collectionID: String? = nil, manufacturerStyleCode: String, category: String) {
            self.styleModelID = styleModelID
            self.brandID = brandID
            self.collectionID = collectionID
            self.manufacturerStyleCode = manufacturerStyleCode
            self.category = category
        }
        enum CodingKeys: String, CodingKey {
            case styleModelID = "style_model_id", brandID = "brand_id", collectionID = "collection_id"
            case manufacturerStyleCode = "manufacturer_style_code", category
        }
    }

    public struct Colorway: Codable, Hashable, Sendable {
        public var colorwayID: String
        public var styleModelID: String
        public var colorName: String
        public init(colorwayID: String, styleModelID: String, colorName: String) {
            self.colorwayID = colorwayID
            self.styleModelID = styleModelID
            self.colorName = colorName
        }
        enum CodingKeys: String, CodingKey { case colorwayID = "colorway_id", styleModelID = "style_model_id", colorName = "color_name" }
    }

    /// `ProductVariant` of R18-WP02: one colour in one size. The size label and its system are separate.
    public struct SizeVariant: Codable, Hashable, Sendable {
        public var variantID: String
        public var colorwayID: String
        public var sizeLabel: String
        public var sizeSystem: String
        public var identifiers: [ProductIdentifier]
        public init(variantID: String, colorwayID: String, sizeLabel: String, sizeSystem: String, identifiers: [ProductIdentifier]) {
            self.variantID = variantID
            self.colorwayID = colorwayID
            self.sizeLabel = sizeLabel
            self.sizeSystem = sizeSystem
            self.identifiers = identifiers
        }
        enum CodingKeys: String, CodingKey {
            case variantID = "variant_id", colorwayID = "colorway_id", sizeLabel = "size_label", sizeSystem = "size_system", identifiers
        }
    }

    public struct Merchant: Codable, Hashable, Sendable {
        public var merchantID: String
        public var displayName: String
        public var markets: [String]
        public init(merchantID: String, displayName: String, markets: [String]) {
            self.merchantID = merchantID
            self.displayName = displayName
            self.markets = markets
        }
        enum CodingKeys: String, CodingKey { case merchantID = "merchant_id", displayName = "display_name", markets }
    }

    public var schemaVersion: Int
    public var graphRevision: Int
    public var collections: [Collection]
    public var styleModels: [StyleModel]
    public var colorways: [Colorway]
    public var sizeVariants: [SizeVariant]
    public var merchants: [Merchant]
    public var offers: [Offer]
    public var claims: [ClaimEvidence]

    public init(graphRevision: Int, collections: [Collection], styleModels: [StyleModel], colorways: [Colorway], sizeVariants: [SizeVariant],
                merchants: [Merchant], offers: [Offer], claims: [ClaimEvidence]) {
        schemaVersion = Self.currentSchemaVersion
        self.graphRevision = graphRevision
        self.collections = collections
        self.styleModels = styleModels
        self.colorways = colorways
        self.sizeVariants = sizeVariants
        self.merchants = merchants
        self.offers = offers
        self.claims = claims
    }

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", graphRevision = "graph_revision", collections, styleModels = "style_models"
        case colorways, sizeVariants = "size_variants", merchants, offers, claims
    }

    /// Internal integrity: unique IDs, every reference resolves to the right kind of node, identifiers in
    /// their own namespace, GTIN canonical and owned by one variant, claims attached to existing nodes.
    public func validate() throws(FaultCode) {
        try require(schemaVersion == Self.currentSchemaVersion && graphRevision >= 1)
        let collectionIDs = Set(collections.map(\.collectionID)), modelIDs = Set(styleModels.map(\.styleModelID))
        let colorwayIDs = Set(colorways.map(\.colorwayID)), variantIDs = Set(sizeVariants.map(\.variantID))
        let merchantIDs = Set(merchants.map(\.merchantID)), offerIDs = Set(offers.map(\.offerID))
        let claimIDs = Set(claims.map(\.claimID))
        try require(collectionIDs.count == collections.count && modelIDs.count == styleModels.count && colorwayIDs.count == colorways.count)
        try require(variantIDs.count == sizeVariants.count && merchantIDs.count == merchants.count && offerIDs.count == offers.count)
        try require(claimIDs.count == claims.count)
        // One ID names one node, whatever its kind.
        try require(allUnique([collectionIDs, modelIDs, colorwayIDs, variantIDs, merchantIDs, offerIDs].flatMap { $0 }))

        for c in collections { try require(allNonBlank([c.collectionID, c.brandID])) }
        for m in styleModels {
            try require(allNonBlank([m.styleModelID, m.brandID, m.manufacturerStyleCode, m.category]))
            if let c = m.collectionID {
                try require(collections.first { $0.collectionID == c }?.brandID == m.brandID)
            }
        }
        for c in colorways { try require(allNonBlank([c.colorwayID, c.colorName]) && modelIDs.contains(c.styleModelID)) }
        for v in sizeVariants {
            try require(allNonBlank([v.variantID, v.sizeLabel, v.sizeSystem]) && colorwayIDs.contains(v.colorwayID))
            for id in v.identifiers {
                try require(!id.value.isBlank)
                if id.namespace.needsIssuer {
                    try require(id.issuer.map(merchantIDs.contains) ?? false)
                } else {
                    try require(id.issuer == nil)
                }
                if id.namespace == .gtin { try require(GTIN.normalized(id.value) == id.value) }
            }
        }
        // A GTIN or a merchant's SKU points at one variant; two would make a scan ambiguous by design.
        try require(allUnique(sizeVariants.flatMap { v in v.identifiers.filter { $0.namespace != .manufacturerStyleCode }.map(\.key) }))
        for m in merchants {
            try require(allNonBlank([m.merchantID, m.displayName]) && !m.markets.isEmpty && m.markets.allSatisfy(isMarketCode))
        }
        for o in offers {
            try o.validate()
            try require(variantIDs.contains(o.variantID) && merchantIDs.contains(o.merchantID))
            try require(merchants.first { $0.merchantID == o.merchantID }!.markets.contains(o.market))
            try require(o.claimIDs.allSatisfy(claimIDs.contains))
        }
        for claim in claims {
            try claim.validate()
            let exists: Bool = switch claim.level {
            case .brand: collections.contains { $0.brandID == claim.subjectID } || styleModels.contains { $0.brandID == claim.subjectID }
            case .collection: collectionIDs.contains(claim.subjectID)
            case .styleModel: modelIDs.contains(claim.subjectID)
            case .colorway: colorwayIDs.contains(claim.subjectID)
            case .sizeVariant: variantIDs.contains(claim.subjectID)
            case .merchant: merchantIDs.contains(claim.subjectID)
            case .offer: offerIDs.contains(claim.subjectID)
            }
            try require(exists)
            // Price and stock are offer facts; never claimed on the product itself.
            if claim.attribute == .price || claim.attribute == .stock { try require(claim.level == .offer) }
        }
    }

    /// Cross-check against the brand registry: every brand the graph uses is registered.
    public func validate(against registry: BrandRegistryV1) throws(FaultCode) {
        try validate()
        try registry.validate()
        let brands = Set(registry.brands.map(\.brandID))
        try require(collections.allSatisfy { brands.contains($0.brandID) } && styleModels.allSatisfy { brands.contains($0.brandID) })
    }

    public func offers(for variantID: String) -> [Offer] { offers.filter { $0.variantID == variantID } }

    public func variant(gtin: String) -> SizeVariant? {
        guard let canonical = GTIN.normalized(gtin) else { return nil }
        return sizeVariants.first { $0.identifiers.contains(ProductIdentifier(.gtin, canonical)) }
    }

    public func claims(about subjectID: String) -> [ClaimEvidence] { claims.filter { $0.subjectID == subjectID } }
}
