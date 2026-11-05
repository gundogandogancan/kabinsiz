import CoreGraphics
import Foundation
import ProductCapture
import Vision

/// The body joints the self-model reads. Apple Vision names, in image pixels (x right, y down).
public enum Joint: String, Codable, CaseIterable, Sendable {
    case nose, leftEye, rightEye, leftEar, rightEar, neck
    case leftShoulder, rightShoulder, leftElbow, rightElbow, leftWrist, rightWrist
    case leftHip, rightHip, leftKnee, rightKnee, leftAnkle, rightAnkle, root
}

/// One person's joints in one photo. Only what Vision was fairly sure of (confidence > 0.3) is kept.
public struct BodyKeypoints: Codable, Hashable, Sendable {
    public let imageWidth: Int
    public let imageHeight: Int
    public var joints: [Joint: CGPoint]

    public init(imageWidth: Int, imageHeight: Int, joints: [Joint: CGPoint]) {
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.joints = joints
    }

    public subscript(_ j: Joint) -> CGPoint? { joints[j] }

    /// Mid-point of a left/right pair, or the one side that was seen.
    public func mid(_ a: Joint, _ b: Joint) -> CGPoint? {
        switch (joints[a], joints[b]) {
        case let (p?, q?): CGPoint(x: (p.x + q.x) / 2, y: (p.y + q.y) / 2)
        case let (p?, nil), let (nil, p?): p
        default: nil
        }
    }

    /// The joints every reader needs: both shoulders and both hips.
    public var hasTorso: Bool {
        [Joint.leftShoulder, .rightShoulder, .leftHip, .rightHip].allSatisfy { joints[$0] != nil }
    }
}

/// Person-vs-background mask in image pixels, 1 = person. Same size as the photo.
public struct PersonMask: Sendable {
    public let width: Int
    public let height: Int
    public let values: [Float]

    public init(width: Int, height: Int, values: [Float]) {
        self.width = width
        self.height = height
        self.values = values
    }

    public func isPerson(_ x: Int, _ y: Int) -> Bool {
        x >= 0 && y >= 0 && x < width && y < height && values[y * width + x] > 0.5
    }

    /// The horizontal run of person pixels on row `y` that contains `x` (or the nearest one within
    /// `search` pixels). Used for widths: the run around the body's centre, so a hanging arm that does
    /// not touch the body is not counted.
    public func run(row y: Int, around x: Int, search: Int = 6) -> ClosedRange<Int>? {
        guard y >= 0, y < height else { return nil }
        var start: Int?
        for dx in 0 ... search {
            if isPerson(x - dx, y) { start = x - dx; break }
            if isPerson(x + dx, y) { start = x + dx; break }
        }
        guard let s = start else { return nil }
        var lo = s, hi = s
        while isPerson(lo - 1, y) { lo -= 1 }
        while isPerson(hi + 1, y) { hi += 1 }
        return lo ... hi
    }

    /// Number of separate person runs on a row that are at least `minWidth` wide (two legs = 2).
    public func runCount(row y: Int, minWidth: Int) -> Int {
        guard y >= 0, y < height else { return 0 }
        var count = 0, length = 0
        for x in 0 ..< width {
            if isPerson(x, y) { length += 1 } else { if length >= minWidth { count += 1 }; length = 0 }
        }
        return count + (length >= minWidth ? 1 : 0)
    }

    /// Top and bottom person rows in the column band `xs` (the head top and the soles).
    public func verticalExtent(columns xs: ClosedRange<Int>) -> ClosedRange<Int>? {
        var top: Int?, bottom: Int?
        let band = max(0, xs.lowerBound) ... min(width - 1, xs.upperBound)
        for y in 0 ..< height where band.contains(where: { isPerson($0, y) }) {
            if top == nil { top = y }
            bottom = y
        }
        guard let t = top, let b = bottom else { return nil }
        return t ... b
    }

    public var coverage: Double { values.isEmpty ? 0 : Double(values.reduce(0, +)) / Double(values.count) }
}

public enum PersonReadingError: Error, Equatable, Sendable {
    case unreadableImage
    /// Vision found nobody, or not the torso joints the readers need.
    case noPerson
    /// More than one person: the self-model never guesses which one is the user.
    case severalPeople(Int)
    /// The Vision request itself is not available here (the iOS Simulator has no body-pose model).
    case visionUnavailable
}

/// Vision body pose on the user's chosen photo. On the device and on macOS; the iOS Simulator has no
/// pose model, so the app uses a stored, labelled fixture there (`SelfModelFixture`).
public enum PoseReader {
    static let names: [(VNHumanBodyPoseObservation.JointName, Joint)] = [
        (.nose, .nose), (.leftEye, .leftEye), (.rightEye, .rightEye), (.leftEar, .leftEar), (.rightEar, .rightEar),
        (.neck, .neck), (.leftShoulder, .leftShoulder), (.rightShoulder, .rightShoulder),
        (.leftElbow, .leftElbow), (.rightElbow, .rightElbow), (.leftWrist, .leftWrist), (.rightWrist, .rightWrist),
        (.leftHip, .leftHip), (.rightHip, .rightHip), (.leftKnee, .leftKnee), (.rightKnee, .rightKnee),
        (.leftAnkle, .leftAnkle), (.rightAnkle, .rightAnkle), (.root, .root),
    ]

    public static func read(_ image: CGImage) throws -> BodyKeypoints {
        let request = VNDetectHumanBodyPoseRequest()
        do {
            try ProductLabelReader.withCPUFallback { cpu in
                if cpu { ProductLabelReader.forceCPU(request) }
                try VisionSerial.run { try VNImageRequestHandler(cgImage: image, options: [:]).perform([request]) }
            }
        } catch {
            throw PersonReadingError.visionUnavailable
        }
        let people = request.results ?? []
        guard !people.isEmpty else { throw PersonReadingError.noPerson }
        guard people.count == 1 else { throw PersonReadingError.severalPeople(people.count) }
        let points = (try? people[0].recognizedPoints(.all)) ?? [:]
        var joints: [Joint: CGPoint] = [:]
        let w = Double(image.width), h = Double(image.height)
        for (vn, joint) in names {
            if let p = points[vn], p.confidence > 0.3 {
                joints[joint] = CGPoint(x: p.location.x * w, y: (1 - p.location.y) * h)
            }
        }
        let keypoints = BodyKeypoints(imageWidth: image.width, imageHeight: image.height, joints: joints)
        guard keypoints.hasTorso else { throw PersonReadingError.noPerson }
        return keypoints
    }
}

/// Person segmentation: Vision's person mask (accurate), else the foreground-instance mask, else a plain
/// background rule. Whatever path is used is reported, never hidden.
public enum PersonMaskReader {
    public enum Method: String, Codable, Sendable {
        case personSegmentation = "PERSON_SEGMENTATION"
        case foregroundInstance = "FOREGROUND_INSTANCE"
        case plainBackground = "PLAIN_BACKGROUND"
        /// Wall and floor: each row's background is read from its own left and right edges.
        case rowBackground = "ROW_BACKGROUND"
    }

    /// With the joints, a mask that stops above the ankles is refused and the next method tried: Vision's
    /// person mask can drop light trousers in front of a light wall (measured on our fixture person-a).
    public static func read(_ image: CGImage, useVision: Bool = true, keypoints: BodyKeypoints? = nil) throws -> (PersonMask, Method) {
        guard let rgba = RGBABuffer(image) else { throw PersonReadingError.unreadableImage }
        var candidates: [() -> (PersonMask, Method)?] = []
        if useVision {
            candidates.append { (try? personSegmentation(image)).flatMap { $0 }.map { ($0, .personSegmentation) } }
            candidates.append {
                (try? GarmentPhotoAnalyzer.visionMask(image, width: rgba.width, height: rgba.height)).flatMap { $0 }
                    .map { (PersonMask(width: rgba.width, height: rgba.height, values: $0), .foregroundInstance) }
            }
        }
        candidates.append {
            GarmentPhotoAnalyzer.plainBackgroundMask(rgba).map { (PersonMask(width: rgba.width, height: rgba.height, values: $0), .plainBackground) }
        }
        candidates.append { rowBackgroundMask(rgba).map { ($0, .rowBackground) } }
        var firstUsable: (PersonMask, Method)?
        for make in candidates {
            guard let candidate = make(), candidate.0.coverage > 0.01 else { continue }
            if firstUsable == nil { firstUsable = candidate }
            if let k = keypoints, !reachesFeet(candidate.0, keypoints: k) { continue }
            return candidate
        }
        // No mask reaches the feet: keep the first one; the body reader then refuses ("not whole").
        guard let usable = firstUsable else { throw PersonReadingError.noPerson }
        return usable
    }

    /// Without Vision (the Simulator, or a device where it fails): a person in front of a wall and a
    /// floor. Each row's background is read from its own outer 8% on the left and on the right, smoothed
    /// over nearby rows, and blended across the row (light falls off from one side), so the wall-to-floor
    /// change and the light gradient are not taken for the person. A pixel is the person when it is far
    /// from that background in Lab. Nil when the edges are busy (a cluttered room).
    ///
    /// Limit, measured 2026-11-05 on our fixture person-b: light skin in front of a light wall falls under
    /// the threshold, so the legs are cut and the mask does not reach the feet; the body reader then
    /// refuses ("bütün görünmüyor") instead of measuring. A lower threshold near the skeleton was tried and
    /// rejected: it took in the figure's soft shadow on the wall and read the chest as ~150 cm.
    static func rowBackgroundMask(_ img: RGBABuffer, threshold: Double = 0.075) -> PersonMask? {
        let w = img.width, h = img.height
        let edge = max(2, w * 8 / 100)
        var left: [SIMD3<Double>] = [], right: [SIMD3<Double>] = []
        var busy = 0
        func side(_ xs: StrideTo<Int>, _ y: Int) -> (SIMD3<Double>, Double) {
            let samples = xs.map { GarmentPhotoAnalyzer.toLab(img.rgb($0, y)) }
            let m = GarmentPhotoAnalyzer.median(samples)
            return (m, samples.map { GarmentPhotoAnalyzer.distance($0, m) }.sorted()[samples.count * 9 / 10])
        }
        for y in 0 ..< h {
            let (l, sl) = side(stride(from: 0, to: edge, by: 2), y)
            let (r, sr) = side(stride(from: w - edge, to: w, by: 2), y)
            if max(sl, sr) > threshold { busy += 1 }
            left.append(l)
            right.append(r)
        }
        guard busy < h / 10 else { return nil }
        func smooth(_ xs: [SIMD3<Double>]) -> [SIMD3<Double>] {
            (0 ..< h).map { y in GarmentPhotoAnalyzer.median(Array(xs[max(0, y - 3) ... min(h - 1, y + 3)])) }
        }
        let l = smooth(left), r = smooth(right)
        var values = [Float](repeating: 0, count: w * h)
        let span = Double(w - edge) - Double(edge / 2)
        for y in 0 ..< h {
            for x in edge ..< (w - edge) {
                let t = min(1, max(0, (Double(x) - Double(edge / 2)) / span))
                let bg = l[y] + (r[y] - l[y]) * t
                let d = GarmentPhotoAnalyzer.distance(GarmentPhotoAnalyzer.toLab(img.rgb(x, y)), bg)
                if d > threshold { values[y * w + x] = 1 }
            }
        }
        let mask = PersonMask(width: w, height: h, values: values)
        return mask.coverage > 0.01 ? mask : nil
    }

    static func reachesFeet(_ mask: PersonMask, keypoints k: BodyKeypoints) -> Bool {
        let ankles = [k[.leftAnkle], k[.rightAnkle]].compactMap { $0 }
        guard !ankles.isEmpty else { return true }
        return ankles.allSatisfy { a in
            (-3 ... 3).contains { dx in mask.isPerson(Int(a.x) + dx, Int(a.y)) }
        }
    }

    static func personSegmentation(_ image: CGImage) throws -> PersonMask? {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        try ProductLabelReader.withCPUFallback { cpu in
            if cpu { ProductLabelReader.forceCPU(request) }
            try VisionSerial.run { try VNImageRequestHandler(cgImage: image, options: [:]).perform([request]) }
        }
        guard let buffer = request.results?.first?.pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        let mw = CVPixelBufferGetWidth(buffer), mh = CVPixelBufferGetHeight(buffer)
        guard let base = CVPixelBufferGetBaseAddress(buffer) else { return nil }
        let rowBytes = CVPixelBufferGetBytesPerRow(buffer)
        // The mask comes at its own resolution; sample it at the photo's pixels.
        let w = image.width, h = image.height
        var out = [Float](repeating: 0, count: w * h)
        for y in 0 ..< h {
            let my = min(mh - 1, y * mh / h)
            let row = base.advanced(by: my * rowBytes).assumingMemoryBound(to: UInt8.self)
            for x in 0 ..< w where row[min(mw - 1, x * mw / w)] > 127 { out[y * w + x] = 1 }
        }
        return PersonMask(width: w, height: h, values: out)
    }
}

/// Small pixel helpers shared by the readers.
enum Pixels {
    /// Median colour of the photo inside a square patch, skipping pixels outside the person and very
    /// dark ones (eyes, shadows) when asked.
    static func patchMedian(_ img: RGBABuffer, mask: PersonMask?, centre: CGPoint, radius: Int,
                            skipDark: Bool = false) -> SIMD3<Double>? {
        var xs: [SIMD3<Double>] = []
        let cx = Int(centre.x), cy = Int(centre.y)
        for y in (cy - radius) ... (cy + radius) where y >= 0 && y < img.height {
            for x in (cx - radius) ... (cx + radius) where x >= 0 && x < img.width {
                if let m = mask, !m.isPerson(x, y) { continue }
                let c = img.rgb(x, y)
                if skipDark, c.sum() < 0.35 { continue }
                xs.append(c)
            }
        }
        guard xs.count >= 4 else { return nil }
        return GarmentPhotoAnalyzer.median(xs)
    }

    /// Perceptual distance (CIELAB, /100 scale as the analyzer uses).
    static func labDistance(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
        GarmentPhotoAnalyzer.distance(GarmentPhotoAnalyzer.toLab(a), GarmentPhotoAnalyzer.toLab(b))
    }

    static func distance(_ a: CGPoint, _ b: CGPoint) -> Double { Double(hypot(a.x - b.x, a.y - b.y)) }

    static func lerp(_ a: CGPoint, _ b: CGPoint, _ t: Double) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}
