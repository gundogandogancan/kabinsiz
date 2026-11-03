import CoreGraphics
import Foundation
@testable import LiveMirror
import Testing

/// MIR-WP02: the garment drawing follows the pose; gates refuse frames and scenes that cannot be drawn honestly.
@Suite("Garment rig")
struct GarmentRigTests {
    // A torso 400×600 px with shoulders 300 px apart; sleeves 100×300; seat; shin; shoe.
    static let top = GarmentFormSpec(form: "coat", family: "top", pxPerMetre: 820, parts: [
        "torso": .init(size: [400, 600], a: [200, 40], b: [200, 460], refWidth: 300, files: ["fabric": "t"]),
        "upperSleeve": .init(size: [100, 300], a: [50, 20], b: [50, 260], refWidth: nil, files: ["fabric": "u"]),
        "lowerSleeve": .init(size: [100, 260], a: [50, 20], b: [50, 230], refWidth: nil, files: ["fabric": "l"]),
    ], thumb: nil)
    static let bottom = GarmentFormSpec(form: "jeans", family: "bottom", pxPerMetre: 820, parts: [
        "seat": .init(size: [300, 400], a: [150, 100], b: [150, 450], refWidth: 156, files: ["fabric": "s"]),
        "thigh": .init(size: [180, 400], a: [90, 50], b: [90, 400], refWidth: nil, files: ["fabric": "t"]),
        "shin": .init(size: [160, 400], a: [80, 40], b: [80, 380], refWidth: nil, files: ["fabric": "h"]),
    ], thumb: nil)
    static let shoe = GarmentFormSpec(form: "sneakers", family: "shoe", pxPerMetre: 820, parts: [
        "shoe": .init(size: [140, 150], a: [70, 40], b: [70, 130], refWidth: nil, files: ["fabric": "s"]),
    ], thumb: nil)

    static let standing = BodyPose2D(points: [
        .leftShoulder: CGPoint(x: 260, y: 300), .rightShoulder: CGPoint(x: 140, y: 300),
        .leftElbow: CGPoint(x: 275, y: 400), .rightElbow: CGPoint(x: 125, y: 400),
        .leftWrist: CGPoint(x: 285, y: 490), .rightWrist: CGPoint(x: 115, y: 490),
        .leftHip: CGPoint(x: 230, y: 470), .rightHip: CGPoint(x: 170, y: 470),
        .leftKnee: CGPoint(x: 235, y: 610), .rightKnee: CGPoint(x: 165, y: 610),
        .leftAnkle: CGPoint(x: 240, y: 750), .rightAnkle: CGPoint(x: 160, y: 750),
    ])

    func placements(_ form: GarmentFormSpec, _ pose: BodyPose2D) throws -> [PartPlacement] {
        guard case .placed(let parts) = GarmentRig.place(form, on: pose) else { throw RigError.notPlaced }
        return parts
    }

    enum RigError: Error { case notPlaced }

    func near(_ p: CGPoint, _ q: CGPoint, _ tol: CGFloat = 0.5) -> Bool { hypot(p.x - q.x, p.y - q.y) < tol }

    @Test("MIR-T01 torso axis lands on the shoulder and hip midpoints; width follows the shoulders")
    func torsoAxis() throws {
        let parts = try placements(Self.top, Self.standing)
        let torso = try #require(parts.first { $0.part == "torso" })
        #expect(near(CGPoint(x: 200, y: 40).applying(torso.transform), CGPoint(x: 200, y: 300)))
        #expect(near(CGPoint(x: 200, y: 460).applying(torso.transform), CGPoint(x: 200, y: 470)))
        // Shoulders 300 px apart in the image become 120 pt apart on screen.
        let l = CGPoint(x: 50, y: 40).applying(torso.transform), r = CGPoint(x: 350, y: 40).applying(torso.transform)
        #expect(abs(abs(r.x - l.x) - 120) < 0.5)
    }

    @Test("MIR-T02 a raised arm carries its sleeve: upper sleeve ends on the elbow, lower on the wrist")
    func raisedArm() throws {
        var pose = Self.standing
        pose.points[.leftElbow] = CGPoint(x: 360, y: 240)
        pose.points[.leftWrist] = CGPoint(x: 400, y: 150)
        let parts = try placements(Self.top, pose)
        let upper = try #require(parts.first { $0.part == "upperSleeve" && $0.side == .left })
        let lower = try #require(parts.first { $0.part == "lowerSleeve" && $0.side == .left })
        #expect(near(CGPoint(x: 50, y: 20).applying(upper.transform), CGPoint(x: 260, y: 300)))
        #expect(near(CGPoint(x: 50, y: 260).applying(upper.transform), CGPoint(x: 360, y: 240)))
        #expect(near(CGPoint(x: 50, y: 20).applying(lower.transform), CGPoint(x: 360, y: 240)))
        #expect(near(CGPoint(x: 50, y: 230).applying(lower.transform), CGPoint(x: 400, y: 150)))
        // Drawing order: upper sleeves behind the torso, forearms in front of it.
        #expect(parts.map(\.part).firstIndex(of: "upperSleeve")! < parts.map(\.part).firstIndex(of: "torso")!)
        #expect(parts.map(\.part).lastIndex(of: "lowerSleeve")! > parts.map(\.part).firstIndex(of: "torso")!)
    }

    @Test("MIR-T03 a garment whose joints are hidden is not drawn")
    func missingJoints() {
        var pose = Self.standing
        pose.points[.leftShoulder] = nil
        #expect(GarmentRig.place(Self.top, on: pose) == .missing([.leftShoulder]))
        pose = Self.standing
        pose.points[.leftAnkle] = nil
        pose.points[.rightAnkle] = nil
        #expect(GarmentRig.place(Self.shoe, on: pose) == .missing([.leftAnkle, .rightAnkle]))
    }

    @Test("MIR-T04 nobody, two people, hidden shoulders: each has its own state and note")
    func trackingStates() {
        #expect(MirrorTracking.decide(people: [], family: "top") == .noPerson)
        #expect(MirrorTracking.decide(people: [Self.standing, Self.standing], family: "top") == .severalPeople(2))
        var hidden = Self.standing
        hidden.points[.rightShoulder] = nil
        #expect(MirrorTracking.decide(people: [hidden], family: "top") == .partial([.rightShoulder]))
        #expect(MirrorTracking.decide(people: [hidden], family: "bottom") == .tracking(hidden))
        #expect(MirrorTracking.severalPeople(2).note?.contains("birden fazla") == true)
        #expect(MirrorTracking.tracking(Self.standing).note == nil)
        // A stray detection with only two joints is not a person.
        let stray = BodyPose2D(points: [.nose: .zero, .neck: CGPoint(x: 1, y: 1)])
        #expect(MirrorTracking.decide(people: [Self.standing, stray], family: "top") == .tracking(Self.standing))
    }

    @Test("MIR-T05 frames out of order or older than the limit are dropped")
    func frameGate() {
        var gate = FrameGate(maxAge: 0.25)
        let steps: [(UInt64, Double, Double, Bool)] = [
            (1, 10.0, 10.02, true), (1, 10.03, 10.05, false),   // repeat
            (3, 10.06, 10.08, true), (2, 10.05, 10.09, false),  // late arrival
            (4, 10.0, 10.40, false),                            // stale
            (5, 10.41, 10.42, true),
        ]
        for (seq, captured, now, expected) in steps {
            let admitted = gate.admit(sequence: seq, capturedAt: captured, now: now)
            #expect(admitted == expected, "frame \(seq)")
        }
        #expect(gate.dropped == 3)
    }

    @Test("MIR-T06 smoothing steadies jitter but follows a real move")
    func oneEuro() {
        var f = OneEuroFilter()
        var t = 0.0
        var last = 0.0
        for i in 0..<60 { t += 1.0 / 30; last = f(100 + (i % 2 == 0 ? 2 : -2), at: t) }
        #expect(abs(last - 100) < 1.2)    // ±2 px jitter mostly removed
        for _ in 0..<15 { t += 1.0 / 30; last = f(200, at: t) }
        #expect(last > 190)               // a 100 px move is followed within half a second
    }

    @Test("MIR-T07 hips out of frame: the torso continues downwards from the shoulder line")
    func hipsHidden() throws {
        var pose = Self.standing
        pose.points[.leftHip] = nil
        pose.points[.rightHip] = nil
        let torso = try #require(try placements(Self.top, pose).first { $0.part == "torso" })
        let hem = CGPoint(x: 200, y: 460).applying(torso.transform)
        #expect(hem.y > 300 + 120)        // below the shoulders by more than a shoulder width
        #expect(abs(hem.x - 200) < 1)
    }

    @Test("MIR-T08 the manifest is accepted only as our own drawings")
    func manifestProvenance() throws {
        let good = #"{"provenance":"OWNED_ORIGINAL","forms":{}}"#.data(using: .utf8)!
        let bad = #"{"provenance":"SCRAPED","forms":{}}"#.data(using: .utf8)!
        #expect(try GarmentSpriteManifest.decode(good).forms.isEmpty)
        #expect(throws: (any Error).self) { try GarmentSpriteManifest.decode(bad) }
    }

    @Test("MIR-T09 trousers: seat on the hips, thighs and shins on each leg")
    func bottoms() throws {
        let parts = try placements(Self.bottom, Self.standing)
        #expect(parts.filter { $0.part == "thigh" }.count == 2)
        #expect(parts.filter { $0.part == "shin" }.count == 2)
        let shin = try #require(parts.first { $0.part == "shin" && $0.side == .right })
        #expect(near(CGPoint(x: 80, y: 40).applying(shin.transform), CGPoint(x: 165, y: 610)))
        #expect(near(CGPoint(x: 80, y: 380).applying(shin.transform), CGPoint(x: 160, y: 750)))
        let seat = try #require(parts.first { $0.part == "seat" })
        #expect(near(CGPoint(x: 150, y: 100).applying(seat.transform), CGPoint(x: 200, y: 470)))
        #expect(parts.last?.part == "seat")
    }

    @Test("MIR-T10 shoes sit at both ankles; room light gain stays in bounds")
    func shoesAndLight() throws {
        let parts = try placements(Self.shoe, Self.standing)
        #expect(parts.count == 2)
        for p in parts {
            let ankle = p.side == .left ? CGPoint(x: 240, y: 750) : CGPoint(x: 160, y: 750)
            #expect(near(CGPoint(x: 70, y: 40).applying(p.transform), ankle))
        }
        #expect(FrameLight.gain(meanLuma: 0) == 0.62)
        #expect(FrameLight.gain(meanLuma: 1) == 1.08)
        #expect(FrameLight.gain(meanLuma: .nan) == 1)
    }
}
