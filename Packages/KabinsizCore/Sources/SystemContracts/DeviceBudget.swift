import DomainContracts
import Foundation

/// Scheduling priority (§103.2).
public enum TaskPriority: String, Codable, CaseIterable, Comparable, Sendable {
    /// Avatar slider, permission prompt, cached outfit, delete data.
    case p0Interactive = "P0"
    case p1UserRequested = "P1"
    case p2Opportunistic = "P2"
    case p3Maintenance = "P3"

    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

/// Execution tier (§113.1). Thresholds that pick a tier belong to the governor (WP15-06), not here.
public enum ExecutionTier: String, Codable, CaseIterable, Sendable {
    case turbo = "TURBO", balanced = "BALANCED", conserve = "CONSERVE", survival = "SURVIVAL"
    case offline = "OFFLINE", lockedBackground = "LOCKED_BACKGROUND"
}

/// What work a tier allows. There is no field that relaxes privacy or authentication: speed is bought
/// with visual quality and deferral only (INV-09).
public struct DeviceBudget: VersionedContract, Hashable {
    public static var currentSchemaVersion: Int { 1 }
    public static var knownKeys: Set<String> { Set(CodingKeys.allCases.map(\.stringValue)) }

    public var schemaVersion: Int
    public var tier: ExecutionTier
    public var maxConcurrentHeavyTasks: Int
    public var allowedPriorities: Set<TaskPriority>
    public var allowsBackgroundInference: Bool
    public var allowsPhysics: Bool
    public var maxVisualTier: VisualFidelityTier
    public var allowsNetwork: Bool

    enum CodingKeys: String, CodingKey, CaseIterable {
        case schemaVersion = "schema_version", tier, maxConcurrentHeavyTasks = "max_concurrent_heavy_tasks"
        case allowedPriorities = "allowed_priorities", allowsBackgroundInference = "allows_background_inference"
        case allowsPhysics = "allows_physics", maxVisualTier = "max_visual_tier", allowsNetwork = "allows_network"
    }

    /// Starting hypotheses from §113.1, to be calibrated on named devices. Not performance claims.
    public static func defaults(for tier: ExecutionTier) -> DeviceBudget {
        switch tier {
        case .turbo: .init(tier, heavy: 2, [.p0Interactive, .p1UserRequested, .p2Opportunistic, .p3Maintenance], background: true, physics: false, .productAsset, network: true)
        case .balanced: .init(tier, heavy: 1, [.p0Interactive, .p1UserRequested, .p2Opportunistic], background: false, physics: false, .genericMesh, network: true)
        case .conserve: .init(tier, heavy: 1, [.p0Interactive, .p1UserRequested], background: false, physics: false, .flat2D, network: true)
        case .survival: .init(tier, heavy: 0, [.p0Interactive], background: false, physics: false, .flat2D, network: false)
        case .offline: .init(tier, heavy: 1, [.p0Interactive, .p1UserRequested, .p2Opportunistic], background: false, physics: false, .genericMesh, network: false)
        case .lockedBackground: .init(tier, heavy: 0, [.p3Maintenance], background: false, physics: false, .flat2D, network: false)
        }
    }

    private init(_ tier: ExecutionTier, heavy: Int, _ priorities: Set<TaskPriority>, background: Bool, physics: Bool, _ visual: VisualFidelityTier, network: Bool) {
        schemaVersion = Self.currentSchemaVersion
        self.tier = tier
        maxConcurrentHeavyTasks = heavy
        allowedPriorities = priorities
        allowsBackgroundInference = background
        allowsPhysics = physics
        maxVisualTier = visual
        allowsNetwork = network
    }

    public func allows(_ priority: TaskPriority) -> Bool { allowedPriorities.contains(priority) }

    /// Sets are written sorted so the same budget always produces the same bytes.
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(tier, forKey: .tier)
        try c.encode(maxConcurrentHeavyTasks, forKey: .maxConcurrentHeavyTasks)
        try c.encode(sortedRaw(allowedPriorities), forKey: .allowedPriorities)
        try c.encode(allowsBackgroundInference, forKey: .allowsBackgroundInference)
        try c.encode(allowsPhysics, forKey: .allowsPhysics)
        try c.encode(maxVisualTier, forKey: .maxVisualTier)
        try c.encode(allowsNetwork, forKey: .allowsNetwork)
    }

    public func validate() throws(FaultCode) {
        guard schemaVersion == Self.currentSchemaVersion, maxConcurrentHeavyTasks >= 0, !allowedPriorities.isEmpty
        else { throw .schemaInvalid }
        // Physics stays off until a physics model, input rights and hardware benchmarks pass (§113.2 stage 4).
        guard !allowsPhysics else { throw .policyDenied }
        // Deleting data and the slider (P0) must stay possible whenever the app is in the foreground.
        if tier != .lockedBackground, !allows(.p0Interactive) { throw .schemaInvalid }
        if tier == .offline || tier == .survival || tier == .lockedBackground, allowsNetwork { throw .schemaInvalid }
    }
}
