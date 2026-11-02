import DomainContracts
import Foundation
import WardrobeDomain

/// Chosen outfit per slot plus everything that could not be covered (ADR-003).
public struct CapsuleSolution: Codable, Hashable, Sendable {
    public var assignments: [String: OutfitCandidate]
    public var uncoveredSlotIDs: [String]

    public var packedGarmentIDs: Set<String> { Set(assignments.values.flatMap(\.garmentIDs)) }
    public var isFeasible: Bool { uncoveredSlotIDs.isEmpty }
}

/// Deterministic set-cover planner: locks first, greedy by scarcity, then local repair.
public struct CapsuleOptimizer: Sendable {
    public var maxRepairPasses = 6

    public init() {}

    public func solve(
        slots: [OutfitSlot],
        candidates: [String: [OutfitCandidate]],
        wardrobe: Wardrobe,
        policy: PackingPolicy,
        locked: [String: OutfitCandidate] = [:]
    ) -> CapsuleSolution {
        let limits = RewearLimits(wardrobe: wardrobe, policy: policy)
        var assignment: [String: OutfitCandidate] = [:]
        var uncovered: [String] = []

        // Locked outfits are the user's decision and are kept even if they break a reuse default (T-TRV-046).
        for slot in slots { if let lock = locked[slot.id] { assignment[slot.id] = lock } }

        let open = slots.filter { locked[$0.id] == nil }.sorted { a, b in
            let ca = candidates[a.id]?.count ?? 0, cb = candidates[b.id]?.count ?? 0
            return ca != cb ? ca < cb : a.id < b.id
        }
        for slot in open {
            let options = candidates[slot.id] ?? []
            let byCost: (OutfitCandidate, OutfitCandidate) -> Bool = { lhs, rhs in
                cost(lhs, assignment: assignment, policy: policy) < cost(rhs, assignment: assignment, policy: policy)
            }
            if let chosen = options.filter({ limits.allows($0, in: slot, assignment: assignment, slots: slots, locked: locked) }).min(by: byCost) {
                assignment[slot.id] = chosen
            } else if let fallback = options.min(by: byCost) {
                // The closet can dress this slot, only not within the reuse preference. Say so honestly
                // instead of reporting a false "nothing fits" gap that nudges toward buying.
                assignment[slot.id] = fallback.adding(gap: "Bir parçayı tercihinden fazla tekrar giymen gerekiyor")
            } else {
                uncovered.append(slot.id)
            }
        }

        // Local repair: swap one slot at a time while it strictly lowers the number of packed pieces.
        // Skipped for "variety", where a bigger bag is the user's stated choice (T-TRV-056).
        for _ in 0..<(policy.preference == .variety ? 0 : maxRepairPasses) {
            var improved = false
            for slot in open where assignment[slot.id] != nil {
                let current = uniqueCount(assignment)
                for option in candidates[slot.id] ?? [] where option != assignment[slot.id] {
                    var trial = assignment
                    trial[slot.id] = option
                    guard uniqueCount(trial) < current, limits.valid(trial, slots: slots, locked: locked) else { continue }
                    assignment = trial
                    improved = true
                    break
                }
            }
            if !improved { break }
        }
        return CapsuleSolution(assignments: assignment, uncoveredSlotIDs: uncovered.sorted())
    }

    /// Lexicographic cost: new pieces added, then gaps, then preference-specific tie-breaks, then ID.
    private func cost(_ c: OutfitCandidate, assignment: [String: OutfitCandidate], policy: PackingPolicy) -> Cost {
        let packed = Set(assignment.values.flatMap(\.garmentIDs))
        let newPieces = c.garmentIDs.filter { !packed.contains($0) }.count
        let reuse = c.garmentIDs.filter { packed.contains($0) }.count
        let preferenceKey: Int
        switch policy.preference {
        case .light: preferenceKey = -reuse
        case .balanced: preferenceKey = 0
        case .variety: preferenceKey = reuse
        }
        // Variety trades a larger bag for fewer repeats, so it weighs new pieces less.
        let pieceKey = policy.preference == .variety ? 0 : newPieces
        return Cost(pieces: pieceKey, gaps: c.gaps.count, preference: preferenceKey, style: -c.styleScore, newPieces: newPieces, id: c.id)
    }

    private struct Cost: Comparable {
        let pieces, gaps, preference, style, newPieces: Int
        let id: String
        static func < (a: Cost, b: Cost) -> Bool {
            (a.pieces, a.gaps, a.preference, a.style, a.newPieces, a.id) < (b.pieces, b.gaps, b.preference, b.style, b.newPieces, b.id)
        }
    }
}

func uniqueCount(_ assignment: [String: OutfitCandidate]) -> Int {
    Set(assignment.values.flatMap(\.garmentIDs)).count
}

/// Enforces "how many different days may this piece be worn" per category (§45.4).
struct RewearLimits {
    let categoryByID: [String: GarmentCategory]
    let policy: PackingPolicy

    init(wardrobe: Wardrobe, policy: PackingPolicy) {
        categoryByID = Dictionary(uniqueKeysWithValues: wardrobe.garments.map { ($0.id, $0.category) })
        self.policy = policy
    }

    /// A lock may push a piece over its limit only by the days the lock itself covers; every other use still counts.
    func allows(_ c: OutfitCandidate, in slot: OutfitSlot, assignment: [String: OutfitCandidate], slots: [OutfitSlot], locked: [String: OutfitCandidate]) -> Bool {
        var trial = assignment
        trial[slot.id] = c
        return valid(trial, slots: slots, locked: locked)
    }

    func valid(_ assignment: [String: OutfitCandidate], slots: [OutfitSlot], locked: [String: OutfitCandidate]) -> Bool {
        let dayBySlot = Dictionary(uniqueKeysWithValues: slots.map { ($0.id, $0.dayIndex) })
        var days: [String: Set<Int>] = [:]
        var lockedDays: [String: Set<Int>] = [:]
        for (slotID, c) in assignment {
            guard let day = dayBySlot[slotID] else { continue }
            for id in c.garmentIDs { days[id, default: []].insert(day) }
            if locked[slotID] == c { for id in c.garmentIDs { lockedDays[id, default: []].insert(day) } }
        }
        for (id, used) in days {
            guard let category = categoryByID[id] else { return false }
            let allowed = max(policy.rewearDays(for: category), lockedDays[id]?.count ?? 0)
            if used.count > allowed { return false }
        }
        return true
    }
}

/// Exhaustive reference for small fixtures only (T-TRV-043). Not used in the app.
public enum BruteForceCapsuleSolver {
    public static func minimumUniquePieces(
        slots: [OutfitSlot], candidates: [String: [OutfitCandidate]], wardrobe: Wardrobe, policy: PackingPolicy
    ) -> Int? {
        let limits = RewearLimits(wardrobe: wardrobe, policy: policy)
        let ordered = slots.sorted { $0.id < $1.id }
        var best: Int?
        func walk(_ index: Int, _ assignment: [String: OutfitCandidate]) {
            if let best, uniqueCount(assignment) >= best { return }
            if index == ordered.count {
                if limits.valid(assignment, slots: slots, locked: [:]) { best = uniqueCount(assignment) }
                return
            }
            let slot = ordered[index]
            for option in candidates[slot.id] ?? [] {
                var next = assignment
                next[slot.id] = option
                walk(index + 1, next)
            }
        }
        walk(0, [:])
        return best
    }
}
