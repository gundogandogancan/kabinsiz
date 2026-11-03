import AvatarDressing
import DomainContracts
import Foundation
import TravelEngine
import WardrobeDomain

/// One look ready to put on the figure, with the reasons it was chosen (v2.5 §4.3 OutfitSnapshotV1,
/// reconciled with the travel planner's `OutfitCandidate`: same generator, same garment IDs).
public struct TodayLook: Codable, Hashable, Sendable, Identifiable {
    public let outfit: DressedOutfit
    /// Short, true reasons built only from data the engine used.
    public let reasons: [String]
    /// What the look lacks, honestly (e.g. no shoes in the closet).
    public let gaps: [String]
    /// Claims the engine deliberately did not make, shown when the user opens "why".
    public let unsupportedClaims: [String]
    public let candidateID: String
    public var id: String { outfit.id }

    public init(outfit: DressedOutfit, reasons: [String], gaps: [String], unsupportedClaims: [String], candidateID: String) {
        self.outfit = outfit
        self.reasons = reasons
        self.gaps = gaps
        self.unsupportedClaims = unsupportedClaims
        self.candidateID = candidateID
    }
    public var isSyntheticDemo: Bool { outfit.isSynthetic }
}

/// The day's looks: a short ranked list composed ahead of time, so "new outfit" only moves to the
/// next prepared look instead of computing on tap (§4.5 step 1).
public struct TodayLooks: Codable, Hashable, Sendable {
    public enum Source: String, Codable, Sendable {
        /// From the user's own wardrobe.
        case wardrobe = "WARDROBE"
        /// The wardrobe cannot dress the figure; a labelled synthetic example is shown instead.
        case syntheticExample = "SYNTHETIC_EXAMPLE"
    }

    public let localDate: LocalDate
    public let mood: TodayOutfitEngine.Mood
    public let source: Source
    public let looks: [TodayLook]
    /// Changes whenever the pool the looks came from changes; a cache with another revision is stale.
    public let poolRevision: String

    public init(localDate: LocalDate, mood: TodayOutfitEngine.Mood, source: Source, looks: [TodayLook], poolRevision: String) {
        self.localDate = localDate
        self.mood = mood
        self.source = source
        self.looks = looks
        self.poolRevision = poolRevision
    }
}

public struct TodayOutfitEngine: Sendable {
    /// The user's one-tap steer (v2.5 §4.5 step 2).
    public enum Mood: String, Codable, CaseIterable, Sendable {
        case balanced, simpler, bolder, relaxed, sharper

        public var displayName: String {
            switch self {
            case .balanced: "Dengeli"
            case .simpler: "Daha sade"
            case .bolder: "Daha cesur"
            case .relaxed: "Daha rahat"
            case .sharper: "Daha şık"
            }
        }

        var formality: Formality {
            switch self {
            case .relaxed: .relaxed
            case .sharper: .smart
            case .balanced, .simpler, .bolder: .casual
            }
        }
    }

    public var limit = 5
    public init() {}

    public func looks(for date: LocalDate, wardrobe: Wardrobe, mood: Mood = .balanced) -> TodayLooks {
        let own = compose(date, wardrobe, mood)
        if !own.isEmpty {
            return TodayLooks(localDate: date, mood: mood, source: .wardrobe, looks: own, poolRevision: Self.revision(wardrobe))
        }
        let example = compose(date, SyntheticCloset.studio, mood)
        return TodayLooks(localDate: date, mood: mood, source: .syntheticExample, looks: example, poolRevision: Self.revision(wardrobe))
    }

    /// A fingerprint of everything in the wardrobe the engine reads.
    public static func revision(_ wardrobe: Wardrobe) -> String {
        var hasher = StableHasher()
        for g in wardrobe.garments.sorted(by: { $0.id < $1.id }) {
            hasher.add(g.id); hasher.add(g.name); hasher.add(g.category.rawValue); hasher.add(g.colorName)
            hasher.add(g.condition.rawValue); hasher.add("\(g.formalityRange)")
        }
        return hasher.hex
    }

    // MARK: Composition

    private func compose(_ date: LocalDate, _ wardrobe: Wardrobe, _ mood: Mood) -> [TodayLook] {
        let slot = OutfitSlot.everyday(date, formality: mood.formality)
        let drawable = Wardrobe(garments: wardrobe.garments.filter { GarmentAppearance.dressItem(for: $0) != nil || $0.category == .accessory })
        let base = OutfitCandidateGenerator().candidates(for: slot, wardrobe: drawable)
        let usable = drawable.garments.filter { $0.condition.isPlannable }
        let outers = usable.filter { $0.category == .outerwear && $0.covers(slot.formality) }.sorted { $0.id < $1.id }
        // "Daha sade" keeps accessories neutral too.
        let accessories = usable.filter { mood != .simpler || $0.isNeutralColor }
            .compactMap(GarmentAppearance.dressItem(for:)).filter { [.bag, .belt, .otherAccessory].contains($0.slot) }
            .sorted { $0.id < $1.id }

        var scored: [(score: Int, look: TodayLook)] = []
        for candidate in base {
            let pieces = candidate.garmentIDs.compactMap { wardrobe.garment(id: $0) }
            let items = pieces.compactMap(GarmentAppearance.dressItem(for:))
            // The figure needs a top and a bottom it can actually draw.
            guard items.contains(where: { $0.slot == .top }), items.contains(where: { $0.slot == .bottom }) else { continue }
            // Variants: as generated, and with each outer layer as a styling choice (not a weather claim).
            var variants: [[Garment]] = [pieces]
            if !pieces.contains(where: { $0.category == .outerwear }) {
                variants += outers.map { pieces + [$0] }
            }
            for variant in variants {
                let variantItems = variant.compactMap(GarmentAppearance.dressItem(for:))
                let score = styleScore(variant, mood: mood) + candidate.styleScore
                scored.append((score, look(candidate, variant, variantItems, mood: mood, styledLayer: variant.count > pieces.count)))
            }
        }
        // Best first; ties by ID so the order is identical on every run.
        let ranked = scored.sorted { ($0.score, $1.look.id) > ($1.score, $0.look.id) }
        var seen = Set<String>(), result: [TodayLook] = []
        for entry in ranked where seen.insert(entry.look.id).inserted {
            result.append(entry.look)
            if result.count == limit { break }
        }
        // Accessories rotate across the looks, so each look is visibly its own.
        guard !accessories.isEmpty else { return result }
        return result.enumerated().map { index, look in
            var outfit = look.outfit
            var reasons = look.reasons
            for (k, slotKind) in [GarmentSlotID.belt, .bag, .otherAccessory].enumerated() {
                let options = accessories.filter { $0.slot == slotKind }
                guard !options.isEmpty, (index + k) % 2 == 0 else { continue }
                if slotKind == .belt, outfit[.bottom].map({ [.trousers, .jeans].contains($0.form) }) != true { continue }
                outfit = outfit.replacing(options[(index / 2) % options.count])
            }
            let added = outfit.items.count - look.outfit.items.count
            if added > 0 { reasons.append("\(added) aksesuar dolabından") }
            return TodayLook(outfit: outfit, reasons: reasons, gaps: look.gaps, unsupportedClaims: look.unsupportedClaims, candidateID: look.candidateID)
        }
    }

    private func look(_ candidate: OutfitCandidate, _ pieces: [Garment], _ items: [DressItem], mood: Mood, styledLayer: Bool) -> TodayLook {
        var reasons: [String] = []
        let synthetic = pieces.allSatisfy(\.provenance.isSynthetic)
        reasons.append(synthetic ? "Örnek dolaptan \(items.count) parça (sentetik)" : "Dolabından \(items.count) parça")
        reasons.append("\(mood.formality.displayName) bir gün için")
        if let top = items.first(where: { $0.slot == .top }), let bottom = items.first(where: { $0.slot == .bottom }) {
            reasons.append(colorReason(top, bottom))
        }
        if styledLayer { reasons.append("Üstte bir katman: stil tercihi") }
        if mood != .balanced { reasons.append(mood.displayName) }
        let unsupported = [
            "Hava verisi kullanılmadı: kombin havaya göre seçilmedi.",
            "Görünüm temsilidir; beden ve kumaş uyumunu göstermez.",
        ]
        return TodayLook(outfit: DressedOutfit(items), reasons: reasons, gaps: candidate.gaps, unsupportedClaims: unsupported, candidateID: candidate.id)
    }

    /// Small, explainable colour and mood terms on top of the generator's score.
    private func styleScore(_ pieces: [Garment], mood: Mood) -> Int {
        let colours = pieces.map(\.colorName)
        let accents = pieces.filter { !$0.isNeutralColor }.count
        var score = 0
        // Two different accent colours in one look read as busy.
        if Set(pieces.filter { !$0.isNeutralColor }.map(\.colorName)).count > 1 { score -= 3 }
        // Top and bottom in the same colour read as flat, unless deliberately tonal.
        if let top = pieces.first(where: { $0.category == .top }), let bottom = pieces.first(where: { $0.category == .bottom }),
           top.colorName == bottom.colorName { score -= 1 }
        switch mood {
        case .simpler: score += 3 * (pieces.count - accents) - 2 * accents
        case .bolder: score += 4 * accents + (pieces.contains { $0.category == .outerwear } ? 2 : 0)
        case .sharper: score += pieces.contains { $0.category == .outerwear } ? 3 : 0
        case .relaxed: score += pieces.contains { $0.category == .outerwear } ? -2 : 1
        case .balanced: score += Set(colours).count >= 3 ? 1 : 0
        }
        return score
    }

    private func colorReason(_ top: DressItem, _ bottom: DressItem) -> String {
        let lt = luminance(top.colorHex), lb = luminance(bottom.colorHex)
        if abs(lt - lb) > 0.25 { return "\(top.colorName.capitalized(with: Locale(identifier: "tr_TR"))) üst, \(bottom.colorName) alt: açık-koyu dengesi" }
        return "\(top.colorName.capitalized(with: Locale(identifier: "tr_TR"))) ve \(bottom.colorName): yakın tonlar"
    }

    private func luminance(_ hex: UInt32) -> Double {
        let r = Double((hex >> 16) & 0xFF) / 255, g = Double((hex >> 8) & 0xFF) / 255, b = Double(hex & 0xFF) / 255
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}

/// FNV-1a over UTF-8, stable across launches (Swift's Hasher is seeded per process).
struct StableHasher {
    private var state: UInt64 = 0xCBF2_9CE4_8422_2325
    mutating func add(_ s: String) {
        for byte in s.utf8 { state = (state ^ UInt64(byte)) &* 0x0000_0100_0000_01B3 }
        state = (state ^ 0xFF) &* 0x0000_0100_0000_01B3
    }
    var hex: String { String(format: "%016llx", state) }
}
