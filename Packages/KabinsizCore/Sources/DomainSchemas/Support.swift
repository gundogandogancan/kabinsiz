import Foundation
import SystemContracts

/// Every check in this module fails closed with `schemaInvalid` unless it says otherwise: a value that
/// breaks a provenance rule is refused, never repaired (§4 "Zorunlu provenance ilkesi").
@inline(__always)
func require(_ condition: Bool, _ fault: FaultCode = .schemaInvalid) throws(FaultCode) {
    if !condition { throw fault }
}

extension String {
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
}

/// ISO 3166-1 alpha-2 style market code (`TR`, `DE`, `US`) or `EU`. Upper-case ASCII only.
func isMarketCode(_ s: String) -> Bool {
    s.count == 2 && s.unicodeScalars.allSatisfy { ("A"..."Z").contains($0) }
}

/// ISO 4217 style currency code (`TRY`, `EUR`).
func isCurrencyCode(_ s: String) -> Bool {
    s.count == 3 && s.unicodeScalars.allSatisfy { ("A"..."Z").contains($0) }
}

func allUnique<S: Sequence>(_ items: S) -> Bool where S.Element: Hashable {
    var seen = Set<S.Element>()
    return items.allSatisfy { seen.insert($0).inserted }
}

func allNonBlank<S: Sequence>(_ items: S) -> Bool where S.Element == String {
    items.allSatisfy { !$0.isBlank }
}

extension Double {
    func isFinite(in range: ClosedRange<Double>) -> Bool { isFinite && range.contains(self) }
}

/// GS1 Global Trade Item Number. Stored in one canonical form, GTIN-14, so the same product scanned as
/// EAN-13 or UPC-A is the same identifier (§3.1 "GS1 check digit").
public enum GTIN {
    /// Digits only (spaces and hyphens ignored), 8/12/13/14 long, valid mod-10 check digit → GTIN-14.
    /// Anything else is `nil`; a wrong check digit is never "corrected".
    public static func normalized(_ raw: String) -> String? {
        let digits = raw.filter { $0 != " " && $0 != "-" }
        guard [8, 12, 13, 14].contains(digits.count),
              digits.unicodeScalars.allSatisfy({ ("0"..."9").contains($0) })
        else { return nil }
        let padded = String(repeating: "0", count: 14 - digits.count) + digits
        return hasValidCheckDigit(padded) ? padded : nil
    }

    static func hasValidCheckDigit(_ gtin14: String) -> Bool {
        let n = gtin14.compactMap(\.wholeNumberValue)
        guard n.count == 14 else { return false }
        // Weights 3,1,3,… from the left over the first 13 digits of a GTIN-14.
        let sum = n.prefix(13).enumerated().reduce(0) { $0 + $1.element * ($1.offset.isMultiple(of: 2) ? 3 : 1) }
        return (10 - sum % 10) % 10 == n[13]
    }
}
