import BodyGeometry
import DomainContracts
import Foundation
import Octopus
import SystemContracts

/// A latch that ignores cancellation, so tests can model a module that never checks for it.
actor Signal {
    private var fired = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if fired { return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func fire() {
        fired = true
        waiters.forEach { $0.resume() }
        waiters.removeAll()
    }
}

actor Counter {
    private(set) var value = 0
    @discardableResult func increment() -> Int {
        value += 1
        return value
    }
}

final class TestClock: @unchecked Sendable {
    private let lock = NSLock()
    private var now = Date(timeIntervalSince1970: 1_800_000_000)

    var date: Date { lock.withLock { now } }
    func advance(_ seconds: TimeInterval) { lock.withLock { now += seconds } }
    var function: @Sendable () -> Date { { self.date } }
}

/// Store with the same revision rule as the vault store, for tests that do not need encryption.
actor MemoryBodyStore: BodyStore {
    private(set) var saved: BodyProfile?
    private(set) var snapshot: AvatarSnapshot?
    private(set) var saveCount = 0
    private var lastRevision = 0
    var failLoad = false

    func setFailLoad(_ fail: Bool) { failLoad = fail }

    func load() throws -> BodyProfile? {
        if failLoad { throw FaultCode.storageCorrupted }
        return saved
    }

    func save(_ profile: BodyProfile, snapshot: AvatarSnapshot) throws {
        guard profile.revision > lastRevision, snapshot.bodyRevision == profile.revision else { throw FaultCode.staleRevision }
        saved = profile
        self.snapshot = snapshot
        saveCount += 1
        lastRevision = profile.revision
    }

    func delete() throws -> DeletionReceipt {
        let had = saved != nil
        saved = nil
        snapshot = nil
        return DeletionReceipt(completedAt: Date(), scope: .record,
                               deletedCountsByType: had ? ["body-profile": 1, "avatar-cache": 1] : [:], destroyedKeyCount: 0)
    }
}

struct Fallback: Sendable {
    let make: @Sendable (FaultCode) -> any Sendable
    init(_ make: @escaping @Sendable (FaultCode) -> any Sendable) { self.make = make }
}

func node(
    _ id: String, module: ModuleID = .bodyGeometry, capability: Capability = .bodyReadExact, reads: Set<String> = [],
    dependsOn: [String] = [], deadline: Duration = .seconds(2), heavy: Bool = false,
    fallback: Fallback? = nil, limitation: String? = nil,
    _ work: @escaping @Sendable (TaskInputs) async throws -> any Sendable = { _ in 1 }
) -> TaskNode {
    TaskNode(id: id, module: module, capabilities: [capability], reads: reads, dependsOn: dependsOn, deadline: deadline,
             isHeavy: heavy, fallback: fallback?.make, fallbackLimitation: limitation, work: work)
}

func studio(
    store: any BodyStore = MemoryBodyStore(), governor: any ResourceGovernor = BudgetGovernor(),
    renderDeadline: Duration = .milliseconds(500),
    renderer: @escaping @Sendable (AvatarSnapshot, VisualFidelityTier) async throws -> PreviewScene = { PreviewScene.render($0, maxTier: $1) }
) -> BodyStudio {
    BodyStudio(coordinator: OctopusCoordinator(registry: .p0(), governor: governor), store: store,
               renderDeadline: renderDeadline, renderer: renderer)
}

extension BodyProfile {
    func cm(_ p: BodyParameter) -> Double { self[p].length.centimeters }
}
