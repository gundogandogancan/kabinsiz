import DomainContracts
import Foundation
import LivingWorld
import TravelEngine
import WardrobeDomain

// V36 (ADR-017, rival recon): the closet features users of Alta and Cladwell value most. They are done
// entirely on the device, with nothing estimated. A price exists only if the user typed it. A wear exists
// only if the user logged it. A calendar title is read on the device and never stored.

// MARK: - Wear log

/// One day's outfit as the user logged it ("Bugün bunu giydim").
public struct WearEntry: Codable, Hashable, Sendable {
    public let date: LocalDate
    public let garmentIDs: [String]

    public init(date: LocalDate, garmentIDs: [String]) {
        self.date = date
        self.garmentIDs = Array(Set(garmentIDs)).sorted()
    }
}

/// A price the user typed, in minor units (kuruş, cent). Never fetched, never guessed.
public struct UserPrice: Codable, Hashable, Sendable {
    public let minorUnits: Int
    /// ISO 4217, e.g. "TRY".
    public let currency: String

    public init?(minorUnits: Int, currency: String) {
        guard minorUnits > 0, currency.count == 3 else { return nil }
        self.minorUnits = minorUnits
        self.currency = currency.uppercased()
    }
}

/// The local ledger: logged wears and the prices the user typed. One entry per day; logging a day
/// again replaces it (the user corrected it).
public struct WearLedger: Codable, Hashable, Sendable {
    public static let schemaVersion = 1
    public private(set) var entries: [WearEntry] = []
    public private(set) var prices: [String: UserPrice] = [:]

    public init() {}

    public mutating func log(_ entry: WearEntry) {
        entries.removeAll { $0.date == entry.date }
        guard !entry.garmentIDs.isEmpty else { return }
        entries.append(entry)
        entries.sort { $0.date < $1.date }
    }

    public mutating func setPrice(_ price: UserPrice?, for garmentID: String) { prices[garmentID] = price }

    /// The garment is gone from the closet: its wears and price go too.
    public mutating func forget(garmentID: String) {
        prices[garmentID] = nil
        entries = entries.compactMap { e in
            let rest = e.garmentIDs.filter { $0 != garmentID }
            return rest.isEmpty ? nil : WearEntry(date: e.date, garmentIDs: rest)
        }
    }

    public func wearCount(_ id: String) -> Int { entries.reduce(0) { $0 + ($1.garmentIDs.contains(id) ? 1 : 0) } }
    public func lastWorn(_ id: String) -> LocalDate? { entries.last { $0.garmentIDs.contains(id) }?.date }

    /// Price ÷ wears, only when both are the user's own numbers. Nil otherwise: never "0 ₺" or a guess.
    public func costPerWear(_ id: String) -> (minorUnits: Int, currency: String)? {
        guard let p = prices[id] else { return nil }
        let n = wearCount(id)
        guard n > 0 else { return nil }
        return ((p.minorUnits + n / 2) / n, p.currency)
    }

    /// Garments worn within `days` days before `date` (not counting `date`), for repeat avoidance.
    public func recentlyWorn(before date: LocalDate, days: Int) -> Set<String> {
        Set(entries.filter { $0.date < date && $0.date.days(until: date) <= days }.flatMap(\.garmentIDs))
    }
}

// MARK: - Closet report

public struct WearStat: Hashable, Sendable {
    public let garment: Garment
    public let wears: Int
    public let lastWorn: LocalDate?
}

public struct ClosetReport: Hashable, Sendable {
    /// Most worn first; only garments with at least one wear.
    public let mostWorn: [WearStat]
    /// Worn least (never-worn first), excluding pieces added after `since`.
    public let leastWorn: [WearStat]
    public let neverWorn: [Garment]
    /// Share of the closet worn at least once in the window, 0…1. Nil for an empty closet.
    public let utilisation: Double?
    /// True when the closet holds only the labelled demo set: the report is an example, not the user's.
    public let isSyntheticExample: Bool

    public static func make(wardrobe: Wardrobe, ledger: WearLedger, top: Int = 5) -> ClosetReport {
        let plannable = wardrobe.garments.filter { $0.category != .underlayer }
        let stats = plannable.map { WearStat(garment: $0, wears: ledger.wearCount($0.id), lastWorn: ledger.lastWorn($0.id)) }
        let worn = stats.filter { $0.wears > 0 }.sorted { ($0.wears, $1.garment.id) > ($1.wears, $0.garment.id) }
        let least = stats.sorted { ($0.wears, $0.garment.id) < ($1.wears, $1.garment.id) }
        return ClosetReport(
            mostWorn: Array(worn.prefix(top)),
            leastWorn: Array(least.prefix(top)),
            neverWorn: stats.filter { $0.wears == 0 }.map(\.garment),
            utilisation: plannable.isEmpty ? nil : Double(worn.count) / Double(plannable.count),
            isSyntheticExample: !plannable.isEmpty && plannable.allSatisfy { $0.provenance.isSynthetic }
        )
    }
}

// MARK: - Closet gaps

/// What the closet cannot do yet, by plain rules. It is a hint, never a push to buy.
public struct ClosetGap: Hashable, Sendable, Identifiable {
    public enum Kind: String, Hashable, Sendable {
        case noTops, noBottoms, noShoes, noOuterwear, noRainProtection, noFormal, noSmart, noNeutralBasics, fewBottomsForTops
    }

    public let kind: Kind
    public let message: String
    public var id: String { kind.rawValue }
}

public enum ClosetGapFinder {
    public static let footnote = "Kurala dayalı öneri · satın alma önerisi değildir"

    public static func gaps(in wardrobe: Wardrobe) -> [ClosetGap] {
        let usable = wardrobe.garments.filter { $0.condition != .unavailable }
        guard !usable.isEmpty else { return [] }
        func count(_ c: GarmentCategory) -> Int { usable.filter { $0.category == c }.count }
        let tops = count(.top), bottoms = count(.bottom), dresses = count(.dress)
        var out: [ClosetGap] = []
        if tops == 0, dresses == 0 { out.append(.init(kind: .noTops, message: "Dolabında üst yok")) }
        if bottoms == 0, dresses == 0 { out.append(.init(kind: .noBottoms, message: "Dolabında alt yok")) }
        if count(.shoes) == 0 { out.append(.init(kind: .noShoes, message: "Ayakkabı eklenmemiş")) }
        if count(.outerwear) == 0 { out.append(.init(kind: .noOuterwear, message: "Serin günler için dış giyim yok")) }
        let rainReady = usable.contains { $0.category == .weatherProtection || $0.hasClaim(.waterResistant) }
        if !rainReady { out.append(.init(kind: .noRainProtection, message: "Yağmurlu günler için su geçirmez parça yok")) }
        let wearable = usable.filter { [.top, .bottom, .dress, .outerwear, .shoes].contains($0.category) }
        if !wearable.isEmpty {
            if !wearable.contains(where: { $0.covers(.formal) }) {
                out.append(.init(kind: .noFormal, message: "Resmi bir davet için parça yok"))
            }
            if !wearable.contains(where: { $0.covers(.smart) }) {
                out.append(.init(kind: .noSmart, message: "Şık bir gün (toplantı, akşam yemeği) için parça yok"))
            }
            if !wearable.contains(where: \.isNeutralColor) {
                out.append(.init(kind: .noNeutralBasics, message: "Her şeyle giyilen nötr renkli temel parça yok"))
            }
        }
        if bottoms > 0, tops >= 4 * bottoms {
            out.append(.init(kind: .fewBottomsForTops, message: "\(tops) üste \(bottoms) alt düşüyor: kombinler tekrar edecek"))
        }
        return out
    }
}

// MARK: - The day's needs (weather + calendar)

/// What today asks of an outfit. The calendar is read on the device: titles are matched here and dropped.
public struct DayNeeds: Hashable, Sendable {
    public var minimumFormality: Formality
    public var needsOuterwear: Bool
    public var needsRainProtection: Bool
    public var activewear: Bool
    /// Why, in one line per reason, for the "neden bu kombin" sheet.
    public var reasons: [String]

    /// Weather counts only if it was drawn from evidence (a fresh observation or nothing). A preview never
    /// changes what the user is told to wear.
    public static func make(weather: SceneWeatherState?, temperatureC: Double?, eventTitles: [String]) -> DayNeeds {
        var n = DayNeeds(minimumFormality: .relaxed, needsOuterwear: false, needsRainProtection: false, activewear: false, reasons: [])
        if let w = weather, !w.isPreview, let c = w.drawn {
            switch c {
            case .rain:
                n.needsRainProtection = true
                n.needsOuterwear = true
                n.reasons.append("Yağmur gözlendi")
            case .snow:
                n.needsOuterwear = true
                n.needsRainProtection = true
                n.reasons.append("Kar gözlendi")
            case .wind:
                n.needsOuterwear = true
                n.reasons.append("Rüzgâr gözlendi")
            case .clear, .cloudy, .fog: break
            }
        }
        if let t = temperatureC, t < 15 {
            n.needsOuterwear = true
            n.reasons.append("Ölçülen sıcaklık \(Int(t.rounded()))°")
        }
        for title in eventTitles {
            guard let match = OccasionReader.occasion(in: title) else { continue }
            if match.formality > n.minimumFormality { n.minimumFormality = match.formality }
            if match.active { n.activewear = true }
            if !n.reasons.contains(match.reason) { n.reasons.append(match.reason) }
        }
        return n
    }
}

/// Keyword reading of a calendar title, on the device (Turkish and English). No title is kept.
public enum OccasionReader {
    public struct Occasion: Hashable, Sendable {
        public let formality: Formality
        public let active: Bool
        public let reason: String
    }

    private static let rules: [(words: [String], occasion: Occasion)] = [
        (["düğün", "nikah", "gala", "wedding", "black tie", "resepsiyon"], Occasion(formality: .formal, active: false, reason: "Takviminde resmi bir davet var")),
        (["mülakat", "görüşme", "interview", "sunum", "presentation", "toplantı", "meeting", "müşteri", "client", "board"],
         Occasion(formality: .smart, active: false, reason: "Takviminde iş görüşmesi var")),
        (["akşam yemeği", "dinner", "tiyatro", "opera", "theatre", "date", "randevu"], Occasion(formality: .smart, active: false, reason: "Takviminde şık bir akşam var")),
        (["spor", "gym", "koşu", "run", "yoga", "pilates", "antrenman", "workout", "maç"], Occasion(formality: .relaxed, active: true, reason: "Takviminde spor var")),
    ]

    public static func occasion(in title: String) -> Occasion? {
        let t = title.lowercased(with: Locale(identifier: "tr_TR"))
        return rules.first { rule in rule.words.contains { t.contains($0) } }?.occasion
    }
}
