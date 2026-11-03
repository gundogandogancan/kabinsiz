import Foundation
import ShoppingCopilot

/// Where a code on the label came from.
public enum CodeSource: Hashable, Sendable {
    /// A machine-read barcode or 2D code; `symbology` is the Vision name (e.g. `EAN13`, `Code128`).
    case barcode(symbology: String)
    /// Text read from the label (on-device OCR).
    case labelText
}

/// One code found on the photo, already normalised.
public struct ReadCode: Hashable, Sendable {
    public enum Kind: String, Hashable, Sendable {
        /// A shop's own variant or model code, e.g. `KB-JKT-01-NVY`.
        case productCode = "PRODUCT_CODE"
        /// A GTIN (EAN-8/UPC-A/EAN-13/GTIN-14) with a valid check digit.
        case gtin = "GTIN"
    }

    public let value: String
    public let kind: Kind
    public let source: CodeSource

    public init(value: String, kind: Kind, source: CodeSource) {
        self.value = value
        self.kind = kind
        self.source = source
    }
}

/// What Vision saw on a photo: barcode payloads and text lines. Pixels never leave the reader.
public struct ProductLabelReading: Hashable, Sendable {
    public struct Barcode: Hashable, Sendable {
        public let payload: String
        public let symbology: String
        public init(payload: String, symbology: String) {
            self.payload = payload
            self.symbology = symbology
        }
    }

    /// A detector that could not run on this device; what it would have read is missing, not absent.
    public enum Part: String, Hashable, Sendable { case barcodes = "BARCODES", text = "TEXT" }

    public var barcodes: [Barcode]
    public var textLines: [String]
    public var unreadParts: [Part]

    public init(barcodes: [Barcode] = [], textLines: [String] = [], unreadParts: [Part] = []) {
        self.barcodes = barcodes
        self.textLines = textLines
        self.unreadParts = unreadParts
    }
}

/// The answer for a product photo. Never a "similar" product (T-V13-003): a code that is not in the
/// catalogue stays not found, and several real candidates are put to the user, not guessed.
public enum ProductPhotoMatch: Hashable, Sendable {
    case found(CatalogProduct, via: CodeSource)
    /// Several catalogue products were read, or a model code fits several variants: the user picks.
    case choose([CatalogProduct])
    /// Codes were read but none is in the catalogue (e.g. a shop's real EAN with no catalogue connected).
    case notInCatalog([ReadCode])
    /// No barcode and no product code could be read.
    case nothingRead
}

public struct ProductPhotoResult: Hashable, Sendable {
    public let match: ProductPhotoMatch
    /// Every code read, in the order it was trusted (barcodes before label text).
    public let codes: [ReadCode]
    /// Barcode payloads refused as input (links, phone numbers, scripts): counted, never opened (V15-T-SEC-05).
    public let refusedPayloads: Int
    /// Detectors that could not run; "nothing read" then means "not fully looked at".
    public let unreadParts: [ProductLabelReading.Part]
}

/// Turns a reading into catalogue codes and a match. Pure and deterministic: no I/O, no network.
public enum ProductCodeMatcher {
    /// Variant/model codes: two or more letter-digit segments joined by hyphens (`KB-TEE-01-WHT`).
    static let codeSegments = 2...6

    public static func match(_ reading: ProductLabelReading, resolver: ProductResolver) -> ProductPhotoResult {
        let (codes, refused) = extract(reading)
        var found: [(CatalogProduct, CodeSource)] = []
        var ambiguous: [CatalogProduct] = []
        for code in codes where code.kind == .productCode {
            candidates: for candidate in [code.value] + ocrRepairs(code.value, source: code.source) {
                switch resolver.resolve(candidate) {
                case let .found(product):
                    if !found.contains(where: { $0.0 == product }) { found.append((product, code.source)) }
                    break candidates
                case let .ambiguous(options):
                    for option in options where !ambiguous.contains(option) { ambiguous.append(option) }
                    break candidates
                case .notFound, .invalidInput:
                    continue candidates
                }
            }
        }
        let match: ProductPhotoMatch
        let distinct = found.map(\.0)
        if distinct.count == 1, ambiguous.allSatisfy({ $0 == distinct[0] || $0.modelCode == distinct[0].modelCode }) {
            match = .found(distinct[0], via: found[0].1)
        } else if !distinct.isEmpty || !ambiguous.isEmpty {
            var options = distinct
            for option in ambiguous where !options.contains(option) { options.append(option) }
            match = .choose(options)
        } else if !codes.isEmpty {
            match = .notInCatalog(codes)
        } else {
            match = .nothingRead
        }
        return ProductPhotoResult(match: match, codes: codes, refusedPayloads: refused, unreadParts: reading.unreadParts)
    }

    /// Normalised codes, barcodes first, de-duplicated by value; plus how many payloads were refused.
    static func extract(_ reading: ProductLabelReading) -> (codes: [ReadCode], refused: Int) {
        var out: [ReadCode] = []
        var refused = 0
        func add(_ code: ReadCode) {
            if !out.contains(where: { $0.value == code.value }) { out.append(code) }
        }
        for barcode in reading.barcodes {
            let source = CodeSource.barcode(symbology: barcode.symbology)
            let payload = barcode.payload.trimmingCharacters(in: .whitespacesAndNewlines)
            if let gtin = gtin(payload) {
                add(ReadCode(value: gtin, kind: .gtin, source: source))
            } else if let code = productCode(payload) {
                add(ReadCode(value: code, kind: .productCode, source: source))
            } else {
                refused += 1
            }
        }
        for line in reading.textLines {
            let upper = line.uppercased()
            // "KB - TEE - 01" on a tag is one code; OCR often spaces the hyphens.
            let joined = upper.replacingOccurrences(of: #"\s*[-‐‑–]\s*"#, with: "-", options: .regularExpression)
            for token in joined.split(whereSeparator: { $0.isWhitespace || ",;:/|()[]".contains($0) }) {
                let trimmed = token.trimmingCharacters(in: CharacterSet(charactersIn: ".-*#"))
                if let code = productCode(trimmed) { add(ReadCode(value: code, kind: .productCode, source: .labelText)) }
            }
            // A printed GTIN is digits with spaces: "8 690000 000002".
            let digits = upper.filter { !$0.isWhitespace }
            if digits.allSatisfy(\.isASCIIDigitCharacter), let gtin = gtin(digits) {
                add(ReadCode(value: gtin, kind: .gtin, source: .labelText))
            }
        }
        return (out, refused)
    }

    /// A shop code: passes the resolver's own input rules, has 2–6 segments, letters and digits.
    static func productCode(_ raw: String) -> String? {
        guard let code = ProductResolver.normalize(raw) else { return nil }
        let segments = code.split(separator: "-", omittingEmptySubsequences: false)
        guard codeSegments.contains(segments.count), segments.allSatisfy({ !$0.isEmpty }),
              code.contains(where: \.isLetter), code.contains(where: \.isASCIIDigitCharacter),
              code.count >= 5 else { return nil }
        return code
    }

    /// GTIN-8/12/13/14 with a valid GS1 check digit.
    public static func gtin(_ raw: String) -> String? {
        guard [8, 12, 13, 14].contains(raw.count), raw.allSatisfy(\.isASCIIDigitCharacter) else { return nil }
        let digits = raw.compactMap(\.wholeNumberValue)
        let body = digits.dropLast()
        var sum = 0
        for (i, d) in body.reversed().enumerated() { sum += d * (i.isMultiple(of: 2) ? 3 : 1) }
        return (10 - sum % 10) % 10 == digits.last ? raw : nil
    }

    /// OCR mixes up O/0, I/1, S/5, B/8 inside a numeric segment ("O1" for "01"). Only text reads are
    /// repaired, only where the rest of the segment is digits, and a repair still has to be in the catalogue.
    static func ocrRepairs(_ code: String, source: CodeSource) -> [String] {
        guard source == .labelText else { return [] }
        let map: [Character: Character] = ["O": "0", "I": "1", "L": "1", "S": "5", "B": "8"]
        let segments = code.split(separator: "-").map { segment -> String in
            let digits = segment.filter(\.isASCIIDigitCharacter).count
            guard digits > 0, segment.allSatisfy({ $0.isASCIIDigitCharacter || map[$0] != nil }) else { return String(segment) }
            return String(segment.map { map[$0] ?? $0 })
        }
        let repaired = segments.joined(separator: "-")
        return repaired == code ? [] : [repaired]
    }
}

extension Character {
    var isASCIIDigitCharacter: Bool { ("0"..."9").contains(self) }
}
