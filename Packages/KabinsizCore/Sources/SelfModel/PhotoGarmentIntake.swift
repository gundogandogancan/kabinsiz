import BodyGeometry
import CoreGraphics
import DomainContracts
import Foundation
import GarmentPattern
import ImageIO
import ProductCapture
import UniformTypeIdentifiers

/// A wardrobe garment rebuilt from its own photo (V37, ADR-018 §7): the sewing pattern it was drafted
/// from, and the photo's own cut-out pixels for the front panel. The figure wears the pattern sewn
/// around the body (`PatternGarmentMesh`), not a flat picture. Stored next to the wardrobe in the Vault.
public struct PhotoGarment: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public let garmentID: String
    public let pattern: SewingPattern
    /// The garment's sizes read against an A4 sheet; nil when the pattern was drafted from the user's body.
    public let measurements: GarmentMeasurements?
    /// The front of the garment as photographed, cropped to the torso (tops) or the whole garment
    /// (bottoms), on the garment's own colour where the photo had background. Opaque PNG.
    public let frontPNG: Data
    /// Width ÷ height of `frontPNG`.
    public let frontAspect: Double
    /// Main colour, for the back and the sleeves (the photo shows the front only).
    public let colourRGB: SIMD3<Double>
    /// Plain Turkish lines shown with the garment: where every number came from.
    public let basis: [String]
    public let createdAt: Date

    public init(garmentID: String, pattern: SewingPattern, measurements: GarmentMeasurements?, frontPNG: Data,
                frontAspect: Double, colourRGB: SIMD3<Double>, basis: [String], createdAt: Date) {
        self.garmentID = garmentID
        self.pattern = pattern
        self.measurements = measurements
        self.frontPNG = frontPNG
        self.frontAspect = frontAspect
        self.colourRGB = colourRGB
        self.basis = basis
        self.createdAt = createdAt
    }
}

/// What one garment photo says before the user confirms anything. Nothing is saved from it unasked.
public struct PhotoGarmentProposal: Sendable {
    /// Suggested pattern kind; the user picks the final one.
    public let kind: GarmentKind
    public let colourName: String
    public let isNeutralColour: Bool
    public let colourRGB: SIMD3<Double>
    public let cutoutMethod: CutoutMethod
    /// The front texture (see `PhotoGarment.frontPNG`).
    public let frontPNG: Data
    public let frontAspect: Double
    /// Sizes read against an A4 sheet in the same photo; nil without a sheet.
    public let measurement: FlatGarmentMeasurement?
    /// Why there are no sizes (Turkish), when there is no measurement.
    public let noMeasurementReason: String?
}

public enum PhotoGarmentIntake {
    public enum Failure: Error, Equatable, Sendable {
        case unreadableImage
        case noGarmentFound
        /// Neither an A4 sheet in the photo nor a body to draft from: no honest size for the pattern.
        case noSizeSource

        public var reason: String {
            switch self {
            case .unreadableImage: "Fotoğraf okunamadı."
            case .noGarmentFound: "Fotoğrafta giysi ayrılamadı. Giysiyi düz, tek renk bir zemine serip yeniden çek."
            case .noSizeSource: "Ölçü yok: fotoğrafta A4 kâğıt bulunamadı ve henüz bir modelin yok. Önce modelini kur ya da giysinin yanına A4 kâğıt koy."
            }
        }
    }

    /// The kinds a photo garment can be sewn as on the figure today.
    public static let sewableKinds: [GarmentKind] = [.top, .longSleeveTop, .coat, .trousers, .shorts, .skirt]

    /// Reads a flat-lay photo: cut-out, colour, a kind suggestion and, with an A4 sheet, sizes.
    /// Synchronous Vision work: call from a background queue (`VisionLane`).
    public static func read(_ image: CGImage, useVision: Bool = true) throws(Failure) -> PhotoGarmentProposal {
        let analysis: GarmentPhotoAnalysis
        do { analysis = try GarmentPhotoAnalyzer.analyze(image, useVision: useVision, classify: useVision) } catch let e as GarmentPhotoAnalyzer.Failure {
            throw e == .unreadableImage ? .unreadableImage : .noGarmentFound
        } catch { throw .noGarmentFound }
        guard analysis.method != .none else { throw .noGarmentFound }

        var measurement: FlatGarmentMeasurement?
        var reason: String?
        do { measurement = try FlatGarmentMeasurer.measure(image, useVision: useVision) } catch let e as FlatGarmentMeasurer.Failure {
            reason = e.reason
        } catch { reason = "Ölçü okunamadı." }

        let layoutIsBottom = measurement?.layout == .bottom
        let kind = suggestedKind(category: analysis.categorySuggestion?.category, bottomLayout: layoutIsBottom, measurement: measurement)
        guard let front = frontTexture(analysis, sheet: measurement?.sheet, bottom: kind.isBottom) else { throw .noGarmentFound }
        return PhotoGarmentProposal(kind: kind, colourName: analysis.colour.name, isNeutralColour: analysis.colour.isNeutral,
                                    colourRGB: analysis.colourRGB, cutoutMethod: analysis.method, frontPNG: front.png,
                                    frontAspect: front.aspect, measurement: measurement, noMeasurementReason: reason)
    }

    /// The garment as the figure will wear it. With sizes from the photo the pattern reproduces the
    /// garment; without, it is the basic block for `kind` on the user's body, and says so.
    public static func make(garmentID: String, proposal p: PhotoGarmentProposal, kind: GarmentKind, body: BodyProfile?,
                            at date: Date) throws -> PhotoGarment {
        var basis: [String] = []
        var measurements: GarmentMeasurements?
        if let m = p.measurement, let gm = garmentMeasurements(m, kind: kind) {
            measurements = gm.value
            basis.append("Ölçüler fotoğraftaki A4 kâğıda göre okundu: tahmin, mezura ölçüsü değil.")
            basis += gm.notes
        }
        let pattern: SewingPattern
        if let measurements, let drafted = try? PatternDrafter.pattern(from: measurements) {
            pattern = drafted
        } else if let body {
            measurements = nil
            pattern = try PatternDrafter.block(for: body, kind: kind)
            basis.append("Bu fotoğrafta ölçü yok: kalıp senin bedeninden standart bollukla çizildi, giysinin kendi ölçüsü değil.")
        } else {
            throw Failure.noSizeSource
        }
        basis.append("Ön yüzde fotoğrafın kendi pikselleri var; arka ve kollar ana renkte (fotoğraf yalnız önü gösteriyor).")
        return PhotoGarment(garmentID: garmentID, pattern: pattern, measurements: measurements, frontPNG: p.frontPNG,
                            frontAspect: p.frontAspect, colourRGB: p.colourRGB, basis: basis, createdAt: date)
    }

    /// Flat-lay sizes → the pattern drafter's input. Tops need the pit-to-pit width; bottoms the waist.
    /// The hip of a bottom is not read from a flat lay: it is derived from the waist and named so.
    static func garmentMeasurements(_ m: FlatGarmentMeasurement, kind: GarmentKind) -> (value: GarmentMeasurements, notes: [String])? {
        func v(_ x: FlatGarmentMeasurement.Value?) -> GarmentMeasurements.Value? { x.map { .init($0.cm, .photoEstimated) } }
        guard let length = v(m.length) else { return nil }
        if kind.isBottom {
            guard let waist = m.waistWidth else { return nil }
            // PatternDrafter derives an unknown waist as 0.85 × hip; the inverse gives the hip here.
            let hip = GarmentMeasurements.Value(waist.cm / 0.85, .photoEstimated)
            let value = GarmentMeasurements(kind: kind, bodyWidth: hip, length: length, hemWidth: v(m.hemWidth),
                                            waistWidth: v(m.waistWidth), inseam: kind == .skirt ? nil : v(m.inseam))
            guard (try? value.validate()) != nil else { return nil }
            return (value, ["Kalça genişliği fotoğraftan okunmaz: bel genişliğinden türetildi (ölçü değil)."])
        }
        guard let chest = v(m.chestWidth) else { return nil }
        let value = GarmentMeasurements(kind: kind, bodyWidth: chest, length: length, hemWidth: v(m.hemWidth))
        guard (try? value.validate()) != nil else { return nil }
        return (value, [])
    }

    static func suggestedKind(category: GarmentCategory?, bottomLayout: Bool, measurement: FlatGarmentMeasurement?) -> GarmentKind {
        if bottomLayout || category == .bottom {
            if let m = measurement, m.inseam == nil { return .skirt }
            if let len = measurement?.length?.cm, len < 60 { return .shorts }
            return .trousers
        }
        if category == .outerwear || category == .weatherProtection { return .coat }
        return .top
    }

    // MARK: Front texture

    /// The garment's front, cropped, on its own colour. Tops are cut to the torso (the span below the
    /// armholes) so the sleeves lying beside it are not stretched onto the front panel.
    static func frontTexture(_ a: GarmentPhotoAnalysis, sheet: A4SheetDetection?, bottom: Bool, maxSide: Int = 1024) -> (png: Data, aspect: Double)? {
        guard var buf = RGBABuffer(a.cutout) else { return nil }
        if let sheet { clear(sheet, in: &buf) }
        guard let box = opaqueBounds(buf) else { return nil }
        var crop = box
        if !bottom {
            // Torso span: the garment's run through the middle column, measured 70% of the way down.
            let y = box.minY + Int(Double(box.height) * 0.7)
            let mid = (box.minX + box.maxX) / 2
            var l = mid, r = mid
            while l > box.minX, buf.alpha(l - 1, y) > 0.5 { l -= 1 }
            while r < box.maxX - 1, buf.alpha(r + 1, y) > 0.5 { r += 1 }
            if r - l > box.width / 4 { crop = Box(minX: l, minY: box.minY, maxX: r + 1, maxY: box.maxY) }
        }
        let scale = min(1, Double(maxSide) / Double(max(crop.width, crop.height)))
        let w = max(1, Int(Double(crop.width) * scale)), h = max(1, Int(Double(crop.height) * scale))
        guard let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cleaned = buf.applying(mask: (0 ..< buf.width * buf.height).map { Float(buf.bytes[$0 * 4 + 3]) / 255 }) else { return nil }
        // Background → the garment's colour, then the photo's own pixels on top.
        ctx.setFillColor(red: a.colourRGB.x, green: a.colourRGB.y, blue: a.colourRGB.z, alpha: 1)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
        ctx.interpolationQuality = .high
        // CG origin is bottom-left; the crop box is top-left.
        let fullH = Double(buf.height)
        let drawRect = CGRect(x: -Double(crop.minX) * scale, y: -(fullH - Double(crop.maxY)) * scale,
                              width: Double(buf.width) * scale, height: fullH * scale)
        ctx.draw(cleaned, in: drawRect)
        guard let out = ctx.makeImage() else { return nil }
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, out, nil)
        guard CGImageDestinationFinalize(dest) else { return nil }
        return (data as Data, Double(w) / Double(h))
    }

    struct Box { var minX: Int, minY: Int, maxX: Int, maxY: Int
        var width: Int { maxX - minX }
        var height: Int { maxY - minY }
    }

    /// The A4 sheet is not the garment: its pixels (grown by a margin for the blurred edge) are cleared.
    static func clear(_ sheet: A4SheetDetection, in buf: inout RGBABuffer) {
        let margin = max(4, sheet.edgeWidthPx * 2)
        let xs = sheet.corners.map(\.x), ys = sheet.corners.map(\.y)
        let x0 = max(0, Int(xs.min()! - margin)), x1 = min(buf.width - 1, Int(xs.max()! + margin))
        let y0 = max(0, Int(ys.min()! - margin)), y1 = min(buf.height - 1, Int(ys.max()! + margin))
        guard x0 <= x1, y0 <= y1 else { return }
        for y in y0 ... y1 {
            for x in x0 ... x1 where inside(CGPoint(x: x, y: y), sheet.corners, grow: margin) {
                buf.bytes[(y * buf.width + x) * 4 + 3] = 0
            }
        }
    }

    static func inside(_ p: CGPoint, _ quad: [CGPoint], grow: Double) -> Bool {
        let c = CGPoint(x: quad.map(\.x).reduce(0, +) / Double(quad.count), y: quad.map(\.y).reduce(0, +) / Double(quad.count))
        // Grow the quad about its centre, then a convex point-in-polygon test.
        let grown = quad.map { q -> CGPoint in
            let dx = q.x - c.x, dy = q.y - c.y, d = max(1, (dx * dx + dy * dy).squareRoot())
            return CGPoint(x: q.x + dx / d * grow, y: q.y + dy / d * grow)
        }
        var sign = 0.0
        for i in 0 ..< grown.count {
            let a = grown[i], b = grown[(i + 1) % grown.count]
            let cross = (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x)
            if cross != 0 {
                if sign == 0 { sign = cross } else if (cross > 0) != (sign > 0) { return false }
            }
        }
        return true
    }

    static func opaqueBounds(_ buf: RGBABuffer) -> Box? {
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for y in 0 ..< buf.height {
            for x in 0 ..< buf.width where buf.bytes[(y * buf.width + x) * 4 + 3] > 127 {
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard maxX >= minX, maxY >= minY, maxX - minX > 8, maxY - minY > 8 else { return nil }
        return Box(minX: minX, minY: minY, maxX: maxX + 1, maxY: maxY + 1)
    }
}

extension GarmentKind {
    public var isBottom: Bool { self == .trousers || self == .shorts || self == .skirt }

    /// The wardrobe category the garment is saved under.
    public var wardrobeCategory: GarmentCategory {
        switch self {
        case .top, .longSleeveTop: .top
        case .trousers, .shorts, .skirt: .bottom
        case .dress: .dress
        case .coat: .outerwear
        }
    }

    /// A name the wardrobe's shape reader understands ("uzun kollu", "şort", "etek", "kaban").
    public var wardrobeName: String {
        switch self {
        case .top: "Tişört"
        case .longSleeveTop: "Uzun kollu üst"
        case .coat: "Kaban"
        case .trousers: "Pantolon"
        case .shorts: "Şort"
        case .skirt: "Etek"
        case .dress: "Elbise"
        }
    }
}
