import DomainContracts
import Foundation
@testable import Octopus
import SystemContracts
import Testing

@Suite("Octopus coordinator (§103, §127.1)")
struct CoordinatorTests {
    let registry = ModuleRegistry.p0()

    // MARK: Graph contract

    @Test("Graph validation rejects duplicates, unknown or self dependencies, cycles and empty capabilities")
    func graphValidation() throws {
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([]) }
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([node("a"), node("a")]) }
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([node("a", dependsOn: ["zzz"])]) }
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([node("a", dependsOn: ["a"])]) }
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([node("a", dependsOn: ["b"]), node("b", dependsOn: ["a"])]) }
        let empty = TaskNode(id: "a", module: .bodyGeometry, capabilities: []) { _ in 1 }
        #expect(throws: FaultCode.schemaInvalid) { try TaskGraph([empty]) }

        let graph = try TaskGraph([node("c", dependsOn: ["a", "b"]), node("b", dependsOn: ["a"]), node("a")])
        #expect(graph.levels.map { $0.map(\.id) } == [["a"], ["b"], ["c"]])
        let wide = try TaskGraph([node("x"), node("y"), node("z", dependsOn: ["x", "y"])])
        #expect(wide.levels.map { $0.map(\.id) } == [["x", "y"], ["z"]])
    }

    // MARK: ORC-01

    @Test("V15-T-ORC-01: one bounded run, upstream outputs flow down, grant released")
    func boundedRun() async throws {
        let governor = BudgetGovernor()
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let graph = try TaskGraph([
            node("a") { _ in 20 },
            node("b") { _ in 22 },
            node("sum", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, dependsOn: ["a", "b"]) { input in
                try input.upstream("a", as: Int.self) + input.upstream("b", as: Int.self)
            },
        ])
        let outcome = await coordinator.run(graph, context: ContextSnapshot(), priority: .p1UserRequested, traceID: "t-1") { outputs in
            try #require(outputs["sum"] as? Int)
        }
        #expect(outcome.envelope.state == .completed)
        #expect(outcome.envelope.value == 42)
        #expect(outcome.envelope.traceID == "t-1")
        #expect(outcome.nodeStates.values.allSatisfy { $0 == .completed })
        #expect(governor.activeGrantCount == 0)
    }

    // MARK: Policy (ORC-09)

    @Test("V15-T-ORC-09: a renderer that asks for the body profile is blocked before anything runs")
    func rendererCannotReadBody() async throws {
        let ran = Counter()
        let coordinator = OctopusCoordinator(registry: registry)
        let context = ContextSnapshot(["body.profile": ContextEntry("secret", requires: .bodyReadExact)])
        let sneaky = try TaskGraph([
            node("render", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, reads: ["body.profile"]) { _ in
                await ran.increment()
                return 0
            },
        ])
        let outcome = await coordinator.run(sneaky, context: context, priority: .p0Interactive) { _ in 0 }
        #expect(outcome.envelope.fault == .policyDenied)
        #expect(outcome.nodeStates["render"] == .blockedPolicy)
        #expect(await ran.value == 0)

        // Asking for the capability outright is refused by the registry too.
        let direct = try TaskGraph([node("render", module: .avatarRenderer, capability: .bodyReadExact) { _ in 0 }])
        let denied = await coordinator.run(direct, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(denied.envelope.value == nil)
        #expect(denied.nodeStates["render"] == .blockedPolicy)

        // An unregistered module gets nothing.
        let ghost = try TaskGraph([node("x", module: .photoIntake, capability: .bodyReadExact) { _ in 0 }])
        let refused = await coordinator.run(ghost, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(refused.envelope.value == nil)

        // A read of context that does not exist is a schema error, not a silent nil.
        let missing = try TaskGraph([node("m", reads: ["nope"]) { _ in 0 }])
        let schema = await coordinator.run(missing, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(schema.envelope.fault == .schemaInvalid)
    }

    @Test("A task sees only the context it names")
    func minimisedInputs() async throws {
        let coordinator = OctopusCoordinator(registry: registry)
        let context = ContextSnapshot([
            "body.profile": ContextEntry("body", requires: .bodyReadExact),
            "other": ContextEntry("other", requires: .bodyReadExact),
        ])
        let graph = try TaskGraph([node("a", reads: ["body.profile"]) { input in input.context.keys.sorted().joined(separator: ",") }])
        let outcome = await coordinator.run(graph, context: context, priority: .p0Interactive) { try #require($0["a"] as? String) }
        #expect(outcome.envelope.value == "body.profile")
    }

    // MARK: Budget

    @Test("Governor: disallowed priority, network without budget and heavy over the limit are refused before work runs")
    func governor() async throws {
        let ran = Counter()
        let governor = BudgetGovernor(budget: .defaults(for: .survival))
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let graph = try TaskGraph([node("a") { _ in await ran.increment() }])
        let p1 = await coordinator.run(graph, context: ContextSnapshot(), priority: .p1UserRequested) { _ in 0 }
        #expect(p1.envelope.fault == .resourceDenied)

        let network = try TaskGraph([node("w", module: .weatherContext, capability: .weatherFetch) { _ in await ran.increment() }])
        let offline = await coordinator.run(network, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(offline.envelope.fault == .resourceDenied)
        #expect(await ran.value == 0)

        // P0 interactive work still runs in survival, heavy or not.
        let heavy = try TaskGraph([node("h", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, heavy: true) { _ in 1 }])
        let p0 = await coordinator.run(heavy, context: ContextSnapshot(), priority: .p0Interactive) { _ in 1 }
        #expect(p0.envelope.value == 1)

        let balanced = BudgetGovernor(budget: .defaults(for: .balanced))
        let first = try #require(balanced.reserve(priority: .p1UserRequested, heavySlots: 1, needsNetwork: false))
        #expect(balanced.reserve(priority: .p1UserRequested, heavySlots: 1, needsNetwork: false) == nil)
        balanced.release(first)
        #expect(balanced.reserve(priority: .p1UserRequested, heavySlots: 1, needsNetwork: false) != nil)
        #expect(governor.activeGrantCount == 0)
    }

    // MARK: ORC-04

    @Test("V15-T-ORC-04: cancelling a run releases the grant, abandons a module that ignores cancellation, and nothing downstream runs")
    func cancellation() async throws {
        let governor = BudgetGovernor()
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let started = Signal(), hang = Signal(), downstream = Counter()
        let graph = try TaskGraph([
            node("slow", deadline: .seconds(60)) { _ in
                await started.fire()
                await hang.wait() // never looks at cancellation
                return 1
            },
            node("commit", capability: .bodyWriteManual, dependsOn: ["slow"]) { _ in await downstream.increment() },
        ])
        let task = Task { await coordinator.run(graph, context: ContextSnapshot(), priority: .p1UserRequested) { _ in 1 } }
        await started.wait()
        #expect(governor.activeGrantCount == 1)
        task.cancel()
        let outcome = await task.value
        #expect(outcome.envelope.fault == .cancelled)
        #expect(outcome.envelope.value == nil)
        #expect(outcome.nodeStates["slow"] == .cancelled)
        #expect(outcome.nodeStates["commit"] == .cancelled)
        #expect(governor.activeGrantCount == 0)
        await hang.fire()
        #expect(await downstream.value == 0)
    }

    @Test("A run cancelled before it starts does no work")
    func cancelledBeforeStart() async throws {
        let ran = Counter()
        let coordinator = OctopusCoordinator(registry: registry)
        let graph = try TaskGraph([node("a") { _ in await ran.increment() }])
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        }
        #expect(await task.value.envelope.fault == .cancelled)
        #expect(await ran.value == 0)
    }

    // MARK: ORC-05

    @Test("V15-T-ORC-05: a node past its deadline uses its labelled fallback; without one the run times out")
    func timeout() async throws {
        let governor = BudgetGovernor()
        let coordinator = OctopusCoordinator(registry: registry, governor: governor)
        let hang = Signal()
        let slow: @Sendable (TaskInputs) async throws -> any Sendable = { _ in
            await hang.wait()
            return "late"
        }
        let withFallback = try TaskGraph([
            node("r", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, deadline: .milliseconds(50),
                 fallback: Fallback { fault in "fallback:\(fault.rawValue)" }, limitation: "2D kart gösteriliyor", slow),
        ])
        let clock = ContinuousClock()
        let start = clock.now
        let degraded = await coordinator.run(withFallback, context: ContextSnapshot(), priority: .p0Interactive, confidence: .verifiedFacts) {
            try #require($0["r"] as? String)
        }
        // The module hangs until the end of the test, so returning at all proves it was abandoned; the bound
        // only catches a run that waits for it. Loose because the full suite saturates the thread pool.
        #expect(clock.now - start < .seconds(30))
        #expect(degraded.envelope.state == .degraded)
        #expect(degraded.envelope.value == "fallback:\(FaultCode.timedOut.rawValue)")
        #expect(degraded.envelope.limitations == ["2D kart gösteriliyor"])
        #expect(degraded.envelope.confidence == .partial)
        #expect(degraded.nodeStates["r"] == .degraded)

        let bare = try TaskGraph([node("r", deadline: .milliseconds(50), slow)])
        let failed = await coordinator.run(bare, context: ContextSnapshot(), priority: .p0Interactive) { _ in "x" }
        #expect(failed.envelope.fault == .timedOut)
        #expect(failed.nodeStates["r"] == .timedOut)
        #expect(governor.activeGrantCount == 0)
        await hang.fire()
    }

    // MARK: ORC-06

    @Test("V15-T-ORC-06: a crashing module is isolated, its sibling completes, and the breaker stops calling it")
    func crashIsolationAndBreaker() async throws {
        let clock = TestClock()
        let coordinator = OctopusCoordinator(registry: registry, breakerThreshold: 3, breakerCooldown: 30, clock: clock.function)
        let calls = Counter()
        struct Boom: Error {}
        let graph = try TaskGraph([
            node("bad", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, fallback: Fallback { _ in -1 }, limitation: "yedek") { _ in
                await calls.increment()
                throw Boom()
            },
            node("good") { _ in 7 },
        ])
        func run() async -> RunOutcome<[Int]> {
            await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { out in
                [try #require(out["bad"] as? Int), try #require(out["good"] as? Int)]
            }
        }
        for _ in 0..<3 {
            let outcome = await run()
            #expect(outcome.envelope.value == [-1, 7])
            #expect(outcome.nodeStates["good"] == .completed)
            #expect(outcome.nodeStates["bad"] == .degraded)
        }
        #expect(await calls.value == 3)

        let open = await run()
        #expect(open.envelope.value == [-1, 7])
        #expect(await calls.value == 3, "open breaker: the module is not called")

        clock.advance(31)
        _ = await run()
        #expect(await calls.value == 4, "after cooldown the module is tried again")
    }

    @Test("Review P1-3: the breaker is per node, skips do not re-arm it, and one probe after cooldown closes it")
    func breakerPerNodeNoRearm() async throws {
        let clock = TestClock()
        let coordinator = OctopusCoordinator(registry: registry, breakerThreshold: 3, breakerCooldown: 30, clock: clock.function)
        let writes = Counter(), morphs = Counter()
        let failWrites = Signal()
        struct Boom: Error {}
        let write = try TaskGraph([node("persist", capability: .bodyWriteManual) { _ in
            await writes.increment()
            throw Boom()
        }])
        let morph = try TaskGraph([node("morph") { _ in await morphs.increment() }])
        for _ in 0..<3 { _ = await coordinator.run(write, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 } }
        #expect(await writes.value == 3)
        // Same module, other node: still runs.
        let m = await coordinator.run(morph, context: ContextSnapshot(), priority: .p0Interactive) { try #require($0["morph"] as? Int) }
        #expect(m.envelope.value == 1)
        // Calls during the cooldown are skipped and do not extend it.
        for step in [10.0, 10, 9] {
            clock.advance(step)
            _ = await coordinator.run(write, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        }
        #expect(await writes.value == 3)
        clock.advance(2) // 31 s after opening
        _ = await coordinator.run(write, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(await writes.value == 4, "half-open probe after the original cooldown")
        await failWrites.fire()
    }

    @Test("Review P1-1: a must-complete write is awaited past its deadline and past the caller's cancellation")
    func mustCompleteIsAwaited() async throws {
        let coordinator = OctopusCoordinator(registry: registry)
        let done = Counter()
        let graph = try TaskGraph([
            TaskNode(id: "persist", module: .bodyGeometry, capabilities: [.bodyWriteManual], deadline: .milliseconds(20), mustComplete: true) { _ in
                try? await Task.sleep(for: .milliseconds(200))
                return await done.increment()
            },
        ])
        let slow = await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { try #require($0["persist"] as? Int) }
        #expect(slow.envelope.value == 1, "not abandoned at the 20 ms deadline")

        let task = Task { await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 } }
        try await Task.sleep(for: .milliseconds(30))
        task.cancel()
        let cancelled = await task.value
        #expect(cancelled.envelope.fault == .cancelled)
        #expect(await done.value == 2, "the write finished before the run reported")
    }

    @Test("Review P2: a module that throws CancellationError on its own is a module failure, not a cancelled run")
    func selfCancellingModule() async throws {
        let coordinator = OctopusCoordinator(registry: registry)
        let graph = try TaskGraph([
            node("render", module: .avatarRenderer, capability: .avatarReadRenderSnapshot, fallback: Fallback { _ in "2d" }) { _ in
                throw CancellationError()
            },
            node("persist", capability: .bodyWriteManual) { _ in "saved" },
        ])
        let outcome = await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { out in
            "\(try #require(out["render"] as? String))+\(try #require(out["persist"] as? String))"
        }
        #expect(outcome.envelope.value == "2d+saved")
        #expect(outcome.envelope.state == .degraded)
    }

    @Test("A failing node without a fallback fails the run, and later levels never run")
    func failureStopsDownstream() async throws {
        let downstream = Counter()
        let coordinator = OctopusCoordinator(registry: registry)
        struct Boom: Error {}
        let graph = try TaskGraph([
            node("a") { _ in throw Boom() },
            node("b", dependsOn: ["a"]) { _ in await downstream.increment() },
        ])
        let outcome = await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive) { _ in 0 }
        #expect(outcome.envelope.fault == .moduleFailed)
        #expect(outcome.nodeStates["a"] == .failed)
        #expect(outcome.nodeStates["b"] == .failed)
        #expect(await downstream.value == 0)
    }

    // MARK: ORC-02 / ORC-03

    @Test("V15-T-ORC-02: identical work under one key runs once, then again after the TTL")
    func coalescing() async throws {
        let clock = TestClock()
        let coordinator = OctopusCoordinator(registry: registry, clock: clock.function)
        let runs = Counter(), gate = Signal()
        let results = await withTaskGroup(of: Int.self) { group in
            for _ in 0..<10 {
                group.addTask {
                    await coordinator.coalesced(key: "product:123|M", ttl: 60) {
                        await gate.wait()
                        return await runs.increment()
                    }
                }
            }
            try? await Task.sleep(for: .milliseconds(50))
            await gate.fire()
            return await group.reduce(into: [Int]()) { $0.append($1) }
        }
        #expect(await runs.value == 1)
        #expect(Set(results) == [1])

        let cached = await coordinator.coalesced(key: "product:123|M", ttl: 60) { await runs.increment() }
        #expect(cached == 1)
        let other = await coordinator.coalesced(key: "product:999|M", ttl: 60) { await runs.increment() }
        #expect(other == 2)
        clock.advance(61)
        let fresh = await coordinator.coalesced(key: "product:123|M", ttl: 60) { await runs.increment() }
        #expect(fresh == 3)
    }

    @Test("V15-T-ORC-03: latest-wins — a superseded call returns nil, never a stale value")
    func latestWins() async throws {
        let coordinator = OctopusCoordinator(registry: registry)
        let started = Signal()
        let first = Task {
            await coordinator.latest(lane: "preview") { () -> String in
                await started.fire()
                try? await Task.sleep(for: .seconds(10))
                return "stale"
            }
        }
        await started.wait()
        let second = await coordinator.latest(lane: "preview") { "fresh" }
        #expect(second == "fresh")
        #expect(await first.value == nil)

        // Different lanes do not cancel each other.
        async let a = coordinator.latest(lane: "x") { "a" }
        async let b = coordinator.latest(lane: "y") { "b" }
        #expect(await [a, b] == ["a", "b"])
    }
}
