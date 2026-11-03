@testable import BodyGeometry
import Foundation
import Testing

@Suite("Original 3D garments on the body (V25-03, tier T1)")
struct GarmentMeshTests {
    func snapshot(_ edits: [(BodyParameter, Double)] = []) throws -> AvatarSnapshot {
        var profile = BodyProfile.neutral()
        for (p, cm) in edits { profile = try profile.applying(.slider(p, cm: cm)) }
        return try AvatarSnapshot.make(for: profile)
    }

    @Test("Every form builds a valid, bounded surface on the neutral body, deterministically")
    func everyFormBuilds() throws {
        let snap = try snapshot()
        for form in GarmentForm.allCases {
            let g = try GarmentMesh.make(form, on: snap)
            try g.validate(heightM: Float(snap.silhouette.heightCm / 100))
            #expect(g.triangleCount < 14_000, "\(form)")
            #expect(g.bodyRevision == snap.bodyRevision)
            #expect(try GarmentMesh.make(form, on: snap) == g, "same body, same garment")
        }
    }

    /// Body torso ring at exactly this height (garment rings reuse the body's ring heights).
    func bodyRing(_ rig: BodyRig, y: Double) -> BodyMesh.Ring? {
        rig.torsoRings.first { abs($0.center.y - y) < 1e-6 }
    }

    @Test("Tops and outer layers stand outside the skin at every ring above the crotch")
    func topsOutsideSkin() throws {
        let snap = try snapshot([(.chest, 112), (.waist, 104)])
        let rig = try BodyRig(snap.silhouette)
        let crotchY = rig.h - rig.outline[rig.crotchIndex].y
        for form in [GarmentForm.tee, .longSleeveTee, .shirt, .knit, .jacket, .coat] {
            let shell = try #require(try GarmentMesh.make(form, on: snap).pieces.first)
            var checked = 0
            for v in shell.positions {
                let y = Double(v.y) * 100
                guard y > crotchY, let r = bodyRing(rig, y: y) else { continue }
                let x = Double(v.x) * 100, z = Double(v.z) * 100
                #expect((x / r.a) * (x / r.a) + (z / r.b) * (z / r.b) >= 1.02, "\(form) inside the body at y \(y)")
                checked += 1
            }
            #expect(checked > 200, "\(form): \(checked)")
        }
    }

    func halfWidth(_ form: GarmentForm, _ snap: AvatarSnapshot, atFraction f: Double) throws -> Float {
        let rig = try BodyRig(snap.silhouette)
        let y = Float((rig.h - rig.outline[rig.outlineIndex(atFraction: f)].y) / 100)
        let shell = try #require(try GarmentMesh.make(form, on: snap).pieces.first)
        return shell.positions.filter { abs($0.y - y) < 1e-5 }.map { abs($0.x) }.max() ?? 0
    }

    @Test("Layers nest at the chest and waist: coat > jacket > knit > shirt > tee")
    func layersNest() throws {
        let snap = try snapshot()
        for f in [0.27, 0.39] {
            let order: [GarmentForm] = [.tee, .shirt, .knit, .jacket, .coat]
            let widths = try order.map { try halfWidth($0, snap, atFraction: f) }
            #expect(zip(widths, widths.dropFirst()).allSatisfy { $0 < $1 }, "at \(f): \(widths)")
            #expect(zip(order, order.dropFirst()).allSatisfy { $0.layer < $1.layer })
        }
    }

    @Test("Long sleeves reach the wrist, short sleeves stop above the elbow; a coat reaches below the knee")
    func lengths() throws {
        let snap = try snapshot()
        let h = Float(snap.silhouette.heightCm / 100)
        func lowest(_ form: GarmentForm, piece: Int) throws -> Float {
            try #require(try GarmentMesh.make(form, on: snap).pieces[piece].positions.map(\.y).min())
        }
        let teeSleeve = try lowest(.tee, piece: 1), longSleeve = try lowest(.longSleeveTee, piece: 1)
        #expect(teeSleeve > h * 0.62 && longSleeve < h * 0.50, "\(teeSleeve) \(longSleeve)")
        #expect(try lowest(.coat, piece: 0) < h * 0.26)
        #expect(try lowest(.jacket, piece: 0) > h * 0.38)
        #expect(try lowest(.trousers, piece: 1) < h * 0.05)
        #expect(try lowest(.shorts, piece: 1) > h * 0.30)
    }

    @Test("Trouser legs contain the body's legs from the crotch to the hem")
    func trousersContainLegs() throws {
        let snap = try snapshot([(.hip, 112)])
        let rig = try BodyRig(snap.silhouette)
        let leg = try #require(try GarmentMesh.make(.trousers, on: snap).pieces.last { $0.role == .shell && $0.positions.map(\.x).reduce(0, +) > 0 })
        var checked = 0
        for ring in rig.legRings.dropLast() where ring.center.y < rig.h * 0.45 && ring.center.y > rig.h * 0.05 {
            let around = leg.positions.filter { abs(Double($0.y) * 100 - ring.center.y) < 1e-4 }
            guard !around.isEmpty else { continue }
            for v in around {
                let dx = (Double(v.x) * 100 - ring.center.x) / ring.a, dz = (Double(v.z) * 100 - ring.center.z) / ring.b
                #expect(dx * dx + dz * dz >= 1.02)
            }
            checked += 1
        }
        #expect(checked > 10)
    }

    @Test("Shoes enclose the foot and stand on the floor")
    func shoesEncloseFeet() throws {
        let snap = try snapshot()
        let body = try BodyMesh.make(from: snap)
        let foot = try #require(body.piece(.rightLeg)).positions.filter { $0.y < 0.03 }
        for form in [GarmentForm.sneakers, .boots, .loafers] {
            let shoes = try GarmentMesh.make(form, on: snap)
            let right = shoes.pieces.filter { $0.role == .shell && $0.positions.allSatisfy { $0.x > 0 } }
            let all = right.flatMap(\.positions)
            let lo = all.reduce(SIMD3<Float>(repeating: .infinity)) { pointwiseMin($0, $1) }
            let hi = all.reduce(SIMD3<Float>(repeating: -.infinity)) { pointwiseMax($0, $1) }
            #expect(foot.allSatisfy { $0.x > lo.x && $0.x < hi.x && $0.z > lo.z && $0.z < hi.z }, "\(form)")
            #expect(try #require(shoes.pieces.flatMap(\.positions).map(\.y).min()) <= 0.001)
            #expect(shoes.pieces.filter { $0.role == .sole }.count == 2)
        }
    }

    @Test("The tote hangs beside the leg, not through the hip")
    func toteBesideBody() throws {
        let snap = try snapshot([(.hip, 120)])
        let rig = try BodyRig(snap.silhouette)
        let bag = try #require(try GarmentMesh.make(.tote, on: snap).pieces.first)
        let lo = bag.positions.map(\.x).min()!
        let hipHalf = Float((rig.outline.map(\.x).dropFirst(rig.outlineIndex(atFraction: 0.4)).max() ?? 0) / 100)
        #expect(lo > hipHalf, "bag inner face \(lo) m vs hip \(hipHalf) m")
    }

    @Test("243 extreme bodies: every garment is valid on every buildable body")
    func extremeBodies() throws {
        var built = 0
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
                            } catch { continue }
                            guard let snap = try? AvatarSnapshot.make(for: profile), (try? BodyMesh.make(from: snap, detail: .low)) != nil else { continue }
                            for form in GarmentForm.allCases {
                                #expect((try? GarmentMesh.make(form, on: snap, detail: .low)) != nil, "\(form) h\(height) s\(shoulder) c\(chest) w\(waist) hip\(hip)")
                            }
                            built += 1
                        }
                    }
                }
            }
        }
        #expect(built > 200)
    }
}
