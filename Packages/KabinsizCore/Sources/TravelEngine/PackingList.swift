import DomainContracts
import Foundation
import WardrobeDomain

public enum PackingItemSource: String, Codable, Sendable {
    case owned = "OWNED", userEntered = "USER_ENTERED", genericNeed = "GENERIC_NEED"
}

public struct PackingListItem: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public var garmentID: String?
    public var title: String
    public var category: GarmentCategory
    public var quantity: Int
    public var assignedSlotIDs: [String]
    /// Copied from the wardrobe; `UNKNOWN` stays unknown (§45.3).
    public var condition: ItemCondition
    /// Only the user ticks this. The planner never sets it (§47 invariants).
    public var isPacked: Bool
    public var weightKg: Double?
    /// Not owned: a need the closet cannot cover. Shown as a gap, never as a possession.
    public var missing: Bool
    public var userEdited: Bool
    public var source: PackingItemSource
}

public struct PackingList: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public var tripID: String
    public var items: [PackingListItem]

    public var grouped: [(GarmentCategory, [PackingListItem])] {
        Dictionary(grouping: items, by: \.category).sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }

    public var packedCount: Int { items.filter(\.isPacked).count }

    /// Total only when every packed-to-be item has a measured weight; otherwise `nil` (T-TRV-053).
    public var knownTotalWeightKg: Double? {
        let carried = items.filter { !$0.missing }
        guard !carried.isEmpty, carried.allSatisfy({ $0.weightKg != nil }) else { return nil }
        return carried.reduce(0) { $0 + $1.weightKg! * Double($1.quantity) }
    }

    public var weighedItemCount: Int { items.filter { !$0.missing && $0.weightKg != nil }.count }

    /// `true`/`false` only when both the limit and the full weight are known (T-TRV-054/055).
    public func exceedsLimit(_ maxKg: Double?) -> Bool? {
        guard let maxKg, let total = knownTotalWeightKg else { return nil }
        return total > maxKg
    }

    public mutating func setPacked(_ packed: Bool, itemID: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].isPacked = packed
    }

    public mutating func setQuantity(_ quantity: Int, itemID: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].quantity = max(0, quantity)
        items[index].userEdited = true
    }

    /// The user weighed this row (per unit). `nil` clears it back to unknown.
    public mutating func setWeight(_ kg: Double?, itemID: String) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[index].weightKg = kg.map { max(0, $0) }
        items[index].userEdited = true
    }

    /// Plan no longer uses this packed piece; the user decides whether to take it out.
    public func isUnplannedButPacked(_ item: PackingListItem) -> Bool {
        item.source == .owned && item.garmentID != nil && item.assignedSlotIDs.isEmpty && item.category != .underlayer && item.category != .sleepwear
    }

    /// Adds something the user wants in the bag regardless of the plan (T-TRV-066).
    public mutating func addManual(title: String, category: GarmentCategory, quantity: Int = 1) {
        let id = "manual-\(UUID().uuidString)"
        items.append(PackingListItem(
            id: id, garmentID: nil, title: title, category: category, quantity: max(1, quantity), assignedSlotIDs: [],
            condition: .unknown, isPacked: false, weightKg: nil, missing: false, userEdited: true, source: .userEntered
        ))
    }
}

enum PackingListBuilder {
    /// One row per owned garment, however many outfits use it (T-TRV-047). User edits and packed ticks
    /// from `previous` survive a rebuild so a replan never unpacks the bag.
    static func build(
        trip: Trip, solution: CapsuleSolution, slots: [OutfitSlot], wardrobe: Wardrobe, previous: PackingList?
    ) -> PackingList {
        var slotsByGarment: [String: [String]] = [:]
        for (slotID, candidate) in solution.assignments {
            for id in candidate.garmentIDs { slotsByGarment[id, default: []].append(slotID) }
        }
        let old = Dictionary(uniqueKeysWithValues: (previous?.items ?? []).map { ($0.id, $0) })

        var items: [PackingListItem] = slotsByGarment.keys.sorted().compactMap { garmentID in
            guard let garment = wardrobe.garment(id: garmentID) else { return nil }
            let id = "owned-\(garmentID)"
            return PackingListItem(
                id: id, garmentID: garmentID, title: garment.name, category: garment.category, quantity: 1,
                assignedSlotIDs: slotsByGarment[garmentID]!.sorted(), condition: garment.condition,
                isPacked: old[id]?.isPacked ?? false, weightKg: old[id]?.weightKg ?? garment.weightKg, missing: false,
                userEdited: old[id]?.userEdited ?? false, source: .owned
            )
        }

        // A packed piece the plan no longer uses stays on the list until the user unticks it (G-TRV-REPLAN).
        let present = Set(items.map(\.id))
        for row in previous?.items ?? [] where row.source == .owned && row.isPacked && row.garmentID != nil && !present.contains(row.id)
            && !row.id.hasPrefix("need-") {
            var kept = row
            kept.assignedSlotIDs = []
            if let garment = wardrobe.garment(id: row.garmentID!) { kept.condition = garment.condition; kept.weightKg = kept.weightKg ?? garment.weightKg }
            items.append(kept)
        }

        // Underlayers: one set per day unless laundry is available or the user chose a number.
        let days = trip.dates.count
        let defaultSets = trip.policy.laundryAccess == .yes ? min(days, 4) : days
        let sets = trip.policy.underlayerSets ?? defaultSets
        let ownedUnder = wardrobe.garments(in: .underlayer).first
        let underID = "need-underlayer"
        items.append(PackingListItem(
            id: underID, garmentID: ownedUnder?.id, title: "Çorap ve iç çamaşırı", category: .underlayer,
            quantity: old[underID]?.userEdited == true ? old[underID]!.quantity : sets, assignedSlotIDs: [],
            condition: ownedUnder?.condition ?? .unknown, isPacked: old[underID]?.isPacked ?? false,
            weightKg: old[underID]?.weightKg ?? ownedUnder?.weightKg,
            missing: ownedUnder == nil, userEdited: old[underID]?.userEdited ?? false,
            source: ownedUnder == nil ? .genericNeed : .owned
        ))

        let sleep = wardrobe.garments(in: .sleepwear).first
        let sleepID = "need-sleepwear"
        items.append(PackingListItem(
            id: sleepID, garmentID: sleep?.id, title: sleep?.name ?? "Pijama", category: .sleepwear, quantity: 1,
            assignedSlotIDs: [], condition: sleep?.condition ?? .unknown, isPacked: old[sleepID]?.isPacked ?? false,
            weightKg: old[sleepID]?.weightKg ?? sleep?.weightKg, missing: sleep == nil, userEdited: false, source: sleep == nil ? .genericNeed : .owned
        ))

        // Keep rows the user added by hand.
        items += (previous?.items ?? []).filter { $0.source == .userEntered }
        return PackingList(tripID: trip.id, items: items)
    }
}
