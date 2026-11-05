import BodyGeometry
import Foundation

/// Drafts flat sewing-pattern pieces ("kalıp") from body measurements plus ease, or from a garment's own
/// finished measurements. A simplified proportional block method: every number comes from the formulas
/// written next to it, so any pattern can be re-derived and checked by hand. It is a basic block, not a
/// brand's pattern, and it makes no fit promise: a block is where a pattern maker starts, then fits.
///
/// Conventions: centimetres; x across the piece from the centre line (CF/CB, or the sleeve and trouser
/// crease line); y down from the top. Front and back bodice and skirt pieces are halves cut on the fold.
///
/// Bodice block (C chest, W waist, H hip, S shoulder width, Ht height, E ease, all cm):
/// - quarter panel at the underarm: front = back = (C + E.chest) / 4, so 2 × (front + back) = C + E.chest
/// - neck half-width NW = C / 20 + 2; front neck depth NW + 1; back neck depth 2
/// - shoulder point at S / 2 from the centre line, dropped 0.1 S + 0.3 below the neck point
/// - armhole depth AD (neck point level to underarm) = C / 8 + 7
/// - waist line 0.245 Ht and hip line 0.355 Ht below the neck point (body stations 0.39 Ht and 0.50 Ht
///   from the crown, the neck point sitting ≈0.145 Ht below it)
/// - length: tee/long-sleeve top 0.40 Ht, dress 0.52 Ht, coat 0.55 Ht
/// Sleeve: cap height 0.6 (AD − drop); bicep width 0.34 C + 2 + E.chest / 5; length 0.12 Ht (short),
/// 0.35 Ht (long), 0.36 Ht (coat); cuff 0.88 (short), 0.62 (long), 0.70 (coat) × bicep. The cap is a
/// sin² bell; cap ease against the armhole is not balanced (simplified block).
/// Trousers: Hc = H + E.hip, Wc = W + E.waist; hip quarter front Hc/4 − 1, back Hc/4 + 1; waist quarter
/// front Wc/4 − 1, back Wc/4 + 1 (no darts: the difference goes into the side seam); rise 0.14 Ht + 1.5;
/// hip line min(0.11 Ht, 0.8 rise); crotch extension front Hc/16, back Hc/10; back waist raised 2 cm at
/// the centre back; inseam 0.42 Ht (trousers) or 0.10 Ht (shorts); leg opening 0.21 Hc + 20 (trousers)
/// or 0.6 Hc (shorts), split front −1 / back +1.
/// Skirt: waist quarter (W + E.waist)/4, hip quarter (H + E.hip)/4, hip depth min(0.11 Ht, 0.6 L),
/// length 0.33 Ht, hem quarter = hip quarter + 0.08 (L − hip depth).
public enum PatternDrafter {
    /// Standard seam allowance (cm) on every non-fold edge.
    public static let seamAllowanceCm = 1.0

    // MARK: Body block

    /// A basic block for `kind` from the body profile plus `ease` (defaults to `PatternEase.standard`).
    /// Values that are starting points or slider shapes are drafted the same way but named as such in
    /// `provenance`, so the block never reads as made-to-measure when it is not.
    public static func block(for profile: BodyProfile, kind: GarmentKind, ease: PatternEase? = nil) throws(PatternError) -> SewingPattern {
        do { try profile.validate() } catch { throw .invalidMeasurement("body profile") }
        let e = ease ?? .standard(for: kind)
        for v in [e.chestCm, e.waistCm, e.hipCm] where !(v.isFinite && v >= 0 && v <= 60) { throw .invalidMeasurement("ease") }
        let ht = profile[.height].length.centimeters
        let s = profile[.shoulderWidth].length.centimeters
        let c = profile[.chest].length.centimeters
        let w = profile[.waist].length.centimeters
        let h = profile[.hip].length.centimeters

        let pieces: [PatternPiece]
        let used: [BodyParameter]
        switch kind.family {
        case .bodice:
            used = [.height, .shoulderWidth, .chest, .waist, .hip]
            let nw = c / 20 + 2
            let drop = 0.1 * s + 0.3
            let ad = c / 8 + 7
            let chestQ = (c + e.chestCm) / 4
            let waistQ = (w + e.waistCm) / 4
            let hipQ = (h + e.hipCm) / 4
            let waistY = 0.245 * ht, hipY = 0.355 * ht
            let length: Double = switch kind {
            case .dress: 0.52 * ht
            case .coat: 0.55 * ht
            default: 0.40 * ht
            }
            var side: [(y: Double, x: Double, name: String)]
            if kind == .dress {
                side = [(waistY, waistQ, "waist"), (hipY, hipQ, "hip")].filter { $0.y > ad + 1 && $0.y < length - 1 }
                side.append((length, hipQ + 0.08 * max(length - hipY, 0), "hem-side"))
            } else {
                side = [(length, length > hipY ? max(chestQ, hipQ) : chestQ, "hem-side")]
            }
            let spec = BodiceSpec(neckHalf: nw, frontNeckDepth: nw + 1, backNeckDepth: 2, shoulderHalf: s / 2, shoulderDrop: drop,
                                  armholeDepth: ad, frontQ: chestQ, backQ: chestQ, side: side.map { ($0.y, $0.x, $0.x, $0.name) }, length: length)
            var list = [try bodicePiece(spec, front: true), try bodicePiece(spec, front: false)]
            let capHeight = 0.6 * (ad - drop)
            let bicep = 0.34 * c + 2 + e.chestCm / 5
            let sleeve: (length: Double, cuff: Double)? = switch kind {
            case .top: (0.12 * ht, 0.88 * bicep)
            case .longSleeveTop: (0.35 * ht, 0.62 * bicep)
            case .coat: (0.36 * ht, 0.70 * bicep)
            default: nil
            }
            if let sleeve {
                list.append(try sleevePiece(SleeveSpec(capHeight: capHeight, bicep: bicep, length: sleeve.length, cuff: sleeve.cuff)))
            }
            pieces = list
        case .trousers:
            used = [.height, .waist, .hip]
            let hc = h + e.hipCm, wc = w + e.waistCm
            let rise = 0.14 * ht + 1.5
            let inseam = kind == .trousers ? 0.42 * ht : 0.10 * ht
            let opening = kind == .trousers ? 0.21 * hc + 20 : 0.6 * hc
            pieces = try trouserPieces(TrouserSpec(waistCirc: wc, hipCirc: hc, rise: rise, hipY: min(0.11 * ht, 0.8 * rise),
                                                   length: rise + inseam, opening: opening, withKnee: kind == .trousers))
        case .skirt:
            used = [.height, .waist, .hip]
            let length = 0.33 * ht
            let hipQ = (h + e.hipCm) / 4
            let hd = min(0.11 * ht, 0.6 * length)
            pieces = try skirtPieces(waistQ: (w + e.waistCm) / 4, hipQ: hipQ, hipDepth: hd, length: length,
                                     hemQ: hipQ + 0.08 * (length - hd))
        }
        let values = used.map { p in "\(p.displayName.lowercased()) \(cmText(profile[p].length.centimeters)) cm (\(profile[p].source.label.lowercased()))" }
        let easeText = kind.family == .bodice
            ? "göğüs \(cmText(e.chestCm)), bel \(cmText(e.waistCm)), kalça \(cmText(e.hipCm)) cm"
            : "bel \(cmText(e.waistCm)), kalça \(cmText(e.hipCm)) cm"
        let provenance = "\(kind.displayName) temel bloğu, basitleştirilmiş orantılı yöntem. Beden: \(values.joined(separator: ", ")). "
            + "Bolluk: \(easeText). Marka kalıbı değildir; prova gerekir."
        return SewingPattern(kind: kind, pieces: pieces, source: .bodyBlock, ease: e, provenance: provenance)
    }

    // MARK: Garment measurements

    /// A pattern whose seam lines reproduce the garment's finished measurements: front + back half-widths
    /// at the underarm (or hip) equal `bodyWidth`, the piece length equals `length`, and the sleeve, hem,
    /// waist and inseam follow when given. Anything not given is derived from `bodyWidth` by the
    /// proportions below and named "türetildi" in `provenance`: a derived number is never a measurement.
    public static func pattern(from m: GarmentMeasurements) throws(PatternError) -> SewingPattern {
        try m.validate()
        let bw = m.bodyWidth.cm, length = m.length.cm
        var derived: [String] = []
        let pieces: [PatternPiece]
        switch m.kind.family {
        case .bodice:
            // Finished chest circumference Cg = 2 × flat width; each quarter panel = bodyWidth / 2.
            let cg = 2 * bw
            let q = bw / 2
            let nw = cg / 22 + 2
            let sh = 0.43 * bw
            let drop = 0.2 * sh + 0.3
            let ad = 0.25 * bw + 6
            guard length > ad + 4 else { throw .invalidMeasurement("length shorter than the armhole") }
            var side: [(Double, Double, Double, String)]
            if m.kind == .dress {
                let waistQ = (m.waistWidth?.cm ?? 0.88 * bw) / 2
                if m.waistWidth == nil { derived.append("bel genişliği") }
                let waistY = ad + 0.22 * cg, hipY = waistY + 0.18 * cg
                let hipQ = max(q, waistQ)
                side = [(waistY, waistQ, waistQ, "waist"), (hipY, hipQ, hipQ, "hip")].filter { $0.0 > ad + 1 && $0.0 < length - 1 }
                let hemQ = (m.hemWidth?.cm).map { $0 / 2 } ?? hipQ * 1.1
                if m.hemWidth == nil { derived.append("etek ucu genişliği") }
                side.append((length, hemQ, hemQ, "hem-side"))
            } else {
                let hemQ = (m.hemWidth?.cm).map { $0 / 2 } ?? q
                side = [(length, hemQ, hemQ, "hem-side")]
            }
            let spec = BodiceSpec(neckHalf: nw, frontNeckDepth: nw + 1, backNeckDepth: 2, shoulderHalf: sh, shoulderDrop: drop,
                                  armholeDepth: ad, frontQ: q, backQ: q, side: side, length: length)
            var list = [try bodicePiece(spec, front: true), try bodicePiece(spec, front: false)]
            let defaultSleeve: Double? = switch m.kind {
            case .top: 0.4 * bw
            case .longSleeveTop, .coat: 1.15 * bw
            default: nil
            }
            if let sl = m.sleeveLength?.cm ?? defaultSleeve {
                if m.sleeveLength == nil { derived.append("kol boyu") }
                let bicep = 0.34 * cg
                let long = sl > 0.8 * bw
                list.append(try sleevePiece(SleeveSpec(capHeight: 0.6 * (ad - drop), bicep: bicep, length: sl, cuff: (long ? 0.62 : 0.88) * bicep)))
            }
            pieces = list
            derived.append("omuz, yaka ve kol oyuğu (orantıdan)")
        case .trousers:
            let hc = 2 * bw
            let wc = 2 * (m.waistWidth?.cm ?? 0.85 * bw)
            if m.waistWidth == nil { derived.append("bel genişliği") }
            let inseam = m.inseam?.cm ?? max(length - 0.26 * hc, 3)
            if m.inseam == nil { derived.append("iç bacak boyu") }
            let rise = length - inseam
            guard rise >= 10, rise <= length - 2 else { throw .invalidMeasurement("inseam") }
            let openingFlat = m.hemWidth?.cm ?? (m.kind == .trousers ? 0.105 * hc + 10 : 0.3 * hc)
            if m.hemWidth == nil { derived.append("paça genişliği") }
            pieces = try trouserPieces(TrouserSpec(waistCirc: wc, hipCirc: hc, rise: rise, hipY: 0.68 * rise, length: length,
                                                   opening: 2 * openingFlat, withKnee: m.kind == .trousers && inseam > 30))
            derived.append("ağ ve kalça hattı (orantıdan)")
        case .skirt:
            let waistQ = (m.waistWidth?.cm ?? 0.82 * bw) / 2
            if m.waistWidth == nil { derived.append("bel genişliği") }
            let hemQ = (m.hemWidth?.cm ?? 1.1 * bw) / 2
            if m.hemWidth == nil { derived.append("etek ucu genişliği") }
            pieces = try skirtPieces(waistQ: waistQ, hipQ: bw / 2, hipDepth: min(0.18 * 2 * bw, 0.6 * length), length: length, hemQ: hemQ)
        }
        var given = ["en \(cmText(bw)) cm (\(m.bodyWidth.source.label))", "boy \(cmText(length)) cm (\(m.length.source.label))"]
        for (name, v) in [("kol", m.sleeveLength), ("etek ucu", m.hemWidth), ("bel", m.waistWidth), ("iç bacak", m.inseam)] {
            if let v { given.append("\(name) \(cmText(v.cm)) cm (\(v.source.label))") }
        }
        var provenance = "\(m.kind.displayName) kalıbı, giysinin bitmiş ölçülerinden: \(given.joined(separator: ", "))."
        if !derived.isEmpty { provenance += " Türetildi (ölçü değil): \(derived.joined(separator: ", "))." }
        provenance += " Marka kalıbı değildir."
        return SewingPattern(kind: m.kind, pieces: pieces, source: .garmentMeasurements, ease: nil, provenance: provenance)
    }

    // MARK: Pieces

    struct BodiceSpec {
        var neckHalf: Double
        var frontNeckDepth: Double
        var backNeckDepth: Double
        var shoulderHalf: Double
        var shoulderDrop: Double
        var armholeDepth: Double
        var frontQ: Double
        var backQ: Double
        /// Side seam points below the underarm, top to bottom, ending at the hem: (y, front x, back x, notch).
        var side: [(Double, Double, Double, String)]
        var length: Double
    }

    struct SleeveSpec {
        var capHeight: Double
        var bicep: Double
        var length: Double
        var cuff: Double
    }

    /// Half bodice on the fold: centre line, neckline (quarter ellipse), shoulder, armhole (cubic, deeper
    /// scoop in front), side seam, hem. y-monotone by construction, so every row has one width.
    static func bodicePiece(_ s: BodiceSpec, front: Bool) throws(PatternError) -> PatternPiece {
        let q = front ? s.frontQ : s.backQ
        let nd = front ? s.frontNeckDepth : s.backNeckDepth
        let scoop = front ? 2.0 : 1.0
        let (nw, sh, drop, ad, l) = (s.neckHalf, s.shoulderHalf, s.shoulderDrop, s.armholeDepth, s.length)
        var pts = [PatternPoint(x: 0, y: l)]
        for k in 0...10 {
            let t = Double.pi / 2 * Double(k) / 10
            pts.append(PatternPoint(x: nw * sin(t), y: nd * cos(t)))
        }
        pts.append(PatternPoint(x: sh, y: drop))
        pts += Polygon.bezier(PatternPoint(x: sh, y: drop), PatternPoint(x: sh - 1.5, y: drop + 0.55 * (ad - drop)),
                              PatternPoint(x: min(sh, q) - scoop, y: ad), PatternPoint(x: q, y: ad), samples: 12).dropFirst()
        var notches = [PatternPiece.Notch("neck-point", PatternPoint(x: nw, y: 0)), .init("shoulder-point", PatternPoint(x: sh, y: drop)),
                       .init("underarm", PatternPoint(x: q, y: ad))]
        for p in s.side {
            let pt = PatternPoint(x: front ? p.1 : p.2, y: p.0)
            pts.append(pt)
            notches.append(.init(p.3, pt))
        }
        let gx = 0.35 * min(q, sh)
        return try PatternPiece(name: front ? "Ön beden" : "Arka beden", role: front ? .front : .back, outline: pts,
                                grainline: .init(start: PatternPoint(x: gx, y: max(nd, drop) + 2), end: PatternPoint(x: gx, y: l - 2)),
                                notches: notches, seamAllowanceCm: seamAllowanceCm, cutCount: 1, mirror: true)
    }

    /// Full sleeve, symmetric about its centre line (x = 0): a sin² cap from underarm to underarm, then
    /// straight underarm seams to the cuff. Positive x is the front of the sleeve.
    static func sleevePiece(_ s: SleeveSpec) throws(PatternError) -> PatternPiece {
        let bw = s.bicep, ch = s.capHeight
        let sl = max(s.length, ch + 4)
        let cuff = min(s.cuff, bw)
        var pts: [PatternPoint] = []
        for k in 0...24 {
            let x = -bw / 2 + bw * Double(k) / 24
            let si = sin(Double.pi * x / bw)
            pts.append(PatternPoint(x: x, y: ch * si * si))
        }
        pts.append(PatternPoint(x: cuff / 2, y: sl))
        pts.append(PatternPoint(x: -cuff / 2, y: sl))
        return try PatternPiece(name: "Kol", role: .sleeve, outline: pts,
                                grainline: .init(start: PatternPoint(x: 0, y: ch), end: PatternPoint(x: 0, y: sl - 2)),
                                notches: [.init("cap-top", PatternPoint(x: 0, y: 0)), .init("underarm-front", PatternPoint(x: bw / 2, y: ch)),
                                          .init("underarm-back", PatternPoint(x: -bw / 2, y: ch)), .init("cuff", PatternPoint(x: cuff / 2, y: sl))],
                                seamAllowanceCm: seamAllowanceCm, cutCount: 2, mirror: false)
    }

    struct TrouserSpec {
        var waistCirc: Double
        var hipCirc: Double
        var rise: Double
        var hipY: Double
        var length: Double
        var opening: Double
        var withKnee: Bool
    }

    /// Front and back trouser leg. Centre line (CF/CB) at x = 0, side seam towards +x, crotch extension
    /// towards −x; the crease line sits mid-way across the crotch line, legs centred on it.
    static func trouserPieces(_ s: TrouserSpec) throws(PatternError) -> [PatternPiece] {
        var out: [PatternPiece] = []
        for front in [true, false] {
            let sign = front ? -1.0 : 1.0
            let waistQ = s.waistCirc / 4 + sign
            let hipQ = s.hipCirc / 4 + sign
            let ext = front ? s.hipCirc / 16 : s.hipCirc / 10
            let raise = front ? 0.0 : 2.0
            let hem = s.opening / 2 + sign
            let xc = (hipQ - ext) / 2
            let thigh = hipQ + ext
            guard hem < thigh, s.hipY < s.rise, s.rise < s.length else { throw .invalidGeometry("trouser proportions") }
            var pts = [PatternPoint(x: 0, y: -raise), PatternPoint(x: waistQ, y: 0)]
            for k in 1...8 {
                let t = Double(k) / 8
                pts.append(PatternPoint(x: waistQ + (hipQ - waistQ) * sin(t * .pi / 2), y: s.hipY * t))
            }
            pts.append(PatternPoint(x: hipQ, y: s.rise))
            var notches = [PatternPiece.Notch("waist-side", PatternPoint(x: waistQ, y: 0)), .init("hip", PatternPoint(x: hipQ, y: s.hipY)),
                           .init("crotch-point", PatternPoint(x: -ext, y: s.rise))]
            var knee: (y: Double, w: Double)?
            if s.withKnee {
                let inseam = s.length - s.rise
                knee = (s.rise + 0.45 * inseam, hem + 0.15 * (thigh - hem))
            }
            if let knee {
                pts.append(PatternPoint(x: xc + knee.w / 2, y: knee.y))
                notches.append(.init("knee", PatternPoint(x: xc + knee.w / 2, y: knee.y)))
            }
            pts.append(PatternPoint(x: xc + hem / 2, y: s.length))
            notches.append(.init("hem-outer", PatternPoint(x: xc + hem / 2, y: s.length)))
            pts.append(PatternPoint(x: xc - hem / 2, y: s.length))
            if let knee { pts.append(PatternPoint(x: xc - knee.w / 2, y: knee.y)) }
            pts.append(PatternPoint(x: -ext, y: s.rise))
            // Crotch curve: a quarter ellipse centred on (−ext, hip line), so it hugs the corner where the
            // centre line meets the crotch line (the usual J-shaped scoop).
            for k in 1...10 {
                let t = Double.pi / 2 * Double(k) / 10
                pts.append(PatternPoint(x: -ext + ext * sin(t), y: s.hipY + (s.rise - s.hipY) * cos(t)))
            }
            out.append(try PatternPiece(name: front ? "Pantolon ön" : "Pantolon arka", role: front ? .front : .back, outline: pts,
                                        grainline: .init(start: PatternPoint(x: xc, y: max(s.hipY * 0.5, 1)), end: PatternPoint(x: xc, y: s.length - 2)),
                                        notches: notches, seamAllowanceCm: seamAllowanceCm, cutCount: 2, mirror: false))
        }
        return out
    }

    /// Front and back skirt halves on the fold: waist, curved side to the hip, straight to an A-line hem.
    static func skirtPieces(waistQ: Double, hipQ: Double, hipDepth: Double, length: Double, hemQ: Double) throws(PatternError) -> [PatternPiece] {
        guard hipDepth < length else { throw .invalidGeometry("skirt proportions") }
        var out: [PatternPiece] = []
        for front in [true, false] {
            var pts = [PatternPoint(x: 0, y: 0), PatternPoint(x: waistQ, y: 0)]
            for k in 1...8 {
                let t = Double(k) / 8
                pts.append(PatternPoint(x: waistQ + (hipQ - waistQ) * sin(t * .pi / 2), y: hipDepth * t))
            }
            pts.append(PatternPoint(x: hemQ, y: length))
            pts.append(PatternPoint(x: 0, y: length))
            let gx = 0.4 * min(waistQ, hipQ)
            out.append(try PatternPiece(name: front ? "Etek ön" : "Etek arka", role: front ? .front : .back, outline: pts,
                                        grainline: .init(start: PatternPoint(x: gx, y: 2), end: PatternPoint(x: gx, y: length - 2)),
                                        notches: [.init("waist-side", PatternPoint(x: waistQ, y: 0)), .init("hip", PatternPoint(x: hipQ, y: hipDepth)),
                                                  .init("hem-side", PatternPoint(x: hemQ, y: length))],
                                        seamAllowanceCm: seamAllowanceCm, cutCount: 1, mirror: true))
        }
        return out
    }

    /// One decimal with a Turkish comma, locale-independent so output is deterministic.
    static func cmText(_ v: Double) -> String {
        String(format: "%.1f", v).replacingOccurrences(of: ".", with: ",")
    }
}
