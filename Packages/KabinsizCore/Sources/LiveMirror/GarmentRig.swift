import CoreGraphics
import Foundation

// MIR-WP02: places a prepared garment drawing on the person in the camera picture.
//
// A garment is a few flat parts rendered offline in Blender (tools/garments): torso, upper and lower
// sleeve, seat, thigh, shin, shoe. Each part carries two anchors on its own axis (a = top joint,
// b = bottom joint). On every frame each part is mapped with one affine transform so that its axis
// lies on the matching bone of the detected pose. This is a drawing that follows the body, not cloth
// simulation, and never evidence of size or fit (MirrorFidelity.mayInformSizeAdvice == false).

/// The body joints the mirror uses. Names follow the person, not the screen (a mirrored picture puts
/// the left shoulder on the right of the screen).
public enum BodyJoint: String, Codable, CaseIterable, Sendable {
    case nose, neck
    case leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist
    case leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle
}

/// One detected pose in view coordinates (points, y down).
public struct BodyPose2D: Sendable, Equatable {
    public var points: [BodyJoint: CGPoint]

    public init(points: [BodyJoint: CGPoint]) { self.points = points }

    public subscript(_ joint: BodyJoint) -> CGPoint? { points[joint] }
}

// MARK: - Manifest (garments.json)

public struct GarmentPartSpec: Codable, Hashable, Sendable {
    /// Pixel size of the part image.
    public let size: [Double]
    /// Axis anchors in image pixels (y down): `a` is the upper joint, `b` the lower one.
    public let a: [Double]
    public let b: [Double]
    /// Shoulder (torso) or hip (seat) distance in image pixels, for the width scale.
    public let refWidth: Double?
    /// "fabric" (tinted to the product colour) and optionally "fixed" (trims, never tinted).
    public let files: [String: String]

    public init(size: [Double], a: [Double], b: [Double], refWidth: Double?, files: [String: String]) {
        self.size = size
        self.a = a
        self.b = b
        self.refWidth = refWidth
        self.files = files
    }

    var anchorA: CGPoint { CGPoint(x: a[0], y: a[1]) }
    var anchorB: CGPoint { CGPoint(x: b[0], y: b[1]) }
}

public struct GarmentThumbSpec: Codable, Hashable, Sendable {
    public let size: [Double]
    public let files: [String: String]
}

public struct GarmentFormSpec: Codable, Hashable, Sendable {
    public let form: String
    /// "top", "bottom" or "shoe".
    public let family: String
    public let pxPerMetre: Double
    public let parts: [String: GarmentPartSpec]
    public let thumb: GarmentThumbSpec?

    public init(form: String, family: String, pxPerMetre: Double, parts: [String: GarmentPartSpec], thumb: GarmentThumbSpec?) {
        self.form = form
        self.family = family
        self.pxPerMetre = pxPerMetre
        self.parts = parts
        self.thumb = thumb
    }
}

public struct GarmentSpriteManifest: Codable, Hashable, Sendable {
    /// Always OWNED_ORIGINAL: every drawing is made from primitives in our own script.
    public let provenance: String
    public let forms: [String: GarmentFormSpec]

    public static func decode(_ data: Data) throws -> GarmentSpriteManifest {
        let manifest = try JSONDecoder().decode(GarmentSpriteManifest.self, from: data)
        guard manifest.provenance == "OWNED_ORIGINAL" else { throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "provenance")) }
        return manifest
    }
}

// MARK: - Placement

public struct PartPlacement: Sendable, Equatable {
    public enum Side: String, Sendable { case center, left, right }
    public let part: String
    public let side: Side
    /// Image pixels → view points.
    public let transform: CGAffineTransform
    /// Drawing order, low first.
    public let order: Int
}

public enum RigResult: Sendable, Equatable {
    case placed([PartPlacement])
    /// The joints this garment needs are not visible; nothing is drawn (no frozen garment, V32-MIR-06).
    case missing([BodyJoint])
}

public enum GarmentRig {
    /// Minimum along-axis scale relative to the body scale, so a limb pointing at the camera does not
    /// collapse into a sliver.
    static let minFore: CGFloat = 0.28

    public static func required(for family: String) -> [BodyJoint] {
        switch family {
        case "top": [.leftShoulder, .rightShoulder]
        case "bottom": [.leftHip, .rightHip]
        default: [.leftAnkle, .rightAnkle]
        }
    }

    public static func place(_ form: GarmentFormSpec, on pose: BodyPose2D) -> RigResult {
        let need = required(for: form.family).filter { pose[$0] == nil }
        if !need.isEmpty { return .missing(need) }
        var out: [PartPlacement] = []
        switch form.family {
        case "top":
            guard let torso = form.parts["torso"], let ls = pose[.leftShoulder], let rs = pose[.rightShoulder] else { return .missing([]) }
            let shoulders = mid(ls, rs)
            let shoulderWidth = dist(ls, rs)
            let hips: CGPoint
            if let lh = pose[.leftHip], let rh = pose[.rightHip] {
                hips = mid(lh, rh)
            } else {
                // Hips out of frame: continue the torso straight down from the shoulder line.
                let down = perpDown(ls, rs)
                hips = CGPoint(x: shoulders.x + down.x * shoulderWidth * 1.34, y: shoulders.y + down.y * shoulderWidth * 1.34)
            }
            let along = dist(shoulders, hips) / max(dist(torso.anchorA, torso.anchorB), 1)
            let across = clamp(shoulderWidth / max(torso.refWidth ?? 1, 1), along * 0.55, along * 1.6)
            let body = along
            out.append(PartPlacement(part: "torso", side: .center, transform: map(torso, shoulders, hips, along: along, across: across), order: 10))
            for (side, s, e, w) in [(PartPlacement.Side.left, BodyJoint.leftShoulder, BodyJoint.leftElbow, BodyJoint.leftWrist),
                                    (.right, .rightShoulder, .rightElbow, .rightWrist)] {
                guard let sp = pose[s], let ep = pose[e] else { continue }
                if let upper = form.parts["upperSleeve"] {
                    let l = max(dist(sp, ep) / max(dist(upper.anchorA, upper.anchorB), 1), body * minFore)
                    out.append(PartPlacement(part: "upperSleeve", side: side, transform: map(upper, sp, ep, along: l, across: body), order: 5))
                }
                if let lower = form.parts["lowerSleeve"], let wp = pose[w] {
                    let l = max(dist(ep, wp) / max(dist(lower.anchorA, lower.anchorB), 1), body * minFore)
                    out.append(PartPlacement(part: "lowerSleeve", side: side, transform: map(lower, ep, wp, along: l, across: body), order: 20))
                }
            }
        case "bottom":
            guard let seat = form.parts["seat"], let lh = pose[.leftHip], let rh = pose[.rightHip] else { return .missing([]) }
            let hips = mid(lh, rh)
            let hipWidth = dist(lh, rh)
            // Body scale from the torso when the shoulders are visible (steadier than the hips).
            var body: CGFloat
            if let ls = pose[.leftShoulder], let rs = pose[.rightShoulder] {
                body = dist(mid(ls, rs), hips) / (0.51 * form.pxPerMetre)
            } else {
                body = hipWidth / max(seat.refWidth ?? 1, 1)
            }
            let knees: CGPoint
            if let lk = pose[.leftKnee], let rk = pose[.rightKnee] {
                knees = mid(lk, rk)
            } else {
                let down = perpDown(rh, lh)
                knees = CGPoint(x: hips.x + down.x * 0.43 * form.pxPerMetre * body, y: hips.y + down.y * 0.43 * form.pxPerMetre * body)
            }
            body = max(body, 0.0001)
            let across = clamp(hipWidth / max(seat.refWidth ?? 1, 1), body * 0.6, body * 1.6)
            out.append(PartPlacement(part: "seat", side: .center,
                                     transform: map(seat, hips, knees, along: dist(hips, knees) / max(dist(seat.anchorA, seat.anchorB), 1), across: across),
                                     order: 20))
            for (side, h, k, a) in [(PartPlacement.Side.left, BodyJoint.leftHip, BodyJoint.leftKnee, BodyJoint.leftAnkle),
                                    (.right, .rightHip, .rightKnee, .rightAnkle)] {
                guard let hp = pose[h], let kp = pose[k] else { continue }
                if let thigh = form.parts["thigh"] {
                    let l = max(dist(hp, kp) / max(dist(thigh.anchorA, thigh.anchorB), 1), body * minFore)
                    out.append(PartPlacement(part: "thigh", side: side, transform: map(thigh, hp, kp, along: l, across: body), order: 10))
                }
                if let shin = form.parts["shin"], let ap = pose[a] {
                    let l = max(dist(kp, ap) / max(dist(shin.anchorA, shin.anchorB), 1), body * minFore)
                    out.append(PartPlacement(part: "shin", side: side, transform: map(shin, kp, ap, along: l, across: body), order: 11))
                }
            }
        default:
            guard let shoe = form.parts["shoe"] else { return .missing([]) }
            for (side, k, a) in [(PartPlacement.Side.left, BodyJoint.leftKnee, BodyJoint.leftAnkle), (.right, .rightKnee, .rightAnkle)] {
                guard let ap = pose[a] else { continue }
                // Scale from the shin when visible, else from the distance between the ankles.
                let body: CGFloat
                if let kp = pose[k] {
                    body = dist(kp, ap) / (0.42 * form.pxPerMetre)
                } else if let la = pose[.leftAnkle], let ra = pose[.rightAnkle] {
                    body = max(dist(la, ra), 1) / (0.22 * form.pxPerMetre)
                } else {
                    continue
                }
                let down = CGPoint(x: 0, y: 1)
                let tip = CGPoint(x: ap.x + down.x * dist(shoe.anchorA, shoe.anchorB) * body, y: ap.y + down.y * dist(shoe.anchorA, shoe.anchorB) * body)
                out.append(PartPlacement(part: "shoe", side: side, transform: map(shoe, ap, tip, along: body, across: body), order: 5))
            }
        }
        return .placed(out.sorted { $0.order < $1.order })
    }

    /// Affine map taking the part's axis a→b onto A→B, scaling `along` the axis and `across` it.
    static func map(_ part: GarmentPartSpec, _ A: CGPoint, _ B: CGPoint, along: CGFloat, across: CGFloat) -> CGAffineTransform {
        let a = part.anchorA, b = part.anchorB
        let u = unit(CGPoint(x: b.x - a.x, y: b.y - a.y))
        let v = CGPoint(x: -u.y, y: u.x)
        var U = unit(CGPoint(x: B.x - A.x, y: B.y - A.y))
        if U == .zero { U = CGPoint(x: 0, y: 1) }
        let V = CGPoint(x: -U.y, y: U.x)
        let l00 = along * U.x * u.x + across * V.x * v.x
        let l01 = along * U.x * u.y + across * V.x * v.y
        let l10 = along * U.y * u.x + across * V.y * v.x
        let l11 = along * U.y * u.y + across * V.y * v.y
        let tx = A.x - (l00 * a.x + l01 * a.y)
        let ty = A.y - (l10 * a.x + l11 * a.y)
        return CGAffineTransform(a: l00, b: l10, c: l01, d: l11, tx: tx, ty: ty)
    }

    static func mid(_ p: CGPoint, _ q: CGPoint) -> CGPoint { CGPoint(x: (p.x + q.x) / 2, y: (p.y + q.y) / 2) }
    static func dist(_ p: CGPoint, _ q: CGPoint) -> CGFloat { hypot(p.x - q.x, p.y - q.y) }
    static func unit(_ p: CGPoint) -> CGPoint {
        let l = hypot(p.x, p.y)
        return l < 1e-6 ? .zero : CGPoint(x: p.x / l, y: p.y / l)
    }
    static func clamp(_ x: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat { min(max(x, lo), hi) }

    /// Unit vector perpendicular to the line p→q, pointing down the screen (towards the feet).
    static func perpDown(_ p: CGPoint, _ q: CGPoint) -> CGPoint {
        let u = unit(CGPoint(x: q.x - p.x, y: q.y - p.y))
        var n = CGPoint(x: -u.y, y: u.x)
        if n.y < 0 { n = CGPoint(x: -n.x, y: -n.y) }
        return n == .zero ? CGPoint(x: 0, y: 1) : n
    }
}

// MARK: - Frame and person gates

/// Drops frames that arrive out of order or too late to be drawn honestly (V32-MIR-08, LM21-T06).
public struct FrameGate: Sendable {
    public let maxAge: TimeInterval
    private var lastSequence: UInt64?
    public private(set) var dropped = 0

    public init(maxAge: TimeInterval = 0.25) { self.maxAge = maxAge }

    public mutating func admit(sequence: UInt64, capturedAt: TimeInterval, now: TimeInterval) -> Bool {
        if let last = lastSequence, sequence <= last { dropped += 1; return false }
        if now - capturedAt > maxAge || capturedAt > now + 0.05 { dropped += 1; lastSequence = sequence; return false }
        lastSequence = sequence
        return true
    }
}

/// What the mirror may draw on this frame, decided before any garment is placed.
public enum MirrorTracking: Equatable, Sendable {
    case tracking(BodyPose2D)
    case noPerson
    /// More than one person: the garment is not attached to anyone at random (V32-MIR-04).
    case severalPeople(Int)
    /// A person, but the joints this garment needs are hidden (V32-MIR-03/06).
    case partial([BodyJoint])

    public static func decide(people: [BodyPose2D], family: String) -> MirrorTracking {
        let real = people.filter { $0.points.count >= 4 }
        if real.isEmpty { return .noPerson }
        if real.count > 1 { return .severalPeople(real.count) }
        let missing = GarmentRig.required(for: family).filter { real[0][$0] == nil }
        return missing.isEmpty ? .tracking(real[0]) : .partial(missing)
    }

    /// Short Turkish note for the screen; nil while tracking.
    public var note: String? {
        switch self {
        case .tracking: nil
        case .noPerson: "Kadrajda kimse görünmüyor. Telefonu karşına koyup biraz geri çekil."
        case .severalPeople: "Kadrajda birden fazla kişi var. Giysiyi kime koyacağımızı tahmin etmiyoruz."
        case .partial(let joints):
            if joints.contains(.leftShoulder) || joints.contains(.rightShoulder) { "Omuzların görünmüyor; biraz geri çekil." }
            else if joints.contains(.leftHip) || joints.contains(.rightHip) { "Belin görünmüyor; biraz geri çekil." }
            else { "Ayakların görünmüyor; telefonu biraz aşağı indir." }
        }
    }
}

// MARK: - Smoothing and light

/// One Euro filter (Casiez et al. 2012): smooth when still, responsive when moving. Per coordinate.
public struct OneEuroFilter: Sendable {
    public var minCutoff: Double
    public var beta: Double
    public var derivativeCutoff: Double
    private var x: Double?
    private var dx: Double = 0
    private var t: TimeInterval?

    public init(minCutoff: Double = 1.2, beta: Double = 0.02, derivativeCutoff: Double = 1.0) {
        self.minCutoff = minCutoff
        self.beta = beta
        self.derivativeCutoff = derivativeCutoff
    }

    static func alpha(_ cutoff: Double, _ dt: Double) -> Double {
        let tau = 1 / (2 * Double.pi * cutoff)
        return 1 / (1 + tau / dt)
    }

    public mutating func callAsFunction(_ value: Double, at time: TimeInterval) -> Double {
        guard let px = x, let pt = t, time > pt else { x = value; t = time; return value }
        let dt = time - pt
        let rawD = (value - px) / dt
        let ad = Self.alpha(derivativeCutoff, dt)
        dx = ad * rawD + (1 - ad) * dx
        let cutoff = minCutoff + beta * abs(dx)
        let a = Self.alpha(cutoff, dt)
        let out = a * value + (1 - a) * px
        x = out
        t = time
        return out
    }

    public mutating func reset() { x = nil; t = nil; dx = 0 }
}

/// Smooths a whole pose joint by joint; a joint that disappears is dropped at once (no ghost limb).
public struct PoseSmoother: Sendable {
    private var filters: [BodyJoint: (OneEuroFilter, OneEuroFilter)] = [:]

    public init() {}

    public mutating func smooth(_ pose: BodyPose2D, at time: TimeInterval) -> BodyPose2D {
        var out: [BodyJoint: CGPoint] = [:]
        for (joint, p) in pose.points {
            var pair = filters[joint] ?? (OneEuroFilter(), OneEuroFilter())
            out[joint] = CGPoint(x: pair.0(Double(p.x), at: time), y: pair.1(Double(p.y), at: time))
            filters[joint] = pair
        }
        for joint in filters.keys where pose.points[joint] == nil { filters[joint] = nil }
        return BodyPose2D(points: out)
    }

    public mutating func reset() { filters.removeAll() }
}

/// Matches the drawing's brightness to the room: a dark room dims the garment, a bright one lifts it.
public enum FrameLight {
    /// `meanLuma` 0…1 of the camera picture → multiplier for the garment colour.
    public static func gain(meanLuma: Double) -> Double {
        guard meanLuma.isFinite else { return 1 }
        return min(max(0.55 + meanLuma * 0.85, 0.62), 1.08)
    }
}
