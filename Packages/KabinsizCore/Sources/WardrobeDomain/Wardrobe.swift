import DomainContracts
import Foundation

/// The user's local closet. Pure value; persistence lives in the app's repository.
public struct Wardrobe: Codable, Hashable, Sendable {
    public static let schemaVersion = 1

    public private(set) var garments: [Garment]

    public init(garments: [Garment] = []) {
        self.garments = garments.sorted { $0.id < $1.id }
    }

    public var isEmpty: Bool { garments.isEmpty }

    public func garment(id: String) -> Garment? { garments.first { $0.id == id } }

    public func garments(in category: GarmentCategory) -> [Garment] {
        garments.filter { $0.category == category }
    }

    /// Inserts or replaces by ID, so re-adding the same garment never duplicates it (T-TRV-060).
    public mutating func upsert(_ garment: Garment) {
        if let index = garments.firstIndex(where: { $0.id == garment.id }) {
            garments[index] = garment
        } else {
            garments.append(garment)
            garments.sort { $0.id < $1.id }
        }
    }

    public mutating func remove(id: String) {
        garments.removeAll { $0.id == id }
    }

    public mutating func setCondition(_ condition: ItemCondition, for id: String) {
        guard let index = garments.firstIndex(where: { $0.id == id }) else { return }
        garments[index].condition = condition
    }
}
