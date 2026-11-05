import Foundation

/// A front-view outline of a neutral, covered body (§108.3): a smooth closed shape built from a fixed
/// list of stations. There is no face, no hair and no anatomical detail anywhere in the model, by
/// construction (V15-T-BOD-09). This is the 2D preview (D-003); the 3D mesh comes in WP15-07/08.
public struct Silhouette: Codable, Hashable, Sendable {
    public struct Point: Codable, Hashable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// Body landmarks along the height, top to bottom. Fractions are of total height from the top.
    public enum Station: String, Codable, CaseIterable, Sendable {
        case crown, headWidest, neck, shoulder, chest, waist, hip, thigh, knee, ankle

        public var heightFraction: Double {
            switch self {
            case .crown: 0
            case .headWidest: 0.06
            case .neck: 0.13
            case .shoulder: 0.18
            case .chest: 0.27
            case .waist: 0.39
            case .hip: 0.50
            case .thigh: 0.60
            case .knee: 0.74
            case .ankle: 0.96
            }
        }
    }

    /// Height in cm and the half-width (centre to edge) at each station, in cm.
    public let heightCm: Double
    public let halfWidthsCm: [Station: Double]
    /// Right half of the outline, top to bottom, in cm (x ≥ 0 from the centre line, y down from the crown).
    /// The left half is its mirror, so the drawn shape is symmetric by construction.
    public let rightOutline: [Point]

    /// Front-view half-width of a roughly elliptical cross-section with circumference `c`. A torso is
    /// wider than deep (≈1.45:1), which makes the visible width ≈ c / 2.6. Drawing approximation only.
    static func halfWidth(circumference c: Double) -> Double { c / 2.6 / 2 }
    /// Inverse of `halfWidth(circumference:)`: the girth a drawn half-width stands for.
    static func circumference(halfWidth w: Double) -> Double { w * 2 * 2.6 }

    /// Geometry from a profile. Shoulder changes also widen the upper chest a little, so the outline
    /// stays one smooth shape instead of a step (correlated morph, §108.2).
    public static func make(for profile: BodyProfile) throws(BodyEditError) -> Silhouette {
        let h = profile[.height].length.centimeters
        let shoulderHalf = profile[.shoulderWidth].length.centimeters / 2
        let chestHalf = max(halfWidth(circumference: profile[.chest].length.centimeters), shoulderHalf * 0.78)
        let waistHalf = halfWidth(circumference: profile[.waist].length.centimeters)
        let hipHalf = halfWidth(circumference: profile[.hip].length.centimeters)
        let widths: [Station: Double] = [
            .crown: 0.012 * h,
            .headWidest: 0.046 * h,
            .neck: 0.034 * h,
            .shoulder: shoulderHalf,
            .chest: chestHalf,
            .waist: waistHalf,
            .hip: hipHalf,
            // Both legs together, standing with the feet a little apart (neutral proportions, not measurements).
            .thigh: hipHalf * 0.82,
            .knee: max(hipHalf * 0.58, 0.058 * h),
            .ankle: 0.055 * h,
        ]
        let anchors = Station.allCases.map { Point(x: widths[$0]!, y: $0.heightFraction * h) }
        let outline = roundedHead(smooth(anchors, samplesPerSegment: 8), crown: widths[.crown]!, widest: widths[.headWidest]!,
                                  widestY: Station.headWidest.heightFraction * h)
        let shape = Silhouette(heightCm: h, halfWidthsCm: widths, rightOutline: outline)
        try shape.validate()
        return shape
    }

    /// Geometric safety (V15-T-BOD-02): finite numbers, positive widths, y strictly increasing (the
    /// outline never folds back over itself), no width wider than 30 % of height, and no jump between
    /// neighbouring samples steeper than the limit, so the shape cannot spike or tear.
    public func validate() throws(BodyEditError) {
        guard heightCm.isFinite, heightCm > 0, rightOutline.count >= Station.allCases.count else { throw .unsafeGeometry("empty") }
        for (a, b) in zip(rightOutline, rightOutline.dropFirst()) {
            guard a.x.isFinite, a.y.isFinite, b.x.isFinite, b.y.isFinite else { throw .unsafeGeometry("non-finite") }
            guard b.y > a.y else { throw .unsafeGeometry("fold") }
            guard b.x > 0, b.x <= heightCm * 0.3 else { throw .unsafeGeometry("width") }
            guard abs(b.x - a.x) <= (b.y - a.y) * Self.maxSlope else { throw .unsafeGeometry("spike") }
        }
    }

    /// Crown to the widest point of the head follows a quarter ellipse instead of the monotone cubic,
    /// which would read as a pointed hood. Starts at the crown width, so nothing collapses to a point.
    static func roundedHead(_ outline: [Point], crown: Double, widest: Double, widestY: Double) -> [Point] {
        outline.map { p in
            guard p.y < widestY else { return p }
            let s = (widestY - p.y) / widestY // 1 at the crown, 0 at the widest point
            return Point(x: max(crown, widest * (1 - s * s).squareRoot()), y: p.y)
        }
    }

    /// Largest allowed |dx/dy| between samples. Shoulders are the steepest real step.
    public static let maxSlope = 6.0

    /// Monotone cubic (Fritsch–Carlson) interpolation of x over y: smooth, and it never overshoots the
    /// anchors, so the curve cannot invent a bulge or a negative width between stations.
    static func smooth(_ anchors: [Point], samplesPerSegment n: Int) -> [Point] {
        let k = anchors.count
        guard k >= 2 else { return anchors }
        var slopes = [Double](repeating: 0, count: k)
        let deltas = (0..<(k - 1)).map { (anchors[$0 + 1].x - anchors[$0].x) / (anchors[$0 + 1].y - anchors[$0].y) }
        slopes[0] = deltas[0]
        slopes[k - 1] = deltas[k - 2]
        for i in 1..<(k - 1) {
            slopes[i] = deltas[i - 1] * deltas[i] <= 0 ? 0 : (deltas[i - 1] + deltas[i]) / 2
        }
        for i in 0..<(k - 1) where deltas[i] == 0 {
            slopes[i] = 0
            slopes[i + 1] = 0
        }
        for i in 0..<(k - 1) where deltas[i] != 0 {
            let a = slopes[i] / deltas[i], b = slopes[i + 1] / deltas[i]
            let s = a * a + b * b
            if s > 9 {
                let t = 3 / s.squareRoot()
                slopes[i] = t * a * deltas[i]
                slopes[i + 1] = t * b * deltas[i]
            }
        }
        var out: [Point] = []
        for i in 0..<(k - 1) {
            let p0 = anchors[i], p1 = anchors[i + 1]
            let dy = p1.y - p0.y
            for s in 0..<n {
                let t = Double(s) / Double(n)
                let h00 = 2 * t * t * t - 3 * t * t + 1, h10 = t * t * t - 2 * t * t + t
                let h01 = -2 * t * t * t + 3 * t * t, h11 = t * t * t - t * t
                let x = h00 * p0.x + h10 * dy * slopes[i] + h01 * p1.x + h11 * dy * slopes[i + 1]
                out.append(Point(x: x, y: p0.y + t * dy))
            }
        }
        out.append(anchors[k - 1])
        return out
    }
}

/// What the renderer may read (§102.3): an immutable snapshot of geometry plus its body revision. It has no
/// source labels and no write path back to the profile, but the widths are derived from the measurements and
/// let them be recovered, so it is `LOCAL_SENSITIVE` like the profile: stored encrypted, never sent anywhere.
public struct AvatarSnapshot: Codable, Hashable, Sendable {
    public let bodyRevision: Int
    public let silhouette: Silhouette
    /// Which baked body the 3D tier draws (ADR-011). The 2D silhouette does not depend on it.
    public let template: BodyTemplate

    public init(bodyRevision: Int, silhouette: Silhouette, template: BodyTemplate = .neutral) {
        self.bodyRevision = bodyRevision
        self.silhouette = silhouette
        self.template = template
    }

    public static func make(for profile: BodyProfile) throws(BodyEditError) -> AvatarSnapshot {
        AvatarSnapshot(bodyRevision: profile.revision, silhouette: try Silhouette.make(for: profile), template: profile.template)
    }

    enum CodingKeys: String, CodingKey { case bodyRevision, silhouette, template }

    // Caches written before ADR-011 have no template; a neutral snapshot writes none.
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        bodyRevision = try c.decode(Int.self, forKey: .bodyRevision)
        silhouette = try c.decode(Silhouette.self, forKey: .silhouette)
        template = try c.decodeIfPresent(BodyTemplate.self, forKey: .template) ?? .neutral
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(bodyRevision, forKey: .bodyRevision)
        try c.encode(silhouette, forKey: .silhouette)
        if template != .neutral { try c.encode(template, forKey: .template) }
    }
}
