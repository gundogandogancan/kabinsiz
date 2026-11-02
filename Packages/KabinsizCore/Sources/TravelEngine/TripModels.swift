import DomainContracts
import Foundation

public enum TripState: String, Codable, CaseIterable, Sendable {
    case draft = "DRAFT", planned = "PLANNED", packing = "PACKING", departed = "DEPARTED"
    case inTrip = "IN_TRIP", returned = "RETURNED", archived = "ARCHIVED"

    /// Lifecycle from §41.4. Deletion is a repository action, not a state.
    public func canMove(to next: TripState) -> Bool {
        switch (self, next) {
        case (.draft, .planned), (.planned, .packing), (.packing, .departed), (.departed, .inTrip),
             (.inTrip, .returned), (.returned, .archived), (.planned, .draft), (.packing, .planned):
            true
        default:
            false
        }
    }
}

/// Activity presets from §41.1. Each carries conservative defaults the user can override per event.
public enum Activity: String, Codable, CaseIterable, Sendable {
    case cityWalk, business, formalEvent, beach, museum, dinner, hiking, sport, familyVisit, nightOut, rest, other

    public var displayName: String {
        switch self {
        case .cityWalk: "Gezi / yürüyüş"
        case .business: "İş / toplantı"
        case .formalEvent: "Resmi etkinlik"
        case .beach: "Sahil / havuz"
        case .museum: "Müze / şehir"
        case .dinner: "Akşam yemeği"
        case .hiking: "Doğa / trekking"
        case .sport: "Spor"
        case .familyVisit: "Aile ziyareti"
        case .nightOut: "Gece eğlencesi"
        case .rest: "Rahat dinlenme"
        case .other: "Diğer"
        }
    }

    public var defaultFormality: Formality {
        switch self {
        case .rest, .beach, .sport, .hiking: .relaxed
        case .cityWalk, .museum, .familyVisit, .other: .casual
        case .dinner, .nightOut, .business: .smart
        case .formalEvent: .formal
        }
    }

    public var defaultIndoors: IndoorsOutdoors {
        switch self {
        case .cityWalk, .beach, .hiking: .outdoors
        case .business, .dinner, .formalEvent, .rest: .indoors
        // A museum day still means walking there and between sites.
        case .museum, .sport, .familyVisit, .nightOut, .other: .mixed
        }
    }

    public var involvesLongWalking: Bool { self == .cityWalk || self == .hiking || self == .museum }
}

public enum IndoorsOutdoors: String, Codable, Sendable { case indoors = "INDOORS", outdoors = "OUTDOORS", mixed = "MIXED", unknown = "UNKNOWN" }

public enum TimeBlock: String, Codable, CaseIterable, Sendable, Comparable {
    case morning = "MORNING", afternoon = "AFTERNOON", evening = "EVENING", fullDay = "FULL_DAY"

    public static func < (lhs: Self, rhs: Self) -> Bool { allCases.firstIndex(of: lhs)! < allCases.firstIndex(of: rhs)! }

    public var displayName: String {
        switch self {
        case .morning: "Sabah"
        case .afternoon: "Öğleden sonra"
        case .evening: "Akşam"
        case .fullDay: "Tüm gün"
        }
    }
}

public struct TripEvent: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public var localDate: LocalDate
    public var timeBlock: TimeBlock
    public var activity: Activity
    public var formality: Formality
    public var indoorsOutdoors: IndoorsOutdoors
    /// Dress code exactly as the user typed it from an invitation (§43.1 level 1). Never generated.
    public var userDressCode: String?

    public init(
        id: String, localDate: LocalDate, timeBlock: TimeBlock, activity: Activity,
        formality: Formality? = nil, indoorsOutdoors: IndoorsOutdoors? = nil, userDressCode: String? = nil
    ) {
        self.id = id
        self.localDate = localDate
        self.timeBlock = timeBlock
        self.activity = activity
        self.formality = formality ?? activity.defaultFormality
        self.indoorsOutdoors = indoorsOutdoors ?? activity.defaultIndoors
        self.userDressCode = userDressCode
    }
}

public enum BagType: String, Codable, CaseIterable, Sendable {
    case cabin = "CABIN", checked = "CHECKED", other = "OTHER", unknown = "UNKNOWN"

    public var displayName: String {
        switch self {
        case .cabin: "Kabin valizi"
        case .checked: "Bagaj"
        case .other: "Diğer"
        case .unknown: "Bilmiyorum"
        }
    }
}

public enum LaundryAccess: String, Codable, CaseIterable, Sendable {
    case yes = "YES", no = "NO", unknown = "UNKNOWN"

    public var displayName: String {
        switch self {
        case .yes: "Var"
        case .no: "Yok"
        case .unknown: "Bilmiyorum"
        }
    }
}

public enum PackingPreference: String, Codable, CaseIterable, Sendable {
    case light = "LIGHT", balanced = "BALANCED", variety = "VARIETY"

    public var displayName: String {
        switch self {
        case .light: "Hafif valiz"
        case .balanced: "Dengeli"
        case .variety: "Daha çok çeşit"
        }
    }
}

public struct PackingPolicy: Codable, Hashable, Sendable {
    public var bagType: BagType
    /// Only what the user entered. Carrier allowances are never assumed (T-TRV-055).
    public var maxWeightKg: Double?
    public var laundryAccess: LaundryAccess
    public var preference: PackingPreference
    /// User override of "how many days may one piece be worn". `nil` uses `defaultRewearDays`.
    public var rewearDaysByCategory: [GarmentCategory: Int]
    /// Socks/underlayer sets; `nil` = one per day.
    public var underlayerSets: Int?

    public init(
        bagType: BagType = .unknown, maxWeightKg: Double? = nil, laundryAccess: LaundryAccess = .unknown,
        preference: PackingPreference = .balanced, rewearDaysByCategory: [GarmentCategory: Int] = [:], underlayerSets: Int? = nil
    ) {
        self.bagType = bagType
        self.maxWeightKg = maxWeightKg
        self.laundryAccess = laundryAccess
        self.preference = preference
        self.rewearDaysByCategory = rewearDaysByCategory
        self.underlayerSets = underlayerSets
    }

    /// Conservative defaults per category. Underlayers are never reused across days.
    public func rewearDays(for category: GarmentCategory) -> Int {
        if let override = rewearDaysByCategory[category] { return max(1, override) }
        let base: Int
        switch category {
        case .underlayer, .swimwear, .activewear: base = 1
        case .top: base = preference == .variety ? 1 : 2
        case .dress: base = preference == .light ? 2 : 1
        case .bottom: base = preference == .light ? 4 : (preference == .balanced ? 3 : 2)
        case .outerwear, .shoes, .accessory, .weatherProtection, .sleepwear: base = 99
        }
        return laundryAccess == .yes && base < 99 && category != .underlayer ? base * 2 : base
    }
}

public struct Trip: Codable, Hashable, Identifiable, Sendable {
    public static let schemaVersion = 1

    public let id: String
    public var title: String
    public var state: TripState
    public var destination: Destination
    public var dates: [LocalDate]
    public var events: [TripEvent]
    public var policy: PackingPolicy
    /// Demo trips built from synthetic fixtures carry this flag into every screen (§56).
    public var isSyntheticDemo: Bool
    public var createdAt: Date
    public var lastEditedAt: Date
    public var revision: Int

    public init(
        id: String, title: String, destination: Destination, dates: [LocalDate], events: [TripEvent],
        policy: PackingPolicy, isSyntheticDemo: Bool, now: Date = Date()
    ) {
        self.id = id
        self.title = title
        state = .draft
        self.destination = destination
        self.dates = dates
        self.events = events
        self.policy = policy
        self.isSyntheticDemo = isSyntheticDemo
        createdAt = now
        lastEditedAt = now
        revision = 1
    }
}
