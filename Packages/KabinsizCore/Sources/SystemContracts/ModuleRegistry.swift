import Foundation

/// One runtime specialist's contract (§104). A module gets exactly these capabilities and nothing else.
public struct ModuleDescriptor: Codable, Hashable, Sendable {
    public enum SecurityTier: String, Codable, Sendable {
        /// Parses untrusted input (photos, catalog text). No writes, no network.
        case low = "LOW"
        case standard = "STANDARD"
        /// Touches network or deletion. Reviewed separately.
        case high = "HIGH"
    }

    /// Coarse cost class the governor budgets against (§113). Measured numbers come later, per device.
    public enum ResourceCost: String, Codable, Sendable { case light = "LIGHT", heavy = "HEAVY" }

    public let id: ModuleID
    public let owner: String
    public let version: Int
    /// Typed inputs and outputs by name; the Swift types behind them live in `implementedBy`.
    public let inputs: [String]
    public let outputs: [String]
    public let readScopes: Set<Capability>
    public let writeScopes: Set<Capability>
    public let networkCapabilities: Set<Capability>
    /// `nil` = deterministic code, no ML model. Every P0 module is deterministic today.
    public let modelID: String?
    public let resourceCost: ResourceCost
    public let deadlineMs: Int
    public let confidencePolicy: String
    public let failureFallback: String
    public let evaluationDataset: String?
    public let goldenTests: [String]
    public let prohibitedActions: [String]
    public let securityTier: SecurityTier
    /// Existing code that currently implements this specialist.
    public let implementedBy: [String]

    public init(
        id: ModuleID, owner: String, version: Int = 1, inputs: [String], outputs: [String],
        readScopes: Set<Capability> = [], writeScopes: Set<Capability> = [], networkCapabilities: Set<Capability> = [],
        modelID: String? = nil, resourceCost: ResourceCost = .light, deadlineMs: Int, confidencePolicy: String,
        failureFallback: String, evaluationDataset: String? = nil, goldenTests: [String] = [], prohibitedActions: [String],
        securityTier: SecurityTier, implementedBy: [String] = []
    ) {
        self.id = id
        self.owner = owner
        self.version = version
        self.inputs = inputs
        self.outputs = outputs
        self.readScopes = readScopes
        self.writeScopes = writeScopes
        self.networkCapabilities = networkCapabilities
        self.modelID = modelID
        self.resourceCost = resourceCost
        self.deadlineMs = deadlineMs
        self.confidencePolicy = confidencePolicy
        self.failureFallback = failureFallback
        self.evaluationDataset = evaluationDataset
        self.goldenTests = goldenTests
        self.prohibitedActions = prohibitedActions
        self.securityTier = securityTier
        self.implementedBy = implementedBy
    }

    public var allCapabilities: Set<Capability> { readScopes.union(writeScopes).union(networkCapabilities) }

    public func validate() throws(FaultCode) {
        guard version >= 1, deadlineMs > 0, !owner.isEmpty, !failureFallback.isEmpty, !confidencePolicy.isEmpty,
              !inputs.isEmpty, !outputs.isEmpty, !prohibitedActions.isEmpty,
              networkCapabilities.allSatisfy(\.isNetwork),
              !readScopes.union(writeScopes).contains(where: \.isNetwork),
              // An ML module must name the dataset it is evaluated on (§104, §114).
              modelID == nil || evaluationDataset != nil
        else { throw .schemaInvalid }
        // Low-trust parsers of untrusted input may never write or reach the network (§112.1).
        if securityTier == .low, !(writeScopes.isEmpty && networkCapabilities.isEmpty) { throw .policyDenied }
        if !networkCapabilities.isEmpty, securityTier != .high { throw .policyDenied }
    }

    enum CodingKeys: String, CodingKey {
        case id, owner, version, inputs, outputs, readScopes = "read_scopes", writeScopes = "write_scopes"
        case networkCapabilities = "network_capabilities", modelID = "model_id", resourceCost = "resource_cost"
        case deadlineMs = "deadline_ms", confidencePolicy = "confidence_policy", failureFallback = "failure_fallback"
        case evaluationDataset = "evaluation_dataset", goldenTests = "golden_tests", prohibitedActions = "prohibited_actions"
        case securityTier = "security_tier", implementedBy = "implemented_by"
    }

    /// Capability sets are written sorted so the registry always encodes to the same bytes.
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(owner, forKey: .owner)
        try c.encode(version, forKey: .version)
        try c.encode(inputs, forKey: .inputs)
        try c.encode(outputs, forKey: .outputs)
        try c.encode(sortedRaw(readScopes), forKey: .readScopes)
        try c.encode(sortedRaw(writeScopes), forKey: .writeScopes)
        try c.encode(sortedRaw(networkCapabilities), forKey: .networkCapabilities)
        try c.encodeIfPresent(modelID, forKey: .modelID)
        try c.encode(resourceCost, forKey: .resourceCost)
        try c.encode(deadlineMs, forKey: .deadlineMs)
        try c.encode(confidencePolicy, forKey: .confidencePolicy)
        try c.encode(failureFallback, forKey: .failureFallback)
        try c.encodeIfPresent(evaluationDataset, forKey: .evaluationDataset)
        try c.encode(goldenTests, forKey: .goldenTests)
        try c.encode(prohibitedActions, forKey: .prohibitedActions)
        try c.encode(securityTier, forKey: .securityTier)
        try c.encode(implementedBy, forKey: .implementedBy)
    }
}

public enum CapabilityDecision: Hashable, Sendable {
    case allowed
    case denied(FaultCode)

    public var isAllowed: Bool { self == .allowed }
}

/// Immutable registry built once at launch. There is no API to add, remove or widen a module after
/// construction, so a specialist cannot escalate its own permissions (V15-T-AGT-05).
public struct ModuleRegistry: Sendable {
    private let modules: [ModuleID: ModuleDescriptor]

    public init(_ descriptors: [ModuleDescriptor]) throws(FaultCode) {
        var map: [ModuleID: ModuleDescriptor] = [:]
        for d in descriptors {
            try d.validate()
            guard map[d.id] == nil else { throw .schemaInvalid }
            map[d.id] = d
        }
        modules = map
    }

    /// An empty registry denies everything. Used as the fail-closed fallback if the table is invalid.
    public static let denyAll: ModuleRegistry = { do { return try ModuleRegistry([]) } catch { fatalError("unreachable") } }()

    public var registeredIDs: [ModuleID] { modules.keys.sorted { $0.rawValue < $1.rawValue } }

    public func descriptor(_ id: ModuleID) -> ModuleDescriptor? { modules[id] }

    /// Default deny: unknown module, unregistered module or ungranted capability (V15-T-AGT-04).
    public func decide(module rawID: String, capability: Capability) -> CapabilityDecision {
        guard let id = ModuleID(rawValue: rawID) else { return .denied(.unknownModule) }
        return decide(module: id, capability: capability)
    }

    public func decide(module id: ModuleID, capability: Capability) -> CapabilityDecision {
        guard let d = modules[id] else { return .denied(.unknownModule) }
        return d.allCapabilities.contains(capability) ? .allowed : .denied(.capabilityNotGranted)
    }
}

extension ModuleRegistry {
    /// P0 registry: only specialists that exist in code or are next in the v1.5 queue. Everything else in
    /// `ModuleID` stays unregistered and is denied. If the table were ever invalid, the result is `denyAll`,
    /// never a crash and never a partial registry.
    public static func p0() -> ModuleRegistry {
        (try? ModuleRegistry(p0Descriptors)) ?? .denyAll
    }

    public static let p0Descriptors: [ModuleDescriptor] = [
        .init(id: .consentGuardian, owner: "AG-09", inputs: ["UserIntent.delete"], outputs: ["DeletionReceipt"],
              writeScopes: [.vaultDelete], deadlineMs: 2_000, confidencePolicy: "Not applicable: user command",
              failureFallback: "Deny and keep data; show retry", goldenTests: ["T-TRV-013"],
              prohibitedActions: ["Delete without an explicit user command", "Export data"], securityTier: .high,
              implementedBy: ["AppModel.deleteAllData", "AppModel.deleteTrip", "Octopus.BodyStudio.deleteProfile"]),
        .init(id: .garmentVision, owner: "AG-05", inputs: ["UserSelectedImage"], outputs: ["GarmentCandidate"],
              readScopes: [.photosReadUserSelected], resourceCost: .heavy, deadlineMs: 1_500,
              confidencePolicy: "Uncalibrated: always ask the user to confirm", failureFallback: "Manual garment entry",
              prohibitedActions: ["Network", "Read the whole photo library", "Change body data"], securityTier: .low),
        .init(id: .bodyGeometry, owner: "AG-04", inputs: ["UserMeasurements"], outputs: ["BodyRevision"],
              readScopes: [.bodyReadExact], writeScopes: [.bodyWriteManual], deadlineMs: 50,
              confidencePolicy: "User-entered values are the truth; photo estimates are labelled hypotheses",
              failureFallback: "Restore last valid body revision",
              goldenTests: ["V15-T-BOD-01", "V15-T-BOD-02", "V15-T-BOD-03", "V15-T-BOD-04", "V15-T-ORC-08"],
              prohibitedActions: ["Network", "Read travel history", "Infer gender, age or health"], securityTier: .standard,
              implementedBy: ["BodyGeometry.BodyProfile", "BodyGeometry.Silhouette", "Octopus.BodyStudio"]),
        .init(id: .avatarRenderer, owner: "AG-04", inputs: ["AvatarSnapshot"], outputs: ["RenderedScene"],
              readScopes: [.avatarReadRenderSnapshot], resourceCost: .heavy, deadlineMs: 33,
              confidencePolicy: "Shows its visual fidelity tier", failureFallback: "2D silhouette card",
              goldenTests: ["V15-T-BOD-07", "V15-T-BOD-08", "V15-T-ORC-09"],
              prohibitedActions: ["Write measurements", "Export the mesh"], securityTier: .standard,
              implementedBy: ["Octopus.PreviewScene"]),
        .init(id: .productIdentifier, owner: "AG-08", inputs: ["ProductCode"], outputs: ["ResolveResult"],
              readScopes: [.catalogReadLicensed], deadlineMs: 300, confidencePolicy: "Exact match or ambiguous/not found; never a guess",
              failureFallback: "Not found card", goldenTests: ["T-V13-003", "T-V13-004", "T-V13-034"],
              prohibitedActions: ["Network", "Guess a product"], securityTier: .low,
              implementedBy: ["ShoppingCopilot.ProductResolver"]),
        .init(id: .fitSpecialist, owner: "AG-06", inputs: ["UserMeasurements", "SizeChart", "FitPassport"], outputs: ["SizeAdvice"],
              readScopes: [.bodyReadExact, .catalogReadLicensed], deadlineMs: 200,
              confidencePolicy: "Abstain unless ≥2 consistent records or a unique chart row; no percentages",
              failureFallback: "Abstain: not enough data", goldenTests: ["T-V13-015", "T-V13-019"],
              prohibitedActions: ["Network", "Write body truth", "Read photos"], securityTier: .standard,
              implementedBy: ["FitPassport.SizeAdvisor"]),
        .init(id: .styleDirector, owner: "AG-07", inputs: ["Wardrobe", "Occasion", "WeatherSnapshot"], outputs: ["OutfitCandidate"],
              readScopes: [.wardrobeRead], deadlineMs: 500, confidencePolicy: "Rule-based reasons only",
              failureFallback: "Deterministic rules", goldenTests: ["T-V13-045", "T-V13-046"],
              prohibitedActions: ["Read exact body measurements", "Use protected traits"], securityTier: .standard,
              implementedBy: ["ShoppingCopilot.ShoppingGuard", "TravelEngine.OutfitCandidateGenerator"]),
        .init(id: .weatherContext, owner: "AG-11", inputs: ["Destination (city centre)", "LocalDate range"], outputs: ["WeatherSnapshot"],
              networkCapabilities: [.weatherFetch], deadlineMs: 3_000,
              confidencePolicy: "Evidence label on every day; NO_DATA beyond the returned horizon",
              failureFallback: "NO_DATA or cached, labelled", goldenTests: ["T-TRV-018", "T-TRV-019", "T-TRV-021"],
              prohibitedActions: ["Use device location", "Request without a user tap"], securityTier: .high,
              implementedBy: ["TravelEngine.WeatherProvider", "AppleWeatherProvider"]),
        .init(id: .occasionVenue, owner: "AG-02", inputs: ["FamousStreet (catalogue point)"], outputs: ["Look Around scene"],
              networkCapabilities: [.streetImageryFetch], deadlineMs: 5_000,
              confidencePolicy: "A scene or none; no scene → owned 3D street or studio, said on screen",
              failureFallback: "Owned 3D street, else studio", goldenTests: ["UI28-T060", "UI28-T061"],
              prohibitedActions: ["Use device location", "Request without a user tap", "Store or export imagery"], securityTier: .high,
              implementedBy: ["LookAroundProvider"]),
        .init(id: .wardrobeSteward, owner: "AG-07", inputs: ["Garment edits"], outputs: ["Wardrobe"],
              readScopes: [.wardrobeRead], writeScopes: [.wardrobeWrite], deadlineMs: 200,
              confidencePolicy: "User-confirmed state only", failureFallback: "Keep last saved wardrobe",
              prohibitedActions: ["Network", "Mark items dirty without the user"], securityTier: .standard,
              implementedBy: ["WardrobeDomain.Wardrobe"]),
        .init(id: .capsuleTravelPlanner, owner: "AG-07", inputs: ["Trip", "Wardrobe", "WeatherSnapshot"], outputs: ["TripPlan", "PackingList"],
              readScopes: [.travelReadPrivate, .wardrobeRead], resourceCost: .heavy, deadlineMs: 2_000,
              confidencePolicy: "Partial when any slot is uncovered or weather is missing",
              failureFallback: "Generic packing list with explicit gaps", goldenTests: ["T-TRV-042", "T-TRV-046", "T-TRV-062"],
              prohibitedActions: ["Network", "Mark items packed or worn"], securityTier: .standard,
              implementedBy: ["TravelEngine.TripPlanner"]),
        .init(id: .fitMemoryLearner, owner: "AG-06", inputs: ["FitObservation"], outputs: ["FitPassport"],
              writeScopes: [.learningUpdateLocal], deadlineMs: 200, confidencePolicy: "Learning switch and brand exclusions respected",
              failureFallback: "Do not learn; keep previous passport", goldenTests: ["T-V13-016", "T-V13-020"],
              prohibitedActions: ["Network", "Train on other users"], securityTier: .standard,
              implementedBy: ["FitPassport.FitPassport.record"]),
        .init(id: .retailPrivacyGateway, owner: "AG-09", inputs: ["ProductCode"], outputs: ["Sanitized product facts"],
              readScopes: [.catalogReadLicensed], networkCapabilities: [.networkProductOnly], deadlineMs: 3_000,
              confidencePolicy: "Facts carry EvidenceRecord provenance", failureFallback: "Offline catalog or not found",
              prohibitedActions: ["Send avatar, photos, body, wardrobe or trips", "Execute catalog text"], securityTier: .high),
        .init(id: .healthIntegrityWatch, owner: "AG-11", inputs: ["Redacted counters"], outputs: ["Local diagnostics"],
              readScopes: [.diagnosticsReadRedacted], deadlineMs: 100, confidencePolicy: "Not applicable",
              failureFallback: "No diagnostics", prohibitedActions: ["Log secrets or personal data", "Network"], securityTier: .standard),
    ]
}
