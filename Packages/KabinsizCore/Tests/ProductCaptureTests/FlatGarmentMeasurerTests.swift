import CoreGraphics
import Foundation
@testable import ProductCapture
import Testing

/// V37-03: garment size from a flat-lay photo with an A4 sheet as the ruler. Synthetic photos only:
/// every scene is drawn in millimetres, so the true size of each garment is known exactly.
@Suite("Flat garment measurer: A4 sheet scale, perspective, fail closed")
struct FlatGarmentMeasurerTests {
    /// A flat-lay scene in millimetres: dark plain floor, a coloured garment polygon, an optional white sheet.
    struct Scene {
        var canvasMM: (Double, Double)
        var garmentCM: [(Double, Double)]
        /// Where the garment's (0, 0) cm lies on the canvas, mm.
        var anchorMM: (Double, Double)
        var sheet: (centreMM: (Double, Double), sizeMM: (Double, Double), angleDeg: Double)?
        var floor = (0.17, 0.19, 0.22)
        var colour = (0.75, 0.16, 0.20)
    }

    /// T-shirt, centre-top origin, cm. Length 72; sleeves angle down, armpits at y = 24.
    static let tee: [(Double, Double)] = [(-9, 0), (9, 0), (24, 4), (44, 16), (36, 30), (25, 24), (26, 72),
                                          (-26, 72), (-25, 24), (-36, 30), (-44, 16), (-24, 4)]
    /// Trousers, centre-top origin, cm. Waist at y = 0, crotch at (0, 30), hem at y = 104.
    static let trousers: [(Double, Double)] = [(-21, 0), (21, 0), (25, 20), (20, 104), (6, 104), (0, 30),
                                               (-6, 104), (-20, 104), (-25, 20)]

    // True sizes of the drawn shapes, cm (the rules in FlatGarmentMeasurer read them at these rows).
    static let teeLength = 72.0
    static let teeChest = 2 * (25 + 2.5 / 48)          // body edge 2.5 cm below the armpit
    static let teeHem = 52.0
    static let trousersLength = 104.0
    static let trousersWaist = 2 * (21 + 0.05 * 4 / 20) // 5 mm below the top edge
    static let trousersLegOpening = 14.0
    static let trousersInseam = (74.0 * 74 + 6 * 6).squareRoot()

    static func teeScene(sheet: Bool = true, sheetSize: (Double, Double) = (210, 297), angle: Double = 0) -> Scene {
        Scene(canvasMM: (1400, 1000), garmentCM: tee, anchorMM: (540, 90),
              sheet: sheet ? ((1195, 450), sheetSize, angle) : nil)
    }

    static func trousersScene() -> Scene {
        Scene(canvasMM: (1050, 1250), garmentCM: trousers, anchorMM: (400, 80), sheet: ((840, 520), (210, 297), 30),
              colour: (0.20, 0.30, 0.55))
    }

    func render(_ s: Scene, pxPerMM: Double) -> CGImage {
        let w = Int(s.canvasMM.0 * pxPerMM), h = Int(s.canvasMM.1 * pxPerMM)
        let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: pxPerMM, y: -pxPerMM)   // draw in mm, origin top-left, y down
        ctx.setFillColor(CGColor(srgbRed: s.floor.0, green: s.floor.1, blue: s.floor.2, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: s.canvasMM.0, height: s.canvasMM.1))
        ctx.setFillColor(CGColor(srgbRed: s.colour.0, green: s.colour.1, blue: s.colour.2, alpha: 1))
        let path = CGMutablePath()
        path.addLines(between: s.garmentCM.map { CGPoint(x: s.anchorMM.0 + $0.0 * 10, y: s.anchorMM.1 + $0.1 * 10) })
        path.closeSubpath()
        ctx.addPath(path)
        ctx.fillPath()
        if let sheet = s.sheet {
            ctx.saveGState()
            ctx.translateBy(x: sheet.centreMM.0, y: sheet.centreMM.1)
            ctx.rotate(by: sheet.angleDeg * .pi / 180)
            ctx.setFillColor(CGColor(srgbRed: 0.97, green: 0.97, blue: 0.95, alpha: 1))
            ctx.fill(CGRect(x: -sheet.sizeMM.0 / 2, y: -sheet.sizeMM.1 / 2, width: sheet.sizeMM.0, height: sheet.sizeMM.1))
            ctx.restoreGState()
        }
        return ctx.makeImage()!
    }

    /// The photo a tilted phone takes: the same pinhole camera (focal `0.8 × long side` px, principal point
    /// at the photo's centre) turned by `tiltDeg` about the horizontal axis and `rollDeg` about the optical
    /// axis, still aimed at the scene's centre. This is an exact homography of the floor plane (camera
    /// rotation); the output is 25% larger so the near edge, now magnified, stays in frame.
    func tiltedPhoto(_ image: CGImage, tiltDeg: Double, rollDeg: Double, floor: (Double, Double, Double)) throws -> CGImage {
        let src = try #require(RGBABuffer(image))
        let sw = image.width, sh = image.height
        let w = sw * 5 / 4, h = sh * 5 / 4
        let f = 0.8 * Double(max(sw, sh))
        let t = tiltDeg * .pi / 180, r = rollDeg * .pi / 180
        // R = Rz(roll) · Rx(tilt); output ray q ↦ source ray Rᵀ q.
        func rotT(_ v: SIMD3<Double>) -> SIMD3<Double> {
            let a = SIMD3(cos(r) * v.x + sin(r) * v.y, -sin(r) * v.x + cos(r) * v.y, v.z)        // Rz(roll)ᵀ
            return SIMD3(a.x, cos(t) * a.y + sin(t) * a.z, -sin(t) * a.y + cos(t) * a.z)          // Rx(tilt)ᵀ
        }
        let axis = rotT(SIMD3(0, 0, 1))
        let pp = SIMD2(Double(sw) / 2, Double(sh) / 2) - f * SIMD2(axis.x / axis.z, axis.y / axis.z)
        var out = [UInt8](repeating: 255, count: w * h * 4)
        let fl = [floor.0, floor.1, floor.2].map { UInt8(($0 * 255).rounded()) }
        for y in 0 ..< h {
            for x in 0 ..< w {
                let o = (y * w + x) * 4
                let ray = rotT(SIMD3((Double(x) + 0.5 - Double(w) / 2) / f, (Double(y) + 0.5 - Double(h) / 2) / f, 1))
                let sx = pp.x + f * ray.x / ray.z - 0.5, sy = pp.y + f * ray.y / ray.z - 0.5
                guard ray.z > 0, sx >= 0, sy >= 0, sx < Double(sw - 1), sy < Double(sh - 1) else {
                    out[o] = fl[0]; out[o + 1] = fl[1]; out[o + 2] = fl[2]
                    continue
                }
                let x0 = Int(sx), y0 = Int(sy), fx = sx - Double(x0), fy = sy - Double(y0)
                for k in 0 ..< 3 {
                    func v(_ xx: Int, _ yy: Int) -> Double { Double(src.bytes[(yy * sw + xx) * 4 + k]) }
                    let top = v(x0, y0) * (1 - fx) + v(x0 + 1, y0) * fx
                    let bottom = v(x0, y0 + 1) * (1 - fx) + v(x0 + 1, y0 + 1) * fx
                    out[o + k] = UInt8((top * (1 - fy) + bottom * fy).rounded())
                }
            }
        }
        let provider = CGDataProvider(data: Data(out) as CFData)!
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
                       space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
    }

    func expectClose(_ v: FlatGarmentMeasurement.Value?, _ truth: Double, _ tag: String) {
        guard let v else { Issue.record("\(tag): missing"); return }
        #expect(abs(v.cm - truth) <= 1.5, "\(tag): \(v.cm) vs \(truth)")
        #expect(v.uncertaintyCm > 0 && v.uncertaintyCm <= 3, "\(tag): ± \(v.uncertaintyCm)")
        print("FLAT \(tag): \(v.line) (truth \(String(format: "%.2f", truth)), error \(String(format: "%+.2f", v.cm - truth)))")
    }

    func checkCommon(_ m: FlatGarmentMeasurement) {
        #expect(m.source == .photoEstimated)
        #expect(m.limitations.contains { $0.contains("Fotoğraftan tahmin") })
        #expect(m.summaryLines.count == m.values.count + m.limitations.count)
    }

    // MARK: Homography

    @Test("FLAT-T01: the 4-point homography solve recovers a known projective map; collinear points are refused")
    func homography() throws {
        let truth = PlaneHomography(matrix: [1.12, 0.07, 31.5, -0.05, 0.94, 12.25, 0.00021, -0.00013, 1])
        let from: [SIMD2<Double>] = [SIMD2(10, 20), SIMD2(1300, 40), SIMD2(1250, 980), SIMD2(30, 900)]
        let to = from.map { truth.apply($0)! }
        let solved = try #require(PlaneHomography(mapping: from, to: to))
        for (a, b) in zip(solved.m, truth.m) { #expect(abs(a - b) <= 1e-9 * max(1, abs(b)), "\(a) vs \(b)") }
        let probe = SIMD2(640.0, 512.0)
        let there = try #require(solved.apply(probe)), back = try #require(solved.inverse?.apply(there))
        #expect(abs(back.x - probe.x) < 1e-6 && abs(back.y - probe.y) < 1e-6)
        #expect(PlaneHomography(mapping: [SIMD2(0, 0), SIMD2(1, 1), SIMD2(2, 2), SIMD2(0, 5)], to: to) == nil)
    }

    // MARK: Measurements

    @Test("FLAT-T02: a T-shirt beside an A4 sheet, two pixel scales: length, pit-to-pit and hem within 1.5 cm",
          arguments: [false, true], [1.0, 0.7])
    func teeFlat(useVision: Bool, pxPerMM: Double) async throws {
        let m = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.teeScene(), pxPerMM: pxPerMM), useVision: useVision) }
        let tag = "tee vision=\(useVision) scale=\(pxPerMM)"
        print("FLAT \(tag): sheet \(m.sheet.method.rawValue) ratio \(String(format: "%.3f", m.sheet.measuredRatio)) σc \(String(format: "%.2f", m.sheet.cornerSigmaPx)) px, mask \(m.maskMethod.rawValue)")
        #expect(m.layout == .top)
        #expect(m.maskMethod == .plainBackground)
        expectClose(m.length, Self.teeLength, "\(tag) length")
        expectClose(m.chestWidth, Self.teeChest, "\(tag) chest")
        expectClose(m.hemWidth, Self.teeHem, "\(tag) hem")
        #expect(m.inseam == nil && m.waistWidth == nil)
        checkCommon(m)
    }

    @Test("FLAT-T03: trousers with the sheet turned 30°: length, waist, leg opening and inseam within 1.5 cm",
          arguments: [false, true])
    func trousersFlat(useVision: Bool) async throws {
        let m = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.trousersScene(), pxPerMM: 1), useVision: useVision) }
        let tag = "trousers vision=\(useVision)"
        print("FLAT \(tag): sheet \(m.sheet.method.rawValue) ratio \(String(format: "%.3f", m.sheet.measuredRatio))")
        #expect(m.layout == .bottom)
        expectClose(m.length, Self.trousersLength, "\(tag) length")
        expectClose(m.waistWidth, Self.trousersWaist, "\(tag) waist")
        expectClose(m.hemWidth, Self.trousersLegOpening, "\(tag) leg opening")
        expectClose(m.inseam, Self.trousersInseam, "\(tag) inseam")
        #expect(m.chestWidth == nil)
        checkCommon(m)
    }

    @Test("FLAT-T04: a phone tilted 15° and turned 4° (exact camera homography) still measures within 1.5 cm",
          arguments: [false, true])
    func perspective(useVision: Bool) async throws {
        let tee = try tiltedPhoto(render(Self.teeScene(), pxPerMM: 1), tiltDeg: 15, rollDeg: 4, floor: (0.17, 0.19, 0.22))
        let t = try await VisionLane.run { try FlatGarmentMeasurer.measure(tee, useVision: useVision) }
        print("FLAT warped tee vision=\(useVision): sheet \(t.sheet.method.rawValue) ratio \(String(format: "%.3f", t.sheet.measuredRatio)) perspective \(String(format: "%.3f", t.sheet.perspectiveIndex)) focal \(t.sheet.focalLengthPx.map { String(format: "%.0f", $0) } ?? "-") (true \(0.8 * 1400))")
        #expect(t.sheet.perspectiveIndex > 0.03)
        expectClose(t.length, Self.teeLength, "warped tee vision=\(useVision) length")
        expectClose(t.chestWidth, Self.teeChest, "warped tee vision=\(useVision) chest")
        expectClose(t.hemWidth, Self.teeHem, "warped tee vision=\(useVision) hem")

        let tr = try tiltedPhoto(render(Self.trousersScene(), pxPerMM: 1), tiltDeg: 15, rollDeg: 4, floor: (0.17, 0.19, 0.22))
        let b = try await VisionLane.run { try FlatGarmentMeasurer.measure(tr, useVision: useVision) }
        print("FLAT warped trousers vision=\(useVision): sheet ratio \(String(format: "%.3f", b.sheet.measuredRatio)) perspective \(String(format: "%.3f", b.sheet.perspectiveIndex)) focal \(b.sheet.focalLengthPx.map { String(format: "%.0f", $0) } ?? "-") (true \(0.8 * 1250))")
        #expect(b.layout == .bottom)
        expectClose(b.length, Self.trousersLength, "warped trousers vision=\(useVision) length")
        expectClose(b.waistWidth, Self.trousersWaist, "warped trousers vision=\(useVision) waist")
        expectClose(b.hemWidth, Self.trousersLegOpening, "warped trousers vision=\(useVision) leg opening")
        expectClose(b.inseam, Self.trousersInseam, "warped trousers vision=\(useVision) inseam")
    }

    @Test("FLAT-T10: a steep 25° tilt along the sheet's axis: A4 is still recognised (ratio undone for perspective) and measured; a tilted US Letter is still refused")
    func steepTilt() async throws {
        let floor = (0.17, 0.19, 0.22)
        let photo = try tiltedPhoto(render(Self.teeScene(), pxPerMM: 1), tiltDeg: 25, rollDeg: 0, floor: floor)
        let m = try await VisionLane.run { try FlatGarmentMeasurer.measure(photo, useVision: false) }
        let s = m.sheet
        let c = s.corners
        let photoRatio = (hypot(c[1].x - c[2].x, c[1].y - c[2].y) + hypot(c[3].x - c[0].x, c[3].y - c[0].y))
            / (hypot(c[0].x - c[1].x, c[0].y - c[1].y) + hypot(c[2].x - c[3].x, c[2].y - c[3].y))
        print("FLAT 25° tee: photo ratio \(String(format: "%.3f", photoRatio)), rectified \(String(format: "%.3f", s.measuredRatio)), focal \(s.focalLengthPx.map { String(format: "%.0f", $0) } ?? "-") assumed=\(s.focalLengthAssumed) (true 1120)")
        #expect(abs(photoRatio - A4SheetDetection.sideRatio) > A4SheetDetection.ratioTolerance, "the plain photo ratio alone would have refused this sheet")
        #expect(s.focalLengthAssumed)
        #expect(m.limitations.contains { $0.contains("telefon kamerası varsayılarak") })
        expectClose(m.length, Self.teeLength, "25° tee length")
        expectClose(m.chestWidth, Self.teeChest, "25° tee chest")
        expectClose(m.hemWidth, Self.teeHem, "25° tee hem")

        let letter = try tiltedPhoto(render(Self.teeScene(sheetSize: (216, 279), angle: 30), pxPerMM: 1), tiltDeg: 15, rollDeg: 4, floor: floor)
        do {
            let r = try await VisionLane.run { try FlatGarmentMeasurer.measure(letter, useVision: false) }
            Issue.record("tilted Letter accepted as A4: \(r.sheet.measuredRatio)")
        } catch let FlatGarmentMeasurer.Failure.sheetNotA4(ratio) {
            print("FLAT tilted Letter refused, rectified ratio \(String(format: "%.3f", ratio)) (true 1.292)")
            #expect(abs(ratio - 279.0 / 216) < 0.04)
        }
    }

    @Test("FLAT-T05: the uncertainty grows when the photo has fewer pixels per millimetre")
    func uncertaintyScales() async throws {
        let fine = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.teeScene(), pxPerMM: 1.0), useVision: false) }
        let coarse = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.teeScene(), pxPerMM: 0.5), useVision: false) }
        let a = try #require(fine.hemWidth?.uncertaintyCm), b = try #require(coarse.hemWidth?.uncertaintyCm)
        #expect(b > a, "± \(b) at 0.5 px/mm vs ± \(a) at 1 px/mm")
    }

    @Test("FLAT-T11: with the Vision foreground mask (the busy-floor path) the sizes still hold within 1.5 cm")
    func visionMaskPath() async throws {
        let tee = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.teeScene(), pxPerMM: 1), useVision: true, layout: nil, maskOrder: [.vision]) }
        #expect(tee.maskMethod == .visionForeground)
        #expect(tee.limitations.contains { $0.contains("Vision ile ayrıldı") })
        expectClose(tee.length, Self.teeLength, "vision-mask tee length")
        expectClose(tee.chestWidth, Self.teeChest, "vision-mask tee chest")
        expectClose(tee.hemWidth, Self.teeHem, "vision-mask tee hem")
        let tr = try await VisionLane.run { try FlatGarmentMeasurer.measure(render(Self.trousersScene(), pxPerMM: 1), useVision: true, layout: nil, maskOrder: [.vision]) }
        #expect(tr.maskMethod == .visionForeground && tr.layout == .bottom)
        expectClose(tr.length, Self.trousersLength, "vision-mask trousers length")
        expectClose(tr.waistWidth, Self.trousersWaist, "vision-mask trousers waist")
        expectClose(tr.hemWidth, Self.trousersLegOpening, "vision-mask trousers leg opening")
        expectClose(tr.inseam, Self.trousersInseam, "vision-mask trousers inseam")
    }

    // MARK: Fail closed

    @Test("FLAT-T06: no sheet → no centimetres (fails closed, never guesses a scale)", arguments: [false, true])
    func noSheet(useVision: Bool) async throws {
        let img = render(Self.teeScene(sheet: false), pxPerMM: 1)
        await #expect(throws: FlatGarmentMeasurer.Failure.noSheetFound) { try await VisionLane.run { try FlatGarmentMeasurer.measure(img, useVision: useVision) } }
        #expect(FlatGarmentMeasurer.Failure.noSheetFound.reason.hasPrefix("Kâğıt bulunamadı: ölçü yok"))
    }

    @Test("FLAT-T07: a white sheet that is not A4 (square, US Letter) is rejected as a ruler", arguments: [false, true])
    func notA4(useVision: Bool) async throws {
        for size in [(200.0, 200.0), (216.0, 279.0)] {
            let img = render(Self.teeScene(sheetSize: size), pxPerMM: 1)
            do {
                let m = try await VisionLane.run { try FlatGarmentMeasurer.measure(img, useVision: useVision) }
                Issue.record("\(size) accepted as A4: \(m.summaryLines)")
            } catch let FlatGarmentMeasurer.Failure.sheetNotA4(ratio) {
                #expect(abs(ratio - size.1 / size.0) < 0.03, "\(size): ratio \(ratio)")
                #expect(FlatGarmentMeasurer.Failure.sheetNotA4(ratio: ratio).reason.contains("A4 oranında değil"))
            }
        }
    }

    @Test("FLAT-T08: a garment running off the photo is not measured")
    func cutOff() async throws {
        var s = Self.teeScene()
        s.anchorMM = (300, 90)   // left sleeve leaves the frame
        let photo = render(s, pxPerMM: 1)
        await #expect(throws: FlatGarmentMeasurer.Failure.garmentCutOff) { try await VisionLane.run { try FlatGarmentMeasurer.measure(photo, useVision: false) } }
    }

    @Test("FLAT-T09: the pixel detector alone finds the sheet's corners within a pixel, at any angle")
    func pixelCorners() throws {
        for angle in [0.0, 30.0, 63.0] {
            let img = render(Self.teeScene(angle: angle), pxPerMM: 1)
            let sheet = try FlatGarmentMeasurer.findSheet(try #require(RGBABuffer(img)), image: nil)
            #expect(sheet.method == .pixelRegion)
            #expect(abs(sheet.measuredRatio - A4SheetDetection.sideRatio) < 0.01, "\(angle)°: ratio \(sheet.measuredRatio)")
            let c = cos(angle * .pi / 180), s = sin(angle * .pi / 180)
            let truth = [(-105.0, -148.5), (105, -148.5), (105, 148.5), (-105, 148.5)].map { (x, y) in
                CGPoint(x: 1195 + c * x - s * y, y: 450 + s * x + c * y)
            }
            for t in truth {
                let nearest = sheet.corners.map { hypot($0.x - t.x, $0.y - t.y) }.min()!
                #expect(nearest < 1.0, "\(angle)°: corner \(t) off by \(nearest) px")
            }
        }
    }
}
