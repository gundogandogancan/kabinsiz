import Foundation
import SystemContracts

/// The single §113 governor for concurrent work. It turns device signals into a tier and a budget,
/// admits or refuses work against that budget, and takes grants back when the tier drops.
///
/// - Downgrades apply at once; upgrades wait `recoveryDelay` of steadily better signals (hysteresis),
///   so a phone hovering between two thermal states does not flap the UI.
/// - P0 grants (slider, save, delete) are never taken back. A new P0 is refused only while locked or
///   in the background, where the vault cannot be trusted to open (V15-T-DEV-10).
/// - A memory warning evicts registered caches; it never touches uncommitted user state (DEV-05).
public final class DeviceResourceGovernor: ResourceGovernor, @unchecked Sendable {
    public typealias Evictor = @Sendable () async -> Int

    public struct EvictionReport: Hashable, Sendable {
        /// Cache name → items freed. Names only, never contents.
        public let freed: [String: Int]
    }

    private struct Entry {
        let grant: ResourceGrant
        let sequence: Int
        var onPreempt: (@Sendable () -> Void)?
    }

    private let lock = NSLock()
    private let clock: @Sendable () -> Date
    private let recoveryDelay: TimeInterval
    private let memoryCalmDelay: TimeInterval
    private var signals: DeviceSignals
    private var applied: HealthLevel
    private var upgradeSince: Date?
    private var lastMemoryWarning: Date?
    private var current: TierDecision
    private var active: [UUID: Entry] = [:]
    private var preempted: Set<UUID> = []
    private var sequence = 0
    private var evictors: [UUID: (name: String, evict: Evictor)] = [:]
    private var observers: [UUID: @Sendable (TierDecision) -> Void] = [:]
    private var unlockWaiters: [UUID: CheckedContinuation<Void, any Error>] = [:]
    private var preemptionCount = 0

    public init(
        signals: DeviceSignals = DeviceSignals(), recoveryDelay: TimeInterval = 20, memoryCalmDelay: TimeInterval = 60,
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.signals = signals
        self.recoveryDelay = recoveryDelay
        self.memoryCalmDelay = memoryCalmDelay
        self.clock = clock
        let (health, reasons) = TierPolicy.health(for: signals)
        applied = health
        current = TierPolicy.decide(signals, health: health, reasons: reasons)
    }

    // MARK: Reading

    public var decision: TierDecision { refreshed().decision }
    public var budget: DeviceBudget { decision.budget }
    public var activeGrantCount: Int { lock.withLock { active.count } }
    /// How many grants were taken back since launch (evidence and tests; no identities).
    public var preemptions: Int { lock.withLock { preemptionCount } }
    public var protectedDataAvailable: Bool { lock.withLock { signals.presence != .locked } }

    // MARK: Signals

    /// Replaces the whole reading. Returns the decision now in force.
    @discardableResult
    public func update(_ next: DeviceSignals) -> TierDecision {
        update { $0 = next }
    }

    @discardableResult
    public func update(_ mutate: (inout DeviceSignals) -> Void) -> TierDecision {
        let (unlocked, waiters): (Bool, [CheckedContinuation<Void, any Error>]) = lock.withLock {
            let wasLocked = signals.presence == .locked
            mutate(&signals)
            guard wasLocked, signals.presence != .locked else { return (false, []) }
            let all = Array(unlockWaiters.values)
            unlockWaiters.removeAll()
            return (true, all)
        }
        let result = refreshed()
        if unlocked { waiters.forEach { $0.resume() } }
        return result.decision
    }

    /// `UIApplication.didReceiveMemoryWarningNotification`: frees every registered cache and holds the
    /// tier at CONSERVE until `memoryCalmDelay` passes without another warning (drill 8).
    @discardableResult
    public func noteMemoryWarning() async -> EvictionReport {
        let caches: [(String, Evictor)] = lock.withLock {
            lastMemoryWarning = clock()
            return evictors.values.map { ($0.name, $0.evict) }
        }
        _ = refreshed()
        var freed: [String: Int] = [:]
        for (name, evict) in caches { freed[name, default: 0] += await evict() }
        return EvictionReport(freed: freed)
    }

    /// Registers a cache the governor may empty under memory pressure. Only rebuildable data belongs
    /// here: never a pending write, undo history or anything the user has not saved.
    @discardableResult
    public func registerEvictable(_ name: String, evict: @escaping Evictor) -> UUID {
        let id = UUID()
        lock.withLock { evictors[id] = (name, evict) }
        return id
    }

    public func unregister(_ id: UUID) {
        lock.withLock {
            evictors[id] = nil
            observers[id] = nil
        }
    }

    /// Called with every new decision (UI note, camera cadence). Not called for the current one.
    @discardableResult
    public func observe(_ handler: @escaping @Sendable (TierDecision) -> Void) -> UUID {
        let id = UUID()
        lock.withLock { observers[id] = handler }
        return id
    }

    /// Suspends while protected data is unavailable; returns at once when it is. Vault work waits here
    /// instead of failing half-way or falling back to a plaintext copy (drill 3, V15-T-DEV-10).
    /// Throws `CancellationError` if the caller is cancelled while waiting.
    public func untilProtectedDataAvailable() async throws {
        let id = UUID()
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, any Error>) in
                // The cancel flag is set before `onCancel` runs and both take the lock, so a waiter is
                // either never stored (cancelled here) or removed and resumed by `onCancel`.
                enum Start { case ready, cancelled, waiting }
                let start: Start = lock.withLock {
                    if Task.isCancelled { return .cancelled }
                    if signals.presence != .locked { return .ready }
                    unlockWaiters[id] = c
                    return .waiting
                }
                switch start {
                case .ready: c.resume()
                case .cancelled: c.resume(throwing: CancellationError())
                case .waiting: break
                }
            }
        } onCancel: {
            let waiter = lock.withLock { unlockWaiters.removeValue(forKey: id) }
            waiter?.resume(throwing: CancellationError())
        }
    }

    // MARK: ResourceGovernor

    public func reserve(priority: TaskPriority, heavySlots: Int, needsNetwork: Bool) -> ResourceGrant? {
        let budget = refreshed().decision.budget
        return lock.withLock {
            guard Admission.admits(budget, active: active.values.map(\.grant), priority: priority, heavySlots: heavySlots, needsNetwork: needsNetwork)
            else { return nil }
            sequence += 1
            let grant = ResourceGrant(id: UUID(), priority: priority, heavySlots: heavySlots, tier: budget.tier, needsNetwork: needsNetwork)
            active[grant.id] = Entry(grant: grant, sequence: sequence)
            return grant
        }
    }

    public func release(_ grant: ResourceGrant) {
        lock.withLock {
            active[grant.id] = nil
            preempted.remove(grant.id)
        }
    }

    public func watch(_ grant: ResourceGrant, onPreempt: @escaping @Sendable () -> Void) {
        let already: Bool = lock.withLock {
            if preempted.contains(grant.id) { return true }
            active[grant.id]?.onPreempt = onPreempt
            return false
        }
        if already { onPreempt() }
    }

    // MARK: Decision

    /// Re-evaluates health with hysteresis, applies the decision, and takes back grants the new budget
    /// no longer covers. Handlers run outside the lock.
    private func refreshed() -> (decision: TierDecision, changed: Bool) {
        let now = clock()
        let (decision, changed, handlers, listeners): (TierDecision, Bool, [@Sendable () -> Void], [@Sendable (TierDecision) -> Void]) = lock.withLock {
            var effective = signals
            if let warned = lastMemoryWarning, now.timeIntervalSince(warned) < memoryCalmDelay {
                effective.memory = max(effective.memory, .warning)
            }
            var (raw, reasons) = TierPolicy.health(for: effective)
            if raw < applied {
                applied = raw
                upgradeSince = nil
            } else if raw > applied {
                if let since = upgradeSince, now.timeIntervalSince(since) >= recoveryDelay {
                    applied = raw
                    upgradeSince = nil
                } else {
                    if upgradeSince == nil { upgradeSince = now }
                    reasons.append(.recovering)
                }
            } else {
                upgradeSince = nil
            }
            let next = TierPolicy.decide(effective, health: applied, reasons: reasons)
            let changed = next != current
            current = next
            guard changed else { return (next, false, [], []) }
            return (next, true, takeBack(for: next.budget), Array(observers.values))
        }
        handlers.forEach { $0() }
        if changed { listeners.forEach { $0(decision) } }
        return (decision, changed)
    }

    /// Lock held. Non-P0 grants the budget no longer allows go first; then heavy grants above the slot
    /// count, lowest priority and newest first. Their slots free immediately.
    private func takeBack(for budget: DeviceBudget) -> [@Sendable () -> Void] {
        var victims: [UUID] = []
        let candidates = active.values.filter { $0.grant.priority != .p0Interactive }
        for entry in candidates where !budget.allows(entry.grant.priority) || (entry.grant.needsNetwork && !budget.allowsNetwork) {
            victims.append(entry.grant.id)
        }
        let survivors = candidates.filter { !victims.contains($0.grant.id) && $0.grant.heavySlots > 0 }
        var used = active.values.filter { !victims.contains($0.grant.id) && $0.grant.priority != .p0Interactive }.reduce(0) { $0 + $1.grant.heavySlots }
        let order = survivors.sorted { ($0.grant.priority, $0.sequence) > ($1.grant.priority, $1.sequence) }
        for entry in order where used > budget.maxConcurrentHeavyTasks {
            victims.append(entry.grant.id)
            used -= entry.grant.heavySlots
        }
        var handlers: [@Sendable () -> Void] = []
        for id in victims {
            if let handler = active[id]?.onPreempt { handlers.append(handler) }
            active[id] = nil
            preempted.insert(id)
            preemptionCount += 1
        }
        return handlers
    }
}
