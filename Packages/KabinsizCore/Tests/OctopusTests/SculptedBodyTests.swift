@testable import BodyGeometry
import Foundation
@testable import Octopus
import Testing

@Suite("Sculpted neutral body (ADR-010)")
struct SculptedBodyTests {
    func basis() throws -> SculptedBodyBasis { try #require(SculptedBodyBasis.shared) }

    func profile(_ values: [BodyParameter: Double]) throws -> BodyProfile {
        var p = BodyProfile.neutral()
        // Height first, so the shoulder/height link never refuses a later shoulder value.
        for key in [BodyParameter.height, .shoulderWidth, .chest, .waist, .hip] {
            if let cm = values[key] { p = try p.applying(.slider(key, cm: cm)) }
        }
        return p
    }

    func sculpted(_ p: BodyProfile) throws -> BodyMesh { try BodyMesh.sculpted(from: AvatarSnapshot.make(for: p)) }

    @Test("Bundled basis loads, passes its checksum and matches its declared sizes")
    func basisLoads() throws {
        let b = try basis()
        #expect(b.vertexCount > 10_000 && b.triangleCount > 20_000)
        #expect(b.base.count == b.vertexCount && b.isArm.count == b.vertexCount)
        #expect(b.deltas.count == b.meta.bases.count && b.deltas.allSatisfy { $0.count == b.vertexCount })
        #expect(b.indices.count == b.triangleCount * 3)
    }

    @Test("A damaged resource is refused, never half-loaded (fail closed)")
    func damagedBasisIsRefused() throws {
        let (json, original) = try #require(SculptedBodyBasis.bundledData())
        #expect(throws: Never.self) { try SculptedBodyBasis(json: json, binary: original) }
        var bin = original
        bin[100] ^= 0xFF
        #expect(throws: BodyEditError.unsafeGeometry("basis-checksum")) { try SculptedBodyBasis(json: json, binary: bin) }
        #expect(throws: BodyEditError.unsafeGeometry("basis-meta")) { try SculptedBodyBasis(json: Data("{}".utf8), binary: bin) }
    }

    @Test("Neutral body: one closed, outward, finite piece; feet on the floor; height exact")
    func neutralIsValid() throws {
        let p = BodyProfile.neutral()
        let m = try sculpted(p)
        try m.validate()
        #expect(m.pieces.map(\.part) == [.body])
        let ys = m.pieces[0].positions.map(\.y)
        #expect(abs(Double(ys.min()!)) < 1e-6)
        #expect(abs(Double(m.heightM) - p.cm(.height) / 100) < 1e-4)
    }

    @Test("Girths land on the drawn targets across a realistic grid (≤ 1 cm), and height is exact")
    func girthsMatchTargets() throws {
        let b = try basis()
        var worst = 0.0
        for h in [150.0, 170, 195] {
            for (s, c, w, hip) in [(36.0, 82.0, 64.0, 90.0), (42, 95, 82, 98), (46, 110, 98, 108), (40, 100, 76, 118), (48, 124, 112, 124)] {
                let p = try profile([.height: h, .shoulderWidth: s, .chest: c, .waist: w, .hip: hip])
                let snapshot = try AvatarSnapshot.make(for: p)
                let m = try BodyMesh.sculpted(from: snapshot)
                let target = try #require(SculptedBody.targetsCm(snapshot))
                let got = SculptedBody.measureCm(b, m.pieces[0].positions)
                // The solve gets close; the radial and shoulder corrections close the rest.
                for i in 1...3 { worst = max(worst, abs(got[i] - target[i])) }
                #expect(abs(got[0] - target[0]) < 1.0, "shoulder \(got[0]) vs \(target[0])")
                #expect(abs(Double(m.heightM) - h / 100) < 1e-4)
            }
        }
        #expect(worst < 1.0, "worst girth error \(worst) cm")
    }

    @Test("Left and right mirror each other (neutral phenotype, symmetric pose)")
    func mirrorSymmetric() throws {
        let m = try sculpted(try profile([.waist: 95, .hip: 110]))
        let pts = m.pieces[0].positions
        // Every vertex has a mirror partner within 2 mm (checked on a sample, nearest neighbour).
        for i in stride(from: 0, to: pts.count, by: 97) {
            let mirror = SIMD3(-pts[i].x, pts[i].y, pts[i].z)
            let nearest = pts.map { (($0 - mirror) * ($0 - mirror)).sum() }.min()!
            #expect(nearest.squareRoot() < 0.002)
        }
    }

    @Test("Same snapshot, same mesh, bit for bit")
    func deterministic() throws {
        let p = try profile([.chest: 104, .waist: 90])
        #expect(try sculpted(p) == sculpted(p))
    }

    @Test("Every extreme combination (3⁵) gives a valid sculpted body, or is refused as out of range")
    func extremes() throws {
        let values: [BodyParameter: [Double]] = [
            .height: [120, 170, 220], .shoulderWidth: [30, 42, 54], .chest: [60, 100, 160], .waist: [50, 100, 160], .hip: [60, 110, 170],
        ]
        var built = 0
        for h in values[.height]! { for s in values[.shoulderWidth]! { for c in values[.chest]! { for w in values[.waist]! { for hip in values[.hip]! {
            guard let p = try? profile([.height: h, .shoulderWidth: s, .chest: c, .waist: w, .hip: hip]) else { continue }
            let m = try sculpted(p)
            try m.validate()
            built += 1
        } } } } }
        #expect(built > 150)
    }

    @Test("Faceless: the head is one smooth convex egg (no nose, eye or ear relief)")
    func facelessHead() throws {
        let m = try sculpted(.neutral())
        let pts = m.pieces[0].positions
        let top = pts.map(\.y).max()!
        // Head band above the chin: the front-facing profile along the centre line has no bump.
        let band = pts.filter { $0.y > top - 0.15 * m.heightM / 1.837 && abs($0.x) < 0.006 && $0.z > 0 }
            .sorted { $0.y < $1.y }
        #expect(band.count > 8)
        // Along an egg the forward depth changes monotonically up to the widest point and then
        // back; a nose would add a second local maximum.
        var maxima = 0
        let z = band.map(\.z)
        for i in 2..<(z.count - 2) where z[i] > z[i - 2] + 0.0005 && z[i] > z[i + 2] + 0.0005 { maxima += 1 }
        #expect(maxima <= 1)
    }

    @Test("Without a basis the 3D tier falls back to the procedural body (G0 order)")
    func fallback() throws {
        let snapshot = try AvatarSnapshot.make(for: .neutral())
        #expect(throws: BodyEditError.unsafeGeometry("basis-missing")) { try BodyMesh.sculpted(from: snapshot, basis: nil) }
        #expect(BodyMesh.best(from: snapshot)?.pieces.map(\.part) == [.body])
    }
}
