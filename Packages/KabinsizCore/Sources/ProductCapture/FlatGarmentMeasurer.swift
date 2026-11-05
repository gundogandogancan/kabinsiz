import CoreGraphics
import Foundation
import Vision

// V37-03 ("ebat tanıma"). The user lays a garment flat with an A4 sheet (210 × 297 mm) beside it and takes
// one photo from above. The sheet is the only ruler: its four corners give a homography from the photo to
// a metric plane, so a slightly tilted phone still measures right. No sheet, no centimetres: the scale is
// never guessed (fail closed). Every number is a photo estimate with a ± range the user confirms; it is
// never presented as a tape-measure value. Runs on the device; the photo is not stored or sent.

/// How the garment lies, which decides what is measured.
public enum FlatGarmentLayout: String, Codable, Sendable {
    /// T-shirt, shirt, knit, coat, dress: length, pit-to-pit width, hem width.
    case top = "TOP"
    /// Trousers, shorts, skirt: length, waist width, hem (leg opening) width, inseam when the legs part.
    case bottom = "BOTTOM"
}

/// A 3 × 3 plane-to-plane projective map (row-major, `m[8]` normalised to 1).
public struct PlaneHomography: Hashable, Sendable {
    public let m: [Double]

    public init(matrix: [Double]) {
        precondition(matrix.count == 9, "a homography has 9 entries")
        let s = matrix[8] == 0 ? 1 : matrix[8]
        m = matrix.map { $0 / s }
    }

    /// The exact map taking four points to four points (DLT with h33 = 1, an 8 × 8 linear solve).
    /// Points are normalised first (Hartley) so pixel coordinates in the thousands stay well conditioned.
    /// Nil when three of the points are collinear.
    public init?(mapping from: [SIMD2<Double>], to: [SIMD2<Double>]) {
        guard from.count == 4, to.count == 4 else { return nil }
        let t1 = Self.normaliser(from), t2 = Self.normaliser(to)
        let a = from.map { Self.mul3(t1, $0) }, b = to.map { Self.mul3(t2, $0) }
        var rows: [[Double]] = [], rhs: [Double] = []
        for i in 0 ..< 4 {
            let (x, y, u, v) = (a[i].x, a[i].y, b[i].x, b[i].y)
            rows.append([x, y, 1, 0, 0, 0, -u * x, -u * y]); rhs.append(u)
            rows.append([0, 0, 0, x, y, 1, -v * x, -v * y]); rhs.append(v)
        }
        guard let h = Self.solve(rows, rhs), let t2inv = Self.invert(t2) else { return nil }
        let full = Self.matmul(t2inv, Self.matmul(h + [1], t1))
        guard abs(full[8]) > 1e-12, full.allSatisfy(\.isFinite) else { return nil }
        self.init(matrix: full)
    }

    /// The mapped point, or nil on the line sent to infinity.
    public func apply(_ p: SIMD2<Double>) -> SIMD2<Double>? {
        let w = m[6] * p.x + m[7] * p.y + m[8]
        guard abs(w) > 1e-12 else { return nil }
        return SIMD2((m[0] * p.x + m[1] * p.y + m[2]) / w, (m[3] * p.x + m[4] * p.y + m[5]) / w)
    }

    public var inverse: PlaneHomography? { Self.invert(m).map(PlaneHomography.init(matrix:)) }

    /// Gaussian elimination with partial pivoting. Nil when the system is singular.
    package static func solve(_ a: [[Double]], _ b: [Double]) -> [Double]? {
        let n = b.count
        var m = a, r = b
        for col in 0 ..< n {
            guard let pivot = (col ..< n).max(by: { abs(m[$0][col]) < abs(m[$1][col]) }), abs(m[pivot][col]) > 1e-12 else { return nil }
            m.swapAt(col, pivot); r.swapAt(col, pivot)
            for row in col + 1 ..< n {
                let f = m[row][col] / m[col][col]
                guard f != 0 else { continue }
                for k in col ..< n { m[row][k] -= f * m[col][k] }
                r[row] -= f * r[col]
            }
        }
        var x = [Double](repeating: 0, count: n)
        for row in stride(from: n - 1, through: 0, by: -1) {
            var s = r[row]
            for k in row + 1 ..< n { s -= m[row][k] * x[k] }
            x[row] = s / m[row][row]
        }
        return x.allSatisfy(\.isFinite) ? x : nil
    }

    static func normaliser(_ pts: [SIMD2<Double>]) -> [Double] {
        let c = pts.reduce(.zero, +) / Double(pts.count)
        let mean = pts.map { (($0 - c) * ($0 - c)).sum().squareRoot() }.reduce(0, +) / Double(pts.count)
        let s = mean > 0 ? 2.0.squareRoot() / mean : 1
        return [s, 0, -s * c.x, 0, s, -s * c.y, 0, 0, 1]
    }

    static func mul3(_ t: [Double], _ p: SIMD2<Double>) -> SIMD2<Double> {
        let w = t[6] * p.x + t[7] * p.y + t[8]
        return SIMD2((t[0] * p.x + t[1] * p.y + t[2]) / w, (t[3] * p.x + t[4] * p.y + t[5]) / w)
    }

    static func matmul(_ a: [Double], _ b: [Double]) -> [Double] {
        var out = [Double](repeating: 0, count: 9)
        for i in 0 ..< 3 { for j in 0 ..< 3 { for k in 0 ..< 3 { out[i * 3 + j] += a[i * 3 + k] * b[k * 3 + j] } } }
        return out
    }

    static func invert(_ a: [Double]) -> [Double]? {
        let c00 = a[4] * a[8] - a[5] * a[7], c01 = a[5] * a[6] - a[3] * a[8], c02 = a[3] * a[7] - a[4] * a[6]
        let det = a[0] * c00 + a[1] * c01 + a[2] * c02
        guard abs(det) > 1e-15 else { return nil }
        let adj = [c00, a[2] * a[7] - a[1] * a[8], a[1] * a[5] - a[2] * a[4],
                   c01, a[0] * a[8] - a[2] * a[6], a[2] * a[3] - a[0] * a[5],
                   c02, a[1] * a[6] - a[0] * a[7], a[0] * a[4] - a[1] * a[3]]
        return adj.map { $0 / det }
    }
}

/// The A4 sheet found in the photo: the photo's ruler.
public struct A4SheetDetection: Sendable {
    public enum Method: String, Codable, Sendable {
        /// Apple Vision rectangle detector, corners refined on the pixels.
        case visionRectangle = "VISION_RECTANGLE"
        /// A bright near-white region found on the pixels alone (works without Vision, e.g. the simulator).
        case pixelRegion = "PIXEL_REGION"
    }

    public static let shortSideMM = 210.0
    public static let longSideMM = 297.0
    /// √2, ISO 216.
    public static let sideRatio = 297.0 / 210.0
    public static let ratioTolerance = 0.08

    /// Corners in photo pixels (origin top-left), clockwise from the top-left one.
    public let corners: [CGPoint]
    public let method: Method
    /// Long side ÷ short side of the sheet as seen: undone for perspective when the camera's focal length
    /// could be recovered from the quad (`focalLengthPx`), otherwise opposite sides averaged in the photo.
    public let measuredRatio: Double
    /// Focal length used to undo perspective (pixels); nil when the photo is square-on (the plain photo
    /// ratio is already right).
    public let focalLengthPx: Double?
    /// True when the focal length could not be recovered from the quad (one pair of sides parallel, the
    /// phone tilted along the sheet's own axis) and a typical phone main camera was assumed instead.
    public let focalLengthAssumed: Bool
    /// 0 when the phone was square above the sheet; grows with tilt (opposite sides differ in length).
    public let perspectiveIndex: Double
    /// Corner position uncertainty, pixels (edge-fit residual and edge blur).
    public let cornerSigmaPx: Double
    /// Median 20→80% brightness transition across the sheet edge, pixels (sharpness; 1 is crisp).
    public let edgeWidthPx: Double
    /// Shortest side in pixels.
    public let shortSidePx: Double
    /// Photo pixels → sheet plane millimetres.
    public let imageToPlane: PlaneHomography
}

/// Garment size from one flat-lay photo. Every value is `photoEstimated`, with a ± range.
public struct FlatGarmentMeasurement: Sendable {
    public enum Source: String, Codable, Sendable {
        /// Read from a photo against a reference sheet: an estimate, not a tape measure.
        case photoEstimated = "PHOTO_ESTIMATED"
    }

    public enum Kind: String, Codable, Sendable {
        case length = "LENGTH"
        case chestWidth = "CHEST_WIDTH"
        case hemWidth = "HEM_WIDTH"
        case waistWidth = "WAIST_WIDTH"
        case inseam = "INSEAM"
    }

    public struct Value: Hashable, Sendable {
        public let kind: Kind
        /// Plain Turkish name for the confirm screen.
        public let name: String
        public let cm: Double
        /// About two standard deviations, cm.
        public let uncertaintyCm: Double

        public var line: String { "\(name): \(Self.tr(cm)) ± \(Self.tr(uncertaintyCm)) cm" }

        static func tr(_ v: Double) -> String { String(format: "%.1f", v).replacingOccurrences(of: ".", with: ",") }
    }

    public let source: Source
    public let layout: FlatGarmentLayout
    public let values: [Value]
    public let sheet: A4SheetDetection
    public let maskMethod: CutoutMethod
    /// Plain Turkish lines on what this photo could not tell, shown with the numbers.
    public let limitations: [String]

    public func value(_ kind: Kind) -> Value? { values.first { $0.kind == kind } }
    public var length: Value? { value(.length) }
    public var chestWidth: Value? { value(.chestWidth) }
    public var hemWidth: Value? { value(.hemWidth) }
    public var waistWidth: Value? { value(.waistWidth) }
    public var inseam: Value? { value(.inseam) }

    /// The confirm screen's lines. Never presents an estimate as a measurement.
    public var summaryLines: [String] { values.map(\.line) + limitations }
}

public enum FlatGarmentMeasurer {
    public enum Failure: Error, Equatable, Sendable {
        case unreadableImage
        case noSheetFound
        case sheetNotA4(ratio: Double)
        case sheetTooSmall
        case tooTilted
        case noGarmentFound
        case garmentCutOff

        /// Why there are no centimetres, in plain Turkish.
        public var reason: String {
            switch self {
            case .unreadableImage: "Fotoğraf okunamadı: ölçü yok."
            case .noSheetFound: "Kâğıt bulunamadı: ölçü yok. Giysinin yanına düz, beyaz bir A4 kâğıt koy; dört köşesi görünsün."
            case let .sheetNotA4(ratio):
                "Kâğıt A4 oranında değil (\(FlatGarmentMeasurement.Value.tr(ratio)), A4 1,41): ölçü yok. Yalnız A4 kâğıt ölçek olur."
            case .sheetTooSmall: "Kâğıt fotoğrafta çok küçük: ölçü yok. Biraz yaklaş."
            case .tooTilted: "Telefon çok eğik: ölçü yok. Tam tepeden çek."
            case .noGarmentFound: "Giysi zeminden ayrılamadı: ölçü yok. Düz, tek renkli bir zemin kullan."
            case .garmentCutOff: "Giysi fotoğrafın kenarına taşıyor: ölçü yok. Giysinin tamamı kadraja girsin."
            }
        }
    }

    /// Perspective index above which the photo is refused (opposite sheet sides differ by more than 35%).
    static let maxPerspectiveIndex = 0.35
    /// The sheet's short side must span this many pixels, or a pixel is already ~3 mm.
    static let minSheetShortSidePx = 60.0

    /// Measures a flat-lay photo. `layout` nil = decided from the outline (two legs or a narrow waist → bottom).
    /// Throws `Failure` (with a Turkish `reason`) instead of guessing whenever the sheet is missing or unusable.
    public static func measure(_ image: CGImage, useVision: Bool = true, layout: FlatGarmentLayout? = nil) throws -> FlatGarmentMeasurement {
        try measure(image, useVision: useVision, layout: layout, maskOrder: useVision ? [.plainBackground, .vision] : [.plainBackground])
    }

    package enum MaskSource: Sendable { case plainBackground, vision }

    /// Mask order: the plain-background mask first because its edge is pixel-exact (the Vision mask is
    /// upscaled from a coarse map and softens the outline by a few pixels); Vision when the floor is busy.
    package static func measure(_ image: CGImage, useVision: Bool, layout: FlatGarmentLayout?, maskOrder: [MaskSource]) throws -> FlatGarmentMeasurement {
        guard let rgba = RGBABuffer(image) else { throw Failure.unreadableImage }
        let sheet = try findSheet(rgba, image: useVision ? image : nil)
        guard sheet.perspectiveIndex <= maxPerspectiveIndex else { throw Failure.tooTilted }
        let w = rgba.width, h = rgba.height

        // Garment mask: the analyzer's mask, minus the sheet (grown by its blurred edge), largest piece only.
        let keepOut = sheetKeepOut(sheet, width: w, height: h)
        var mask: [Float]?
        var method = CutoutMethod.none
        for source in maskOrder {
            let raw: [Float]? = switch source {
            case .plainBackground: GarmentPhotoAnalyzer.plainBackgroundMask(rgba)
            case .vision: try? GarmentPhotoAnalyzer.visionMask(image, width: w, height: h)
            }
            guard var m = raw else { continue }
            for i in keepOut { m[i] = 0 }
            let largest = largestComponent(m, width: w, height: h)
            if GarmentPhotoAnalyzer.coverage(of: largest) > 0.005 {
                mask = largest
                method = source == .vision ? .visionForeground : .plainBackground
                break
            }
        }
        guard let mask else { throw Failure.noGarmentFound }
        let b = GarmentPhotoAnalyzer.bounds(of: mask, width: w)
        guard b.minX > 0, b.minY > 0, Int(b.maxX) < w, Int(b.maxY) < h else { throw Failure.garmentCutOff }

        // Metric plane, turned so the garment's own axis is vertical: garments lie mirror-symmetric, so the
        // axis is the mirror line of the flat outline, searched within ±30° of the photo's "up" (the user lays
        // the collar or waist towards the top of the frame; the phone and the sheet may be turned).
        let toPlane = sheet.imageToPlane
        guard let toImage = toPlane.inverse else { throw Failure.noSheetFound }
        var sum = SIMD2<Double>.zero, count = 0.0
        for y in Int(b.minY) ..< Int(b.maxY) { for x in Int(b.minX) ..< Int(b.maxX) where mask[y * w + x] > 0.5 { sum += SIMD2(Double(x) + 0.5, Double(y) + 0.5); count += 1 } }
        let centre = sum / count
        guard let p0 = toPlane.apply(centre), let pUp = toPlane.apply(centre - SIMD2(0, 20)),
              let pRight = toPlane.apply(centre + SIMD2(1, 0)), let pDown = toPlane.apply(centre + SIMD2(0, 1)) else { throw Failure.tooTilted }
        let up = pUp - p0
        let rot = Rotation(-Double.pi / 2 - garmentAxisAngle(mask, width: w, height: h, bounds: b, toPlane: toPlane, toImage: toImage,
                                                             upAngle: atan2(up.y, up.x)))
        let jx = pRight - p0, jy = pDown - p0
        let mmPerPx = abs(jx.x * jy.y - jx.y * jy.x).squareRoot()

        let bx0 = Double(b.minX), by0 = Double(b.minY), bx1 = Double(b.maxX), by1 = Double(b.maxY)
        let boxCorners: [SIMD2<Double>] = [SIMD2(bx0, by0), SIMD2(bx1, by0), SIMD2(bx1, by1), SIMD2(bx0, by1)]
        let metricCorners = try boxCorners.map { c -> SIMD2<Double> in
            guard let p = toPlane.apply(c) else { throw Failure.tooTilted }
            return rot.apply(p)
        }
        let lo: SIMD2<Double> = metricCorners.dropFirst().reduce(metricCorners[0]) { pointwiseMin($0, $1) } - 5
        let hi: SIMD2<Double> = metricCorners.dropFirst().reduce(metricCorners[0]) { pointwiseMax($0, $1) } + 5
        var cell = 1.0
        while (hi.x - lo.x) / cell * ((hi.y - lo.y) / cell) > 6_000_000 { cell *= 2 }
        let gw = Int(((hi.x - lo.x) / cell).rounded(.up))
        let gh = Int(((hi.y - lo.y) / cell).rounded(.up))
        var grid = [Bool](repeating: false, count: gw * gh)
        for gy in 0 ..< gh {
            for gx in 0 ..< gw {
                let q = lo + SIMD2((Double(gx) + 0.5) * cell, (Double(gy) + 0.5) * cell)
                guard let p = toImage.apply(rot.inverse(q)) else { continue }
                let ix = Int(p.x.rounded(.down)), iy = Int(p.y.rounded(.down))
                if ix >= 0, iy >= 0, ix < w, iy < h, mask[iy * w + ix] > 0.5 { grid[gy * gw + gx] = true }
            }
        }
        let metric = MetricMask(width: gw, height: gh, cell: cell, on: grid)
        guard let rows = metric.rowRange else { throw Failure.noGarmentFound }

        let chosen = layout ?? autoLayout(metric)

        // Error model inputs.
        let sheetCentre = sheet.corners.reduce(SIMD2<Double>.zero) { $0 + SIMD2(Double($1.x), Double($1.y)) } / 4
        let halfDiagonal = 0.25 * (distance(sheet.corners[0], sheet.corners[2]) + distance(sheet.corners[1], sheet.corners[3]))
        let reach = boxCorners.map { (($0 - sheetCentre) * ($0 - sheetCentre)).sum().squareRoot() }.max()! / halfDiagonal
        let errors = ErrorModel(mmPerPx: mmPerPx, maskEdgePx: method == .visionForeground ? 2.5 : 1.0,
                                relativeScale: sheet.cornerSigmaPx * 2.0.squareRoot() / sheet.shortSidePx * (1 + 0.25 * max(0, reach - 1)),
                                perspectiveIndex: sheet.perspectiveIndex, cell: cell)

        var limitations = ["Fotoğraftan tahmin · ölçü değil: her satırı onaylamadan kaydedilmez.",
                           "Kırışıklık, katlanan kenar ve kumaş kalınlığı hesaba katılmadı; giysiyi düz ser."]
        var values: [FlatGarmentMeasurement.Value] = []
        func add(_ kind: FlatGarmentMeasurement.Kind, _ name: String, _ mm: Double, extraMM: Double = 0) {
            values.append(.init(kind: kind, name: name, cm: (mm / 10 * 10).rounded() / 10, uncertaintyCm: errors.plusMinusCM(mm, extraMM: extraMM)))
        }
        let lengthMM = Double(rows.upperBound - rows.lowerBound + 1) * cell
        let cm10 = max(1, Int((10 / cell).rounded())), mm5 = max(1, Int((5 / cell).rounded()))

        switch chosen {
        case .top:
            add(.length, "Boy (en üst nokta–etek ucu)", lengthMM)
            let r = measureTop(metric, rows: rows, cm10: cm10, mm5: mm5)
            if let chest = r.chestMM {
                add(.chestWidth, "Koltuk altı genişliği", chest)
            } else {
                limitations.append("Kol altı bulunamadı: koltuk altı genişliği yok. Kolları gövdeden ayırıp yana aç.")
            }
            if let hem = r.hemMM { add(.hemWidth, "Etek ucu genişliği", hem) }
        case .bottom:
            add(.length, "Boy (bel–paça)", lengthMM)
            let r = measureBottom(metric, rows: rows, cm10: cm10, mm5: mm5)
            if let waist = r.waistMM { add(.waistWidth, "Bel genişliği", waist) }
            if let hem = r.hemMM { add(.hemWidth, r.legs ? "Paça genişliği" : "Etek ucu genişliği", hem) }
            if let inseam = r.inseamMM {
                add(.inseam, "İç bacak boyu", inseam, extraMM: r.inseamExtraMM)
                limitations.append("İç bacak, bacaklar düz ve paralel serildiğinde doğrudur; ağ noktası şekilden kestirildi.")
            } else {
                limitations.append("Bacaklar ayrı görünmüyor: iç bacak boyu yok.")
            }
        }

        if sheet.focalLengthAssumed {
            limitations.append("Kâğıdın oranı tipik bir telefon kamerası varsayılarak düzeltildi; kırpılmış fotoğrafta güvenme.")
        }
        if sheet.perspectiveIndex > 0.12 {
            limitations.append("Telefon eğik tutulmuş: perspektif düzeltildi ama hata payı büyüdü. Tam tepeden çekmek daha iyi.")
        }
        if reach > 8 { limitations.append("Kâğıt giysiye göre küçük ya da uzak: kâğıdı giysinin hemen yanına koy.") }
        if sheet.edgeWidthPx > 3 { limitations.append("Kâğıdın kenarı bulanık: fotoğraf net değil, hata payı büyüdü.") }
        if method == .visionForeground { limitations.append("Zemin düz değil: giysi Vision ile ayrıldı, kenarlar birkaç milimetre oynayabilir.") }
        let rgb = GarmentPhotoAnalyzer.dominantColour(rgba, mask: mask)
        if min(rgb.x, rgb.y, rgb.z) > 0.75 { limitations.append("Giysi beyaza yakın: kâğıtla karışabilir; koyu bir zemin kullan.") }

        return FlatGarmentMeasurement(source: .photoEstimated, layout: chosen, values: values, sheet: sheet, maskMethod: method, limitations: limitations)
    }

    /// Direction (radians, plane coordinates) of the garment's vertical axis: the mirror line of the outline
    /// on the metric plane. The outline is sampled on an even 8 mm grid (so near and far parts of a tilted
    /// photo weigh the same); for each candidate direction through the outline's centroid, the share of
    /// cells whose mirror image is also garment is scored. Coarse search ±30° around the photo's up in 1°
    /// steps, then ±1° in 0.1° steps. An outline that is not mirror-like (best score < 0.6, e.g. a folded
    /// sleeve) keeps the photo's up.
    static func garmentAxisAngle(_ mask: [Float], width: Int, height: Int, bounds b: CGRect,
                                 toPlane: PlaneHomography, toImage: PlaneHomography, upAngle: Double) -> Double {
        let corners = [(b.minX, b.minY), (b.maxX, b.minY), (b.maxX, b.maxY), (b.minX, b.maxY)]
            .compactMap { toPlane.apply(SIMD2(Double($0.0), Double($0.1))) }
        guard corners.count == 4 else { return upAngle }
        let lo: SIMD2<Double> = corners.dropFirst().reduce(corners[0]) { pointwiseMin($0, $1) }
        let hi: SIMD2<Double> = corners.dropFirst().reduce(corners[0]) { pointwiseMax($0, $1) }
        let cell = max(8.0, max(hi.x - lo.x, hi.y - lo.y) / 250)
        let gw = Int(((hi.x - lo.x) / cell).rounded(.up)) + 1, gh = Int(((hi.y - lo.y) / cell).rounded(.up)) + 1
        var occ = [Bool](repeating: false, count: gw * gh)
        var pts: [SIMD2<Double>] = []
        for gy in 0 ..< gh {
            for gx in 0 ..< gw {
                let q = lo + SIMD2((Double(gx) + 0.5) * cell, (Double(gy) + 0.5) * cell)
                guard let p = toImage.apply(q) else { continue }
                let ix = Int(p.x.rounded(.down)), iy = Int(p.y.rounded(.down))
                if ix >= 0, iy >= 0, ix < width, iy < height, mask[iy * width + ix] > 0.5 {
                    occ[gy * gw + gx] = true
                    pts.append(q)
                }
            }
        }
        guard pts.count > 50 else { return upAngle }
        let m = pts.reduce(.zero, +) / Double(pts.count)
        func score(_ angle: Double) -> Double {
            let d = SIMD2(cos(angle), sin(angle))
            var hit = 0
            for p in pts {
                let r = 2 * (m + d * ((p - m) * d).sum()) - p
                let gx = Int(((r.x - lo.x) / cell).rounded(.down)), gy = Int(((r.y - lo.y) / cell).rounded(.down))
                if gx >= 0, gy >= 0, gx < gw, gy < gh, occ[gy * gw + gx] { hit += 1 }
            }
            return Double(hit) / Double(pts.count)
        }
        /// The best score and the middle of the angles that reach it (a coarse grid scores a plateau).
        func best(_ centre: Double, _ span: Double, _ step: Double) -> (Double, Double) {
            let angles = Array(stride(from: centre - span, through: centre + span + 1e-9, by: step))
            let scores = angles.map(score)
            let top = scores.max()!
            let at = angles.indices.filter { scores[$0] >= top - 1e-9 }
            return (angles[at[at.count / 2]], top)
        }
        let coarse = best(upAngle, .pi / 6, .pi / 180)
        let fine = best(coarse.0, .pi / 180, .pi / 1800)
        return fine.1 >= 0.6 ? fine.0 : upAngle
    }

    // MARK: Measurement rules (metric plane, rows top → bottom, 1 cell = `cell` mm)

    /// Tops. Length = highest to lowest garment row. Pit-to-pit: scanning up from the hem, the run under the
    /// garment's centre line is the torso; where the sleeves join it the run jumps wider (> 15% and > 3 cm
    /// against the row 1 cm lower) — that row is the armpit. The chest width is read 2.5 cm below it (the
    /// usual "one inch below the armpit" rule), so seam blur at the joint does not count. The jump is only
    /// accepted in the upper 60% of the garment. Hem width = the centre run 5 mm above the lowest row.
    static func measureTop(_ g: MetricMask, rows: ClosedRange<Int>, cm10: Int, mm5: Int) -> (chestMM: Double?, hemMM: Double?) {
        let yTop = rows.lowerBound, yBot = rows.upperBound
        let hemRow = max(yTop, yBot - mm5)
        guard let base = g.extent(max(yTop, yBot - cm10)) else { return (nil, nil) }
        let cx = (base.lowerBound + base.upperBound) / 2
        let hem = g.run(containing: cx, row: hemRow).map { g.width($0) }
        let lowestAllowed = yTop + Int(Double(yBot - yTop) * 0.6)
        let highest = yTop + Int(Double(yBot - yTop) * 0.1)
        var armpit: Int?
        var y = yBot - cm10
        while y >= highest {
            if y <= lowestAllowed, let a = g.run(containing: cx, row: y), let below = g.run(containing: cx, row: y + cm10) {
                let wa = g.width(a), wb = g.width(below)
                if wa > wb * 1.15, wa - wb > 30 { armpit = y; break }
            }
            y -= 1
        }
        guard let armpit else { return (nil, hem) }
        let chestRow = min(hemRow, armpit + Int((25 / g.cell).rounded()))
        return (g.run(containing: cx, row: chestRow).map { g.width($0) }, hem)
    }

    /// Bottoms. Waist = full width 5 mm below the top edge. Legs: rows where the centre line (the waist's
    /// midpoint) is empty with garment on both sides, counted up from the hem; they must reach ≥ 10% of the
    /// length (and ≥ 3 cm). Hem = mean leg-opening width 5 mm above the lowest row (or the full width for a
    /// skirt). Inseam: the inner edge of each leg as a polyline (2 cm steps) from the crotch to the hem;
    /// the crotch is where the two inner edges, fitted as lines over the top of the gap, meet (the gap's
    /// narrow apex is below one cell and cannot be seen directly). The two legs are averaged.
    static func measureBottom(_ g: MetricMask, rows: ClosedRange<Int>, cm10: Int, mm5: Int)
        -> (waistMM: Double?, hemMM: Double?, inseamMM: Double?, inseamExtraMM: Double, legs: Bool) {
        let yTop = rows.lowerBound, yBot = rows.upperBound
        guard let waistRun = g.extent(min(yBot, yTop + mm5)) else { return (nil, nil, nil, 0, false) }
        let waist = g.width(waistRun)
        let cx = (waistRun.lowerBound + waistRun.upperBound) / 2
        let hemRow = max(yTop, yBot - mm5)

        func legs(_ y: Int) -> (left: ClosedRange<Int>, right: ClosedRange<Int>)? {
            let runs = g.runs(y)
            guard !runs.contains(where: { $0.contains(cx) }),
                  let l = runs.filter({ $0.upperBound < cx }).max(by: { $0.upperBound < $1.upperBound }),
                  let r = runs.filter({ $0.lowerBound > cx }).min(by: { $0.lowerBound < $1.lowerBound }) else { return nil }
            return (l, r)
        }
        var gapTop: Int?
        var misses = 0
        var y = hemRow
        while y > yTop {
            if legs(y) != nil { gapTop = y; misses = 0 } else if gapTop != nil {
                misses += 1
                if misses > max(2, mm5 / 2) { break }
            } else if y < hemRow - cm10 { break }
            y -= 1
        }
        let length = Double(yBot - yTop + 1) * g.cell
        guard let top = gapTop, Double(hemRow - top) * g.cell >= max(30, 0.1 * length), let hemLegs = legs(hemRow) else {
            return (waist, g.extent(hemRow).map { g.width($0) }, nil, 0, false)
        }
        let hem = (g.width(hemLegs.left) + g.width(hemLegs.right)) / 2

        // Inner edges in mm: left leg's right boundary, right leg's left boundary.
        func innerEdges(_ y: Int) -> (l: Double, r: Double)? {
            legs(y).map { (Double($0.left.upperBound + 1) * g.cell, Double($0.right.lowerBound) * g.cell) }
        }
        let fitRows = max(10, (hemRow - top) * 15 / 100)
        var ls: [SIMD2<Double>] = [], rs: [SIMD2<Double>] = []
        for yy in top ... min(hemRow, top + fitRows) {
            if let e = innerEdges(yy) {
                let ym = (Double(yy) + 0.5) * g.cell
                ls.append(SIMD2(ym, e.l)); rs.append(SIMD2(ym, e.r))
            }
        }
        let topY = (Double(top) + 0.5) * g.cell
        var apexY = topY
        if let fl = lineFit(ls), let fr = lineFit(rs), abs(fl.b - fr.b) > 1e-3 {
            apexY = min(topY, max(topY - 100, max(Double(yTop) * g.cell, (fr.a - fl.a) / (fl.b - fr.b))))
        }
        let apexX = { () -> Double in
            guard let fl = lineFit(ls), let fr = lineFit(rs) else { return Double(cx) * g.cell }
            return (fl.a + fl.b * apexY + fr.a + fr.b * apexY) / 2
        }()
        let step = max(1, Int((20 / g.cell).rounded()))
        var legLengths: [Double] = []
        for side in 0 ..< 2 {
            var pts = [SIMD2(apexX, apexY)]
            var yy = top
            while yy < yBot {
                if let e = innerEdges(yy) { pts.append(SIMD2(side == 0 ? e.l : e.r, (Double(yy) + 0.5) * g.cell)) }
                yy += step
            }
            if let e = innerEdges(hemRow) { pts.append(SIMD2(side == 0 ? e.l : e.r, Double(yBot + 1) * g.cell)) }
            legLengths.append(zip(pts, pts.dropFirst()).map { (($1 - $0) * ($1 - $0)).sum().squareRoot() }.reduce(0, +))
        }
        let inseam = legLengths.reduce(0, +) / 2
        return (waist, hem, inseam, 3 + 0.25 * (topY - apexY), true)
    }

    /// Two legs (the analyzer's shape rule) or a narrow waist over a wide hem (a skirt) → bottom.
    static func autoLayout(_ g: MetricMask) -> FlatGarmentLayout {
        let floats = g.on.map { $0 ? Float(1) : 0 }
        guard let f = ShapeCategorizer.features(mask: floats, width: g.width, height: g.height) else { return .top }
        if f.legGap > 0.5 || (f.topToHem < 0.8 && f.aspect < 1.3 && f.aspect >= 0.7) { return .bottom }
        return .top
    }

    /// Least-squares x = a + b·y over (y, x) pairs.
    static func lineFit(_ pts: [SIMD2<Double>]) -> (a: Double, b: Double)? {
        guard pts.count >= 3 else { return nil }
        let n = Double(pts.count)
        let my = pts.map(\.x).reduce(0, +) / n, mx = pts.map(\.y).reduce(0, +) / n
        let syy = pts.map { ($0.x - my) * ($0.x - my) }.reduce(0, +)
        guard syy > 1e-9 else { return nil }
        let b = pts.map { ($0.x - my) * ($0.y - mx) }.reduce(0, +) / syy
        return (mx - b * my, b)
    }

    // MARK: Error model

    /// Uncertainty, honest about its parts: pixel size and mask edge at both ends of a span, the sheet's
    /// corner error turned into a scale error (worse the farther the garment reaches from the sheet),
    /// tilt (garment thickness above the floor and lens bending grow with it: 5% of the span per unit of
    /// perspective index) and the metric grid's own step. Reported as ±2σ, rounded up to 0.1 cm.
    struct ErrorModel {
        let mmPerPx: Double
        let maskEdgePx: Double
        let relativeScale: Double
        let perspectiveIndex: Double
        let cell: Double

        func plusMinusCM(_ spanMM: Double, extraMM: Double = 0) -> Double {
            let pixel = mmPerPx * maskEdgePx * 2.0.squareRoot()
            let scale = spanMM * relativeScale
            let tilt = spanMM * 0.05 * perspectiveIndex
            let grid = 0.5 * cell * 2.0.squareRoot()
            let sigma = (pixel * pixel + scale * scale + tilt * tilt + grid * grid + extraMM * extraMM).squareRoot()
            return max(0.2, (2 * sigma).rounded(.up) / 10)
        }
    }

    // MARK: Sheet

    /// Finds the A4 sheet: Vision rectangles (when an image is given) plus the pixel detector, each candidate
    /// checked for paper (bright, near-white, brighter than around it), corners refined on the pixels,
    /// then the side ratio checked against √2 ± 0.08. The largest passing sheet wins.
    ///
    /// Tilt changes a sheet's apparent proportions (a 20° tilt shortens it by ~6%), so with visible
    /// perspective the true ratio is recovered first (`rectifiedRatio`); without it the photo ratio is used.
    package static func findSheet(_ rgba: RGBABuffer, image: CGImage?) throws -> A4SheetDetection {
        var candidates: [([SIMD2<Double>], A4SheetDetection.Method)] = []
        if let image, let quads = try? visionQuads(image) { candidates += quads.map { ($0, .visionRectangle) } }
        candidates += pixelQuads(rgba).map { ($0, .pixelRegion) }
        let luma = LumaImage(rgba)
        var best: (A4SheetDetection, Double)?
        var offRatio: (Double, Double)?
        var tooSmall = false
        for (quad, method) in candidates {
            guard isPaper(orderCorners(quad), rgba, luma) else { continue }
            let refined = refineCorners(orderCorners(quad), luma)
            let c = orderCorners(refined.corners)
            let s = (0 ..< 4).map { simdDistance(c[$0], c[($0 + 1) % 4]) }
            let area = polygonArea(c)
            let a = s[0] + s[2], b = s[1] + s[3]
            let perspective = max(abs(s[0] - s[2]) / max(s[0], s[2]), abs(s[1] - s[3]) / max(s[1], s[3]))
            let rectified = perspective >= 0.02 ? rectifiedRatio(c, width: rgba.width, height: rgba.height) : nil
            let widthOverHeight = rectified?.widthOverHeight ?? a / b
            let ratio = max(widthOverHeight, 1 / widthOverHeight)
            guard s.min()! >= minSheetShortSidePx else { tooSmall = true; continue }
            guard abs(ratio - A4SheetDetection.sideRatio) <= A4SheetDetection.ratioTolerance else {
                if offRatio == nil || area > offRatio!.1 { offRatio = (ratio, area) }
                continue
            }
            let portrait = widthOverHeight < 1
            let plane: [SIMD2<Double>] = portrait
                ? [SIMD2(0, 0), SIMD2(210, 0), SIMD2(210, 297), SIMD2(0, 297)]
                : [SIMD2(0, 0), SIMD2(297, 0), SIMD2(297, 210), SIMD2(0, 210)]
            guard let hom = PlaneHomography(mapping: c, to: plane) else { continue }
            let det = A4SheetDetection(corners: c.map { CGPoint(x: $0.x, y: $0.y) }, method: method, measuredRatio: ratio, focalLengthPx: rectified?.focalPx,
                                       focalLengthAssumed: rectified?.assumed ?? false,
                                       perspectiveIndex: perspective, cornerSigmaPx: refined.sigma, edgeWidthPx: refined.edgeWidth,
                                       shortSidePx: s.min()!, imageToPlane: hom)
            if best == nil || area > best!.1 * 1.02 { best = (det, area) }
        }
        if let best { return best.0 }
        if let offRatio { throw Failure.sheetNotA4(ratio: offRatio.0) }
        if tooSmall { throw Failure.sheetTooSmall }
        throw Failure.noSheetFound
    }

    /// The true width ÷ height of a rectangle seen as the quad `c` (TL, TR, BR, BL), after Zhang & He,
    /// "Whiteboard scanning and image enhancement" (2007): the focal length follows from the quad's two
    /// vanishing points, assuming square pixels and the principal point at the photo's centre (true for
    /// an uncropped phone photo). When the focal length is not determined (one pair of sides parallel) or
    /// implausible (outside 0.2–10 × the photo's long side), a phone main camera is assumed: 26 mm
    /// equivalent ≈ 0.75 × the long side of a 4:3 photo (`assumed` = true; the ±0.08 ratio tolerance
    /// absorbs a wrong guess of ±20% at moderate tilt). Nil only for a degenerate quad.
    static func rectifiedRatio(_ c: [SIMD2<Double>], width: Int, height: Int) -> (widthOverHeight: Double, focalPx: Double, assumed: Bool)? {
        let scale = Double(max(width, height))
        let centre = SIMD2(Double(width), Double(height)) / 2
        // m1 = TL, m2 = TR, m3 = BL, m4 = BR, centred on the principal point and scaled to ~1.
        let m = [c[0], c[1], c[3], c[2]].map { p -> SIMD3<Double> in let q = (p - centre) / scale; return SIMD3(q.x, q.y, 1) }
        func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
            SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
        }
        func dot(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double { (a * b).sum() }
        let d2 = dot(cross(m[1], m[3]), m[2]), d3 = dot(cross(m[2], m[3]), m[1])
        guard abs(d2) > 1e-12, abs(d3) > 1e-12 else { return nil }
        let k2 = dot(cross(m[0], m[3]), m[2]) / d2
        let k3 = dot(cross(m[0], m[3]), m[1]) / d3
        let n2 = k2 * m[1] - m[0], n3 = k3 * m[2] - m[0]
        var f2 = abs(n2.z * n3.z) > 1e-12 ? -(n2.x * n3.x + n2.y * n3.y) / (n2.z * n3.z) : -1
        let assumed = !(f2 > 0.04 && f2 < 100)
        if assumed { f2 = 0.75 * 0.75 }
        func norm2(_ n: SIMD3<Double>) -> Double { (n.x * n.x + n.y * n.y) / f2 + n.z * n.z }
        let r = (norm2(n2) / norm2(n3)).squareRoot()
        guard r.isFinite, r > 0 else { return nil }
        return (r, f2.squareRoot() * scale, assumed)
    }

    /// Apple Vision's rectangle detector, tuned to paper-shaped quads (aspect 0.55–0.85 to allow some tilt).
    static func visionQuads(_ image: CGImage) throws -> [[SIMD2<Double>]] {
        let request = VNDetectRectanglesRequest()
        request.minimumAspectRatio = 0.55
        request.maximumAspectRatio = 0.85
        request.quadratureTolerance = 30
        request.minimumSize = 0.04
        request.minimumConfidence = 0.3
        request.maximumObservations = 8
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try ProductLabelReader.withCPUFallback { cpu in
            if cpu { ProductLabelReader.forceCPU(request) }
            try VisionSerial.run { try handler.perform([request]) }
        }
        let w = Double(image.width), h = Double(image.height)
        return (request.results ?? []).map { obs in
            [obs.topLeft, obs.topRight, obs.bottomRight, obs.bottomLeft].map { SIMD2(Double($0.x) * w, (1 - Double($0.y)) * h) }
        }
    }

    /// Pixel-only detector: bright near-white connected regions (threshold relative to the brightest
    /// pixels), each outlined by its convex hull and reduced to the largest inscribed quadrilateral.
    /// A region that does not fill its quad (≥ 85%) is not a sheet (a white garment, a reflection).
    package static func pixelQuads(_ img: RGBABuffer) -> [[SIMD2<Double>]] {
        let ds = max(1, max(img.width, img.height) / 900)
        let gw = img.width / ds, gh = img.height / ds
        guard gw > 4, gh > 4 else { return [] }
        var lows = [Double](repeating: 0, count: gw * gh), chroma = lows
        for gy in 0 ..< gh {
            for gx in 0 ..< gw {
                let c = img.rgb(gx * ds + ds / 2, gy * ds + ds / 2)
                let lo = min(c.x, c.y, c.z), hi = max(c.x, c.y, c.z)
                lows[gy * gw + gx] = img.alpha(gx * ds + ds / 2, gy * ds + ds / 2) > 0.5 ? lo : 0
                chroma[gy * gw + gx] = hi - lo
            }
        }
        let bright = lows.sorted()[lows.count * 995 / 1000]
        let threshold = max(0.45, 0.75 * bright)
        let candidate = (0 ..< gw * gh).map { lows[$0] >= threshold && chroma[$0] <= 0.15 }
        var seen = [Bool](repeating: false, count: gw * gh)
        var found: [(Int, [SIMD2<Double>])] = []
        let minSize = max(200, gw * gh / 500)
        for start in 0 ..< gw * gh where candidate[start] && !seen[start] {
            var stack = [start], size = 0
            var rowMin: [Int: Int] = [:], rowMax: [Int: Int] = [:]
            seen[start] = true
            while let i = stack.popLast() {
                size += 1
                let x = i % gw, y = i / gw
                rowMin[y] = min(rowMin[y] ?? x, x); rowMax[y] = max(rowMax[y] ?? x, x)
                for (nx, ny) in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)] where nx >= 0 && ny >= 0 && nx < gw && ny < gh {
                    let j = ny * gw + nx
                    if candidate[j], !seen[j] { seen[j] = true; stack.append(j) }
                }
            }
            guard size >= minSize else { continue }
            var outline: [SIMD2<Double>] = []
            for (y, lx) in rowMin {
                let rx = rowMax[y]!
                outline += [SIMD2(Double(lx), Double(y)), SIMD2(Double(lx), Double(y + 1)),
                            SIMD2(Double(rx + 1), Double(y)), SIMD2(Double(rx + 1), Double(y + 1))]
            }
            let hull = convexHull(outline)
            guard hull.count >= 4 else { continue }
            let quad = largestQuad(hull)
            let quadArea = polygonArea(quad)
            guard quadArea > 0, Double(size) / quadArea >= 0.85 else { continue }
            found.append((size, quad.map { $0 * Double(ds) }))
        }
        return found.sorted { $0.0 > $1.0 }.prefix(5).map(\.1)
    }

    /// Paper: ≥ 90% of interior samples near-white (min channel ≥ 0.45, chroma ≤ 0.15) and the interior
    /// brighter than a ring just outside by ≥ 0.12.
    static func isPaper(_ q: [SIMD2<Double>], _ img: RGBABuffer, _ luma: LumaImage) -> Bool {
        func at(_ u: Double, _ v: Double) -> SIMD2<Double> {
            let top = q[0] + (q[1] - q[0]) * u, bottom = q[3] + (q[2] - q[3]) * u
            return top + (bottom - top) * v
        }
        var white = 0, total = 0, inside = 0.0
        for i in 0 ..< 10 {
            for j in 0 ..< 10 {
                let p = at(0.15 + 0.07 * Double(i), 0.15 + 0.07 * Double(j))
                let x = Int(p.x), y = Int(p.y)
                guard x >= 0, y >= 0, x < img.width, y < img.height else { return false }
                let c = img.rgb(x, y)
                total += 1
                if min(c.x, c.y, c.z) >= 0.45, max(c.x, c.y, c.z) - min(c.x, c.y, c.z) <= 0.15 { white += 1 }
                inside += luma.at(p)
            }
        }
        guard Double(white) >= 0.9 * Double(total) else { return false }
        let centre = q.reduce(.zero, +) / 4
        var outside: [Double] = []
        for k in 0 ..< 4 {
            for t in [0.25, 0.5, 0.75] {
                let p = q[k] + (q[(k + 1) % 4] - q[k]) * t
                let o = p + (p - centre) * 0.08
                if o.x >= 0, o.y >= 0, o.x < Double(img.width), o.y < Double(img.height) { outside.append(luma.at(o)) }
            }
        }
        guard outside.count >= 4 else { return false }
        return inside / Double(total) - outside.reduce(0, +) / Double(outside.count) >= 0.12
    }

    /// Each side re-found on the full-resolution pixels: brightness profiles across the side (48 of them),
    /// the half-way crossing as the edge point, a total-least-squares line through the points (one outlier
    /// pass), corners as the lines' intersections. σ(corner) = max(0.35, fit RMS) + 0.15 × edge width.
    static func refineCorners(_ q: [SIMD2<Double>], _ luma: LumaImage) -> (corners: [SIMD2<Double>], sigma: Double, edgeWidth: Double) {
        let centre = q.reduce(.zero, +) / 4
        let sides = (0 ..< 4).map { simdDistance(q[$0], q[($0 + 1) % 4]) }
        let radius = max(6, 0.02 * sides.min()!)
        var lines: [(p: SIMD2<Double>, d: SIMD2<Double>, rms: Double)] = []
        var widths: [Double] = []
        for k in 0 ..< 4 {
            let a = q[k], b = q[(k + 1) % 4]
            let dir = (b - a) / simdDistance(a, b)
            var n = SIMD2(-dir.y, dir.x)
            let mid = (a + b) / 2
            if ((centre - mid) * n).sum() > 0 { n = -n }   // outward
            var pts: [SIMD2<Double>] = []
            for s in 0 ..< 48 {
                let base = a + (b - a) * (0.12 + 0.76 * Double(s) / 47)
                let offsets = Array(stride(from: -radius, through: radius, by: 0.5))
                let prof = offsets.map { luma.at(base + n * $0) }
                let inner = prof.prefix(4).reduce(0, +) / 4, outer = prof.suffix(4).reduce(0, +) / 4
                let diff = inner - outer
                guard diff >= 0.12 else { continue }
                func crossing(_ level: Double) -> Double? {
                    for i in 1 ..< prof.count where prof[i - 1] >= level && prof[i] < level {
                        return offsets[i - 1] + (prof[i - 1] - level) / (prof[i - 1] - prof[i]) * 0.5
                    }
                    return nil
                }
                guard let half = crossing(outer + diff * 0.5) else { continue }
                if let hi = crossing(outer + diff * 0.8), let lo = crossing(outer + diff * 0.2) { widths.append(max(0, lo - hi)) }
                pts.append(base + n * half)
            }
            guard var fit = tlsLine(pts) else { return (q, 1.5 + 0.02 * sides.min()!, 3) }
            let kept = pts.filter { abs((($0 - fit.p) * SIMD2(-fit.d.y, fit.d.x)).sum()) <= max(1.0, 2.5 * fit.rms) }
            if kept.count >= 8, let refit = tlsLine(kept) { fit = refit }
            lines.append(fit)
        }
        var out: [SIMD2<Double>] = []
        for k in 0 ..< 4 {
            let l1 = lines[(k + 3) % 4], l2 = lines[k]
            let det = l1.d.x * (-l2.d.y) - l1.d.y * (-l2.d.x)
            guard abs(det) > 1e-6 else { return (q, 1.5 + 0.02 * sides.min()!, 3) }
            let r = l2.p - l1.p
            let t = (r.x * (-l2.d.y) - r.y * (-l2.d.x)) / det
            let p = l1.p + l1.d * t
            guard simdDistance(p, q[k]) <= 3 * radius else { return (q, 1.5 + 0.02 * sides.min()!, 3) }
            out.append(p)
        }
        let width = widths.isEmpty ? 3 : widths.sorted()[widths.count / 2]
        let rms = lines.map(\.rms).reduce(0, +) / 4
        return (out, max(0.35, rms) + 0.15 * width, width)
    }

    static func tlsLine(_ pts: [SIMD2<Double>]) -> (p: SIMD2<Double>, d: SIMD2<Double>, rms: Double)? {
        guard pts.count >= 8 else { return nil }
        let m = pts.reduce(.zero, +) / Double(pts.count)
        var sxx = 0.0, sxy = 0.0, syy = 0.0
        for p in pts { let d = p - m; sxx += d.x * d.x; sxy += d.x * d.y; syy += d.y * d.y }
        let theta = 0.5 * atan2(2 * sxy, sxx - syy)
        let d = SIMD2(cos(theta), sin(theta)), n = SIMD2(-d.y, d.x)
        let rms = (pts.map { let r = (($0 - m) * n).sum(); return r * r }.reduce(0, +) / Double(pts.count)).squareRoot()
        return (m, d, rms)
    }

    /// Pixels inside the sheet grown by its blurred edge plus 3 px, so the paper's soft rim is not garment.
    static func sheetKeepOut(_ s: A4SheetDetection, width: Int, height: Int) -> [Int] {
        let c = s.corners.map { SIMD2(Double($0.x), Double($0.y)) }
        let centre = c.reduce(.zero, +) / 4
        let grow = 3 + 2 * s.edgeWidthPx
        let g = c.map { $0 + ($0 - centre) / simdDistance($0, centre) * grow * 2.0.squareRoot() }
        let lo: SIMD2<Double> = g.dropFirst().reduce(g[0]) { pointwiseMin($0, $1) }
        let hi: SIMD2<Double> = g.dropFirst().reduce(g[0]) { pointwiseMax($0, $1) }
        var out: [Int] = []
        for y in max(0, Int(lo.y)) ... min(height - 1, Int(hi.y)) {
            for x in max(0, Int(lo.x)) ... min(width - 1, Int(hi.x)) where insideConvex(g, SIMD2(Double(x) + 0.5, Double(y) + 0.5)) {
                out.append(y * width + x)
            }
        }
        return out
    }

    // MARK: Geometry helpers

    /// Clockwise in photo coordinates (y down), starting at the corner nearest the top-left.
    static func orderCorners(_ q: [SIMD2<Double>]) -> [SIMD2<Double>] {
        let c = q.reduce(.zero, +) / Double(q.count)
        let sorted = q.sorted { atan2($0.y - c.y, $0.x - c.x) < atan2($1.y - c.y, $1.x - c.x) }
        let first = sorted.indices.min { sorted[$0].sum() < sorted[$1].sum() }!
        return (0 ..< sorted.count).map { sorted[(first + $0) % sorted.count] }
    }

    static func convexHull(_ points: [SIMD2<Double>]) -> [SIMD2<Double>] {
        let p = points.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        guard p.count > 2 else { return p }
        func cross(_ o: SIMD2<Double>, _ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x) }
        var lower: [SIMD2<Double>] = [], upper: [SIMD2<Double>] = []
        for pt in p {
            while lower.count >= 2, cross(lower[lower.count - 2], lower[lower.count - 1], pt) <= 0 { lower.removeLast() }
            lower.append(pt)
        }
        for pt in p.reversed() {
            while upper.count >= 2, cross(upper[upper.count - 2], upper[upper.count - 1], pt) <= 0 { upper.removeLast() }
            upper.append(pt)
        }
        return Array(lower.dropLast() + upper.dropLast())
    }

    /// Largest-area quadrilateral on a convex hull: start from the diameter and the farthest point on each
    /// side of it, then move one corner at a time to the hull point that grows the area most (3 rounds).
    static func largestQuad(_ hull: [SIMD2<Double>]) -> [SIMD2<Double>] {
        let n = hull.count
        var best = (0, 1, 0.0)
        for i in 0 ..< n { for j in i + 1 ..< n { let d = simdDistance(hull[i], hull[j]); if d > best.2 { best = (i, j, d) } } }
        func off(_ k: Int) -> Double {
            let a = hull[best.0], b = hull[best.1]
            return (b.x - a.x) * (hull[k].y - a.y) - (b.y - a.y) * (hull[k].x - a.x)
        }
        let k1 = (0 ..< n).max { off($0) < off($1) }!, k2 = (0 ..< n).min { off($0) < off($1) }!
        var idx = [best.0, k1, best.1, k2]
        func area(_ ix: [Int]) -> Double { polygonArea(orderCorners(ix.map { hull[$0] })) }
        for _ in 0 ..< 3 {
            for c in 0 ..< 4 {
                var bestArea = area(idx), bestK = idx[c]
                for k in 0 ..< n where !idx.contains(k) {
                    var trial = idx
                    trial[c] = k
                    let a = area(trial)
                    if a > bestArea { bestArea = a; bestK = k }
                }
                idx[c] = bestK
            }
        }
        return orderCorners(idx.map { hull[$0] })
    }

    static func polygonArea(_ p: [SIMD2<Double>]) -> Double {
        var a = 0.0
        for i in p.indices { let q = p[(i + 1) % p.count]; a += p[i].x * q.y - q.x * p[i].y }
        return abs(a) / 2
    }

    static func insideConvex(_ poly: [SIMD2<Double>], _ pt: SIMD2<Double>) -> Bool {
        var sign = 0.0
        for i in poly.indices {
            let a = poly[i], b = poly[(i + 1) % poly.count]
            let c = (b.x - a.x) * (pt.y - a.y) - (b.y - a.y) * (pt.x - a.x)
            if c != 0 {
                if sign == 0 { sign = c } else if (c > 0) != (sign > 0) { return false }
            }
        }
        return true
    }

    /// Largest 4-connected piece of a mask; stray specks and far shadows drop out.
    static func largestComponent(_ mask: [Float], width: Int, height: Int) -> [Float] {
        var label = [Int32](repeating: 0, count: mask.count)
        var bestLabel: Int32 = 0, bestSize = 0, next: Int32 = 0
        var stack: [Int] = []
        for start in mask.indices where mask[start] > 0.5 && label[start] == 0 {
            next += 1
            label[start] = next
            stack.append(start)
            var size = 0
            while let i = stack.popLast() {
                size += 1
                let x = i % width, y = i / width
                if x > 0, mask[i - 1] > 0.5, label[i - 1] == 0 { label[i - 1] = next; stack.append(i - 1) }
                if x < width - 1, mask[i + 1] > 0.5, label[i + 1] == 0 { label[i + 1] = next; stack.append(i + 1) }
                if y > 0, mask[i - width] > 0.5, label[i - width] == 0 { label[i - width] = next; stack.append(i - width) }
                if y < height - 1, mask[i + width] > 0.5, label[i + width] == 0 { label[i + width] = next; stack.append(i + width) }
            }
            if size > bestSize { bestSize = size; bestLabel = next }
        }
        return label.map { $0 == bestLabel && bestLabel != 0 ? 1 : 0 }
    }

    static func simdDistance(_ a: SIMD2<Double>, _ b: SIMD2<Double>) -> Double { ((a - b) * (a - b)).sum().squareRoot() }
    static func distance(_ a: CGPoint, _ b: CGPoint) -> Double { hypot(Double(a.x - b.x), Double(a.y - b.y)) }
}

/// A rotation of the metric plane.
struct Rotation {
    let c: Double, s: Double
    init(_ angle: Double) { c = cos(angle); s = sin(angle) }
    func apply(_ p: SIMD2<Double>) -> SIMD2<Double> { SIMD2(c * p.x - s * p.y, s * p.x + c * p.y) }
    func inverse(_ p: SIMD2<Double>) -> SIMD2<Double> { SIMD2(c * p.x + s * p.y, -s * p.x + c * p.y) }
}

/// Luma (Rec. 601) of an RGBA buffer, sampled bilinearly with pixel centres at +0.5.
struct LumaImage {
    let width: Int, height: Int
    let v: [Float]

    init(_ img: RGBABuffer) {
        width = img.width; height = img.height
        var out = [Float](repeating: 0, count: img.width * img.height)
        img.bytes.withUnsafeBufferPointer { b in
            for i in 0 ..< out.count {
                out[i] = (0.299 * Float(b[i * 4]) + 0.587 * Float(b[i * 4 + 1]) + 0.114 * Float(b[i * 4 + 2])) / 255
            }
        }
        v = out
    }

    func at(_ p: SIMD2<Double>) -> Double {
        let x = min(max(p.x - 0.5, 0), Double(width - 1)), y = min(max(p.y - 0.5, 0), Double(height - 1))
        let x0 = Int(x), y0 = Int(y), x1 = min(x0 + 1, width - 1), y1 = min(y0 + 1, height - 1)
        let fx = x - Double(x0), fy = y - Double(y0)
        let top = Double(v[y0 * width + x0]) * (1 - fx) + Double(v[y0 * width + x1]) * fx
        let bottom = Double(v[y1 * width + x0]) * (1 - fx) + Double(v[y1 * width + x1]) * fx
        return top * (1 - fy) + bottom * fy
    }
}

/// The garment on the metric plane: `on[y * width + x]`, one cell = `cell` mm, rows top → bottom.
struct MetricMask {
    let width: Int, height: Int
    let cell: Double
    let on: [Bool]

    var rowRange: ClosedRange<Int>? {
        let rows = (0 ..< height).filter { y in (0 ..< width).contains { on[y * width + $0] } }
        guard let a = rows.first, let b = rows.last else { return nil }
        return a ... b
    }

    /// Garment runs in a row; gaps under 3 mm are bridged (mask speckle, not shape).
    func runs(_ y: Int) -> [ClosedRange<Int>] {
        guard y >= 0, y < height else { return [] }
        let bridge = max(1, Int((3 / cell).rounded()))
        var out: [ClosedRange<Int>] = []
        var start = -1, last = -1
        for x in 0 ..< width where on[y * width + x] {
            if start < 0 { start = x } else if x - last > bridge { out.append(start ... last); start = x }
            last = x
        }
        if start >= 0 { out.append(start ... last) }
        return out
    }

    func run(containing x: Int, row y: Int) -> ClosedRange<Int>? { runs(y).first { $0.contains(x) } }

    func extent(_ y: Int) -> ClosedRange<Int>? {
        let r = runs(y)
        guard let a = r.first, let b = r.last else { return nil }
        return a.lowerBound ... b.upperBound
    }

    func width(_ r: ClosedRange<Int>) -> Double { Double(r.upperBound - r.lowerBound + 1) * cell }
}
