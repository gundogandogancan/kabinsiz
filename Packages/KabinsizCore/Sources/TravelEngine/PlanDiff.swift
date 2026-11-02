import Foundation

public enum PlanChangeReason: String, Codable, Sendable {
    case weather = "WEATHER", schedule = "SCHEDULE", garment = "GARMENT", userEdit = "USER_EDIT", sourceChanged = "SOURCE_CHANGED"
}

public struct PlanChange: Codable, Hashable, Sendable {
    public let slotID: String
    public let reason: PlanChangeReason
    public let before: [String]
    public let after: [String]
}

/// What a replan would change. Applied only after the user approves (§42.4, T-TRV-062).
public struct TripPlanDiff: Codable, Hashable, Sendable {
    public let oldRevision: Int
    public let newRevision: Int
    public let changes: [PlanChange]
    /// Packed pieces the new plan no longer needs. They stay in the bag until the user unticks them.
    public let packedButNoLongerNeeded: [String]
    public let requiresApproval: Bool

    public var isEmpty: Bool { changes.isEmpty }

    public static func between(
        old: TripPlan, new: TripPlan, packedGarmentIDs: Set<String>, reason: PlanChangeReason
    ) -> TripPlanDiff {
        let slotIDs = Set(old.solution.assignments.keys).union(new.solution.assignments.keys).sorted()
        var changes: [PlanChange] = []
        for id in slotIDs {
            let before = old.solution.assignments[id]?.garmentIDs ?? []
            let after = new.solution.assignments[id]?.garmentIDs ?? []
            if before != after { changes.append(PlanChange(slotID: id, reason: reason, before: before, after: after)) }
        }
        let dropped = packedGarmentIDs.subtracting(new.solution.packedGarmentIDs).sorted()
        let touchesLock = changes.contains { old.lockedSlotIDs.contains($0.slotID) }
        return TripPlanDiff(
            oldRevision: old.revision, newRevision: new.revision, changes: changes,
            packedButNoLongerNeeded: dropped, requiresApproval: !changes.isEmpty || touchesLock || !dropped.isEmpty
        )
    }
}
