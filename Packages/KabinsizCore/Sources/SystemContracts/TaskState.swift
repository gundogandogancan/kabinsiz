import Foundation

/// Orchestrator task lifecycle (§103.1). Terminal states are immutable (V15-T-ORC-10).
public enum TaskState: String, Codable, CaseIterable, Sendable {
    case created = "CREATED", authorized = "AUTHORIZED", scheduled = "SCHEDULED", running = "RUNNING"
    case partial = "PARTIAL", completed = "COMPLETED", degraded = "DEGRADED", cancelled = "CANCELLED"
    case timedOut = "TIMED_OUT", failed = "FAILED", blockedPolicy = "BLOCKED_POLICY"

    public var isTerminal: Bool {
        switch self {
        case .completed, .degraded, .cancelled, .timedOut, .failed, .blockedPolicy: true
        case .created, .authorized, .scheduled, .running, .partial: false
        }
    }

    /// Every non-terminal state may be cancelled or fail; only `CREATED` can be blocked by policy.
    /// `PARTIAL` is progress shown to the user while work continues.
    public func canTransition(to next: TaskState) -> Bool {
        guard !isTerminal else { return false }
        switch (self, next) {
        case (.created, .authorized), (.created, .blockedPolicy): return true
        case (.authorized, .scheduled): return true
        case (.scheduled, .running): return true
        case (.running, .partial), (.running, .completed), (.running, .degraded), (.running, .timedOut): return true
        case (.partial, .partial), (.partial, .completed), (.partial, .degraded), (.partial, .timedOut): return true
        case (_, .cancelled), (_, .failed): return true
        default: return false
        }
    }

    public func transition(to next: TaskState) throws(FaultCode) -> TaskState {
        guard canTransition(to: next) else { throw .invalidTransition }
        return next
    }
}
