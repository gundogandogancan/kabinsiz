import Foundation

/// The shape family of a garment drawn on the body. Original, procedural geometry (v2.5 §5.2 tier T1:
/// "temsili", category-level): colour and silhouette approximate a real piece, never its pattern,
/// seams, logo or fit. Nothing here is downloaded or licensed.
public enum GarmentForm: String, Codable, CaseIterable, Sendable {
    case tee, longSleeveTee, knit, shirt, jacket, coat
    case trousers, jeans, shorts, skirt
    case sneakers, boots, loafers
    case belt, tote, scarf

    /// Drawing order from the skin outwards. A garment of a higher layer is always the larger surface
    /// where two overlap, so an outer layer never disappears inside an inner one while turning.
    public var layer: Int {
        switch self {
        case .sneakers, .boots, .loafers: 1
        case .trousers, .jeans, .shorts, .skirt: 2
        case .tee, .longSleeveTee: 3
        case .shirt: 4
        case .knit: 5
        case .belt: 6
        case .jacket: 7
        case .coat: 8
        case .scarf: 9
        case .tote: 10
        }
    }
}

/// A garment surface built from the same rings as the body (`BodyRig`), pushed outwards by the
/// garment's ease. Coordinates match `BodyMesh` (metres, y up from the floor, z towards the viewer).
public struct GarmentMesh: Codable, Hashable, Sendable {
    /// What a surface is, so the renderer can give trims, soles and hardware their own material.
    public enum Role: String, Codable, Sendable { case shell, trim, sole, hardware }

    public struct Piece: Codable, Hashable, Sendable {
        public let role: Role
        public let positions: [SIMD3<Float>]
        public let normals: [SIMD3<Float>]
        public let indices: [UInt32]
    }

    public let form: GarmentForm
    public let bodyRevision: Int
    public let pieces: [Piece]

    public var triangleCount: Int { pieces.reduce(0) { $0 + $1.indices.count / 3 } }

    /// Axis-aligned bounds of every piece, in metres.
    public var bounds: (min: SIMD3<Float>, max: SIMD3<Float>) {
        var lo = SIMD3<Float>(repeating: .infinity), hi = SIMD3<Float>(repeating: -.infinity)
        for p in pieces.flatMap(\.positions) {
            lo = pointwiseMin(lo, p)
            hi = pointwiseMax(hi, p)
        }
        return (lo, hi)
    }

    // MARK: Ease (cm)

    /// How far the garment stands off the skin: a visual allowance, not a fit or size statement.
    static func ease(_ form: GarmentForm) -> Double {
        switch form {
        case .tee, .longSleeveTee: 0.9
        case .shirt: 1.3
        case .knit: 2.0
        case .jacket: 3.0
        case .coat: 3.8
        case .jeans: 0.8
        case .trousers, .shorts: 1.3
        case .skirt: 1.6
        case .sneakers, .boots, .loafers: 0.7
        case .belt: 0.5
        case .tote, .scarf: 0
        }
    }

    // MARK: Build

    public static func make(_ form: GarmentForm, on snapshot: AvatarSnapshot, detail: BodyMesh.Detail = .standard) throws(BodyEditError) -> GarmentMesh {
        let rig = try BodyRig(snapshot.silhouette)
        let s = detail.rawValue
        var pieces: [Piece]
        switch form {
        case .tee: pieces = top(rig, form, hem: 0.505, sleeve: 0.30, segments: s)
        case .longSleeveTee: pieces = top(rig, form, hem: 0.505, sleeve: 0.86, segments: s)
        case .shirt: pieces = top(rig, form, hem: 0.52, sleeve: 0.86, segments: s, collar: true)
        case .knit: pieces = top(rig, form, hem: 0.50, sleeve: 0.86, segments: s, ribbed: true)
        case .jacket: pieces = top(rig, form, hem: 0.585, sleeve: 0.88, segments: s, collar: true, placket: true)
        case .coat: pieces = top(rig, form, hem: 0.80, sleeve: 0.90, segments: s, collar: true, placket: true, flare: 3.5)
        case .trousers: pieces = bottom(rig, form, hem: 0.965, straightFrom: 0.62, segments: s)
        case .jeans: pieces = bottom(rig, form, hem: 0.96, straightFrom: 0.80, segments: s)
        case .shorts: pieces = bottom(rig, form, hem: 0.68, straightFrom: 0.60, segments: s)
        case .skirt: pieces = skirt(rig, hem: 0.76, segments: s)
        case .sneakers: pieces = shoes(rig, form, top: 0.048, length: 0.076, segments: s)
        case .boots: pieces = shoes(rig, form, top: 0.105, length: 0.078, segments: s)
        case .loafers: pieces = shoes(rig, form, top: 0.036, length: 0.074, segments: s)
        case .belt: pieces = belt(rig, segments: s)
        case .tote: pieces = tote(rig, segments: s)
        case .scarf: pieces = scarf(rig, segments: s)
        }
        let mesh = GarmentMesh(form: form, bodyRevision: snapshot.bodyRevision, pieces: pieces.map { $0.scaled(0.01) })
        try mesh.validate(heightM: Float(rig.h * 0.01))
        return mesh
    }

    /// Finite numbers, indices in range, no degenerate triangle, unit normals, inside the figure's
    /// space. Garment surfaces may be open (hems, cuffs); the renderer draws both faces.
    public func validate(heightM: Float) throws(BodyEditError) {
        guard !pieces.isEmpty else { throw .unsafeGeometry("garment-empty") }
        for piece in pieces {
            let n = piece.positions.count
            guard n >= 3, piece.normals.count == n, piece.indices.count >= 3, piece.indices.count % 3 == 0 else { throw .unsafeGeometry("garment-shape") }
            for (p, nrm) in zip(piece.positions, piece.normals) {
                guard p.x.isFinite, p.y.isFinite, p.z.isFinite else { throw .unsafeGeometry("garment-nan") }
                guard p.y >= -0.002, p.y <= heightM + 0.002, abs(p.x) < heightM, abs(p.z) < heightM else { throw .unsafeGeometry("garment-bounds") }
                let len = (nrm * nrm).sum().squareRoot()
                guard abs(len - 1) < 0.01 else { throw .unsafeGeometry("garment-normal") }
            }
            for t in stride(from: 0, to: piece.indices.count, by: 3) {
                let i = piece.indices[t], j = piece.indices[t + 1], k = piece.indices[t + 2]
                guard Int(i) < n, Int(j) < n, Int(k) < n, i != j, j != k, i != k else { throw .unsafeGeometry("garment-index") }
                let a = piece.positions[Int(i)], b = piece.positions[Int(j)], c = piece.positions[Int(k)]
                let cr = cross(b - a, c - a)
                guard (cr * cr).sum() > 1e-14 else { throw .unsafeGeometry("garment-degenerate") }
            }
        }
    }

    // MARK: Forms

    /// Body of a top or outer layer from the neck to `hem` (fraction of height from the crown) plus two
    /// sleeves to `sleeve` (fraction of the arm, 0 = shoulder, 1 = hand). Below the crotch the hem ring
    /// encloses both legs; `flare` (cm at the hem) opens a coat into an A-line.
    static func top(_ rig: BodyRig, _ form: GarmentForm, hem: Double, sleeve: Double, segments: Int,
                    collar: Bool = false, ribbed: Bool = false, placket: Bool = false, flare: Double = 0) -> [Piece] {
        let e = ease(form)
        let h = rig.h
        let first = rig.outlineIndex(atFraction: 0.142)
        let last = rig.outlineIndex(atFraction: hem)
        var rings: [GRing] = []
        let crotch = rig.crotchIndex
        let legDepth = rig.legRings.map(\.b).max() ?? rig.depths[crotch]
        for i in first...last {
            let p = rig.outline[i]
            let y = h - p.y
            if i <= crotch {
                rings.append(GRing(center: SIMD3(0, y, rig.zShift[i]), a: p.x + e, b: rig.depths[i] + e))
            } else {
                // Below the crotch: one ellipse around both legs, flaring towards the hem.
                let t = Double(i - crotch) / Double(max(last - crotch, 1))
                let depth = max(rig.depths[crotch] * 0.96, legDepth)
                rings.append(GRing(center: SIMD3(0, y, 0), a: p.x + e + flare * t, b: depth + e + flare * 0.6 * t))
            }
        }
        var pieces = [tube(rings, segments: segments, role: .shell)]
        // Sleeves: the arm's own rings, pushed out by the same ease, capped at the shoulder so the
        // opening never shows from above.
        let armRings = zip(rig.armRings, rig.armT).filter { $0.1 <= sleeve }.map { ring, _ in
            GRing(center: ring.center, a: ring.a + e, b: ring.b + e, u: ring.u, v: SIMD3(0, 0, 1))
        }
        if armRings.count >= 2 {
            let sleevePiece = tube(armRings, segments: max(segments / 2, 12), role: .shell,
                                   topCap: rig.arm.joint - rig.arm.axis * (0.008 * h))
            pieces.append(sleevePiece)
            pieces.append(sleevePiece.mirrored())
        }
        if collar {
            // A short stand collar just above the neckline.
            let neck = rig.outline[first]
            let y0 = h - neck.y
            let c = [GRing(center: SIMD3(0, y0 - 0.2, 0), a: neck.x + e + 0.4, b: rig.depths[first] + e + 0.4),
                     GRing(center: SIMD3(0, y0 + 0.022 * h, -0.004 * h), a: neck.x + e + 0.9, b: rig.depths[first] + e + 0.6)]
            pieces.append(tube(c, segments: segments, role: .trim))
        }
        if ribbed, let low = rings.last {
            // Knit hem band: slightly tighter and a different surface.
            let band = [GRing(center: low.center + SIMD3(0, 0.03 * h, 0), a: low.a + 0.15, b: low.b + 0.15),
                        GRing(center: low.center - SIMD3(0, 0.002 * h, 0), a: low.a - 0.25, b: low.b - 0.25)]
            pieces.append(tube(band, segments: segments, role: .trim))
        }
        if placket {
            // Front opening: a narrow strip on the centre front, with buttons for a jacket or coat.
            var strip: [SIMD3<Double>] = []
            for r in rings { strip.append(SIMD3(0, r.center.y, r.center.z + r.b + 0.12)) }
            pieces.append(ribbon(strip, halfWidth: 0.0075 * h, normal: SIMD3(0, 0, 1), role: .trim))
            let count = form == .coat ? 4 : 3
            for k in 0..<count {
                let f = 0.30 + Double(k) * (form == .coat ? 0.085 : 0.075)
                let i = rig.outlineIndex(atFraction: f)
                guard let r = rings.first(where: { $0.center.y <= h - rig.outline[i].y }) else { continue }
                pieces.append(disc(center: SIMD3(0, r.center.y, r.center.z + r.b + 0.25), radius: 0.006 * h, role: .hardware))
            }
        }
        return pieces
    }

    /// Waistband and seat from the waist to the crotch, then two legs to `hem`. From `straightFrom`
    /// down, the leg keeps the width it has there (a straight cut, not skin-tight to the ankle).
    static func bottom(_ rig: BodyRig, _ form: GarmentForm, hem: Double, straightFrom: Double, segments: Int) -> [Piece] {
        let e = ease(form)
        let h = rig.h
        let waist = rig.outlineIndex(atFraction: 0.40)
        let seatRings = rig.torsoRings[waist...].map { GRing(center: $0.center, a: $0.a + e, b: $0.b + e) }
        let seatBottom = seatRings.last!.center - SIMD3(0, 0.006 * h, 0)
        var pieces = [tube(Array(seatRings), segments: segments, role: .shell, bottomCap: seatBottom)]
        let hemY = h * (1 - hem)
        let straightY = h * (1 - straightFrom)
        var legs: [GRing] = []
        var held: (a: Double, b: Double)?
        for ring in rig.legRings.dropLast() where ring.center.y >= hemY - 0.01 {
            var a = ring.a + e, b = ring.b + e
            if ring.center.y <= straightY {
                if held == nil { held = (a, b) }
                a = max(a, held!.a * 0.92)
                b = max(b, held!.b * 0.92)
            }
            legs.append(GRing(center: ring.center, a: a, b: b))
        }
        if legs.count >= 2 {
            let leg = tube(legs, segments: segments, role: .shell, topCap: legs[0].center + SIMD3(0, 0.01 * h, 0))
            pieces.append(leg)
            pieces.append(leg.mirrored())
        }
        // Waistband: a narrow band at the top edge.
        if let top = seatRings.first {
            let band = [GRing(center: top.center + SIMD3(0, 0.003 * h, 0), a: top.a + 0.25, b: top.b + 0.25),
                        GRing(center: top.center - SIMD3(0, 0.022 * h, 0), a: top.a + 0.25, b: top.b + 0.25)]
            pieces.append(tube(band, segments: segments, role: .trim))
        }
        return pieces
    }

    /// One cone around both legs from the waist to `hem`.
    static func skirt(_ rig: BodyRig, hem: Double, segments: Int) -> [Piece] {
        let e = ease(.skirt)
        let h = rig.h
        let waist = rig.outlineIndex(atFraction: 0.40)
        let last = rig.outlineIndex(atFraction: hem)
        let legDepth = rig.legRings.map(\.b).max() ?? 0
        var rings: [GRing] = []
        var widest = 0.0, deepest = 0.0
        for i in waist...last {
            let p = rig.outline[i]
            widest = max(widest, p.x + e)
            deepest = max(deepest, max(i <= rig.crotchIndex ? rig.depths[i] : legDepth, rig.depths[min(i, rig.crotchIndex)]) + e)
            let t = Double(i - waist) / Double(max(last - waist, 1))
            rings.append(GRing(center: SIMD3(0, h - p.y, 0), a: widest + 2.5 * t * t, b: deepest + 1.5 * t * t))
        }
        return [tube(rings, segments: segments, role: .shell, topCap: nil)]
    }

    /// A pair of shoes around the feet: an upper from the sole to `top` (fraction of height, floor up)
    /// and a separate sole. `length` is half the shoe length as a fraction of height.
    static func shoes(_ rig: BodyRig, _ form: GarmentForm, top: Double, length: Double, segments: Int) -> [Piece] {
        let h = rig.h
        guard let foot = rig.legRings.last, rig.legRings.count >= 2 else { return [] }
        let ankle = rig.legRings[rig.legRings.count - 2]
        let e = ease(form)
        let w = max(foot.a * 1.3, ankle.a + e) + 0.5
        let l = length * h
        let cz = 0.022 * h
        let topY = top * h
        let slim: Double = form == .loafers ? 0.9 : 1
        var rings = [GRing(center: SIMD3(foot.center.x, 0.012 * h, cz), a: w * slim, b: l)]
        rings.append(GRing(center: SIMD3(foot.center.x, 0.026 * h, cz - 0.004 * h), a: w * 0.96 * slim, b: l * 0.9))
        if topY > 0.06 * h {
            // Boot shaft: up the ankle.
            rings.append(GRing(center: SIMD3(ankle.center.x, 0.05 * h, 0.004 * h), a: ankle.a + e + 0.9, b: ankle.b + e + 1.1))
        }
        rings.append(GRing(center: SIMD3(ankle.center.x, topY, 0), a: ankle.a + e + 0.6, b: ankle.b + e + 0.7))
        let upper = tube(rings.reversed(), segments: segments, role: .shell, topCap: SIMD3(ankle.center.x, topY + 0.002 * h, 0))
        let soleRings = [GRing(center: SIMD3(foot.center.x, 0.0135 * h, cz), a: w * slim + 0.3, b: l + 0.3),
                         GRing(center: SIMD3(foot.center.x, 0.0005 * h, cz), a: w * slim + 0.3, b: l + 0.3)]
        let sole = tube(soleRings, segments: segments, role: .sole,
                        topCap: SIMD3(foot.center.x, 0.0136 * h, cz), bottomCap: SIMD3(foot.center.x, 0, cz))
        return [upper, upper.mirrored(), sole, sole.mirrored()]
    }

    /// A belt at the waistband with a buckle on the centre front.
    static func belt(_ rig: BodyRig, segments: Int) -> [Piece] {
        let h = rig.h
        let waist = rig.outlineIndex(atFraction: 0.40)
        let r = rig.torsoRings[waist]
        let e = ease(.trousers) + 0.5
        let band = [GRing(center: r.center - SIMD3(0, 0.002 * h, 0), a: r.a + e, b: r.b + e),
                    GRing(center: r.center - SIMD3(0, 0.019 * h, 0), a: r.a + e, b: r.b + e)]
        let buckle = box(center: SIMD3(0, r.center.y - 0.0105 * h, r.b + e + 0.35), half: SIMD3(0.012 * h, 0.011 * h, 0.25), role: .hardware)
        return [tube(band, segments: segments, role: .shell), buckle]
    }

    /// A tote in the right hand: two handles from the hand down to a bag hanging beside the leg,
    /// its broad faces parallel to the body's side so it never cuts through the hip.
    static func tote(_ rig: BodyRig, segments: Int) -> [Piece] {
        let h = rig.h
        let hand = rig.arm.point(0.93)
        let half = SIMD3(0.022 * h, 0.075 * h, 0.085 * h)
        let top = hand.y - 0.055 * h
        let center = SIMD3(hand.x + 0.012 * h, top - half.y, 0.006 * h)
        var pieces = [box(center: center, half: half, role: .shell)]
        for dz in [-0.045 * h, 0.045 * h] {
            // Handle: an arch in the y-z plane from the bag's top edge up over the hand.
            var path: [SIMD3<Double>] = []
            for k in 0...10 {
                let a = Double.pi * Double(k) / 10
                path.append(SIMD3(center.x, top + sin(a) * (hand.y - top + 0.012 * h), center.z + dz * cos(a)))
            }
            pieces.append(strap(path, radius: 0.0045 * h, side: SIMD3(1, 0, 0), segments: 8, role: .trim))
        }
        return pieces
    }

    /// A scarf: a wrap round the neck and two ends hanging down the front, outside any coat.
    static func scarf(_ rig: BodyRig, segments: Int) -> [Piece] {
        let h = rig.h
        let neck = rig.outlineIndex(atFraction: 0.13)
        let low = rig.outlineIndex(atFraction: 0.165)
        let outer = ease(.coat) + 1.0
        let wrap = [GRing(center: SIMD3(0, h - rig.outline[neck].y + 0.008 * h, 0), a: rig.outline[neck].x + 2.4, b: rig.depths[neck] + 2.4),
                    GRing(center: SIMD3(0, h - rig.outline[low].y, 0), a: rig.outline[low].x + outer, b: rig.depths[low] + outer)]
        var pieces = [tube(wrap, segments: segments, role: .shell, topCap: nil)]
        let chest = rig.outlineIndex(atFraction: 0.27)
        let z = rig.zShift[chest] + rig.depths[chest] + outer + 0.5
        for (x, f) in [(-0.028 * h, 0.36), (0.022 * h, 0.40)] {
            let end = rig.outlineIndex(atFraction: f)
            let path = [SIMD3(x, h - rig.outline[low].y, z - 1.0), SIMD3(x, h - rig.outline[end].y, z)]
            pieces.append(ribbon(path, halfWidth: 0.026 * h, normal: SIMD3(0, 0, 1), role: .shell, thickness: 0.5))
        }
        return pieces
    }

    // MARK: Surface helpers

    /// An elliptical ring with explicit cross-section axes (`u` sideways, `v` front-back by default).
    struct GRing {
        var center: SIMD3<Double>
        var a: Double
        var b: Double
        var u = SIMD3<Double>(1, 0, 0)
        var v = SIMD3<Double>(0, 0, 1)
    }

    /// Rings → a tube, optionally closed at either end. Faces point away from the ring axis.
    static func tube(_ rings: [GRing], segments: Int, role: Role, topCap: SIMD3<Double>? = nil, bottomCap: SIMD3<Double>? = nil) -> Piece {
        var positions: [SIMD3<Double>] = []
        for ring in rings {
            for s in 0..<segments {
                let theta = 2 * Double.pi * Double(s) / Double(segments)
                positions.append(ring.center + ring.u * (ring.a * cos(theta)) + ring.v * (ring.b * sin(theta)))
            }
        }
        var indices: [UInt32] = []
        let S = UInt32(segments)
        for r in 0..<UInt32(rings.count - 1) {
            for s in 0..<S {
                let v00 = r * S + s, v01 = r * S + (s + 1) % S
                let v10 = (r + 1) * S + s, v11 = (r + 1) * S + (s + 1) % S
                indices += [v00, v01, v10, v01, v11, v10]
            }
        }
        if let topCap {
            let c = UInt32(positions.count)
            positions.append(topCap)
            for s in 0..<S { indices += [c, (s + 1) % S, s] }
        }
        if let bottomCap {
            let c = UInt32(positions.count)
            positions.append(bottomCap)
            let last = UInt32(rings.count - 1) * S
            for s in 0..<S { indices += [c, last + s, last + (s + 1) % S] }
        }
        return Piece(role: role, positions: positions.map { SIMD3<Float>($0) }, normals: BodyMesh.smoothNormals(positions, indices), indices: indices)
    }

    /// A round strap along a path; `side` is any direction not parallel to the path.
    static func strap(_ path: [SIMD3<Double>], radius: Double, side: SIMD3<Double>, segments: Int, role: Role) -> Piece {
        var rings: [GRing] = []
        for (k, p) in path.enumerated() {
            let a = path[max(k - 1, 0)], b = path[min(k + 1, path.count - 1)]
            let t = normalize(b - a)
            let u = normalize(side - t * dot(side, t))
            rings.append(GRing(center: p, a: radius, b: radius, u: u, v: normalize(cross(t, u))))
        }
        return tube(rings, segments: segments, role: role, topCap: path.first, bottomCap: path.last)
    }

    /// A flat band along a path, facing `normal`, as a thin closed slab.
    static func ribbon(_ path: [SIMD3<Double>], halfWidth: Double, normal: SIMD3<Double>, role: Role, thickness: Double = 0.15) -> Piece {
        var rings: [GRing] = []
        for (k, p) in path.enumerated() {
            let a = path[max(k - 1, 0)], b = path[min(k + 1, path.count - 1)]
            let t = normalize(b - a)
            let u = normalize(cross(normal, t))
            rings.append(GRing(center: p, a: halfWidth, b: thickness, u: u, v: normalize(cross(t, u))))
        }
        return tube(rings, segments: 8, role: role, topCap: path.first, bottomCap: path.last)
    }

    /// A small flat disc facing +z (a button).
    static func disc(center: SIMD3<Double>, radius: Double, role: Role) -> Piece {
        let rings = [GRing(center: center - SIMD3(0, 0, 0.12), a: radius, b: radius, u: SIMD3(1, 0, 0), v: SIMD3(0, 1, 0)),
                     GRing(center: center, a: radius, b: radius, u: SIMD3(1, 0, 0), v: SIMD3(0, 1, 0))]
        return tube(rings, segments: 10, role: role, topCap: center - SIMD3(0, 0, 0.12), bottomCap: center + SIMD3(0, 0, 0.05))
    }

    /// An axis-aligned box with flat faces.
    static func box(center c: SIMD3<Double>, half: SIMD3<Double>, role: Role) -> Piece {
        let faces: [(n: SIMD3<Double>, u: SIMD3<Double>, v: SIMD3<Double>)] = [
            (SIMD3(1, 0, 0), SIMD3(0, 1, 0), SIMD3(0, 0, 1)), (SIMD3(-1, 0, 0), SIMD3(0, 0, 1), SIMD3(0, 1, 0)),
            (SIMD3(0, 1, 0), SIMD3(0, 0, 1), SIMD3(1, 0, 0)), (SIMD3(0, -1, 0), SIMD3(1, 0, 0), SIMD3(0, 0, 1)),
            (SIMD3(0, 0, 1), SIMD3(1, 0, 0), SIMD3(0, 1, 0)), (SIMD3(0, 0, -1), SIMD3(0, 1, 0), SIMD3(1, 0, 0)),
        ]
        var positions: [SIMD3<Float>] = [], normals: [SIMD3<Float>] = [], indices: [UInt32] = []
        for f in faces {
            let base = UInt32(positions.count)
            let o = c + f.n * half
            let du = f.u * half, dv = f.v * half
            for p in [o - du - dv, o + du - dv, o + du + dv, o - du + dv] {
                positions.append(SIMD3<Float>(p))
                normals.append(SIMD3<Float>(f.n))
            }
            indices += [base, base + 1, base + 2, base, base + 2, base + 3]
        }
        return Piece(role: role, positions: positions, normals: normals, indices: indices)
    }
}

extension GarmentMesh.Piece {
    /// Mirror across x = 0, reversing triangle order so faces keep pointing outwards.
    func mirrored() -> GarmentMesh.Piece {
        var flipped: [UInt32] = []
        flipped.reserveCapacity(indices.count)
        for t in stride(from: 0, to: indices.count, by: 3) { flipped += [indices[t], indices[t + 2], indices[t + 1]] }
        return GarmentMesh.Piece(role: role, positions: positions.map { SIMD3(-$0.x, $0.y, $0.z) },
                                 normals: normals.map { SIMD3(-$0.x, $0.y, $0.z) }, indices: flipped)
    }

    func scaled(_ k: Float) -> GarmentMesh.Piece {
        GarmentMesh.Piece(role: role, positions: positions.map { $0 * k }, normals: normals, indices: indices)
    }
}

private func normalize(_ v: SIMD3<Double>) -> SIMD3<Double> {
    let l = (v * v).sum().squareRoot()
    return l > 0 ? v / l : SIMD3(0, 1, 0)
}

private func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double { (a * b).sum() }

private func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
    SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}

private func cross(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> SIMD3<Float> {
    SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}
