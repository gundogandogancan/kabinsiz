import BodyGeometry
import DomainContracts
import Foundation
import SystemContracts
import Vault

// MARK: - Preview scene

/// What the screen draws (OCT-08 output). Built from an `AvatarSnapshot` only, never from measurements.
public struct PreviewScene: Codable, Hashable, Sendable {
    public let bodyRevision: Int
    public let tier: VisualFidelityTier
    /// Right half of the outline, normalised: y in 0…1 from the crown, x as a fraction of height.
    /// Empty when the shape could not be drawn and the values list is the fallback (V15-T-BOD-07).
    public let rightOutline: [Silhouette.Point]
    public let isFallback: Bool
    /// The neutral 3D body (ADR-007) when the budget allows a mesh; nil under `2D_CARD` or if the mesh
    /// failed validation, and the 2D outline is drawn instead (G0 fallback).
    public let mesh: BodyMesh?

    public init(bodyRevision: Int, tier: VisualFidelityTier, rightOutline: [Silhouette.Point], isFallback: Bool, mesh: BodyMesh? = nil) {
        self.bodyRevision = bodyRevision
        self.tier = tier
        self.rightOutline = rightOutline
        self.isFallback = isFallback
        self.mesh = mesh
    }

    /// Full outline plus the neutral 3D mesh under a 3D-capable budget; only the station anchors and no
    /// mesh under `2D_CARD` (lower LOD, same controls, V15-T-BOD-08).
    public static func render(_ snapshot: AvatarSnapshot, maxTier: VisualFidelityTier) -> PreviewScene {
        let shape = snapshot.silhouette
        let h = shape.heightCm
        let points: [Silhouette.Point]
        if maxTier == .flat2D {
            points = Silhouette.Station.allCases.compactMap { station in
                shape.halfWidthsCm[station].map { Silhouette.Point(x: $0 / h, y: station.heightFraction) }
            }
        } else {
            points = shape.rightOutline.map { Silhouette.Point(x: $0.x / h, y: $0.y / h) }
        }
        // The 2D outline always travels with the mesh, so the view can fall back without another run.
        let mesh = maxTier == .flat2D ? nil : try? BodyMesh.make(from: snapshot)
        return PreviewScene(bodyRevision: snapshot.bodyRevision, tier: mesh == nil ? .flat2D : .genericMesh,
                            rightOutline: points, isFallback: false, mesh: mesh)
    }

    public static func valuesOnly(bodyRevision: Int) -> PreviewScene {
        PreviewScene(bodyRevision: bodyRevision, tier: .flat2D, rightOutline: [], isFallback: true)
    }
}

// MARK: - Events

/// Body events carry no measurement values (§105.3 "minimum safe fields"); the vault holds the truth.
public struct BodyEventPayload: Codable, Hashable, Sendable {
    public enum Kind: String, Codable, Sendable { case committed = "COMMITTED", deleted = "DELETED" }
    public let kind: Kind
    public let changedParameter: BodyParameter?
}

public typealias BodyEvent = DomainEventV1<BodyEventPayload>

/// In-process event log (§105.3: delivery may be lost on termination; durable truth is the vault).
public actor EventJournal {
    public static let capacity = 500
    public private(set) var events: [BodyEvent] = []

    public init() {}

    public func append(_ event: BodyEvent) throws(FaultCode) {
        try event.validate()
        events.append(event)
        if events.count > Self.capacity { events.removeFirst(events.count - Self.capacity) }
    }
}

/// Replays body events into "what is committed". Idempotent and order-safe: duplicates and older
/// revisions are ignored, and a replayed commit can never resurrect a deleted body (V15-T-ORC-07).
public struct BodyProjection: Sendable, Equatable {
    public private(set) var committedRevision: Int?
    public private(set) var isDeleted = false
    private var guardRail = EntityRevisionGuard()

    public init() {}

    @discardableResult
    public mutating func apply(_ event: BodyEvent) -> Bool {
        do { try guardRail.accept(event) } catch { return false }
        switch event.payload.kind {
        case .committed:
            committedRevision = event.revision
            isDeleted = false
        case .deleted:
            committedRevision = nil
            isDeleted = true
        }
        return true
    }

    public static func == (a: Self, b: Self) -> Bool { a.committedRevision == b.committedRevision && a.isDeleted == b.isDeleted }
}

// MARK: - Store

/// Where committed body truth lives. Revisions only go up: an older or equal one is refused at the
/// persistence boundary (V15-T-ORC-08), not by the UI.
public protocol BodyStore: Sendable {
    func load() async throws -> BodyProfile?
    func save(_ profile: BodyProfile, snapshot: AvatarSnapshot) async throws
    func delete() async throws -> DeletionReceipt
}

public actor VaultBodyStore: BodyStore {
    public static let profileSpec = VaultRecordSpec(id: "body-profile", type: "body-profile", domain: .body, classification: .localSensitive)
    /// Derived from the profile: deleting the profile deletes it (V15-T-BOD-10, CRY-10). The geometry lets the
    /// measurements be recovered, so it is as sensitive as the profile itself.
    public static let avatarSpec = VaultRecordSpec(id: "avatar-cache", type: "avatar-cache", domain: .body,
                                                   classification: .localSensitive, derivedFrom: ["body-profile"])

    private let vault: @Sendable () async -> Vault?
    private var lastRevision = 0

    /// `vault` is asked on every call, because "delete everything" replaces the vault instance.
    public init(vault: @escaping @Sendable () async -> Vault?) { self.vault = vault }

    private func current() async throws -> Vault {
        guard let v = await vault() else { throw FaultCode.storageCorrupted }
        return v
    }

    public func load() async throws -> BodyProfile? {
        let profile = try await current().get(BodyProfile.self, id: Self.profileSpec.id, currentVersion: BodyProfile.schemaVersion)
        // A record that decrypts but is out of range is treated as unreadable, never drawn or edited.
        try profile?.validate()
        lastRevision = max(lastRevision, profile?.revision ?? 0)
        return profile
    }

    /// The revision is checked and claimed before the first await, so two saves can never interleave and
    /// leave the older one on disk; a failed save still burns its revision.
    public func save(_ profile: BodyProfile, snapshot: AvatarSnapshot) async throws {
        guard profile.revision > lastRevision, snapshot.bodyRevision == profile.revision else { throw FaultCode.staleRevision }
        lastRevision = profile.revision
        let v = try await current()
        try await v.put(profile, Self.profileSpec, schemaVersion: BodyProfile.schemaVersion)
        try await v.put(snapshot, Self.avatarSpec, schemaVersion: 1)
    }

    public func delete() async throws -> DeletionReceipt {
        try await current().delete(Self.profileSpec.id)
    }

    /// Highest revision this store has seen, so a body created after a delete continues above it.
    public var highestRevision: Int { lastRevision }
}

// MARK: - The journey

/// §133 step 5, one journey through the coordinator: slider changed → body revision → preview → local save.
/// Previews are latest-wins and cancellable; commits are serialized and never cancelled by a newer
/// preview or by the screen going away (§103.1 "without stopping critical persistence").
public actor BodyStudio {
    public enum Status: Equatable, Sendable {
        case noProfile, ready, unreadable
        /// Closed for "delete everything": queued commits are refused until `load()` runs again.
        case closed
    }

    private let coordinator: OctopusCoordinator
    private let store: any BodyStore
    public nonisolated let journal: EventJournal
    private let renderer: @Sendable (AvatarSnapshot, VisualFidelityTier) async throws -> PreviewScene
    private let renderDeadline: Duration
    private let clock: @Sendable () -> Date

    public private(set) var profile: BodyProfile?
    public private(set) var status: Status = .noProfile
    private var history = BodyEditHistory()
    private var highestRevision = 0
    private var lastCommit: Task<Void, Never>?

    public init(
        coordinator: OctopusCoordinator, store: any BodyStore, journal: EventJournal = EventJournal(),
        renderDeadline: Duration = .milliseconds(500), clock: @escaping @Sendable () -> Date = Date.init,
        renderer: @escaping @Sendable (AvatarSnapshot, VisualFidelityTier) async throws -> PreviewScene = { PreviewScene.render($0, maxTier: $1) }
    ) {
        self.coordinator = coordinator
        self.store = store
        self.journal = journal
        self.renderer = renderer
        self.renderDeadline = renderDeadline
        self.clock = clock
    }

    public var canUndo: Bool { history.canUndo }
    public var canRedo: Bool { history.canRedo }

    /// An unreadable stored body is never overwritten: the studio stays read-only until the user deletes it.
    /// Runs in the commit queue and clears undo, so nothing from before a reload can be restored.
    @discardableResult
    public func load() async -> Status {
        await serialized { studio in await studio.performLoad() }
    }

    /// Refuses every commit queued after this until the next `load()`. Returns once earlier commits finished.
    public func close() async {
        await serialized { studio in await studio.performClose() }
    }

    private func performLoad() async -> Status {
        history.reset()
        do {
            profile = try await store.load()
            highestRevision = max(highestRevision, profile?.revision ?? 0)
            status = profile == nil ? .noProfile : .ready
        } catch {
            profile = nil
            status = .unreadable
        }
        return status
    }

    private func performClose() async {
        await coordinator.cancelLane(Self.previewLane)
        status = .closed
        profile = nil
        history.reset()
    }

    // MARK: Preview (latest-wins, nothing saved)

    /// `nil` when a newer drag superseded this one.
    public func preview(_ edit: BodyEdit) async -> DecisionEnvelope<PreviewScene>? {
        guard status == .ready, let base = profile else { return .failure(traceID: UUID().uuidString, .schemaInvalid) }
        let graph: TaskGraph
        do { graph = try Self.graph(base: base, change: .edit(edit), revision: highestRevision + 1, persist: nil, render: renderNode(), renderDeadline: renderDeadline) } catch {
            return .failure(traceID: UUID().uuidString, error)
        }
        let coordinator = coordinator
        return await coordinator.latest(lane: Self.previewLane) {
            await coordinator.run(graph, context: Self.context(base), priority: .p0Interactive) { try Self.scene(from: $0) }.envelope
        }
    }

    static let previewLane = "body.preview"

    /// The committed body drawn through the coordinator, so the device budget picks the detail (BOD-08).
    public func currentScene() async -> DecisionEnvelope<PreviewScene>? {
        guard status == .ready, let base = profile else { return nil }
        guard let graph = try? Self.graph(base: base, change: .restore(base), revision: base.revision, persist: nil,
                                          render: renderNode(), renderDeadline: renderDeadline) else { return nil }
        return await coordinator.run(graph, context: Self.context(base), priority: .p0Interactive) { try Self.scene(from: $0) }.envelope
    }

    // MARK: Commits (serialized, not cancellable)

    public func createNeutral(unit: LengthUnit = .centimeters) async -> DecisionEnvelope<PreviewScene> {
        await serialized { studio in await studio.performCreateNeutral(unit: unit) }
    }

    public func commit(_ edit: BodyEdit) async -> DecisionEnvelope<PreviewScene> {
        await serialized { studio in await studio.perform(.edit(edit)) }
    }

    public func undo() async -> DecisionEnvelope<PreviewScene>? {
        await serialized { studio in await studio.performUndoRedo(undo: true) }
    }

    public func redo() async -> DecisionEnvelope<PreviewScene>? {
        await serialized { studio in await studio.performUndoRedo(undo: false) }
    }

    public func setUnit(_ unit: LengthUnit) async -> DecisionEnvelope<PreviewScene>? {
        await serialized { studio in
            guard let base = await studio.profile, base.preferredUnit != unit else { return nil }
            var target = base.restoring(base)
            target.preferredUnit = unit
            return await studio.perform(.restore(target), recordHistory: false)
        }
    }

    /// Deletes the body and everything derived from it; the renderer drops its snapshot (V15-T-BOD-10).
    public func deleteProfile() async -> Result<DeletionReceipt, FaultCode> {
        await serialized { studio in await studio.performDelete() }
    }

    /// Runs one commit at a time, in a task that does not inherit the caller's cancellation.
    private func serialized<R: Sendable>(_ work: @escaping @Sendable (BodyStudio) async -> R) async -> R {
        let previous = lastCommit
        let task = Task { await previous?.value; return await work(self) }
        lastCommit = Task { _ = await task.value }
        return await task.value
    }

    enum Change: Sendable {
        case edit(BodyEdit)
        case restore(BodyProfile)

        /// The new profile at exactly `revision`. Revisions come from the studio, not from the base, so a
        /// write that timed out and landed later can never collide with the next commit.
        func apply(to base: BodyProfile?, revision: Int) throws -> BodyProfile {
            let next: BodyProfile
            switch self {
            case .edit(let edit):
                guard let base else { throw FaultCode.schemaInvalid }
                next = try base.applying(edit)
            case .restore(let target):
                next = target
            }
            let stamped = BodyProfile(revision: revision, values: next.values, preferredUnit: next.preferredUnit)
            try stamped.validate()
            return stamped
        }
    }

    private func performCreateNeutral(unit: LengthUnit) async -> DecisionEnvelope<PreviewScene> {
        // Only from empty: a double tap must never reset an existing body without undo.
        guard status == .noProfile else {
            return .failure(traceID: UUID().uuidString, status == .ready ? .schemaInvalid : .storageCorrupted)
        }
        let start = BodyProfile.neutral(unit: unit)
        let target = BodyProfile(revision: 0, values: start.values, preferredUnit: unit)
        return await perform(.restore(target), recordHistory: false, allowFromEmpty: true)
    }

    private func performUndoRedo(undo: Bool) async -> DecisionEnvelope<PreviewScene>? {
        guard status == .ready, let current = profile else { return nil }
        var scratch = history
        guard let target = undo ? scratch.undo(from: current) : scratch.redo(from: current) else { return nil }
        let result = await perform(.restore(target), recordHistory: false)
        if result.value != nil { history = scratch }
        return result
    }

    private func perform(_ change: Change, recordHistory: Bool = true, allowFromEmpty: Bool = false) async -> DecisionEnvelope<PreviewScene> {
        let trace = UUID().uuidString
        guard status == .ready || (allowFromEmpty && status == .noProfile) else {
            return .failure(traceID: trace, status == .ready || status == .noProfile ? .schemaInvalid : .storageCorrupted)
        }
        let base = profile
        let store = store
        // Burn the revision up front: even if this commit fails, the next one goes above it.
        highestRevision += 1
        let revision = highestRevision
        let graph: TaskGraph
        do {
            graph = try Self.graph(base: base, change: change, revision: revision, persist: { profile, snapshot in
                try await store.save(profile, snapshot: snapshot)
            }, render: renderNode(), renderDeadline: renderDeadline)
        } catch {
            return .failure(traceID: trace, error)
        }
        let outcome = await coordinator.run(graph, context: Self.context(base), priority: .p0Interactive, traceID: trace) { try Self.scene(from: $0) }
        guard outcome.envelope.value != nil, let committed = try? change.apply(to: base, revision: revision) else {
            // The write may have happened even though the run failed: the store, not memory, is the truth.
            await resync()
            return outcome.envelope
        }
        if recordHistory, let base { history.recordCommit(previous: base) }
        profile = committed
        status = .ready
        let changed: BodyParameter? = if case .edit(let e) = change { e.parameter } else { nil }
        try? await journal.append(event(.committed, revision: committed.revision, parameter: changed, trace: trace))
        return outcome.envelope
    }

    private func performDelete() async -> Result<DeletionReceipt, FaultCode> {
        guard status != .closed else { return .failure(.storageCorrupted) }
        let store = store
        let trace = UUID().uuidString
        await coordinator.cancelLane(Self.previewLane)
        let node = TaskNode(id: "delete", module: .consentGuardian, capabilities: [.vaultDelete], mustComplete: true) { _ in
            try await store.delete()
        }
        let graph: TaskGraph
        do { graph = try TaskGraph([node]) } catch { return .failure(error) }
        let outcome = await coordinator.run(graph, context: ContextSnapshot(), priority: .p0Interactive, traceID: trace) { outputs in
            guard let receipt = outputs["delete"] as? DeletionReceipt else { throw FaultCode.schemaInvalid }
            return receipt
        }
        guard let receipt = outcome.envelope.value else {
            await resync()
            return .failure(outcome.envelope.fault ?? .moduleFailed)
        }
        highestRevision += 1
        profile = nil
        status = .noProfile
        history.reset()
        try? await journal.append(event(.deleted, revision: highestRevision, parameter: nil, trace: trace))
        return .success(receipt)
    }

    /// Re-reads the store after a failed write or delete. Undo history is kept; it holds whole profiles.
    private func resync() async {
        guard status != .closed else { return }
        do {
            profile = try await store.load()
            highestRevision = max(highestRevision, profile?.revision ?? 0)
            status = profile == nil ? .noProfile : .ready
        } catch {
            profile = nil
            status = .unreadable
        }
    }

    private func event(_ kind: BodyEventPayload.Kind, revision: Int, parameter: BodyParameter?, trace: String) -> BodyEvent {
        BodyEvent(
            eventType: kind == .committed ? "avatar.revision.committed" : "body.profile.deleted", occurredAtUTC: clock(),
            traceID: trace, sourceModule: kind == .committed ? .bodyGeometry : .consentGuardian, entityKind: "body",
            entityLocalID: "body-profile", revision: revision, payloadClassification: .localPrivate,
            provenance: EventProvenance(sourceKind: "USER_EDIT"), payload: BodyEventPayload(kind: kind, changedParameter: parameter)
        )
    }

    // MARK: Graph

    private func renderNode() -> (@Sendable (AvatarSnapshot) async throws -> PreviewScene) {
        let renderer = renderer
        let tier = coordinator.governor.budget.maxVisualTier
        return { snapshot in try await renderer(snapshot, tier) }
    }

    static func context(_ base: BodyProfile?) -> ContextSnapshot {
        guard let base else { return ContextSnapshot() }
        return ContextSnapshot(["body.profile": ContextEntry(base, requires: .bodyReadExact)])
    }

    /// morph (OCT-07: profile → snapshot) → render (OCT-08: snapshot → scene, fallback values-only),
    /// plus persist (OCT-07: write the same revision) when committing. The renderer reads the
    /// snapshot only; it never sees the profile.
    static func graph(
        base: BodyProfile?, change: Change, revision: Int,
        persist: (@Sendable (BodyProfile, AvatarSnapshot) async throws -> Void)?,
        render: @escaping @Sendable (AvatarSnapshot) async throws -> PreviewScene,
        renderDeadline: Duration = .milliseconds(500)
    ) throws(FaultCode) -> TaskGraph {
        let reads: Set<String> = base == nil ? [] : ["body.profile"]
        var nodes = [
            TaskNode(id: "morph", module: .bodyGeometry, capabilities: [.bodyReadExact], reads: reads, deadline: .milliseconds(200)) { input in
                let current: BodyProfile? = try? input.context("body.profile")
                let next = try change.apply(to: current, revision: revision)
                return try AvatarSnapshot.make(for: next)
            },
            TaskNode(id: "render", module: .avatarRenderer, capabilities: [.avatarReadRenderSnapshot], dependsOn: ["morph"],
                     deadline: renderDeadline, isHeavy: true,
                     fallback: { _ in PreviewScene.valuesOnly(bodyRevision: -1) },
                     fallbackLimitation: "Şekil çizilemedi; değerler listede gösteriliyor.") { input in
                try await render(try input.upstream("morph", as: AvatarSnapshot.self))
            },
        ]
        if let persist {
            nodes.append(TaskNode(id: "persist", module: .bodyGeometry, capabilities: [.bodyWriteManual, .bodyReadExact],
                                  reads: reads, dependsOn: ["morph"], mustComplete: true) { input in
                let current: BodyProfile? = try? input.context("body.profile")
                let next = try change.apply(to: current, revision: revision)
                let snapshot = try input.upstream("morph", as: AvatarSnapshot.self)
                try await persist(next, snapshot)
                return next.revision
            })
        }
        return try TaskGraph(nodes)
    }

    static func scene(from outputs: [String: any Sendable]) throws -> PreviewScene {
        guard let snapshot = outputs["morph"] as? AvatarSnapshot, let scene = outputs["render"] as? PreviewScene else {
            throw FaultCode.schemaInvalid
        }
        // The fallback does not know the revision; stamp it here so stale-result checks still work.
        return scene.isFallback ? .valuesOnly(bodyRevision: snapshot.bodyRevision) : scene
    }
}
