import BodyGeometry
import DomainContracts
import Foundation

/// Where on the figure a piece is worn (v2.5 §5.1). One piece per slot; layers come from the slot.
public enum GarmentSlotID: String, Codable, CaseIterable, Sendable, Comparable {
    case top = "TOP", bottom = "BOTTOM", outerwear = "OUTERWEAR", dress = "DRESS", footwear = "FOOTWEAR"
    case bag = "BAG", belt = "BELT", eyewear = "EYEWEAR", headwear = "HEADWEAR", jewelry = "JEWELRY"
    case otherAccessory = "OTHER_ACCESSORY"

    public static func < (lhs: Self, rhs: Self) -> Bool { allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)! }

    public var displayName: String {
        switch self {
        case .top: "Üst"
        case .bottom: "Alt"
        case .outerwear: "Dış giyim"
        case .dress: "Elbise"
        case .footwear: "Ayakkabı"
        case .bag: "Çanta"
        case .belt: "Kemer"
        case .eyewear: "Gözlük"
        case .headwear: "Şapka"
        case .jewelry: "Takı"
        case .otherAccessory: "Aksesuar"
        }
    }

    /// SF Symbol for the slot rail.
    public var symbol: String {
        switch self {
        case .top: "tshirt"
        case .bottom: "figure.walk"
        case .outerwear: "jacket"
        case .dress: "figure.stand.dress"
        case .footwear: "shoe"
        case .bag: "bag"
        case .belt: "line.3.horizontal"
        case .eyewear: "eyeglasses"
        case .headwear: "hat.widebrim"
        case .jewelry: "sparkle"
        case .otherAccessory: "scarf"
        }
    }

    /// Wardrobe category each slot is filled from.
    public var categories: [GarmentCategory] {
        switch self {
        case .top: [.top]
        case .bottom: [.bottom]
        case .outerwear: [.outerwear, .weatherProtection]
        case .dress: [.dress]
        case .footwear: [.shoes]
        case .bag, .belt, .eyewear, .headwear, .jewelry, .otherAccessory: [.accessory]
        }
    }
}

/// How truthful a picture of a garment is (v2.5 §5.2). Presenting T0/T1 as T2/T3 is STOP_THE_LINE.
public enum VisualTruthTier: String, Codable, CaseIterable, Sendable, Comparable {
    /// Bare form, no garment.
    case t0 = "T0_FORM"
    /// Category-level original garment: colour and silhouette approximate, "temsili".
    case t1 = "T1_REPRESENTATIVE"
    /// Licensed or user-made asset for this exact SKU and colour.
    case t2 = "T2_SKU_ASSET"
    /// Calibrated fabric and measurements.
    case t3 = "T3_CALIBRATED"
    /// Generative image or video (cloud VTON): photoreal, never a fit proof.
    case t4 = "T4_GENERATIVE"

    public static func < (lhs: Self, rhs: Self) -> Bool { allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)! }

    public var label: String {
        switch self {
        case .t0: "Kıyafetsiz form"
        case .t1: "Temsili 3B giysi: renk ve biçim yaklaşık, ürünün kendisi değil"
        case .t2: "Ürüne özel 3B model"
        case .t3: "Kalibre kumaş ve ölçü"
        case .t4: "Yapay zekâ görüntüsü: beden kanıtı değildir"
        }
    }

    /// No tier makes a size or fit statement; fit evidence is a separate line (§6.4 Precision Fit).
    public var mayInformSizeAdvice: Bool { false }
}

/// One piece as it is drawn on the figure.
public struct DressItem: Codable, Hashable, Sendable, Identifiable {
    /// The wardrobe garment (or catalogue product) this picture stands for.
    public let id: String
    public let name: String
    public let slot: GarmentSlotID
    public let form: GarmentForm
    /// sRGB 0xRRGGBB, from the garment's colour name. Approximate by definition.
    public let colorHex: UInt32
    public let colorName: String
    public let tier: VisualTruthTier
    public let provenance: Provenance

    public init(id: String, name: String, slot: GarmentSlotID, form: GarmentForm, colorHex: UInt32, colorName: String,
                tier: VisualTruthTier = .t1, provenance: Provenance) {
        self.id = id
        self.name = name
        self.slot = slot
        self.form = form
        self.colorHex = colorHex
        self.colorName = colorName
        self.tier = tier
        self.provenance = provenance
    }
}

/// A full look: at most one piece per slot.
public struct DressedOutfit: Codable, Hashable, Sendable, Identifiable {
    public let items: [GarmentSlotID: DressItem]

    public init(_ items: [DressItem]) {
        var map: [GarmentSlotID: DressItem] = [:]
        for item in items { map[item.slot] = item }
        // A dress replaces separate top and bottom.
        if map[.dress] != nil {
            map[.top] = nil
            map[.bottom] = nil
        }
        self.items = map
    }

    /// Stable identity: the sorted garment IDs, so the same pieces are the same outfit.
    public var id: String { items.values.map(\.id).sorted().joined(separator: "+") }
    public var isEmpty: Bool { items.isEmpty }
    public var isSynthetic: Bool { !items.isEmpty && items.values.allSatisfy { $0.provenance.isSynthetic } }
    /// The weakest tier on the figure is the tier of the whole picture.
    public var tier: VisualTruthTier { items.values.map(\.tier).min() ?? .t0 }
    public var slots: [GarmentSlotID] { items.keys.sorted() }
    public subscript(slot: GarmentSlotID) -> DressItem? { items[slot] }

    public func replacing(_ item: DressItem) -> DressedOutfit {
        var all = items
        all[item.slot] = item
        if item.slot == .top || item.slot == .bottom { all[.dress] = nil }
        return DressedOutfit(Array(all.values))
    }

    public func removing(_ slot: GarmentSlotID) -> DressedOutfit {
        var all = items
        all[slot] = nil
        return DressedOutfit(Array(all.values))
    }
}
