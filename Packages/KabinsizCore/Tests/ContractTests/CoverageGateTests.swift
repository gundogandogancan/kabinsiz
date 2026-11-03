import DomainContracts
@testable import DomainSchemas
import Foundation
import SystemContracts
import Testing

/// A small licensed world (all SYNTHETIC_DEMO_ONLY values, but tiered as if real) to drive the gate.
private struct World {
    static let t0 = Goldens.t0
    static func t(_ h: Double) -> Date { Goldens.t(h) }

    var registry = BrandRegistryV1(
        registryRevision: 1,
        owners: [.init(ownerID: "own-a", legalName: "Örnek Sahip A.Ş. (SYNTHETIC_DEMO_ONLY)", sourceClaimID: "c-owner")],
        brands: [.init(brandID: "brand-a", displayName: "Örnek A", ownerID: "own-a", markets: ["TR", "DE"], sourceTier: .a)]
    )
    var graph = CommerceGraphV1(
        graphRevision: 1, collections: [],
        styleModels: [.init(styleModelID: "m1", brandID: "brand-a", manufacturerStyleCode: "A-100", category: "BOTTOM")],
        colorways: [.init(colorwayID: "cw1", styleModelID: "m1", colorName: "Mavi")],
        sizeVariants: [
            .init(variantID: "v-m", colorwayID: "cw1", sizeLabel: "M", sizeSystem: "EU-ALPHA", identifiers: [.init(.gtin, "02000001000014")]),
            .init(variantID: "v-l", colorwayID: "cw1", sizeLabel: "L", sizeSystem: "EU-ALPHA", identifiers: [.init(.gtin, "02000001000021")]),
        ],
        merchants: [.init(merchantID: "mer-tr", displayName: "Mağaza TR", markets: ["TR"]),
                    .init(merchantID: "mer-de", displayName: "Laden DE", markets: ["DE"])],
        offers: [
            .init(offerID: "o-tr", variantID: "v-m", merchantID: "mer-tr", market: "TR", priceMinor: 199_900, currency: "TRY",
                  stock: .availableVerified, observedAt: t(0), validUntil: t(6), isAffiliateLink: true, isSponsored: false,
                  claimIDs: ["c-price-tr", "c-stock-tr"]),
            .init(offerID: "o-de", variantID: "v-m", merchantID: "mer-de", market: "DE", priceMinor: 4_999, currency: "EUR",
                  stock: .availableVerified, observedAt: t(0), validUntil: t(6), isAffiliateLink: false, isSponsored: false,
                  claimIDs: ["c-price-de", "c-stock-de"]),
        ],
        claims: []
    )
    var rights = CatalogRightsV1(rightsRevision: 1, licenses: [
        .init(licenseID: "lic-brand", grantorID: "own-a",
              allowedAttributes: [.identity, .sizeLabel, .color, .finishedMeasurement, .bodySizeChart, .composition, .media],
              countryScope: ["TR", "DE"], validFrom: t(-100), validUntil: t(100), imageRights: true, derivative3DRights: true,
              offlineCacheRights: true),
        .init(licenseID: "lic-retail-tr", grantorID: "mer-tr", allowedAttributes: [.price, .stock], countryScope: ["TR"],
              validFrom: t(-100), validUntil: t(50), affiliateLinkRights: true),
        .init(licenseID: "lic-retail-de", grantorID: "mer-de", allowedAttributes: [.price, .stock], countryScope: ["DE"],
              validFrom: t(-100), validUntil: t(50)),
        .init(licenseID: "lic-gs1", grantorID: "gs1", allowedAttributes: [.identity, .sizeLabel, .color], countryScope: ["TR"],
              validFrom: t(-100), validUntil: t(100)),
    ])
    var evidence: [EvidenceRecord] = []

    init() {
        brand("c-id", "v-m", .sizeVariant, .identity, "A-100 Mavi M")
        brand("c-size", "v-m", .sizeVariant, .sizeLabel, "M")
        brand("c-color", "cw1", .colorway, .color, "Mavi")
        brand("c-fin", "v-m", .sizeVariant, .finishedMeasurement, "waist_flat 41", unit: "cm")
        brand("c-comp", "m1", .styleModel, .composition, "COTTON:98, ELASTANE:2")
        brand("c-media", "m1", .styleModel, .media, "asset-a-100-r3")
        add(.init(claimID: "c-price-tr", subjectID: "o-tr", level: .offer, attribute: .price, claimedBy: .retailer, sourceTier: .b,
                  sourceURI: "feed-tr", licenseID: "lic-retail-tr", market: "TR", observedAt: Self.t(0), validUntil: Self.t(6), revision: 1,
                  evidenceID: "e-price-tr"), "199900", unit: "TRY_MINOR")
        add(.init(claimID: "c-stock-tr", subjectID: "o-tr", level: .offer, attribute: .stock, claimedBy: .retailer, sourceTier: .b,
                  sourceURI: "feed-tr", licenseID: "lic-retail-tr", market: "TR", observedAt: Self.t(0), validUntil: Self.t(6), revision: 1,
                  evidenceID: "e-stock-tr"), "AVAILABLE")
        add(.init(claimID: "c-price-de", subjectID: "o-de", level: .offer, attribute: .price, claimedBy: .retailer, sourceTier: .b,
                  sourceURI: "feed-de", licenseID: "lic-retail-de", market: "DE", observedAt: Self.t(0), validUntil: Self.t(6), revision: 1,
                  evidenceID: "e-price-de"), "4999", unit: "EUR_MINOR")
        add(.init(claimID: "c-stock-de", subjectID: "o-de", level: .offer, attribute: .stock, claimedBy: .retailer, sourceTier: .b,
                  sourceURI: "feed-de", licenseID: "lic-retail-de", market: "DE", observedAt: Self.t(0), validUntil: Self.t(6), revision: 1,
                  evidenceID: "e-stock-de"), "AVAILABLE")
    }

    mutating func brand(_ id: String, _ subject: String, _ level: ClaimEvidence.Level, _ attribute: ClaimEvidence.Attribute,
                        _ value: String, unit: String? = nil, license: String? = "lic-brand") {
        add(.init(claimID: id, subjectID: subject, level: level, attribute: attribute, claimedBy: .brand, sourceTier: .a,
                  sourceURI: "brand-feed", licenseID: license, observedAt: Self.t(-1), validUntil: nil, revision: 1,
                  evidenceID: "e-\(id)"), value, unit: unit)
    }

    mutating func add(_ claim: ClaimEvidence, _ value: String, unit: String? = nil) {
        graph.claims.append(claim)
        evidence.append(EvidenceRecord(
            evidenceID: claim.evidenceID, factKey: claim.attribute.rawValue, subjectProductID: "m1", variantID: nil, factValue: value,
            unit: unit, sourceType: claim.sourceTier == .d ? .userEntered : .syntheticFixture, sourceURIOrLicensedDatasetID: claim.sourceURI,
            licenseID: claim.licenseID, collectedAt: claim.observedAt, confidenceKind: .heuristic, verificationMethod: .none
        ))
    }

    func gate() throws -> EvidenceCoverageGate {
        try EvidenceCoverageGate(graph: graph, registry: registry, rights: rights, evidence: evidence)
    }

    func report(_ variant: String = "v-m", _ market: String = "TR", at hours: Double = 1) throws -> EvidenceCoverageGate.Report {
        try gate().coverage(variantID: variant, market: market, at: Self.t(hours))
    }
}

@Suite("R18-WP03 EvidenceCoverageGate")
struct CoverageGateTests {
    @Test("Fully licensed variant: every level the data can prove, never LIVE_PARTNER")
    func fullCoverage() throws {
        let r = try World().report()
        #expect(r.levels == [.universalSchemaSupported, .brandIdentifiable, .variantVerified, .fitEligible, .tryOnAssetReady, .commerceEligible])
        #expect(!EvidenceCoverageGate.CoverageLevel.allCases.map(\.rawValue).contains("LIVE_PARTNER"))
        #expect(r.status(.identity) == .fact(value: "A-100 MAVI M", tier: .a, claimIDs: ["c-id"]))
        #expect(r.status(.composition).sayableValue == "COTTON:98, ELASTANE:2", "model-level claim reaches the variant")
        #expect(r.status(.color).confidence == .verifiedFacts)
        #expect(r.status(.care) == .unknown)
        #expect(r.offers == [.init(offerID: "o-tr", status: .purchasable, affiliateLinkAllowed: true)])
        #expect(r.mayCacheOffline.contains(.identity) && r.mayCacheOffline.contains(.media))
    }

    @Test("V18-T-003: GTIN known only through GS1 → basic identity; size, fit and material stay unknown")
    func gs1Only() throws {
        var w = World()
        w.graph.claims.removeAll { $0.level != .offer }
        w.evidence.removeAll { !$0.evidenceID.contains("price") && !$0.evidenceID.contains("stock") }
        for (id, attr, value) in [("g-id", ClaimEvidence.Attribute.identity, "A-100"), ("g-size", .sizeLabel, "M"), ("g-color", .color, "Mavi")] {
            w.add(.init(claimID: id, subjectID: "v-m", level: .sizeVariant, attribute: attr, claimedBy: .gs1, sourceTier: .c,
                        sourceURI: "gs1-basic", licenseID: "lic-gs1", observedAt: World.t(-1), validUntil: nil, revision: 1, evidenceID: "e-\(id)"), value)
        }
        let r = try w.report()
        #expect(r.levels == [.universalSchemaSupported, .brandIdentifiable, .verifiedBasicIdentity])
        #expect(r.status(.identity).confidence == .partial)
        for a in [ClaimEvidence.Attribute.finishedMeasurement, .bodySizeChart, .composition] { #expect(r.status(a) == .unknown) }
        #expect(!r.levels.contains(.commerceEligible), "an offer alone never makes an unverified variant buyable")
    }

    @Test("V18-T-010: two suppliers disagree on fabric → CONFLICTING_SOURCES, fit gate stops; agreement is not conflict")
    func conflictingSources() throws {
        var w = World()
        w.add(.init(claimID: "c-comp-retail", subjectID: "m1", level: .styleModel, attribute: .composition, claimedBy: .retailer,
                    sourceTier: .b, sourceURI: "feed-tr", licenseID: "lic-retail-tr", observedAt: World.t(-1), validUntil: nil, revision: 1,
                    evidenceID: "e-comp-retail"), "COTTON:100")
        w.rights.licenses[1].allowedAttributes.append(.composition)
        let r = try w.report()
        #expect(r.status(.composition) == .conflicting(claimIDs: ["c-comp", "c-comp-retail"]))
        #expect(r.status(.composition).confidence == .abstain && r.status(.composition).sayableValue == nil)
        #expect(r.conflicts == [.composition])
        #expect(!r.levels.contains(.fitEligible))
        #expect(r.levels.contains(.variantVerified), "identity itself is not in dispute")

        var same = World()
        same.add(.init(claimID: "c-comp-retail", subjectID: "m1", level: .styleModel, attribute: .composition, claimedBy: .retailer,
                       sourceTier: .b, sourceURI: "feed-tr", licenseID: "lic-retail-tr", observedAt: World.t(-1), validUntil: nil, revision: 1,
                       evidenceID: "e-comp-retail"), " cotton:98,   elastane:2 ")
        same.rights.licenses[1].allowedAttributes.append(.composition)
        let agreed = try same.report()
        #expect(agreed.status(.composition) == .fact(value: "COTTON:98, ELASTANE:2", tier: .a, claimIDs: ["c-comp"]))
        #expect(agreed.levels.contains(.fitEligible))
    }

    @Test("V18-T-010 for measurements: a variant-level value contradicting the model-level one also stops fit")
    func measurementConflictAcrossLevels() throws {
        var w = World()
        w.brand("c-fin-model", "m1", .styleModel, .finishedMeasurement, "waist_flat 43", unit: "cm")
        let r = try w.report()
        #expect(r.status(.finishedMeasurement) == .conflicting(claimIDs: ["c-fin", "c-fin-model"]))
        #expect(!r.levels.contains(.fitEligible))
    }

    @Test("V18-T-011: licence ends → facts, images and 3D stop at once and cached copies are purged")
    func licenceExpiry() throws {
        let w = World()
        let before = try w.report(at: 99)
        #expect(before.levels.contains(.tryOnAssetReady))
        let after = try w.report(at: 100)
        #expect(after.status(.identity) == .blocked(.licenseExpiredOrRevoked))
        #expect(after.status(.media) == .blocked(.licenseExpiredOrRevoked))
        #expect(!after.levels.contains(.variantVerified) && !after.levels.contains(.tryOnAssetReady) && !after.levels.contains(.fitEligible))
        #expect(after.mayCacheOffline.isEmpty)
        let purged = Set(try w.gate().revocations(at: World.t(100)))
        for id in ["c-id", "c-size", "c-color", "c-fin", "c-comp", "c-media"] { #expect(purged.contains(.purgeCachedClaim(claimID: id))) }
        #expect(try w.gate().revocations(at: World.t(1)).isEmpty)

        var revoked = World()
        revoked.rights.licenses[0].revoked = true
        #expect(try revoked.report().status(.identity) == .blocked(.licenseExpiredOrRevoked))
        #expect(try revoked.gate().revocations(at: World.t(1)).contains(.purgeCachedClaim(claimID: "c-id")))
    }

    @Test("V18-T-015: the offer's stock TTL runs out → STALE, closed for buying, not commerce-eligible")
    func staleOffer() throws {
        let w = World()
        #expect(try w.report(at: 5.9).offers.first?.status == .purchasable)
        let r = try w.report(at: 6)
        #expect(r.offers == [.init(offerID: "o-tr", status: .stale, affiliateLinkAllowed: false)])
        #expect(!r.levels.contains(.commerceEligible))
        #expect(r.levels.contains(.fitEligible), "product facts do not age with the offer")
    }

    @Test("V18-T-020: affiliate right ends → link disabled; organic statements unchanged")
    func affiliateEnds() throws {
        var w = World()
        let organic = try w.report()
        w.rights.licenses[1].affiliateLinkRights = false
        let r = try w.report()
        #expect(r.offers.first?.affiliateLinkAllowed == false && r.offers.first?.status == .purchasable)
        #expect(r.attributes == organic.attributes && r.levels == organic.levels)
        #expect(try w.gate().revocations(at: World.t(1)) == [.disableAffiliateLink(offerID: "o-tr")])
    }

    @Test("V18-T-025: another market sees only its own offers in its own currency; no conversion, no borrowed claims")
    func otherMarket() throws {
        let w = World()
        let de = try w.report("v-m", "DE")
        #expect(de.offers.map(\.offerID) == ["o-de"])
        #expect(de.offers.first?.status == .purchasable)
        let tr = try w.report("v-m", "TR")
        #expect(tr.offers.map(\.offerID) == ["o-tr"])
        var pricedForTR = World()
        pricedForTR.graph.offers[1].claimIDs = ["c-price-tr", "c-stock-de"]
        #expect(try pricedForTR.report("v-m", "DE").offers.first?.status == .notVerified, "a TR price claim never prices a DE offer")
        #expect(throws: FaultCode.schemaInvalid) { try w.gate().coverage(variantID: "v-m", market: "tr", at: World.t(1)) }
        var gs1 = World()
        gs1.graph.claims.removeAll { $0.claimID == "c-id" }
        gs1.add(.init(claimID: "g-id", subjectID: "v-m", level: .sizeVariant, attribute: .identity, claimedBy: .gs1, sourceTier: .c,
                      sourceURI: "gs1-basic", licenseID: "lic-gs1", observedAt: World.t(-1), validUntil: nil, revision: 1, evidenceID: "e-g-id"), "A-100")
        #expect(try gs1.report("v-m", "DE").status(.identity) == .blocked(.outsideLicenseScope), "GS1 licence is TR-only here")
    }

    @Test("UNKNOWN and BLOCKED stay apart, each block names its reason")
    func unknownIsNotFalse() throws {
        var w = World()
        #expect(try w.report().status(.care) == .unknown)
        w.brand("c-care", "m1", .styleModel, .care, "30C")
        #expect(try w.report().status(.care) == .blocked(.outsideLicenseScope), "licence does not cover care")
        w.brand("c-chart", "m1", .styleModel, .bodySizeChart, "M chest 96-100", license: nil)
        #expect(try w.report().status(.bodySizeChart) == .blocked(.noLicense))

        var missing = World()
        missing.evidence.removeAll { $0.evidenceID == "e-c-color" }
        #expect(try missing.report().status(.color) == .blocked(.evidenceMissing))
        #expect(try !missing.report().levels.contains(.variantVerified))

        var withdrawn = World()
        withdrawn.evidence[withdrawn.evidence.firstIndex { $0.evidenceID == "e-c-size" }!].revocationTombstone = true
        #expect(try withdrawn.report().status(.sizeLabel) == .blocked(.evidenceWithdrawn))

        var revokedClaim = World()
        revokedClaim.graph.claims[0].revocationStatus = .superseded
        #expect(try revokedClaim.report().status(.identity) == .blocked(.claimRevoked))

        var noImageRight = World()
        noImageRight.rights.licenses[0].imageRights = false
        noImageRight.rights.licenses[0].derivative3DRights = false
        let r = try noImageRight.report()
        #expect(r.status(.media) == .blocked(.outsideLicenseScope) && !r.levels.contains(.tryOnAssetReady))
    }

    @Test("Each right is checked on its own: claim market, 3D derivative, offline cache, offer TTL vs claim TTL")
    func rightsOneByOne() throws {
        // A claim scoped to TR does not speak for DE even when the licence covers both.
        var scoped = World()
        scoped.graph.claims[scoped.graph.claims.firstIndex { $0.claimID == "c-size" }!].market = "TR"
        #expect(try scoped.report("v-m", "DE").status(.sizeLabel) == .blocked(.otherMarket))
        #expect(try scoped.report("v-m", "TR").status(.sizeLabel).sayableValue == "M")

        // Images allowed, 3D derivatives not: the picture may show, the try-on asset may not.
        var noDerivative = World()
        noDerivative.rights.licenses[0].derivative3DRights = false
        let nd = try noDerivative.report()
        #expect(nd.status(.media).confidence == .verifiedFacts && !nd.levels.contains(.tryOnAssetReady))

        // No offline-cache right: facts still sayable now, nothing kept for later.
        var noCache = World()
        noCache.rights.licenses[0].offlineCacheRights = false
        let nc = try noCache.report()
        #expect(nc.status(.identity).confidence == .verifiedFacts && nc.mayCacheOffline.isEmpty)

        // The seller's claims last longer than the offer itself: the offer's own TTL still closes it.
        var longClaims = World()
        for id in ["c-price-tr", "c-stock-tr"] {
            longClaims.graph.claims[longClaims.graph.claims.firstIndex { $0.claimID == id }!].validUntil = World.t(10)
        }
        #expect(try longClaims.report(at: 5).offers.first?.status == .purchasable)
        #expect(try longClaims.report(at: 6).offers.first?.status == .stale)
    }

    @Test("The user's own label reading is theirs: partial, never brand fact, and a disagreement still stops")
    func userEvidence() throws {
        var w = World()
        w.graph.claims.removeAll { $0.claimID == "c-comp" }
        w.evidence.removeAll { $0.evidenceID == "e-c-comp" }
        w.add(.init(claimID: "u-comp", subjectID: "m1", level: .styleModel, attribute: .composition, claimedBy: .user, sourceTier: .d,
                    sourceURI: "label-ocr-confirmed", licenseID: nil, observedAt: World.t(0), validUntil: nil, revision: 1,
                    evidenceID: "e-u-comp"), "COTTON:100")
        let r = try w.report()
        #expect(r.status(.composition) == .userEvidence(value: "COTTON:100", claimIDs: ["u-comp"]))
        #expect(r.status(.composition).confidence == .partial && !r.mayCacheOffline.contains(.composition))
        w.brand("c-comp", "m1", .styleModel, .composition, "COTTON:98, ELASTANE:2")
        #expect(try w.report().status(.composition) == .conflicting(claimIDs: ["c-comp", "u-comp"]))
    }

    @Test("Synthetic demo data is labelled synthetic everywhere and proves nothing")
    func syntheticWorld() throws {
        let evidence = Goldens.graph.claims.map { c in
            EvidenceRecord(evidenceID: c.evidenceID, factKey: c.attribute.rawValue, subjectProductID: c.subjectID, variantID: nil,
                           factValue: "54", unit: "cm", sourceType: .syntheticFixture, sourceURIOrLicensedDatasetID: c.sourceURI,
                           licenseID: nil, collectedAt: c.observedAt, confidenceKind: .heuristic, verificationMethod: .none)
        }
        let gate = try EvidenceCoverageGate(graph: Goldens.graph, registry: Goldens.registry, rights: Goldens.rights, evidence: evidence)
        let r = try gate.coverage(variantID: "var-synth-jkt-01-nvy-m", market: "TR", at: Goldens.t(1))
        #expect(r.levels == [.universalSchemaSupported, .brandIdentifiable])
        #expect(r.status(.finishedMeasurement) == .synthetic(value: "54 cm", claimIDs: ["claim-synth-chart-1"]))
        #expect(r.status(.finishedMeasurement).confidence == .heuristic)
        #expect(r.offers.allSatisfy { $0.status != .purchasable })
        #expect(r.attributes.values.allSatisfy { if case .fact = $0 { false } else { true } })
    }

    @Test("Fail closed on bad inputs: the gate refuses to start instead of guessing")
    func refusesBadInputs() throws {
        var w = World()
        w.evidence.append(w.evidence[0])
        #expect(throws: FaultCode.schemaInvalid) { try w.gate() }
        w = World()
        w.rights.licenses[0].imageRights = false
        #expect(throws: FaultCode.schemaInvalid, "3D right without image right") { try w.gate() }
        w = World()
        w.registry.brands[0].brandID = "brand-b"
        #expect(throws: FaultCode.schemaInvalid, "graph uses an unregistered brand") { try w.gate() }
        w = World()
        #expect(throws: FaultCode.schemaInvalid) { try w.gate().coverage(variantID: "v-xl", market: "TR", at: World.t(1)) }
    }
}
