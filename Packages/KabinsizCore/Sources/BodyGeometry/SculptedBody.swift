import CryptoKit
import Foundation

/// The sculpted neutral body (ADR-010): a MakeHuman-derived human form from NAVER Anny (Apache-2.0
/// code, CC0 assets), baked offline by `scripts/avatar/bake_sculpted_body.py` into one neutral mesh
/// plus a handful of shape bases. On the phone nothing is downloaded and no model runs: the four
/// girths from the `AvatarSnapshot` are matched by mixing the bases (a tiny box-constrained least
/// squares), a smooth radial correction closes the last centimetres, and the result is scaled to the
/// height. Faceless egg head, arms down, no anatomical detail (v1.5 §108.3); appearance is never fit
/// evidence (v1.7 §3.2). If the resource is missing or damaged, `BodyMesh.best` falls back to the
/// procedural body (ADR-007), so the 3D tier never depends on this file.
public struct SculptedBodyBasis: Sendable {
    public static let formatVersion = 1

    public let vertexCount: Int
    public let triangleCount: Int
    let base: [SIMD3<Float>]
    let indices: [UInt32]
    /// One delta per basis, per vertex (metres, app frame: y up, z towards the viewer).
    let deltas: [[SIMD3<Float>]]
    let isArm: [Bool]
    let meta: Metadata

    struct Metadata: Decodable, Sendable {
        let formatVersion: Int
        let vertexCount: Int
        let triangleCount: Int
        let bases: [String]
        let deltaScales: [Double]
        let baseHeightM: Double
        let measures: [String]
        let baseMeasuresCm: [Double]
        let jacobianCm: [[Double]]
        let shoulderPair: [Int]
        let tapes: [String: [[Double]]]
        let tapeHeightFractions: [String: Double]
        let binarySHA256: String
    }

    /// The bundled basis, loaded once. nil if the resource is missing or fails any check.
    public static let shared: SculptedBodyBasis? = {
        guard let (json, binary) = bundledData() else { return nil }
        return try? SculptedBodyBasis(json: json, binary: binary)
    }()

    static func bundledData() -> (json: Data, binary: Data)? {
        guard let json = Bundle.module.url(forResource: "SculptedBody", withExtension: "json"),
              let bin = Bundle.module.url(forResource: "SculptedBody", withExtension: "bin"),
              let j = try? Data(contentsOf: json), let b = try? Data(contentsOf: bin) else { return nil }
        return (j, b)
    }

    /// Fails closed on anything unexpected: version, checksum, sizes, index range, finite values.
    public init(json: Data, binary: Data) throws(BodyEditError) {
        guard let meta = try? JSONDecoder().decode(Metadata.self, from: json) else { throw .unsafeGeometry("basis-meta") }
        guard meta.formatVersion == Self.formatVersion else { throw .unsafeGeometry("basis-version") }
        let digest = SHA256.hash(data: binary).map { String(format: "%02x", $0) }.joined()
        guard digest == meta.binarySHA256 else { throw .unsafeGeometry("basis-checksum") }
        let n = meta.vertexCount, t = meta.triangleCount, k = meta.bases.count
        guard n > 0, n <= Int(UInt16.max), t > 0, k > 0, meta.deltaScales.count == k,
              meta.baseMeasuresCm.count == 4, meta.measures.count == 4,
              meta.jacobianCm.count == 4, meta.jacobianCm.allSatisfy({ $0.count == k }),
              meta.shoulderPair.count == 2, meta.shoulderPair.allSatisfy({ (0..<n).contains($0) }),
              meta.baseHeightM > 0.5, meta.baseHeightM < 3,
              binary.count == n * 12 + t * 6 + k * n * 6 + n else { throw .unsafeGeometry("basis-size") }
        for name in SculptedBody.tapeNames {
            guard let tape = meta.tapes[name], tape.count >= 8, meta.tapeHeightFractions[name] != nil,
                  tape.allSatisfy({ $0.count == 3 && (0..<n).contains(Int($0[0])) && (0..<n).contains(Int($0[1])) && (0...1).contains($0[2]) })
            else { throw .unsafeGeometry("basis-tape") }
        }

        var base = [SIMD3<Float>](), indices = [UInt32](), deltas = [[SIMD3<Float>]](), arm = [Bool]()
        binary.withUnsafeBytes { raw in
            var o = 0
            func f32() -> Float { defer { o += 4 }; return Float(bitPattern: UInt32(littleEndian: raw.loadUnaligned(fromByteOffset: o, as: UInt32.self))) }
            func u16() -> UInt16 { defer { o += 2 }; return UInt16(littleEndian: raw.loadUnaligned(fromByteOffset: o, as: UInt16.self)) }
            func i16() -> Int16 { defer { o += 2 }; return Int16(littleEndian: raw.loadUnaligned(fromByteOffset: o, as: Int16.self)) }
            base = (0..<n).map { _ in SIMD3(f32(), f32(), f32()) }
            indices = (0..<(t * 3)).map { _ in UInt32(u16()) }
            deltas = meta.deltaScales.map { scale in
                let s = Float(scale)
                return (0..<n).map { _ in SIMD3(Float(i16()), Float(i16()), Float(i16())) * s }
            }
            arm = (0..<n).map { i in raw[o + i] != 0 }
        }
        guard base.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.z.isFinite }),
              indices.allSatisfy({ Int($0) < n }) else { throw .unsafeGeometry("basis-values") }

        self.vertexCount = n
        self.triangleCount = t
        self.base = base
        self.indices = indices
        self.deltas = deltas
        self.isArm = arm
        self.meta = meta
    }
}

/// The on-device half of ADR-010: solve, correct, scale. Pure and deterministic.
public enum SculptedBody {
    static let tapeNames = ["chest", "waist", "hip"]

    /// Largest weight per basis: measurement targets stay inside MakeHuman's authored range; the weight
    /// phenotype may extrapolate half again, which still reads as a natural fuller body.
    static func upperBound(_ name: String) -> Double { name == "weight+" ? 1.5 : 1 }
    /// Preference between bases that reach the same tapes: the weight phenotype first (it shapes the
    /// whole body naturally), then the measurement targets, then the plain scale targets.
    static func cost(_ name: String) -> Double {
        if name.hasPrefix("weight") { return 0.3 }
        if ["shoulder", "bust", "waist", "hips"].contains(where: { name.hasPrefix($0) }) { return 1 }
        return 2
    }
    static let regularisation = 4.0
    static let solverSweeps = 300
    /// The radial correction never scales a cross-section by more than this, so bodies far outside
    /// what the bases reach stay smooth; the remaining gap is reported by `measuredCm`.
    static let maxRadialCorrection = 0.25

    /// The four drawn girths behind a snapshot, in cm: shoulder width and the chest, waist and hip
    /// circumferences the silhouette was built from (inverse of `Silhouette.halfWidth`).
    public static func targetsCm(_ snapshot: AvatarSnapshot) -> [Double]? {
        let w = snapshot.silhouette.halfWidthsCm
        guard let s = w[.shoulder], let c = w[.chest], let wa = w[.waist], let h = w[.hip] else { return nil }
        return [s * 2, Silhouette.circumference(halfWidth: c), Silhouette.circumference(halfWidth: wa), Silhouette.circumference(halfWidth: h)]
    }

    /// Mixing weights for girth targets (cm) at the basis' own height: projected coordinate descent on
    /// ‖J w − r‖² + λ Σ cₖ wₖ², 0 ≤ wₖ ≤ upperₖ. Convex, so it converges to the one minimum.
    static func solve(_ basis: SculptedBodyBasis, residualCm r: [Double]) -> [Double] {
        let J = basis.meta.jacobianCm, names = basis.meta.bases, k = names.count
        var w = [Double](repeating: 0, count: k)
        let column = (0..<k).map { c in (0..<4).reduce(0) { $0 + J[$1][c] * J[$1][c] } + regularisation * cost(names[c]) }
        var fit = [Double](repeating: 0, count: 4) // J w
        for _ in 0..<solverSweeps {
            for c in 0..<k {
                var dot = 0.0
                for m in 0..<4 { dot += J[m][c] * (r[m] - fit[m] + J[m][c] * w[c]) }
                let next = min(max(dot / column[c], 0), upperBound(names[c]))
                if next != w[c] {
                    for m in 0..<4 { fit[m] += J[m][c] * (next - w[c]) }
                    w[c] = next
                }
            }
        }
        return w
    }

    /// Shoulder width and the three tape girths of `positions`, in cm (same definition as the baker).
    public static func measureCm(_ basis: SculptedBodyBasis, _ positions: [SIMD3<Float>]) -> [Double] {
        let a = SIMD3<Double>(positions[basis.meta.shoulderPair[0]]), b = SIMD3<Double>(positions[basis.meta.shoulderPair[1]])
        var out = [((a - b) * (a - b)).sum().squareRoot() * 100]
        for name in tapeNames {
            out.append(hullPerimeter(tapePoints(basis, name, positions).map { SIMD2($0.x, $0.z) }) * 100)
        }
        return out
    }

    static func tapePoints(_ basis: SculptedBodyBasis, _ name: String, _ p: [SIMD3<Float>]) -> [SIMD3<Double>] {
        (basis.meta.tapes[name] ?? []).map { e in
            let a = SIMD3<Double>(p[Int(e[0])]), b = SIMD3<Double>(p[Int(e[1])])
            return a + e[2] * (b - a)
        }
    }

    /// Convex hull perimeter: a tape measure pulled around the slice (Andrew's monotone chain).
    static func hullPerimeter(_ points: [SIMD2<Double>]) -> Double {
        let pts = points.sorted { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }
        guard pts.count >= 3 else { return 0 }
        func cross(_ o: SIMD2<Double>, _ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double {
            (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
        }
        var hull: [SIMD2<Double>] = []
        for p in pts {
            while hull.count >= 2, cross(hull[hull.count - 2], hull[hull.count - 1], p) <= 0 { hull.removeLast() }
            hull.append(p)
        }
        let lowerCount = hull.count + 1
        for p in pts.reversed().dropFirst() {
            while hull.count >= lowerCount, cross(hull[hull.count - 2], hull[hull.count - 1], p) <= 0 { hull.removeLast() }
            hull.append(p)
        }
        hull.removeLast()
        var length = 0.0
        for i in hull.indices {
            let d = hull[i] - hull[(i + 1) % hull.count]
            length += (d * d).sum().squareRoot()
        }
        return length
    }

    static func smoothstep(_ e0: Double, _ e1: Double, _ x: Double) -> Double {
        let t = min(max((x - e0) / (e1 - e0), 0), 1)
        return t * t * (3 - 2 * t)
    }

    /// Positions in metres, feet on y = 0, for a height and four girth targets.
    static func positions(_ basis: SculptedBodyBasis, heightCm: Double, targetsCm: [Double]) -> [SIMD3<Float>] {
        let h0 = basis.meta.baseHeightM
        let s0 = heightCm / 100 / h0
        let m0 = basis.meta.baseMeasuresCm
        let w = solve(basis, residualCm: (0..<4).map { targetsCm[$0] / s0 - m0[$0] })

        var v = basis.base
        for (c, weight) in w.enumerated() where weight > 0 {
            let d = basis.deltas[c], f = Float(weight)
            for i in v.indices { v[i] += d[i] * f }
        }

        // Exact height: scale by what the mix actually measures. The girth targets at that scale:
        var y0 = Double.infinity, y1 = -Double.infinity
        for p in v { y0 = min(y0, Double(p.y)); y1 = max(y1, Double(p.y)) }
        let height = y1 - y0
        let scale = heightCm / 100 / height
        let target = targetsCm.map { $0 / scale }
        let measured = measureCm(basis, v)

        // Radial correction about each tape's centre line, blended along the height: hip → waist →
        // chest, fading out towards the shoulders and down the thighs. Arms are not scaled; they
        // swing out from the shoulder by the largest widening beside them, so they never cut in.
        var knots: [(y: Double, a: Double, cz: Double, halfWidth: Double)] = []
        for (m, name) in [(3, "hip"), (2, "waist"), (1, "chest")] {
            let pts = tapePoints(basis, name, v)
            let a = measured[m] > 0 ? min(max(target[m] / measured[m] - 1, -maxRadialCorrection), maxRadialCorrection) : 0
            let cz = pts.reduce(0) { $0 + $1.z } / Double(max(pts.count, 1))
            let hw = pts.map { abs($0.x) }.max() ?? 0
            knots.append((y0 + (basis.meta.tapeHeightFractions[name] ?? 0.5) * height, a, cz, hw))
        }
        let shoulderY = y0 + 0.80 * height, thighY = y0 + 0.36 * height, elbowY = y0 + 0.62 * height
        func interpolate(_ y: Double, _ value: (Int) -> Double) -> Double {
            if y <= knots[0].y { return value(0) }
            if y >= knots[2].y { return value(2) }
            let j = y < knots[1].y ? 0 : 1
            let t = (y - knots[j].y) / (knots[j + 1].y - knots[j].y)
            return value(j) * (1 - t) + value(j + 1) * t
        }
        let push = max(0, knots[0].a * knots[0].halfWidth, knots[1].a * knots[1].halfWidth) * 1.15
        for i in v.indices {
            let p = SIMD3<Double>(v[i])
            if basis.isArm[i] {
                guard push > 0 else { continue }
                let t = smoothstep(shoulderY, elbowY, p.y)
                v[i].x += Float((p.x >= 0 ? 1 : -1) * push * t)
                continue
            }
            var a = interpolate(p.y) { knots[$0].a }
            if p.y > knots[2].y { a *= 1 - smoothstep(knots[2].y, shoulderY, p.y) }
            if p.y < knots[0].y { a *= 1 - smoothstep(knots[0].y, thighY, p.y) }
            guard a != 0 else { continue }
            let cz = interpolate(p.y) { knots[$0].cz }
            v[i].x = Float(p.x * (1 + a))
            v[i].z = Float(cz + (p.z - cz) * (1 + a))
        }

        // Shoulder width the bases could not reach: widen (or narrow) the upper torso sideways from
        // the chest tape up to the shoulder points, fading out up the neck, and carry the arms with it.
        let shoulder = measureCm(basis, v)[0]
        if shoulder > 0 {
            let gain = min(max(target[0] / shoulder - 1, -maxRadialCorrection), maxRadialCorrection)
            let shift = gain * shoulder / 200 // metres per side
            let pointY = Double(v[basis.meta.shoulderPair[0]].y)
            let chestY = knots[2].y, neckY = y0 + 0.88 * height
            if gain != 0, pointY > chestY, neckY > pointY {
                for i in v.indices {
                    let y = Double(v[i].y)
                    if basis.isArm[i] {
                        v[i].x += Float((v[i].x >= 0 ? 1 : -1) * shift)
                    } else {
                        let t = smoothstep(chestY, pointY, y) * (1 - smoothstep(pointY, neckY, y))
                        v[i].x = Float(Double(v[i].x) * (1 + gain * t))
                    }
                }
            }
        }

        let lift = Float(y0)
        return v.map { SIMD3($0.x, $0.y - lift, $0.z) * Float(scale) }
    }
}

extension BodyMesh {
    /// The sculpted body for a snapshot (ADR-010), as one closed piece. Throws if the basis is missing
    /// or the result fails the same structural checks as the procedural body.
    public static func sculpted(from snapshot: AvatarSnapshot, basis: SculptedBodyBasis? = .shared) throws(BodyEditError) -> BodyMesh {
        guard let basis else { throw .unsafeGeometry("basis-missing") }
        let shape = snapshot.silhouette
        try shape.validate()
        guard let targets = SculptedBody.targetsCm(snapshot), targets.allSatisfy({ $0.isFinite && $0 > 0 }) else {
            throw .unsafeGeometry("targets")
        }
        let positions = SculptedBody.positions(basis, heightCm: shape.heightCm, targetsCm: targets)
        var top: Float = 0
        for p in positions { top = max(top, p.y) }
        let normals = smoothNormals(positions.map(SIMD3<Double>.init), basis.indices)
        let mesh = BodyMesh(bodyRevision: snapshot.bodyRevision, heightM: top,
                            pieces: [Piece(part: .body, positions: positions, normals: normals, indices: basis.indices)])
        try mesh.validate()
        return mesh
    }

    /// What the 3D tier draws: the sculpted body, or the procedural one if that is unavailable (G0
    /// fallback order, ADR-007 §5 / ADR-010). nil only if neither can be built.
    public static func best(from snapshot: AvatarSnapshot) -> BodyMesh? {
        if let mesh = try? sculpted(from: snapshot) { return mesh }
        return try? make(from: snapshot)
    }
}
