import BodyGeometry
import Foundation

public enum PatternError: Error, Equatable, Sendable {
    case invalidMeasurement(String)
    case invalidGeometry(String)
}

/// What is being drafted. One list for body blocks and for patterns from a garment's own measurements.
public enum GarmentKind: String, Codable, CaseIterable, Sendable {
    case top, longSleeveTop, trousers, shorts, skirt, dress, coat

    enum Family { case bodice, trousers, skirt }

    var family: Family {
        switch self {
        case .top, .longSleeveTop, .dress, .coat: .bodice
        case .trousers, .shorts: .trousers
        case .skirt: .skirt
        }
    }

    public var displayName: String {
        switch self {
        case .top: "Üst (kısa kollu)"
        case .longSleeveTop: "Üst (uzun kollu)"
        case .trousers: "Pantolon"
        case .shorts: "Şort"
        case .skirt: "Etek"
        case .dress: "Elbise"
        case .coat: "Kaban"
        }
    }
}

/// Wearing ease: total extra girth (cm) over the body at chest, waist and hip. A drafting allowance so
/// the body can move, not a fit or size statement.
public struct PatternEase: Codable, Hashable, Sendable {
    public var chestCm: Double
    public var waistCm: Double
    public var hipCm: Double

    public init(chestCm: Double, waistCm: Double, hipCm: Double) {
        self.chestCm = chestCm
        self.waistCm = waistCm
        self.hipCm = hipCm
    }

    /// Common block-drafting starting values per kind (loose tee to close skirt). Drafting hypotheses.
    public static func standard(for kind: GarmentKind) -> PatternEase {
        switch kind {
        case .top: PatternEase(chestCm: 10, waistCm: 10, hipCm: 8)
        case .longSleeveTop: PatternEase(chestCm: 12, waistCm: 12, hipCm: 10)
        case .coat: PatternEase(chestCm: 18, waistCm: 18, hipCm: 16)
        case .dress: PatternEase(chestCm: 8, waistCm: 6, hipCm: 6)
        case .trousers, .shorts: PatternEase(chestCm: 0, waistCm: 2, hipCm: 6)
        case .skirt: PatternEase(chestCm: 0, waistCm: 2, hipCm: 5)
        }
    }
}

/// One flat piece of a sewing pattern. The outline is the seam line (finished size); the cutting line is
/// the outline pushed out by the seam allowance.
public struct PatternPiece: Codable, Hashable, Sendable {
    public enum Role: String, Codable, CaseIterable, Sendable { case front, back, sleeve }

    /// Straight-of-grain line: lay it parallel to the fabric's selvedge.
    public struct Grainline: Codable, Hashable, Sendable {
        public let start: PatternPoint
        public let end: PatternPoint
        public init(start: PatternPoint, end: PatternPoint) {
            self.start = start
            self.end = end
        }
    }

    /// A named match point on the seam line ("underarm", "hip", …): where pieces line up when sewn.
    public struct Notch: Codable, Hashable, Sendable {
        public let name: String
        public let point: PatternPoint
        public init(_ name: String, _ point: PatternPoint) {
            self.name = name
            self.point = point
        }
    }

    public let name: String
    public let role: Role
    /// Closed seam-line polygon in cm (x across, 0 = centre line; y down from the top), positive area.
    public let outline: [PatternPoint]
    public let grainline: Grainline
    public let notches: [Notch]
    public let seamAllowanceCm: Double
    public let cutCount: Int
    /// True: the outline is half the piece, laid on the fabric fold along x = 0 (the centre line); the
    /// cut piece is the outline and its mirror image, and the fold edge gets no seam allowance.
    public let mirror: Bool

    /// Orders the outline to a positive area, then checks it (closed, simple, positive area).
    public init(name: String, role: Role, outline: [PatternPoint], grainline: Grainline, notches: [Notch],
                seamAllowanceCm: Double, cutCount: Int, mirror: Bool) throws(PatternError) {
        var pts = Polygon.dedup(outline)
        if Polygon.signedArea(pts) < 0 { pts.reverse() }
        self.name = name
        self.role = role
        self.outline = pts
        self.grainline = grainline
        self.notches = notches
        self.seamAllowanceCm = seamAllowanceCm
        self.cutCount = cutCount
        self.mirror = mirror
        try validate()
    }

    /// At least three distinct, finite points; no self-intersection; positive area; sane allowance.
    public func validate() throws(PatternError) {
        guard outline.count >= 3 else { throw .invalidGeometry("\(name): fewer than 3 points") }
        for p in outline where !(p.x.isFinite && p.y.isFinite) { throw .invalidGeometry("\(name): non-finite point") }
        guard Polygon.signedArea(outline) > 1 else { throw .invalidGeometry("\(name): no area") }
        guard Polygon.isSimple(outline) else { throw .invalidGeometry("\(name): self-intersecting outline") }
        guard seamAllowanceCm.isFinite, seamAllowanceCm >= 0, seamAllowanceCm <= 5 else { throw .invalidGeometry("\(name): seam allowance") }
        guard cutCount >= 1 else { throw .invalidGeometry("\(name): cut count") }
    }

    public var areaCm2: Double { Polygon.signedArea(outline) }
    public var bounds: PatternBounds { Polygon.bounds(outline) }

    /// Left and right seam-line x at depth `y` (cm), or nil outside the piece.
    public func span(atY y: Double) -> ClosedRange<Double>? { Polygon.span(outline, atY: y) }

    /// Seam-line width at depth `y` (cm); 0 outside the piece.
    public func width(atY y: Double) -> Double { span(atY: y).map { $0.upperBound - $0.lowerBound } ?? 0 }

    public func notch(_ name: String) -> PatternPoint? { notches.first { $0.name == name }?.point }

    /// Fold edges: on a mirrored piece, edges lying on x = 0.
    func isFoldEdge(_ i: Int) -> Bool {
        guard mirror else { return false }
        let a = outline[i], b = outline[(i + 1) % outline.count]
        return abs(a.x) < 1e-9 && abs(b.x) < 1e-9
    }

    /// The cutting line: the seam line pushed out by the seam allowance, except along a fold.
    public var cuttingOutline: [PatternPoint] {
        Polygon.offset(outline, by: outline.indices.map { isFoldEdge($0) ? 0 : seamAllowanceCm })
    }
}

/// A full pattern: its pieces and where the numbers came from.
public struct SewingPattern: Codable, Hashable, Sendable {
    public enum Source: String, Codable, Sendable {
        /// Drafted from body measurements plus ease (a basic block).
        case bodyBlock
        /// Drafted from a garment's own finished measurements (flat-lay or typed).
        case garmentMeasurements
    }

    public let kind: GarmentKind
    public let pieces: [PatternPiece]
    public let source: Source
    /// The ease drafted in, for a body block. Nil for a pattern from garment measurements: the garment's
    /// own ease is already in its finished size and cannot be separated from it.
    public let ease: PatternEase?
    /// Human-readable origin of every number (Turkish, for the UI): measured, estimated or derived.
    public let provenance: String

    public init(kind: GarmentKind, pieces: [PatternPiece], source: Source, ease: PatternEase?, provenance: String) {
        self.kind = kind
        self.pieces = pieces
        self.source = source
        self.ease = ease
        self.provenance = provenance
    }

    public func piece(_ role: PatternPiece.Role) -> PatternPiece? { pieces.first { $0.role == role } }

    /// What a flat-lay measurement across the garment reads at depth `y`: front half-width plus back
    /// half-width (half the finished circumference). Uses both pieces at the same depth.
    public func flatWidth(atY y: Double) -> Double? {
        guard let f = piece(.front), let b = piece(.back) else { return nil }
        return f.width(atY: y) + b.width(atY: y)
    }
}

/// A garment's finished measurements, as a flat-lay measurement (V37-03) or the user supplies them.
/// Every value carries its source, so a photo estimate is never shown as a measurement.
public struct GarmentMeasurements: Codable, Hashable, Sendable {
    public enum Source: String, Codable, Sendable {
        case userMeasured = "USER_MEASURED"
        case photoEstimated = "PHOTO_ESTIMATED"

        public var label: String { self == .userMeasured ? "senin ölçün" : "fotoğraftan tahmin" }
    }

    public struct Value: Codable, Hashable, Sendable {
        public let cm: Double
        public let source: Source
        public init(_ cm: Double, _ source: Source) {
            self.cm = cm
            self.source = source
        }
    }

    public let kind: GarmentKind
    /// Tops, dresses, coats: pit-to-pit width, laid flat. Trousers, shorts, skirts: flat width across the hip.
    public let bodyWidth: Value
    /// Tops, dresses, coats: high shoulder point (beside the collar) to hem. Bottoms: side waist to hem.
    public let length: Value
    /// Shoulder seam to cuff.
    public let sleeveLength: Value?
    /// Flat width at the hem (bottoms: flat leg opening).
    public let hemWidth: Value?
    /// Flat width at the waist.
    public let waistWidth: Value?
    /// Crotch to hem, along the inside leg.
    public let inseam: Value?

    public init(kind: GarmentKind, bodyWidth: Value, length: Value, sleeveLength: Value? = nil, hemWidth: Value? = nil,
                waistWidth: Value? = nil, inseam: Value? = nil) {
        self.kind = kind
        self.bodyWidth = bodyWidth
        self.length = length
        self.sleeveLength = sleeveLength
        self.hemWidth = hemWidth
        self.waistWidth = waistWidth
        self.inseam = inseam
    }

    /// Finite and inside generous garment ranges, so a typo or a bad photo estimate fails loudly.
    public func validate() throws(PatternError) {
        let checks: [(String, Value?, ClosedRange<Double>)] = [
            ("bodyWidth", bodyWidth, 15...150), ("length", length, 15...200), ("sleeveLength", sleeveLength, 3...100),
            ("hemWidth", hemWidth, 8...200), ("waistWidth", waistWidth, 15...150), ("inseam", inseam, 2...120),
        ]
        for (name, value, range) in checks {
            guard let value else { continue }
            guard value.cm.isFinite, range.contains(value.cm) else { throw .invalidMeasurement(name) }
        }
    }
}
