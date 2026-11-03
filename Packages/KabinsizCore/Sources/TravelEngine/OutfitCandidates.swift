import DomainContracts
import Foundation
import WardrobeDomain

/// One thing the user needs to be dressed for: a day, or a specific event within a day.
public struct OutfitSlot: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let localDate: LocalDate
    public let dayIndex: Int
    public let timeBlock: TimeBlock
    public let activities: [Activity]
    public let formality: Formality
    public let needsWalkingShoes: Bool
    public let outdoors: Bool
    public let weather: WeatherSnapshot
    public let userDressCode: String?
    public let eventIDs: [String]
}

public struct OutfitCandidate: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let slotID: String
    /// Sorted, so two candidates with the same pieces have the same ID.
    public let garmentIDs: [String]
    public let why: [String]
    public let gaps: [String]
    public let styleScore: Int

    func adding(gap: String) -> OutfitCandidate {
        OutfitCandidate(id: id, slotID: slotID, garmentIDs: garmentIDs, why: why, gaps: gaps + [gap], styleScore: styleScore)
    }
}

enum SlotBuilder {
    /// Groups events into slots. A day with no events still needs clothes: one casual full-day slot.
    /// Evening events get their own slot so a dinner look can differ from the daytime look.
    static func slots(for trip: Trip, weather: [LocalDate: WeatherSnapshot]) -> [OutfitSlot] {
        var result: [OutfitSlot] = []
        for (dayIndex, date) in trip.dates.enumerated() {
            let dayWeather = weather[date] ?? .noData(date)
            let events = trip.events.filter { $0.localDate == date }.sorted { ($0.timeBlock, $0.id) < ($1.timeBlock, $1.id) }
            let evening = events.filter { $0.timeBlock == .evening }
            let daytime = events.filter { $0.timeBlock != .evening }

            if daytime.isEmpty && evening.isEmpty {
                result.append(make(date: date, dayIndex: dayIndex, block: .fullDay, events: [], weather: dayWeather))
                continue
            }
            if !daytime.isEmpty || evening.isEmpty {
                result.append(make(date: date, dayIndex: dayIndex, block: daytime.count == 1 ? daytime[0].timeBlock : .fullDay, events: daytime, weather: dayWeather))
            } else {
                // Only an evening event was entered; the user still needs a daytime outfit.
                result.append(make(date: date, dayIndex: dayIndex, block: .fullDay, events: [], weather: dayWeather))
            }
            if !evening.isEmpty {
                result.append(make(date: date, dayIndex: dayIndex, block: .evening, events: evening, weather: dayWeather))
            }
        }
        return result
    }

    private static func make(date: LocalDate, dayIndex: Int, block: TimeBlock, events: [TripEvent], weather: WeatherSnapshot) -> OutfitSlot {
        let activities = events.isEmpty ? [Activity.other] : events.map(\.activity)
        let formality = events.map(\.formality).max() ?? .casual
        let outdoors = events.isEmpty || events.contains { $0.indoorsOutdoors != .indoors }
        return OutfitSlot(
            id: "\(date)-\(block.rawValue)",
            localDate: date,
            dayIndex: dayIndex,
            timeBlock: block,
            activities: activities,
            formality: formality,
            needsWalkingShoes: events.contains { $0.activity.involvesLongWalking },
            outdoors: outdoors,
            weather: weather,
            userDressCode: events.compactMap(\.userDressCode).first,
            eventIDs: events.map(\.id)
        )
    }
}

/// Builds feasible outfits for one slot from owned, plannable garments (§45.2 step 1).
/// Each category is pruned to its best few pieces so the search stays small on large closets.
public struct OutfitCandidateGenerator: Sendable {
    public var perCategoryLimit = 4

    public init() {}

    public func candidates(for slot: OutfitSlot, wardrobe: Wardrobe) -> [OutfitCandidate] {
        let usable = wardrobe.garments.filter { $0.condition.isPlannable && $0.covers(slot.formality) }
        let tops = best(usable, .top, slot)
        let bottoms = best(usable, .bottom, slot)
        let dresses = best(usable, .dress, slot)
        let shoes = shoeOptions(usable, slot)
        let warmNeeded = slot.outdoors && slot.weather.needsWarmLayer == true
        let rainLikely = slot.outdoors && slot.weather.rainLikely == true
        let outers = best(usable, .outerwear, slot, preferRain: rainLikely)

        var bases: [[Garment]] = []
        for top in tops { for bottom in bottoms { bases.append([top, bottom]) } }
        for dress in dresses { bases.append([dress]) }

        var result: [OutfitCandidate] = []
        let shoeChoices: [Garment?] = shoes.isEmpty ? [nil] : shoes.map { $0 }
        let outerChoices: [Garment?] = warmNeeded && !outers.isEmpty ? outers.map { $0 } : [nil]
        for base in bases {
            for shoe in shoeChoices {
                for outer in outerChoices {
                    let pieces = base + [shoe, outer].compactMap { $0 }
                    result.append(candidate(slot: slot, pieces: pieces, shoe: shoe, outer: outer, warmNeeded: warmNeeded, rainLikely: rainLikely))
                }
            }
        }
        return result.sorted { ($0.styleScore, $1.id) > ($1.styleScore, $0.id) }
    }

    private func candidate(slot: OutfitSlot, pieces: [Garment], shoe: Garment?, outer: Garment?, warmNeeded: Bool, rainLikely: Bool) -> OutfitCandidate {
        var why: [String] = [slot.activities.map(\.displayName).joined(separator: " + "), slot.formality.displayName]
        var gaps: [String] = []

        if slot.weather.hasNumbers {
            why.append(slot.weather.chipText + (slot.weather.isSynthetic ? " (örnek veri)" : ""))
        } else {
            why.append(slot.weather.evidence.displayName)
        }
        if let code = slot.userDressCode { why.append("Davetiye: \(code)") }

        if shoe == nil { gaps.append("Bu ortama uygun ayakkabı yok") }
        if slot.needsWalkingShoes {
            if shoe?.walkingComfort == true { why.append("Yürüyüşe rahat ayakkabı") }
            else { gaps.append("Yürüyüşe rahat olduğu bilinen ayakkabı yok") }
        }
        if warmNeeded {
            if outer != nil { why.append("Serin hava için katman") }
            else { gaps.append("Serin hava için dış katman yok") }
        }
        if rainLikely {
            if outer?.hasClaim(.waterResistant) == true { why.append("Yağmura dayanıklı (etiket bilgisi)") }
            else { gaps.append("Yağmura dayanıklı olduğu bilinen parça yok") }
        }

        let neutralShare = pieces.filter(\.isNeutralColor).count
        let score = neutralShare * 2 - gaps.count * 5
        let ids = pieces.map(\.id).sorted()
        return OutfitCandidate(id: "\(slot.id)|" + ids.joined(separator: "+"), slotID: slot.id, garmentIDs: ids, why: why, gaps: gaps, styleScore: score)
    }

    private func best(_ garments: [Garment], _ category: GarmentCategory, _ slot: OutfitSlot, preferRain: Bool = false) -> [Garment] {
        let pool = garments.filter { $0.category == category }
        return pool.sorted { a, b in
            let ka = rank(a, slot, preferRain), kb = rank(b, slot, preferRain)
            return ka != kb ? ka > kb : a.id < b.id
        }.prefix(perCategoryLimit).map { $0 }
    }

    private func rank(_ g: Garment, _ slot: OutfitSlot, _ preferRain: Bool) -> Int {
        var score = g.isNeutralColor ? 2 : 0
        // Prefer pieces whose range is centred on the slot: versatile but not over-dressed.
        score -= abs(g.formalityRange.lowerBound.rawValue - slot.formality.rawValue)
        if preferRain && g.hasClaim(.waterResistant) { score += 5 }
        if g.condition == .clean { score += 1 }
        return score
    }

    private func shoeOptions(_ garments: [Garment], _ slot: OutfitSlot) -> [Garment] {
        let shoes = best(garments, .shoes, slot)
        guard slot.needsWalkingShoes else { return shoes }
        let comfortable = shoes.filter { $0.walkingComfort == true }
        let allComfortable = garments.filter { $0.category == .shoes && $0.walkingComfort == true }
        // Hard constraint when the closet can satisfy it (T-TRV-058); otherwise fall back and report a gap.
        if !comfortable.isEmpty { return comfortable }
        if !allComfortable.isEmpty { return Array(allComfortable.sorted { $0.id < $1.id }.prefix(perCategoryLimit)) }
        return shoes
    }
}

extension OutfitSlot {
    /// An ordinary day, not a trip (Today screen, v2.5 §4): one full-day slot with no events. Weather
    /// is "no data" unless real evidence is passed in; nothing is assumed about the day.
    public static func everyday(_ date: LocalDate, formality: Formality = .casual, weather: WeatherSnapshot? = nil) -> OutfitSlot {
        OutfitSlot(id: "\(date)-today", localDate: date, dayIndex: 0, timeBlock: .fullDay, activities: [.other],
                   formality: formality, needsWalkingShoes: false, outdoors: true,
                   weather: weather ?? .noData(date), userDressCode: nil, eventIDs: [])
    }
}
