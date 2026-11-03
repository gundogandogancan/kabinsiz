import DomainContracts
import Foundation

/// A size chart with its source. Only synthetic charts exist in P0 (ADR-004).
public struct SizeChart: Codable, Hashable, Sendable {
    public struct Row: Codable, Hashable, Sendable {
        public let size: String
        public let chestCm: ClosedRange<Double>?
        public let waistCm: ClosedRange<Double>?

        public init(size: String, chestCm: ClosedRange<Double>?, waistCm: ClosedRange<Double>?) {
            self.size = size
            self.chestCm = chestCm
            self.waistCm = waistCm
        }
    }

    public let revision: Int
    public let rows: [Row]
    public let provenance: Provenance

    public init(revision: Int, rows: [Row], provenance: Provenance) {
        self.revision = revision
        self.rows = rows
        self.provenance = provenance
    }
}

/// Measurements the user typed in themselves. Never derived from photos here.
public struct UserMeasurements: Codable, Hashable, Sendable {
    public var chestCm: Double?
    public var waistCm: Double?

    public init(chestCm: Double? = nil, waistCm: Double? = nil) {
        self.chestCm = chestCm
        self.waistCm = waistCm
    }
}

/// A body measurement a size chart can list.
public enum ChartMeasure: String, Codable, CaseIterable, Comparable, Sendable {
    case chest, waist

    public var displayName: String {
        switch self {
        case .chest: "Göğüs"
        case .waist: "Bel"
        }
    }

    public static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }
}

/// What the card may say about size. There is no percentage anywhere by design (T-V13-019).
public enum SizeAdvice: Hashable, Sendable {
    /// Not enough data. `reason` is user-facing Turkish.
    case abstain(reason: String)
    /// Exactly one relevant record: we show history, not a prediction.
    case history(size: String, outcome: FitOutcome)
    /// At least two consistent records for this brand + category.
    case likely(size: String, basedOn: Int)
    /// Every measurement in `basedOn` falls in this size's row and in no other row. `notInChart` are
    /// measurements the user gave that the chart cannot judge; the card names them instead of letting
    /// "your measurements" imply they were checked (V21-00 gap 1).
    case chartMatch(size: String, chartProvenance: Provenance, basedOn: Set<ChartMeasure>, notInChart: Set<ChartMeasure>)

    public var confidence: ConfidenceKind {
        switch self {
        case .abstain: .abstain
        case .history: .partial
        case .likely: .heuristic
        case let .chartMatch(_, p, _, notInChart): p == .licensedCatalog && notInChart.isEmpty ? .verifiedFacts : .heuristic
        }
    }

    public var headline: String {
        switch self {
        case .abstain: "Yeterli veri yok"
        case let .history(size, outcome): "Daha önce \(size) aldın: \(outcome.displayName.lowercased())"
        case let .likely(size, _): "\(size) daha olası"
        case let .chartMatch(size, _, basedOn, notInChart):
            notInChart.isEmpty && basedOn.count > 1
                ? "Ölçülerine göre tabloda \(size)"
                : "\(basedOn.sorted().map(\.displayName).joined(separator: " ve ")) ölçüne göre tabloda \(size)"
        }
    }

    public var detail: String {
        switch self {
        case .abstain(let reason): reason
        case .history: "Tek bir deneme sonucu var. Kesin beden önerisi için yeterli değil."
        case let .likely(_, n): "Bu markada aynı türde \(n) deneme kaydına dayanıyor."
        case let .chartMatch(_, p, _, notInChart):
            [
                notInChart.isEmpty ? nil : "\(notInChart.sorted().map(\.displayName).joined(separator: " ve ")) ölçün bu tabloda yok; karşılaştırılmadı.",
                p.isSynthetic ? "Örnek (sentetik) beden tablosu. Gerçek ürün tablosu değil." : "Markanın beden tablosu.",
            ].compactMap { $0 }.joined(separator: " ")
        }
    }
}

public enum SizeAdvisor {
    /// Scope rule (ADR-005): only same brand + same category. A record about the *same model* at an older
    /// catalog revision is stale. Any contradicting record for a size blocks "likely" (STOP_THE_LINE on fit claims).
    public static func advice(
        passport: FitPassport,
        brandID: String?,
        category: GarmentCategory,
        productModelID: String? = nil,
        catalogRevision: Int?,
        chart: SizeChart?,
        measurements: UserMeasurements?
    ) -> SizeAdvice {
        if let brandID, passport.learningEnabled, !passport.excludedBrandIDs.contains(brandID) {
            let relevant = passport.observations.filter {
                $0.brandID == brandID && $0.garmentCategory == category && $0.observedOutcome != .notTried && $0.markedSize != nil
            }
            let stale = relevant.filter { obs in
                guard let model = productModelID, obs.productModelID == model,
                      let old = obs.catalogRevision, let now = catalogRevision else { return false }
                return old != now
            }
            let current = relevant.filter { obs in !stale.contains { $0.id == obs.id } }
            if current.isEmpty && !stale.isEmpty {
                return .abstain(reason: "Bu ürünün kalıbı, kayıtlı denemenden sonra değişmiş. Eski bedenin geçerli olmayabilir.")
            }
            if current.count == 1, let only = current.first, let size = only.markedSize {
                return .history(size: size, outcome: only.observedOutcome)
            }
            if current.count >= 2 {
                let fittingSizes = Set(current.filter { $0.observedOutcome == .fits }.compactMap(\.markedSize))
                if fittingSizes.count == 1, let size = fittingSizes.first {
                    let sameSize = current.filter { $0.markedSize == size }
                    let fits = sameSize.filter { $0.observedOutcome == .fits }.count
                    let contradicting = sameSize.count - fits
                    if contradicting == 0 && fits >= 2 { return .likely(size: size, basedOn: fits) }
                    if contradicting > 0 {
                        return .abstain(reason: "\(size) bedeninde kayıtların çelişiyor: \(fits) kez tam, \(contradicting) kez dar veya bol.")
                    }
                } else if fittingSizes.count > 1 {
                    return .abstain(reason: "Bu markada farklı bedenler tam olmuş (\(fittingSizes.sorted().joined(separator: ", "))). Kabinde dene.")
                } else {
                    return .abstain(reason: "Kayıtlı denemelerinde bu markada tam oturan bir beden yok.")
                }
            }
        }
        if let chart, let match = chartMatch(chart: chart, measurements: measurements) {
            return .chartMatch(size: match.size, chartProvenance: chart.provenance, basedOn: match.basedOn, notInChart: match.notInChart)
        }
        if chart == nil {
            return .abstain(reason: "Bu ürünün beden tablosu yok. Kabinde denemeden kesin beden alma.")
        }
        return .abstain(reason: "Ölçü girmedin veya ölçün tablodaki aralıklara uymuyor.")
    }

    /// A size matches only if every measurement the user gave *and the row lists* falls in that row's
    /// ranges, at least one was compared, and exactly one row matches. Measurements the matching row does
    /// not list are returned as `notInChart`, so the card can say what was not checked.
    static func chartMatch(chart: SizeChart, measurements: UserMeasurements?) -> (size: String, basedOn: Set<ChartMeasure>, notInChart: Set<ChartMeasure>)? {
        guard let m = measurements else { return nil }
        let given: [(ChartMeasure, Double)] = [(.chest, m.chestCm), (.waist, m.waistCm)].compactMap { k, v in v.map { (k, $0) } }
        guard !given.isEmpty else { return nil }
        func range(_ row: SizeChart.Row, _ k: ChartMeasure) -> ClosedRange<Double>? {
            switch k {
            case .chest: row.chestCm
            case .waist: row.waistCm
            }
        }
        let matches: [(SizeChart.Row, Set<ChartMeasure>)] = chart.rows.compactMap { row in
            var checked: Set<ChartMeasure> = []
            for (k, value) in given {
                guard let r = range(row, k) else { continue }
                guard r.contains(value) else { return nil }
                checked.insert(k)
            }
            return checked.isEmpty ? nil : (row, checked)
        }
        guard matches.count == 1, let (row, basedOn) = matches.first else { return nil }
        return (row.size, basedOn, Set(given.map(\.0)).subtracting(basedOn))
    }
}
