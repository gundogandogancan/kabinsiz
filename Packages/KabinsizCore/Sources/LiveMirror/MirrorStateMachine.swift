import Foundation

public enum MirrorEvent: Hashable, Sendable {
    case requestPermission
    case permissionGranted
    case permissionDenied
    /// Local: the overlay (or camera-only view) is running.
    case goLive
    /// Cloud only: network and price checks before any connection.
    case startPreflight
    case preflightPassed
    /// Cloud only: the remote session answered.
    case connected
    case degrade(DegradeReason)
    case recover
    case stop(StopReason)
    /// The provider confirmed the camera and any remote session are closed.
    case closed
    case fail(MirrorFault)
}

/// The single mirror state machine (LM21-04). Pure and total: every (state, event) pair either has one
/// next state or is refused. Leaving any camera-holding state goes through `stopping`, and only the
/// provider's `closed` confirmation reaches `stopped` / `failed`, so "stopped" always means closed.
public struct MirrorStateMachine: Sendable {
    public let mode: MirrorMode
    public private(set) var status: MirrorStatus = .idle
    public private(set) var stopReason: StopReason?
    public private(set) var fault: MirrorFault?
    public private(set) var degradeReason: DegradeReason?

    public init(mode: MirrorMode) { self.mode = mode }

    /// Next state for `event`, or nil if the event is not allowed now (the machine does not change).
    public static func next(_ s: MirrorStatus, _ e: MirrorEvent, mode: MirrorMode) -> MirrorStatus? {
        if s.isTerminal { return nil }
        switch e {
        case .stop:
            // Stopping again is a no-op, not an error: every lifecycle signal may arrive at once.
            return s.holdsCamera ? .stopping : .stopped
        case .fail:
            return s.holdsCamera ? .stopping : .failed
        case .closed:
            return nil
        default:
            break
        }
        switch (s, e) {
        case (.idle, .requestPermission): return .requestingPermission
        case (.requestingPermission, .permissionGranted): return .preview
        case (.requestingPermission, .permissionDenied): return .failed
        case (.preview, .goLive) where mode == .local: return .live
        case (.preview, .startPreflight) where mode == .cloudOptIn: return .preflight
        case (.preflight, .preflightPassed) where mode == .cloudOptIn: return .connecting
        case (.connecting, .connected) where mode == .cloudOptIn: return .live
        case (.live, .degrade), (.degraded, .degrade): return .degraded
        case (.degraded, .recover): return .live
        default: return nil
        }
    }

    /// Applies `event`; returns false (and changes nothing) when it is not allowed.
    @discardableResult
    public mutating func apply(_ event: MirrorEvent) -> Bool {
        if case .closed = event {
            guard status == .stopping else { return false }
            status = fault == nil ? .stopped : .failed
            return true
        }
        guard let next = Self.next(status, event, mode: mode) else { return false }
        switch event {
        case .stop(let r) where stopReason == nil && fault == nil: stopReason = r
        case .fail(let f) where stopReason == nil && fault == nil: fault = f
        case .permissionDenied: fault = .permissionDenied
        case .degrade(let r): degradeReason = r
        case .recover: degradeReason = nil
        default: break
        }
        status = next
        return true
    }
}
