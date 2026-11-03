import Foundation

/// Work the OS lets run for a limited time after the app leaves the screen (`beginBackgroundTask`).
/// When the OS says time is up, the work is cancelled, the checkpoint runs, and the outcome says so:
/// a run that did not finish is never reported as finished (drill 6, V15-T-DEV-07).
public enum BackgroundOutcome<Value: Sendable>: Sendable {
    case completed(Value)
    /// Time ran out; the checkpoint saved where the work stopped. Resume later.
    case stoppedAtCheckpoint
    /// The work itself failed (not the time limit). Nothing is claimed.
    case failed
}

public final class BackgroundWindow: @unchecked Sendable {
    private let lock = NSLock()
    private var expired = false
    private var onExpire: (@Sendable () -> Void)?

    public init() {}

    public var isExpired: Bool { lock.withLock { expired } }

    /// The expiration handler of `beginBackgroundTask` calls this. Idempotent.
    public func expire() {
        let handler: (@Sendable () -> Void)? = lock.withLock {
            guard !expired else { return nil }
            expired = true
            return onExpire
        }
        handler?()
    }

    /// Runs `work` until it finishes or the window expires. `checkpoint` runs only when time ran out,
    /// after the work was cancelled and has stopped.
    public func perform<Value: Sendable>(
        _ work: @escaping @Sendable () async throws -> Value,
        checkpoint: @escaping @Sendable () async -> Void
    ) async -> BackgroundOutcome<Value> {
        let task = Task { try await work() }
        let alreadyExpired: Bool = lock.withLock {
            if expired { return true }
            onExpire = { task.cancel() }
            return false
        }
        if alreadyExpired { task.cancel() }
        let result = await task.result
        lock.withLock { onExpire = nil }
        // Expiry wins over a late finish: the OS may already be suspending us, so a result that arrived
        // after the deadline is not trusted as complete.
        if isExpired {
            await checkpoint()
            return .stoppedAtCheckpoint
        }
        switch result {
        case .success(let value): return .completed(value)
        case .failure: return .failed
        }
    }
}
