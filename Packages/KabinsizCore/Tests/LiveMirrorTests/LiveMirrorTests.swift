import DomainContracts
import DomainSchemas
import Foundation
@testable import LiveMirror
import SystemContracts
import Testing

/// Test double for the camera/remote side. Tracks whether anything is open and how often it was closed.
actor ScriptedProvider: LiveMirrorProvider {
    var prepared = 0, started = 0, stopped = 0
    var isOpen = false
    /// Set at the end of `start`, which may finish after a stop already arrived.
    var isStreaming = false
    var failPrepare: MirrorFault?
    var failStart: MirrorFault?
    var duringPrepare: (@Sendable () async -> Void)?
    var duringStart: (@Sendable () async -> Void)?

    init(failPrepare: MirrorFault? = nil, failStart: MirrorFault? = nil) {
        self.failPrepare = failPrepare
        self.failStart = failStart
    }

    func setDuringPrepare(_ hook: @escaping @Sendable () async -> Void) { duringPrepare = hook }
    func setDuringStart(_ hook: @escaping @Sendable () async -> Void) { duringStart = hook }

    func prepare(_ spec: MirrorSessionSpec) async throws(MirrorFault) {
        prepared += 1
        if let hook = duringPrepare { await hook() }
        if let failPrepare { throw failPrepare }
        // The camera opens at the end of prepare, possibly after a stop already arrived.
        isOpen = true
    }

    func start() async throws(MirrorFault) {
        started += 1
        if let hook = duringStart { await hook() }
        if let failStart { throw failStart }
        isStreaming = true
    }

    func stop() async {
        stopped += 1
        isOpen = false
        isStreaming = false
    }
}

let t0 = Date(timeIntervalSince1970: 1_793_696_400)

func product(_ kind: ProductIdentityV1.MatchKind = .exactUserConfirmed, id: String = "pid-1", catalog: String = "cat-7") -> ProductIdentityV1 {
    ProductIdentityV1(
        identityID: id, gtin: kind.isExact ? "02000001000014" : nil, retailerSku: nil, brandID: "brand-1", brandProductCode: "B-1",
        modelID: "m-1", colorID: "NVY", sizeLabel: "M", market: "TR", sourceRef: "SYNTHETIC_DEMO_ONLY", matchKind: kind,
        verifiedAt: kind.isExact ? t0 : nil, expiresAt: kind == .exactVerified ? t0.addingTimeInterval(3600) : nil,
        evidenceIDs: kind.isExact ? ["ev-1"] : [], licensingRights: kind == .exactVerified ? [.displayFacts] : [], catalogVersion: catalog
    )
}

func localSpec(asset: Int? = 3, seconds: Int = 600) -> MirrorSessionSpec {
    MirrorSessionSpec(productVariantID: "pid-1", catalogVersion: "cat-7", assetRevision: asset, bodyProfileRevision: 4,
                      requestedMode: .local, maxDurationSeconds: seconds)
}

func cloudSpec(seconds: Int = 15) -> MirrorSessionSpec {
    MirrorSessionSpec(productVariantID: "pid-1", catalogVersion: "cat-7", assetRevision: nil, bodyProfileRevision: nil,
                      requestedMode: .cloudOptIn, maxDurationSeconds: seconds, consentRevision: 1, estimatedMaxCostUSD: Decimal(string: "0.30"))
}

@Suite("LM21-WP03 live mirror contracts")
struct LiveMirrorTests {
    // MARK: Contracts

    @Test("Persisted raw values are frozen")
    func frozen() {
        #expect(MirrorMode.allCases.map(\.rawValue) == ["LOCAL", "CLOUD_OPT_IN"])
        #expect(MirrorStatus.allCases.map(\.rawValue) == ["IDLE", "REQUESTING_PERMISSION", "PREVIEW", "PREFLIGHT", "CONNECTING", "LIVE",
                                                          "DEGRADED", "STOPPING", "STOPPED", "FAILED"])
        #expect(StopReason.allCases.map(\.rawValue) == ["USER_TAPPED", "APP_BACKGROUND", "SCREEN_LOCKED", "INCOMING_CALL",
                                                        "CAMERA_PERMISSION_REVOKED", "MAX_DURATION", "COST_CAP", "NETWORK_LOST",
                                                        "THERMAL_CRITICAL", "PRODUCT_CHANGED"])
        #expect(MirrorFault.allCases.map(\.rawValue) == ["PERMISSION_DENIED", "CAMERA_UNAVAILABLE", "PRODUCT_UNVERIFIED", "PRODUCT_AMBIGUOUS",
                                                         "STALE_REVISION", "CLOUD_DISABLED", "CONSENT_MISSING", "BUDGET_EXCEEDED",
                                                         "DEVICE_TOO_HOT", "NETWORK_UNSUITABLE", "PROVIDER_FAILED", "INVALID_SPEC"])
        #expect(MirrorFidelity.allCases.map(\.rawValue) == ["CAMERA_ONLY", "LOCAL_GARMENT_OVERLAY", "CLOUD_GENERATED"])
    }

    @Test("LM21-08 / LM21-T32: every picture says what it is and none of them sizes anything")
    func truthLabels() {
        #expect(!MirrorFidelity.mayInformSizeAdvice && !VisualTryOnV1.mayInformSizeAdvice)
        #expect(MirrorFidelity.localGarmentOverlay.truthLabel.contains("kanıtı değildir"))
        #expect(MirrorFidelity.cloudGenerated.truthLabel.contains("Logo") && MirrorFidelity.cloudGenerated.truthLabel.contains("kanıtı değildir"))
        #expect(MirrorFidelity.cameraOnly.tryOnFidelity == .g0 && MirrorFidelity.localGarmentOverlay.tryOnFidelity == .g1)
        #expect(MirrorFidelity.cloudGenerated.tryOnFidelity == .g3)
        for text in MirrorFault.allCases.map(\.userMessage) + DegradeReason.allCases.map(\.note) {
            #expect(!text.contains { $0.isNumber || $0 == "%" || $0 == "°" }, "\(text)")
        }
    }

    @Test("Spec: local carries no consent or price; cloud needs consent, a known price and a 10/15/30 s pack")
    func specRules() {
        #expect((try? localSpec().validate()) != nil)
        var s = localSpec(); s.consentRevision = 1
        #expect(throws: MirrorFault.invalidSpec) { try s.validate() }
        s = localSpec(); s.estimatedMaxCostUSD = 1
        #expect(throws: MirrorFault.invalidSpec) { try s.validate() }
        #expect(throws: MirrorFault.invalidSpec) { try localSpec(seconds: 0).validate() }
        #expect(throws: MirrorFault.invalidSpec) { try localSpec(asset: 0).validate() }
        #expect((try? cloudSpec().validate()) != nil)
        #expect(throws: MirrorFault.invalidSpec) { try cloudSpec(seconds: 60).validate() }
        s = cloudSpec(); s.consentRevision = nil
        #expect(throws: MirrorFault.consentMissing) { try s.validate() }
        s = cloudSpec(); s.estimatedMaxCostUSD = nil
        #expect(throws: MirrorFault.invalidSpec, "price shown before start") { try s.validate() }
        s = localSpec(); s.productVariantID = " "
        #expect(throws: MirrorFault.invalidSpec) { try s.validate() }
    }

    // MARK: Admission

    @Test("LM21-T04 / T05 / T06: only the confirmed variant at the catalogue revision the user saw")
    func admitProduct() throws {
        let budget = DeviceBudget.defaults(for: .turbo)
        #expect(throws: MirrorFault.productUnverified) { try MirrorPolicy.admit(localSpec(), product: product(.candidateOnly), budget: budget, at: t0) }
        #expect(throws: MirrorFault.productUnverified) { try MirrorPolicy.admit(localSpec(), product: product(.notFound), budget: budget, at: t0) }
        #expect(throws: MirrorFault.productAmbiguous) { try MirrorPolicy.admit(localSpec(), product: product(.ambiguous), budget: budget, at: t0) }
        #expect(throws: MirrorFault.productUnverified) { try MirrorPolicy.admit(localSpec(), product: product(id: "pid-2"), budget: budget, at: t0) }
        #expect(throws: MirrorFault.staleRevision) { try MirrorPolicy.admit(localSpec(), product: product(catalog: "cat-8"), budget: budget, at: t0) }
        #expect(try MirrorPolicy.admit(localSpec(), product: product(.exactVerified), budget: budget, at: t0.addingTimeInterval(60)) == .localGarmentOverlay)
        #expect(throws: MirrorFault.productUnverified, "verification expired") {
            try MirrorPolicy.admit(localSpec(), product: product(.exactVerified), budget: budget, at: t0.addingTimeInterval(7200))
        }
    }

    @Test("LM21-06: the device budget picks the fidelity; critical heat or a locked phone opens nothing")
    func admitBudget() throws {
        let p = product()
        #expect(try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .turbo), at: t0) == .localGarmentOverlay)
        #expect(try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .balanced), at: t0) == .cameraOnly)
        #expect(try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .conserve), at: t0) == .cameraOnly)
        #expect(try MirrorPolicy.admit(localSpec(asset: nil), product: p, budget: .defaults(for: .turbo), at: t0) == .cameraOnly)
        #expect(try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .offline), at: t0) == .cameraOnly, "local needs no network")
        #expect(throws: MirrorFault.deviceTooHot) { try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .survival), at: t0) }
        #expect(throws: MirrorFault.cameraUnavailable) { try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .lockedBackground), at: t0) }
    }

    @Test("LM21-T14 / T25 / ADR-008: cloud is refused before any provider or token call; local still works")
    func cloudOff() throws {
        let p = product()
        #expect(throws: MirrorFault.cloudDisabled) { try MirrorPolicy.admit(cloudSpec(), product: p, budget: .defaults(for: .turbo), at: t0) }
        #expect(!MirrorFlags.production.cloudMirrorEnabled)
        #expect(try MirrorPolicy.admit(localSpec(), product: p, budget: .defaults(for: .turbo), at: t0) == .localGarmentOverlay)
        // With the flag on (test-only initialiser), the other gates still apply.
        let on = MirrorFlags(cloudMirrorEnabled: true)
        #expect(throws: MirrorFault.networkUnsuitable) { try MirrorPolicy.admit(cloudSpec(), product: p, budget: .defaults(for: .offline), flags: on, at: t0) }
        #expect(try MirrorPolicy.admit(cloudSpec(), product: p, budget: .defaults(for: .balanced), flags: on, at: t0) == .cloudGenerated)
    }

    // MARK: State machine

    @Test("Transition table: terminal states absorb; nothing holding the camera ends without passing STOPPING; local never preflights")
    func transitionTable() {
        let events: [MirrorEvent] = [.requestPermission, .permissionGranted, .permissionDenied, .goLive, .startPreflight, .preflightPassed,
                                     .connected, .recover, .closed] + DegradeReason.allCases.map(MirrorEvent.degrade)
            + StopReason.allCases.map(MirrorEvent.stop) + MirrorFault.allCases.map(MirrorEvent.fail)
        for mode in MirrorMode.allCases {
            for s in MirrorStatus.allCases {
                for e in events {
                    guard let n = MirrorStateMachine.next(s, e, mode: mode) else { continue }
                    #expect(!s.isTerminal, "\(s) is terminal but \(e) moved it")
                    if s.holdsCamera { #expect(!n.isTerminal, "\(s) → \(n) on \(e) skips closing") }
                    if mode == .local { #expect(n != .preflight && n != .connecting) }
                    if mode == .cloudOptIn, n == .live { #expect(s == .connecting || s == .degraded, "cloud reaches LIVE only through CONNECTING") }
                }
            }
        }
    }

    @Test("Random event storms (2 000 runs): the machine never reopens, records the first cause, and STOPPED always means closed")
    func eventStorms() {
        var rng = SplitMix(seed: 21)
        let events: [MirrorEvent] = [.requestPermission, .permissionGranted, .permissionDenied, .goLive, .startPreflight, .preflightPassed,
                                     .connected, .recover, .closed, .degrade(.deviceWarm), .stop(.userTapped), .stop(.appBackground),
                                     .fail(.providerFailed), .stop(.networkLost)]
        for run in 0..<2000 {
            var m = MirrorStateMachine(mode: run.isMultiple(of: 2) ? .local : .cloudOptIn)
            var firstCause: String?
            var closedSeen = false
            var everHeldCamera = false
            for _ in 0..<12 {
                let e = events[Int(rng.next() % UInt64(events.count))]
                let before = m.status
                let ok = m.apply(e)
                everHeldCamera = everHeldCamera || m.status.holdsCamera
                if ok, firstCause == nil {
                    if case .stop(let r) = e { firstCause = r.rawValue }
                    if case .fail(let f) = e { firstCause = f.rawValue }
                    if case .permissionDenied = e { firstCause = MirrorFault.permissionDenied.rawValue }
                }
                if ok, case .closed = e {
                    closedSeen = true
                    #expect(before == .stopping, "only the provider closing a STOPPING session ends it")
                }
                if before.isTerminal { #expect(m.status == before) }
            }
            if m.status.isTerminal, everHeldCamera { #expect(closedSeen, "ended without the provider confirming it closed") }
            if let firstCause { #expect(m.stopReason?.rawValue == firstCause || m.fault?.rawValue == firstCause) }
        }
    }

    // MARK: Session

    @Test("LM21-T01: permission denied opens nothing and fails with its reason")
    func permissionDenied() async {
        let provider = ScriptedProvider()
        let session = MirrorSession(spec: localSpec(), fidelity: .cameraOnly, provider: provider)
        await session.start(permissionGranted: false, now: 0)
        #expect(await session.status == .failed)
        #expect(await session.fault == .permissionDenied)
        #expect(await provider.prepared == 0)
        #expect(await provider.isOpen == false)
    }

    @Test("LM21-T18 / T20: every stop reason closes the camera exactly once; repeated signals do not reopen or re-close")
    func everyStopCloses() async {
        for reason in StopReason.allCases {
            let provider = ScriptedProvider()
            let session = MirrorSession(spec: localSpec(), fidelity: .localGarmentOverlay, provider: provider)
            await session.start(permissionGranted: true, now: 0)
            #expect(await session.status == .live)
            #expect(await provider.isOpen)
            await session.stop(reason)
            await session.stop(.userTapped)
            await session.fail(.providerFailed)
            #expect(await session.status == .stopped)
            #expect(await session.stopReason == reason)
            #expect(await session.fault == nil)
            #expect(await provider.stopped == 1, "\(reason)")
            #expect(await provider.isOpen == false, "\(reason)")
            #expect(await session.history == [.idle, .requestingPermission, .preview, .live, .stopping, .stopped])
        }
    }

    @Test("LM21-T19: a finished session never starts again by itself; trying again is a new session")
    func noReconnect() async {
        let provider = ScriptedProvider()
        let session = MirrorSession(spec: localSpec(), fidelity: .cameraOnly, provider: provider)
        await session.start(permissionGranted: true, now: 0)
        await session.stop(.networkLost)
        await session.start(permissionGranted: true, now: 10)
        #expect(await provider.prepared == 1)
        #expect(await provider.started == 1)
        #expect(await provider.isOpen == false)
        #expect(await session.status == .stopped)
    }

    @Test("A stop that lands while the camera is still opening wins, and whatever opened late is closed again")
    func stopDuringPrepare() async {
        let provider = ScriptedProvider()
        let session = MirrorSession(spec: localSpec(), fidelity: .cameraOnly, provider: provider)
        await provider.setDuringPrepare { await session.stop(.appBackground) }
        await session.start(permissionGranted: true, now: 0)
        #expect(await session.status == .stopped)
        #expect(await session.stopReason == .appBackground)
        #expect(await provider.isOpen == false)
        #expect(await provider.started == 0)
    }

    @Test("A stop that lands while streaming is starting wins, and the late stream is closed again")
    func stopDuringStart() async {
        for spec in [localSpec(), cloudSpec()] {
            let provider = ScriptedProvider()
            let session = MirrorSession(spec: spec, fidelity: .cameraOnly, provider: provider)
            await provider.setDuringStart { await session.stop(.incomingCall) }
            await session.start(permissionGranted: true, now: 0)
            #expect(await session.status == .stopped)
            #expect(await session.stopReason == .incomingCall)
            #expect(await provider.isStreaming == false)
            #expect(await provider.isOpen == false)
            #expect(await session.history.contains(.live) == false)
        }
    }

    @Test("Provider failure closes the camera and ends FAILED with the reason; the product card stays usable")
    func providerFails() async {
        for (prep, start) in [(MirrorFault.cameraUnavailable, nil), (nil, MirrorFault.providerFailed)] as [(MirrorFault?, MirrorFault?)] {
            let provider = ScriptedProvider(failPrepare: prep, failStart: start)
            let session = MirrorSession(spec: localSpec(), fidelity: .cameraOnly, provider: provider)
            await session.start(permissionGranted: true, now: 0)
            #expect(await session.status == .failed)
            #expect(await session.fault == (prep ?? start))
            #expect(await provider.stopped == 1)
            #expect(await provider.isOpen == false)
        }
    }

    @Test("LM21-06 / T30: warm degrades with a note, critical heat or lock closes; cloud loses network → stop, not reconnect")
    func budgetDuringSession() async {
        let provider = ScriptedProvider()
        let session = MirrorSession(spec: localSpec(), fidelity: .localGarmentOverlay, provider: provider)
        await session.start(permissionGranted: true, now: 0)
        await session.budgetChanged(.defaults(for: .conserve))
        #expect(await session.status == .degraded)
        #expect(await session.degradeReason == .deviceWarm)
        await session.budgetChanged(.defaults(for: .offline))
        #expect(await session.status == .degraded, "local does not need the network")
        await session.recover()
        #expect(await session.status == .live)
        #expect(await session.degradeReason == nil)
        await session.budgetChanged(.defaults(for: .survival))
        #expect(await session.status == .stopped)
        #expect(await session.stopReason == .thermalCritical)
        #expect(await provider.isOpen == false)

        let cloudProvider = ScriptedProvider()
        let cloud = MirrorSession(spec: cloudSpec(), fidelity: .cloudGenerated, provider: cloudProvider)
        await cloud.start(permissionGranted: true, now: 0)
        #expect(await cloud.history == [.idle, .requestingPermission, .preview, .preflight, .connecting, .live])
        await cloud.budgetChanged(.defaults(for: .offline))
        #expect(await cloud.status == .stopped)
        #expect(await cloud.stopReason == .networkLost)
        #expect(await cloudProvider.prepared == 1)
        #expect(await cloudProvider.isOpen == false)

        let locked = MirrorSession(spec: localSpec(), fidelity: .cameraOnly, provider: ScriptedProvider())
        await locked.start(permissionGranted: true, now: 0)
        await locked.budgetChanged(.defaults(for: .lockedBackground))
        #expect(await locked.stopReason == .screenLocked)
    }

    @Test("LM21-T23: the duration cap ends the session on time")
    func durationCap() async {
        let provider = ScriptedProvider()
        let session = MirrorSession(spec: cloudSpec(seconds: 10), fidelity: .cloudGenerated, provider: provider)
        await session.start(permissionGranted: true, now: 100)
        await session.tick(now: 109.9)
        #expect(await session.status == .live)
        await session.tick(now: 110)
        #expect(await session.status == .stopped)
        #expect(await session.stopReason == .maxDuration)
        #expect(await provider.isOpen == false)
    }

    @Test("LM21-T06: any revision change under the session ends it")
    func revisionChangeStops() async {
        for change in 0..<4 {
            let provider = ScriptedProvider()
            let spec = localSpec()
            let session = MirrorSession(spec: spec, fidelity: .localGarmentOverlay, provider: provider)
            await session.start(permissionGranted: true, now: 0)
            await session.revisionsChanged(productVariantID: spec.productVariantID, catalogVersion: spec.catalogVersion,
                                           assetRevision: spec.assetRevision, bodyProfileRevision: spec.bodyProfileRevision)
            #expect(await session.status == .live, "same revisions change nothing")
            await session.revisionsChanged(
                productVariantID: change == 0 ? "pid-2" : spec.productVariantID, catalogVersion: change == 1 ? "cat-8" : spec.catalogVersion,
                assetRevision: change == 2 ? 4 : spec.assetRevision, bodyProfileRevision: change == 3 ? 5 : spec.bodyProfileRevision)
            #expect(await session.stopReason == .productChanged)
            #expect(await provider.isOpen == false)
        }
    }

    // MARK: Frames

    @Test("Frame guard: fresh frames show, late ones carry a delay note, very late, reordered or stale-revision frames never show")
    func frames() {
        let spec = localSpec()
        func stamp(_ seq: UInt64, at t: TimeInterval, asset: Int? = 3, body: Int? = 4, catalog: String = "cat-7") -> FrameStamp {
            FrameStamp(sequence: seq, capturedAt: t, productVariantID: "pid-1", catalogVersion: catalog, assetRevision: asset, bodyProfileRevision: body)
        }
        var g = FrameGuard(spec: spec)
        #expect(g.admit(stamp(1, at: 10), now: 10.1) == .show)
        #expect(g.admit(stamp(2, at: 10), now: 10.6) == .showDelayed)
        #expect(g.admit(stamp(3, at: 10), now: 11.5) == .drop(.tooLate))
        #expect(g.admit(stamp(2, at: 11), now: 11.1) == .drop(.outOfOrder))
        #expect(g.admit(stamp(4, at: 12), now: 11.9) == .drop(.fromTheFuture))
        #expect(g.admit(stamp(5, at: 12, asset: 2), now: 12.1) == .drop(.staleRevision))
        #expect(g.admit(stamp(6, at: 12, body: 3), now: 12.1) == .drop(.staleRevision))
        #expect(g.admit(stamp(7, at: 12, catalog: "cat-6"), now: 12.1) == .drop(.staleRevision))
        #expect(g.admit(stamp(8, at: .nan), now: 12.1) == .drop(.tooLate))
        #expect(g.admit(stamp(9, at: 12), now: 12.2) == .show)
        #expect(g.lastShown == 9)
    }
}

struct SplitMix {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
