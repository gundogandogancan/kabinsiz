import BodyGeometry
import Foundation
@testable import GarmentPattern
import Testing

/// V37-04: sewing-pattern blocks from body measurements and patterns from a garment's own measurements.
@Suite("Pattern drafting: body blocks and garment measurements")
struct PatternDrafterTests {
    func profile(_ form: BodyForm = .neutral, _ edits: [(BodyParameter, Double)] = []) throws -> BodyProfile {
        var p = BodyProfile.neutral(form: form)
        for (k, cm) in edits { p = try p.applying(.measured(k, cm, .centimeters)) }
        return p
    }

    var bodies: [BodyProfile] {
        get throws {
            [try profile(), try profile(.feminine), try profile(.masculine),
             try profile(.neutral, [(.chest, 120), (.waist, 110), (.hip, 118)]),
             try profile(.feminine, [(.height, 152), (.chest, 80), (.waist, 62), (.hip, 88), (.shoulderWidth, 34)])]
        }
    }

    @Test("PAT-T01: bodice block — 2 × (front + back) at the underarm equals chest + ease within 1 cm")
    func bodiceWidths() throws {
        for body in try bodies {
            for kind in [GarmentKind.top, .longSleeveTop, .coat, .dress] {
                let ease = PatternEase.standard(for: kind)
                let pattern = try PatternDrafter.block(for: body, kind: kind)
                let front = try #require(pattern.piece(.front)), back = try #require(pattern.piece(.back))
                let ua = try #require(front.notch("underarm"))
                let total = 2 * (front.width(atY: ua.y) + back.width(atY: ua.y))
                let expected = body[.chest].length.centimeters + ease.chestCm
                #expect(abs(total - expected) < 1, "\(kind): \(total) vs \(expected)")
                #expect(pattern.source == .bodyBlock && pattern.ease == ease)
                #expect(front.mirror && back.mirror, "bodice halves are cut on the fold")
            }
        }
    }

    @Test("PAT-T02: trousers and skirt blocks — hip and waist girths equal body + ease within 1 cm")
    func bottomWidths() throws {
        for body in try bodies {
            for kind in [GarmentKind.trousers, .shorts, .skirt] {
                let e = PatternEase.standard(for: kind)
                let pattern = try PatternDrafter.block(for: body, kind: kind)
                let front = try #require(pattern.piece(.front)), back = try #require(pattern.piece(.back))
                let hipY = try #require(front.notch("hip")).y
                let hip = 2 * (front.width(atY: hipY) + back.width(atY: hipY))
                #expect(abs(hip - (body[.hip].length.centimeters + e.hipCm)) < 1, "\(kind) hip \(hip)")
                let fws = try #require(front.notch("waist-side")), bws = try #require(back.notch("waist-side"))
                let waist = 2 * (fws.x + bws.x)
                #expect(abs(waist - (body[.waist].length.centimeters + e.waistCm)) < 1, "\(kind) waist \(waist)")
            }
        }
    }

    @Test("PAT-T03: every piece of every kind is closed, simple, positive in area, y-monotone")
    func polygonsValid() throws {
        for body in try bodies {
            for kind in GarmentKind.allCases {
                let pattern = try PatternDrafter.block(for: body, kind: kind)
                #expect(pattern.pieces.count >= 2)
                for piece in pattern.pieces {
                    try piece.validate()
                    #expect(piece.areaCm2 > 100, "\(kind) \(piece.name)")
                    #expect(Polygon.isSimple(piece.outline), "\(kind) \(piece.name)")
                    #expect(Polygon.isSimple(piece.cuttingOutline), "\(kind) \(piece.name) cutting line")
                    #expect(Polygon.signedArea(piece.cuttingOutline) > piece.areaCm2, "seam allowance adds area")
                    // y-monotone: every interior row has one span, and its ends lie on the outline.
                    let b = piece.bounds
                    for k in 1..<40 {
                        let y = b.minY + b.height * Double(k) / 40
                        #expect(piece.span(atY: y) != nil, "\(kind) \(piece.name) row \(y)")
                    }
                    #expect(piece.grainline.end.y > piece.grainline.start.y)
                }
            }
        }
    }

    @Test("PAT-T04: a self-intersecting or empty outline is refused")
    func refusesBadPolygons() {
        let bow = [PatternPoint(x: 0, y: 0), PatternPoint(x: 10, y: 10), PatternPoint(x: 10, y: 0), PatternPoint(x: 0, y: 10)]
        let g = PatternPiece.Grainline(start: PatternPoint(x: 1, y: 1), end: PatternPoint(x: 1, y: 2))
        #expect(throws: PatternError.self) {
            try PatternPiece(name: "x", role: .front, outline: bow, grainline: g, notches: [], seamAllowanceCm: 1, cutCount: 1, mirror: false)
        }
        let line = [PatternPoint(x: 0, y: 0), PatternPoint(x: 5, y: 0), PatternPoint(x: 10, y: 0)]
        #expect(throws: PatternError.self) {
            try PatternPiece(name: "x", role: .front, outline: line, grainline: g, notches: [], seamAllowanceCm: 1, cutCount: 1, mirror: false)
        }
    }

    @Test("PAT-T05: a top from flat-lay measurements reproduces width, length and sleeve within 1 cm")
    func topFromMeasurements() throws {
        for (width, length, sleeve) in [(52.0, 70.0, 21.0), (46.0, 62.0, 18.0), (61.0, 76.0, 24.0)] {
            let m = GarmentMeasurements(kind: .top, bodyWidth: .init(width, .photoEstimated), length: .init(length, .userMeasured),
                                        sleeveLength: .init(sleeve, .userMeasured))
            let p = try PatternDrafter.pattern(from: m)
            let front = try #require(p.piece(.front)), back = try #require(p.piece(.back)), arm = try #require(p.piece(.sleeve))
            let ua = try #require(front.notch("underarm"))
            #expect(abs(try #require(p.flatWidth(atY: ua.y)) - width) < 1, "pit-to-pit")
            #expect(abs(front.bounds.height - length) < 1 && abs(back.bounds.height - length) < 1, "length")
            #expect(abs(arm.bounds.height - sleeve) < 1, "sleeve")
            #expect(p.source == .garmentMeasurements && p.ease == nil)
            #expect(p.provenance.contains("fotoğraftan tahmin") && p.provenance.contains("senin ölçün"))
        }
    }

    @Test("PAT-T06: trousers, skirt, dress from measurements keep their finished dimensions")
    func bottomsFromMeasurements() throws {
        let t = try PatternDrafter.pattern(from: GarmentMeasurements(
            kind: .trousers, bodyWidth: .init(50, .userMeasured), length: .init(102, .userMeasured), hemWidth: .init(19, .userMeasured),
            waistWidth: .init(41, .userMeasured), inseam: .init(76, .userMeasured)))
        let tf = try #require(t.piece(.front)), tb = try #require(t.piece(.back))
        let hipY = try #require(tf.notch("hip")).y
        #expect(abs(try #require(t.flatWidth(atY: hipY)) - 50) < 1, "hip flat width")
        let fw = try #require(tf.notch("waist-side")), bw = try #require(tb.notch("waist-side")), crotch = try #require(tf.notch("crotch-point"))
        #expect(abs(fw.x + bw.x - 41) < 1, "waist flat width")
        #expect(abs(tf.bounds.maxY - 102) < 1, "outseam")
        #expect(abs(tf.bounds.maxY - crotch.y - 76) < 1, "inseam")
        #expect(abs(tf.width(atY: tf.bounds.maxY) + tb.width(atY: tb.bounds.maxY) - 2 * 19) < 1, "leg opening = 2 × flat hem")

        let s = try PatternDrafter.pattern(from: GarmentMeasurements(kind: .skirt, bodyWidth: .init(50, .userMeasured), length: .init(60, .photoEstimated)))
        let sf = try #require(s.piece(.front))
        let sHip = try #require(sf.notch("hip"))
        #expect(abs(try #require(s.flatWidth(atY: sHip.y)) - 50) < 1)
        #expect(abs(sf.bounds.height - 60) < 1)
        #expect(s.provenance.contains("Türetildi"), "derived values are named")

        let d = try PatternDrafter.pattern(from: GarmentMeasurements(kind: .dress, bodyWidth: .init(47, .userMeasured), length: .init(95, .userMeasured),
                                                                     waistWidth: .init(39, .userMeasured)))
        let df = try #require(d.piece(.front))
        let dUnder = try #require(df.notch("underarm")), dWaist = try #require(df.notch("waist"))
        #expect(abs(try #require(d.flatWidth(atY: dUnder.y)) - 47) < 1)
        #expect(abs(try #require(d.flatWidth(atY: dWaist.y)) - 39) < 1)
        #expect(d.piece(.sleeve) == nil, "no sleeve length → sleeveless")
    }

    @Test("PAT-T07: impossible measurements fail loudly")
    func refusesBadMeasurements() {
        for m in [
            GarmentMeasurements(kind: .top, bodyWidth: .init(.nan, .userMeasured), length: .init(70, .userMeasured)),
            GarmentMeasurements(kind: .top, bodyWidth: .init(52, .userMeasured), length: .init(400, .userMeasured)),
            GarmentMeasurements(kind: .top, bodyWidth: .init(60, .userMeasured), length: .init(20, .userMeasured)),
            GarmentMeasurements(kind: .trousers, bodyWidth: .init(50, .userMeasured), length: .init(100, .userMeasured), inseam: .init(98, .userMeasured)),
        ] {
            #expect(throws: PatternError.self) { try PatternDrafter.pattern(from: m) }
        }
    }

    @Test("PAT-T08: a block from starting values says so (no made-to-measure claim)")
    func provenanceHonest() throws {
        let p = try PatternDrafter.block(for: BodyProfile.neutral(), kind: .top)
        #expect(p.provenance.contains("başlangıç (ölçü değil)"))
        #expect(p.provenance.contains("Marka kalıbı değildir"))
        let measured = try PatternDrafter.block(for: try profile(.neutral, [(.chest, 100)]), kind: .top)
        #expect(measured.provenance.contains("senin girdiğin ölçü"))
    }

    @Test("PAT-T09: drafting is deterministic")
    func deterministic() throws {
        for kind in GarmentKind.allCases {
            #expect(try PatternDrafter.block(for: profile(.feminine), kind: kind) == PatternDrafter.block(for: profile(.feminine), kind: kind))
        }
    }
}
