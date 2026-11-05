import CoreGraphics
import Foundation
import ImageIO
import ProductCapture
import UniformTypeIdentifiers

/// How long the hair reads in a front photo. A class, not a measurement.
public enum HairLength: String, Codable, CaseIterable, Sendable {
    /// No hair colour above the face (bald, shaved, or a hat).
    case notVisible = "NOT_VISIBLE"
    case short = "SHORT"
    /// Hair beside the face below the eyes, not reaching the shoulders.
    case medium = "MEDIUM"
    /// Hair beside the neck down to the shoulders.
    case long = "LONG"

    public var displayName: String {
        switch self {
        case .notVisible: "Görünmüyor"
        case .short: "Kısa"
        case .medium: "Orta"
        case .long: "Uzun"
        }
    }
}

/// What the model may borrow from the user's face photo to look like them. Deliberately not an identity:
/// no landmarks, no embedding, nothing that could recognise the person in another photo is kept.
public struct FaceAppearance: Codable, Hashable, Sendable {
    /// Median skin colour of the cheeks, sRGB 0…1.
    public let skinRGB: SIMD3<Double>
    /// Our own 1 (lightest) … 10 (darkest) scale from CIELAB lightness, for words on screen only.
    public let skinToneStep: Int
    public let hairRGB: SIMD3<Double>?
    public let hairColourName: String?
    public let hairLength: HairLength
    /// Head height ÷ head width in the photo (with hair). Shapes the 3D head a little.
    public let headAspect: Double
    /// Where the face crop was taken, in image pixels. Used only to build the texture, then dropped.
    public let faceBox: CGRect
    public let limitations: [String]
}

public enum AppearanceReader {
    /// Reads skin, hair and head shape from the user's own photo. Needs the nose and the shoulders.
    public static func read(_ image: CGImage, keypoints k: BodyKeypoints, mask: PersonMask) throws -> FaceAppearance {
        guard let img = RGBABuffer(image) else { throw PersonReadingError.unreadableImage }
        guard let nose = k[.nose], let shoulders = k.mid(.leftShoulder, .rightShoulder) else { throw PersonReadingError.noPerson }
        var notes: [String] = []
        let neckY = Double(k[.neck]?.y ?? shoulders.y)
        let noseX = Int(nose.x), noseY = Int(nose.y)
        // Head width: the person run through the nose row (face with hair and ears).
        guard let headRun = mask.run(row: noseY, around: noseX) else { throw PersonReadingError.noPerson }
        let headW = Double(headRun.count)
        let band = (noseX - Int(headW * 0.25)) ... (noseX + Int(headW * 0.25))
        guard let extent = mask.verticalExtent(columns: band) else { throw PersonReadingError.noPerson }
        let top = Double(extent.lowerBound)
        // Chin: the first row below the nose where the silhouette narrows to the neck (< 72% of the head).
        // Long hair keeps the silhouette wide, so the joint-based guess caps it.
        var chin = min(Double(noseY) + (Double(noseY) - top) * 1.6, neckY - 2)
        for y in noseY ..< Int(neckY) {
            if let run = mask.run(row: y, around: noseX), Double(run.count) < headW * 0.72 { chin = Double(y); break }
        }
        let headH = max(chin - top, 1)
        let faceBox = CGRect(x: Double(headRun.lowerBound), y: top, width: headW, height: headH)

        // Skin: both cheeks, just below the nose line and inside the face, skipping dark pixels (eyes, nostrils).
        let r = max(2, Int(headW * 0.06))
        let cheeks = [-1.0, 1.0].compactMap { side in
            Pixels.patchMedian(img, mask: mask, centre: CGPoint(x: Double(noseX) + side * headW * 0.2, y: Double(noseY) + headH * 0.06),
                               radius: r, skipDark: true)
        }
        var skin: SIMD3<Double>
        if !cheeks.isEmpty {
            skin = GarmentPhotoAnalyzer.median(cheeks + cheeks)
        } else if let w = k[.leftWrist] ?? k[.rightWrist], let hand = Pixels.patchMedian(img, mask: mask, centre: w, radius: r) {
            skin = hand
            notes.append("Ten rengi yüzden değil, elden okundu.")
        } else {
            throw PersonReadingError.noPerson
        }
        skin = SIMD3(min(max(skin.x, 0), 1), min(max(skin.y, 0), 1), min(max(skin.z, 0), 1))

        // Hair: the top of the head, inside the person, away from the silhouette's soft edge.
        var hairPixels: [SIMD3<Double>] = []
        let inner = Int(headW * 0.18)
        for y in (Int(top) + 3) ... max(Int(top) + 3, Int(top + headH * 0.2)) {
            for x in (headRun.lowerBound + inner) ... max(headRun.lowerBound + inner, headRun.upperBound - inner) where mask.isPerson(x, y) {
                hairPixels.append(img.rgb(x, y))
            }
        }
        var hair: SIMD3<Double>? = hairPixels.count >= 8 ? GarmentPhotoAnalyzer.median(hairPixels) : nil
        // Blond hair on light skin differs mostly in yellow (b*), so the bar is low; a bald head matches skin.
        if let h = hair, Pixels.labDistance(h, skin) < 0.04 { hair = nil }
        let length: HairLength = hair.map { lengthClass(img, mask: mask, hair: $0, skin: skin, noseX: noseX, chin: chin,
                                                         eyesY: Double(noseY) - headH * 0.1, shoulderY: Double(shoulders.y),
                                                         headW: headW) } ?? .notVisible
        if hair == nil { notes.append("Saç rengi görünmedi (kısa saç, şapka ya da ışık).") }

        return FaceAppearance(
            skinRGB: skin, skinToneStep: toneStep(skin), hairRGB: hair,
            hairColourName: hair.map(hairName), hairLength: length, headAspect: headH / headW,
            faceBox: faceBox, limitations: notes + ["Görünüş okuması, kimlik değil: yüz şablonu üretilmez ve saklanmaz."]
        )
    }

    /// Rows from the eyes to the shoulders: how far down hair colour shows beside the face and neck.
    static func lengthClass(_ img: RGBABuffer, mask: PersonMask, hair: SIMD3<Double>, skin: SIMD3<Double>, noseX: Int,
                            chin: Double, eyesY: Double, shoulderY: Double, headW: Double) -> HairLength {
        // Long: below the chin the silhouette stays nearly head-wide (hair beside the neck); a bare neck is narrow.
        let neckRows = stride(from: Int(chin + (shoulderY - chin) * 0.2), to: Int(chin + (shoulderY - chin) * 0.8), by: 2)
        let wide = neckRows.filter { y in (mask.run(row: y, around: noseX)?.count).map { Double($0) >= headW * 0.8 } ?? false }.count
        if neckRows.underestimatedCount > 0, Double(wide) >= Double(Array(neckRows).count) * 0.6 { return .long }
        // Medium: hair colour on both sides of the face between the eyes and the chin.
        func sideHair(_ y: Int) -> Bool {
            guard let run = mask.run(row: y, around: noseX) else { return false }
            let edge = max(2, Int(Double(run.count) * 0.15))
            func isHair(_ x: Int) -> Bool { Pixels.labDistance(img.rgb(x, y), hair) < 0.08 && Pixels.labDistance(img.rgb(x, y), skin) > 0.06 }
            let left = (run.lowerBound ..< run.lowerBound + edge).contains(where: isHair)
            let right = (run.upperBound - edge + 1 ... run.upperBound).contains(where: isHair)
            return left && right
        }
        let faceRows = Array(stride(from: Int(eyesY), to: Int(chin), by: 2))
        return !faceRows.isEmpty && Double(faceRows.filter(sideHair).count) >= Double(faceRows.count) * 0.5 ? .medium : .short
    }

    static func toneStep(_ rgb: SIMD3<Double>) -> Int {
        let lightness = GarmentPhotoAnalyzer.toLab(rgb).x * 100   // L* 0…100
        // L* ≈ 80 → 1 … L* ≈ 25 → 10, evenly.
        return min(10, max(1, Int(((80 - lightness) / 5.5).rounded()) + 1))
    }

    static func hairName(_ rgb: SIMD3<Double>) -> String {
        let palette: [(String, SIMD3<Double>)] = [
            ("siyah", SIMD3(0.06, 0.05, 0.05)), ("koyu kahve", SIMD3(0.22, 0.14, 0.09)),
            ("kahverengi", SIMD3(0.40, 0.26, 0.15)), ("kumral", SIMD3(0.55, 0.40, 0.25)),
            ("sarı", SIMD3(0.85, 0.70, 0.40)), ("açık sarı", SIMD3(0.84, 0.77, 0.62)),
            ("koyu gri", SIMD3(0.36, 0.34, 0.33)), ("kızıl", SIMD3(0.62, 0.25, 0.10)),
            ("gri", SIMD3(0.60, 0.60, 0.60)), ("beyaz", SIMD3(0.90, 0.90, 0.88)),
        ]
        return palette.min { Pixels.labDistance($0.1, rgb) < Pixels.labDistance($1.1, rgb) }!.0
    }
}

/// The face texture for the 3D head: the photo's own pixels in a soft oval, square, so it can be laid
/// on the front of the head. Nothing is drawn, smoothed or beautified. Kept only in the Vault.
public enum FaceTexture {
    /// `matte`: blend the oval's edge into this colour and return an opaque square (the head's skin), so the
    /// renderer needs no transparency and the seam disappears. `nil` keeps a transparent edge.
    public static func make(_ image: CGImage, appearance: FaceAppearance, size: Int = 512, matte: SIMD3<Double>? = nil) -> CGImage? {
        guard let img = RGBABuffer(image) else { return nil }
        let box = appearance.faceBox
        let side = max(box.width, box.height) * 1.08
        let origin = CGPoint(x: box.midX - side / 2, y: box.midY - side / 2)
        var out = [UInt8](repeating: 0, count: size * size * 4)
        for py in 0 ..< size {
            for px in 0 ..< size {
                // Oval with a feathered edge (last 12%), wider than tall like a face seen from the front.
                let u = (Double(px) + 0.5) / Double(size) * 2 - 1, v = (Double(py) + 0.5) / Double(size) * 2 - 1
                let d = (u * u) / (0.86 * 0.86) + (v * v) / (0.98 * 0.98)
                let i = (py * size + px) * 4
                let sx = Int(origin.x + (Double(px) + 0.5) / Double(size) * side)
                let sy = Int(origin.y + (Double(py) + 0.5) / Double(size) * side)
                let inside = d < 1 && sx >= 0 && sy >= 0 && sx < img.width && sy < img.height
                let fade = d < 0.76 ? 1.0 : max(0, (1 - d) / 0.24)
                if let m = matte {
                    let c = inside ? img.rgb(sx, sy) * fade + m * (1 - fade) : m
                    out[i] = UInt8((c.x * 255).rounded()); out[i + 1] = UInt8((c.y * 255).rounded())
                    out[i + 2] = UInt8((c.z * 255).rounded()); out[i + 3] = 255
                    continue
                }
                guard inside else { continue }
                let alpha = fade
                let c = img.rgb(sx, sy)
                out[i] = UInt8((c.x * alpha * 255).rounded())
                out[i + 1] = UInt8((c.y * alpha * 255).rounded())
                out[i + 2] = UInt8((c.z * alpha * 255).rounded())
                out[i + 3] = UInt8((alpha * 255).rounded())
            }
        }
        guard let provider = CGDataProvider(data: Data(out) as CFData) else { return nil }
        return CGImage(width: size, height: size, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: size * 4,
                       space: CGColorSpace(name: CGColorSpace.sRGB)!,
                       bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }

    public static func png(_ image: CGImage) -> Data? {
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data as CFMutableData, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, image, nil)
        return CGImageDestinationFinalize(dest) ? data as Data : nil
    }
}
