import BodyGeometry
import Foundation

/// Body cross-sections read back from a `BodyMesh`'s own vertices (metres, the mesh's axes: y up from the
/// floor, x to the viewer's right, z towards the viewer). Torso and leg rings in `BodyMesh` are
/// horizontal, so vertices sharing one y form one ring; the arm is a tilted tube, read by its main axis.
/// Working from the public mesh keeps the body's internal rig private and guarantees the garment wraps
/// the exact surface that is drawn.
public struct BodyEnvelope: Sendable {
    /// An ellipse in the horizontal plane: centre (x, z) and semi-axes along x (`a`) and z (`b`), metres.
    public struct Section: Hashable, Sendable {
        public let centerX: Double
        public let centerZ: Double
        public let a: Double
        public let b: Double
        /// Girth of the body itself here: the convex-hull perimeter of the body's points (a tape measure
        /// round everything at this height). The ellipse holds the body, so its perimeter is ≥ this.
        public let bodyPerimeter: Double

        /// Ramanujan's second approximation; within a few parts per million for body-like ellipses.
        public var perimeter: Double { ellipsePerimeter(a, b) }

        /// ≥ 1 on or outside the ellipse.
        public func level(x: Double, z: Double) -> Double {
            let u = (x - centerX) / a, v = (z - centerZ) / b
            return (u * u + v * v).squareRoot()
        }
    }

    /// The right arm's straight axis: from the shoulder end (`joint`) towards the hand.
    public struct Arm: Sendable {
        public let joint: SIMD3<Double>
        public let axis: SIMD3<Double>
        /// Perpendicular to the axis in the x-y plane, pointing away from the body.
        public let side: SIMD3<Double>
        public let length: Double
        /// (distance along the axis, distance from it) for every arm vertex, sorted by distance.
        let profile: [(t: Double, r: Double)]

        /// Largest arm radius within 1.5 cm of `t` along the axis.
        public func radius(at t: Double) -> Double {
            let near = profile.filter { abs($0.t - t) <= 0.015 }
            if let r = near.map(\.r).max() { return r }
            return profile.min { abs($0.t - t) < abs($1.t - t) }?.r ?? 0
        }
    }

    struct Slice {
        let y: Double
        let points: [SIMD2<Double>]
    }

    public let heightM: Double
    let torso: [Slice]
    let rightLeg: [Slice]
    let leftLeg: [Slice]
    public let arm: Arm
    /// Lowest leg ring above the foot (m): the ankle. Garments are not drawn below it.
    public let ankleY: Double

    public init(_ body: BodyMesh) throws(PatternError) {
        guard let torso = body.piece(.torso), let rl = body.piece(.rightLeg), let ll = body.piece(.leftLeg),
              let ra = body.piece(.rightArm) else { throw .invalidGeometry("body mesh parts") }
        heightM = Double(body.heightM)
        self.torso = Self.slices(torso.positions)
        rightLeg = Self.slices(rl.positions)
        leftLeg = Self.slices(ll.positions)
        guard self.torso.count >= 4, rightLeg.count >= 3 else { throw .invalidGeometry("body rings") }
        ankleY = rightLeg[rightLeg.count - 2].y
        arm = try Self.arm(ra.positions)
    }

    /// Horizontal rings: vertices grouped by exact y, top first. Cap vertices (alone at their y) drop out.
    static func slices(_ positions: [SIMD3<Float>]) -> [Slice] {
        let sorted = positions.sorted { $0.y != $1.y ? $0.y > $1.y : ($0.x != $1.x ? $0.x < $1.x : $0.z < $1.z) }
        var out: [Slice] = []
        var i = 0
        while i < sorted.count {
            var j = i
            while j < sorted.count, sorted[j].y == sorted[i].y { j += 1 }
            if j - i >= 6 { out.append(Slice(y: Double(sorted[i].y), points: sorted[i..<j].map { SIMD2(Double($0.x), Double($0.z)) })) }
            i = j
        }
        return out
    }

    /// Points of the two rings bracketing `y`, or none when `y` is outside this part. The surface between
    /// two rings is made of straight segments, so any ellipse containing both rings contains it too.
    static func bracket(_ s: [Slice], _ y: Double) -> [SIMD2<Double>] {
        guard let top = s.first, let bottom = s.last, y <= top.y + 1e-9, y >= bottom.y - 1e-9 else { return [] }
        for k in 0..<(s.count - 1) where y <= s[k].y && y >= s[k + 1].y { return s[k].points + s[k + 1].points }
        return top.points
    }

    /// The axis-aligned ellipse of least perimeter, centred on the points' box, that holds every point.
    /// For a width a' ≥ the widest point, the depth needed is max |dz| / √(1 − (dx / a')²); the perimeter
    /// over a' is searched by golden section (deterministic, 48 steps). Two legs side by side get a
    /// wide, shallow ellipse instead of a uniformly blown-up one.
    static func fit(_ pts: [SIMD2<Double>], symmetric: Bool) -> Section? {
        guard !pts.isEmpty else { return nil }
        var lo = SIMD2<Double>(repeating: .infinity), hi = SIMD2<Double>(repeating: -.infinity)
        for p in pts {
            lo = pointwiseMin(lo, p)
            hi = pointwiseMax(hi, p)
        }
        let cx = symmetric ? 0 : (lo.x + hi.x) / 2, cz = (lo.y + hi.y) / 2
        let a = max(pts.map { abs($0.x - cx) }.max() ?? 0, 1e-3)
        func depth(_ wide: Double) -> Double {
            var b = 1e-3
            for p in pts {
                let u = (p.x - cx) / wide
                b = max(b, abs(p.y - cz) / max(1 - u * u, 1e-12).squareRoot())
            }
            return b
        }
        func cost(_ s: Double) -> Double { ellipsePerimeter(a * s, depth(a * s)) }
        let g = (5.0.squareRoot() - 1) / 2
        var l = 1.0005, r = 3.0
        var m1 = r - g * (r - l), m2 = l + g * (r - l)
        var c1 = cost(m1), c2 = cost(m2)
        for _ in 0..<48 {
            if c1 <= c2 {
                r = m2; m2 = m1; c2 = c1
                m1 = r - g * (r - l); c1 = cost(m1)
            } else {
                l = m1; m1 = m2; c1 = c2
                m2 = l + g * (r - l); c2 = cost(m2)
            }
        }
        let s = (l + r) / 2
        return Section(centerX: cx, centerZ: cz, a: a * s, b: depth(a * s), bodyPerimeter: hullPerimeter(pts))
    }

    /// Convex hull perimeter (monotone chain).
    static func hullPerimeter(_ pts: [SIMD2<Double>]) -> Double {
        let p = pts.sorted { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }
        guard p.count >= 3 else { return 0 }
        func turn(_ o: SIMD2<Double>, _ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x) }
        var hull: [SIMD2<Double>] = []
        for q in p {
            while hull.count >= 2, turn(hull[hull.count - 2], hull[hull.count - 1], q) <= 0 { hull.removeLast() }
            hull.append(q)
        }
        let lower = hull.count + 1
        for q in p.reversed().dropFirst() {
            while hull.count >= lower, turn(hull[hull.count - 2], hull[hull.count - 1], q) <= 0 { hull.removeLast() }
            hull.append(q)
        }
        hull.removeLast()
        var s = 0.0
        for i in hull.indices {
            let d = hull[(i + 1) % hull.count] - hull[i]
            s += (d * d).sum().squareRoot()
        }
        return s
    }

    /// Everything the torso of a garment must enclose at height `y`: the torso and, where they are, both
    /// legs. Centred on x = 0 (the body is symmetric). Clamped to the nearest ring outside the body.
    public func torsoSection(atY y: Double) -> Section {
        let yc = min(max(y, ankleY), torso[0].y)
        let pts = Self.bracket(torso, yc) + Self.bracket(rightLeg, yc) + Self.bracket(leftLeg, yc)
        return Self.fit(pts, symmetric: true) ?? Section(centerX: 0, centerZ: 0, a: 0.05, b: 0.05, bodyPerimeter: 0)
    }

    /// The right leg alone at height `y` (for trouser legs). Above the leg's top ring, the top ring.
    public func legSection(atY y: Double) -> Section {
        let yc = min(max(y, ankleY), rightLeg[0].y)
        return Self.fit(Self.bracket(rightLeg, yc), symmetric: false) ?? Section(centerX: 0.08, centerZ: 0, a: 0.05, b: 0.05, bodyPerimeter: 0)
    }

    /// Main axis of the arm vertices (power iteration on their covariance, starting straight down, so
    /// the result is deterministic); the shoulder end is the vertex furthest up the axis.
    static func arm(_ positions: [SIMD3<Float>]) throws(PatternError) -> Arm {
        let pts = positions.map { SIMD3<Double>($0) }
        guard pts.count >= 8 else { throw .invalidGeometry("arm") }
        var c = SIMD3<Double>.zero
        for p in pts { c += p }
        c /= Double(pts.count)
        var m = [SIMD3<Double>](repeating: .zero, count: 3)
        for p in pts {
            let d = p - c
            m[0] += d * d.x
            m[1] += d * d.y
            m[2] += d * d.z
        }
        var v = SIMD3<Double>(0, -1, 0)
        for _ in 0..<64 {
            let w = m[0] * v.x + m[1] * v.y + m[2] * v.z
            let l = (w * w).sum().squareRoot()
            guard l > 0 else { break }
            v = w / l
        }
        if v.y > 0 { v = -v }
        let ts = pts.map { ((($0 - c) * v).sum()) }
        let t0 = ts.min() ?? 0, t1 = ts.max() ?? 0
        let joint = c + v * t0
        let side3 = SIMD3<Double>(-v.y, v.x, 0) // cross(z, axis): in the x-y plane, outwards for the right arm
        let sl = (side3 * side3).sum().squareRoot()
        let side = sl > 0 ? side3 / sl : SIMD3(1, 0, 0)
        var profile: [(t: Double, r: Double)] = []
        for (p, t) in zip(pts, ts) {
            let d = p - (joint + v * (t - t0))
            profile.append((t - t0, (d * d).sum().squareRoot()))
        }
        profile.sort { $0.t != $1.t ? $0.t < $1.t : $0.r < $1.r }
        return Arm(joint: joint, axis: v, side: side, length: t1 - t0, profile: profile)
    }
}

func ellipsePerimeter(_ a: Double, _ b: Double) -> Double {
    .pi * (3 * (a + b) - ((3 * a + b) * (a + 3 * b)).squareRoot())
}
