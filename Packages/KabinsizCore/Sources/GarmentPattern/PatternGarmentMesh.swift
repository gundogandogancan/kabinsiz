import BodyGeometry
import Foundation

/// A 3D garment sewn from pattern pieces: every vertex comes from a point on a flat piece, so the
/// fabric's own print keeps its proportions on the body. Same coordinates as `BodyMesh` and
/// `GarmentMesh` (metres, y up from the floor, x to the viewer's right, z towards the viewer), with UVs
/// added. `GarmentMesh.Piece` has no texture coordinates, which a photo-textured panel needs, so this is
/// a sibling type with the same field names (`positions`, `normals`, `indices`) plus `uvs`.
public struct SewnGarment: Codable, Hashable, Sendable {
    public enum Side: String, Codable, Sendable { case right, left }

    public struct Piece: Codable, Hashable, Sendable {
        public let panel: PatternPiece.Role
        /// Viewer's right (+x) or left (−x). A piece cut on the fold gives one right and one left half.
        public let side: Side
        public let role: GarmentMesh.Role
        public let positions: [SIMD3<Float>]
        public let normals: [SIMD3<Float>]
        /// Image coordinates 0…1, origin top-left, v down, inside this panel's `UVRegion`.
        public let uvs: [SIMD2<Float>]
        public let indices: [UInt32]
        /// Vertices on the pattern's left and right boundary, top to bottom: centre line (or inseam,
        /// or one side of the sleeve seam) and side seam (or outseam, or the other side of the sleeve seam).
        public let leftEdge: [UInt32]
        public let rightEdge: [UInt32]
    }

    /// Where a panel's texture lands: the part of that panel's photo (image 0…1, origin top-left, v down)
    /// its vertices cover. Fitted inside the image without stretching, so a centimetre of fabric spans
    /// the same number of pixels across and down (`cmPerU / cmPerV` equals the image aspect).
    public struct UVRegion: Codable, Hashable, Sendable {
        public let panel: PatternPiece.Role
        public let u0: Double, v0: Double, u1: Double, v1: Double
        /// Fabric centimetres per whole image width / height.
        public let cmPerU: Double
        public let cmPerV: Double
    }

    public let kind: GarmentKind
    public let bodyRevision: Int
    public let pieces: [Piece]
    public let uvRegions: [UVRegion]
    /// Honest notes on what was approximated (tight rows, a hem clamped at the ankle, …).
    public let notes: [String]

    public var triangleCount: Int { pieces.reduce(0) { $0 + $1.indices.count / 3 } }

    public func pieces(_ panel: PatternPiece.Role) -> [Piece] { pieces.filter { $0.panel == panel } }
    public func uvRegion(_ panel: PatternPiece.Role) -> UVRegion? { uvRegions.first { $0.panel == panel } }

    /// The same structural checks as `GarmentMesh.validate`, plus one UV per vertex inside 0…1.
    public func validate(heightM: Float) throws(PatternError) {
        guard !pieces.isEmpty else { throw .invalidGeometry("garment-empty") }
        for piece in pieces {
            let n = piece.positions.count
            guard n >= 3, piece.normals.count == n, piece.uvs.count == n, piece.indices.count >= 3, piece.indices.count % 3 == 0 else {
                throw .invalidGeometry("garment-shape")
            }
            for k in 0..<n {
                let p = piece.positions[k], nrm = piece.normals[k], t = piece.uvs[k]
                guard p.x.isFinite, p.y.isFinite, p.z.isFinite else { throw .invalidGeometry("garment-nan") }
                guard p.y >= -0.002, p.y <= heightM + 0.002, abs(p.x) < heightM, abs(p.z) < heightM else { throw .invalidGeometry("garment-bounds") }
                guard abs((nrm * nrm).sum().squareRoot() - 1) < 0.01 else { throw .invalidGeometry("garment-normal") }
                guard t.x.isFinite, t.y.isFinite, t.x >= -1e-4, t.x <= 1.0001, t.y >= -1e-4, t.y <= 1.0001 else { throw .invalidGeometry("garment-uv") }
            }
            for t in stride(from: 0, to: piece.indices.count, by: 3) {
                let i = piece.indices[t], j = piece.indices[t + 1], k = piece.indices[t + 2]
                guard Int(i) < n, Int(j) < n, Int(k) < n, i != j, j != k, i != k else { throw .invalidGeometry("garment-index") }
                guard triangleAreaSq(piece.positions[Int(i)], piece.positions[Int(j)], piece.positions[Int(k)]) > 1e-14 else {
                    throw .invalidGeometry("garment-degenerate")
                }
            }
        }
    }
}

/// Sews a `SewingPattern` onto a body: front panels wrap the front half of the body, back panels the
/// back half, sleeves and legs are tubes whose girth is the piece's width. A geometric wrap, not a cloth
/// simulation: no drape, folds or gravity.
///
/// How a flat piece becomes a surface. Each pattern row (depth y) becomes a horizontal ring around the
/// body at the matching height; the ring is the body's cross-section grown evenly until its perimeter
/// equals the pattern's circumference there (2 × (front + back half-widths)), never closer than
/// `standoffCm` to the skin. Along the ring, arc length follows pattern centimetres (front from the
/// centre front, back from the centre back), so a looser pattern gives a looser ring and the print is
/// not stretched. Front and back meet at the same side-seam point, computed once from both widths.
public enum PatternGarmentMesh {
    /// Closest the fabric may sit to the skin (cm). A tighter pattern is drawn at this distance and
    /// listed in `notes` (it would need stretch fabric).
    public static let standoffCm = 0.4
    /// A top's hem below the trouser or skirt waistband stands this far off the skin, outside the
    /// bottom's own allowance (`GarmentMesh.ease`, at most 1.6 cm): worn untucked, its front print stays in
    /// view instead of poking through the trousers in patches.
    public static let untuckedHemStandoffCm = 2.4
    /// The waistband of the drawn bottoms (`GarmentMesh.bottom`), as a fraction of the height from the crown.
    static let bottomsWaistbandFraction = 0.40
    /// Neck point (top of a bodice pattern) and waist (top of a skirt or trousers), as fractions of the
    /// height from the crown: the body's own station heights (`Silhouette.Station`).
    public static let neckPointFraction = 0.145
    public static let waistFraction = Silhouette.Station.waist.heightFraction

    public static func sew(_ pattern: SewingPattern, onto snapshot: AvatarSnapshot, photoAspects: [PatternPiece.Role: Double] = [:],
                           columns: Int = 16, rowStepCm: Double = 1.5) throws(PatternError) -> SewnGarment {
        let body: BodyMesh
        do { body = try BodyMesh.make(from: snapshot) } catch { throw .invalidGeometry("body mesh") }
        return try sew(pattern, onto: body, photoAspects: photoAspects, columns: columns, rowStepCm: rowStepCm)
    }

    /// - Parameter photoAspects: width ÷ height of each panel's photo cut-out (front, back, sleeve). When
    ///   absent, the panel's own aspect is used and its UVs fill the whole image.
    public static func sew(_ pattern: SewingPattern, onto body: BodyMesh, photoAspects: [PatternPiece.Role: Double] = [:],
                           columns: Int = 16, rowStepCm: Double = 1.5) throws(PatternError) -> SewnGarment {
        guard let front = pattern.piece(.front), let back = pattern.piece(.back) else { throw .invalidGeometry("front and back pieces") }
        guard columns >= 2, columns <= 128, rowStepCm.isFinite, rowStepCm >= 0.25 else { throw .invalidGeometry("mesh resolution") }
        let env = try BodyEnvelope(body)
        let ctx = Context(env: env, family: pattern.kind.family, front: front, back: back)
        var notes: [String] = []
        let rows = rowList([front, back], step: rowStepCm)

        var regions: [SewnGarment.UVRegion] = []
        var pieces: [SewnGarment.Piece] = []
        for piece in [front, back] {
            let region = uvRegion(piece, aspect: photoAspects[piece.role])
            regions.append(region)
            let b = piece.bounds
            let uc = (region.u0 + region.u1) / 2
            // Front: +x (the wearer's left, the viewer's right) is the photo's right. Back: seen from
            // behind, the same side is the photo's left.
            let sign = piece.role == .front ? 1.0 : -1.0
            let right = try panel(piece, rows: rows, columns: columns, map: { y in ctx.torsoRow(piece, y) },
                                  uv: { x, y in SIMD2(uc + sign * x / region.cmPerU, region.v0 + (y - b.minY) / region.cmPerV) })
            pieces += [right, mirrored(right, region: region)]
        }
        if let sleeve = pattern.piece(.sleeve) {
            let region = uvRegion(sleeve, aspect: photoAspects[.sleeve])
            regions.append(region)
            let b = sleeve.bounds
            let right = try panel(sleeve, rows: rowList([sleeve], step: rowStepCm), columns: columns, map: { y in ctx.sleeveRow(sleeve, y) },
                                  uv: { x, y in SIMD2(region.u0 + (x - b.minX) / region.cmPerU, region.v0 + (y - b.minY) / region.cmPerV) })
            pieces += [right, mirrored(right, region: region)]
            if sleeve.bounds.maxY / 100 > env.arm.length - 0.02 { notes.append("Kol, kol boyundan uzun: kol ağzı bilekte çizildi.") }
        }
        if ctx.anyTight([front, back], rows: rows) {
            notes.append("Kalıp bazı satırlarda bedenden dar: kumaş tene \(PatternDrafter.cmText(standoffCm)) cm mesafede çizildi (esnek kumaş gerekir).")
        }
        if ctx.topY - max(front.bounds.maxY, back.bounds.maxY) / 100 < env.ankleY {
            notes.append("Giysi bacaktan uzun: etek ucu bilek hizasında çizildi.")
        }
        let garment = SewnGarment(kind: pattern.kind, bodyRevision: body.bodyRevision, pieces: pieces, uvRegions: regions, notes: notes)
        try garment.validate(heightM: body.heightM)
        return garment
    }

    // MARK: Rows and panels

    /// Every outline vertex depth (so corners and curves are kept), with even rows in between.
    static func rowList(_ pieces: [PatternPiece], step: Double) -> [Double] {
        var key = pieces.flatMap { $0.outline.map(\.y) + $0.notches.map(\.point.y) }.sorted()
        key = key.reduce(into: []) { out, y in if out.last.map({ y - $0 > 1e-6 }) ?? true { out.append(y) } }
        var rows: [Double] = []
        for (a, b) in zip(key, key.dropFirst()) {
            rows.append(a)
            let n = Int(((b - a) / step).rounded(.up))
            if n > 1 { for k in 1..<n { rows.append(a + (b - a) * Double(k) / Double(n)) } }
        }
        if let last = key.last { rows.append(last) }
        return rows
    }

    /// A surface sample: position (m) and the outward direction it should face.
    typealias Sample = (p: SIMD3<Double>, out: SIMD3<Double>)

    /// The right half of a panel as a grid: one vertex row per pattern row, `columns` + 1 vertices
    /// across from the left to the right seam line. Degenerate triangles (a piece narrowing to a point)
    /// are left out; faces are turned to point the same way as `out`.
    static func panel(_ piece: PatternPiece, rows all: [Double], columns n: Int, map: (Double) -> (Double, Double, Double) -> Sample,
                      uv: (Double, Double) -> SIMD2<Double>) throws(PatternError) -> SewnGarment.Piece {
        let b = piece.bounds
        let rows = [b.minY] + all.filter { $0 > b.minY + 1e-6 && $0 < b.maxY - 1e-6 } + [b.maxY]
        var pos: [SIMD3<Double>] = [], out: [SIMD3<Double>] = [], uvs: [SIMD2<Float>] = []
        var leftEdge: [UInt32] = [], rightEdge: [UInt32] = []
        for y in rows {
            guard let span = piece.span(atY: y) else { throw .invalidGeometry("\(piece.name): row \(y)") }
            let rowMap = map(y)
            let l = span.lowerBound, r = span.upperBound
            for j in 0...n {
                let x = j == n ? r : l + (r - l) * Double(j) / Double(n)
                let s = rowMap(x, l, r)
                if j == 0 { leftEdge.append(UInt32(pos.count)) }
                if j == n { rightEdge.append(UInt32(pos.count)) }
                pos.append(s.p)
                out.append(s.out)
                let t = uv(x, y)
                uvs.append(SIMD2(Float(t.x), Float(t.y)))
            }
        }
        let fp = pos.map { SIMD3<Float>($0) }
        var idx: [UInt32] = []
        let w = UInt32(n + 1)
        for r in 0..<UInt32(rows.count - 1) {
            for j in 0..<UInt32(n) {
                let v00 = r * w + j, v01 = v00 + 1, v10 = v00 + w, v11 = v10 + 1
                for tri in [[v00, v10, v01], [v01, v10, v11]] where triangleAreaSq(fp[Int(tri[0])], fp[Int(tri[1])], fp[Int(tri[2])]) > 4e-14 {
                    idx += tri
                }
            }
        }
        guard !idx.isEmpty else { throw .invalidGeometry("\(piece.name): no surface") }
        // Majority vote against the outward directions: the grid's winding depends on how the pattern
        // axes land on the body, so it is measured rather than assumed.
        var vote = 0.0
        for t in stride(from: 0, to: idx.count, by: 3) {
            let i = Int(idx[t]), j = Int(idx[t + 1]), k = Int(idx[t + 2])
            vote += dot(cross(pos[j] - pos[i], pos[k] - pos[i]), out[i] + out[j] + out[k])
        }
        if vote < 0 { for t in stride(from: 0, to: idx.count, by: 3) { idx.swapAt(t + 1, t + 2) } }
        return SewnGarment.Piece(panel: piece.role, side: .right, role: .shell, positions: fp, normals: normals(pos, idx, fallback: out),
                                 uvs: uvs, indices: idx, leftEdge: leftEdge, rightEdge: rightEdge)
    }

    /// The left half: mirrored across x = 0 with the triangle order reversed (mirroring flips
    /// handedness), and the photo mirrored about the region's centre line.
    static func mirrored(_ p: SewnGarment.Piece, region: SewnGarment.UVRegion) -> SewnGarment.Piece {
        var flipped: [UInt32] = []
        flipped.reserveCapacity(p.indices.count)
        for t in stride(from: 0, to: p.indices.count, by: 3) { flipped += [p.indices[t], p.indices[t + 2], p.indices[t + 1]] }
        let su = Float(region.u0 + region.u1)
        return SewnGarment.Piece(panel: p.panel, side: .left, role: p.role, positions: p.positions.map { SIMD3(-$0.x, $0.y, $0.z) },
                                 normals: p.normals.map { SIMD3(-$0.x, $0.y, $0.z) }, uvs: p.uvs.map { SIMD2(su - $0.x, $0.y) },
                                 indices: flipped, leftEdge: p.leftEdge, rightEdge: p.rightEdge)
    }

    /// Area-weighted vertex normals; a vertex in no triangle takes its outward direction.
    static func normals(_ p: [SIMD3<Double>], _ idx: [UInt32], fallback: [SIMD3<Double>]) -> [SIMD3<Float>] {
        var acc = [SIMD3<Double>](repeating: .zero, count: p.count)
        for t in stride(from: 0, to: idx.count, by: 3) {
            let i = Int(idx[t]), j = Int(idx[t + 1]), k = Int(idx[t + 2])
            let n = cross(p[j] - p[i], p[k] - p[i])
            acc[i] += n
            acc[j] += n
            acc[k] += n
        }
        return zip(acc, fallback).map { v, f in
            let l = (v * v).sum().squareRoot()
            if l > 1e-18 { return SIMD3<Float>(v / l) }
            let fl = (f * f).sum().squareRoot()
            return fl > 0 ? SIMD3<Float>(f / fl) : SIMD3(0, 0, 1)
        }
    }

    /// The part of the image a panel covers, fitted inside 0…1 without stretching. Front and back use
    /// the full unfolded width (both halves; for trousers both legs), the sleeve its own width.
    static func uvRegion(_ piece: PatternPiece, aspect: Double?) -> SewnGarment.UVRegion {
        let b = piece.bounds
        let width = piece.role == .sleeve ? b.width : 2 * max(b.maxX, -b.minX)
        let pa = width / b.height
        let ia = aspect.flatMap { $0.isFinite && $0 > 0 ? $0 : nil } ?? pa
        var (u0, u1, v0, v1) = (0.0, 1.0, 0.0, 1.0)
        if pa <= ia {
            let w = pa / ia
            (u0, u1) = (0.5 - w / 2, 0.5 + w / 2)
        } else {
            let h = ia / pa
            (v0, v1) = (0.5 - h / 2, 0.5 + h / 2)
        }
        return SewnGarment.UVRegion(panel: piece.role, u0: u0, v0: v0, u1: u1, v1: v1, cmPerU: width / (u1 - u0), cmPerV: b.height / (v1 - v0))
    }

    // MARK: Wrapping

    struct Context {
        let env: BodyEnvelope
        let family: GarmentKind.Family
        let front: PatternPiece
        let back: PatternPiece
        /// Height (m) of pattern depth 0.
        let topY: Double
        let underarmY: Double?
        let hipY: Double?
        let crotchY: Double?

        init(env: BodyEnvelope, family: GarmentKind.Family, front: PatternPiece, back: PatternPiece) {
            self.env = env
            self.family = family
            self.front = front
            self.back = back
            topY = env.heightM * (1 - (family == .bodice ? PatternGarmentMesh.neckPointFraction : PatternGarmentMesh.waistFraction))
            underarmY = family == .bodice ? front.notch("underarm")?.y : nil
            hipY = family == .trousers ? front.notch("hip")?.y : nil
            crotchY = family == .trousers ? front.notch("crotch-point")?.y : nil
        }

        func height(_ y: Double) -> Double { max(topY - y / 100, env.ankleY) }

        /// Front and back seam-line widths at depth y; a panel missing at that depth borrows the other's.
        func widths(_ y: Double) -> (front: Double, back: Double) {
            var f = front.width(atY: y), b = back.width(atY: y)
            if f <= 1e-9 { f = b }
            if b <= 1e-9 { b = f }
            return (max(f, 1e-6), max(b, 1e-6))
        }

        struct Ring {
            let sec: BodyEnvelope.Section
            let k: Double
            let table: ArcTable
            /// The pattern's girth here is less than the body's own girth (stretch fabric needed).
            let tight: Bool
            var a: Double { sec.a + k }
            var b: Double { sec.b + k }
            func point(_ arc: Double, y: Double) -> Sample {
                let th = table.theta(arc)
                let c = cos(th), s = sin(th)
                let o = SIMD3(c / a, 0, s / b)
                return (SIMD3(sec.centerX + a * c, y, sec.centerZ + b * s), o / (o * o).sum().squareRoot())
            }
        }

        /// The body section at height `y3` grown until its perimeter is `target` metres.
        func ring(_ sec: BodyEnvelope.Section, target: Double, start: Double) -> Ring {
            let k0 = PatternGarmentMesh.standoffCm / 100
            var k = k0
            // Below the standoff the ring keeps the standoff (never inside the skin) and the print
            // stretches a little; that only counts as tight when the pattern is under the body's girth.
            let tight = target < sec.bodyPerimeter
            if ellipsePerimeter(sec.a + k0, sec.b + k0) < target {
                var lo = k0, hi = k0 + target / (2 * .pi)
                for _ in 0..<60 {
                    let mid = (lo + hi) / 2
                    if ellipsePerimeter(sec.a + mid, sec.b + mid) < target { lo = mid } else { hi = mid }
                }
                k = (lo + hi) / 2
            }
            return Ring(sec: sec, k: k, table: ArcTable(a: sec.a + k, b: sec.b + k, start: start, dir: -1), tight: tight)
        }

        func torsoRing(_ y: Double) -> Ring {
            let w = widths(y)
            return ring(env.torsoSection(atY: height(y)), target: 2 * (w.front + w.back) / 100, start: .pi / 2)
        }

        func legRing(_ y: Double) -> Ring {
            let w = widths(y)
            return ring(env.legSection(atY: height(y)), target: (w.front + w.back) / 100, start: .pi)
        }

        func anyTight(_ pieces: [PatternPiece], rows: [Double]) -> Bool {
            let lo = pieces.map(\.bounds.minY).max() ?? 0, hi = pieces.map(\.bounds.maxY).min() ?? 0
            return rows.contains { y in
                guard y >= lo, y <= hi, underarmY.map({ y >= $0 }) ?? true else { return false }
                if let crotchY, y >= crotchY { return legRing(y).tight }
                return torsoRing(y).tight
            }
        }

        /// Moves a point that ended up inside the body (plus standoff) straight out from the section centre.
        func pushOut(_ s: Sample, section sec: BodyEnvelope.Section) -> Sample {
            var so = PatternGarmentMesh.standoffCm / 100
            if family == .bodice {
                // From 3 cm above the waistband down, ease out to the untucked distance over 5 cm.
                let waistband = env.heightM * (1 - PatternGarmentMesh.bottomsWaistbandFraction)
                let t = smoothstep((waistband + 0.03 - s.p.y) / 0.05)
                so += (PatternGarmentMesh.untuckedHemStandoffCm - PatternGarmentMesh.standoffCm) / 100 * t
            }
            let dx = s.p.x - sec.centerX, dz = s.p.z - sec.centerZ
            let u = dx / (sec.a + so), v = dz / (sec.b + so)
            let level = (u * u + v * v).squareRoot()
            guard level < 1, level > 1e-9 else { return s }
            return (SIMD3(sec.centerX + dx / level, s.p.y, sec.centerZ + dz / level), s.out)
        }

        /// One pattern row of a front or back piece on the torso (and, for trousers, the legs).
        func torsoRow(_ piece: PatternPiece, _ y: Double) -> (Double, Double, Double) -> Sample {
            let isFront = piece.role == .front
            let w = widths(y)
            switch family {
            case .bodice:
                let ring: Ring, scale: Double?
                if let ua = underarmY, y < ua {
                    // Above the underarm the pattern has no full width (armhole, shoulder): keep the
                    // underarm's growth and centimetre scale so the neckline and shoulder are not stretched.
                    let ref = torsoRing(ua)
                    let wu = widths(ua)
                    let sec = env.torsoSection(atY: height(y))
                    ring = Ring(sec: sec, k: ref.k, table: ArcTable(a: sec.a + ref.k, b: sec.b + ref.k, start: .pi / 2, dir: -1), tight: false)
                    scale = ref.table.perimeter / 2 / (wu.front + wu.back)
                } else {
                    ring = torsoRing(y)
                    scale = nil
                }
                let half = ring.table.perimeter / 2
                let arcSide = half * w.front / (w.front + w.back)
                let y3 = height(y)
                let np = piece.notch("neck-point"), sp = piece.notch("shoulder-point")
                let band = 3.5 * env.heightM // cm: 0.035 × height
                return { x, l, r in
                    let t = r - l > 1e-9 ? (x - l) / (r - l) : 0
                    let arc: Double
                    if let scale {
                        arc = isFront ? min(x * scale, half) : half - min(x * scale, half)
                    } else {
                        arc = isFront ? arcSide * t : half - (half - arcSide) * t
                    }
                    var s = ring.point(arc, y: y3)
                    var lifted = false
                    if let np, let sp, sp.x > np.x {
                        // Over the shoulder: towards the shoulder seam the panel folds to the body's
                        // mid-plane (z = centre), where front and back meet, and rises over the shoulder.
                        let xc = min(max(x, np.x), sp.x)
                        let lineY = np.y + (sp.y - np.y) * (xc - np.x) / (sp.x - np.x)
                        let g = sin(min(max(y - lineY, 0) / band, 1) * .pi / 2)
                        s.p.z = ring.sec.centerZ + (s.p.z - ring.sec.centerZ) * g
                        s.p.y += (1 - g) * (ring.k + 0.005)
                        s.out = normalize(s.out * g + SIMD3(0, 1, 0) * (1 - g))
                        lifted = g < 1
                    }
                    return pushOut(s, section: lifted ? env.torsoSection(atY: s.p.y) : ring.sec)
                }
            case .skirt:
                let ring = torsoRing(y)
                let half = ring.table.perimeter / 2
                let arcSide = half * w.front / (w.front + w.back)
                let y3 = height(y)
                return { x, l, r in
                    let t = r - l > 1e-9 ? (x - l) / (r - l) : 0
                    return pushOut(ring.point(isFront ? arcSide * t : half - (half - arcSide) * t, y: y3), section: ring.sec)
                }
            case .trousers:
                let y3 = height(y)
                let hip = hipY ?? 0, crotch = crotchY ?? 0
                let blend = y <= hip ? 0 : (y >= crotch ? 1 : smoothstep((y - hip) / max(crotch - hip, 1e-6)))
                let torso: Ring? = blend < 1 ? torsoRing(y) : nil
                let leg: Ring? = blend > 0 ? legRing(y) : nil
                return { x, l, r in
                    let t = r - l > 1e-9 ? (x - l) / (r - l) : 0
                    var a: Sample?, b: Sample?
                    if let torso {
                        // Centre front/back to the side seam, as on a skirt.
                        let half = torso.table.perimeter / 2
                        let arcSide = half * w.front / (w.front + w.back)
                        a = torso.point(isFront ? arcSide * t : half - (half - arcSide) * t, y: y3)
                    }
                    if let leg {
                        // Inseam (inner side of the leg) round the front or the back to the outseam.
                        let p = leg.table.perimeter
                        let arcFront = p * w.front / (w.front + w.back)
                        b = leg.point(isFront ? arcFront * t : p - (p - arcFront) * t, y: y3)
                    }
                    switch (a, b) {
                    case let (a?, nil): return pushOut(a, section: torso!.sec)
                    case let (nil, b?): return pushOut(b, section: leg!.sec)
                    case let (a?, b?): return (a.p * (1 - blend) + b.p * blend, normalize(a.out * (1 - blend) + b.out * blend))
                    default: return (SIMD3(0, y3, 0), SIMD3(0, 0, 1))
                    }
                }
            }
        }

        /// One sleeve row: a ring round the arm axis whose circumference is the row's width (at least the
        /// arm plus standoff, the cap included). The sleeve's two edges meet at the underarm (−side).
        func sleeveRow(_ sleeve: PatternPiece, _ y: Double) -> (Double, Double, Double) -> Sample {
            let arm = env.arm
            let d = min(y / 100, arm.length - 0.02)
            var radius = sleeve.width(atY: y) / (2 * .pi) / 100
            // The cap narrows to a point at the shoulder on paper; on the body it still wraps the arm
            // from the shoulder joint, so the sleeve meets the bodice instead of starting at the underarm.
            radius = max(radius, arm.radius(at: d) + PatternGarmentMesh.standoffCm / 100)
            let centre = arm.joint + arm.axis * d
            let z = SIMD3<Double>(0, 0, 1)
            return { x, l, r in
                let t = r - l > 1e-9 ? (x - l) / (r - l) : 0
                let phi = Double.pi + 2 * .pi * t
                let o = arm.side * cos(phi) + z * sin(phi)
                return (centre + o * radius, o)
            }
        }
    }
}

/// Arc length along an ellipse from a start angle, walked in direction `dir` (−1 = clockwise seen from
/// above with z towards the viewer: from the centre front towards +x). A fine polyline, so arc → angle is
/// a table lookup: deterministic and exact enough (720 steps, < 0.1 mm on a body-size ellipse).
struct ArcTable {
    static let steps = 720
    let start: Double
    let dir: Double
    let arcs: [Double]

    init(a: Double, b: Double, start: Double, dir: Double) {
        self.start = start
        self.dir = dir
        var arcs = [0.0]
        arcs.reserveCapacity(Self.steps + 1)
        var prev = SIMD2(a * cos(start), b * sin(start))
        for i in 1...Self.steps {
            let th = start + dir * 2 * .pi * Double(i) / Double(Self.steps)
            let p = SIMD2(a * cos(th), b * sin(th))
            arcs.append(arcs[i - 1] + ((p - prev) * (p - prev)).sum().squareRoot())
            prev = p
        }
        self.arcs = arcs
    }

    var perimeter: Double { arcs[arcs.count - 1] }

    func theta(_ s: Double) -> Double {
        let s = min(max(s, 0), perimeter)
        var lo = 0, hi = arcs.count - 1
        while hi - lo > 1 {
            let mid = (lo + hi) / 2
            if arcs[mid] <= s { lo = mid } else { hi = mid }
        }
        let seg = arcs[hi] - arcs[lo]
        let f = seg > 0 ? (s - arcs[lo]) / seg : 0
        return start + dir * 2 * .pi * (Double(lo) + f) / Double(Self.steps)
    }
}

private func smoothstep(_ t: Double) -> Double {
    let x = min(max(t, 0), 1)
    return x * x * (3 - 2 * x)
}

private func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double { (a * b).sum() }

private func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
    SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}

private func normalize(_ v: SIMD3<Double>) -> SIMD3<Double> {
    let l = (v * v).sum().squareRoot()
    return l > 0 ? v / l : SIMD3(0, 0, 1)
}

/// Squared length of the cross product in Float, exactly as `GarmentMesh.validate` measures it.
func triangleAreaSq(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>) -> Float {
    let u = b - a, v = c - a
    let cr = SIMD3(u.y * v.z - u.z * v.y, u.z * v.x - u.x * v.z, u.x * v.y - u.y * v.x)
    return (cr * cr).sum()
}
