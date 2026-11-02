import DomainContracts
import Foundation
import WardrobeDomain

/// Everything one planning run produced. Counts in UI copy must come from here, never be hardcoded (§46.3).
public struct TripPlan: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public var tripID: String
    public var revision: Int
    public var slots: [OutfitSlot]
    /// All feasible alternatives, kept so the user can swap without a replan.
    public var candidates: [String: [OutfitCandidate]]
    public var solution: CapsuleSolution
    public var lockedSlotIDs: Set<String>
    public var weatherProvider: String
    public var generatedAt: Date

    public var uniquePieceCount: Int { solution.packedGarmentIDs.count }

    /// Distinct outfit options across the trip that only use packed pieces.
    public var outfitOptionCount: Int {
        let packed = solution.packedGarmentIDs
        return Set(candidates.values.flatMap { $0 }.filter { $0.garmentIDs.allSatisfy(packed.contains) }.map { $0.garmentIDs }).count
    }

    public var confidence: ConfidenceKind {
        if !solution.isFeasible { return .partial }
        let hasWeather = slots.contains { $0.weather.evidence != .noData }
        return hasWeather ? .heuristic : .partial
    }

    public func outfit(for slotID: String) -> OutfitCandidate? { solution.assignments[slotID] }

    /// Weather for display, re-aged against the current time so a saved plan never looks fresher than it is.
    public func displayWeather(for slot: OutfitSlot, now: Date = Date()) -> WeatherSnapshot { slot.weather.aged(now: now) }
}

public struct PlanResult: Sendable {
    public let plan: TripPlan
    public let packingList: PackingList
}

/// Runs the §48.1 sequence locally: validate → wardrobe → weather → slots → candidates → cover → list.
public struct TripPlanner: Sendable {
    public let weather: any WeatherProvider
    public var generator = OutfitCandidateGenerator()
    public var optimizer = CapsuleOptimizer()

    public init(weather: any WeatherProvider) {
        self.weather = weather
    }

    public func plan(
        trip: Trip, wardrobe: Wardrobe, previous: TripPlan? = nil, previousList: PackingList? = nil, now: Date = Date()
    ) async -> PlanResult {
        let snapshots = await weather.snapshots(for: trip.destination, dates: trip.dates).map { $0.aged(now: now) }
        // Guard against providers returning dates in another order or extra days (T-TRV-030).
        let byDate = Dictionary(snapshots.filter { trip.dates.contains($0.localDate) }.map { ($0.localDate, $0) }, uniquingKeysWith: { a, _ in a })
        return replan(trip: trip, wardrobe: wardrobe, weatherByDate: byDate, previous: previous, previousList: previousList, now: now)
    }

    /// Synchronous core, also used to recompute from cached weather in airplane mode.
    public func replan(
        trip: Trip, wardrobe: Wardrobe, weatherByDate: [LocalDate: WeatherSnapshot],
        previous: TripPlan?, previousList: PackingList?, now: Date = Date()
    ) -> PlanResult {
        let slots = SlotBuilder.slots(for: trip, weather: weatherByDate)
        var candidates: [String: [OutfitCandidate]] = [:]
        for slot in slots { candidates[slot.id] = generator.candidates(for: slot, wardrobe: wardrobe) }

        // Keep locks whose pieces still exist and are plannable (T-TRV-061 invalidates the rest).
        var locked: [String: OutfitCandidate] = [:]
        for slotID in previous?.lockedSlotIDs ?? [] {
            guard let lock = previous?.solution.assignments[slotID], slots.contains(where: { $0.id == slotID }) else { continue }
            let stillOwned = lock.garmentIDs.allSatisfy { wardrobe.garment(id: $0)?.condition.isPlannable == true }
            if stillOwned { locked[slotID] = lock }
        }

        let solution = optimizer.solve(slots: slots, candidates: candidates, wardrobe: wardrobe, policy: trip.policy, locked: locked)
        let plan = TripPlan(
            tripID: trip.id, revision: (previous?.revision ?? 0) + 1, slots: slots, candidates: candidates,
            solution: solution, lockedSlotIDs: Set(locked.keys), weatherProvider: weather.name, generatedAt: now
        )
        let list = PackingListBuilder.build(trip: trip, solution: solution, slots: slots, wardrobe: wardrobe, previous: previousList)
        return PlanResult(plan: plan, packingList: list)
    }
}

extension TripPlanner {
    /// Rebuilds the packing list after a manual swap, keeping packed ticks and user rows.
    public static func packingList(trip: Trip, plan: TripPlan, wardrobe: Wardrobe, previous: PackingList?) -> PackingList {
        PackingListBuilder.build(trip: trip, solution: plan.solution, slots: plan.slots, wardrobe: wardrobe, previous: previous)
    }
}

extension TripPlan {
    /// User swaps one slot to another feasible candidate.
    public mutating func choose(_ candidate: OutfitCandidate) {
        guard candidates[candidate.slotID]?.contains(candidate) == true else { return }
        solution.assignments[candidate.slotID] = candidate
        solution.uncoveredSlotIDs.removeAll { $0 == candidate.slotID }
        revision += 1
    }

    public mutating func setLocked(_ locked: Bool, slotID: String) {
        guard solution.assignments[slotID] != nil else { return }
        if locked { lockedSlotIDs.insert(slotID) } else { lockedSlotIDs.remove(slotID) }
    }
}
