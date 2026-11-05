import CoreGraphics
import Foundation
import ProductCapture
import Vision

/// A brand's written logo as the licensed catalogue gives it. Only brands we have a right to show.
public struct BrandWordmark: Codable, Hashable, Sendable {
    public let brandID: String
    public let displayName: String
    /// Spellings printed on the garment, e.g. "ORNEK A".
    public let marks: [String]

    public init(brandID: String, displayName: String, marks: [String]) {
        self.brandID = brandID
        self.displayName = displayName
        self.marks = marks
    }
}

public struct BrandMarkReading: Codable, Hashable, Sendable {
    public let brandID: String
    public let displayName: String
    /// What Vision read, after folding case and accents.
    public let readText: String
    /// 0 = exact, 1 = one letter off (long marks only).
    public let editDistance: Int
    public let basis: String
}

/// Written-logo reading on the garment regions. Graphic logos (a symbol without letters) are not read:
/// that needs a licensed, trained logo model we do not have (UNKNOWN, V37-02). Text that matches no brand
/// is dropped at once: a T-shirt slogan or a name tag is the user's, not ours.
public enum BrandMarkReader {
    public static func read(_ image: CGImage, regions: [CGRect], brands: [BrandWordmark]) -> [BrandMarkReading] {
        guard !brands.isEmpty, !regions.isEmpty else { return [] }
        var lines: [String] = []
        let w = Double(image.width), h = Double(image.height)
        for rect in regions {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            // Vision's region of interest is normalised with the origin at the bottom left.
            let roi = CGRect(x: rect.minX / w, y: 1 - rect.maxY / h, width: rect.width / w, height: rect.height / h)
                .intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
            guard !roi.isNull, roi.width > 0.01, roi.height > 0.01 else { continue }
            request.regionOfInterest = roi
            let ok = (try? ProductLabelReader.withCPUFallback { (cpu: Bool) throws -> Bool in
                if cpu { ProductLabelReader.forceCPU(request) }
                try VisionSerial.run { try VNImageRequestHandler(cgImage: image, options: [:]).perform([request]) }
                return true
            }) != nil
            guard ok else { continue }
            for obs in request.results ?? [] {
                if let top = obs.topCandidates(1).first, top.confidence >= 0.3 { lines.append(top.string) }
            }
        }
        return match(lines: lines, brands: brands)
    }

    /// Pure matching, testable without Vision.
    public static func match(lines: [String], brands: [BrandWordmark]) -> [BrandMarkReading] {
        var found: [String: BrandMarkReading] = [:]
        for line in lines {
            let text = fold(line)
            guard !text.isEmpty else { continue }
            // Each brand's closest mark for this line.
            var perBrand: [(brand: BrandWordmark, d: Int)] = []
            for brand in brands {
                let ds = brand.marks.map(fold).filter { !$0.isEmpty }.compactMap { mark -> Int? in
                    text.contains(mark) ? 0 : (mark.count >= 5 ? bestDistance(text, mark) : nil)
                }
                if let d = ds.min(), d <= 1 { perBrand.append((brand, d)) }
            }
            // Only the closest brands count. "ORNEK A" is exact for A and one letter off B: B is not read.
            // A one-letter guess that fits two brands equally is ambiguous and dropped.
            guard let best = perBrand.map(\.d).min() else { continue }
            let winners = perBrand.filter { $0.d == best }
            if best > 0, winners.count > 1 { continue }
            for (brand, d) in winners {
                if let old = found[brand.brandID], old.editDistance <= d { continue }
                found[brand.brandID] = BrandMarkReading(
                    brandID: brand.brandID, displayName: brand.displayName, readText: text, editDistance: d,
                    basis: d == 0 ? "Giysideki yazı katalogdaki marka yazısıyla aynı" : "Giysideki yazı bir harf farkla katalogdaki marka yazısı"
                )
            }
        }
        return found.values.sorted { $0.brandID < $1.brandID }
    }

    /// Upper case, Turkish and Latin accents folded, only letters, digits and single spaces.
    static func fold(_ s: String) -> String {
        let folded = s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "tr_TR"))
            .replacingOccurrences(of: "ı", with: "i").uppercased()
        let kept = folded.map { $0.isLetter || $0.isNumber ? $0 : " " }
        return String(kept).split(separator: " ").joined(separator: " ")
    }

    /// Smallest edit distance between the mark and any same-length window of the text.
    static func bestDistance(_ text: String, _ mark: String) -> Int {
        let t = Array(text), m = Array(mark)
        guard t.count >= m.count - 1 else { return Int.max }
        var best = Int.max
        for len in max(1, m.count - 1) ... (m.count + 1) where len <= t.count {
            for start in 0 ... (t.count - len) {
                best = min(best, levenshtein(Array(t[start ..< start + len]), m))
                if best == 0 { return 0 }
            }
        }
        return best
    }

    static func levenshtein(_ a: [Character], _ b: [Character]) -> Int {
        var prev = Array(0 ... b.count)
        for i in 1 ... max(1, a.count) where !a.isEmpty {
            var cur = [i] + [Int](repeating: 0, count: b.count)
            for j in 1 ... max(1, b.count) where !b.isEmpty {
                cur[j] = min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1))
            }
            prev = cur
        }
        return a.isEmpty ? b.count : prev[b.count]
    }
}
