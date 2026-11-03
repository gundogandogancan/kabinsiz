import Foundation
import SystemContracts

/// A reservation of device resources for one run. Released exactly once, on every path.
public struct ResourceGrant: Hashable, Sendable {
    public let id: UUID
    public let priority: TaskPriority
    public let heavySlots: Int
    public let tier: ExecutionTier
}

/// The §113 seam. WP15-05 ships a budget-only governor; WP15-06 feeds it thermal, low-power and
/// memory signals. Synchronous on purpose, so `defer` can release a grant on every exit path.
public protocol ResourceGovernor: Sendable {
    func reserve(priority: TaskPriority, heavySlots: Int, needsNetwork: Bool) -> ResourceGrant?
    func release(_ grant: ResourceGrant)
    var activeGrantCount: Int { get }
    var budget: DeviceBudget { get }
}

/// Counts grants against a `DeviceBudget`: the priority must be allowed, heavy work must fit the
/// tier's slots, and network work needs a tier that allows network.
public final class BudgetGovernor: ResourceGovernor, @unchecked Sendable {
    private let lock = NSLock()
    private var current: DeviceBudget
    private var active: [UUID: ResourceGrant] = [:]

    public init(budget: DeviceBudget = .defaults(for: .balanced)) { current = budget }

    public var budget: DeviceBudget { lock.withLock { current } }
    public var activeGrantCount: Int { lock.withLock { active.count } }

    public func setBudget(_ budget: DeviceBudget) { lock.withLock { current = budget } }

    public func reserve(priority: TaskPriority, heavySlots: Int, needsNetwork: Bool) -> ResourceGrant? {
        lock.withLock {
            guard current.allows(priority), !(needsNetwork && !current.allowsNetwork) else { return nil }
            let usedHeavy = active.values.reduce(0) { $0 + $1.heavySlots }
            // P0 interactive work is never refused for heavy slots; it is kept light by design instead.
            guard heavySlots == 0 || priority == .p0Interactive || usedHeavy + heavySlots <= current.maxConcurrentHeavyTasks else { return nil }
            let grant = ResourceGrant(id: UUID(), priority: priority, heavySlots: heavySlots, tier: current.tier)
            active[grant.id] = grant
            return grant
        }
    }

    public func release(_ grant: ResourceGrant) {
        lock.withLock { _ = active.removeValue(forKey: grant.id) }
    }
}

/// Stops calling an operation that keeps failing (§103.1): after `threshold` consecutive failures it is
/// skipped for `cooldown`, and its fallback is used directly instead of cascading retries. Keyed per
/// module *and* node, so a failing write cannot block the morph of the same module. Skips are not
/// failures (no re-arming while the user keeps dragging); after the cooldown one call probes it
/// (half-open): success closes it, failure opens it again.
struct CircuitBreaker {
    let threshold: Int
    let cooldown: TimeInterval
    private var failures: [String: Int] = [:]
    private var openUntil: [String: Date] = [:]

    init(threshold: Int, cooldown: TimeInterval) {
        self.threshold = threshold
        self.cooldown = cooldown
    }

    static func key(_ node: TaskNode) -> String { "\(node.module.rawValue)#\(node.id)" }

    func isOpen(_ key: String, now: Date) -> Bool { (openUntil[key] ?? .distantPast) > now }

    mutating func recordSuccess(_ key: String) {
        failures[key] = 0
        openUntil[key] = nil
    }

    mutating func recordFailure(_ key: String, now: Date) {
        let count = (failures[key] ?? 0) + 1
        failures[key] = count
        if count >= threshold { openUntil[key] = now.addingTimeInterval(cooldown) }
    }
}
