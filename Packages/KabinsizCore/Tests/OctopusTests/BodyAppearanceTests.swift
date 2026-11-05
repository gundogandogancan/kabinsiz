@testable import BodyGeometry
import Foundation
@testable import Octopus
import SystemContracts
import Testing

/// ADR-011: an optional body template (neutral / female / male) and an optional weight. Both shape
/// the picture only; neither is ever inferred, required, or used as a measurement.
@Suite("Body template and weight (ADR-011)")
struct BodyAppearanceTests {
    @Test("A new body is neutral with no weight, and stores exactly what it stored before ADR-011")
    func neutralByDefault() throws {
        let p = BodyProfile.neutral()
        #expect(p.template == .neutral && p.weightKg == nil)
        let keys = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(p)) as? [String: Any]).keys
        #expect(Set(keys) == ["revision", "values", "preferredUnit"])
        // A record written before ADR-011 reads back as neutral, without weight.
        let old = Data(#"{"revision":3,"values":["HEIGHT",{"length":{"tenthsOfMillimeter":17000},"source":"NEUTRAL_START"}],"preferredUnit":"CM"}"#.utf8)
        let decoded = try JSONDecoder().decode(BodyProfile.self, from: old)
        #expect(decoded.template == .neutral && decoded.weightKg == nil)
        // Snapshots too.
        let snapshotKeys = try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(AvatarSnapshot.make(for: p))) as? [String: Any]).keys
        #expect(Set(snapshotKeys) == ["bodyRevision", "silhouette"])
    }

    @Test("Picking a template redraws only the starting values; shaped and typed values never move")
    func templateKeepsUserValues() throws {
        let p = try BodyProfile.neutral()
            .applying(.slider(.waist, cm: 90))
            .applying(.measured(.hip, 104, .centimeters))
        let f = try p.withAppearance(template: .female, weightKg: nil)
        #expect(f.template == .female && f.revision == p.revision + 1)
        #expect(f[.waist] == p[.waist] && f[.hip] == p[.hip])
        #expect(f[.height] == p[.height])
        #expect(f.cm(.chest) == BodyTemplate.female.startCm(.chest) && f[.chest].source == .neutralStart)
        #expect(f.cm(.shoulderWidth) == BodyTemplate.female.startCm(.shoulderWidth))
        // And back: the neutral starting values return.
        let n = try f.withAppearance(template: .neutral, weightKg: nil)
        #expect(n.cm(.chest) == BodyParameter.chest.neutralStartCm && n[.waist] == p[.waist])
    }

    @Test("A weight draws shoulders, chest, waist and hip as estimates; height stays; size advice never sees them")
    func weightIsAnEstimateOnly() throws {
        let p = try BodyProfile.neutral().applying(.measured(.waist, 80, .centimeters))
        let w = try p.withAppearance(template: .neutral, weightKg: 72.36)
        #expect(w.weightKg == 72.4) // one decimal
        #expect(w[.waist] == p[.waist]) // typed: untouched
        for g in [BodyParameter.shoulderWidth, .chest, .hip] { #expect(w[g].source == .weightEstimate) }
        #expect(w[.height] == p[.height])
        #expect(w.measuredCentimeters == [.waist: 80])
        // Estimates are the app's drawing: an edit can never claim that source.
        #expect(throws: BodyEditError.neutralIsNotAMeasurement) {
            try w.applying(BodyEdit(.chest, BodyLength(100, .centimeters), source: .weightEstimate))
        }
    }

    @Test("Heavier draws fuller; the same weight on a taller body draws slimmer; estimates stay in range", arguments: BodyTemplate.allCases)
    func estimateIsMonotone(_ t: BodyTemplate) throws {
        func body(_ h: Double, _ kg: Double) throws -> BodyProfile {
            try BodyProfile.neutral().applying(.slider(.height, cm: h)).withAppearance(template: t, weightKg: kg)
        }
        var lastWaist = 0.0
        for kg in stride(from: 40.0, through: 160, by: 10) {
            let p = try body(170, kg)
            #expect(p.cm(.waist) >= lastWaist)
            lastWaist = p.cm(.waist)
            for g in BodyParameter.girths { #expect(p.allowedRange(g).contains(p.cm(g))) }
            _ = try #require(BodyMesh.best(from: AvatarSnapshot.make(for: p)))
        }
        let short = try body(155, 70), tall = try body(190, 70)
        #expect(tall.cm(.waist) / 190 < short.cm(.waist) / 155)
    }

    @Test("Estimates look like people, not caricatures (plausibility band, not a norm)")
    func estimateIsPlausible() throws {
        // Broad bands: the estimate is a drawing start and is labelled as one.
        let cases: [(BodyTemplate, Double, Double, ClosedRange<Double>)] = [
            (.neutral, 170, 70, 75...100), (.female, 165, 60, 65...90), (.male, 180, 80, 78...100),
        ]
        for (t, h, kg, band) in cases {
            let w = try #require(BodyShapeEstimate.cm(template: t, heightCm: h, weightKg: kg)?[.waist])
            #expect(band.contains(w), "\(t) \(h) cm \(kg) kg → waist \(w)")
        }
    }

    @Test("A new height moves the weight estimate with it; clearing the weight returns the starting values")
    func heightAndClear() throws {
        let p = try BodyProfile.neutral().withAppearance(template: .male, weightKg: 85)
        let taller = try p.applying(.slider(.height, cm: 190))
        #expect(taller[.waist].source == .weightEstimate && taller.cm(.waist) != p.cm(.waist))
        let cleared = try taller.withAppearance(template: .male, weightKg: nil)
        #expect(cleared.weightKg == nil)
        for g in [BodyParameter.shoulderWidth] + BodyParameter.girths {
            #expect(cleared[g].source == .neutralStart && cleared.cm(g) == BodyTemplate.male.startCm(g))
        }
    }

    @Test("Out-of-range or non-finite weights are refused and nothing changes")
    func weightGuard() throws {
        let p = BodyProfile.neutral()
        for kg in [29.9, 250.1, .nan, .infinity, -70] {
            #expect(throws: BodyEditError.weightOutOfRange) { try p.withAppearance(template: .female, weightKg: kg) }
        }
    }

    @Test("Undo restores the template and weight exactly")
    func undoRestoresAppearance() throws {
        var history = BodyEditHistory()
        let a = BodyProfile.neutral()
        let b = try a.withAppearance(template: .female, weightKg: 58)
        history.recordCommit(previous: a)
        let undoResult = history.undo(from: b)
        let undone = try #require(undoResult)
        #expect(undone.sameShape(as: a) && undone.template == .neutral && undone.weightKg == nil)
        let redoResult = history.redo(from: undone)
        let redone = try #require(redoResult)
        #expect(redone.sameShape(as: b) && redone.template == .female && redone.weightKg == 58)
    }

    @Test("The studio commits a template change as one undoable, saved revision")
    func studioCommitsAppearance() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.load()
        _ = await s.createNeutral()
        let result = try #require(await s.setAppearance(template: .female, weightKg: 62))
        #expect(result.value != nil)
        let saved = try #require(try await store.load())
        #expect(saved.template == .female && saved.weightKg == 62)
        #expect(await s.setAppearance(template: .female, weightKg: 62) == nil) // no change, no commit
        _ = await s.undo()
        let back = try #require(await s.profile)
        #expect(back.template == .neutral && back.weightKg == nil)
    }

    @Test("The ANSUR II fit: outside the fitted range there is no estimate, inside it is close to the survey's own means")
    func estimateRange() throws {
        #expect(BodyShapeEstimate.cm(template: .female, heightCm: 139, weightKg: 60) == nil)
        #expect(BodyShapeEstimate.cm(template: .male, heightCm: 180, weightKg: 161) == nil)
        // ANSUR II means (2012): women 162.9 cm / 67.8 kg, waist 84.9; men 175.6 cm / 85.5 kg, waist 94.1.
        let f = try #require(BodyShapeEstimate.cm(template: .female, heightCm: 162.9, weightKg: 67.8))
        let m = try #require(BodyShapeEstimate.cm(template: .male, heightCm: 175.6, weightKg: 85.5))
        #expect(abs(f[.waist]! - 84.9) < 2.5 && abs(m[.waist]! - 94.1) < 2.5)
        // Neutral lies between the two.
        let n = try #require(BodyShapeEstimate.cm(template: .neutral, heightCm: 170, weightKg: 70))
        let f2 = try #require(BodyShapeEstimate.cm(template: .female, heightCm: 170, weightKg: 70))
        let m2 = try #require(BodyShapeEstimate.cm(template: .male, heightCm: 170, weightKg: 70))
        for g in n.keys { #expect(min(f2[g]!, m2[g]!) <= n[g]! && n[g]! <= max(f2[g]!, m2[g]!)) }
    }

    @Test("The start form: gender, height and weight are each optional; nothing given is the neutral body")
    func startForm() throws {
        let plain = try BodyProfile.start()
        #expect(plain.sameShape(as: BodyProfile.neutral()) && plain.template == .neutral && plain.weightKg == nil)
        let full = try BodyProfile.start(unit: .centimeters, template: .female, height: 165, weightKg: 60)
        #expect(full.template == .female && full.weightKg == 60)
        #expect(full[.height].source == .userMeasured && full.cm(.height) == 165)
        #expect(full[.waist].source == .weightEstimate)
        #expect(full.measuredCentimeters == [.height: 165]) // only the typed height is a measurement
        let onlyGender = try BodyProfile.start(template: .male)
        #expect(onlyGender.cm(.chest) == BodyTemplate.male.startCm(.chest) && onlyGender.measuredCentimeters.isEmpty)
        let inches = try BodyProfile.start(unit: .inches, height: 70)
        #expect(abs(inches.cm(.height) - 177.8) < 0.6 && inches.preferredUnit == .inches)
        #expect(throws: BodyEditError.weightOutOfRange) { try BodyProfile.start(weightKg: 20) }
        #expect(throws: (any Error).self) { try BodyProfile.start(height: 20) }
    }

    @Test("The studio creates a body from the start form once, and saves it")
    func studioCreatesFromStart() async throws {
        let store = MemoryBodyStore()
        let s = studio(store: store)
        _ = await s.load()
        let start = try BodyProfile.start(template: .female, height: 160, weightKg: 55)
        _ = await s.create(start)
        let saved = try #require(try await store.load())
        #expect(saved.template == .female && saved.weightKg == 55 && saved.cm(.height) == 160)
        // A second create does nothing: the body already exists.
        _ = await s.create(try BodyProfile.start(template: .male))
        #expect(try await store.load()?.template == .female)
    }
}
