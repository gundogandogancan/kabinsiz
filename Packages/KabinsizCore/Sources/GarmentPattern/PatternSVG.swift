import Foundation

/// Where one piece sits on the printed sheet, in millimetres.
public struct PlacedPiece: Codable, Hashable, Sendable {
    public let name: String
    /// Added to a piece point (cm × 10) to get its sheet position.
    public let offsetXMm: Double
    public let offsetYMm: Double
    /// Footprint of the cutting line on the sheet.
    public let boundsMm: PatternBounds
}

extension SewingPattern {
    /// Sheet margins and the gap between pieces (mm).
    static let sheetMarginMm = 10.0
    static let pieceGapMm = 15.0
    /// Row width before the next row starts (mm): a 150 cm fabric width.
    static let sheetRowMm = 1500.0
    /// Side of the 10 cm check square printed in the top-left corner.
    static let checkSquareMm = 100.0

    /// Pieces laid out left to right in rows below the check square. Footprints are the cutting lines
    /// (seam allowance included) and never overlap: each piece gets its own box plus a gap.
    public func layout() -> (pieces: [PlacedPiece], widthMm: Double, heightMm: Double) {
        let m = Self.sheetMarginMm, gap = Self.pieceGapMm
        var x = m, y = m + Self.checkSquareMm + gap
        var rowHeight = 0.0, width = m + Self.checkSquareMm + m
        var placed: [PlacedPiece] = []
        for piece in pieces {
            let b = Polygon.bounds(piece.cuttingOutline)
            let w = b.width * 10, h = b.height * 10
            if x > m, x + w > m + Self.sheetRowMm {
                x = m
                y += rowHeight + gap
                rowHeight = 0
            }
            let dx = x - b.minX * 10, dy = y - b.minY * 10
            placed.append(PlacedPiece(name: piece.name, offsetXMm: dx, offsetYMm: dy,
                                      boundsMm: PatternBounds(minX: x, minY: y, maxX: x + w, maxY: y + h)))
            x += w + gap
            rowHeight = max(rowHeight, h)
            width = max(width, x - gap + m)
        }
        return (placed, width, y + rowHeight + m)
    }

    /// The pattern as a true-scale SVG: width and height in mm and a viewBox in mm, so 1 user unit is
    /// 1 mm and printing at 100 % gives real size (check against the 10 cm square). Seam lines are solid,
    /// cutting lines (seam allowance) dashed, fold edges dash-dot; each piece has its grainline arrow,
    /// notches and label. Plain string building, every text escaped.
    public func svg() -> String {
        let (placed, w, h) = layout()
        var s = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        s += "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"\(f(w))mm\" height=\"\(f(h))mm\" viewBox=\"0 0 \(f(w)) \(f(h))\">\n"
        s += "<title>\(Self.escape("Kabinsiz kalıp · \(kind.displayName)"))</title>\n"
        s += "<desc>\(Self.escape(provenance))</desc>\n"
        let m = Self.sheetMarginMm, sq = Self.checkSquareMm
        s += "<g id=\"check-square\"><rect x=\"\(f(m))\" y=\"\(f(m))\" width=\"\(f(sq))\" height=\"\(f(sq))\" fill=\"none\" stroke=\"#000\" stroke-width=\"0.5\"/>"
        s += "<text x=\"\(f(m + 5))\" y=\"\(f(m + 12))\" font-family=\"sans-serif\" font-size=\"6\">\(Self.escape("10 cm × 10 cm — %100 ölçekte yazdır"))</text></g>\n"
        for (k, (piece, at)) in zip(pieces, placed).enumerated() {
            func pt(_ p: PatternPoint) -> (Double, Double) { (p.x * 10 + at.offsetXMm, p.y * 10 + at.offsetYMm) }
            func points(_ ps: [PatternPoint]) -> String { ps.map { let q = pt($0); return "\(f(q.0)),\(f(q.1))" }.joined(separator: " ") }
            s += "<g id=\"piece-\(k + 1)\" data-name=\"\(Self.escape(piece.name))\">\n"
            s += "<polygon class=\"seam-line\" points=\"\(points(piece.outline))\" fill=\"none\" stroke=\"#000\" stroke-width=\"0.5\"/>\n"
            s += "<polygon class=\"cut-line\" points=\"\(points(piece.cuttingOutline))\" fill=\"none\" stroke=\"#000\" stroke-width=\"0.35\" stroke-dasharray=\"4 2\"/>\n"
            if piece.mirror {
                let b = piece.bounds
                let a = pt(PatternPoint(x: 0, y: b.minY)), c = pt(PatternPoint(x: 0, y: b.maxY))
                s += "<line class=\"fold\" x1=\"\(f(a.0))\" y1=\"\(f(a.1))\" x2=\"\(f(c.0))\" y2=\"\(f(c.1))\" stroke=\"#000\" stroke-width=\"0.7\" stroke-dasharray=\"10 2 2 2\"/>\n"
            }
            let g0 = pt(piece.grainline.start), g1 = pt(piece.grainline.end)
            s += "<line class=\"grainline\" x1=\"\(f(g0.0))\" y1=\"\(f(g0.1))\" x2=\"\(f(g1.0))\" y2=\"\(f(g1.1))\" stroke=\"#000\" stroke-width=\"0.5\"/>\n"
            s += "<polyline class=\"grain-arrow\" points=\"\(f(g0.0 - 3)),\(f(g0.1 + 6)) \(f(g0.0)),\(f(g0.1)) \(f(g0.0 + 3)),\(f(g0.1 + 6))\" fill=\"none\" stroke=\"#000\" stroke-width=\"0.5\"/>\n"
            s += "<polyline class=\"grain-arrow\" points=\"\(f(g1.0 - 3)),\(f(g1.1 - 6)) \(f(g1.0)),\(f(g1.1)) \(f(g1.0 + 3)),\(f(g1.1 - 6))\" fill=\"none\" stroke=\"#000\" stroke-width=\"0.5\"/>\n"
            for n in piece.notches {
                let q = pt(n.point)
                s += "<circle class=\"notch\" cx=\"\(f(q.0))\" cy=\"\(f(q.1))\" r=\"1.5\" fill=\"#000\"><title>\(Self.escape(n.name))</title></circle>\n"
            }
            let lx = g0.0 + 4, ly = (g0.1 + g1.1) / 2
            let detail = "\(piece.cutCount)× kes · dikiş payı \(PatternDrafter.cmText(piece.seamAllowanceCm)) cm" + (piece.mirror ? " · kumaş katına yerleştir" : "")
            s += "<text class=\"label\" x=\"\(f(lx))\" y=\"\(f(ly))\" font-family=\"sans-serif\" font-size=\"8\">\(Self.escape(piece.name))</text>\n"
            s += "<text class=\"label\" x=\"\(f(lx))\" y=\"\(f(ly + 9))\" font-family=\"sans-serif\" font-size=\"5\">\(Self.escape(detail))</text>\n"
            s += "</g>\n"
        }
        s += "</svg>\n"
        return s
    }

    static func escape(_ text: String) -> String {
        var out = ""
        for ch in text {
            switch ch {
            case "&": out += "&amp;"
            case "<": out += "&lt;"
            case ">": out += "&gt;"
            case "\"": out += "&quot;"
            case "'": out += "&apos;"
            default: out.append(ch)
            }
        }
        return out
    }
}

/// Two decimals, POSIX format (a dot, never a locale comma), so the file is byte-stable.
private func f(_ v: Double) -> String { String(format: "%.2f", v) }
