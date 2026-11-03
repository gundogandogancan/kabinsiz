import BodyGeometry
import DomainContracts
@testable import DomainSchemas
import Foundation
import SystemContracts
import Testing

private func invalid<T: VersionedContract>(_ value: T, _ fault: FaultCode = .schemaInvalid, _ comment: Comment? = nil,
                                           sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(throws: fault, comment, sourceLocation: sourceLocation) { try value.validate() }
}

private func decode<T: VersionedContract>(_ type: T.Type, _ data: Data) throws(FaultCode) -> T {
    try ContractCoder.decode(T.self, from: data)
}

@Suite("R17-02 / R18-WP02 domain schemas")
struct DomainSchemaTests {
    // MARK: Golden files

    static let fixtureDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().appendingPathComponent("Fixtures")

    @Test("Golden files equal the golden values both ways, keep frozen key names and round-trip")
    func goldens() throws {
        if ProcessInfo.processInfo.environment["REGENERATE_GOLDENS"] == "1" {
            // Writes the source files; the test bundle's copy updates on the next build.
            for (name, encoded) in try Goldens.all() {
                let object = try JSONSerialization.jsonObject(with: encoded)
                try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
                    .write(to: Self.fixtureDir.appendingPathComponent("\(name).json"))
            }
        }
        for (name, encoded) in try Goldens.all() {
            let golden = try fixture(name)
            // Same JSON object as today's encoder writes (key names, values, nulls left out).
            let a = try #require(JSONSerialization.jsonObject(with: golden) as? NSDictionary)
            let b = try #require(JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
            #expect(a == b, "\(name) drifted from its golden file")
            try roundTrip(name, golden)
        }
    }

    private func roundTrip(_ name: String, _ data: Data) throws {
        func check<T: VersionedContract & Equatable>(_ type: T.Type, _ expected: T) throws {
            let value = try decode(T.self, data)
            #expect(value == expected, "\(name)")
            #expect(try decode(T.self, ContractCoder.encode(value)) == value)
        }
        switch name {
        case "product_identity_v1": try check(ProductIdentityV1.self, Goldens.identity)
        case "product_physical_spec_v1": try check(ProductPhysicalSpecV1.self, Goldens.physical)
        case "fabric_spec_v1": try check(FabricSpecV1.self, Goldens.fabric)
        case "body_profile_v2": try check(BodyProfileV2.self, Goldens.body)
        case "regional_fit_v1": try check(RegionalFitV1.self, Goldens.fit)
        case "thermal_advice_v1": try check(ThermalAdviceV1.self, Goldens.thermal)
        case "visual_try_on_v1": try check(VisualTryOnV1.self, Goldens.tryOn)
        case "brand_registry_v1": try check(BrandRegistryV1.self, Goldens.registry)
        case "catalog_rights_v1": try check(CatalogRightsV1.self, Goldens.rights)
        default: try check(CommerceGraphV1.self, Goldens.graph)
        }
    }

    static let names = ["product_identity_v1", "product_physical_spec_v1", "fabric_spec_v1", "body_profile_v2", "regional_fit_v1",
                        "thermal_advice_v1", "visual_try_on_v1", "brand_registry_v1", "commerce_graph_v1", "catalog_rights_v1"]

    private func decodeAny(_ name: String, _ data: Data) throws(FaultCode) {
        switch name {
        case "product_identity_v1": _ = try decode(ProductIdentityV1.self, data)
        case "product_physical_spec_v1": _ = try decode(ProductPhysicalSpecV1.self, data)
        case "fabric_spec_v1": _ = try decode(FabricSpecV1.self, data)
        case "body_profile_v2": _ = try decode(BodyProfileV2.self, data)
        case "regional_fit_v1": _ = try decode(RegionalFitV1.self, data)
        case "thermal_advice_v1": _ = try decode(ThermalAdviceV1.self, data)
        case "visual_try_on_v1": _ = try decode(VisualTryOnV1.self, data)
        case "brand_registry_v1": _ = try decode(BrandRegistryV1.self, data)
        case "catalog_rights_v1": _ = try decode(CatalogRightsV1.self, data)
        default: _ = try decode(CommerceGraphV1.self, data)
        }
    }

    @Test("Backward: an older reader refuses a newer file instead of half-reading it", arguments: names)
    func newerRefused(_ name: String) throws {
        let current = try #require(JSONSerialization.jsonObject(with: fixture(name)) as? [String: Any])["schema_version"] as? Int
        let data = try mutated(name, "schema_version", try #require(current) + 1)
        #expect(throws: FaultCode.schemaNewer) { try decodeAny(name, data) }
    }

    @Test("A same-version file cannot smuggle extra keys", arguments: names)
    func extraKeys(_ name: String) throws {
        #expect(throws: FaultCode.schemaInvalid) { try decodeAny(name, mutated(name, "latitude", 41.0)) }
    }

    @Test("Raw values of every new persisted enum are frozen")
    func frozenEnums() throws {
        let current: [String: [String]] = [
            "MatchKind": ProductIdentityV1.MatchKind.allCases.map(\.rawValue),
            "LicensingRight": ProductIdentityV1.LicensingRight.allCases.map(\.rawValue),
            "GarmentRegion": GarmentRegion.allCases.map(\.rawValue),
            "MeasurementType": ProductPhysicalSpecV1.MeasurementType.allCases.map(\.rawValue),
            "Dimension": ProductPhysicalSpecV1.Dimension.allCases.map(\.rawValue),
            "MeasureMethod": ProductPhysicalSpecV1.Method.allCases.map(\.rawValue),
            "Fiber": FabricSpecV1.Fiber.allCases.map(\.rawValue),
            "CompositionOrigin": FabricSpecV1.CompositionOrigin.allCases.map(\.rawValue),
            "BodyRegion": BodyProfileV2.Region.allCases.map(\.rawValue),
            "BodyOrigin": BodyProfileV2.Origin.allCases.map(\.rawValue),
            "Evaluation": RegionalFitV1.Evaluation.allCases.map(\.rawValue),
            "Recommendation": RegionalFitV1.Recommendation.allCases.map(\.rawValue),
            "Advice": ThermalAdviceV1.Advice.allCases.map(\.rawValue),
            "Fidelity": VisualTryOnV1.Fidelity.allCases.map(\.rawValue),
            "AssetLicense": VisualTryOnV1.AssetLicense.allCases.map(\.rawValue),
            "RenderingMethod": VisualTryOnV1.RenderingMethod.allCases.map(\.rawValue),
            "SourceTier": SourceTier.allCases.map(\.rawValue),
            "Namespace": ProductIdentifier.Namespace.allCases.map(\.rawValue),
            "ClaimAttribute": ClaimEvidence.Attribute.allCases.map(\.rawValue),
            "ClaimedBy": ClaimEvidence.ClaimedBy.allCases.map(\.rawValue),
            "Stock": Offer.Stock.allCases.map(\.rawValue),
            "CoverageLevel": EvidenceCoverageGate.CoverageLevel.allCases.map(\.rawValue),
        ].mapValues { $0.sorted() }
        let url = Self.fixtureDir.appendingPathComponent("frozen_raw_values_r17.json")
        if ProcessInfo.processInfo.environment["REGENERATE_GOLDENS"] == "1" {
            try JSONSerialization.data(withJSONObject: current, options: [.prettyPrinted, .sortedKeys]).write(to: url)
        }
        let frozen = try #require(JSONSerialization.jsonObject(with: fixture("frozen_raw_values_r17")) as? [String: [String]])
        #expect(frozen == current)
    }

    // MARK: GTIN

    @Test("GTIN: published check digits pass; every form of the same code is one GTIN-14")
    func gtinKnown() {
        #expect(GTIN.normalized("4006381333931") == "04006381333931")   // EAN-13
        #expect(GTIN.normalized("036000291452") == "00036000291452")    // UPC-A
        #expect(GTIN.normalized("96385074") == "00000096385074")        // EAN-8
        #expect(GTIN.normalized("4006-381 333931") == "04006381333931")
        #expect(GTIN.normalized("04006381333931") == GTIN.normalized("4006381333931"))
        for bad in ["4006381333932", "40063813339", "", "ABCDEFGHIJKLM", "٤٠٠٦٣٨١٣٣٣٩٣١", "4006381333931\u{200B}", "123456789012345"] {
            #expect(GTIN.normalized(bad) == nil, "\(bad)")
        }
    }

    @Test("GTIN: any single wrong digit is caught (mod-10 property over 500 generated codes)")
    func gtinSingleDigitErrors() {
        var rng = SplitMix(seed: 17)
        for _ in 0..<500 {
            let body = (0..<12).map { _ in Int(rng.next() % 10) }
            let sum = body.enumerated().reduce(0) { $0 + $1.element * ($1.offset.isMultiple(of: 2) ? 1 : 3) }
            let code = body + [(10 - sum % 10) % 10]
            let text = code.map(String.init).joined()
            #expect(GTIN.normalized(text) != nil, "\(text)")
            let i = Int(rng.next() % 13)
            var wrong = code
            wrong[i] = (wrong[i] + 1 + Int(rng.next() % 9)) % 10
            #expect(GTIN.normalized(wrong.map(String.init).joined()) == nil)
        }
    }

    // MARK: Product identity and physical spec

    @Test("Identity: exact needs a code, evidence and a check time; a guess is never verified")
    func identityRules() {
        var v = Goldens.identity
        v.evidenceIDs = []
        invalid(v, .schemaInvalid, "exact without evidence")
        v = Goldens.identity; v.gtin = nil
        invalid(v, .schemaInvalid, "exact without GTIN or SKU")
        v = Goldens.identity; v.matchKind = .candidateOnly
        invalid(v, .schemaInvalid, "candidate carrying a verification time")
        v.verifiedAt = nil
        #expect((try? v.validate()) != nil)
        v = Goldens.identity; v.matchKind = .exactVerified
        invalid(v, .schemaInvalid, "verified without the right to display facts")
        v = Goldens.identity; v.gtin = "2000001000014"
        invalid(v, .schemaInvalid, "raw EAN-13 instead of canonical GTIN-14")
        v = Goldens.identity; v.market = "tr"
        invalid(v)
        v = Goldens.identity; v.sizeLabel = " "
        invalid(v, .schemaInvalid, "size label alone is not identity, and a blank one is nothing")
    }

    @Test("Identity levels: user-confirmed is identifiable but not verified; verified ages out")
    func identityLevels() throws {
        let confirmed = Goldens.identity
        #expect(confirmed.identityLevel(at: Goldens.t(1)) == .brandIdentifiable)
        var verified = confirmed
        verified.matchKind = .exactVerified
        verified.licensingRights = [.displayFacts]
        verified.expiresAt = Goldens.t(24)
        try verified.validate()
        #expect(verified.identityLevel(at: Goldens.t(1)) == .variantVerified)
        #expect(verified.identityLevel(at: Goldens.t(24)) == .brandIdentifiable)
        #expect(!verified.isVerified(at: Goldens.t(-1)))
        var missing = confirmed
        missing.matchKind = .notFound; missing.verifiedAt = nil
        #expect(missing.identityLevel(at: Goldens.t(1)) == .none)
    }

    @Test("Physical spec: body chart and garment measurements stay distinct; no silent duplicates")
    func physicalRules() {
        var v = Goldens.physical
        v.measurementType = .bodySizeChart
        invalid(v, .schemaInvalid, "a body has no flat half width")
        v = Goldens.physical; v.pointsBySize.append(v.pointsBySize[0])
        invalid(v, .schemaInvalid, "two values for M chest")
        v = Goldens.physical; v.pointsBySize[0].revision = 3
        invalid(v, .schemaInvalid, "point newer than its spec")
        for bad in [Double.nan, .infinity, 0, -5, 900] {
            v = Goldens.physical; v.pointsBySize[1].cm = bad
            invalid(v, .schemaInvalid, "\(bad) cm")
        }
        v = Goldens.physical; v.pointsBySize[0].sourceEvidenceID = ""
        invalid(v, .schemaInvalid, "a number with no source")
        v = Goldens.physical; v.pointsBySize = []
        invalid(v)
        #expect(Goldens.physical.sizes == ["M", "L"])
        #expect(Goldens.physical.point(size: "L", region: .chest, dimension: .flatHalfWidth)?.cm == 56.5)
    }

    // MARK: Fabric

    @Test("Fabric: every value names its source and only present values may; percentages add up")
    func fabricProvenance() {
        var v = Goldens.fabric
        v.fabricWeightGsm = 320
        invalid(v, .schemaInvalid, "weight without evidence")
        v.evidenceByAttribute["fabric_weight_gsm"] = "ev-w"
        #expect((try? v.validate()) != nil)
        v = Goldens.fabric; v.evidenceByAttribute["thermal_resistance_test"] = "ev-orphan"
        invalid(v, .schemaInvalid, "evidence for a value that is not there")
        v = Goldens.fabric; v.composition = [.init(.cotton, 80), .init(.elastane, 10)]
        invalid(v, .schemaInvalid, "90 %")
        v = Goldens.fabric; v.composition = [.init(.cotton, 50), .init(.cotton, 50)]
        invalid(v, .schemaInvalid, "same fibre twice")
        v = Goldens.fabric; v.compositionOrigin = nil
        invalid(v, .schemaInvalid, "composition from nowhere")
        v = Goldens.fabric; v.composition = [.init(.cotton, 99.4), .init(.elastane, 1.2)]
        #expect((try? v.validate()) != nil, "rounded label within one point")
    }

    @Test("Fabric: a picture gives appearance, not material; stretch numbers need a test; care temp is care")
    func fabricTruth() {
        var v = Goldens.fabric
        v.visualAppearanceHint = "denim görünümlü"
        #expect((try? v.validate()) != nil)
        #expect(!v.compositionIsProductFact, "synthetic composition is never product fact")
        v.compositionOrigin = .careLabelUnconfirmed
        #expect(!v.compositionIsProductFact)
        v.compositionOrigin = .brandLicensed
        #expect(v.compositionIsProductFact)
        v = Goldens.fabric; v.stretchRecovery = 92; v.stretchDirection = FabricSpecV1.StretchDirection.none
        v.evidenceByAttribute["stretch_recovery"] = "ev-test"
        invalid(v, .schemaInvalid, "recovery without stretch")
        v = Goldens.fabric; v.washInstructionC = 120
        invalid(v)
        #expect(!FabricSpecV1.CompositionOrigin.allCases.map(\.rawValue).contains { $0.contains("IMAGE") || $0.contains("PHOTO") })
    }

    // MARK: Body v2 and migration

    @Test("Body v2: local only, estimates labelled, size advice sees only approved typed values")
    func bodyRules() {
        var v = Goldens.body
        v.localOnly = false
        invalid(v, .egressBlocked)
        v = Goldens.body; v.measurements[2].confidence = nil
        invalid(v, .schemaInvalid, "estimate without confidence")
        v = Goldens.body; v.measurements[0].method = .photoEstimate
        invalid(v, .schemaInvalid, "typed value claiming a photo method")
        v = Goldens.body; v.measurements[0].cm = 820
        invalid(v, .schemaInvalid, "typo guard 82 → 820")
        #expect(Goldens.body.sizingMeasurements == [.chest: 96, .waist: 82.5])
        v = Goldens.body; v.userApproval = .declined
        #expect(v.sizingMeasurements.isEmpty)
        #expect(BodyProfileV2.dataClassification == .localSensitive && !BodyProfileV2.dataClassification.mayLeaveDeviceByDefault)
    }

    @Test("Migration v1 → v2 never turns a slider shape or a starting value into a measurement")
    func upgradeKeepsShapesOut() throws {
        var v1 = BodyProfile.neutral()
        v1 = try v1.applying(.slider(.waist, cm: 90))
        v1 = try v1.applying(.slider(.chest, cm: 101))
        let v2 = try BodyProfileMigration.upgrade(v1, at: Goldens.t0)
        #expect(v2.measurements.isEmpty)
        #expect(v2.sizingMeasurements.isEmpty && v2.userApproval == .notAsked)
        #expect(v2.avatarMorphState.values.count == 5)
        #expect(v2.avatarMorphState.values.first { $0.region == .waist }?.source == .sliderShaped)
        #expect(v2.avatarMorphState.values.first { $0.region == .hip }?.source == .neutralStart)

        let measured = try v1.applying(.measured(.waist, 32, .inches))
        let m2 = try BodyProfileMigration.upgrade(measured, at: Goldens.t0)
        #expect(m2.sizingMeasurements == [.waist: 81.28])
        #expect(m2.profileRevision == measured.revision)
    }

    @Test("Migration round trip v1 → v2 → v1 is exact over 300 generated bodies")
    func roundTripProperty() throws {
        var rng = SplitMix(seed: 2)
        var checked = 0
        for _ in 0..<300 {
            var profile = BodyProfile.neutral(unit: rng.next() % 2 == 0 ? .centimeters : .inches)
            for p in BodyParameter.allCases where rng.next() % 3 != 0 {
                let r = profile.allowedRange(p)
                let cm = r.lowerBound + Double(rng.next() % 1000) / 1000 * (r.upperBound - r.lowerBound)
                let edit: BodyEdit = rng.next() % 2 == 0 ? .slider(p, cm: (cm * 2).rounded() / 2) : .measured(p, cm / 2.54, .inches)
                profile = (try? profile.applying(edit)) ?? profile
            }
            let back = try BodyProfileMigration.downgrade(BodyProfileMigration.upgrade(profile, at: Goldens.t0))
            #expect(back == profile)
            checked += 1
        }
        #expect(checked == 300)
    }

    @Test("Downgrade draws a photo estimate as a shape, never writes it back as a measurement")
    func downgradeEstimate() throws {
        let v1 = try BodyProfileMigration.downgrade(Goldens.body)
        #expect(v1[.hip].source == .sliderShaped)
        #expect(v1[.waist].source == .userMeasured && v1[.waist].length.centimeters == 82.5)
        #expect(v1[.height].source == .neutralStart)
        #expect(v1.measuredCentimeters.keys.sorted { $0.rawValue < $1.rawValue } == [.chest, .waist])
    }

    @Test("Reader takes a v1 file or a v2 file, refuses a v3 file and a doctored v1 file")
    func readEitherVersion() throws {
        let v1 = try BodyProfile.neutral().applying(.measured(.hip, 101, .centimeters))
        let fromV1 = try BodyProfileMigration.read(JSONEncoder().encode(v1), now: Goldens.t0)
        #expect(fromV1.sizingMeasurements == [.hip: 101])
        let fromV2 = try BodyProfileMigration.read(fixture("body_profile_v2"), now: Goldens.t0)
        #expect(fromV2 == Goldens.body)
        #expect(throws: FaultCode.schemaNewer) { try BodyProfileMigration.read(mutated("body_profile_v2", "schema_version", 3), now: Goldens.t0) }
        var doctored = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(v1)) as? [String: Any])
        doctored["upload_url"] = "https://example.com"
        #expect(throws: FaultCode.schemaInvalid) { try BodyProfileMigration.read(JSONSerialization.data(withJSONObject: doctored), now: Goldens.t0) }
        #expect(throws: FaultCode.schemaInvalid) { try BodyProfileMigration.read(Data("[]".utf8), now: Goldens.t0) }
    }

    // MARK: Regional fit

    @Test("Fit: one size only when every region is evaluated; proof only with evidence everywhere")
    func fitRules() throws {
        var v = Goldens.fit
        v.recommendation = .trySize; v.recommendedSizes = ["M"]
        invalid(v, .schemaInvalid, "TRY_SIZE with hip unknown")
        v.regions.removeLast()
        #expect((try? v.validate()) != nil)
        v.isProductSpecificFitProven = true
        invalid(v, .schemaInvalid, "proven while waist is only 'possibly tight'")
        v = Goldens.fit; v.limitations = []
        invalid(v, .schemaInvalid, "not proven and silent about why")
        v = Goldens.fit; v.recommendedSizes = ["M"]
        invalid(v, .schemaInvalid, "compare with one size")
        v = Goldens.fit; v.regions[0].evidenceIDs = []
        invalid(v, .schemaInvalid, "verdict with no source")
        v = Goldens.fit; v.regions[2].garmentEaseCm = 3
        invalid(v, .schemaInvalid, "ease for an unknown region")
        #expect(Goldens.fit.confidence == .partial)
        var none = Goldens.fit
        none.recommendation = .insufficientData; none.recommendedSizes = []
        #expect(none.confidence == .abstain)
    }

    @Test("Fit cross-check: same body revision, and no verdict rests on a slider shape or a photo estimate")
    func fitAgainstBody() throws {
        try Goldens.fit.validate(against: Goldens.body)
        var v = Goldens.fit
        v.regions[2] = .init(region: .hip, evaluation: .possiblyLoose, usableMeasurements: [.hip], evidenceIDs: ["ev-h"], explanation: "Kalça bol olabilir.")
        #expect(throws: FaultCode.schemaInvalid, "hip is a photo estimate") { try v.validate(against: Goldens.body) }
        v = Goldens.fit
        v.regions[0].usableMeasurements = [.shoulderWidth]
        #expect(throws: FaultCode.schemaInvalid, "shoulder is a slider shape") { try v.validate(against: Goldens.body) }
        var older = Goldens.body
        older.profileRevision = 6
        #expect(throws: FaultCode.staleRevision) { try Goldens.fit.validate(against: older) }
        var declined = Goldens.body
        declined.userApproval = .declined
        #expect(throws: FaultCode.schemaInvalid) { try Goldens.fit.validate(against: declined) }
    }

    // MARK: Thermal

    @Test("Thermal: no weather numbers without a weather source; no degrees without measured data")
    func thermalRules() throws {
        var v = Goldens.thermal
        v.context.airTempC = 14
        invalid(v, .schemaInvalid, "temperature with no weather evidence")
        v.weatherEvidenceID = "ev-weather-1"; v.advice = .layeringSuggestion
        #expect((try? v.validate()) != nil)
        v.estimatedComfortIntervalC = .init(lowC: 12, highC: 20)
        invalid(v, .schemaInvalid, "interval without measured thermal data")
        v.verifiedMeasurementIDs = ["ev-rct-1"]; v.text = "Katmanlı giy; tahmini aralık 12–20 °C."
        #expect((try? v.validate()) != nil)
        v.advice = .weatherUncertain
        invalid(v, .schemaInvalid, "interval while weather is uncertain")
        v = Goldens.thermal; v.text = "21 °C'de giyilir."
        invalid(v, .schemaInvalid, "a degree figure with no interval behind it")
        v = Goldens.thermal; v.weatherEvidenceID = "ev-w"
        invalid(v, .schemaInvalid, "NO_DATA citing weather")
        v = Goldens.thermal; v.limitations = []
        invalid(v)
    }

    @Test("Thermal: the wash temperature is carried as care and changes nothing else (30 °C wash ≠ 30 °C wear)")
    func washIsCareOnly() throws {
        for wash in [nil, 30, 40, 60, 95] as [Int?] {
            var v = Goldens.thermal
            v.washCareTempC = wash
            try v.validate()
            #expect(v.estimatedComfortIntervalC == nil && !v.text.contains { $0.isNumber })
        }
        var v = Goldens.thermal
        v.washCareTempC = 140
        invalid(v)
    }

    // MARK: Visual try-on

    @Test("Try-on: only G2 is a validated simulation; G3 is always a generated image; pictures never size")
    func tryOnRules() {
        var v = Goldens.tryOn
        v.simulationValidated = true
        invalid(v, .schemaInvalid, "G0 claiming simulation")
        v = Goldens.tryOn; v.fidelity = .g1; v.renderingMethod = .preparedProductMesh; v.assetLicense = .brandLicensed
        invalid(v, .schemaInvalid, "G1 without asset revision")
        v.assetRevision = 3
        #expect((try? v.validate()) != nil)
        v.simulationValidated = true
        invalid(v, .schemaInvalid, "G1 is not physics")
        v = Goldens.tryOn; v.fidelity = .g1; v.renderingMethod = .generativeImage; v.assetRevision = 1; v.assetLicense = .brandLicensed
        invalid(v, .schemaInvalid, "generated image presented as G1")
        v = Goldens.tryOn; v.fidelity = .g3; v.renderingMethod = .generativeImage; v.assetLicense = .none
        #expect((try? v.validate()) != nil)
        v.limitations = []
        invalid(v)
        v = Goldens.tryOn; v.fidelity = .g2; v.renderingMethod = .validatedDrape; v.simulationValidated = true; v.assetRevision = 1
        v.assetLicense = .ownProcedural
        invalid(v, .schemaInvalid, "drape without a product asset licence")
        #expect(!VisualTryOnV1.mayInformSizeAdvice)
        #expect(VisualTryOnV1.Fidelity(.flat2D) == .g0 && VisualTryOnV1.Fidelity(.genericMesh) == .g0)
        #expect(VisualTryOnV1.Fidelity(.productAsset) == .g1)
    }

    // MARK: Commerce

    @Test("Brand registry: owner, licensee and markets are separate, resolvable entries")
    func registryRules() {
        var v = Goldens.registry
        v.brands[0].localLicensees = [.init(market: "DE", ownerID: "owner-synth-1")]
        invalid(v, .schemaInvalid, "licensee is the owner")
        v = Goldens.registry; v.brands[0].ownerID = "owner-unknown"
        invalid(v)
        v = Goldens.registry; v.brands[0].localLicensees = [.init(market: "US", ownerID: "owner-synth-2")]
        invalid(v, .schemaInvalid, "licensee in a market the brand is not in")
        v = Goldens.registry; v.brands[0].sourceTier = .d
        invalid(v, .schemaInvalid, "user OCR is not a brand registry source")
        v = Goldens.registry; v.brands.append(v.brands[0])
        invalid(v)
    }

    @Test("Commerce graph: references resolve, namespaces stay apart, one GTIN names one variant")
    func graphIntegrity() throws {
        try Goldens.graph.validate(against: Goldens.registry)
        var g = Goldens.graph
        g.colorways[0].styleModelID = "model-missing"
        invalid(g)
        g = Goldens.graph; g.sizeVariants[1].identifiers[0] = .init(.gtin, "02000001000014")
        invalid(g, .schemaInvalid, "two variants share a GTIN")
        g = Goldens.graph; g.sizeVariants[0].identifiers[0] = .init(.gtin, "2000001000014")
        invalid(g, .schemaInvalid, "GTIN not canonical")
        g = Goldens.graph; g.sizeVariants[0].identifiers[2] = .init(.merchantSku, "SKU-778-M")
        invalid(g, .schemaInvalid, "merchant SKU without its merchant")
        g = Goldens.graph; g.sizeVariants[1].identifiers.append(.init(.merchantSku, "SKU-778-M", issuer: "merchant-synth-1"))
        invalid(g, .schemaInvalid, "one merchant SKU on two variants")
        // The same style code on many variants is normal: it names the model, not the variant.
        #expect(Goldens.graph.sizeVariants.allSatisfy { $0.identifiers.contains(.init(.manufacturerStyleCode, "SYN-JKT-01")) })
        g = Goldens.graph; g.offers[0].market = "DE"
        invalid(g, .schemaInvalid, "offer in a market the merchant does not serve")
        g = Goldens.graph; g.offers[0].variantID = "cw-synth-jkt-01-nvy"
        invalid(g, .schemaInvalid, "offer on a colourway, not a variant")
        var unregistered = Goldens.graph
        unregistered.styleModels[0].brandID = "brand-other"
        #expect(throws: FaultCode.schemaInvalid) { try unregistered.validate(against: Goldens.registry) }
        #expect(Goldens.graph.variant(gtin: "2000001000021")?.variantID == "var-synth-jkt-01-nvy-l")
        #expect(Goldens.graph.variant(gtin: "2000001000022") == nil)
        #expect(Goldens.graph.offers(for: "var-synth-jkt-01-nvy-m").count == 1)
    }

    @Test("Offers: money in minor units with a currency; verified stock always expires and then reads UNKNOWN")
    func offerRules() throws {
        var g = Goldens.graph
        g.offers[0].currency = nil
        invalid(g, .schemaInvalid, "price without currency")
        g = Goldens.graph; g.offers[0].currency = "TL"
        invalid(g)
        g = Goldens.graph; g.offers[0].validUntil = nil
        invalid(g, .schemaInvalid, "open-ended 'in stock'")
        g = Goldens.graph; g.offers[0].priceMinor = 0
        invalid(g)
        let offer = Goldens.graph.offers[0]
        #expect(offer.stock(at: Goldens.t(1)) == .availableVerified)
        #expect(offer.stock(at: Goldens.t(6)) == .unknown)
        #expect(offer.stock(at: Goldens.t(-1)) == .unknown)
        #expect(offer.isPriceCurrent(at: Goldens.t(1)) && !offer.isPriceCurrent(at: Goldens.t(7)))
        #expect(!Goldens.graph.offers[1].isPriceCurrent(at: Goldens.t(1)))
    }

    @Test("Claims: tier matches the claimant; GS1 carries identity only; price and stock belong to offers")
    func claimRules() throws {
        var g = Goldens.graph
        g.claims[2].claimedBy = .brand
        invalid(g, .schemaInvalid, "brand claim labelled synthetic tier")
        g.claims[2].sourceTier = .a
        #expect((try? g.validate()) != nil)
        g = Goldens.graph; g.claims[2].claimedBy = .gs1; g.claims[2].sourceTier = .c
        invalid(g, .schemaInvalid, "GS1 cannot give garment measurements")
        g.claims[2].attribute = .identity
        #expect((try? g.validate()) != nil)
        g = Goldens.graph; g.claims[0].level = .sizeVariant; g.claims[0].subjectID = "var-synth-jkt-01-nvy-m"
        invalid(g, .schemaInvalid, "price claimed on the product")
        g = Goldens.graph; g.claims[0].subjectID = "offer-missing"
        invalid(g)

        var claim = Goldens.graph.claims[2]
        #expect(!claim.isServableAsFact(at: Goldens.t(1)), "synthetic is never a fact")
        claim.claimedBy = .brand; claim.sourceTier = .a; claim.licenseID = "lic-1"; claim.validUntil = Goldens.t(10)
        #expect(claim.isServableAsFact(at: Goldens.t(1)))
        #expect(!claim.isServableAsFact(at: Goldens.t(10)))
        claim.revocationStatus = .revoked
        #expect(!claim.isServableAsFact(at: Goldens.t(1)))
        claim.revocationStatus = .active; claim.licenseID = nil
        #expect(!claim.isServableAsFact(at: Goldens.t(1)), "no licence, no fact")
        claim.licenseID = "lic-1"; claim.claimedBy = .user; claim.sourceTier = .d
        #expect(!claim.isServableAsFact(at: Goldens.t(1)), "the user's own reading is not brand truth")
    }
}

/// Deterministic generator for property tests (no global RNG state, same cases every run).
struct SplitMix {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
