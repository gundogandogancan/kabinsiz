import CoreGraphics
import DomainContracts
import Foundation
import ProductCapture

/// What the person is wearing, read region by region from the joints: torso, legs, feet.
public struct WornGarment: Codable, Hashable, Sendable {
    public enum Slot: String, Codable, Sendable { case top = "TOP", bottom = "BOTTOM", shoes = "SHOES" }

    public let slot: Slot
    public let category: GarmentCategory
    /// The app's garment form (tools/garments FORMS): tee, longSleeveTee, trousers, shorts, skirt, sneakers …
    public let form: String
    public let colourName: String
    public let colourRGB: SIMD3<Double>
    /// The region in image pixels the colour came from (and the cut-out, for the wardrobe card).
    public let region: CGRect
    /// Plain words: how the kind was decided.
    public let basis: String
    /// The garment's colour is too close to the skin to tell sleeve or leg length: the user picks.
    public let needsUserChoice: Bool
}

public struct WornGarmentReading: Codable, Hashable, Sendable {
    public let garments: [WornGarment]
    public let limitations: [String]

    public func garment(_ slot: WornGarment.Slot) -> WornGarment? { garments.first { $0.slot == slot } }
}

public enum WornGarmentReader {
    public static func read(_ image: CGImage, keypoints k: BodyKeypoints, mask: PersonMask, skin: SIMD3<Double>) throws -> WornGarmentReading {
        guard let img = RGBABuffer(image) else { throw PersonReadingError.unreadableImage }
        guard let ls = k[.leftShoulder], let rs = k[.rightShoulder], let lh = k[.leftHip], let rh = k[.rightHip] else {
            throw PersonReadingError.noPerson
        }
        let shoulderY = Double(ls.y + rs.y) / 2, hipY = Double(lh.y + rh.y) / 2, torso = hipY - shoulderY
        let r = max(2, Int(Pixels.distance(ls, rs) * 0.05))
        // Region pixels: only clear skin is dropped. Arm and shin patches are judged by which they are nearer,
        // skin or the garment's own colour, so beige trousers on light skin are not read as bare legs.
        func isSkin(_ c: SIMD3<Double>) -> Bool { Pixels.labDistance(c, skin) < 0.06 }
        func bare(_ c: SIMD3<Double>, versus garment: SIMD3<Double>) -> Bool {
            Pixels.labDistance(c, skin) < Pixels.labDistance(c, garment) && Pixels.labDistance(c, skin) < 0.14
        }
        func patch(_ a: CGPoint?, _ b: CGPoint?, _ t: Double) -> SIMD3<Double>? {
            guard let a, let b else { return nil }
            return Pixels.patchMedian(img, mask: mask, centre: Pixels.lerp(a, b, t), radius: r)
        }
        var garments: [WornGarment] = []
        var notes: [String] = []

        // Top: the torso between the shoulder line and the hips, inside the shoulders, skin excluded.
        let inset = abs(Double(rs.x - ls.x)) * 0.18
        let topRect = CGRect(x: Double(min(ls.x, rs.x)) + inset, y: shoulderY + torso * 0.12,
                             width: max(1, abs(Double(rs.x - ls.x)) - 2 * inset), height: torso * 0.8)
        if let top = regionColour(img, mask: mask, rect: topRect, exclude: isSkin) {
            let upperArm = [patch(k[.leftShoulder], k[.leftElbow], 0.55), patch(k[.rightShoulder], k[.rightElbow], 0.55)].compactMap { $0 }
            let forearm = [patch(k[.leftElbow], k[.leftWrist], 0.5), patch(k[.rightElbow], k[.rightWrist], 0.5)].compactMap { $0 }
            let (form, basis): (String, String)
            if !upperArm.isEmpty, upperArm.allSatisfy({ bare($0, versus: top) }) {
                (form, basis) = ("tank", "Kollar açık: kolsuz üst")
            } else if !forearm.isEmpty, forearm.allSatisfy({ bare($0, versus: top) }) {
                (form, basis) = ("tee", "Ön kol açık: kısa kollu üst")
            } else if forearm.isEmpty {
                (form, basis) = ("tee", "Kollar görünmedi: üst (kol boyu bilinmiyor)")
            } else {
                (form, basis) = ("longSleeveTee", "Ön kol kapalı: uzun kollu üst")
            }
            let close = Pixels.labDistance(top, skin) < 0.08
            garments.append(WornGarment(slot: .top, category: .top, form: form, colourName: GarmentPhotoAnalyzer.colourName(top).name,
                                        colourRGB: top, region: topRect,
                                        basis: close ? "Rengi tene çok yakın: kol boyunu sen seç" : basis, needsUserChoice: close))
        } else {
            notes.append("Üst giysi bölgesi okunamadı.")
        }

        // Bottom: hips to ankles. Shins decide trousers vs shorts/skirt; separate legs at mid-thigh decide shorts vs skirt.
        if let knee = k.mid(.leftKnee, .rightKnee) {
            let bottomRect = CGRect(x: Double(min(lh.x, rh.x)) - inset, y: hipY + torso * 0.12,
                                    width: abs(Double(rh.x - lh.x)) + 2 * inset, height: Double(knee.y) - hipY - torso * 0.12)
            if let bottom = regionColour(img, mask: mask, rect: bottomRect, exclude: isSkin) {
                let shins = [patch(k[.leftKnee], k[.leftAnkle], 0.5), patch(k[.rightKnee], k[.rightAnkle], 0.5)].compactMap { $0 }
                let thighY = Int(hipY + (Double(knee.y) - hipY) * 0.6)
                let legsApart = mask.runCount(row: thighY, minWidth: max(3, r)) >= 2
                let (category, form, basis): (GarmentCategory, String, String)
                if !shins.isEmpty, shins.allSatisfy({ bare($0, versus: bottom) }) {
                    (category, form, basis) = legsApart ? (.bottom, "shorts", "Baldır açık, bacaklar ayrı: şort")
                                                        : (.bottom, "skirt", "Baldır açık, bacaklar tek parça: etek")
                } else if let top = garments.first, Pixels.labDistance(top.colourRGB, bottom) < 0.06, !legsApart {
                    (category, form, basis) = (.dress, "dress", "Üst ve alt aynı renk, bacaklar tek parça: elbise")
                } else {
                    (category, form, basis) = (.bottom, "trousers", "Baldır kapalı: uzun pantolon")
                }
                let close = Pixels.labDistance(bottom, skin) < 0.08
                garments.append(WornGarment(slot: .bottom, category: category, form: form,
                                            colourName: GarmentPhotoAnalyzer.colourName(bottom).name, colourRGB: bottom,
                                            region: bottomRect,
                                            basis: close ? "Rengi tene çok yakın: boyunu sen seç" : basis, needsUserChoice: close))
            } else {
                notes.append("Alt giysi bölgesi okunamadı.")
            }
        } else {
            notes.append("Dizler görünmedi: alt giysi okunmadı.")
        }

        // Shoes: between each ankle and the sole (the lowest person row in that column).
        let feet = [k[.leftAnkle], k[.rightAnkle]].compactMap { $0 }.compactMap { a -> SIMD3<Double>? in
            var sole = Int(a.y)
            while mask.isPerson(Int(a.x), sole + 1) { sole += 1 }
            let y = Double(a.y) + Double(sole - Int(a.y)) * 0.6
            return Pixels.patchMedian(img, mask: mask, centre: CGPoint(x: a.x, y: y), radius: max(1, min(r, (sole - Int(a.y)) / 3)))
        }
        if !feet.isEmpty {
            let shoe = GarmentPhotoAnalyzer.median(feet + feet)
            if Pixels.labDistance(shoe, skin) < 0.06 {
                notes.append("Ayakkabı görünmedi.")
            } else if let a = k.mid(.leftAnkle, .rightAnkle) {
                garments.append(WornGarment(slot: .shoes, category: .shoes, form: "sneakers",
                                            colourName: GarmentPhotoAnalyzer.colourName(shoe).name, colourRGB: shoe,
                                            region: CGRect(x: Double(a.x) - torso * 0.4, y: Double(a.y), width: torso * 0.8, height: torso * 0.2),
                                            basis: "Ayak bileğinin altı; ayakkabı türü fotoğraftan seçilmez", needsUserChoice: true))
            }
        }
        return WornGarmentReading(garments: garments, limitations: notes + [
            "Renk fotoğrafın pikselinden; ışık rengi değiştirebilir.",
            "Tür kuraldan (kol, baldır, bacak ayrımı); kaydetmeden önce sen onaylarsın.",
        ])
    }

    /// Dominant colour of the person's pixels in a rectangle, skipping skin.
    static func regionColour(_ img: RGBABuffer, mask: PersonMask, rect: CGRect, exclude: (SIMD3<Double>) -> Bool) -> SIMD3<Double>? {
        var m = [Float](repeating: 0, count: img.width * img.height)
        var n = 0
        let x0 = max(0, Int(rect.minX)), x1 = min(img.width - 1, Int(rect.maxX))
        let y0 = max(0, Int(rect.minY)), y1 = min(img.height - 1, Int(rect.maxY))
        guard x0 < x1, y0 < y1 else { return nil }
        for y in y0 ... y1 {
            for x in x0 ... x1 where mask.isPerson(x, y) && !exclude(img.rgb(x, y)) {
                m[y * img.width + x] = 1
                n += 1
            }
        }
        guard n >= 12 else { return nil }
        return GarmentPhotoAnalyzer.dominantColour(img, mask: m)
    }
}
