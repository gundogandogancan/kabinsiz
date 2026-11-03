import DomainContracts
import Foundation
import SystemContracts

/// Result of one run: the envelope the UI shows, plus each node's final state for audit and tests.
public struct RunOutcome<Value: Codable & Hashable & Sendable>: Sendable {
    public let envelope: DecisionEnvelope<Value>
    public let nodeStates: [String: TaskState]
}

/// The single accountable controller (§103). It never invents facts: it authorizes, budgets, runs the
/// DAG, enforces deadlines and cancellation, applies fallbacks and assembles a `DecisionEnvelope`.
/// Actor isolation is not the privacy boundary; the registry check per node is (§103 note).
public actor OctopusCoordinator {
    private let registry: ModuleRegistry
    public nonisolated let governor: any ResourceGovernor
    private let clock: @Sendable () -> Date
    private var breaker: CircuitBreaker
    private var lanes: [String: LaneTicket] = [:]
    private var coalescedWork: [String: CoalescedEntry] = [:]

    private struct LaneTicket {
        let id: UUID
        let cancel: @Sendable () -> Void
    }

    private struct CoalescedEntry {
        let id: UUID
        let task: any Sendable
        var expiresAt: Date?
    }

    public init(
        registry: ModuleRegistry, governor: any ResourceGovernor = BudgetGovernor(),
        breakerThreshold: Int = 3, breakerCooldown: TimeInterval = 30, clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.registry = registry
        self.governor = governor
        self.clock = clock
        breaker = CircuitBreaker(threshold: breakerThreshold, cooldown: breakerCooldown)
    }

    // MARK: Run

    public func run<Value: Codable & Hashable & Sendable>(
        _ graph: TaskGraph, context: ContextSnapshot, priority: TaskPriority, traceID: String = UUID().uuidString,
        confidence: ConfidenceKind = .heuristic,
        assemble: @Sendable ([String: any Sendable]) throws -> Value
    ) async -> RunOutcome<Value> {
        var states = Dictionary(uniqueKeysWithValues: graph.nodes.map { ($0.id, TaskState.created) })

        /// Every state change goes through the §103.1 machine; an illegal one becomes FAILED (V15-T-ORC-10).
        func move(_ id: String, to next: TaskState) {
            guard let current = states[id] else { return }
            states[id] = current.canTransition(to: next) ? next : (current.isTerminal ? current : .failed)
        }

        func finish(_ fault: FaultCode, as terminal: TaskState? = nil) -> RunOutcome<Value> {
            for (id, state) in states where !state.isTerminal {
                move(id, to: terminal ?? (fault == .cancelled ? .cancelled : .failed))
            }
            return RunOutcome(envelope: .failure(traceID: traceID, fault), nodeStates: states)
        }

        // 1. Authorize every node before anything runs: capabilities and every context read.
        for node in graph.nodes {
            if let fault = authorize(node, context: context) {
                return finish(fault, as: fault == .schemaInvalid ? .failed : .blockedPolicy)
            }
        }
        for id in graph.nodes.map(\.id) { move(id, to: .authorized) }

        // 2. Budget. Released on every path below.
        guard let grant = governor.reserve(priority: priority, heavySlots: graph.heavyCount, needsNetwork: graph.usesNetwork) else {
            return finish(.resourceDenied)
        }
        defer { governor.release(grant) }
        for id in graph.nodes.map(\.id) { move(id, to: .scheduled) }

        // 3. Levels in order, nodes in a level concurrently.
        var outputs: [String: any Sendable] = [:]
        var limitations: [String] = []
        for level in graph.levels {
            if Task.isCancelled { return finish(.cancelled) }
            var jobs: [(TaskNode, TaskInputs, Bool)] = []
            for node in level {
                move(node.id, to: .running)
                let inputs = TaskInputs(
                    context: Dictionary(uniqueKeysWithValues: node.reads.map { ($0, context.entries[$0]!.value) }),
                    upstream: Dictionary(uniqueKeysWithValues: node.dependsOn.map { ($0, outputs[$0]!) })
                )
                jobs.append((node, inputs, breaker.isOpen(CircuitBreaker.key(node), now: clock())))
            }
            let skipped = Set(jobs.filter(\.2).map(\.0.id))
            let results = await withTaskGroup(of: (String, Result<SendableBox, FaultCode>).self) { group in
                for (node, inputs, open) in jobs {
                    group.addTask {
                        if open { return (node.id, .failure(.moduleFailed)) }
                        return (node.id, await Self.execute(node, inputs: inputs))
                    }
                }
                var all: [String: Result<SendableBox, FaultCode>] = [:]
                for await (id, result) in group { all[id] = result }
                return all
            }
            // Only the caller's cancellation cancels the run. A module that throws CancellationError on its
            // own is a module failure: its fallback applies and finished siblings (a write) still count.
            if Task.isCancelled { return finish(.cancelled) }
            for node in level {
                switch results[node.id]! {
                case .success(let box):
                    breaker.recordSuccess(CircuitBreaker.key(node))
                    outputs[node.id] = box.value
                    move(node.id, to: .completed)
                case .failure(let fault):
                    if !skipped.contains(node.id) { breaker.recordFailure(CircuitBreaker.key(node), now: clock()) }
                    let reported: FaultCode = fault == .cancelled ? .moduleFailed : fault
                    if let fallback = node.fallback {
                        outputs[node.id] = fallback(reported)
                        move(node.id, to: .degraded)
                        limitations.append(node.fallbackLimitation ?? reported.userMessage)
                    } else {
                        move(node.id, to: reported == .timedOut ? .timedOut : .failed)
                        return finish(reported)
                    }
                }
            }
        }

        // 4. A run cancelled after its last task never reports a result (V15-T-ORC-04).
        if Task.isCancelled { return finish(.cancelled) }
        let value: Value
        do { value = try assemble(outputs) } catch { return finish(.moduleFailed) }
        let envelope = limitations.isEmpty
            ? DecisionEnvelope(traceID: traceID, state: .completed, value: value, confidence: confidence)
            : DecisionEnvelope(traceID: traceID, state: .degraded, value: value, confidence: .partial, limitations: limitations)
        return RunOutcome(envelope: envelope, nodeStates: states)
    }

    private func authorize(_ node: TaskNode, context: ContextSnapshot) -> FaultCode? {
        for capability in node.capabilities {
            if case .denied(let fault) = registry.decide(module: node.module, capability: capability) { return fault }
        }
        for key in node.reads {
            guard let entry = context.entries[key] else { return .schemaInvalid }
            // V15-T-ORC-09: a module never receives context its registry entry does not cover.
            if case .denied = registry.decide(module: node.module, capability: entry.requires) { return .policyDenied }
        }
        return nil
    }

    // MARK: Deadlines

    struct SendableBox: Sendable { let value: any Sendable }

    /// Races the work against its deadline and the caller's cancellation. Returns as soon as one wins;
    /// a module that ignores cancellation is abandoned, not awaited, so it cannot hang the run.
    static func execute(_ node: TaskNode, inputs: TaskInputs) async -> Result<SendableBox, FaultCode> {
        if node.mustComplete {
            // Unstructured, so neither the deadline nor the caller's cancellation can cut a write short.
            let work = Task { try await node.work(inputs) }
            do { return .success(SendableBox(value: try await work.value)) } catch { return .failure(.moduleFailed) }
        }
        let race = Race()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                race.install(continuation)
                let worker = Task {
                    do {
                        race.finish(.success(SendableBox(value: try await node.work(inputs))))
                    } catch is CancellationError {
                        race.finish(.failure(.cancelled))
                    } catch FaultCode.cancelled {
                        race.finish(.failure(.cancelled))
                    } catch {
                        race.finish(.failure(.moduleFailed))
                    }
                }
                let timer = Task {
                    do {
                        try await Task.sleep(for: node.deadline)
                        race.finish(.failure(.timedOut))
                    } catch {}
                }
                race.onFinish { worker.cancel(); timer.cancel() }
            }
        } onCancel: {
            race.finish(.failure(.cancelled))
        }
    }

    // MARK: Latest-wins and coalescing (§103.1)

    /// Runs `operation` in `lane`, cancelling whatever ran there before. Returns `nil` if a newer call
    /// superseded this one, so a stale preview can never be shown (V15-T-ORC-03).
    public func latest<R: Sendable>(lane: String, _ operation: @escaping @Sendable () async -> R) async -> R? {
        lanes[lane]?.cancel()
        let id = UUID()
        let task = Task { await operation() }
        lanes[lane] = LaneTicket(id: id, cancel: { task.cancel() })
        let result = await withTaskCancellationHandler { await task.value } onCancel: { task.cancel() }
        guard lanes[lane]?.id == id else { return nil }
        lanes[lane] = nil
        return Task.isCancelled ? nil : result
    }

    /// Cancels whatever runs in `lane` (a deleted body must not be repainted by a preview in flight).
    public func cancelLane(_ lane: String) {
        lanes[lane]?.cancel()
        lanes[lane] = nil
    }

    /// Identical work under one key (product + variant, never a user identity) runs once; callers that
    /// arrive while it runs, or within `ttl` after, get the same result (V15-T-ORC-02).
    public func coalesced<R: Sendable>(key: String, ttl: TimeInterval, _ operation: @escaping @Sendable () async -> R) async -> R {
        let now = clock()
        coalescedWork = coalescedWork.filter { $0.value.expiresAt.map { $0 > now } ?? true }
        if let entry = coalescedWork[key], let task = entry.task as? Task<R, Never> {
            return await task.value
        }
        let id = UUID()
        let task = Task { await operation() }
        coalescedWork[key] = CoalescedEntry(id: id, task: task, expiresAt: nil)
        let value = await task.value
        if coalescedWork[key]?.id == id { coalescedWork[key]?.expiresAt = clock().addingTimeInterval(ttl) }
        return value
    }
}

/// First-result-wins latch for `execute`. Any order of install / finish / onFinish is safe.
final class Race: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Result<OctopusCoordinator.SendableBox, FaultCode>, Never>?
    private var result: Result<OctopusCoordinator.SendableBox, FaultCode>?
    private var resumed = false
    private var cleanup: (@Sendable () -> Void)?
    private var finished = false

    func install(_ c: CheckedContinuation<Result<OctopusCoordinator.SendableBox, FaultCode>, Never>) {
        let ready: Result<OctopusCoordinator.SendableBox, FaultCode>? = lock.withLock {
            continuation = c
            return result
        }
        if let ready { resume(ready) }
    }

    func finish(_ r: Result<OctopusCoordinator.SendableBox, FaultCode>) {
        let (first, c, clean): (Bool, CheckedContinuation<Result<OctopusCoordinator.SendableBox, FaultCode>, Never>?, (@Sendable () -> Void)?) = lock.withLock {
            guard !finished else { return (false, nil, nil) }
            finished = true
            result = r
            return (true, continuation, cleanup)
        }
        guard first else { return }
        clean?()
        if c != nil { resume(r) }
    }

    func onFinish(_ f: @escaping @Sendable () -> Void) {
        let alreadyFinished: Bool = lock.withLock {
            if finished { return true }
            cleanup = f
            return false
        }
        if alreadyFinished { f() }
    }

    private func resume(_ r: Result<OctopusCoordinator.SendableBox, FaultCode>) {
        let c: CheckedContinuation<Result<OctopusCoordinator.SendableBox, FaultCode>, Never>? = lock.withLock {
            guard !resumed, let c = continuation else { return nil }
            resumed = true
            return c
        }
        c?.resume(returning: r)
    }
}
