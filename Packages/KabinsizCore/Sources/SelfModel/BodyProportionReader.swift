import BodyGeometry
import CoreGraphics
import Foundation

/// One body value read from a photo: a centimetre estimate with an honest range. Never a measurement.
public struct BodyEstimate: Codable, Hashable, Sendable {
    public let parameter: BodyParameter
    public let centimeters: Double
    public let low: Double
    public let high: Double
    /// Plain words for the user: how it was read and why it may be off.
    public let basis: String
}

/// The body read from one front photo. The user's typed height is the only scale; without it there are no
/// centimetres, only ratios (fail closed: a photo has no ruler).
public struct BodyReading: Codable, Hashable, Sendable {
    public let heightUsedCm: Double
    /// Person height in the photo, in pixels (head top to soles).
    public let pixelHeight: Double
    public let estimates: [BodyEstimate]
    /// Shoulder width ÷ hip width and waist ÷ hip, scale-free.
    public let shoulderToHip: Double
    public let waistToHip: Double
    public let limitations: [String]

    public func estimate(_ p: BodyParameter) -> BodyEstimate? { estimates.first { $0.parameter == p } }
}

public enum BodyProportionReader {
    public enum Failure: Error, Equatable, Sendable {
        /// No typed height: the photo alone gives no centimetres.
        case heightMissing
        case heightOutOfRange
        /// Feet or head cut off: the scale would be wrong.
        case personNotWhole
        /// The arms lie against the body: the chest row runs past an elbow, so the widths would include them.
        case armsTouchBody
    }

    /// Depth ÷ breadth of the body's cross-section at each level (adult averages, used for the ellipse).
    /// This is the main source of error: a body is not an ellipse and depth is not seen from the front.
    static let depthRatio: [BodyParameter: Double] = [.chest: 0.68, .waist: 0.74, .hip: 0.72]

    public static func read(keypoints k: BodyKeypoints, mask: PersonMask, userHeightCm: Double?) throws -> BodyReading {
        guard let height = userHeightCm else { throw Failure.heightMissing }
        guard BodyParameter.height.safeRange.contains(height) else { throw Failure.heightOutOfRange }
        guard let ls = k[.leftShoulder], let rs = k[.rightShoulder], let lh = k[.leftHip], let rh = k[.rightHip] else {
            throw PersonReadingError.noPerson
        }
        let centreX = Int((ls.x + rs.x + lh.x + rh.x) / 4)
        let shoulderY = (ls.y + rs.y) / 2, hipY = (lh.y + rh.y) / 2
        let torso = Double(hipY - shoulderY)
        guard torso > 4 else { throw PersonReadingError.noPerson }

        // Scale: head top to soles in the body's own column band.
        let halfBand = Int(Pixels.distance(ls, rs) * 0.6)
        guard let extent = mask.verticalExtent(columns: (centreX - halfBand) ... (centreX + halfBand)) else {
            throw PersonReadingError.noPerson
        }
        // A whole person: the soles are below the ankles and nothing touches the photo's top or bottom edge.
        let ankleY = max(k[.leftAnkle]?.y ?? 0, k[.rightAnkle]?.y ?? 0)
        guard extent.lowerBound > 0, extent.upperBound < mask.height - 1, ankleY > 0, Double(extent.upperBound) >= Double(ankleY)
        else { throw Failure.personNotWhole }
        let pixelHeight = Double(extent.count)
        let cmPerPx = height / pixelHeight

        func width(atY y: Double) -> Double? {
            mask.run(row: Int(y), around: centreX).map { Double($0.count) * cmPerPx }
        }
        // Levels as fractions of the shoulder→hip-joint distance (Vision's hip joints sit above the widest hip).
        let shoulderLevel = Double(shoulderY) + torso * 0.04
        let chestLevel = Double(shoulderY) + torso * 0.28
        let waistLevel = Double(shoulderY) + torso * 0.72
        let hipLevel = Double(hipY) + torso * 0.10

        guard let shoulderOuter = width(atY: shoulderLevel), let chestB = width(atY: chestLevel),
              let waistB = width(atY: waistLevel), let hipB = width(atY: hipLevel)
        else { throw PersonReadingError.noPerson }
        // The chest row must end inside the elbows: past one, an arm is merged into the torso (a colour-only
        // mask with sleeves the colour of the top did this on our fixture person-b, chest read ~25% wide).
        if let le = k[.leftElbow], let re = k[.rightElbow], let run = mask.run(row: Int(chestLevel), around: centreX) {
            let inner = min(le.x, re.x), outer = max(le.x, re.x)
            guard Double(run.lowerBound) > Double(inner), Double(run.upperBound) < Double(outer) else { throw Failure.armsTouchBody }
        }

        // The run at shoulder level spans the deltoids; shoulder width (acromion to acromion) is ~88% of it.
        let shoulder = shoulderOuter * 0.88
        func circumference(_ breadth: Double, _ p: BodyParameter) -> Double {
            let a = breadth / 2, b = a * depthRatio[p]!
            return Double.pi * (3 * (a + b) - ((3 * a + b) * (a + 3 * b)).squareRoot())   // Ramanujan
        }
        let clothes = "Giysinin üstünden okundu; kalın giysi değeri büyütür."
        let estimates = [
            BodyEstimate(parameter: .height, centimeters: height, low: height, high: height, basis: "Senin yazdığın boy (ölçek)"),
            BodyEstimate(parameter: .shoulderWidth, centimeters: shoulder, low: shoulder * 0.92, high: shoulder * 1.08,
                         basis: "Fotoğraftaki omuz genişliği. \(clothes)"),
            ring(.chest, circumference(chestB, .chest), basis: "Göğüs hizasındaki genişlik, derinlik ortalamadan. \(clothes)"),
            ring(.waist, circumference(waistB, .waist), basis: "Bel hizasındaki genişlik, derinlik ortalamadan. \(clothes)"),
            ring(.hip, circumference(hipB, .hip), basis: "Kalça hizasındaki genişlik, derinlik ortalamadan. \(clothes)"),
        ]
        return BodyReading(
            heightUsedCm: height, pixelHeight: pixelHeight, estimates: estimates,
            shoulderToHip: shoulderOuter / hipB, waistToHip: waistB / hipB,
            limitations: [
                "Fotoğraftan tahmin, ölçü değil. Mezura ile ölçtüğün değer her zaman önce gelir.",
                "Çevre ölçüleri yalnız önden görünen genişlikten ve ortalama vücut derinliğinden hesaplanır (±%10).",
                "Kollar gövdeye değiyorsa genişlik büyük çıkar.",
                "Beden formu (Kadın/Erkek/Nötr) fotoğraftan çıkarılmaz; senin seçimindir.",
            ]
        )
    }

    static func ring(_ p: BodyParameter, _ cm: Double, basis: String) -> BodyEstimate {
        let r = p.safeRange
        let c = min(max(cm, r.lowerBound), r.upperBound)
        return BodyEstimate(parameter: p, centimeters: c, low: max(r.lowerBound, c * 0.9), high: min(r.upperBound, c * 1.1), basis: basis)
    }
}
