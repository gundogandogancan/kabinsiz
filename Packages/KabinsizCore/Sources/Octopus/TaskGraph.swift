import Foundation
import SystemContracts

/// One piece of context a task may read, with the capability a module needs to see it (§102.2:
/// "minimized scoped input"). A task only receives the entries it names and is allowed to read.
public struct ContextEntry: Sendable {
    public let value: any Sendable
    public let requires: Capability

    public init(_ value: any Sendable, requires: Capability) {
        self.value = value
        self.requires = requires
    }
}

/// The immutable context built for one intent (§103 "minimal immutable ContextSnapshot").
public struct ContextSnapshot: Sendable {
    public let entries: [String: ContextEntry]

    public init(_ entries: [String: ContextEntry] = [:]) { self.entries = entries }
}

/// What a task body sees: its own context reads and the outputs of the tasks it depends on. Nothing else.
public struct TaskInputs: Sendable {
    public let context: [String: any Sendable]
    public let upstream: [String: any Sendable]

    public func context<T>(_ key: String, as type: T.Type = T.self) throws -> T {
        guard let value = context[key] as? T else { throw FaultCode.schemaInvalid }
        return value
    }

    public func upstream<T>(_ id: String, as type: T.Type = T.self) throws -> T {
        guard let value = upstream[id] as? T else { throw FaultCode.schemaInvalid }
        return value
    }
}

/// One node of the task DAG. `capabilities` are checked against the module registry before anything runs.
public struct TaskNode: Sendable {
    public let id: String
    public let module: ModuleID
    public let capabilities: Set<Capability>
    public let reads: Set<String>
    public let dependsOn: [String]
    public let deadline: Duration
    public let isHeavy: Bool
    /// Critical persistence (§103.1): never abandoned for a deadline or the caller's cancellation, because
    /// a write that is reported failed must not land later. The run waits for it to finish.
    public let mustComplete: Bool
    public let work: @Sendable (TaskInputs) async throws -> any Sendable
    /// Safe stand-in when the module fails, times out or its circuit is open. The run is then `DEGRADED`
    /// and says so in `limitations` (V15-T-ORC-05/06). `nil` = no safe fallback; the run fails.
    public let fallback: (@Sendable (FaultCode) -> any Sendable)?
    public let fallbackLimitation: String?

    public init(
        id: String, module: ModuleID, capabilities: Set<Capability>, reads: Set<String> = [], dependsOn: [String] = [],
        deadline: Duration = .seconds(2), isHeavy: Bool = false, mustComplete: Bool = false,
        fallback: (@Sendable (FaultCode) -> any Sendable)? = nil, fallbackLimitation: String? = nil,
        work: @escaping @Sendable (TaskInputs) async throws -> any Sendable
    ) {
        self.id = id
        self.module = module
        self.capabilities = capabilities
        self.reads = reads
        self.dependsOn = dependsOn
        self.deadline = deadline
        self.isHeavy = isHeavy
        self.mustComplete = mustComplete
        self.work = work
        self.fallback = fallback
        self.fallbackLimitation = fallbackLimitation
    }
}

/// A validated DAG: unique IDs, known dependencies, no cycles. Levels run in order; nodes in one level
/// run concurrently.
public struct TaskGraph: Sendable {
    public let nodes: [TaskNode]
    public let levels: [[TaskNode]]

    public init(_ nodes: [TaskNode]) throws(FaultCode) {
        let byID = Dictionary(nodes.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        guard !nodes.isEmpty, byID.count == nodes.count,
              nodes.allSatisfy({ $0.dependsOn.allSatisfy { byID[$0] != nil } && !$0.dependsOn.contains($0.id) && !$0.capabilities.isEmpty })
        else { throw .schemaInvalid }
        var remaining = nodes
        var done = Set<String>()
        var levels: [[TaskNode]] = []
        while !remaining.isEmpty {
            let ready = remaining.filter { Set($0.dependsOn).isSubset(of: done) }
            guard !ready.isEmpty else { throw .schemaInvalid } // cycle
            levels.append(ready.sorted { $0.id < $1.id })
            done.formUnion(ready.map(\.id))
            remaining.removeAll { done.contains($0.id) }
        }
        self.nodes = nodes
        self.levels = levels
    }

    public var heavyCount: Int { nodes.filter(\.isHeavy).count }
    public var usesNetwork: Bool { nodes.contains { $0.capabilities.contains(where: \.isNetwork) } }
}
