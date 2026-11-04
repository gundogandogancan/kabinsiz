import BodyGeometry
import DomainContracts
import Foundation
@testable import Octopus
import SystemContracts
import Testing
import Vault

@Suite("Body journey: slider → revision → preview → local save (§133, §127.7)")
struct BodyJourneyTests {
    // MARK: BOD-01 / relaunch

    @Test("V15-T-BOD-01: a waist slider gives a coherent preview and a saved revision that survives a relaunch")
    func waistSliderSaves() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("body-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let keys = EphemeralKeyStore()
        let vault = try Vault.open(directory: dir, keyStore: keys)
        let store = VaultBodyStore { vault }
        let s = studio(store: store)

        #expect(await s.load() == .noProfile)
        let created = await s.createNeutral()
        #expect(created.state == .completed)
        let neutral = try #require(await s.profile)
        #expect(neutral.values.values.allSatisfy { $0.source == .neutralStart })

        let committed = await s.commit(.slider(.waist, cm: 74))
        let scene = try #require(committed.value)
        let profile = try #require(await s.profile)
        #expect(profile.cm(.waist) == 74)
        #expect(profile[.waist].source == .sliderShaped)
        #expect(profile.revision > neutral.revision)
        #expect(scene.bodyRevision == profile.revision)
        #expect(scene == PreviewScene.render(try AvatarSnapshot.make(for: profile), maxTier: .genericMesh))
        #expect(scene.isFallback == false)
        // Only the waist moved.
        for p in BodyParameter.allCases where p != .waist { #expect(profile[p] == neutral[p]) }

        // A preview saves nothing.
        let saved = try #require(try await store.load())
        let previewed = await s.preview(.slider(.waist, cm: 120))
        #expect(previewed?.value != nil)
        #expect(try await store.load() == saved)
        #expect(await s.profile == saved)

        // Relaunch: a fresh vault instance and studio see the same values.
        await vault.close()
        let reopened = try Vault.open(directory: dir, keyStore: keys)
        let again = studio(store: VaultBodyStore { reopened })
        #expect(await again.load() == .ready)
        #expect(await again.profile == profile)
        #expect(await reopened.contains("avatar-cache"))

        let events = await s.journal.events
        #expect(events.map(\.payload.kind) == [.committed, .committed])
        #expect(events.last?.payload.changedParameter == .waist)
        #expect(events.last?.revision == profile.revision)
    }

    // MARK: BOD-02

    @Test("V15-T-BOD-02: every extreme combination (3⁵ = 243) is either a valid shape or refused as out of range — never a broken mesh")
    func extremeCombinations() throws {
        let params = BodyParameter.allCases
        func values(_ p: BodyParameter) -> [Double] { [p.safeRange.lowerBound, p.neutralStartCm, p.safeRange.upperBound] }
        var combos: [[Double]] = [[]]
        for p in params { combos = combos.flatMap { c in values(p).map { c + [$0] } } }
        #expect(combos.count == 243)
        var valid = 0
        for c in combos {
            var vals: [BodyParameter: BodyValue] = [:]
            for (i, p) in params.enumerated() { vals[p] = BodyValue(BodyLength(c[i], .centimeters), source: .sliderShaped) }
            let profile = BodyProfile(revision: 1, values: vals, preferredUnit: .centimeters)
            var refusal: BodyEditError?
            do { try profile.validate() } catch { refusal = error }
            if let refusal {
                #expect(refusal == .outOfSafeRange(.shoulderWidth), "only the shoulder/height link may refuse a combination")
                #expect(c[1] > c[0] * BodyProfile.maxShoulderToHeight)
            } else {
                let shape = try Silhouette.make(for: profile)
                #expect(shape.rightOutline.allSatisfy { $0.x > 0 && $0.x.isFinite })
                valid += 1
            }
        }
        #expect(valid == 216, "only the 27 bodies with 60 cm shoulders at 120 cm height are refused")
    }

    @Test("V15-T-BOD-02: 5 000 random drags inside the offered slider ranges always give a valid shape")
    func randomDrags() throws {
        var rng = SystemRandomNumberGenerator()
        var profile = BodyProfile.neutral()
        for _ in 0..<5_000 {
            let p = BodyParameter.allCases.randomElement(using: &rng)!
            let range = profile.allowedRange(p)
            let steps = Int((range.upperBound - range.lowerBound) / BodyParameter.sliderStepCm)
            let value = range.lowerBound + Double(Int.random(in: 0...steps, using: &rng)) * BodyParameter.sliderStepCm
            profile = try profile.applying(.slider(p, cm: value))
            try profile.validate()
        }
    }

    @Test("Out-of-range and non-finite slider values are refused, and the body is unchanged")
    func rangeGuard() async throws {
        let s = studio()
        _ = await s.createNeutral()
        let before = try #require(await s.profile)
        for bad in [BodyEdit.slider(.waist, cm: 10), .slider(.height, cm: 400), .slider(.chest, cm: .nan), .slider(.hip, cm: .infinity)] {
            let result = await s.commit(bad)
            #expect(result.value == nil)
        }
        #expect(await s.profile == before)
        #expect(throws: BodyEditError.self) { try BodyProfile.neutral().applying(.slider(.shoulderWidth, cm: 29.9)) }
    }

    // MARK: BOD-03

    @Test("V15-T-BOD-03: three undos restore the exact earlier values; redo returns; a new edit clears redo")
    func undoRedo() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral()
        let start = try #require(await s.profile)
        _ = await s.commit(.slider(.waist, cm: 70.5))
        _ = await s.commit(.slider(.hip, cm: 110))
        _ = await s.commit(.measured(.chest, 101.3, .centimeters))
        let end = try #require(await s.profile)

        for _ in 0..<3 { #expect(await s.undo()?.value != nil) }
        let undone = try #require(await s.profile)
        #expect(undone.sameShape(as: start))
        #expect(undone.revision > end.revision, "undo is a new revision, never a rewind")
        #expect(await s.undo() == nil)
        #expect(try await store.load()?.sameShape(as: start) == true)

        for _ in 0..<3 { _ = await s.redo() }
        #expect(try #require(await s.profile).sameShape(as: end))

        _ = await s.undo()
        _ = await s.commit(.slider(.height, cm: 180))
        #expect(await s.canRedo == false)
    }

    // MARK: BOD-04

    @Test("V15-T-BOD-04: inches are converted once, stored exactly, and a unit switch never changes the body")
    func unitConversion() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral(unit: .inches)
        _ = await s.commit(.measured(.waist, 32, .inches))
        let profile = try #require(await s.profile)
        #expect(profile[.waist].length.tenthsOfMillimeter == 32 * 254)
        #expect(profile[.waist].length.value(in: .inches) == 32)
        #expect(profile.measuredCentimeters == [.waist: 81.28])

        _ = await s.setUnit(.centimeters)
        _ = await s.setUnit(.inches)
        _ = await s.setUnit(.centimeters)
        let after = try #require(await s.profile)
        #expect(after.preferredUnit == .centimeters)
        #expect(after.sameShape(as: profile))
        #expect(after[.waist].length.tenthsOfMillimeter == 32 * 254)
        #expect(await s.setUnit(.centimeters) == nil, "no-op switch writes nothing")
    }

    // MARK: Body form (ADR-017)

    @Test("BFORM-T07: the studio saves the chosen form, keeps typed values, undoes it, and keeps it across a relaunch")
    func formThroughStudio() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("form-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let keys = EphemeralKeyStore()
        let vault = try Vault.open(directory: dir, keyStore: keys)
        let s = studio(store: VaultBodyStore { vault })
        _ = await s.createNeutral(form: .feminine)
        let created = try #require(await s.profile)
        #expect(created.form == .feminine && created.cm(.height) == BodyForm.feminine.startCm(.height))
        _ = await s.commit(.measured(.waist, 71, .centimeters))
        let changed = await s.setForm(.masculine)
        #expect(changed?.value != nil)
        let male = try #require(await s.profile)
        #expect(male.form == .masculine && male.cm(.waist) == 71 && male[.waist].source == .userMeasured)
        #expect(male.cm(.height) == BodyForm.masculine.startCm(.height))
        #expect(await s.setForm(.masculine) == nil, "same form writes nothing")
        #expect(await s.undo()?.value != nil)
        #expect(try #require(await s.profile).form == .feminine, "a form change is undoable")
        _ = await s.redo()
        let saved = try #require(await s.profile)
        #expect(saved.form == .masculine)
        // A unit switch or an edit never drops the form (the studio restamps every revision).
        _ = await s.setUnit(.inches)
        _ = await s.commit(.slider(.hip, cm: 99))
        #expect(try #require(await s.profile).form == .masculine)
        await vault.close()
        let reopened = try Vault.open(directory: dir, keyStore: keys)
        let again = studio(store: VaultBodyStore { reopened })
        #expect(await again.load() == .ready)
        #expect(await again.profile?.form == .masculine)
    }

    // MARK: BOD-06 / offline

    @Test("V15-T-BOD-06: the manual flow needs no photos and no network, and works on an offline budget")
    func manualOffline() async throws {
        let graph = try BodyStudio.graph(base: .neutral(), change: .edit(.slider(.waist, cm: 80)), revision: 2,
                                         persist: { _, _ in }, render: { PreviewScene.render($0, maxTier: .flat2D) })
        let capabilities = Set(graph.nodes.flatMap(\.capabilities))
        #expect(capabilities == [.bodyReadExact, .bodyWriteManual, .avatarReadRenderSnapshot])
        #expect(graph.usesNetwork == false)
        let render = try #require(graph.nodes.first { $0.id == "render" })
        #expect(render.reads.isEmpty, "the renderer reads the snapshot, never the profile")
        #expect(render.capabilities == [.avatarReadRenderSnapshot])

        for tier in [ExecutionTier.offline, .survival] {
            let s = studio(governor: BudgetGovernor(budget: .defaults(for: tier)))
            #expect(await s.createNeutral().value != nil)
            #expect(await s.commit(.measured(.height, 176, .centimeters)).value != nil)
        }
    }

    // MARK: BOD-07 / BOD-08

    @Test("V15-T-BOD-07: a broken or slow renderer degrades to the labelled values list; the body still saves")
    func rendererFallback() async throws {
        struct Broken: Error {}
        let store = MemoryBodyStore()
        let s = studio(store: store) { _, _ in throw Broken() }
        _ = await s.createNeutral()
        let result = await s.commit(.slider(.hip, cm: 104))
        #expect(result.state == .degraded)
        #expect(result.confidence == .partial)
        #expect(result.limitations == ["Şekil çizilemedi; değerler listede gösteriliyor."])
        let scene = try #require(result.value)
        #expect(scene.isFallback)
        #expect(scene.rightOutline.isEmpty)
        let profile = try #require(await s.profile)
        #expect(scene.bodyRevision == profile.revision)
        #expect(try await store.load() == profile)

        let hang = Signal()
        let slow = studio(renderDeadline: .milliseconds(50)) { snapshot, tier in
            await hang.wait()
            return PreviewScene.render(snapshot, maxTier: tier)
        }
        _ = await slow.createNeutral()
        let timed = await slow.commit(.slider(.waist, cm: 90))
        #expect(timed.value?.isFallback == true)
        #expect(await slow.profile?.cm(.waist) == 90)
        await hang.fire()
    }

    @Test("V15-T-BOD-08: under a 2D budget the preview drops to station anchors, same controls")
    func lowerLOD() async throws {
        let s = studio(governor: BudgetGovernor(budget: .defaults(for: .conserve)))
        let full = studio()
        _ = await s.createNeutral()
        _ = await full.createNeutral()
        let low = try #require(await s.commit(.slider(.waist, cm: 80)).value)
        let high = try #require(await full.commit(.slider(.waist, cm: 80)).value)
        #expect(low.rightOutline.count == Silhouette.Station.allCases.count)
        #expect(high.rightOutline.count > low.rightOutline.count)
        #expect(low.isFallback == false)
    }

    // MARK: BOD-09

    @Test("V15-T-BOD-09: the avatar model is structural only — fixed stations, no anatomy, no measurement values")
    func structuralOnly() throws {
        #expect(Silhouette.Station.allCases.map(\.rawValue) ==
            ["crown", "headWidest", "neck", "shoulder", "chest", "waist", "hip", "thigh", "knee", "ankle"])
        let profile = try BodyProfile.neutral().applying(.measured(.chest, 101.3, .centimeters))
        let json = String(decoding: try JSONEncoder().encode(AvatarSnapshot.make(for: profile)), as: UTF8.self).lowercased()
        for forbidden in ["tenths", "source", "user_measured", "values", "face", "hair", "skin", "nipple", "genital", "gender", "age"] {
            #expect(!json.contains("\"\(forbidden)"), "snapshot leaks \(forbidden)")
        }
    }

    @Test("Body events carry kind, revision and parameter name only — never a value")
    func eventsCarryNoValues() async throws {
        let s = studio()
        _ = await s.createNeutral()
        _ = await s.commit(.measured(.waist, 77.7, .centimeters))
        let events = await s.journal.events
        let payloadJSON = try String(decoding: JSONEncoder().encode(events.map(\.payload)), as: UTF8.self)
        #expect(!payloadJSON.contains("77"))
        #expect(events.allSatisfy { $0.payloadClassification == .localPrivate })
    }

    // MARK: BOD-10

    @Test("V15-T-BOD-10: deleting the body removes the avatar cache with it, and a new body continues above the old revision")
    func deleteCascades() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("body-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let vault = try Vault.open(directory: dir, keyStore: EphemeralKeyStore())
        let s = studio(store: VaultBodyStore { vault })
        _ = await s.createNeutral()
        _ = await s.commit(.slider(.waist, cm: 70))
        let lastRevision = try #require(await s.profile?.revision)
        #expect(await vault.contains("avatar-cache"))

        let receipt = try await s.deleteProfile().get()
        #expect(receipt.deletedCountsByType == ["body-profile": 1, "avatar-cache": 1])
        #expect(await vault.contains("body-profile") == false)
        #expect(await vault.contains("avatar-cache") == false)
        #expect(await s.profile == nil)
        #expect(await s.status == .noProfile)
        #expect(await s.canUndo == false)

        _ = await s.createNeutral()
        #expect(try #require(await s.profile?.revision) > lastRevision)

        var projection = BodyProjection()
        for e in await s.journal.events { projection.apply(e) }
        #expect(projection.isDeleted == false)
        #expect(projection.committedRevision == (await s.profile?.revision))
    }

    // MARK: ORC-07 / ORC-08

    @Test("V15-T-ORC-07: replaying events twice, shuffled, gives the same state; a deleted body is never resurrected")
    func replayIdempotent() async throws {
        let s = studio()
        _ = await s.createNeutral()
        _ = await s.commit(.slider(.waist, cm: 70))
        _ = await s.commit(.slider(.hip, cm: 100))
        _ = await s.deleteProfile()
        let events = await s.journal.events
        #expect(events.map(\.payload.kind) == [.committed, .committed, .committed, .deleted])

        var inOrder = BodyProjection()
        for e in events { inOrder.apply(e) }
        #expect(inOrder.isDeleted)
        #expect(inOrder.committedRevision == nil)

        var replayed = inOrder
        for e in events { #expect(replayed.apply(e) == false, "duplicate applied") }
        #expect(replayed == inOrder)

        var generator = SystemRandomNumberGenerator()
        for _ in 0..<20 {
            var shuffled = BodyProjection()
            for e in (events + events).shuffled(using: &generator) { shuffled.apply(e) }
            #expect(shuffled == inOrder, "a late commit must not undo the delete")
        }
    }

    @Test("V15-T-ORC-08: the store refuses a stale or mismatched revision at the persistence boundary")
    func staleRevisionRefused() async throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("body-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let vault = try Vault.open(directory: dir, keyStore: EphemeralKeyStore())
        let store = VaultBodyStore { vault }
        let v5 = BodyProfile(revision: 5, values: BodyProfile.neutral().values, preferredUnit: .centimeters)
        try await store.save(v5, snapshot: AvatarSnapshot.make(for: v5))
        let v4 = BodyProfile(revision: 4, values: v5.values, preferredUnit: .centimeters)
        await #expect(throws: FaultCode.staleRevision) { try await store.save(v4, snapshot: AvatarSnapshot.make(for: v4)) }
        await #expect(throws: FaultCode.staleRevision) { try await store.save(v5, snapshot: AvatarSnapshot.make(for: v5)) }
        let v6 = BodyProfile(revision: 6, values: v5.values, preferredUnit: .centimeters)
        await #expect(throws: FaultCode.staleRevision) { try await store.save(v6, snapshot: AvatarSnapshot.make(for: v5)) }
        #expect(try await store.load() == v5)
    }

    @Test("A commit that times out after its write lands does not lock later commits out")
    func lateWriteDoesNotWedge() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral()
        // Simulate a write that landed but whose run reported failure: the store moves ahead on its own.
        let ahead = BodyProfile(revision: try #require(await s.profile?.revision) + 1, values: BodyProfile.neutral().values, preferredUnit: .centimeters)
        try await store.save(ahead, snapshot: AvatarSnapshot.make(for: ahead))
        let blocked = await s.commit(.slider(.waist, cm: 75))
        #expect(blocked.fault == .moduleFailed)
        #expect(await s.profile == ahead, "after a failed write the studio re-reads the store instead of guessing")
        let retried = await s.commit(.slider(.waist, cm: 75))
        #expect(retried.value != nil, "the failed commit burned its revision; the retry goes above it")
    }

    // MARK: Concurrency

    @Test("V15-T-ORC-03: a newer drag supersedes an older preview; the older one never shows")
    func previewLatestWins() async throws {
        let started = Signal(), calls = Counter()
        let s = studio { snapshot, tier in
            if await calls.increment() == 2 { // call 1 is createNeutral
                await started.fire()
                try await Task.sleep(for: .seconds(10))
            }
            return PreviewScene.render(snapshot, maxTier: tier)
        }
        _ = await s.createNeutral()
        let base = try #require(await s.profile)
        let first = Task { await s.preview(.slider(.waist, cm: 140)) }
        await started.wait()
        let second = try #require(await s.preview(.slider(.waist, cm: 60))?.value)
        #expect(await first.value == nil)
        let expected = PreviewScene.render(try AvatarSnapshot.make(for: base.applying(.slider(.waist, cm: 60))), maxTier: .genericMesh)
        #expect(second.rightOutline == expected.rightOutline)
        #expect(await s.profile == base, "previews never commit")
    }

    @Test("V15-T-ORC-04: leaving the screen cancels a preview but never a save in progress")
    func commitSurvivesCancellation() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral()
        let task = Task { await s.commit(.slider(.waist, cm: 88)) }
        task.cancel()
        #expect(await task.value.value != nil)
        #expect(try await store.load()?.cm(.waist) == 88)

        let preview = Task { await s.preview(.slider(.waist, cm: 100)) }
        preview.cancel()
        _ = await preview.value
        #expect(try await store.load()?.cm(.waist) == 88)
    }

    @Test("Concurrent commits are serialized: every one lands, revisions strictly increase, no lost update")
    func serializedCommits() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral()
        let edits: [BodyEdit] = [.slider(.waist, cm: 70), .slider(.hip, cm: 100), .slider(.chest, cm: 99),
                                 .slider(.height, cm: 175), .slider(.shoulderWidth, cm: 44)]
        await withTaskGroup(of: Void.self) { group in
            for e in edits { group.addTask { _ = await s.commit(e) } }
        }
        let final = try #require(await s.profile)
        for e in edits { #expect(final[e.parameter].length == e.length) }
        #expect(await store.saveCount == 6)
        let revisions = await s.journal.events.map(\.revision)
        #expect(revisions == revisions.sorted() && Set(revisions).count == revisions.count)
    }

    @Test("Close refuses commits queued after it; load clears undo so a reload can never restore old values")
    func closeAndReload() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.createNeutral()
        _ = await s.commit(.slider(.waist, cm: 70))
        #expect(await s.canUndo)
        #expect(await s.load() == .ready)
        #expect(await s.canUndo == false, "a reload alone must clear undo")
        _ = await s.commit(.slider(.waist, cm: 70.5))
        _ = await s.commit(.slider(.waist, cm: 70))
        #expect(await s.canUndo)
        await s.close()
        #expect(await s.commit(.slider(.waist, cm: 90)).fault == .storageCorrupted)
        #expect(await s.undo() == nil)
        #expect(try await store.load()?.cm(.waist) == 70)
        #expect(await s.load() == .ready)
        #expect(await s.canUndo == false)
        #expect(await s.commit(.slider(.waist, cm: 90)).value != nil)
    }

    @Test("Review P1-2: the avatar cache is as sensitive as the profile, because the geometry gives the values back")
    func avatarCacheIsSensitive() throws {
        #expect(VaultBodyStore.avatarSpec.classification == .localSensitive)
        #expect(VaultBodyStore.profileSpec.classification == .localSensitive)
        let profile = try BodyProfile.neutral().applying(.measured(.shoulderWidth, 44, .centimeters))
        let snapshot = try AvatarSnapshot.make(for: profile)
        let recovered = try #require(snapshot.silhouette.halfWidthsCm[.shoulder]) * 2
        #expect(abs(recovered - 44) < 0.001, "recoverable: so it must never be treated as anonymous geometry")
    }

    @Test("Review P2: a second create never resets an existing body")
    func createOnlyFromEmpty() async throws {
        let s = studio()
        _ = await s.createNeutral()
        _ = await s.commit(.slider(.waist, cm: 70))
        #expect(await s.createNeutral().value == nil)
        #expect(await s.profile?.cm(.waist) == 70)
    }

    @Test("Review P2: deleting the body cancels a preview in flight, so it cannot repaint the deleted shape")
    func deleteCancelsPreview() async throws {
        let started = Signal(), calls = Counter()
        let s = studio { snapshot, tier in
            if await calls.increment() == 2 {
                await started.fire()
                try await Task.sleep(for: .seconds(10))
            }
            return PreviewScene.render(snapshot, maxTier: tier)
        }
        _ = await s.createNeutral()
        let preview = Task { await s.preview(.slider(.waist, cm: 120)) }
        await started.wait()
        _ = await s.deleteProfile()
        #expect(await preview.value == nil)
        #expect(await s.profile == nil)
    }

    @Test("The committed scene is drawn through the coordinator, so the budget picks the detail (BOD-08)")
    func currentSceneHonoursBudget() async throws {
        let s = studio(governor: BudgetGovernor(budget: .defaults(for: .survival)))
        #expect(await s.currentScene() == nil)
        _ = await s.createNeutral()
        let scene = try #require(await s.currentScene()?.value)
        #expect(scene.rightOutline.count == Silhouette.Station.allCases.count)
    }

    // MARK: Unreadable store

    @Test("An unreadable stored body is never overwritten; only delete is allowed")
    func unreadableIsReadOnly() async throws {
        let store = MemoryBodyStore()
        await store.setFailLoad(true)
        let s = studio(store: store)
        #expect(await s.load() == .unreadable)
        #expect(await s.createNeutral().fault == .storageCorrupted)
        #expect(await s.commit(.slider(.waist, cm: 70)).fault == .storageCorrupted)
        #expect(await store.saveCount == 0)
        #expect((try? await s.deleteProfile().get()) != nil)
        #expect(await s.status == .noProfile)
    }
}
