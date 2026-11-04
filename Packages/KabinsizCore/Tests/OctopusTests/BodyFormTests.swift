@testable import BodyGeometry
import Foundation
import Testing

/// Body form (user decision 2026-11-04: "kadın erkeğe göre model değişmeli; bel, göğüs, omuz önemli").
/// The form is chosen by the user, changes the drawn proportions, and never overrides typed measurements.
@Suite("Body form: feminine, masculine, neutral")
struct BodyFormTests {
    func profile(_ form: BodyForm, _ edits: [(BodyParameter, Double)] = []) throws -> BodyProfile {
        var p = BodyProfile.neutral(form: form)
        for (k, cm) in edits { p = try p.applying(.measured(k, cm, .centimeters)) }
        return p
    }

    @Test("BFORM-T01: records without a form read as neutral; neutral writes the old format; a form round-trips")
    func coding() throws {
        let neutral = BodyProfile.neutral()
        let data = try JSONEncoder().encode(neutral)
        #expect(!String(decoding: data, as: UTF8.self).contains("form"), "neutral stays byte-compatible with pre-form records")
        #expect(try JSONDecoder().decode(BodyProfile.self, from: data).form == .neutral)
        let feminine = try profile(.feminine, [(.waist, 70)])
        let back = try JSONDecoder().decode(BodyProfile.self, from: JSONEncoder().encode(feminine))
        #expect(back == feminine)
        let shape = try Silhouette.make(for: feminine)
        #expect(try JSONDecoder().decode(Silhouette.self, from: JSONEncoder().encode(shape)).form == .feminine)
        // A stored silhouette from before forms (no key) decodes.
        let old = try JSONEncoder().encode(try Silhouette.make(for: neutral))
        #expect(try JSONDecoder().decode(Silhouette.self, from: old).form == .neutral)
    }

    @Test("BFORM-T02: changing the form keeps the user's own values and moves only the starting ones")
    func changeKeepsMeasurements() throws {
        let start = try profile(.neutral, [(.waist, 77), (.chest, 93)])
        let next = try start.withForm(.feminine)
        #expect(next.form == .feminine)
        #expect(next.revision == start.revision + 1)
        #expect(next.cm(.waist) == 77 && next[.waist].source == .userMeasured)
        #expect(next.cm(.chest) == 93 && next[.chest].source == .userMeasured)
        #expect(next.cm(.height) == BodyForm.feminine.startCm(.height) && next[.height].source == .neutralStart)
        #expect(next.cm(.hip) == BodyForm.feminine.startCm(.hip))
        #expect(try next.withForm(.feminine) == next, "same form is a no-op")
        #expect(next.measuredCentimeters == [.waist: 77, .chest: 93], "a form never becomes a measurement")
        #expect(!next.sameShape(as: try start.withForm(.masculine)))
    }

    @Test("BFORM-T03: a feminine bust comes forward at the chest; the back does not move")
    func bustProjects() throws {
        let edits: [(BodyParameter, Double)] = [(.height, 168), (.shoulderWidth, 40), (.chest, 94), (.waist, 74), (.hip, 100)]
        let fem = try BodyRig(Silhouette.make(for: profile(.feminine, edits)))
        let neu = try BodyRig(Silhouette.make(for: profile(.neutral, edits)))
        let i = fem.outlineIndex(atFraction: 0.268)
        #expect(fem.zShift[i] > 0.8, "bust projection \(fem.zShift[i]) cm")
        #expect(fem.zShift[i] + fem.depths[i] > neu.depths[i] + 1, "front of the bust stands further forward than a neutral chest")
        let plain = BodyMesh.depthProfile(fem.shape)
        for k in fem.outline.indices { #expect(abs((fem.zShift[k] - fem.depths[k]) + plain[k]) < 1e-9, "back unchanged at \(k)") }
        // Outside the chest window nothing moves: neck, waist and hips are as drawn.
        for f in [0.13, 0.39, 0.50] { #expect(fem.zShift[fem.outlineIndex(atFraction: f)] == 0) }
        // A bigger bust-to-waist difference projects further.
        let fuller = try BodyRig(Silhouette.make(for: profile(.feminine, [(.chest, 104), (.waist, 74)])))
        #expect(fuller.zShift[i] > fem.zShift[i])
    }

    @Test("BFORM-T04: same measurements, different form: neck, chest width and thighs differ as drawn")
    func proportionsDiffer() throws {
        let edits: [(BodyParameter, Double)] = [(.height, 172), (.shoulderWidth, 42), (.chest, 96), (.waist, 80), (.hip, 100)]
        let f = try Silhouette.make(for: profile(.feminine, edits)), m = try Silhouette.make(for: profile(.masculine, edits))
        #expect(f.halfWidthsCm[.neck]! < m.halfWidthsCm[.neck]!)
        #expect(f.halfWidthsCm[.chest]! < m.halfWidthsCm[.chest]!, "part of a bust girth is depth, not width")
        #expect(f.halfWidthsCm[.thigh]! > m.halfWidthsCm[.thigh]!)
        // Measured girths are the same on both: waist and hip widths come from the same numbers.
        #expect(f.halfWidthsCm[.waist] == m.halfWidthsCm[.waist] && f.halfWidthsCm[.hip] == m.halfWidthsCm[.hip])
    }

    @Test("BFORM-T05: every form × 243 extreme bodies: a valid closed mesh and every garment valid, or refused before drawing")
    func extremes() throws {
        for form in BodyForm.allCases {
            var built = 0
            for height in [120.0, 170, 220] {
                for shoulder in [30.0, 45, 60] {
                    for chest in [60.0, 100, 160] {
                        for waist in [50.0, 90, 150] {
                            for hip in [60.0, 100, 160] {
                                var p = BodyProfile.neutral(form: form)
                                do {
                                    for (k, v) in [(BodyParameter.height, height), (.shoulderWidth, shoulder), (.chest, chest), (.waist, waist), (.hip, hip)] {
                                        p = try p.applying(.slider(k, cm: v))
                                    }
                                } catch { continue }
                                let snap = try AvatarSnapshot.make(for: p)
                                try BodyMesh.make(from: snap, detail: .low).validate()
                                for g in GarmentForm.allCases {
                                    #expect((try? GarmentMesh.make(g, on: snap, detail: .low)) != nil, "\(form) \(g) h\(height) c\(chest) w\(waist)")
                                }
                                built += 1
                            }
                        }
                    }
                }
            }
            #expect(built > 200, "\(form): \(built)")
        }
    }

    @Test("BFORM-T06: on a feminine body every top stands outside the skin, bust included")
    func topsClearBust() throws {
        let snap = try AvatarSnapshot.make(for: profile(.feminine, [(.chest, 104), (.waist, 72)]))
        let rig = try BodyRig(snap.silhouette)
        let crotchY = rig.h - rig.outline[rig.crotchIndex].y
        for g in [GarmentForm.tee, .longSleeveTee, .shirt, .knit, .jacket, .coat] {
            let shell = try #require(try GarmentMesh.make(g, on: snap).pieces.first)
            var checked = 0
            for v in shell.positions {
                let y = Double(v.y) * 100
                guard y > crotchY, let r = rig.torsoRings.first(where: { abs($0.center.y - y) < 1e-6 }) else { continue }
                let x = Double(v.x) * 100, z = Double(v.z) * 100 - r.center.z
                #expect((x / r.a) * (x / r.a) + (z / r.b) * (z / r.b) >= 1.02, "\(g) inside the bust at y \(y)")
                checked += 1
            }
            #expect(checked >= 150, "\(g): \(checked)")
        }
    }
}
