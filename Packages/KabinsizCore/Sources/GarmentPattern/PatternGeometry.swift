import BodyGeometry
import Foundation

/// A pattern point in centimetres: x across the piece (0 = the centre line), y down from the top edge.
/// The same value type and axis convention as the body outline (`Silhouette.Point`, y grows downward),
/// so the 2D body and the 2D pattern pieces are one drawing system.
public typealias PatternPoint = Silhouette.Point

/// Axis-aligned bounds of a pattern piece, in centimetres.
public struct PatternBounds: Codable, Hashable, Sendable {
    public let minX: Double, minY: Double, maxX: Double, maxY: Double
    public var width: Double { maxX - minX }
    public var height: Double { maxY - minY }
}

/// Plain polygon helpers. Outlines are closed implicitly (the last point joins the first).
enum Polygon {
    /// Shoelace area. Pieces are stored with a positive value, so the outward normal of edge a→b is
    /// (dy, -dx): the same rule for every piece, which the seam-allowance offset relies on.
    static func signedArea(_ p: [PatternPoint]) -> Double {
        guard p.count >= 3 else { return 0 }
        var s = 0.0
        for i in p.indices {
            let a = p[i], b = p[(i + 1) % p.count]
            s += a.x * b.y - b.x * a.y
        }
        return s / 2
    }

    static func bounds(_ p: [PatternPoint]) -> PatternBounds {
        var lo = (x: Double.infinity, y: Double.infinity), hi = (x: -Double.infinity, y: -Double.infinity)
        for q in p {
            lo = (min(lo.x, q.x), min(lo.y, q.y))
            hi = (max(hi.x, q.x), max(hi.y, q.y))
        }
        return PatternBounds(minX: lo.x, minY: lo.y, maxX: hi.x, maxY: hi.y)
    }

    /// Consecutive points closer than `eps` collapse to one, so curve samples never make zero-length edges.
    static func dedup(_ p: [PatternPoint], eps: Double = 1e-6) -> [PatternPoint] {
        var out: [PatternPoint] = []
        for q in p where out.last.map({ hypot($0.x - q.x, $0.y - q.y) > eps }) ?? true { out.append(q) }
        while out.count > 1, let f = out.first, let l = out.last, hypot(f.x - l.x, f.y - l.y) <= eps { out.removeLast() }
        return out
    }

    /// No two non-neighbouring edges touch, and neighbouring edges do not fold back onto each other.
    static func isSimple(_ p: [PatternPoint]) -> Bool {
        let n = p.count
        guard n >= 3 else { return false }
        for i in 0..<n {
            let a = p[i], b = p[(i + 1) % n]
            for j in (i + 1)..<n {
                let c = p[j], d = p[(j + 1) % n]
                if j == i + 1 || (i == 0 && j == n - 1) {
                    // Neighbours share one vertex; they may only meet there (no overlap along a line).
                    let shared = j == i + 1 ? b : a
                    let other1 = j == i + 1 ? a : b
                    let other2 = j == i + 1 ? d : c
                    if abs(orient(shared, other1, other2)) < 1e-12, dotFrom(shared, other1, other2) > 0 { return false }
                    continue
                }
                if segmentsIntersect(a, b, c, d) { return false }
            }
        }
        return true
    }

    static func orient(_ a: PatternPoint, _ b: PatternPoint, _ c: PatternPoint) -> Double {
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
    }

    private static func dotFrom(_ o: PatternPoint, _ a: PatternPoint, _ b: PatternPoint) -> Double {
        (a.x - o.x) * (b.x - o.x) + (a.y - o.y) * (b.y - o.y)
    }

    private static func onSegment(_ a: PatternPoint, _ b: PatternPoint, _ p: PatternPoint) -> Bool {
        p.x >= min(a.x, b.x) - 1e-12 && p.x <= max(a.x, b.x) + 1e-12 && p.y >= min(a.y, b.y) - 1e-12 && p.y <= max(a.y, b.y) + 1e-12
    }

    static func segmentsIntersect(_ a: PatternPoint, _ b: PatternPoint, _ c: PatternPoint, _ d: PatternPoint) -> Bool {
        let eps = 1e-12
        let d1 = orient(c, d, a), d2 = orient(c, d, b), d3 = orient(a, b, c), d4 = orient(a, b, d)
        if ((d1 > eps && d2 < -eps) || (d1 < -eps && d2 > eps)) && ((d3 > eps && d4 < -eps) || (d3 < -eps && d4 > eps)) { return true }
        if abs(d1) <= eps, onSegment(c, d, a) { return true }
        if abs(d2) <= eps, onSegment(c, d, b) { return true }
        if abs(d3) <= eps, onSegment(a, b, c) { return true }
        if abs(d4) <= eps, onSegment(a, b, d) { return true }
        return false
    }

    /// Where the horizontal line at `y` crosses the outline: the leftmost and rightmost crossing. Every
    /// drafted piece is y-monotone (each horizontal line meets it in one interval), so this is its width.
    static func span(_ p: [PatternPoint], atY y: Double) -> ClosedRange<Double>? {
        var lo = Double.infinity, hi = -Double.infinity
        let eps = 1e-9
        for i in p.indices {
            let a = p[i], b = p[(i + 1) % p.count]
            if abs(a.y - b.y) < eps {
                if abs(a.y - y) < eps { lo = min(lo, a.x, b.x); hi = max(hi, a.x, b.x) }
                continue
            }
            guard y >= min(a.y, b.y) - eps, y <= max(a.y, b.y) + eps else { continue }
            let t = max(0, min(1, (y - a.y) / (b.y - a.y)))
            let x = a.x + t * (b.x - a.x)
            lo = min(lo, x)
            hi = max(hi, x)
        }
        return lo <= hi ? lo...hi : nil
    }

    /// Outline pushed outwards by a per-edge distance (edge i runs from p[i] to p[i + 1]); a distance of 0
    /// keeps that edge in place (a fold). Corners are mitred; a mitre longer than four allowances is cut
    /// (bevelled) so a sharp corner cannot throw a spike across the sheet.
    static func offset(_ p: [PatternPoint], by d: [Double]) -> [PatternPoint] {
        let n = p.count
        guard n >= 3, d.count == n else { return p }
        func dir(_ i: Int) -> (Double, Double) {
            let a = p[i], b = p[(i + 1) % n]
            let l = max(hypot(b.x - a.x, b.y - a.y), 1e-12)
            return ((b.x - a.x) / l, (b.y - a.y) / l)
        }
        var out: [PatternPoint] = []
        for i in 0..<n {
            let ip = (i - 1 + n) % n
            let e1 = dir(ip), e2 = dir(i)
            let n1 = (e1.1, -e1.0), n2 = (e2.1, -e2.0)
            let q = p[i]
            let l1 = PatternPoint(x: q.x + n1.0 * d[ip], y: q.y + n1.1 * d[ip])
            let l2 = PatternPoint(x: q.x + n2.0 * d[i], y: q.y + n2.1 * d[i])
            let cr = e1.0 * e2.1 - e1.1 * e2.0
            if abs(cr) < 1e-9 {
                out.append(PatternPoint(x: (l1.x + l2.x) / 2, y: (l1.y + l2.y) / 2))
                continue
            }
            let t = ((l2.x - l1.x) * e2.1 - (l2.y - l1.y) * e2.0) / cr
            let m = PatternPoint(x: l1.x + e1.0 * t, y: l1.y + e1.1 * t)
            if hypot(m.x - q.x, m.y - q.y) > 4 * max(d[ip], d[i], 0.01) {
                out.append(l1)
                out.append(l2)
            } else {
                out.append(m)
            }
        }
        return dedup(out)
    }

    /// Cubic Bézier samples, end points included.
    static func bezier(_ p0: PatternPoint, _ p1: PatternPoint, _ p2: PatternPoint, _ p3: PatternPoint, samples n: Int) -> [PatternPoint] {
        (0...n).map { k in
            let t = Double(k) / Double(n), u = 1 - t
            let a = u * u * u, b = 3 * u * u * t, c = 3 * u * t * t, e = t * t * t
            return PatternPoint(x: a * p0.x + b * p1.x + c * p2.x + e * p3.x, y: a * p0.y + b * p1.y + c * p2.y + e * p3.y)
        }
    }
}
