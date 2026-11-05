import CryptoKit
@testable import BodyGeometry
import Foundation
@testable import Octopus
import Testing

@Suite("Sculpted body (ADR-010, ADR-011 templates)")
struct SculptedBodyTests {
    func basis(_ t: BodyTemplate = .neutral) throws -> SculptedBodyBasis { try #require(SculptedBodyBasis.shared(t)) }

    func profile(_ values: [BodyParameter: Double], template: BodyTemplate = .neutral) throws -> BodyProfile {
        var p = try BodyProfile.neutral().withAppearance(template: template, weightKg: nil)
        // Height first, so the shoulder/height link never refuses a later shoulder value.
        for key in [BodyParameter.height, .shoulderWidth, .chest, .waist, .hip] {
            if let cm = values[key] { p = try p.applying(.slider(key, cm: cm)) }
        }
        return p
    }

    func sculpted(_ p: BodyProfile) throws -> BodyMesh { try BodyMesh.sculpted(from: AvatarSnapshot.make(for: p)) }

    @Test("Every bundled template loads, passes its checksum and matches its declared sizes", arguments: BodyTemplate.allCases)
    func basisLoads(_ t: BodyTemplate) throws {
        let b = try basis(t)
        #expect(b.meta.template == t.rawValue.lowercased())
        #expect(b.vertexCount > 10_000 && b.triangleCount > 20_000)
        #expect(b.base.count == b.vertexCount && b.isArm.count == b.vertexCount)
        #expect(b.deltas.count == b.meta.bases.count && b.deltas.allSatisfy { $0.count == b.vertexCount })
        #expect(b.indices.count == b.triangleCount * 3)
        #expect(b.meta.compression == "deflate-raw" && b.meta.rawByteCount > 1_000_000)
    }

    @Test("A damaged or mislabelled resource is refused, never half-loaded (fail closed)")
    func damagedBasisIsRefused() throws {
        let (json, original) = try #require(SculptedBodyBasis.bundledData(.neutral))
        #expect(throws: Never.self) { try SculptedBodyBasis(json: json, binary: original, template: .neutral) }
        var bin = original
        bin[100] ^= 0xFF
        #expect(throws: BodyEditError.unsafeGeometry("basis-checksum")) { try SculptedBodyBasis(json: json, binary: bin, template: .neutral) }
        #expect(throws: BodyEditError.unsafeGeometry("basis-meta")) { try SculptedBodyBasis(json: Data("{}".utf8), binary: bin, template: .neutral) }
        // A file whose checksum is right but whose compressed body is cut short never half-inflates.
        let cut = original.prefix(original.count / 2)
        var meta = try #require(JSONSerialization.jsonObject(with: json) as? [String: Any])
        meta["binarySHA256"] = SHA256.hash(data: cut).map { String(format: "%02x", $0) }.joined()
        let recut = try JSONSerialization.data(withJSONObject: meta)
        #expect(throws: BodyEditError.unsafeGeometry("basis-inflate")) { try SculptedBodyBasis(json: recut, binary: Data(cut), template: .neutral) }
        // The female file offered as the male body is refused, not drawn as the wrong template.
        let (fj, fb) = try #require(SculptedBodyBasis.bundledData(.female))
        #expect(throws: BodyEditError.unsafeGeometry("basis-template")) { try SculptedBodyBasis(json: fj, binary: fb, template: .male) }
    }

    @Test("Each template: one closed, outward, finite piece; feet on the floor; height exact", arguments: BodyTemplate.allCases)
    func templateIsValid(_ t: BodyTemplate) throws {
        let p = try profile([:], template: t)
        let m = try sculpted(p)
        try m.validate()
        #expect(m.pieces.map(\.part) == [.body])
        let ys = m.pieces[0].positions.map(\.y)
        #expect(abs(Double(ys.min()!)) < 1e-6)
        #expect(abs(Double(m.heightM) - p.cm(.height) / 100) < 1e-4)
    }

    @Test("Girths land on the drawn targets across a realistic grid (≤ 1 cm), and height is exact", arguments: BodyTemplate.allCases)
    func girthsMatchTargets(_ t: BodyTemplate) throws {
        let b = try basis(t)
        var worst = 0.0
        for h in [150.0, 170, 195] {
            for (s, c, w, hip) in [(36.0, 82.0, 64.0, 90.0), (42, 95, 82, 98), (46, 110, 98, 108), (40, 100, 76, 118), (48, 124, 112, 124)] {
                let p = try profile([.height: h, .shoulderWidth: s, .chest: c, .waist: w, .hip: hip], template: t)
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

    @Test("Left and right mirror each other (symmetric phenotype and pose)", arguments: BodyTemplate.allCases)
    func mirrorSymmetric(_ t: BodyTemplate) throws {
        let m = try sculpted(try profile([.waist: 95, .hip: 110], template: t))
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

    @Test("Every extreme combination (3⁵) gives a valid sculpted body, or is refused as out of range", arguments: BodyTemplate.allCases)
    func extremes(_ t: BodyTemplate) throws {
        let values: [BodyParameter: [Double]] = [
            .height: [120, 170, 220], .shoulderWidth: [30, 42, 54], .chest: [60, 100, 160], .waist: [50, 100, 160], .hip: [60, 110, 170],
        ]
        var built = 0
        for h in values[.height]! { for s in values[.shoulderWidth]! { for c in values[.chest]! { for w in values[.waist]! { for hip in values[.hip]! {
            guard let p = try? profile([.height: h, .shoulderWidth: s, .chest: c, .waist: w, .hip: hip], template: t) else { continue }
            let m = try sculpted(p)
            try m.validate()
            built += 1
        } } } } }
        #expect(built > 150)
    }

    @Test("Faceless: the head is one smooth convex egg (no nose, eye or ear relief)", arguments: BodyTemplate.allCases)
    func facelessHead(_ t: BodyTemplate) throws {
        let m = try sculpted(try profile([:], template: t))
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

    @Test("The snapshot's template picks the body: same values, different form (ADR-011)")
    func templatePicksTheBody() throws {
        var meshes: [BodyTemplate: BodyMesh] = [:]
        for t in BodyTemplate.allCases {
            // Identical drawn values on purpose: only the template differs.
            let p = try profile([.shoulderWidth: 42, .chest: 95, .waist: 82, .hip: 98], template: t)
            let snapshot = try AvatarSnapshot.make(for: p)
            #expect(snapshot.template == t)
            meshes[t] = try #require(BodyMesh.best(from: snapshot))
        }
        let n = try #require(meshes[.neutral]).pieces[0].positions
        for t in [BodyTemplate.female, .male] {
            let other = try #require(meshes[t]).pieces[0].positions
            let moved = zip(n, other).map { (($0 - $1) * ($0 - $1)).sum().squareRoot() }.max() ?? 0
            #expect(moved > 0.01, "\(t) should differ from neutral")
        }
    }
}
