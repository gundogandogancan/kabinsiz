import CoreGraphics
import DomainContracts
import Foundation
import ImageIO
@testable import ProductCapture
import Testing

/// V36-03: photo → cut-out, colour and category suggestion, on the device.
@Suite("Garment photo: cut-out, colour, category (on device)")
struct GarmentPhotoAnalyzerTests {
    /// A flat garment silhouette on a plain background (the user's bed sheet or floor).
    func shape(_ fill: (Double, Double, Double), on bg: (Double, Double, Double), size: Int = 600) -> CGImage {
        let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(srgbRed: bg.0, green: bg.1, blue: bg.2, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: size, height: size))
        ctx.setFillColor(CGColor(srgbRed: fill.0, green: fill.1, blue: fill.2, alpha: 1))
        let s = Double(size) / 900
        let p = CGMutablePath()
        p.addLines(between: [(250, 120), (650, 120), (650, 600), (800, 520), (860, 640), (620, 780), (280, 780), (40, 640), (100, 520), (250, 600)]
            .map { CGPoint(x: $0.0 * s, y: $0.1 * s) })
        p.closeSubpath()
        ctx.addPath(p)
        ctx.fillPath()
        // A white button and a shadow fold: small areas that must not decide the colour.
        ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 1, alpha: 1))
        ctx.fillEllipse(in: CGRect(x: 440 * s, y: 400 * s, width: 20 * s, height: 20 * s))
        ctx.setFillColor(CGColor(srgbRed: fill.0 * 0.6, green: fill.1 * 0.6, blue: fill.2 * 0.6, alpha: 1))
        ctx.fill(CGRect(x: 300 * s, y: 200 * s, width: 30 * s, height: 400 * s))
        return ctx.makeImage()!
    }

    /// Area of the drawn silhouette, as a share of the image (shoelace formula, 900-unit square).
    let silhouetteShare: Double = {
        let pts: [(Double, Double)] = [(250, 120), (650, 120), (650, 600), (800, 520), (860, 640), (620, 780), (280, 780), (40, 640), (100, 520), (250, 600)]
        var a = 0.0
        for i in pts.indices { let (x1, y1) = pts[i], (x2, y2) = pts[(i + 1) % pts.count]; a += x1 * y2 - x2 * y1 }
        return abs(a) / 2 / (900 * 900)
    }()

    @Test("PHOTO-T01: a garment on a plain background is cut out; coverage matches the drawn shape")
    func plainCutout() throws {
        let r = try GarmentPhotoAnalyzer.analyze(shape((0.80, 0.12, 0.14), on: (0.93, 0.92, 0.90)), useVision: false, classify: false)
        #expect(r.method == .plainBackground)
        #expect(abs(r.coverage - silhouetteShare) < 0.01, "coverage \(r.coverage) vs \(silhouetteShare)")
        #expect(r.bounds.width > 500 && r.bounds.height > 400)
    }

    @Test("PHOTO-T02: the colour comes from the garment, not the background, a button or a fold")
    func colours() throws {
        let cases: [((Double, Double, Double), (Double, Double, Double), String, Bool)] = [
            ((0.80, 0.12, 0.14), (0.93, 0.92, 0.90), "kırmızı", false),
            ((0.12, 0.16, 0.33), (0.93, 0.92, 0.90), "lacivert", true),
            ((0.07, 0.07, 0.08), (0.82, 0.74, 0.62), "siyah", true),
            ((0.20, 0.55, 0.30), (0.96, 0.96, 0.95), "yeşil", false),
            ((0.96, 0.96, 0.95), (0.24, 0.25, 0.27), "beyaz", true),
        ]
        for (fill, bg, name, neutral) in cases {
            let r = try GarmentPhotoAnalyzer.analyze(shape(fill, on: bg), useVision: false, classify: false)
            #expect(r.colour.name == name && r.colour.isNeutral == neutral, "\(fill) on \(bg): \(r.colour.name)")
        }
    }

    @Test("PHOTO-T03: the cut-out keeps the original pixels exactly; outside is transparent")
    func pixelsUnchanged() throws {
        let src = shape((0.12, 0.16, 0.33), on: (0.93, 0.92, 0.90))
        let r = try GarmentPhotoAnalyzer.analyze(src, useVision: false, classify: false)
        let a = try #require(RGBABuffer(src)), b = try #require(RGBABuffer(r.cutout))
        #expect(a.width == b.width && a.height == b.height)
        var inside = 0
        for y in Swift.stride(from: 0, to: a.height, by: 7) {
            for x in Swift.stride(from: 0, to: a.width, by: 7) {
                if b.alpha(x, y) > 0.5 {
                    #expect(a.rgb(x, y) == b.rgb(x, y), "pixel changed at \(x),\(y)")
                    inside += 1
                } else {
                    #expect(b.alpha(x, y) == 0)
                }
            }
        }
        #expect(inside > 1000)
    }

    @Test("PHOTO-T04: a busy background is not cut by the plain-colour rule; the photo is kept whole")
    func busyBackground() throws {
        let size = 300
        let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        for i in 0 ..< 30 {
            for j in 0 ..< 30 {
                let v = Double((i * 7 + j * 13) % 10) / 10
                ctx.setFillColor(CGColor(srgbRed: v, green: 1 - v, blue: (v * 3).truncatingRemainder(dividingBy: 1), alpha: 1))
                ctx.fill(CGRect(x: i * 10, y: j * 10, width: 10, height: 10))
            }
        }
        #expect(GarmentPhotoAnalyzer.plainBackgroundMask(RGBABuffer(ctx.makeImage()!)!) == nil)
        let r = try GarmentPhotoAnalyzer.analyze(ctx.makeImage()!, useVision: false, classify: false)
        #expect(r.method == .none && r.coverage == 1)
        #expect(r.summaryLine.contains("elle kırp") && r.summaryLine.contains("onaylamadan kaydedilmez"))
    }

    @Test("PHOTO-T05: an empty photo is refused, not saved as a garment")
    func empty() throws {
        let ctx = CGContext(data: nil, width: 200, height: 200, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(srgbRed: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        #expect(throws: GarmentPhotoAnalyzer.Failure.noGarmentFound) {
            try GarmentPhotoAnalyzer.analyze(ctx.makeImage()!, useVision: false, classify: false)
        }
    }

    @Test("PHOTO-T06: Vision labels map to closet categories; non-clothing labels map to nothing")
    func labels() {
        #expect(GarmentPhotoAnalyzer.category(forVisionLabel: "jeans") == .bottom)
        #expect(GarmentPhotoAnalyzer.category(forVisionLabel: "coat") == .outerwear)
        #expect(GarmentPhotoAnalyzer.category(forVisionLabel: "shoes") == .shoes)
        #expect(GarmentPhotoAnalyzer.category(forVisionLabel: "t_shirt") == .top)
        #expect(GarmentPhotoAnalyzer.category(forVisionLabel: "dress") == .dress)
        for other in ["dog", "sky", "structure", "textile", "people"] {
            #expect(GarmentPhotoAnalyzer.category(forVisionLabel: other) == nil, "\(other)")
        }
    }

    /// The Blender garment renders the app ships (OWNED_ORIGINAL), when present in this checkout.
    static let garmentsDir = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
        .appendingPathComponent("apps/ios/Kabinsiz/Features/Mirror/Garments")

    func loadOwned(_ name: String) -> CGImage? {
        let url = Self.garmentsDir.appendingPathComponent(name)
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(src, 0, nil)
    }

    /// Composite onto a plain floor colour, as a user's photo on a bed or floor would be.
    func onFloor(_ img: CGImage) -> CGImage {
        let ctx = CGContext(data: nil, width: img.width + 120, height: img.height + 120, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(srgbRed: 0.36, green: 0.30, blue: 0.26, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: ctx.width, height: ctx.height))
        ctx.draw(img, in: CGRect(x: 60, y: 60, width: img.width, height: img.height))
        return ctx.makeImage()!
    }

    @Test("PHOTO-T07: our own Blender garments on a floor: cut out, neutral fabric reads as white or grey; Vision runs on the device")
    func ownedGarments() async throws {
        guard FileManager.default.fileExists(atPath: Self.garmentsDir.path) else { return }
        let expected: [String: GarmentCategory] = [
            "shirt": .top, "tee": .top, "longSleeveTee": .top, "knit": .top, "jacket": .outerwear, "coat": .outerwear,
            "jeans": .bottom, "trousers": .bottom, "shorts": .bottom, "skirt": .bottom,
            "sneakers": .shoes, "boots": .shoes, "loafers": .shoes,
        ]
        var right = 0
        for (stem, want) in expected.sorted(by: { $0.key < $1.key }) {
            let name = "\(stem)-thumb-fabric.png"
            let img = try #require(loadOwned(name), "\(name)")
            let r = try await VisionLane.run { try GarmentPhotoAnalyzer.analyze(onFloor(img)) }
            #expect(r.method != .none, "\(name): \(r.method)")
            #expect(r.coverage > 0.05 && r.coverage < 0.95, "\(name): \(r.coverage)")
            if r.categorySuggestion?.category == want { right += 1 }
            // The fabric layer is drawn neutral (the app tints it): it must read as a light neutral.
            #expect(["beyaz", "açık gri", "krem", "gri"].contains(r.colour.name), "\(name): \(r.colour.name)")
            print("PHOTO-T07 \(name): method=\(r.method.rawValue) coverage=\(String(format: "%.2f", r.coverage)) colour=\(r.colour.name) category=\(r.categorySuggestion.map { "\($0.category.rawValue) via \($0.visionLabel) \(String(format: "%.2f", $0.confidence))" } ?? "none")")
        }
        // Honest bar for a rule-based suggestion the user confirms: most of our own garments, not all.
        // Known miss: a jacket's outline equals a shirt's (aspect ≈ 1, no hem difference); it is suggested as a top.
        #expect(right >= 11, "shape suggestion right for \(right) of \(expected.count)")
        print("PHOTO-T07 shape suggestion right for \(right) of \(expected.count)")
    }

    @Test("PHOTO-T08: shape rules on clear outlines")
    func shapeRules() {
        #expect(ShapeCategorizer.category(for: .init(aspect: 0.6, legGap: 0, pieces: 2, topToHem: 1)) == .shoes)
        #expect(ShapeCategorizer.category(for: .init(aspect: 1.6, legGap: 0.9, pieces: 1, topToHem: 1)) == .bottom)
        #expect(ShapeCategorizer.category(for: .init(aspect: 0.9, legGap: 0, pieces: 1, topToHem: 0.6)) == .bottom)
        #expect(ShapeCategorizer.category(for: .init(aspect: 1.6, legGap: 0, pieces: 1, topToHem: 1.5)) == .outerwear)
        #expect(ShapeCategorizer.category(for: .init(aspect: 1.6, legGap: 0, pieces: 1, topToHem: 0.9)) == .dress)
        #expect(ShapeCategorizer.category(for: .init(aspect: 1.0, legGap: 0, pieces: 1, topToHem: 1.6)) == .top)
    }
}
