import DomainContracts
import DomainSchemas
import Foundation
import SystemContracts

/// Switches the mirror's modes. Production has the cloud mirror off and no public way to turn it on
/// (ADR-008: human decision + DPA + legal review + cost cap + real iPhone test first).
public struct MirrorFlags: Sendable {
    public let cloudMirrorEnabled: Bool
    public static let production = MirrorFlags(cloudMirrorEnabled: false)
    init(cloudMirrorEnabled: Bool) { self.cloudMirrorEnabled = cloudMirrorEnabled }
}

/// Decides whether a session may start and at which fidelity, before any camera, token or provider call.
public enum MirrorPolicy {
    public static func admit(_ spec: MirrorSessionSpec, product: ProductIdentityV1, budget: DeviceBudget, flags: MirrorFlags = .production,
                             at now: Date) throws(MirrorFault) -> MirrorFidelity {
        try spec.validate()
        switch product.matchKind {
        case .ambiguous: throw .productAmbiguous
        case .candidateOnly, .notFound: throw .productUnverified
        case .exactVerified, .exactUserConfirmed: break
        }
        guard product.identityID == spec.productVariantID else { throw .productUnverified }
        if product.matchKind == .exactVerified, !product.isVerified(at: now) { throw .productUnverified }
        guard product.catalogVersion == spec.catalogVersion else { throw .staleRevision }
        switch budget.tier {
        case .survival: throw .deviceTooHot
        case .lockedBackground: throw .cameraUnavailable
        case .turbo, .balanced, .conserve, .offline: break
        }
        switch spec.requestedMode {
        case .local:
            // A product asset is drawn only when the budget allows product assets; otherwise the camera alone.
            return spec.assetRevision != nil && budget.maxVisualTier == .productAsset ? .localGarmentOverlay : .cameraOnly
        case .cloudOptIn:
            guard flags.cloudMirrorEnabled else { throw .cloudDisabled }
            guard budget.allowsNetwork else { throw .networkUnsuitable }
            return .cloudGenerated
        }
    }
}

/// Stamp every frame carries: order, capture time and the revisions it was made from.
public struct FrameStamp: Hashable, Sendable {
    public let sequence: UInt64
    /// Monotonic seconds (e.g. `CACurrentMediaTime`), never wall-clock.
    public let capturedAt: TimeInterval
    public let productVariantID: String
    public let catalogVersion: String
    public let assetRevision: Int?
    public let bodyProfileRevision: Int?

    public init(sequence: UInt64, capturedAt: TimeInterval, productVariantID: String, catalogVersion: String,
                assetRevision: Int?, bodyProfileRevision: Int?) {
        self.sequence = sequence
        self.capturedAt = capturedAt
        self.productVariantID = productVariantID
        self.catalogVersion = catalogVersion
        self.assetRevision = assetRevision
        self.bodyProfileRevision = bodyProfileRevision
    }
}

/// LM21-06 frame staleness and LM21-T06 revision guard: an old frame is never shown as live, and a frame
/// rendered for another product, catalogue, asset or body revision is never shown at all.
public struct FrameGuard: Sendable {
    public enum Verdict: Hashable, Sendable {
        case show
        /// Shown with a visible delay note.
        case showDelayed
        case drop(DropReason)
    }

    public enum DropReason: String, Sendable { case outOfOrder, staleRevision, tooLate, fromTheFuture }

    /// LM21-06: 500 ms and above carries a delay label; far beyond that the frame is not shown.
    public static let delayLabelAfter: TimeInterval = 0.5
    public static let dropAfter: TimeInterval = 1.5

    public let spec: MirrorSessionSpec
    public private(set) var lastShown: UInt64?

    public init(spec: MirrorSessionSpec) { self.spec = spec }

    public mutating func admit(_ f: FrameStamp, now: TimeInterval) -> Verdict {
        guard f.productVariantID == spec.productVariantID, f.catalogVersion == spec.catalogVersion,
              f.assetRevision == spec.assetRevision, f.bodyProfileRevision == spec.bodyProfileRevision
        else { return .drop(.staleRevision) }
        if let lastShown, f.sequence <= lastShown { return .drop(.outOfOrder) }
        let age = now - f.capturedAt
        guard age.isFinite else { return .drop(.tooLate) }
        if age < 0 { return .drop(.fromTheFuture) }
        if age >= Self.dropAfter { return .drop(.tooLate) }
        lastShown = f.sequence
        return age >= Self.delayLabelAfter ? .showDelayed : .show
    }
}

/// What actually opens and closes the camera (and, in cloud mode, the remote session).
/// `stop()` must close everything and be safe to call more than once.
public protocol LiveMirrorProvider: Sendable {
    func prepare(_ spec: MirrorSessionSpec) async throws(MirrorFault)
    func start() async throws(MirrorFault)
    func stop() async
}

/// One mirror session: the state machine driving one provider. Every way out (user stop, background,
/// lock, call, permission loss, time or cost cap, heat, product change, fault) closes the provider once,
/// and a finished session never comes back: trying again is a new session through `MirrorPolicy`.
public actor MirrorSession {
    public let spec: MirrorSessionSpec
    public let fidelity: MirrorFidelity
    private let provider: any LiveMirrorProvider
    private var machine: MirrorStateMachine
    private var startedAt: TimeInterval?
    public private(set) var history: [MirrorStatus] = [.idle]

    public init(spec: MirrorSessionSpec, fidelity: MirrorFidelity, provider: any LiveMirrorProvider) {
        self.spec = spec
        self.fidelity = fidelity
        self.provider = provider
        machine = MirrorStateMachine(mode: spec.requestedMode)
    }

    public var status: MirrorStatus { machine.status }
    public var stopReason: StopReason? { machine.stopReason }
    public var fault: MirrorFault? { machine.fault }
    public var degradeReason: DegradeReason? { machine.degradeReason }

    /// Permission, then camera, then live. `permissionGranted` is the OS answer, asked by the caller.
    public func start(permissionGranted: Bool, now: TimeInterval) async {
        guard apply(.requestPermission) else { return }
        guard permissionGranted else {
            apply(.permissionDenied)
            return
        }
        guard apply(.permissionGranted) else { return }
        do {
            try await provider.prepare(spec)
            guard await stillWanted() else { return }
            if spec.requestedMode == .cloudOptIn {
                guard apply(.startPreflight), apply(.preflightPassed) else { return await closeIfStopping() }
            }
            try await provider.start()
            guard await stillWanted() else { return }
            apply(spec.requestedMode == .local ? .goLive : .connected)
            startedAt = now
        } catch {
            await fail(error)
        }
    }

    /// After every await: a stop may have landed meanwhile, and the provider may have opened something
    /// after it was told to close. Close again (stop is idempotent) and go no further.
    private func stillWanted() async -> Bool {
        guard machine.status == .stopping || machine.status.isTerminal else { return true }
        await provider.stop()
        apply(.closed)
        return false
    }

    public func stop(_ reason: StopReason) async {
        guard apply(.stop(reason)) else { return }
        await closeIfStopping()
    }

    public func fail(_ fault: MirrorFault) async {
        guard apply(.fail(fault)) else { return }
        await closeIfStopping()
    }

    public func degrade(_ reason: DegradeReason) { apply(.degrade(reason)) }
    public func recover() { apply(.recover) }

    /// Clock tick: the duration cap ends the session (LM21-T23).
    public func tick(now: TimeInterval) async {
        guard let startedAt, now - startedAt >= TimeInterval(spec.maxDurationSeconds) else { return }
        await stop(.maxDuration)
    }

    /// Device budget changed mid-session (LM21-06): critical heat closes, warm or low power degrades.
    public func budgetChanged(_ budget: DeviceBudget) async {
        switch budget.tier {
        case .survival: await stop(.thermalCritical)
        case .lockedBackground: await stop(.screenLocked)
        case .conserve: degrade(.deviceWarm)
        case .offline where spec.requestedMode == .cloudOptIn: await stop(.networkLost)
        case .turbo, .balanced, .offline: break
        }
    }

    /// LM21-T06: any revision change under a running session ends it.
    public func revisionsChanged(productVariantID: String, catalogVersion: String, assetRevision: Int?, bodyProfileRevision: Int?) async {
        guard productVariantID != spec.productVariantID || catalogVersion != spec.catalogVersion
                || assetRevision != spec.assetRevision || bodyProfileRevision != spec.bodyProfileRevision
        else { return }
        await stop(.productChanged)
    }

    @discardableResult
    private func apply(_ e: MirrorEvent) -> Bool {
        let ok = machine.apply(e)
        if ok, history.last != machine.status { history.append(machine.status) }
        return ok
    }

    private func closeIfStopping() async {
        guard machine.status == .stopping else { return }
        await provider.stop()
        apply(.closed)
    }
}
