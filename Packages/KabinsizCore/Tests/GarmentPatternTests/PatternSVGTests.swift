import BodyGeometry
import Foundation
@testable import GarmentPattern
import Testing

/// V37-04: the pattern as a printable, true-scale SVG.
@Suite("Pattern SVG: true scale, no overlap, escaped text")
struct PatternSVGTests {
    /// Collects the root size and every element's attributes.
    final class Collector: NSObject, XMLParserDelegate {
        var root: [String: String] = [:]
        var elements: [(name: String, attrs: [String: String])] = []
        var texts: [String] = []
        private var current = ""

        func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?, qualifiedName: String?, attributes: [String: String]) {
            if name == "svg" { root = attributes }
            elements.append((name, attributes))
            current = ""
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) { current += string }

        func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
            if name == "text" || name == "title" || name == "desc" { texts.append(current) }
        }
    }

    func parse(_ svg: String) throws -> Collector {
        let parser = XMLParser(data: Data(svg.utf8))
        let c = Collector()
        parser.delegate = c
        #expect(parser.parse(), "\(parser.parserError.map { "\($0)" } ?? "")")
        return c
    }

    func points(_ s: String) -> [(Double, Double)] {
        s.split(separator: " ").compactMap { pair in
            let xy = pair.split(separator: ",").compactMap { Double($0) }
            return xy.count == 2 ? (xy[0], xy[1]) : nil
        }
    }

    @Test("SVG-T01: parses as XML, size in mm, viewBox in mm, pieces drawn at 1 unit = 1 mm")
    func trueScale() throws {
        for kind in GarmentKind.allCases {
            let pattern = try PatternDrafter.block(for: .neutral(), kind: kind)
            let c = try parse(pattern.svg())
            let w = try #require(c.root["width"]), h = try #require(c.root["height"])
            #expect(w.hasSuffix("mm") && h.hasSuffix("mm"))
            let vb = try #require(c.root["viewBox"]).split(separator: " ").compactMap { Double($0) }
            #expect(vb.count == 4 && vb[0] == 0 && vb[1] == 0)
            #expect(abs(vb[2] - (Double(w.dropLast(2)) ?? -1)) < 0.01 && abs(vb[3] - (Double(h.dropLast(2)) ?? -1)) < 0.01, "1 unit = 1 mm")
            // The check square is exactly 100 × 100 units = 10 cm.
            let square = try #require(c.elements.first { $0.name == "rect" })
            #expect(square.attrs["width"] == "100.00" && square.attrs["height"] == "100.00")
            // Each seam line is the piece outline × 10 (cm → mm).
            let seams = c.elements.filter { $0.name == "polygon" && $0.attrs["class"] == "seam-line" }
            let cuts = c.elements.filter { $0.name == "polygon" && $0.attrs["class"] == "cut-line" }
            #expect(seams.count == pattern.pieces.count && cuts.count == pattern.pieces.count)
            for (seam, piece) in zip(seams, pattern.pieces) {
                let pts = points(seam.attrs["points"] ?? ""), xs = pts.map { $0.0 }, ys = pts.map { $0.1 }
                #expect(xs.count == piece.outline.count)
                #expect(abs((xs.max()! - xs.min()!) - piece.bounds.width * 10) < 0.05, "\(piece.name) width in mm")
                #expect(abs((ys.max()! - ys.min()!) - piece.bounds.height * 10) < 0.05, "\(piece.name) height in mm")
            }
            #expect(cuts.allSatisfy { $0.attrs["stroke-dasharray"] != nil }, "seam allowance is dashed")
            #expect(c.elements.filter { $0.name == "line" && $0.attrs["class"] == "grainline" }.count == pattern.pieces.count)
            #expect(c.texts.contains { $0.contains(pattern.pieces[0].name) })
        }
    }

    @Test("SVG-T02: pieces never overlap and stay on the sheet")
    func noOverlap() throws {
        for kind in GarmentKind.allCases {
            let pattern = try PatternDrafter.block(for: .neutral(form: .masculine), kind: kind)
            let (placed, w, h) = pattern.layout()
            for (k, a) in placed.enumerated() {
                let b = a.boundsMm
                #expect(b.minX >= 0 && b.minY >= 100 && b.maxX <= w && b.maxY <= h, "\(a.name) on sheet")
                for other in placed[(k + 1)...] {
                    let o = other.boundsMm
                    let disjoint = b.maxX <= o.minX || o.maxX <= b.minX || b.maxY <= o.minY || o.maxY <= b.minY
                    #expect(disjoint, "\(a.name) overlaps \(other.name)")
                }
            }
            // Every cutting-line point lands inside its own footprint.
            for (piece, at) in zip(pattern.pieces, placed) {
                for p in piece.cuttingOutline {
                    let x = p.x * 10 + at.offsetXMm, y = p.y * 10 + at.offsetYMm
                    #expect(x >= at.boundsMm.minX - 1e-6 && x <= at.boundsMm.maxX + 1e-6 && y >= at.boundsMm.minY - 1e-6 && y <= at.boundsMm.maxY + 1e-6)
                }
            }
        }
    }

    @Test("SVG-T03: names with markup characters are escaped and round-trip")
    func escaping() throws {
        let base = try PatternDrafter.block(for: .neutral(), kind: .skirt)
        let odd = try base.pieces.map { p in
            try PatternPiece(name: "Ön & <arka> \"x\" 'y'", role: p.role, outline: p.outline, grainline: p.grainline, notches: p.notches,
                             seamAllowanceCm: p.seamAllowanceCm, cutCount: p.cutCount, mirror: p.mirror)
        }
        let pattern = SewingPattern(kind: .skirt, pieces: odd, source: .bodyBlock, ease: base.ease, provenance: "a < b & c")
        let svg = pattern.svg()
        #expect(!svg.contains("<arka>"))
        let c = try parse(svg)
        #expect(c.texts.contains("Ön & <arka> \"x\" 'y'"))
        #expect(c.texts.contains("a < b & c"))
    }

    @Test("SVG-T04: the same pattern gives byte-identical SVG")
    func deterministic() throws {
        let a = try PatternDrafter.block(for: .neutral(form: .feminine), kind: .dress)
        let b = try PatternDrafter.block(for: .neutral(form: .feminine), kind: .dress)
        #expect(a.svg() == b.svg())
    }
}
