import DomainContracts
import Foundation
import Testing
@testable import SystemContracts

@Suite("Module registry, egress declarations, evidence, envelopes, budgets, work orders")
struct RegistryAndPolicyTests {
    let registry = ModuleRegistry.p0()

    // MARK: Registry

    @Test("The P0 registry table is valid and has no network outside HIGH-tier modules")
    func p0Valid() throws {
        _ = try ModuleRegistry(ModuleRegistry.p0Descriptors)
        for d in ModuleRegistry.p0Descriptors where !d.networkCapabilities.isEmpty {
            #expect(d.securityTier == .high)
        }
    }

    @Test("V15-T-AGT-04 unknown or unregistered specialist → default deny", arguments: ["OCT-99", "", "oct-05", "ADMIN"])
    func unknownModule(_ raw: String) {
        #expect(registry.decide(module: raw, capability: .wardrobeRead) == .denied(.unknownModule))
    }

    @Test("Unregistered but valid IDs are denied too")
    func unregistered() {
        let unregistered = ModuleID.allCases.filter { registry.descriptor($0) == nil }
        #expect(!unregistered.isEmpty)
        for id in unregistered {
            for cap in Capability.allCases { #expect(registry.decide(module: id, capability: cap) == .denied(.unknownModule)) }
        }
    }

    @Test("V15-T-AGT-01 garment vision cannot reach the network or write")
    func visionNoNetwork() {
        #expect(registry.decide(module: .garmentVision, capability: .networkProductOnly) == .denied(.capabilityNotGranted))
        #expect(registry.decide(module: .garmentVision, capability: .weatherFetch) == .denied(.capabilityNotGranted))
        #expect(registry.decide(module: .garmentVision, capability: .wardrobeWrite) == .denied(.capabilityNotGranted))
        #expect(registry.decide(module: .garmentVision, capability: .photosReadUserSelected) == .allowed)
    }

    @Test("V15-T-AGT-03 retail gateway cannot read body, avatar, photos, wardrobe or trips")
    func retailNoPrivate() {
        for cap in [Capability.bodyReadExact, .avatarReadRenderSnapshot, .photosReadUserSelected, .wardrobeRead, .travelReadPrivate, .vaultExport] {
            #expect(registry.decide(module: .retailPrivacyGateway, capability: cap) == .denied(.capabilityNotGranted))
        }
    }

    @Test("No registered module may export the vault in P0")
    func noExport() {
        for id in registry.registeredIDs { #expect(!registry.decide(module: id, capability: .vaultExport).isAllowed) }
    }

    @Test("V15-T-AGT-05 a modified descriptor copy cannot widen the registry; bad tables are refused")
    func noEscalation() throws {
        let original = try #require(registry.descriptor(.styleDirector))
        let copy = descriptor(original.id, read: original.readScopes.union([.bodyReadExact]))
        #expect(registry.decide(module: .styleDirector, capability: .bodyReadExact) == .denied(.capabilityNotGranted))
        // Registering the same ID twice (an attempted override) is refused.
        #expect(throws: FaultCode.schemaInvalid) { try ModuleRegistry(ModuleRegistry.p0Descriptors + [copy]) }
        // A low-trust parser may not get network; a non-HIGH module may not either.
        #expect(throws: FaultCode.policyDenied) { try ModuleRegistry([descriptor(.materialAnalyst, net: [.networkProductOnly], tier: .low)]) }
        #expect(throws: FaultCode.policyDenied) { try ModuleRegistry([descriptor(.materialAnalyst, net: [.weatherFetch], tier: .standard)]) }
        // Network capabilities hidden in read scopes are rejected.
        #expect(throws: FaultCode.schemaInvalid) { try ModuleRegistry([descriptor(.materialAnalyst, read: [.networkProductOnly], tier: .high)]) }
        // An ML module without an evaluation dataset is rejected (§104).
        #expect(throws: FaultCode.schemaInvalid) { try ModuleRegistry([descriptor(.materialAnalyst, model: "fabric-v1")]) }
    }

    func descriptor(_ id: ModuleID, read: Set<Capability> = [], net: Set<Capability> = [], tier: ModuleDescriptor.SecurityTier = .standard,
                    model: String? = nil) -> ModuleDescriptor {
        ModuleDescriptor(id: id, owner: "x", inputs: ["in"], outputs: ["out"], readScopes: read, networkCapabilities: net, modelID: model,
                         deadlineMs: 1, confidencePolicy: "x", failureFallback: "x", prohibitedActions: ["x"], securityTier: tier)
    }

    @Test("Every P0 module declares inputs, outputs and prohibited actions, and none uses an ML model yet")
    func descriptorsComplete() {
        for d in ModuleRegistry.p0Descriptors {
            #expect(!d.inputs.isEmpty && !d.outputs.isEmpty && !d.prohibitedActions.isEmpty, "\(d.id)")
            #expect(d.modelID == nil)
        }
        #expect(ModuleRegistry.p0().registeredIDs.count == ModuleRegistry.p0Descriptors.count, "p0() fell back to denyAll")
        #expect(ModuleRegistry.denyAll.decide(module: .consentGuardian, capability: .vaultDelete) == .denied(.unknownModule))
    }

    // MARK: Egress

    func egress(classification: DataClassification = .publicProduct, fields: [String] = ["gtin", "country", "locale"],
                consent: EgressIntent.ConsentBasis = .explicitUserAction, host: String = "catalog.example.test",
                path: String = "/v1/products/resolve", tls: Bool = true, purpose: EgressIntent.Purpose = .productLookup) -> EgressIntent {
        EgressIntent(destinationHost: host, method: .get, endpointPath: path, classification: classification, purpose: purpose,
                     fields: fields, consentBasis: consent, userVisibleEffect: "Ürün bilgisi getirilir", retention: .cacheWithTTL, requiresTLS: tls)
    }

    @Test("Private and sensitive data cannot be declared for egress", arguments: [DataClassification.localPrivate, .localSensitive, .redactedDiagnostic, .syntheticFixture])
    func privateBlocked(_ c: DataClassification) {
        #expect(throws: FaultCode.egressBlocked) { try egress(classification: c).validate() }
    }

    @Test("Any field not on the purpose's allowlist is blocked", arguments: [
        "user_waist_cm", "photo", "avatar_mesh", "latitude", "profile_id", "trip_city",
        "lat", "lng", "coords", "address", "ip", "full_name", "size_cm", "city_center_coordinate",
    ])
    func unlistedFields(_ field: String) {
        #expect(throws: FaultCode.egressBlocked) { try egress(fields: ["gtin", field]).validate() }
    }

    @Test("Field names must be plain lower-case ASCII, so look-alike spellings cannot slip through", arguments: ["EXIF_GPS", "IDFA", "birthDate", "LATİTUDE", "latıtude", "gtin ", "gtin-2"])
    func oddFieldNames(_ field: String) {
        #expect(throws: FaultCode.schemaInvalid) { try egress(fields: ["gtin", field]).validate() }
    }

    @Test("Hosts must be plain DNS names", arguments: ["evil host", "localhost", "catalog.example.test:443", "Catalog.Example.test", ".example.test", "-x.example.test", "user@example.test"])
    func badHosts(_ host: String) {
        #expect(throws: FaultCode.schemaInvalid) { try egress(host: host).validate() }
    }

    @Test("Purpose and data class must match: public data cannot be relabelled as weather")
    func purposeClassPairs() {
        #expect(throws: FaultCode.egressBlocked) { try egress(fields: ["city_center_coordinate"], purpose: .weatherForecast).validate() }
        #expect(throws: FaultCode.egressBlocked) { try egress(classification: .localPrivate).validate() }
    }

    @Test("A trip's city-centre point may go to weather on an explicit tap, and nothing else may ride along")
    func weatherException() throws {
        func weather(_ fields: [String], _ purpose: EgressIntent.Purpose = .weatherForecast, consent: EgressIntent.ConsentBasis = .explicitUserAction) -> EgressIntent {
            EgressIntent(destinationHost: "weatherkit.apple.com", method: .get, endpointPath: "/api/v1/weather", classification: .localPrivate,
                         purpose: purpose, fields: fields, consentBasis: consent, userVisibleEffect: "Hava tahmini", retention: .cacheWithTTL)
        }
        try weather(["city_center_coordinate"]).validate()
        #expect(throws: FaultCode.egressBlocked) { try weather(["city_center_coordinate"], consent: .none).validate() }
        #expect(throws: FaultCode.egressBlocked) { try weather(["city_center_coordinate", "trip_dates"]).validate() }
        #expect(throws: FaultCode.egressBlocked) { try weather(["device_coordinate"]).validate() }
        #expect(throws: FaultCode.egressBlocked) { try weather(["city_center_coordinate"], .productLookup).validate() }
    }

    @Test("Without an explicit user action nothing leaves")
    func noConsent() {
        #expect(throws: FaultCode.egressBlocked) { try egress(consent: .none).validate() }
    }

    @Test("Malformed destinations are invalid")
    func malformed() {
        #expect(throws: FaultCode.schemaInvalid) { try egress(host: "https://catalog.example.test").validate() }
        #expect(throws: FaultCode.schemaInvalid) { try egress(path: "/v1/resolve?gtin=1").validate() }
        #expect(throws: FaultCode.schemaInvalid) { try egress(path: "v1/resolve").validate() }
        #expect(throws: FaultCode.schemaInvalid) { try egress(tls: false).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try egress(fields: []).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try egress(fields: ["gtin", "gtin"]).validate() }
    }

    // MARK: Evidence

    func licensed(source: EvidenceRecord.SourceType = .licensedCatalog, license: String? = "LIC-1", variant: String? = "V-1",
                  verification: EvidenceRecord.VerificationMethod = .partnerAttested, expires: Date? = nil,
                  effective: Date? = nil, tombstone: Bool = false) -> EvidenceRecord {
        EvidenceRecord(evidenceID: "e", factKey: "chest_width_cm", subjectProductID: "P", variantID: variant, factValue: "102", unit: "cm",
                       sourceType: source, sourceURIOrLicensedDatasetID: "ds", licenseID: license, collectedAt: Date(timeIntervalSince1970: 0),
                       effectiveFrom: effective, expiresAt: expires, confidenceKind: .heuristic, verificationMethod: verification,
                       revocationTombstone: tombstone)
    }

    @Test("Only licensed, identified, verified, current, unrevoked facts display as verified")
    func evidenceGate() throws {
        let now = Date(timeIntervalSince1970: 100)
        #expect(licensed().isDisplayableAsVerified(at: now))
        #expect(!licensed(license: nil).isDisplayableAsVerified(at: now))
        #expect(!licensed(variant: nil).isDisplayableAsVerified(at: now))
        #expect(!licensed(source: .review).isDisplayableAsVerified(at: now))
        #expect(!licensed(source: .syntheticFixture).isDisplayableAsVerified(at: now))
        #expect(!licensed(verification: .none).isDisplayableAsVerified(at: now))
        #expect(!licensed(expires: Date(timeIntervalSince1970: 50)).isDisplayableAsVerified(at: now))
        #expect(!licensed(effective: Date(timeIntervalSince1970: 200)).isDisplayableAsVerified(at: now))
        #expect(!licensed(tombstone: true).isDisplayableAsVerified(at: now))
        let golden = try ContractCoder.decode(EvidenceRecord.self, from: fixture("evidence_record_v1"))
        #expect(!golden.isDisplayableAsVerified(at: now), "synthetic fixture must never be verified")
    }

    @Test("A record that labels itself VERIFIED_FACTS without rights is invalid")
    func selfLabelledVerified() {
        var r = licensed(license: nil)
        r.confidenceKind = .verifiedFacts
        #expect(throws: FaultCode.schemaInvalid) { try r.validate() }
    }

    // MARK: Decision envelope

    @Test("Envelope shape follows its state")
    func envelopes() throws {
        typealias E = DecisionEnvelope<String>
        try E(traceID: "t", state: .completed, value: "ok", confidence: .heuristic).validate()
        for fault in FaultCode.allCases { try E.failure(traceID: "t", fault).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try E(traceID: "t", state: .completed, value: nil, confidence: .heuristic).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try E(traceID: "t", state: .degraded, value: "2D", confidence: .partial).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try E(traceID: "t", state: .failed, value: "x", confidence: .abstain, fault: .moduleFailed).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try E(traceID: "t", state: .running, value: "x", confidence: .partial).validate() }
        #expect(throws: FaultCode.schemaInvalid) { try E(traceID: "t", state: .completed, value: "x", confidence: .partial, reasons: ["a", "b", "c", "d"]).validate() }
    }

    @Test("Failures keep their own state: a crash is never shown as a policy block")
    func failureStates() {
        typealias E = DecisionEnvelope<String>
        #expect(E.failure(traceID: "t", .moduleFailed).state == .failed)
        #expect(E.failure(traceID: "t", .offline).state == .failed)
        #expect(E.failure(traceID: "t", .resourceDenied).state == .failed)
        #expect(E.failure(traceID: "t", .policyDenied).state == .blockedPolicy)
        #expect(E.failure(traceID: "t", .egressBlocked).state == .blockedPolicy)
        #expect(E.failure(traceID: "t", .cancelled).state == .cancelled)
        #expect(E.failure(traceID: "t", .timedOut).state == .timedOut)
    }

    @Test("V15-T-AGT-06 a verified answer must cite real, displayable evidence")
    func verifiedNeedsEvidence() throws {
        typealias E = DecisionEnvelope<String>
        let now = Date(timeIntervalSince1970: 100)
        #expect(throws: FaultCode.dataRightsMissing) { try E(traceID: "t", state: .completed, value: "M", confidence: .verifiedFacts).validate() }
        #expect(throws: FaultCode.dataRightsMissing) { try E(traceID: "t", state: .completed, value: "M", confidence: .verifiedFacts, evidenceIDs: [""]).validate() }
        #expect(throws: FaultCode.dataRightsMissing) { try E(traceID: "t", state: .completed, value: "M", confidence: .verifiedFacts, evidenceIDs: ["e", "e"]).validate() }
        // Verified never rides on a degraded or failed result.
        #expect(throws: FaultCode.schemaInvalid) {
            try E(traceID: "t", state: .degraded, value: "M", confidence: .verifiedFacts, limitations: ["x"], fault: .resourceDenied, evidenceIDs: ["e"]).validate()
        }
        // Resolution: an invented ID or a non-verifiable record fails; a licensed one passes.
        let good = E(traceID: "t", state: .completed, value: "M", confidence: .verifiedFacts, evidenceIDs: ["e"])
        #expect(throws: FaultCode.dataRightsMissing) { try good.validate(citing: [], now: now) }
        #expect(throws: FaultCode.dataRightsMissing) { try good.validate(citing: [licensed(source: .syntheticFixture)], now: now) }
        try good.validate(citing: [licensed()], now: now)
    }

    // MARK: Budgets

    @Test("Every default budget is valid; delete/slider stay possible in the foreground")
    func budgets() throws {
        for tier in ExecutionTier.allCases {
            let b = DeviceBudget.defaults(for: tier)
            try b.validate()
            #expect(!b.allowsPhysics)
            if tier != .lockedBackground { #expect(b.allows(.p0Interactive)) }
        }
        #expect(DeviceBudget.defaults(for: .survival).allowedPriorities == [.p0Interactive])
        #expect(DeviceBudget.defaults(for: .survival).maxVisualTier == .flat2D)
        #expect(!DeviceBudget.defaults(for: .offline).allowsNetwork)
    }

    @Test("A budget that drops P0 in the foreground or allows offline network is invalid")
    func badBudgets() {
        var b = DeviceBudget.defaults(for: .conserve)
        b.allowedPriorities = [.p1UserRequested]
        #expect(throws: FaultCode.schemaInvalid) { try b.validate() }
        b = DeviceBudget.defaults(for: .offline)
        b.allowsNetwork = true
        #expect(throws: FaultCode.schemaInvalid) { try b.validate() }
    }

    // MARK: Work orders

    @Test("Work orders scope paths and refuse real person data")
    func workOrders() throws {
        let order = try ContractCoder.decode(WorkOrder.self, from: fixture("work_order_v1"))
        #expect(order.permits(path: "Packages/KabinsizCore/Sources/Vault/Keys.swift"))
        #expect(!order.permits(path: "Packages/KabinsizCore/Sources/TravelEngine/TripPlanner.swift"))
        #expect(!order.permits(path: ".env"))

        var bad = order
        bad.allowedDataClasses.append(.localSensitive)
        #expect(throws: FaultCode.policyDenied) { try bad.validate() }
        bad = order
        bad.prohibitedPaths.append("Packages/KabinsizCore/Sources/**")
        #expect(throws: FaultCode.schemaInvalid) { try bad.validate() }
        bad = order
        bad.dependencies.append(order.id)
        #expect(throws: FaultCode.schemaInvalid) { try bad.validate() }
        bad = order
        bad.acceptanceTests = []
        #expect(throws: FaultCode.schemaInvalid) { try bad.validate() }
        bad = order
        bad.allowedPaths.append("../outside/**")
        #expect(throws: FaultCode.schemaInvalid) { try bad.validate() }
    }

    @Test("Path traversal cannot escape a work order's scope", arguments: [
        "Packages/KabinsizCore/Sources/Vault/../../../../apps/ios/Kabinsiz/Features/X.swift",
        "Packages/KabinsizCore/Sources/Vault/./Keys.swift", "Packages/KabinsizCore/Sources/Vault//Keys.swift",
        "/Packages/KabinsizCore/Sources/Vault/Keys.swift", "",
    ])
    func traversal(_ path: String) throws {
        let order = try ContractCoder.decode(WorkOrder.self, from: fixture("work_order_v1"))
        #expect(!order.permits(path: path))
    }
}
