import BodyGeometry
import DomainContracts
import Foundation
@testable import Octopus
import SystemContracts
import Testing

/// Signals for a cool, charged phone in a live camera flow: the only reading that earns TURBO.
let turboSignals = DeviceSignals(battery: .level(percent: 80, charging: false), activelyScanning: true)

/// Body store that can hold the next save until a gate fires, to keep a commit in flight.
actor GatedBodyStore: BodyStore {
    let inner = MemoryBodyStore()
    private var hold: Signal?
    private(set) var waiting = false

    func holdNextSave() -> Signal {
        let gate = Signal()
        hold = gate
        return gate
    }

    func load() async throws -> BodyProfile? { try await inner.load() }
    func save(_ profile: BodyProfile, snapshot: AvatarSnapshot) async throws {
        if let gate = hold {
            hold = nil
            waiting = true
            await gate.wait()
            waiting = false
        }
        try await inner.save(profile, snapshot: snapshot)
    }
    func delete() async throws -> DeletionReceipt { try await inner.delete() }
}

private func waitUntil(_ condition: @Sendable () async -> Bool) async {
    for _ in 0..<2_000 where !(await condition()) { try? await Task.sleep(for: .milliseconds(1)) }
}

private func hasNoNumbers(_ text: String) -> Bool {
    !text.contains { $0.isNumber || $0 == "%" || $0 == "°" }
}

@Suite("Device governor (§113, V15-T-DEV-01..10)")
struct DeviceGovernorTests {
    let registry = ModuleRegistry.p0()

    // MARK: Policy table

    @Test("§113.1 tier table: each signal maps to its tier and every budget is valid")
    func policyTable() throws {
        func tier(_ s: DeviceSignals) -> TierDecision {
            let (h, r) = TierPolicy.health(for: s)
            return TierPolicy.decide(s, health: h, reasons: r)
        }
        var s = turboSignals
        #expect(tier(s).tier == .turbo)
        s.thermal = .fair
        #expect(tier(s).tier == .balanced && tier(s).reasons.contains(.thermalFair))
        s.thermal = .serious
        #expect(tier(s).tier == .conserve)
        s.thermal = .critical
        #expect(tier(s).tier == .survival)
        s = turboSignals
        s.memory = .warning
        #expect(tier(s).tier == .conserve)
        s.memory = .critical
        #expect(tier(s).tier == .survival)
        s = turboSignals
        s.lowPowerMode = true
        #expect(tier(s).tier == .balanced && tier(s).reasons.contains(.lowPower))
        s = turboSignals
        s.battery = .level(percent: 8, charging: false)
        #expect(tier(s).tier == .conserve && tier(s).reasons.contains(.batteryCritical))
        s.battery = .level(percent: 8, charging: true)
        #expect(tier(s).tier == .turbo)
        s.battery = .level(percent: 18, charging: false)
        #expect(tier(s).tier == .balanced && tier(s).reasons.contains(.batteryLow))
        s = turboSignals
        s.activelyScanning = false
        #expect(tier(s).tier == .balanced && tier(s).reasons.contains(.notScanning))

        // Network is its own axis: offline on a healthy phone, but never better than the health allows.
        s = turboSignals
        s.networkReachable = false
        #expect(tier(s).tier == .offline && !tier(s).budget.allowsNetwork)
        s.thermal = .serious
        #expect(tier(s).tier == .conserve && !tier(s).budget.allowsNetwork)

        s = turboSignals
        s.presence = .locked
        #expect(tier(s).tier == .lockedBackground && tier(s).reasons.contains(.locked))
        s.presence = .background
        #expect(tier(s).tier == .lockedBackground)

        // Every reachable combination yields a budget that passes its own contract.
        for thermal in ThermalLevel.allCases {
            for memory in MemoryPressure.allCases {
                for presence in [AppPresence.foreground, .background, .locked] {
                    for online in [true, false] {
                        for low in [true, false] {
                            let s = DeviceSignals(thermal: thermal, lowPowerMode: low, memory: memory, presence: presence, networkReachable: online)
                            let d = tier(s)
                            try d.budget.validate()
                            if presence == .foreground { #expect(d.budget.allows(.p0Interactive)) }
                        }
                    }
                }
            }
        }
    }

    // MARK: DEV-01

    @Test("V15-T-DEV-01 / drill 1: thermal serious lowers the tier, camera cadence and detail; the body studio still saves")
    func thermalSeriousKeepsUXUsable() async throws {
        let governor = DeviceResourceGovernor(signals: turboSignals)
        let before = governor.decision
        let store = MemoryBodyStore()
        let s = studio(store: store, governor: governor)
        _ = await s.createNeutral()

        let after = governor.update { $0.thermal = .serious }
        #expect(after.tier == .conserve)
        #expect(!after.budget.allowsPhysics && !after.budget.allowsBackgroundInference)
        guard case .continuous(let fast) = before.cvCadence, case .continuous(let slow) = after.cvCadence else {
            Issue.record("camera cadence should stay continuous in TURBO and CONSERVE")
            return
        }
        #expect(slow < fast)

        let committed = await s.commit(.slider(.waist, cm: 80))
        #expect(committed.state == .completed)
        #expect(await store.saved?.cm(.waist) == 80)
        // Lower LOD: station anchors only, same controls (BOD-08 under a real signal).
        #expect(committed.value?.rightOutline.count == Silhouette.Station.allCases.count)

        let note = try #require(after.userNote)
        #expect(note.contains("ısındı"))
        #expect(hasNoNumbers(note))
    }

    // MARK: DEV-02

    @Test("V15-T-DEV-02: thermal critical stops heavy and non-interactive work; P0 and manual entry stay")
    func thermalCriticalSurvival() async throws {
        let governor = DeviceResourceGovernor(signals: turboSignals)
        let d = governor.update { $0.thermal = .critical }
        #expect(d.tier == .survival)
        #expect(d.cvCadence == .paused)
        #expect(governor.reserve(priority: .p1UserRequested, heavySlots: 0, needsNetwork: false) == nil)
        #expect(governor.reserve(priority: .p2Opportunistic, heavySlots: 1, needsNetwork: false) == nil)
        let p0 = try #require(governor.reserve(priority: .p0Interactive, heavySlots: 0, needsNetwork: false))
        governor.release(p0)

        let segmenter = ModelComputeProfile(modelID: "garment-seg", preferred: [.neuralEngine, .gpu], validatedUnits: [.neuralEngine, .gpu], heavy: true)
        #expect(ComputePlanner.plan(segmenter, available: Set(ComputeUnit.allCases), budget: d.budget) == .manual(.budgetForbidsHeavy))

        let store = MemoryBodyStore()
        let s = studio(store: store, governor: governor)
        #expect(await s.createNeutral().state == .completed)
        #expect(await s.commit(.slider(.hip, cm: 100)).state == .completed)
        let note = try #require(d.userNote)
        #expect(note.contains("ölçü girme ve kaydetme açık") && hasNoNumbers(note))
    }

    // MARK: DEV-03

    @Test("V15-T-DEV-03: Low Power mid-inference takes back the lowest-priority heavy run; the other finishes; nothing leaks")
    func lowPowerRebudgets() async throws {
        let governor = DeviceResourceGovernor(signals: turboSignals)
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let release = Signal()
        let p2Ran = Counter()
        let heavy: @Sendable (String, Counter?) throws -> TaskGraph = { id, ran in
            try TaskGraph([node(id, heavy: true) { _ in
                await ran?.increment()
                await release.wait()
                return 1
            }])
        }
        let p1Graph = try heavy("p1", nil)
        let p2Graph = try heavy("p2", p2Ran)
        let important = Task { await coordinator.run(p1Graph, context: ContextSnapshot(), priority: .p1UserRequested) { _ in 1 } }
        await waitUntil { governor.activeGrantCount == 1 }
        let opportunistic = Task { await coordinator.run(p2Graph, context: ContextSnapshot(), priority: .p2Opportunistic) { _ in 2 } }
        await waitUntil { await p2Ran.value == 1 }
        #expect(governor.activeGrantCount == 2)

        let d = governor.update { $0.lowPowerMode = true }
        #expect(d.tier == .balanced && d.budget.maxConcurrentHeavyTasks == 1)
        let taken = await opportunistic.value
        #expect(taken.envelope.fault == .resourceDenied)
        #expect(taken.envelope.value == nil)
        #expect(taken.nodeStates["p2"] == .cancelled)
        #expect(governor.preemptions == 1)

        await release.fire()
        let kept = await important.value
        #expect(kept.envelope.state == .completed && kept.envelope.value == 1)
        #expect(governor.activeGrantCount == 0)
    }

    @Test("V15-T-DEV-03: a taken-back run still lets its must-complete write land and never reports success")
    func preemptionKeepsWrites() async throws {
        let governor = DeviceResourceGovernor(signals: turboSignals)
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let gate = Signal()
        let writes = Counter()
        let graph = try TaskGraph([
            TaskNode(id: "write", module: .bodyGeometry, capabilities: [.bodyReadExact], mustComplete: true) { _ in
                await gate.wait()
                return await writes.increment()
            },
            node("compute", heavy: true) { _ in
                try await Task.sleep(for: .seconds(30))
                return 0
            },
        ])
        let run = Task { await coordinator.run(graph, context: ContextSnapshot(), priority: .p3Maintenance) { _ in 1 } }
        await waitUntil { governor.activeGrantCount == 1 }
        governor.update { $0.activelyScanning = false } // TURBO → BALANCED: P3 no longer allowed
        await gate.fire()
        let outcome = await run.value
        #expect(outcome.envelope.fault == .resourceDenied)
        #expect(await writes.value == 1)
        #expect(governor.activeGrantCount == 0)
    }

    @Test("Take-back order: disallowed priorities, lost network, then heavy above the slots (lowest priority, newest first); P0 never")
    func takeBackOrder() async throws {
        let governor = DeviceResourceGovernor(signals: turboSignals)
        let p1 = try #require(governor.reserve(priority: .p1UserRequested, heavySlots: 1, needsNetwork: false))
        let p2 = try #require(governor.reserve(priority: .p2Opportunistic, heavySlots: 1, needsNetwork: false))
        let p0 = try #require(governor.reserve(priority: .p0Interactive, heavySlots: 1, needsNetwork: false))
        let net = try #require(governor.reserve(priority: .p1UserRequested, heavySlots: 0, needsNetwork: true))
        let fired = Counter()
        for grant in [p1, p2, p0, net] { governor.watch(grant) { Task { await fired.increment() } } }

        governor.update { $0.thermal = .fair } // heavy 2 → 1 for non-P0: P2 goes
        #expect(governor.activeGrantCount == 3)
        governor.update { $0.networkReachable = false } // network grant goes
        #expect(governor.activeGrantCount == 2)
        governor.update { $0.thermal = .critical } // P1 not allowed in SURVIVAL
        #expect(governor.activeGrantCount == 1)
        #expect(governor.preemptions == 3)

        // Watching a grant that is already gone fires at once.
        let late = Counter()
        governor.watch(p1) { Task { await late.increment() } }
        governor.release(p0)
        #expect(governor.activeGrantCount == 0)
        await waitUntil { await fired.value == 3 }
        await waitUntil { await late.value == 1 }
        #expect(await fired.value == 3)
        #expect(await late.value == 1)
    }

    // MARK: DEV-04

    @Test("V15-T-DEV-04 / drill 5: unknown battery (-1) stays unknown, blocks TURBO, and never becomes a number")
    func batteryUnknown() throws {
        #expect(BatteryReading(deviceLevel: -1, charging: false) == .unavailable)
        #expect(BatteryReading(deviceLevel: .nan, charging: false) == .unavailable)
        #expect(BatteryReading(deviceLevel: 1.5, charging: true) == .unavailable)
        #expect(BatteryReading(deviceLevel: 0.42, charging: false) == .level(percent: 42, charging: false))

        var s = turboSignals
        s.battery = BatteryReading(deviceLevel: -1, charging: false)
        let governor = DeviceResourceGovernor(signals: s)
        #expect(governor.decision.tier == .balanced)
        #expect(governor.decision.reasons.contains(.batteryUnknown))
        // Reason codes carry no values at all.
        #expect(TierReason.allCases.allSatisfy { hasNoNumbers($0.rawValue) })
    }

    // MARK: DEV-05

    @Test("V15-T-DEV-05 / drill 8: memory warning evicts caches, keeps the pending save and undo, and recovers with hysteresis")
    func memoryWarning() async throws {
        let clock = TestClock()
        let governor = DeviceResourceGovernor(signals: DeviceSignals(), recoveryDelay: 20, memoryCalmDelay: 60, clock: clock.function)
        let coordinator = OctopusCoordinator(registry: registry, governor: governor, clock: clock.function)
        governor.registerEvictable("octopus.coalesced") { await coordinator.evictCaches() }
        let runs = Counter()
        _ = await coordinator.coalesced(key: "product-1", ttl: 600) { await runs.increment() }
        _ = await coordinator.coalesced(key: "product-1", ttl: 600) { await runs.increment() }
        #expect(await runs.value == 1)

        let store = GatedBodyStore()
        let s = BodyStudio(coordinator: coordinator, store: store)
        _ = await s.createNeutral()
        _ = await s.commit(.slider(.waist, cm: 76))
        #expect(await s.canUndo)

        let gate = await store.holdNextSave()
        let pending = Task { await s.commit(.slider(.waist, cm: 82)) }
        await waitUntil { await store.waiting }
        let report = await governor.noteMemoryWarning()
        #expect(report.freed["octopus.coalesced"] == 1)
        #expect(governor.decision.tier == .conserve && governor.decision.reasons.contains(.memoryWarning))
        await gate.fire()
        #expect(await pending.value.state == .completed)
        #expect(await store.inner.saved?.cm(.waist) == 82)
        #expect(await s.canUndo)

        _ = await coordinator.coalesced(key: "product-1", ttl: 600) { await runs.increment() }
        #expect(await runs.value == 2)

        clock.advance(61)
        #expect(governor.decision.tier == .conserve && governor.decision.reasons.contains(.recovering))
        clock.advance(21)
        #expect(governor.decision.tier == .balanced)
    }

    @Test("Hysteresis: a phone hovering between thermal states does not flap; recovery needs a steady window")
    func hysteresis() {
        let clock = TestClock()
        let governor = DeviceResourceGovernor(signals: DeviceSignals(), recoveryDelay: 20, clock: clock.function)
        #expect(governor.update { $0.thermal = .serious }.tier == .conserve)
        for _ in 0..<5 {
            clock.advance(5)
            #expect(governor.update { $0.thermal = .nominal }.tier == .conserve)
            clock.advance(5)
            #expect(governor.update { $0.thermal = .serious }.tier == .conserve)
        }
        clock.advance(5)
        governor.update { $0.thermal = .nominal }
        clock.advance(19)
        #expect(governor.decision.tier == .conserve)
        clock.advance(2)
        #expect(governor.decision.tier == .balanced)
        // Downgrades never wait.
        #expect(governor.update { $0.thermal = .critical }.tier == .survival)
    }

    // MARK: DEV-06 and drill 2

    @Test("V15-T-DEV-06 / drill 4: temp writes are bounded by a disk floor and refused recoverably")
    func diskBounded() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("eph-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let mb: Int64 = 1_024 * 1_024
        let free = LockedValue<Int64?>(600 * mb)
        let area = try EphemeralArea(root: root, policy: .init(reserveFloorBytes: 512 * mb, unknownSpaceLimitBytes: 16 * mb)) { free.value }

        let first = try area.reserve(bytes: 50 * mb)
        #expect(throws: FaultCode.resourceDenied) { try area.reserve(bytes: 50 * mb) }
        #expect(FaultCode.resourceDenied.isRetryable)
        try first.write(Data(repeating: 1, count: 1_024))
        #expect(FileManager.default.fileExists(atPath: first.url.path))
        #expect(throws: FaultCode.resourceDenied) { try first.write(Data(count: Int(50 * mb) + 1)) }
        first.discard()
        first.discard()
        #expect(!FileManager.default.fileExists(atPath: first.url.path))
        #expect(area.outstandingBytes == 0)
        #expect(throws: FaultCode.invalidTransition) { try first.write(Data([1])) }
        let second = try area.reserve(bytes: 50 * mb)
        second.discard()

        // The OS does not answer: only a small amount may be outstanding.
        free.value = nil
        let small = try area.reserve(bytes: 10 * mb)
        #expect(throws: FaultCode.resourceDenied) { try area.reserve(bytes: 10 * mb) }
        small.discard()
        #expect(throws: FaultCode.schemaInvalid) { try area.reserve(bytes: 0) }
    }

    @Test("Drill 2: a process killed mid-import leaves files that the next launch sweeps; live files are kept")
    func orphanSweep() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("eph-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        // "Killed" process: the file is written and never discarded (no deinit runs after a kill).
        let dead = try EphemeralArea(root: root) { nil }
        let orphan = try dead.reserve(bytes: 1_024)
        try orphan.write(Data(repeating: 7, count: 512))
        let orphanPath = orphan.url.path

        let next = try EphemeralArea(root: root) { nil }
        let live = try next.reserve(bytes: 1_024)
        try live.write(Data([1]))
        #expect(next.sweepOrphans() == 1)
        #expect(!FileManager.default.fileExists(atPath: orphanPath))
        #expect(FileManager.default.fileExists(atPath: live.url.path))
        let backup = try root.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup
        #expect(backup == true)
        withExtendedLifetime(orphan) {}
    }

    // MARK: DEV-07

    @Test("V15-T-DEV-07 / drill 6: background expiry stops at a checkpoint and never reports completion")
    func backgroundExpiry() async {
        let checkpoints = Counter()
        let window = BackgroundWindow()
        let started = Signal()
        let running = Task {
            await window.perform({
                await started.fire()
                try await Task.sleep(for: .seconds(30))
                return 1
            }, checkpoint: { await checkpoints.increment() })
        }
        await started.wait()
        window.expire()
        window.expire()
        guard case .stoppedAtCheckpoint = await running.value else { Issue.record("expected a checkpoint"); return }
        #expect(await checkpoints.value == 1)

        // Work that ignores cancellation and finishes late is still not trusted as complete.
        let stubborn = BackgroundWindow()
        let late = Signal()
        let lateStarted = Signal()
        let lateRun = Task { await stubborn.perform({ await lateStarted.fire(); await late.wait(); return 2 }, checkpoint: {}) }
        await lateStarted.wait()
        stubborn.expire()
        await late.fire()
        guard case .stoppedAtCheckpoint = await lateRun.value else { Issue.record("late finish counted as complete"); return }

        let quick = BackgroundWindow()
        guard case .completed(3) = await quick.perform({ 3 }, checkpoint: { await checkpoints.increment() }) else {
            Issue.record("expected completion"); return
        }
        let gone = BackgroundWindow()
        gone.expire()
        guard case .stoppedAtCheckpoint = await gone.perform({ 4 }, checkpoint: {}) else { Issue.record("expired window ran"); return }
        struct Boom: Error {}
        guard case .failed = await BackgroundWindow().perform({ () async throws -> Int in throw Boom() }, checkpoint: { await checkpoints.increment() }) else {
            Issue.record("expected failure"); return
        }
        #expect(await checkpoints.value == 1)
    }

    // MARK: DEV-08

    @Test("V15-T-DEV-08: a new scan supersedes the old one, which releases its heavy slot first")
    func newScanPreemptsOld() async throws {
        let governor = DeviceResourceGovernor(signals: DeviceSignals(battery: .level(percent: 80, charging: true)))
        #expect(governor.decision.budget.maxConcurrentHeavyTasks == 1)
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let started = Counter()
        let scan: @Sendable (Int) throws -> TaskGraph = { label in
            try TaskGraph([node("scan", heavy: true) { _ in
                await started.increment()
                try await Task.sleep(for: label == 1 ? .seconds(30) : .milliseconds(10))
                return label
            }])
        }
        let old = Task {
            await coordinator.latest(lane: "scan") {
                await coordinator.run(try! scan(1), context: ContextSnapshot(), priority: .p1UserRequested) { $0["scan"] as! Int }
            }
        }
        await waitUntil { await started.value == 1 }
        let new = await coordinator.latest(lane: "scan") {
            await coordinator.run(try! scan(2), context: ContextSnapshot(), priority: .p1UserRequested) { $0["scan"] as! Int }
        }
        #expect(new?.envelope.value == 2)
        #expect(await old.value == nil)
        #expect(governor.activeGrantCount == 0)

        // The superseded scan is finishing a must-complete write that still holds the heavy slot: the new
        // scan waits for it instead of being refused, and the writes stay in order.
        let order = LockedValue<[String]>([])
        let saving = Signal()
        let saveGraph = try TaskGraph([TaskNode(id: "save", module: .bodyGeometry, capabilities: [.bodyReadExact], isHeavy: true, mustComplete: true) { _ in
            await saving.fire()
            try? await Task.sleep(for: .milliseconds(150))
            order.value.append("old-save")
            return 1
        }])
        let nextGraph = try TaskGraph([node("scan", heavy: true) { _ in
            order.value.append("new-scan")
            return 2
        }])
        let older = Task {
            await coordinator.latest(lane: "scan") {
                await coordinator.run(saveGraph, context: ContextSnapshot(), priority: .p1UserRequested) { $0["save"] as! Int }
            }
        }
        await saving.wait()
        let newer = await coordinator.latest(lane: "scan") {
            await coordinator.run(nextGraph, context: ContextSnapshot(), priority: .p1UserRequested) { $0["scan"] as! Int }
        }
        #expect(newer?.envelope.value == 2)
        #expect(await older.value == nil)
        #expect(order.value == ["old-save", "new-scan"])
        #expect(governor.activeGrantCount == 0)
    }

    // MARK: DEV-09

    @Test("V15-T-DEV-09 / drill 7: no Neural Engine → a validated fallback unit, else manual entry")
    func computeFallback() {
        let budget = DeviceBudget.defaults(for: .balanced)
        let model = ModelComputeProfile(modelID: "pose", preferred: [.neuralEngine, .gpu, .cpu], validatedUnits: [.neuralEngine, .cpu], heavy: true)
        #expect(ComputePlanner.plan(model, available: Set(ComputeUnit.allCases), budget: budget) == .run(.neuralEngine, isFallback: false))
        // GPU is available but unvalidated, so the CPU (validated) is chosen.
        #expect(ComputePlanner.plan(model, available: [.gpu, .cpu], budget: budget) == .run(.cpu, isFallback: true))
        let aneOnly = ModelComputeProfile(modelID: "seg", preferred: [.neuralEngine], validatedUnits: [.neuralEngine], heavy: false)
        #expect(ComputePlanner.plan(aneOnly, available: [.gpu, .cpu], budget: budget) == .manual(.noValidatedUnit))
    }

    // MARK: DEV-10

    @Test("V15-T-DEV-10 / drill 3: locked device refuses new vault work, waits instead, writes once after unlock")
    func lockedDefers() async throws {
        let governor = DeviceResourceGovernor(signals: DeviceSignals())
        let store = MemoryBodyStore()
        let s = studio(store: store, governor: governor)
        _ = await s.createNeutral()

        // A save already running when the phone locks is not taken back.
        let gate = Signal()
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let inFlight = Task {
            await coordinator.run(try! TaskGraph([node("save") { _ in await gate.wait(); return 1 }]), context: ContextSnapshot(), priority: .p0Interactive) { _ in 1 }
        }
        await waitUntil { governor.activeGrantCount == 1 }

        governor.update { $0.presence = .locked }
        #expect(!governor.protectedDataAvailable)
        await gate.fire()
        #expect(await inFlight.value.envelope.state == .completed)

        let refused = await s.commit(.slider(.waist, cm: 70))
        #expect(refused.fault == .resourceDenied)
        #expect(await store.saveCount == 1)

        let deferred = Task {
            try await governor.untilProtectedDataAvailable()
            return await s.commit(.slider(.waist, cm: 71))
        }
        try await Task.sleep(for: .milliseconds(50))
        #expect(await store.saveCount == 1)

        let cancelled = Task { try await governor.untilProtectedDataAvailable() }
        cancelled.cancel()
        await #expect(throws: CancellationError.self) { try await cancelled.value }

        governor.update { $0.presence = .foreground }
        #expect(try await deferred.value.state == .completed)
        #expect(await store.saveCount == 2)
        #expect(await store.saved?.cm(.waist) == 71)
        // Already unlocked: no wait.
        try await governor.untilProtectedDataAvailable()
    }

    @Test("User notes never carry numbers, and stay quiet when nothing changed for the user")
    func notes() {
        for tier in ExecutionTier.allCases {
            for reasons in [[TierReason](), [.thermalSerious], [.thermalCritical], [.memoryWarning], [.memoryCritical], [.batteryCritical]] {
                let d = TierDecision(tier: tier, health: .balanced, budget: .defaults(for: tier), reasons: reasons)
                if let note = d.userNote { #expect(hasNoNumbers(note)) }
            }
        }
        #expect(DeviceResourceGovernor(signals: DeviceSignals()).decision.userNote == nil)
    }
}

final class LockedValue<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: T
    init(_ value: T) { stored = value }
    var value: T {
        get { lock.withLock { stored } }
        set { lock.withLock { stored = newValue } }
    }
}
