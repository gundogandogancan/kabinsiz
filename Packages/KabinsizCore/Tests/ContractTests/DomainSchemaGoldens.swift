import BodyGeometry
import DomainSchemas
import Foundation
import SystemContracts

/// The R17-02 golden values, all SYNTHETIC_DEMO_ONLY (GTINs in the GS1 in-store prefix 200, invented
/// brand and owner). The JSON files in `Fixtures/` are these values written once and then frozen; the
/// tests compare both ways so neither can drift. Regenerate only on purpose:
/// `REGENERATE_GOLDENS=1 swift test --filter DomainSchemaTests`.
enum Goldens {
    static let t0 = Date(timeIntervalSince1970: 1_793_696_400) // 2026-11-03T09:00:00Z
    static func t(_ hours: Double) -> Date { t0.addingTimeInterval(hours * 3600) }

    static let identity = ProductIdentityV1(
        identityID: "pid-synth-jkt-01-nvy-m", gtin: "02000001000014", retailerSku: nil, brandID: "brand-synth-1",
        brandProductCode: "SYN-JKT-01", modelID: "model-synth-jkt-01", colorID: "NVY", sizeLabel: "M", season: "2026-AW",
        patternRevision: nil, market: "TR", sourceRef: "SYNTHETIC_DEMO_ONLY", matchKind: .exactUserConfirmed,
        verifiedAt: t(0), expiresAt: nil, evidenceIDs: ["ev-synth-identity-1"], licensingRights: [],
        catalogVersion: "synthetic-catalog-1"
    )

    static let physical = ProductPhysicalSpecV1(
        identityID: "pid-synth-jkt-01-nvy-m", measurementType: .finishedGarment,
        pointsBySize: [
            .init(size: "M", region: .chest, dimension: .flatHalfWidth, cm: 54, toleranceCm: 1, method: .flatLayTape, sourceEvidenceID: "ev-synth-m-chest", revision: 1),
            .init(size: "M", region: .totalLength, dimension: .length, cm: 70.5, toleranceCm: 1, method: .flatLayTape, sourceEvidenceID: "ev-synth-m-length", revision: 1),
            .init(size: "L", region: .chest, dimension: .flatHalfWidth, cm: 56.5, toleranceCm: 1, method: .flatLayTape, sourceEvidenceID: "ev-synth-l-chest", revision: 2),
        ],
        cut: .regular, closure: "zip", lining: true, stretchTestRefs: [], seamAllowanceKnown: nil, unitSystem: .metric,
        sizeSystem: "EU-ALPHA", revision: 2
    )

    static let fabric = FabricSpecV1(
        identityID: "pid-synth-jkt-01-nvy-m", composition: [.init(.cotton, 98), .init(.elastane, 2)], compositionOrigin: .synthetic,
        knitOrWoven: .woven, stretchDirection: .widthOnly, washInstructionC: 30, dryingInstruction: .lineDry,
        evidenceByAttribute: [
            "composition": "ev-synth-composition", "knit_or_woven": "ev-synth-construction",
            "stretch_direction": "ev-synth-stretch", "wash_instruction_c": "ev-synth-care", "drying_instruction": "ev-synth-care",
        ],
        userVerifiedLabelPhoto: nil, uncertainty: .medium
    )

    static let body = BodyProfileV2(
        profileRevision: 7,
        measurements: [
            .init(region: .chest, cm: 96, origin: .userMeasured, method: .tapeSelf, observedAt: t(0)),
            .init(region: .waist, cm: 82.5, origin: .userMeasured, method: .tapeSelf, observedAt: t(0)),
            .init(region: .hip, cm: 99, origin: .imageEstimate, method: .photoEstimate, confidence: .low, observedAt: t(1)),
        ],
        fitPreferences: .init(prefersRelaxedFit: true),
        avatarMorphState: .init(values: [
            .init(region: .height, cm: 170, source: .neutralStart),
            .init(region: .shoulderWidth, cm: 43, source: .sliderShaped),
        ], preferredUnit: .centimeters),
        userApproval: .approved
    )

    static let fit = RegionalFitV1(
        identityID: "pid-synth-jkt-01-nvy-m", profileRevision: 7, chartRevision: 2,
        regions: [
            .init(region: .chest, evaluation: .fitEvidence, usableMeasurements: [.chest], garmentEaseCm: 12, uncertaintyCm: 2,
                  evidenceIDs: ["ev-synth-m-chest"], explanation: "Göğüs, ölçtüğün değere göre rahat pay bırakıyor."),
            .init(region: .waist, evaluation: .possiblyTight, usableMeasurements: [.waist], garmentEaseCm: 1, uncertaintyCm: 2,
                  evidenceIDs: ["ev-synth-m-waist"], explanation: "Bel payı az; dar gelebilir."),
            .init(region: .hip, evaluation: .unknown, usableMeasurements: [], evidenceIDs: [],
                  explanation: "Kalça ölçüsü bu üründe yok; karşılaştırılmadı."),
        ],
        recommendation: .compareTwoSizes, recommendedSizes: ["M", "L"], isProductSpecificFitProven: false,
        limitations: ["Kalça karşılaştırılamadı.", "Ürüne özel uyum denemeyle kanıtlanmadı."]
    )

    static let thermal = ThermalAdviceV1(
        identityID: "pid-synth-jkt-01-nvy-m", weatherEvidenceID: nil, context: .init(activity: .walking, layers: 2),
        advice: .noData, text: "Hava bilgisi yok. Katmanlı giyinmek seçeneklerini açık tutar.",
        limitations: ["Hava verisi yok.", "Kişisel ısı tercihi bilinmiyor."], washCareTempC: 30
    )

    static let tryOn = VisualTryOnV1(
        identityID: "pid-synth-jkt-01-nvy-m", profileRevision: 7, assetRevision: nil, fidelity: .g0, assetLicense: .ownProcedural,
        renderingMethod: .genericMesh, simulationValidated: false, previewLatencyMs: nil,
        confidenceExplanations: ["Nötr gövde, ürünün kendi 3B varlığı yok."],
        limitations: ["Görünüm beden uyumunun kanıtı değildir."]
    )

    static let registry = BrandRegistryV1(
        registryRevision: 3,
        owners: [
            .init(ownerID: "owner-synth-1", legalName: "Örnek Giyim A.Ş. (SYNTHETIC_DEMO_ONLY)", sourceClaimID: "claim-synth-owner-1"),
            .init(ownerID: "owner-synth-2", legalName: "Muster Lizenz GmbH (SYNTHETIC_DEMO_ONLY)", sourceClaimID: "claim-synth-owner-2"),
        ],
        brands: [
            .init(brandID: "brand-synth-1", displayName: "Örnek Marka", ownerID: "owner-synth-1",
                  localLicensees: [.init(market: "DE", ownerID: "owner-synth-2")], markets: ["TR", "DE"], sourceTier: .synthetic),
        ]
    )

    static let graph = CommerceGraphV1(
        graphRevision: 5,
        collections: [.init(collectionID: "col-synth-aw26", brandID: "brand-synth-1", season: "2026-AW")],
        styleModels: [.init(styleModelID: "model-synth-jkt-01", brandID: "brand-synth-1", collectionID: "col-synth-aw26",
                            manufacturerStyleCode: "SYN-JKT-01", category: "OUTERWEAR")],
        colorways: [.init(colorwayID: "cw-synth-jkt-01-nvy", styleModelID: "model-synth-jkt-01", colorName: "Lacivert")],
        sizeVariants: [
            .init(variantID: "var-synth-jkt-01-nvy-m", colorwayID: "cw-synth-jkt-01-nvy", sizeLabel: "M", sizeSystem: "EU-ALPHA",
                  identifiers: [.init(.gtin, "02000001000014"), .init(.manufacturerStyleCode, "SYN-JKT-01"),
                                .init(.merchantSku, "SKU-778-M", issuer: "merchant-synth-1")]),
            .init(variantID: "var-synth-jkt-01-nvy-l", colorwayID: "cw-synth-jkt-01-nvy", sizeLabel: "L", sizeSystem: "EU-ALPHA",
                  identifiers: [.init(.gtin, "02000001000021"), .init(.manufacturerStyleCode, "SYN-JKT-01")]),
        ],
        merchants: [.init(merchantID: "merchant-synth-1", displayName: "Örnek Mağaza", markets: ["TR"])],
        offers: [
            .init(offerID: "offer-synth-1", variantID: "var-synth-jkt-01-nvy-m", merchantID: "merchant-synth-1", market: "TR",
                  priceMinor: 249_990, currency: "TRY", stock: .availableVerified, observedAt: t(0), validUntil: t(6),
                  isAffiliateLink: false, isSponsored: false, claimIDs: ["claim-synth-price-1", "claim-synth-stock-1"]),
            .init(offerID: "offer-synth-2", variantID: "var-synth-jkt-01-nvy-l", merchantID: "merchant-synth-1", market: "TR",
                  priceMinor: nil, currency: nil, stock: .unknown, observedAt: t(0), validUntil: nil,
                  isAffiliateLink: false, isSponsored: false, claimIDs: []),
        ],
        claims: [
            .init(claimID: "claim-synth-price-1", subjectID: "offer-synth-1", level: .offer, attribute: .price, claimedBy: .synthetic,
                  sourceTier: .synthetic, sourceURI: "kabinsiz-synthetic-catalog-v1", licenseID: nil, market: "TR",
                  observedAt: t(0), validUntil: t(6), revision: 1, evidenceID: "ev-synth-price-1"),
            .init(claimID: "claim-synth-stock-1", subjectID: "offer-synth-1", level: .offer, attribute: .stock, claimedBy: .synthetic,
                  sourceTier: .synthetic, sourceURI: "kabinsiz-synthetic-catalog-v1", licenseID: nil, market: "TR",
                  observedAt: t(0), validUntil: t(6), revision: 1, evidenceID: "ev-synth-stock-1"),
            .init(claimID: "claim-synth-chart-1", subjectID: "var-synth-jkt-01-nvy-m", level: .sizeVariant, attribute: .finishedMeasurement,
                  claimedBy: .synthetic, sourceTier: .synthetic, sourceURI: "kabinsiz-synthetic-catalog-v1", licenseID: nil,
                  observedAt: t(0), validUntil: nil, revision: 2, evidenceID: "ev-synth-m-chest"),
        ]
    )

    /// File name → encoded golden.
    static func all() throws -> [(String, Data)] {
        [
            ("product_identity_v1", try ContractCoder.encode(identity)),
            ("product_physical_spec_v1", try ContractCoder.encode(physical)),
            ("fabric_spec_v1", try ContractCoder.encode(fabric)),
            ("body_profile_v2", try ContractCoder.encode(body)),
            ("regional_fit_v1", try ContractCoder.encode(fit)),
            ("thermal_advice_v1", try ContractCoder.encode(thermal)),
            ("visual_try_on_v1", try ContractCoder.encode(tryOn)),
            ("brand_registry_v1", try ContractCoder.encode(registry)),
            ("commerce_graph_v1", try ContractCoder.encode(graph)),
        ]
    }
}
