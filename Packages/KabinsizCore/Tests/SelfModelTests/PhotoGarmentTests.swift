import BodyGeometry
import CoreGraphics
import CoreText
import Foundation
import GarmentPattern
import ImageIO
import ProductCapture
import Testing
@testable import SelfModel

/// A flat-lay photo drawn at 1 px = 1 mm (SYNTHETIC, OWNED_ORIGINAL): a navy T-shirt with white stripes
/// and a red "KABINSIZ" wordmark on a dark plain floor, with or without an A4 sheet beside it.
/// Body 50 cm wide (pit-to-pit), 72 cm long; the sleeves lie spread beside it.
enum FlatLay {
    static let navy = (0.12, 0.17, 0.30)

    static func tee(withSheet: Bool) -> CGImage {
        let w = 1300, h = 1000
        let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        // Top-left origin, millimetres.
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: 1, y: -1)
        ctx.setFillColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        if withSheet {
            ctx.setFillColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1)
            ctx.fill(CGRect(x: 960, y: 420, width: 210, height: 297))
        }
        let shirt = CGMutablePath()
        shirt.move(to: CGPoint(x: 300, y: 120))
        shirt.addLine(to: CGPoint(x: 430, y: 100))
        shirt.addQuadCurve(to: CGPoint(x: 570, y: 100), control: CGPoint(x: 500, y: 170))
        shirt.addLine(to: CGPoint(x: 700, y: 120))
        shirt.addLine(to: CGPoint(x: 860, y: 260))      // right sleeve
        shirt.addLine(to: CGPoint(x: 790, y: 340))
        shirt.addLine(to: CGPoint(x: 750, y: 300))
        shirt.addLine(to: CGPoint(x: 750, y: 820))
        shirt.addLine(to: CGPoint(x: 250, y: 820))
        shirt.addLine(to: CGPoint(x: 250, y: 300))
        shirt.addLine(to: CGPoint(x: 210, y: 340))      // left sleeve
        shirt.addLine(to: CGPoint(x: 140, y: 260))
        shirt.closeSubpath()
        ctx.addPath(shirt)
        ctx.setFillColor(red: navy.0, green: navy.1, blue: navy.2, alpha: 1)
        ctx.fillPath()
        ctx.saveGState()
        ctx.addPath(shirt)
        ctx.clip()
        ctx.setFillColor(red: 0.93, green: 0.93, blue: 0.90, alpha: 1)
        for y in stride(from: 420, to: 820, by: 60) { ctx.fill(CGRect(x: 0, y: y, width: w, height: 18)) }
        ctx.restoreGState()
        // Wordmark on the chest (flip back for text).
        ctx.saveGState()
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: 1, y: -1)
        let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 64, nil)
        let attrs = [kCTFontAttributeName: font, kCTForegroundColorAttributeName: CGColor(srgbRed: 0.82, green: 0.14, blue: 0.16, alpha: 1)] as CFDictionary
        let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, "KABINSIZ" as CFString, attrs))
        let width = CTLineGetTypographicBounds(line, nil, nil, nil)
        ctx.textPosition = CGPoint(x: 500 - width / 2, y: Double(h) - 330)
        CTLineDraw(line, ctx)
        ctx.restoreGState()
        return ctx.makeImage()!
    }

    static func png(_ image: CGImage) -> Data {
        let data = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, image, nil)
        CGImageDestinationFinalize(dest)
        return data as Data
    }
}

@Suite("V37-04 photo garment → pattern → 3D (PHOTO-T01…)")
struct PhotoGarmentTests {
    func proposal(withSheet: Bool) async throws -> PhotoGarmentProposal {
        let image = FlatLay.tee(withSheet: withSheet)
        return try await VisionLane.run { try PhotoGarmentIntake.read(image, useVision: false) }
    }

    @Test("PHOTO-T01 with an A4 sheet: sizes, a top, and the torso cropped for the front panel")
    func withSheet() async throws {
        let p = try await proposal(withSheet: true)
        let m = try #require(p.measurement, "\(p.noMeasurementReason ?? "")")
        #expect(abs((m.length?.cm ?? 0) - 72) < 1.5)
        #expect(abs((m.chestWidth?.cm ?? 0) - 50) < 1.5)
        #expect(p.kind == .top)
        // Torso only: 50 × 72 cm, not the 72 cm span with the sleeves.
        #expect(abs(p.frontAspect - 500.0 / 720.0) < 0.06, "aspect \(p.frontAspect)")
        #expect(p.colourName == "lacivert")
    }

    @Test("PHOTO-T02 the front texture keeps the print and is opaque on the garment's colour")
    func texture() async throws {
        let p = try await proposal(withSheet: true)
        let img = try #require(CGImageSourceCreateWithData(p.frontPNG as CFData, nil).flatMap { CGImageSourceCreateImageAtIndex($0, 0, nil) })
        let buf = try #require(RGBABuffer(img))
        var stripe = 0, navy = 0, red = 0, dark = 0, clear = 0
        for y in stride(from: 0, to: buf.height, by: 3) {
            for x in stride(from: 0, to: buf.width, by: 3) {
                let c = buf.rgb(x, y)
                if buf.alpha(x, y) < 0.99 { clear += 1 }
                if c.x > 0.85, c.y > 0.85 { stripe += 1 }
                if c.z > 0.22, c.x < 0.2 { navy += 1 }
                if c.x > 0.6, c.y < 0.3 { red += 1 }
                if abs(c.x - 0.17) < 0.02, abs(c.z - 0.18) < 0.02 { dark += 1 }
            }
        }
        #expect(clear == 0, "opaque")
        #expect(stripe > 200 && navy > 200, "stripes and ground kept: \(stripe) \(navy)")
        #expect(red > 30, "the wordmark is kept: \(red)")
        #expect(dark < 20, "the floor is not on the garment: \(dark)")
    }

    @Test("PHOTO-T03 the pattern reproduces the photo's sizes and sews onto the body with the photo on the front")
    func sewn() async throws {
        let p = try await proposal(withSheet: true)
        let g = try PhotoGarmentIntake.make(garmentID: "g1", proposal: p, kind: .top, body: nil, at: Date(timeIntervalSince1970: 0))
        #expect(g.pattern.source == .garmentMeasurements)
        #expect(g.measurements?.bodyWidth.source == .photoEstimated)
        #expect(g.basis.contains { $0.contains("A4") })
        let profile = BodyProfile.neutral()
        let body = try BodyMesh.make(from: try AvatarSnapshot.make(for: profile))
        let sewn = try PatternGarmentMesh.sew(g.pattern, onto: body, photoAspects: [.front: g.frontAspect])
        try sewn.validate(heightM: Float(profile[.height].length.centimeters / 100))
        let front = try #require(sewn.uvRegion(.front))
        #expect(front.u0 >= 0 && front.u1 <= 1 && front.v0 >= 0 && front.v1 <= 1)
        #expect(!sewn.pieces(.front).isEmpty && !sewn.pieces(.back).isEmpty)
        // The record survives the Vault round trip.
        let back = try JSONDecoder().decode(PhotoGarment.self, from: JSONEncoder().encode(g))
        #expect(back == g)
    }

    @Test("PHOTO-T04 no sheet: no centimetres; the pattern comes from the body and says so, or nothing")
    func noSheet() async throws {
        let p = try await proposal(withSheet: false)
        #expect(p.measurement == nil)
        #expect(p.noMeasurementReason?.isEmpty == false)
        #expect(throws: PhotoGarmentIntake.Failure.noSizeSource) {
            try PhotoGarmentIntake.make(garmentID: "g2", proposal: p, kind: .top, body: nil, at: Date())
        }
        let g = try PhotoGarmentIntake.make(garmentID: "g2", proposal: p, kind: .longSleeveTop, body: BodyProfile.neutral(), at: Date())
        #expect(g.measurements == nil)
        #expect(g.pattern.kind == .longSleeveTop)
        #expect(g.basis.contains { $0.contains("bedeninden") })
    }

    @Test("PHOTO-T05 bottoms: the hip is derived from the waist and named as derived")
    func bottoms() throws {
        // Waist read from a drawn flat lay (≈42 cm) → hip = waist ÷ 0.85, and the drafter accepts both.
        let mapped = PhotoGarmentIntake.garmentMeasurements(
            try FlatMeasurementStub.bottom(length: 104, waist: 42, hem: 14, inseam: 74), kind: .trousers)
        let m = try #require(mapped)
        let waist = try #require(m.value.waistWidth?.cm)
        #expect(abs(waist - 42) < 1.5)
        #expect(abs(m.value.bodyWidth.cm - waist / 0.85) < 0.01)
        #expect(m.notes.contains { $0.contains("türetildi") })
        #expect((try? PatternDrafter.pattern(from: m.value)) != nil)
    }

    @Test("PHOTO-T06 export the simulator fixture", .enabled(if: ProcessInfo.processInfo.environment["PHOTOGARMENT_FIXTURE_OUT"] != nil))
    func exportFixture() throws {
        let out = URL(fileURLWithPath: ProcessInfo.processInfo.environment["PHOTOGARMENT_FIXTURE_OUT"]!)
        try FlatLay.png(FlatLay.tee(withSheet: true)).write(to: out.appendingPathComponent("PhotoGarmentFixture.png"))
    }
}

/// Builds a bottom measurement through the real measurer on a drawn trousers flat lay would be slow; the
/// mapping is pure, so a measured value set is made by measuring a simple drawn shape instead.
enum FlatMeasurementStub {
    static func bottom(length: Double, waist: Double, hem: Double, inseam: Double) throws -> FlatGarmentMeasurement {
        // Trousers drawn at 1 px/mm with an A4 sheet; the measurer reads them (FLAT-T03 covers accuracy).
        let w = 1100, h = 1300
        let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: 1, y: -1)
        ctx.setFillColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        ctx.setFillColor(red: 0.97, green: 0.97, blue: 0.96, alpha: 1)
        ctx.fill(CGRect(x: 800, y: 500, width: 210, height: 297))
        let top = 100.0, left = 200.0, rise = (length - inseam) * 10
        let p = CGMutablePath()
        p.move(to: CGPoint(x: left, y: top))
        p.addLine(to: CGPoint(x: left + waist * 10, y: top))
        p.addLine(to: CGPoint(x: left + waist * 10 + 40, y: top + rise))
        p.addLine(to: CGPoint(x: left + waist * 10 + 40 - 20, y: top + length * 10))
        p.addLine(to: CGPoint(x: left + waist * 10 + 20 - hem * 10, y: top + length * 10))
        p.addLine(to: CGPoint(x: left + waist * 5 + 15, y: top + rise))
        p.addLine(to: CGPoint(x: left + waist * 5 - 15, y: top + rise))
        p.addLine(to: CGPoint(x: left - 20 + hem * 10, y: top + length * 10))
        p.addLine(to: CGPoint(x: left - 20, y: top + length * 10))
        p.addLine(to: CGPoint(x: left - 40, y: top + rise))
        p.closeSubpath()
        ctx.addPath(p)
        ctx.setFillColor(red: 0.3, green: 0.4, blue: 0.55, alpha: 1)
        ctx.fillPath()
        return try FlatGarmentMeasurer.measure(ctx.makeImage()!, useVision: false, layout: .bottom)
    }
}
