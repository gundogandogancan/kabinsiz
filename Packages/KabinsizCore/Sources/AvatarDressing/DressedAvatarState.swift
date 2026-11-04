import Foundation

/// What the user asked the figure to do (v2.5 §9 OutfitChangeRequestV1).
public struct OutfitChangeRequest: Codable, Hashable, Sendable {
    public enum Action: Codable, Hashable, Sendable {
        /// Put this piece on its slot; the other slots stay as they are.
        case replace(DressItem)
        /// Take a slot off. Any slot may come off (dress-up, user decision 2026-11-04); undo puts it
        /// back. The figure underneath is the neutral mannequin body, never a person's skin.
        case remove(GarmentSlotID)
        /// Show a whole look (new outfit, reroll).
        case wear(DressedOutfit)
        case undo
        case redo
    }

    public let commandID: UUID
    public let action: Action
    /// The revision the request was made against. A result that arrives after a newer change was
    /// applied is refused, so a slow load never puts an older look back (§9 anti-race).
    public let basedOnRevision: Int

    public init(commandID: UUID = UUID(), action: Action, basedOnRevision: Int) {
        self.commandID = commandID
        self.action = action
        self.basedOnRevision = basedOnRevision
    }
}

public enum DressingRefusal: String, Error, Codable, Sendable, Equatable {
    case staleRevision = "STALE_REVISION"
    case nothingToUndo = "NOTHING_TO_UNDO"
    case nothingToRedo = "NOTHING_TO_REDO"
    /// Kept for decoding old records; no slot is required since 2026-11-04.
    case requiredSlot = "REQUIRED_SLOT"
    /// Taking off a slot that is already empty changes nothing and is not put in the history.
    case emptySlot = "EMPTY_SLOT"
    case duplicateCommand = "DUPLICATE_COMMAND"
}

/// The look on the figure, with its history. Pure value: the app holds one and applies requests.
/// Undo restores the full slot state; redo is cleared by any new change.
public struct DressedAvatarState: Codable, Hashable, Sendable {
    public private(set) var outfit: DressedOutfit
    public private(set) var revision: Int
    private var past: [DressedOutfit] = []
    private var future: [DressedOutfit] = []
    private var applied: [UUID] = []
    /// Undo depth kept on the device (local history only).
    public static let historyLimit = 30

    public init(outfit: DressedOutfit = DressedOutfit([]), revision: Int = 0) {
        self.outfit = outfit
        self.revision = revision
    }

    public var canUndo: Bool { !past.isEmpty }
    public var canRedo: Bool { !future.isEmpty }

    @discardableResult
    public mutating func apply(_ request: OutfitChangeRequest) throws(DressingRefusal) -> DressedOutfit {
        guard !applied.contains(request.commandID) else { throw .duplicateCommand }
        guard request.basedOnRevision == revision else { throw .staleRevision }
        let next: DressedOutfit
        switch request.action {
        case let .replace(item):
            next = outfit.replacing(item)
        case let .remove(slot):
            guard outfit[slot] != nil else { throw .emptySlot }
            next = outfit.removing(slot)
        case let .wear(look):
            next = look
        case .undo:
            guard let previous = past.popLast() else { throw .nothingToUndo }
            future.append(outfit)
            commit(previous, request)
            return outfit
        case .redo:
            guard let following = future.popLast() else { throw .nothingToRedo }
            past.append(outfit)
            commit(following, request)
            return outfit
        }
        past.append(outfit)
        if past.count > Self.historyLimit { past.removeFirst(past.count - Self.historyLimit) }
        future.removeAll()
        commit(next, request)
        return outfit
    }

    private mutating func commit(_ look: DressedOutfit, _ request: OutfitChangeRequest) {
        outfit = look
        revision += 1
        applied.append(request.commandID)
        if applied.count > 64 { applied.removeFirst(applied.count - 64) }
    }
}
