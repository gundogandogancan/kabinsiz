import BodyGeometry
import Foundation
@testable import GarmentPattern
import Testing

/// V37-04: a pattern sewn into a 3D garment whose front panel carries the photo's own pixels.
@Suite("Sewn garment mesh: seams, normals, UVs, no clipping")
struct PatternGarmentMeshTests {
    func body(_ form: BodyForm = .neutral, _ edits: [(BodyParameter, Double)] = []) throws -> BodyMesh {
        var p = BodyProfile.neutral(form: form)
        for (k, cm) in edits { p = try p.applying(.measured(k, cm, .centimeters)) }
        return try BodyMesh.make(from: try AvatarSnapshot.make(for: p))
    }

    func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float { ((a - b) * (a - b)).sum().squareRoot() }

    func piece(_ g: SewnGarment, _ panel: PatternPiece.Role, _ side: SewnGarment.Side) throws -> SewnGarment.Piece {
        try #require(g.pieces.first { $0.panel == panel && $0.side == side })
    }

    /// Perimeter of points in one horizontal plane, walked in angle order round (cx, cz).
    func ringPerimeter(_ pts: [SIMD3<Float>], cx: Double, cz: Double) -> Double {
        let sorted = pts.map { (Double($0.x), Double($0.z)) }.sorted { atan2($0.1 - cz, $0.0 - cx) < atan2($1.1 - cz, $1.0 - cx) }
        var s = 0.0
        for i in sorted.indices {
            let a = sorted[i], b = sorted[(i + 1) % sorted.count]
            s += hypot(b.0 - a.0, b.1 - a.1)
        }
        return s
    }

    @Test("MESH-T01: every kind sews onto several bodies: finite, valid, inside the figure's space")
    func everyKindBuilds() throws {
        for b in [try body(), try body(.feminine), try body(.masculine, [(.chest, 118), (.waist, 108)])] {
            for kind in GarmentKind.allCases {
                let profileBlock = try PatternDrafter.block(for: .neutral(), kind: kind)
                let g = try PatternGarmentMesh.sew(profileBlock, onto: b)
                try g.validate(heightM: b.heightM)
                #expect(g.bodyRevision == b.bodyRevision)
                #expect(g.triangleCount > 500 && g.triangleCount < 20_000, "\(kind): \(g.triangleCount)")
                for p in g.pieces { #expect(p.positions.allSatisfy { $0.x.isFinite && $0.y.isFinite && $0.z.isFinite }) }
                #expect(g.pieces(.front).count == 2 && g.pieces(.back).count == 2)
            }
        }
    }

    @Test("MESH-T02: front panel normals face outwards (> 95 % of vertices)")
    func outwardNormals() throws {
        let b = try body(.feminine)
        let env = try BodyEnvelope(b)
        for kind in [GarmentKind.top, .longSleeveTop, .dress, .coat, .skirt] {
            let g = try PatternGarmentMesh.sew(try PatternDrafter.block(for: .neutral(form: .feminine), kind: kind), onto: b)
            for panel in [PatternPiece.Role.front, .back] {
                var good = 0, all = 0
                for p in g.pieces(panel) {
                    for (v, n) in zip(p.positions, p.normals) {
                        let s = env.torsoSection(atY: Double(v.y))
                        let radial = SIMD3<Float>(Float(Double(v.x) - s.centerX), 0, Float(Double(v.z) - s.centerZ))
                        if (radial * n).sum() > 0 { good += 1 }
                        all += 1
                    }
                }
                #expect(Double(good) / Double(all) > 0.95, "\(kind) \(panel): \(good)/\(all)")
            }
        }
    }

    @Test("MESH-T03: side seams (and the trouser inseam) meet within 1 mm; the shoulder seam closes")
    func seamsMeet() throws {
        let b = try body()
        let h = Double(b.heightM)
        for kind in GarmentKind.allCases {
            let pattern = try PatternDrafter.block(for: .neutral(), kind: kind)
            let g = try PatternGarmentMesh.sew(pattern, onto: b)
            for side in [SewnGarment.Side.right, .left] {
                let f = try piece(g, .front, side), k = try piece(g, .back, side)
                let backSeam = k.rightEdge.map { k.positions[Int($0)] }
                // Bodice: the side seam starts at the underarm; above it the edge is the armhole.
                var below = Float.infinity
                if let ua = pattern.piece(.front)?.notch("underarm") {
                    below = Float(h * (1 - PatternGarmentMesh.neckPointFraction) - ua.y / 100) + 1e-5
                }
                var checked = 0
                for i in f.rightEdge {
                    let v = f.positions[Int(i)]
                    guard v.y <= below else { continue }
                    let gap = backSeam.map { distance($0, v) }.min() ?? .infinity
                    #expect(gap < 0.001, "\(kind) \(side) side seam gap \(gap) m at y \(v.y)")
                    checked += 1
                }
                #expect(checked >= 5, "\(kind): \(checked) seam vertices")
                if kind == .trousers || kind == .shorts {
                    let crotch = Float(h * (1 - PatternGarmentMesh.waistFraction) - (pattern.piece(.front)?.notch("crotch-point")?.y ?? 0) / 100)
                    let backInseam = k.leftEdge.map { k.positions[Int($0)] }
                    for i in f.leftEdge where f.positions[Int(i)].y <= crotch - 1e-5 {
                        let gap = backInseam.map { distance($0, f.positions[Int(i)]) }.min() ?? .infinity
                        #expect(gap < 0.001, "\(kind) inseam gap \(gap)")
                    }
                }
                if let pf = pattern.piece(.front), let pb = pattern.piece(.back), let sp = pf.notch("shoulder-point") {
                    // Shoulder seam: front and back share their rows; down to the shoulder point the right
                    // edge is the shoulder line on both, and the two must be one line in 3D.
                    let rows = [0.0] + PatternGarmentMesh.rowList([pf, pb], step: 1.5).filter { $0 > 1e-6 && $0 <= sp.y + 1e-9 }
                    #expect(rows.count >= 3)
                    for r in rows.indices {
                        let gap = distance(f.positions[Int(f.rightEdge[r])], k.positions[Int(k.rightEdge[r])])
                        #expect(gap < 0.001, "\(kind) shoulder seam gap \(gap) at row \(rows[r])")
                    }
                }
            }
            // Sleeve seam: both edges of the tube are one line.
            if let s = g.pieces(.sleeve).first {
                for (a, c) in zip(s.leftEdge, s.rightEdge) { #expect(distance(s.positions[Int(a)], s.positions[Int(c)]) < 0.001) }
            }
        }
    }

    @Test("MESH-T04: at chest level the garment encloses the body (circumference ≥ body chest, no point inside)")
    func noClippingAtChest() throws {
        for (b, form) in [(try body(), BodyForm.neutral), (try body(.feminine), .feminine), (try body(.masculine, [(.chest, 125)]), .masculine)] {
            let env = try BodyEnvelope(b)
            let torso = try #require(b.piece(.torso))
            for kind in [GarmentKind.top, .longSleeveTop, .coat, .dress] {
                // Block from a different (neutral) body, and a pattern from small measurements: both must not clip.
                let patterns = [try PatternDrafter.block(for: .neutral(form: form), kind: kind),
                                try PatternDrafter.pattern(from: GarmentMeasurements(kind: kind, bodyWidth: .init(40, .userMeasured), length: .init(70, .userMeasured)))]
                for pattern in patterns {
                    let g = try PatternGarmentMesh.sew(pattern, onto: b)
                    let chestY = Float(Double(b.heightM) * (1 - Silhouette.Station.chest.heightFraction))
                    let fr = try piece(g, .front, .right)
                    let rowY = try #require(fr.positions.min { abs($0.y - chestY) < abs($1.y - chestY) }).y
                    let ring = (g.pieces(.front) + g.pieces(.back)).flatMap(\.positions).filter { abs($0.y - rowY) < 1e-6 }
                    #expect(ring.count >= 40)
                    let s = env.torsoSection(atY: Double(rowY))
                    for v in ring { #expect(s.level(x: Double(v.x), z: Double(v.z)) >= 1, "\(kind) point inside the body") }
                    // Body ring straight from the mesh: the torso ring nearest that height.
                    let bodyY = try #require(torso.positions.min { abs($0.y - rowY) < abs($1.y - rowY) }).y
                    let bodyRing = torso.positions.filter { $0.y == bodyY }
                    let garmentC = ringPerimeter(ring, cx: 0, cz: s.centerZ)
                    let bodyC = ringPerimeter(bodyRing, cx: 0, cz: s.centerZ)
                    #expect(garmentC >= bodyC, "\(kind): garment \(garmentC) vs body \(bodyC)")
                }
            }
        }
    }

    @Test("MESH-T05: a looser pattern keeps its circumference, so the print is not stretched")
    func circumferenceMatchesPattern() throws {
        let b = try body()
        let pattern = try PatternDrafter.block(for: .neutral(), kind: .top)
        let g = try PatternGarmentMesh.sew(pattern, onto: b)
        let front = try #require(pattern.piece(.front))
        let fr = try piece(g, .front, .right)
        // One row below the underarm: the 3D arc across the right front equals the pattern width.
        let ua = try #require(front.notch("underarm"))
        let targetY = Float(Double(b.heightM) * (1 - PatternGarmentMesh.neckPointFraction) - (ua.y + 6) / 100)
        let rowY = try #require(fr.positions.min { abs($0.y - targetY) < abs($1.y - targetY) }).y
        let row = fr.positions.filter { abs($0.y - rowY) < 1e-6 }
        var arc = 0.0
        for (a, c) in zip(row, row.dropFirst()) { arc += Double(distance(a, c)) }
        let patternY = (Double(b.heightM) * (1 - PatternGarmentMesh.neckPointFraction) - Double(rowY)) * 100
        let width = front.width(atY: patternY)
        #expect(abs(arc * 100 - width) / width < 0.01, "3D arc \(arc * 100) cm vs pattern \(width) cm")
    }

    @Test("MESH-T06: the front UV region covers the front panel exactly; the photo is not stretched")
    func frontUVRegion() throws {
        let b = try body()
        for aspect in [nil, 0.6, 1.0, 1.8] as [Double?] {
            let aspects: [PatternPiece.Role: Double] = aspect.map { [.front: $0, .back: $0] } ?? [:]
            for kind in [GarmentKind.top, .trousers, .skirt] {
                let g = try PatternGarmentMesh.sew(try PatternDrafter.block(for: .neutral(), kind: kind), onto: b, photoAspects: aspects)
                for panel in [PatternPiece.Role.front, .back] {
                    let r = try #require(g.uvRegion(panel))
                    #expect(r.u0 >= 0 && r.v0 >= 0 && r.u1 <= 1 && r.v1 <= 1 && r.u1 > r.u0 && r.v1 > r.v0)
                    if let aspect { #expect(abs(r.cmPerU / r.cmPerV - aspect) < 1e-9, "isotropic pixels") }
                    let uvs = g.pieces(panel).flatMap(\.uvs)
                    let us = uvs.map { Double($0.x) }, vs = uvs.map { Double($0.y) }
                    #expect(us.allSatisfy { $0 >= r.u0 - 1e-4 && $0 <= r.u1 + 1e-4 } && vs.allSatisfy { $0 >= r.v0 - 1e-4 && $0 <= r.v1 + 1e-4 })
                    #expect(abs(vs.min()! - r.v0) < 1e-3 && abs(vs.max()! - r.v1) < 1e-3, "\(kind) \(panel) spans the region's height")
                    if kind != .trousers {
                        #expect(abs(us.min()! - r.u0) < 1e-3 && abs(us.max()! - r.u1) < 1e-3, "\(kind) \(panel) spans the region's width")
                    }
                }
                // The wearer's centre front is the photo's centre line: right and left halves meet there.
                let fr = try piece(g, .front, .right), fl = try piece(g, .front, .left)
                let r = try #require(g.uvRegion(.front))
                if kind != .trousers {
                    let onCentre = fr.leftEdge.filter { abs(fr.positions[Int($0)].x) < 1e-6 }
                    #expect(onCentre.count >= 10)
                    for i in onCentre { #expect(abs(Double(fr.uvs[Int(i)].x) - (r.u0 + r.u1) / 2) < 1e-4) }
                }
                #expect(fr.uvs.allSatisfy { Double($0.x) >= (r.u0 + r.u1) / 2 - 0.2 } && fl.uvs.allSatisfy { Double($0.x) <= (r.u0 + r.u1) / 2 + 0.2 })
                // The viewer's right half (+x) shows the photo's right half.
                let maxX = try #require(fr.positions.indices.max { fr.positions[$0].x < fr.positions[$1].x })
                #expect(Double(fr.uvs[maxX].x) > (r.u0 + r.u1) / 2)
            }
        }
    }

    @Test("MESH-T07: same pattern, same body → identical garment")
    func deterministic() throws {
        let b = try body(.masculine)
        for kind in GarmentKind.allCases {
            let p = try PatternDrafter.block(for: .neutral(form: .masculine), kind: kind)
            #expect(try PatternGarmentMesh.sew(p, onto: b) == PatternGarmentMesh.sew(p, onto: b))
        }
        let m = try PatternDrafter.pattern(from: GarmentMeasurements(kind: .top, bodyWidth: .init(52, .photoEstimated), length: .init(70, .userMeasured)))
        #expect(try PatternGarmentMesh.sew(m, onto: b, photoAspects: [.front: 0.8]) == PatternGarmentMesh.sew(m, onto: b, photoAspects: [.front: 0.8]))
    }

    @Test("MESH-T08: a pattern smaller than the body is drawn at the standoff and says so")
    func tightPatternNoted() throws {
        let b = try body(.masculine, [(.chest, 130), (.waist, 120)])
        let small = try PatternDrafter.pattern(from: GarmentMeasurements(kind: .top, bodyWidth: .init(40, .userMeasured), length: .init(66, .userMeasured)))
        let g = try PatternGarmentMesh.sew(small, onto: b)
        #expect(g.notes.contains { $0.contains("dar") })
        let loose = try PatternGarmentMesh.sew(try PatternDrafter.block(for: .neutral(), kind: .top), onto: try body())
        #expect(!loose.notes.contains { $0.contains("dar") })
    }

    @Test("MESH-T09: a top hangs outside the trousers below the waistband, and its sleeve cap wraps the arm from the shoulder")
    func untuckedHemAndSleeveCap() throws {
        let b = try body()
        let env = try BodyEnvelope(b)
        let g = try PatternGarmentMesh.sew(try PatternDrafter.block(for: .neutral(), kind: .top), onto: b)
        // Fully eased out 2 cm below the band (5 cm blend from 3 cm above it): outside the body's
        // envelope by the untucked distance, which is more than any drawn bottom's allowance (≤ 1.6 cm).
        let band = env.heightM * (1 - PatternGarmentMesh.bottomsWaistbandFraction)
        let clear = (PatternGarmentMesh.untuckedHemStandoffCm - 0.05) / 100
        var checked = 0
        for piece in g.pieces where piece.panel == .front || piece.panel == .back {
            for p in piece.positions where Double(p.y) < band - 0.02 {
                let sec = env.torsoSection(atY: Double(p.y))
                let u = (Double(p.x) - sec.centerX) / (sec.a + clear), v = (Double(p.z) - sec.centerZ) / (sec.b + clear)
                #expect(u * u + v * v >= 0.999, "hem point inside the untucked distance at y \(p.y)")
                checked += 1
            }
        }
        #expect(checked > 20, "the block reaches below the waistband")
        // No sleeve vertex inside the arm, the cap included (it used to shrink to the arm axis there).
        for piece in g.pieces where piece.panel == .sleeve {
            for p in piece.positions {
                // The envelope holds one arm; the mirrored sleeve is checked against it mirrored.
                let sameSide = (p.x >= 0) == (env.arm.joint.x >= 0)
                let q = SIMD3<Double>(sameSide ? Double(p.x) : -Double(p.x), Double(p.y), Double(p.z)) - env.arm.joint
                let along = (q * env.arm.axis).sum()
                guard along >= 0, along <= env.arm.length - 0.02 else { continue }
                let off = q - env.arm.axis * along
                let dist = (off * off).sum().squareRoot()
                #expect(dist >= env.arm.radius(at: along) - 0.002, "sleeve point inside the arm at \(along) m")
            }
        }
    }
}
