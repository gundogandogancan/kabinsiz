import Foundation

/// The neutral 3D body (ADR-007): an original, procedural, covered, faceless mesh built only from an
/// `AvatarSnapshot`. Torso and head are lofted elliptical rings along the silhouette; legs and arms are
/// separate closed tubes. Nothing is downloaded or licensed: every vertex comes from the formulas below,
/// so every reachable body can be validated by tests (V19-T-023..025, same approach as BOD-02).
///
/// Coordinates are metres, y up from the floor, x to the viewer's right, z towards the viewer. The front
/// half-width of every torso ring and the outer edge of the legs equal the 2D silhouette exactly, so the
/// 2D fallback and the 3D view describe the same body (ADR-007 §3). Arms are neutral (no arm measurement
/// exists yet) and hang in a slight A-pose that clears the hips.
public struct BodyMesh: Codable, Hashable, Sendable {
    public enum Part: String, Codable, CaseIterable, Sendable {
        case torso, leftLeg, rightLeg, leftArm, rightArm
    }

    /// One closed, watertight surface. Triangles are counter-clockwise seen from outside.
    public struct Piece: Codable, Hashable, Sendable {
        public let part: Part
        public let positions: [SIMD3<Float>]
        public let normals: [SIMD3<Float>]
        public let indices: [UInt32]
    }

    /// Ring resolution. `standard` for the 3D tier; `low` keeps the same shape with fewer triangles.
    public enum Detail: Int, Codable, Sendable {
        case low = 16, standard = 40
    }

    public let bodyRevision: Int
    public let heightM: Float
    public let pieces: [Piece]

    public var triangleCount: Int { pieces.reduce(0) { $0 + $1.indices.count / 3 } }

    public func piece(_ part: Part) -> Piece? { pieces.first { $0.part == part } }

    // MARK: Proportions (neutral hypotheses, not measurements)

    /// Torso cross-section depth ÷ front half-width for a circumference-derived width: the silhouette uses
    /// half-width = C / 5.2, and the ellipse with that semi-axis whose Ramanujan perimeter is C has this
    /// ratio. Solved numerically once, so 2D width and 3D girth agree.
    public static let girthDepthRatio: Double = solveDepthRatio(widthToCircumference: 1 / 5.2)

    /// Where the legs separate, as a fraction of height (between hip 0.50 and thigh 0.60).
    static let crotchFraction = 0.53
    /// Rings below the crotch over which the torso narrows inside the legs.
    static let tuckRings = 5
    /// Clear space between the legs, as a fraction of height: almost touching at the crotch, a natural
    /// stance at the ankles.
    static func legGap(_ fraction: Double) -> Double {
        let t = max(0, min(1, (fraction - crotchFraction) / (Silhouette.Station.ankle.heightFraction - crotchFraction)))
        return 0.004 + (0.02 - 0.004) * t
    }
    /// Arm length from shoulder joint to the end of the (mitten) hand, as a fraction of height.
    static let armLengthFraction = 0.40
    /// Arm radius along its length (shoulder, elbow, wrist, hand), as fractions of height.
    static let armRadii: [(t: Double, r: Double)] = [(0, 0.024), (0.45, 0.018), (0.78, 0.0135), (0.88, 0.016), (0.96, 0.0145), (1, 0.004)]
    /// Space kept between an arm and the hips.
    static let armClearanceFraction = 0.01

    // MARK: Build

    public static func make(from snapshot: AvatarSnapshot, detail: Detail = .standard) throws(BodyEditError) -> BodyMesh {
        let rig = try BodyRig(snapshot.silhouette)
        let h = rig.h
        let segments = detail.rawValue
        let torsoBottom = rig.torsoRings.last!.center.y - 0.006 * h
        let torso = loft(.torso, rig.torsoRings, segments: segments, topCap: SIMD3(0, h, 0), bottomCap: SIMD3(0, torsoBottom, 0))
        let legRings = rig.legRings
        let rightLeg = loft(.rightLeg, legRings, segments: segments, topCap: legRings[0].center + SIMD3(0, 0.01 * h, 0),
                            bottomCap: SIMD3(legRings.last!.center.x, 0, legRings.last!.center.z))
        let arm = rig.arm
        let rightArm = loft(.rightArm, rig.armRings, segments: max(segments / 2, 12),
                            topCap: arm.joint - arm.axis * (0.01 * h),
                            bottomCap: arm.joint + arm.axis * (arm.length + 0.006 * h))

        let pieces = [torso, rightLeg.mirrored(as: .leftLeg), rightLeg, rightArm.mirrored(as: .leftArm), rightArm]
            .map { $0.scaled(0.01) } // cm → m
        let mesh = BodyMesh(bodyRevision: snapshot.bodyRevision, heightM: Float(h * 0.01), pieces: pieces)
        try mesh.validate()
        return mesh
    }

    // MARK: Validation

    /// Structural safety for every reachable body: finite numbers, indices in range, no degenerate
    /// triangle, every piece closed (each directed edge appears once, its reverse once), outward-facing
    /// (positive signed volume), unit normals, and inside the body's height.
    public func validate() throws(BodyEditError) {
        guard heightM.isFinite, heightM > 0, pieces.count == Part.allCases.count else { throw .unsafeGeometry("mesh-empty") }
        for piece in pieces {
            let n = piece.positions.count
            guard n >= 4, piece.normals.count == n, piece.indices.count >= 12, piece.indices.count % 3 == 0 else { throw .unsafeGeometry("mesh-shape") }
            for (p, nrm) in zip(piece.positions, piece.normals) {
                guard p.x.isFinite, p.y.isFinite, p.z.isFinite else { throw .unsafeGeometry("mesh-nan") }
                guard p.y >= -0.001, p.y <= heightM + 0.001 else { throw .unsafeGeometry("mesh-height") }
                let len = (nrm * nrm).sum().squareRoot()
                guard abs(len - 1) < 0.01 else { throw .unsafeGeometry("mesh-normal") }
            }
            var edges = Set<UInt64>()
            var volume: Double = 0
            for t in stride(from: 0, to: piece.indices.count, by: 3) {
                let i = piece.indices[t], j = piece.indices[t + 1], k = piece.indices[t + 2]
                guard Int(i) < n, Int(j) < n, Int(k) < n, i != j, j != k, i != k else { throw .unsafeGeometry("mesh-index") }
                let a = SIMD3<Double>(piece.positions[Int(i)]), b = SIMD3<Double>(piece.positions[Int(j)]), c = SIMD3<Double>(piece.positions[Int(k)])
                let cr = cross(b - a, c - a)
                guard (cr * cr).sum() > 1e-16 else { throw .unsafeGeometry("mesh-degenerate") }
                volume += (a * cross(b, c)).sum() / 6
                for (x, y) in [(i, j), (j, k), (k, i)] {
                    guard edges.insert(UInt64(x) << 32 | UInt64(y)).inserted else { throw .unsafeGeometry("mesh-edge") }
                }
            }
            for e in edges where !edges.contains((e & 0xFFFF_FFFF) << 32 | e >> 32) { throw .unsafeGeometry("mesh-open") }
            guard volume > 0 else { throw .unsafeGeometry("mesh-inside-out") }
        }
    }

    // MARK: Helpers

    struct Ring {
        var center: SIMD3<Double>
        /// Semi-axis along `u` (front half-width for torso and legs) and along z (depth).
        var a: Double
        var b: Double
        var u: SIMD3<Double>
    }

    /// Depth (cm) at every outline sample, from station depths smoothed like the outline itself.
    static func depthProfile(_ shape: Silhouette) -> [Double] {
        let w = shape.halfWidthsCm
        let r = girthDepthRatio
        let chestDepth = (w[.chest] ?? 0) * r
        let depth: [Silhouette.Station: Double] = [
            .crown: (w[.crown] ?? 0) * 1.1,
            .headWidest: (w[.headWidest] ?? 0) * 1.18,
            .neck: (w[.neck] ?? 0) * 1.0,
            .shoulder: chestDepth * 0.82,
            .chest: chestDepth,
            .waist: (w[.waist] ?? 0) * r,
            .hip: (w[.hip] ?? 0) * r,
            .thigh: (w[.thigh] ?? 0) * 0.55,
            .knee: (w[.knee] ?? 0) * 0.5,
            .ankle: (w[.ankle] ?? 0) * 0.5,
        ]
        let anchors = Silhouette.Station.allCases.map { Silhouette.Point(x: depth[$0]!, y: $0.heightFraction * shape.heightCm) }
        // The head is rounded front to back exactly as it is side to side (no pointed crown in profile).
        return Silhouette.roundedHead(Silhouette.smooth(anchors, samplesPerSegment: 8), crown: depth[.crown]!, widest: depth[.headWidest]!,
                                      widestY: Silhouette.Station.headWidest.heightFraction * shape.heightCm).map(\.x)
    }

    /// Legs are slightly deeper than wide at the thigh and calf, rounder at the knee and ankle.
    static func legDepthRatio(_ fraction: Double) -> Double {
        fraction < 0.74 ? 1.08 : 1.0
    }

    static func armRadius(at t: Double) -> Double {
        for (lo, hi) in zip(armRadii, armRadii.dropFirst()) where t <= hi.t {
            let f = (t - lo.t) / (hi.t - lo.t)
            let s = f * f * (3 - 2 * f) // smoothstep: no kinks at elbow or wrist
            return lo.r + (hi.r - lo.r) * s
        }
        return armRadii.last!.r
    }

    /// From the elbow down, the arm's inner surface stays outside the torso outline (the upper arm may rest
    /// against the chest, as real arms do). Smallest tilt from 8° that achieves it, at most 30°; if even 30°
    /// is not enough (a chest much wider than the shoulders), the whole arm moves out by the remaining gap.
    static let elbowFraction = 0.45

    static func armPlacement(shape: Silhouette, jointX: Double, jointY: Double) -> (tilt: Double, jointX: Double) {
        let h = shape.heightCm
        let length = armLengthFraction * h
        let clearance = armClearanceFraction * h
        func deficit(_ tilt: Double, _ x0: Double) -> Double {
            var worst = 0.0
            for k in 0...16 {
                let t = elbowFraction + (1 - elbowFraction) * Double(k) / 16
                let y = jointY - cos(tilt) * t * length
                let x = x0 + sin(tilt) * t * length
                let inner = x - armRadius(at: t) * h / cos(tilt)
                worst = max(worst, halfWidth(shape, atDepthFromCrown: h - y) + clearance - inner)
            }
            return worst
        }
        var tilt = 8.0 * .pi / 180
        while tilt < 30 * .pi / 180, deficit(tilt, jointX) > 0 { tilt += 0.5 * .pi / 180 }
        return (tilt, jointX + max(deficit(tilt, jointX), 0))
    }

    /// Silhouette half-width at a distance from the crown, by linear interpolation of the outline.
    static func halfWidth(_ shape: Silhouette, atDepthFromCrown y: Double) -> Double {
        let o = shape.rightOutline
        guard let j = o.firstIndex(where: { $0.y >= y }) else { return o.last?.x ?? 0 }
        guard j > 0 else { return o[0].x }
        let p = o[j - 1], q = o[j]
        let f = (y - p.y) / max(q.y - p.y, 1e-9)
        return p.x + (q.x - p.x) * f
    }

    static func solveDepthRatio(widthToCircumference k: Double) -> Double {
        // Perimeter of an ellipse with semi-axes 1 and r (Ramanujan II) must equal 1 / k.
        func perimeter(_ r: Double) -> Double { .pi * (3 * (1 + r) - ((3 + r) * (1 + 3 * r)).squareRoot()) }
        var lo = 0.1, hi = 1.0
        for _ in 0..<60 {
            let mid = (lo + hi) / 2
            if perimeter(mid) < 1 / k { lo = mid } else { hi = mid }
        }
        return (lo + hi) / 2
    }

    /// Rings → closed surface with caps. Vertex `r * segments + s`; caps are the last two vertices.
    static func loft(_ part: Part, _ rings: [Ring], segments: Int, topCap: SIMD3<Double>, bottomCap: SIMD3<Double>) -> Piece {
        var positions: [SIMD3<Double>] = []
        let z = SIMD3<Double>(0, 0, 1)
        for ring in rings {
            for s in 0..<segments {
                let theta = 2 * Double.pi * Double(s) / Double(segments)
                positions.append(ring.center + ring.u * (ring.a * cos(theta)) + z * (ring.b * sin(theta)))
            }
        }
        let top = UInt32(positions.count)
        positions.append(topCap)
        let bottom = UInt32(positions.count)
        positions.append(bottomCap)
        var indices: [UInt32] = []
        let S = UInt32(segments)
        for r in 0..<UInt32(rings.count - 1) {
            for s in 0..<S {
                let v00 = r * S + s, v01 = r * S + (s + 1) % S
                let v10 = (r + 1) * S + s, v11 = (r + 1) * S + (s + 1) % S
                indices += [v00, v01, v10, v01, v11, v10]
            }
        }
        let last = UInt32(rings.count - 1) * S
        for s in 0..<S {
            indices += [top, (s + 1) % S, s]
            indices += [bottom, last + s, last + (s + 1) % S]
        }
        return Piece(part: part, positions: positions.map { SIMD3<Float>($0) }, normals: smoothNormals(positions, indices), indices: indices)
    }

    /// Area-weighted vertex normals. Every vertex belongs to at least one non-degenerate triangle.
    static func smoothNormals(_ p: [SIMD3<Double>], _ idx: [UInt32]) -> [SIMD3<Float>] {
        var acc = [SIMD3<Double>](repeating: .zero, count: p.count)
        for t in stride(from: 0, to: idx.count, by: 3) {
            let i = Int(idx[t]), j = Int(idx[t + 1]), k = Int(idx[t + 2])
            let n = cross(p[j] - p[i], p[k] - p[i])
            acc[i] += n
            acc[j] += n
            acc[k] += n
        }
        return acc.map { v in
            let len = (v * v).sum().squareRoot()
            return SIMD3<Float>(len > 0 ? v / len : SIMD3(0, 1, 0))
        }
    }
}

extension BodyMesh.Piece {
    /// Mirror across x = 0. Mirroring flips handedness, so each triangle's order is reversed to stay
    /// counter-clockwise from outside.
    func mirrored(as part: BodyMesh.Part) -> BodyMesh.Piece {
        var flipped: [UInt32] = []
        flipped.reserveCapacity(indices.count)
        for t in stride(from: 0, to: indices.count, by: 3) { flipped += [indices[t], indices[t + 2], indices[t + 1]] }
        return BodyMesh.Piece(part: part, positions: positions.map { SIMD3(-$0.x, $0.y, $0.z) },
                              normals: normals.map { SIMD3(-$0.x, $0.y, $0.z) }, indices: flipped)
    }

    func scaled(_ k: Float) -> BodyMesh.Piece {
        BodyMesh.Piece(part: part, positions: positions.map { $0 * k }, normals: normals, indices: indices)
    }
}

@inline(__always)
fileprivate func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
    SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}
