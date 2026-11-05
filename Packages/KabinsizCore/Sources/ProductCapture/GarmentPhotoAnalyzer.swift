import CoreGraphics
import DomainContracts
import Foundation
import Vision

// V36-03 (rival recon: Alta's SAM cut-out, Cladwell's batch add). A garment photo becomes a cut-out,
// a colour name and a category suggestion, all on the device. The photo never leaves the phone and is
// never changed: the cut-out is a mask over the original pixels (no recolouring, no reshaping, the
// complaint behind 20 of the 420 rival reviews). Every suggestion waits for the user's confirmation.

/// How the garment was separated from the background, said plainly in the UI.
public enum CutoutMethod: String, Codable, Sendable {
    /// Apple Vision foreground instance mask (iOS 17+, on the device).
    case visionForeground = "VISION_FOREGROUND"
    /// The background is one plain colour: pixels far from the border colour are the garment.
    case plainBackground = "PLAIN_BACKGROUND"
    /// Nothing could be separated; the whole photo is kept and the user crops by hand.
    case none = "NONE"
}

/// A colour word the closet uses, with whether it goes with everything.
public struct GarmentColourName: Hashable, Sendable {
    public let name: String
    public let isNeutral: Bool
}

public struct GarmentPhotoAnalysis: Sendable {
    /// The original pixels with everything outside the garment transparent. Same size as the input.
    public let cutout: CGImage
    public let method: CutoutMethod
    /// Share of the photo the garment covers, 0…1.
    public let coverage: Double
    /// Garment bounds in pixels (origin top-left), for a tight thumbnail.
    public let bounds: CGRect
    /// The main colour, from the garment pixels only.
    public let colour: GarmentColourName
    /// The mean sRGB of the main colour cluster, 0…1.
    public let colourRGB: SIMD3<Double>
    /// A category suggestion and the on-device label it came from; nil when nothing clothing-like was seen.
    public let categorySuggestion: CategorySuggestion?

    public struct CategorySuggestion: Hashable, Sendable {
        public let category: GarmentCategory
        /// Where the suggestion came from: an Apple classifier label, or "şekil" (the cut-out's shape).
        public let visionLabel: String
        public let confidence: Float
    }

    /// One line for the confirm screen. Never presents a guess as a fact.
    public var summaryLine: String {
        var parts = ["Renk önerisi: \(colour.name)"]
        if let c = categorySuggestion { parts.append("Tür önerisi: \(c.category.displayName)") }
        parts.append(method == .none ? "Arka plan ayrılamadı, elle kırp" : "Arka plan cihazda ayrıldı")
        return parts.joined(separator: " · ") + " · onaylamadan kaydedilmez"
    }
}

public enum GarmentPhotoAnalyzer {
    public enum Failure: Error, Equatable { case unreadableImage, noGarmentFound }

    public static func analyze(_ image: CGImage, useVision: Bool = true, classify: Bool = true) throws -> GarmentPhotoAnalysis {
        guard let rgba = RGBABuffer(image) else { throw Failure.unreadableImage }
        var method = CutoutMethod.none
        var mask: [Float]?
        if useVision, let m = try? visionMask(image, width: rgba.width, height: rgba.height), coverage(of: m) > 0.02 {
            mask = m
            method = .visionForeground
        }
        if mask == nil, let m = plainBackgroundMask(rgba) {
            mask = m
            method = .plainBackground
        }
        let finalMask = mask ?? [Float](repeating: 1, count: rgba.width * rgba.height)
        let cover = coverage(of: finalMask)
        guard cover > 0.005 else { throw Failure.noGarmentFound }
        guard let cut = rgba.applying(mask: finalMask) else { throw Failure.unreadableImage }
        let rgb = dominantColour(rgba, mask: finalMask)
        var suggestion = classify ? (try? categorySuggestion(image)) ?? nil : nil
        if suggestion == nil, method != .none {
            suggestion = ShapeCategorizer.suggest(mask: finalMask, width: rgba.width, height: rgba.height)
        }
        return GarmentPhotoAnalysis(cutout: cut, method: method, coverage: cover, bounds: bounds(of: finalMask, width: rgba.width),
                                    colour: colourName(rgb), colourRGB: rgb, categorySuggestion: suggestion)
    }

    // MARK: Masks

    package static func visionMask(_ image: CGImage, width: Int, height: Int) throws -> [Float]? {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try ProductLabelReader.withCPUFallback { cpu in
            if cpu { ProductLabelReader.forceCPU(request) }
            try VisionSerial.run { try handler.perform([request]) }
        }
        guard let obs = request.results?.first, !obs.allInstances.isEmpty else { return nil }
        let buffer = try obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let w = CVPixelBufferGetWidth(buffer), h = CVPixelBufferGetHeight(buffer)
        guard w == width, h == height, let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        var out = [Float](repeating: 0, count: w * h)
        for y in 0 ..< h {
            let row = base.advanced(by: y * rowBytes).assumingMemoryBound(to: Float32.self)
            for x in 0 ..< w { out[y * w + x] = row[x] > 0.5 ? 1 : 0 }
        }
        return out
    }

    /// One plain background (studio sweep, bed sheet, floor): estimate it from the border and keep what
    /// differs. Refuses busy borders, where this rule would cut the garment wrongly.
    package static func plainBackgroundMask(_ img: RGBABuffer, threshold: Double = 0.12) -> [Float]? {
        let w = img.width, h = img.height
        var border: [SIMD3<Double>] = []
        let step = max(1, (w + h) / 400)
        for x in stride(from: 0, to: w, by: step) { border.append(img.rgb(x, 0)); border.append(img.rgb(x, h - 1)) }
        for y in stride(from: 0, to: h, by: step) { border.append(img.rgb(0, y)); border.append(img.rgb(w - 1, y)) }
        let bg = median(border)
        let spread = border.map { distance($0, bg) }.sorted()[border.count * 9 / 10]
        guard spread < threshold * 0.6 else { return nil }
        var mask = [Float](repeating: 0, count: w * h)
        for y in 0 ..< h {
            for x in 0 ..< w where img.alpha(x, y) > 0.5 && distance(img.rgb(x, y), bg) > threshold {
                mask[y * w + x] = 1
            }
        }
        return mask
    }

    package static func coverage(of mask: [Float]) -> Double {
        mask.isEmpty ? 0 : Double(mask.reduce(0, +)) / Double(mask.count)
    }

    package static func bounds(of mask: [Float], width: Int) -> CGRect {
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for (i, v) in mask.enumerated() where v > 0.5 {
            let x = i % width, y = i / width
            minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
        }
        guard maxX >= 0 else { return .zero }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    // MARK: Colour

    /// The biggest of three k-means clusters over the garment pixels (deterministic seeds), so a print,
    /// a shadow fold or a white button does not decide the colour.
    package static func dominantColour(_ img: RGBABuffer, mask: [Float]) -> SIMD3<Double> {
        var pixels: [SIMD3<Double>] = []
        let stride = max(1, Int((Double(img.width * img.height) / 40000).squareRoot()))
        for y in Swift.stride(from: 0, to: img.height, by: stride) {
            for x in Swift.stride(from: 0, to: img.width, by: stride) where mask[y * img.width + x] > 0.5 {
                pixels.append(img.rgb(x, y))
            }
        }
        guard !pixels.isEmpty else { return SIMD3(0.5, 0.5, 0.5) }
        let sorted = pixels.sorted { $0.sum() < $1.sum() }
        var centres = [sorted[sorted.count / 6], sorted[sorted.count / 2], sorted[sorted.count * 5 / 6]]
        var labels = [Int](repeating: 0, count: pixels.count)
        for _ in 0 ..< 10 {
            for (i, p) in pixels.enumerated() {
                labels[i] = (0 ..< 3).min { distance(p, centres[$0]) < distance(p, centres[$1]) }!
            }
            for k in 0 ..< 3 {
                let members = pixels.indices.filter { labels[$0] == k }.map { pixels[$0] }
                if !members.isEmpty { centres[k] = members.reduce(.zero, +) / Double(members.count) }
            }
        }
        let biggest = (0 ..< 3).max { a, b in labels.filter { $0 == a }.count < labels.filter { $0 == b }.count }!
        return centres[biggest]
    }

    /// Turkish closet colour words. Neutral = goes with everything (the gap finder's "nötr temel").
    static let palette: [(String, SIMD3<Double>, Bool)] = [
        ("siyah", SIMD3(0.07, 0.07, 0.08), true), ("beyaz", SIMD3(0.96, 0.96, 0.95), true),
        ("krem", SIMD3(0.93, 0.89, 0.80), true), ("bej", SIMD3(0.82, 0.74, 0.62), true),
        ("açık gri", SIMD3(0.75, 0.75, 0.76), true), ("gri", SIMD3(0.50, 0.50, 0.52), true),
        ("antrasit", SIMD3(0.24, 0.25, 0.27), true), ("lacivert", SIMD3(0.12, 0.16, 0.33), true),
        ("kahverengi", SIMD3(0.42, 0.27, 0.16), true), ("camel", SIMD3(0.70, 0.52, 0.33), true),
        ("haki", SIMD3(0.45, 0.45, 0.30), false), ("mavi", SIMD3(0.18, 0.38, 0.72), false),
        ("açık mavi", SIMD3(0.60, 0.75, 0.90), false), ("kot mavisi", SIMD3(0.27, 0.36, 0.50), false),
        ("kırmızı", SIMD3(0.80, 0.12, 0.14), false), ("bordo", SIMD3(0.48, 0.10, 0.16), false),
        ("pembe", SIMD3(0.95, 0.62, 0.72), false), ("turuncu", SIMD3(0.95, 0.50, 0.15), false),
        ("sarı", SIMD3(0.97, 0.85, 0.25), false), ("yeşil", SIMD3(0.20, 0.55, 0.30), false),
        ("açık yeşil", SIMD3(0.60, 0.80, 0.62), false),
        ("zeytin yeşili", SIMD3(0.36, 0.38, 0.18), false), ("mor", SIMD3(0.45, 0.25, 0.58), false),
    ]

    public static func colourName(_ rgb: SIMD3<Double>) -> GarmentColourName {
        let lab = toLab(rgb)
        let best = palette.min { distance(toLab($0.1), lab) < distance(toLab($1.1), lab) }!
        return GarmentColourName(name: best.0, isNeutral: best.2)
    }

    // MARK: Category

    /// Apple's on-device image classifier labels mapped to closet categories. Only clothing labels count.
    static let labelMap: [(String, GarmentCategory)] = [
        ("jeans", .bottom), ("trousers", .bottom), ("pants", .bottom), ("shorts", .bottom), ("skirt", .bottom),
        ("dress", .dress), ("gown", .dress), ("suit", .dress),
        ("coat", .outerwear), ("jacket", .outerwear), ("blazer", .outerwear), ("raincoat", .weatherProtection),
        ("shoes", .shoes), ("shoe", .shoes), ("sneaker", .shoes), ("boot", .shoes), ("sandal", .shoes), ("footwear", .shoes),
        ("shirt", .top), ("t_shirt", .top), ("tshirt", .top), ("sweater", .top), ("blouse", .top), ("top", .top), ("hoodie", .top),
        ("swimwear", .swimwear), ("bikini", .swimwear),
        ("hat", .accessory), ("scarf", .accessory), ("bag", .accessory), ("handbag", .accessory), ("belt", .accessory),
    ]

    public static func category(forVisionLabel label: String) -> GarmentCategory? {
        let words = Set(label.lowercased().split(whereSeparator: { !$0.isLetter && $0 != "_" }).map(String.init))
        return labelMap.first { words.contains($0.0) }?.1
    }

    static func categorySuggestion(_ image: CGImage) throws -> GarmentPhotoAnalysis.CategorySuggestion? {
        let request = VNClassifyImageRequest()
        try ProductLabelReader.withCPUFallback { cpu in
            if cpu { ProductLabelReader.forceCPU(request) }
            try VisionSerial.run { try VNImageRequestHandler(cgImage: image, options: [:]).perform([request]) }
        }
        // Apple's taxonomy is weak on garments (measured 2026-11-04: 0.01–0.03 on clothing renders), so a
        // label only counts when Vision is fairly sure; otherwise the cut-out's shape decides.
        for obs in (request.results ?? []).sorted(by: { $0.confidence > $1.confidence }) where obs.confidence >= 0.3 {
            if let c = category(forVisionLabel: obs.identifier) {
                return .init(category: c, visionLabel: obs.identifier, confidence: obs.confidence)
            }
        }
        return nil
    }

    // MARK: Maths

    package static func distance(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double { ((a - b) * (a - b)).sum().squareRoot() }

    package static func median(_ xs: [SIMD3<Double>]) -> SIMD3<Double> {
        func m(_ k: Int) -> Double { let s = xs.map { $0[k] }.sorted(); return s[s.count / 2] }
        return SIMD3(m(0), m(1), m(2))
    }

    /// sRGB → CIELAB (D65), scaled to 0…1-ish so distances compare perceptually.
    package static func toLab(_ c: SIMD3<Double>) -> SIMD3<Double> {
        func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
        let r = lin(c.x), g = lin(c.y), b = lin(c.z)
        let x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
        let y = 0.2126 * r + 0.7152 * g + 0.0722 * b
        let z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
        func f(_ t: Double) -> Double { t > 0.008856 ? cbrt(t) : 7.787 * t + 16 / 116 }
        return SIMD3(116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))) / 100
    }
}

/// Straight (non-premultiplied) RGBA8 pixels of an image, sRGB.
package struct RGBABuffer {
    package let width: Int
    package let height: Int
    package var bytes: [UInt8]

    package init?(_ image: CGImage) {
        width = image.width
        height = image.height
        bytes = [UInt8](repeating: 0, count: width * height * 4)
        let ok = bytes.withUnsafeMutableBytes { ptr -> Bool in
            guard let ctx = CGContext(data: ptr.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                                      space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard ok else { return nil }
        for i in stride(from: 0, to: bytes.count, by: 4) where bytes[i + 3] > 0 && bytes[i + 3] < 255 {
            let a = Double(bytes[i + 3]) / 255
            for k in 0 ..< 3 { bytes[i + k] = UInt8(min(255, (Double(bytes[i + k]) / a).rounded())) }
        }
    }

    package func rgb(_ x: Int, _ y: Int) -> SIMD3<Double> {
        let i = (y * width + x) * 4
        return SIMD3(Double(bytes[i]), Double(bytes[i + 1]), Double(bytes[i + 2])) / 255
    }

    package func alpha(_ x: Int, _ y: Int) -> Double { Double(bytes[(y * width + x) * 4 + 3]) / 255 }

    /// The original pixels where the mask is set; transparent elsewhere. Nothing is recoloured.
    package func applying(mask: [Float]) -> CGImage? {
        var out = [UInt8](repeating: 0, count: bytes.count)
        for p in 0 ..< width * height where mask[p] > 0.5 {
            let a = Double(bytes[p * 4 + 3]) / 255
            for k in 0 ..< 3 { out[p * 4 + k] = UInt8((Double(bytes[p * 4 + k]) * a).rounded()) }
            out[p * 4 + 3] = bytes[p * 4 + 3]
        }
        let data = Data(out) as CFData
        guard let provider = CGDataProvider(data: data) else { return nil }
        return CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: width * 4,
                       space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}

/// A category from the cut-out's outline alone, explainable and on the device: two legs, two shoes,
/// sleeves, length. It is a suggestion the user confirms, never a label stored without a tap.
public enum ShapeCategorizer {
    public struct Features: Equatable, Sendable {
        /// Bounding-box height ÷ width.
        public let aspect: Double
        /// Share of rows in the lower third with an empty middle and garment on both sides.
        public let legGap: Double
        /// Separate pieces bigger than 8% of the garment (a pair of shoes is 2).
        public let pieces: Int
        /// Garment width at 25% height ÷ width at 85% height (sleeves spread wide at the top).
        public let topToHem: Double
    }

    public static func features(mask: [Float], width: Int, height: Int) -> Features? {
        let b = GarmentPhotoAnalyzer.bounds(of: mask, width: width)
        guard b.width > 8, b.height > 8 else { return nil }
        let x0 = Int(b.minX), x1 = Int(b.maxX) - 1, y0 = Int(b.minY), y1 = Int(b.maxY) - 1
        func on(_ x: Int, _ y: Int) -> Bool { mask[y * width + x] > 0.5 }
        func rowWidth(_ y: Int) -> Int {
            var lo = -1, hi = -1
            for x in x0 ... x1 where on(x, y) { if lo < 0 { lo = x }; hi = x }
            return lo < 0 ? 0 : hi - lo + 1
        }
        // Two legs: in the lowest rows the centre column is empty while both sides have garment.
        // Measured over the lower third (trousers) and the lowest tenth (shorts, whose legs part only at the hem).
        func gapShare(from fraction: Double, half: Double) -> Double {
            let midL = x0 + Int(Double(b.width) * (0.5 - half)), midR = x0 + Int(Double(b.width) * (0.5 + half))
            var gap = 0, rows = 0
            for y in stride(from: y0 + Int(Double(b.height) * fraction), through: y1, by: 1) {
                rows += 1
                let middleEmpty = (midL ... midR).allSatisfy { !on($0, y) }
                let left = (x0 ..< midL).contains { on($0, y) }, right = ((midR + 1) ... x1).contains { on($0, y) }
                if middleEmpty, left, right { gap += 1 }
            }
            return rows == 0 ? 0 : Double(gap) / Double(rows)
        }
        let legGap = max(gapShare(from: 0.67, half: 0.04), gapShare(from: 0.92, half: 0.02))
        let top = rowWidth(y0 + Int(Double(b.height) * 0.25)), hem = rowWidth(y0 + Int(Double(b.height) * 0.85))
        return Features(aspect: Double(b.height) / Double(b.width), legGap: legGap,
                        pieces: pieces(mask: mask, width: width, height: height), topToHem: hem == 0 ? 9 : Double(top) / Double(hem))
    }

    public static func category(for f: Features) -> GarmentCategory {
        // A pair of shoes is low and wide (our renders: 0.26–0.64); every top, bottom and coat is taller.
        if f.aspect < 0.7 || (f.pieces >= 2 && f.aspect < 1.0) { return .shoes }
        if f.legGap > 0.5 { return .bottom }
        if f.topToHem < 0.8, f.aspect < 1.3 { return .bottom }       // a skirt: narrow waist, wide hem
        if f.aspect > 1.25 { return f.topToHem > 1.15 ? .outerwear : .dress }   // long: coat (sleeves) or dress
        return .top
    }

    static func suggest(mask: [Float], width: Int, height: Int) -> GarmentPhotoAnalysis.CategorySuggestion? {
        guard let f = features(mask: mask, width: width, height: height) else { return nil }
        return .init(category: category(for: f), visionLabel: "şekil", confidence: 0.5)
    }

    /// Connected pieces (4-neighbour) on a downsampled grid, counting those over 8% of the garment.
    static func pieces(mask: [Float], width: Int, height: Int) -> Int {
        let s = max(1, max(width, height) / 160)
        let gw = width / s, gh = height / s
        var grid = [Bool](repeating: false, count: gw * gh)
        for gy in 0 ..< gh { for gx in 0 ..< gw { grid[gy * gw + gx] = mask[(gy * s) * width + gx * s] > 0.5 } }
        let total = grid.filter { $0 }.count
        guard total > 0 else { return 0 }
        var seen = [Bool](repeating: false, count: grid.count)
        var big = 0
        for start in grid.indices where grid[start] && !seen[start] {
            var stack = [start], size = 0
            seen[start] = true
            while let i = stack.popLast() {
                size += 1
                let x = i % gw, y = i / gw
                for (nx, ny) in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)] where nx >= 0 && ny >= 0 && nx < gw && ny < gh {
                    let j = ny * gw + nx
                    if grid[j], !seen[j] { seen[j] = true; stack.append(j) }
                }
            }
            if Double(size) > 0.08 * Double(total) { big += 1 }
        }
        return big
    }
}
