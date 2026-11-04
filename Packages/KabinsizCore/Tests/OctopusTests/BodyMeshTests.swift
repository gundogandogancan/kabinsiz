@testable import BodyGeometry
import DomainContracts
import Foundation
@testable import Octopus
import Testing

@Suite("Neutral 3D body mesh (ADR-007, WP15-07/08)")
struct BodyMeshTests {
    func mesh(_ edits: [(BodyParameter, Double)] = [], detail: BodyMesh.Detail = .standard) throws -> (BodyProfile, BodyMesh) {
        var profile = BodyProfile.neutral()
        for (p, cm) in edits { profile = try profile.applying(.slider(p, cm: cm)) }
        return (profile, try BodyMesh.make(from: AvatarSnapshot.make(for: profile), detail: detail))
    }

    @Test("Neutral body: five closed, outward, finite pieces; height exact; mirror symmetric")
    func neutralIsValid() throws {
        let (profile, m) = try mesh()
        try m.validate()
        #expect(Set(m.pieces.map(\.part)) == Set(BodyMesh.Part.procedural))
        #expect(abs(Double(m.heightM) - profile.cm(.height) / 100) < 1e-6)
        let ys = m.pieces.flatMap(\.positions).map(\.y)
        #expect(abs(Double(ys.max()!) - profile.cm(.height) / 100) < 1e-4)
        #expect(ys.min()! >= -1e-6 && ys.min()! < 0.001)
        // Mirror: every left-side vertex has a right-side twin.
        for (l, r) in [(BodyMesh.Part.leftLeg, BodyMesh.Part.rightLeg), (.leftArm, .rightArm)] {
            let left = try #require(m.piece(l)), right = try #require(m.piece(r))
            #expect(zip(left.positions, right.positions).allSatisfy { abs($0.x + $1.x) < 1e-6 && $0.y == $1.y && $0.z == $1.z })
            #expect(right.positions.allSatisfy { $0.x > 0 })
        }
        let torso = try #require(m.piece(.torso))
        let xs = Set(torso.positions.map { ($0.x * 1e5).rounded() / 1e5 })
        #expect(xs.allSatisfy { xs.contains(($0 == 0 ? 0 : -$0)) })
    }

    @Test("ADR-007 §3: the torso's front half-width and the legs' outer edge equal the 2D silhouette")
    func matchesSilhouette() throws {
        let (profile, m) = try mesh([(.waist, 95), (.hip, 110)])
        let shape = try AvatarSnapshot.make(for: profile).silhouette
        let torso = try #require(m.piece(.torso))
        let h = shape.heightCm
        for station in [Silhouette.Station.headWidest, .neck, .shoulder, .chest, .waist, .hip] {
            let y = Float((h - station.heightFraction * h) / 100)
            let ring = torso.positions.filter { abs($0.y - y) < 1e-5 }
            #expect(!ring.isEmpty, "a ring sits on \(station)")
            let maxX = Double(ring.map(\.x).max() ?? 0) * 100
            #expect(abs(maxX - shape.halfWidthsCm[station]!) < 0.01, "\(station)")
        }
        let leg = try #require(m.piece(.rightLeg))
        for station in [Silhouette.Station.thigh, .knee, .ankle] {
            let y = Float((h - station.heightFraction * h) / 100)
            let ring = leg.positions.filter { abs($0.y - y) < 1e-5 }
            #expect(abs(Double(ring.map(\.x).max() ?? 0) * 100 - shape.halfWidthsCm[station]!) < 0.01, "\(station)")
        }
    }

    @Test("Girth depth comes from the circumference: the torso ellipse has the measured girth (Ramanujan)")
    func girthMatches() throws {
        let (profile, m) = try mesh([(.waist, 90)])
        let shape = try AvatarSnapshot.make(for: profile).silhouette
        let torso = try #require(m.piece(.torso))
        let y = Float((shape.heightCm * (1 - Silhouette.Station.waist.heightFraction)) / 100)
        let ring = torso.positions.filter { abs($0.y - y) < 1e-5 }
        let a = Double(ring.map(\.x).max()!) * 100, b = Double(ring.map(\.z).max()!) * 100
        let perimeter = Double.pi * (3 * (a + b) - ((3 * a + b) * (a + 3 * b)).squareRoot())
        #expect(abs(perimeter - 90) < 0.05)
        #expect(BodyMesh.girthDepthRatio > 0.5 && BodyMesh.girthDepthRatio < 0.8)
    }

    @Test("V19-T-023 / BOD-02 in 3D: 243 extreme combinations are a valid mesh or refused before drawing")
    func extremeCombinations() throws {
        var built = 0, refused = 0
        for height in [120.0, 170, 220] {
            for shoulder in [30.0, 45, 60] {
                for chest in [60.0, 100, 160] {
                    for waist in [50.0, 90, 150] {
                        for hip in [60.0, 100, 160] {
                            var profile = BodyProfile.neutral()
                            do {
                                for (p, v) in [(BodyParameter.height, height), (.shoulderWidth, shoulder), (.chest, chest), (.waist, waist), (.hip, hip)] {
                                    profile = try profile.applying(.slider(p, cm: v))
                                }
                            } catch {
                                refused += 1
                                continue
                            }
                            let m = try BodyMesh.make(from: AvatarSnapshot.make(for: profile))
                            try m.validate()
                            try armsClearTorso(m, profile)
                            built += 1
                        }
                    }
                }
            }
        }
        #expect(built + refused == 243)
        #expect(built > 200)
    }

    func armsClearTorso(_ m: BodyMesh, _ profile: BodyProfile) throws {
        let shape = try AvatarSnapshot.make(for: profile).silhouette
        let arm = try #require(m.piece(.rightArm))
        let h = shape.heightCm
        // From the elbow down (the upper arm may rest on the chest), no arm vertex sits inside the torso outline.
        let elbowFromCrown = 0.195 + BodyMesh.elbowFraction * BodyMesh.armLengthFraction
        for v in arm.positions where Double(v.y) * 100 < h * (1 - elbowFromCrown) {
            let fromCrown = h - Double(v.y) * 100
            let torsoHalf = BodyMesh.halfWidth(shape, atDepthFromCrown: fromCrown)
            #expect(Double(v.x) * 100 > torsoHalf, "arm enters torso at \(Int(fromCrown)) cm from crown")
        }
    }

    @Test("Deterministic: the same snapshot gives byte-identical geometry; detail only changes resolution")
    func deterministic() throws {
        let (_, a) = try mesh([(.chest, 101)])
        let (_, b) = try mesh([(.chest, 101)])
        #expect(a == b)
        let (_, low) = try mesh([(.chest, 101)], detail: .low)
        try low.validate()
        #expect(low.triangleCount < a.triangleCount)
        #expect(a.triangleCount < 40_000)
    }

    @Test("A body edit changes the mesh where it should and only there")
    func localEdit() throws {
        let (base, a) = try mesh()
        let (_, b) = try mesh([(.waist, base.cm(.waist) + 12)])
        let ta = try #require(a.piece(.torso)), tb = try #require(b.piece(.torso))
        let h = Float(base.cm(.height) / 100)
        // The crown and head do not move; the waist ring grows.
        let head = { (p: BodyMesh.Piece) in p.positions.filter { $0.y > h * 0.9 } }
        #expect(head(ta) == head(tb))
        let waistY = h * Float(1 - Silhouette.Station.waist.heightFraction)
        let wa = ta.positions.filter { abs($0.y - waistY) < 1e-5 }.map(\.x).max()!
        let wb = tb.positions.filter { abs($0.y - waistY) < 1e-5 }.map(\.x).max()!
        #expect(wb > wa)
    }

    @Test("V19-T-024: the shoulder slider leaves the hips and legs untouched")
    func shoulderDoesNotDeformHips() throws {
        let (base, a) = try mesh()
        let (_, b) = try mesh([(.shoulderWidth, base.cm(.shoulderWidth) + 6)])
        let h = Float(base.cm(.height) / 100)
        let lower = { (m: BodyMesh, part: BodyMesh.Part) in try #require(m.piece(part)).positions.filter { $0.y < h * 0.5 } }
        #expect(try lower(a, .torso) == lower(b, .torso))
        #expect(try lower(a, .rightLeg) == lower(b, .rightLeg))
        // ...while the shoulder ring itself widens.
        let shoulderY = h * Float(1 - Silhouette.Station.shoulder.heightFraction)
        let width = { (m: BodyMesh) in try #require(m.piece(.torso)).positions.filter { abs($0.y - shoulderY) < 1e-5 }.map(\.x).max()! }
        #expect(try width(b) > width(a))
    }

    @Test("R17-FIT-05 / V19-T-023: across the whole waist slider the waist girth grows monotonically, end to end")
    func waistMonotonic() throws {
        let range = BodyProfile.neutral().allowedRange(.waist)
        var previous = 0.0
        var cm = range.lowerBound
        while cm <= range.upperBound {
            let (profile, m) = try mesh([(.waist, cm)])
            let y = Float((profile.cm(.height) * (1 - Silhouette.Station.waist.heightFraction)) / 100)
            let ring = try #require(m.piece(.torso)).positions.filter { abs($0.y - y) < 1e-5 }
            let a = Double(ring.map(\.x).max()!) * 100, b = Double(ring.map(\.z).max()!) * 100
            let girth = Double.pi * (3 * (a + b) - ((3 * a + b) * (a + 3 * b)).squareRoot())
            #expect(abs(girth - cm) < 0.1, "girth equals the slider value at \(cm) cm")
            #expect(girth > previous)
            previous = girth
            cm += 2.5
        }
    }

    @Test("Structural only: five generic parts, no face, hair or anatomy; the mesh carries no measurement labels")
    func structuralOnly() throws {
        let (_, m) = try mesh()
        #expect(Set(m.pieces.map(\.part)) == [.torso, .leftLeg, .rightLeg, .leftArm, .rightArm])
        let json = String(decoding: try JSONEncoder().encode(m), as: UTF8.self)
        for word in ["face", "eye", "hair", "nose", "mouth", "SLIDER", "MEASURED", "NEUTRAL_START", "chest", "waist"] {
            #expect(!json.contains(word), "\(word)")
        }
    }

    @Test("Validation catches a hole, a flipped piece and a NaN")
    func validationCatches() throws {
        let (_, m) = try mesh()
        let torso = try #require(m.piece(.torso))
        func with(_ piece: BodyMesh.Piece) -> BodyMesh {
            BodyMesh(bodyRevision: m.bodyRevision, heightM: m.heightM, pieces: m.pieces.map { $0.part == piece.part ? piece : $0 })
        }
        let holed = BodyMesh.Piece(part: .torso, positions: torso.positions, normals: torso.normals, indices: Array(torso.indices.dropLast(3)))
        #expect(throws: BodyEditError.unsafeGeometry("mesh-open")) { try with(holed).validate() }
        var flipped: [UInt32] = []
        for t in stride(from: 0, to: torso.indices.count, by: 3) { flipped += [torso.indices[t], torso.indices[t + 2], torso.indices[t + 1]] }
        #expect(throws: BodyEditError.unsafeGeometry("mesh-inside-out")) {
            try with(BodyMesh.Piece(part: .torso, positions: torso.positions, normals: torso.normals, indices: flipped)).validate()
        }
        var bad = torso.positions
        bad[3].x = .nan
        #expect(throws: BodyEditError.unsafeGeometry("mesh-nan")) {
            try with(BodyMesh.Piece(part: .torso, positions: bad, normals: torso.normals, indices: torso.indices)).validate()
        }
    }

    @Test("The studio draws the mesh only when the device budget allows 3D; 2D_CARD keeps the outline (G0)")
    func budgetPicksMesh() async throws {
        let s = studio(governor: BudgetGovernor(budget: .defaults(for: .balanced)))
        let scene = try #require(await s.createNeutral().value)
        #expect(scene.tier == .genericMesh)
        let mesh = try #require(scene.mesh)
        #expect(mesh.bodyRevision == scene.bodyRevision)
        #expect(!scene.rightOutline.isEmpty)

        let hot = studio(governor: DeviceResourceGovernor(signals: DeviceSignals(thermal: .critical)))
        let flat = try #require(await hot.createNeutral().value)
        #expect(flat.tier == .flat2D)
        #expect(flat.mesh == nil)
        #expect(!flat.rightOutline.isEmpty)
    }

    @Test("Normals point outward: away from each piece's own axis")
    func normalsOutward() throws {
        let (_, m) = try mesh()
        let leg = try #require(m.piece(.rightLeg))
        let torso = try #require(m.piece(.torso))
        let mid = torso.positions.indices.filter { torso.positions[$0].y < m.heightM * 0.75 && torso.positions[$0].y > m.heightM * 0.55 }
        #expect(mid.allSatisfy { i in
            let p = torso.positions[i], n = torso.normals[i]
            return p.x * n.x + p.z * n.z > 0
        })
        let legCentreX = (leg.positions.map(\.x).max()! + leg.positions.map(\.x).min()!) / 2
        let knee = leg.positions.indices.filter { abs(leg.positions[$0].y - m.heightM * 0.26) < 0.02 }
        #expect(knee.allSatisfy { i in
            let p = leg.positions[i], n = leg.normals[i]
            return (p.x - legCentreX) * n.x + p.z * n.z > -0.05
        })
    }
}
