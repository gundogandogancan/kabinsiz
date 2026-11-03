import AvatarDressing
import Foundation
import LivingWorld
import TodayOutfit
import TravelEngine
import WardrobeDomain

// v2.8 §05 "Sabah hazır": the day's three looks are prepared on the device and kept in a versioned
// cache, so the home opens on a dressed figure instead of a spinner. Background refresh is only
// opportunistic; nothing here promises a look at 06:00.

// MARK: City time

extension SceneCity {
    /// The city's own clock. The day the looks are for is the day in the chosen city, not on the
    /// device (UI28-T002). The studio has no city, so it follows the device.
    public func timeZone(device: TimeZone = .current) -> TimeZone {
        switch self {
        case .istanbul: TimeZone(identifier: "Europe/Istanbul") ?? device
        case .barcelona: TimeZone(identifier: "Europe/Madrid") ?? device
        case .studio: device
        }
    }
}

// MARK: Weather

/// One weather reading from a consented provider. Never constructed from a guess.
public struct CityWeatherReading: Codable, Hashable, Sendable {
    public let city: SceneCity
    public let condition: SceneCondition
    /// Only when the provider gave one; the chip never shows a temperature that was not measured.
    public let temperatureC: Double?
    public let source: String
    public let observedAt: Date

    public init(city: SceneCity, condition: SceneCondition, temperatureC: Double?, source: String, observedAt: Date) {
        self.city = city
        self.condition = condition
        self.temperatureC = temperatureC
        self.source = source
        self.observedAt = observedAt
    }
}

/// How current the weather on screen is (v2.8 H01/H05, UI28-T008/T009).
public enum WeatherFreshness: Hashable, Sendable {
    /// Within its time-to-live: the scene may draw it.
    case live(CityWeatherReading)
    /// Older than its time-to-live: shown as text with its time, never drawn as current rain.
    case lastKnown(CityWeatherReading)
    /// No reading for this city.
    case none

    public static let defaultTTL: TimeInterval = 3 * 3600

    public static func classify(_ snapshot: CityWeatherReading?, city: SceneCity, now: Date, ttl: TimeInterval = defaultTTL) -> WeatherFreshness {
        guard let snapshot, snapshot.city == city else { return .none }
        return now.timeIntervalSince(snapshot.observedAt) <= ttl ? .live(snapshot) : .lastKnown(snapshot)
    }

    /// Only live rain reaches the scene; a stale or missing reading draws a dry street.
    public var sceneEvidence: SceneWeatherEvidence {
        switch self {
        case let .live(s): .observed(s.condition, source: s.source, at: s.observedAt)
        case .lastKnown, .none: .none
        }
    }

    /// Part of the cache key: a new reading (or the loss of one) makes the cached plan stale.
    public var cacheKey: String {
        switch self {
        case let .live(s): "LIVE:\(s.condition.rawValue):\(Int(s.observedAt.timeIntervalSince1970 / 3600))"
        case .lastKnown, .none: "NONE"
        }
    }

    public var isLiveRain: Bool {
        if case let .live(s) = self { return s.condition == .rain }
        return false
    }
}

/// The top-right chip of the home: city, and weather only as far as there is evidence for it.
public struct WeatherChipText: Hashable, Sendable {
    /// Short line on the chip, e.g. "İstanbul · 12° · Yağmur" or "İstanbul · Hava verisi yok".
    public let title: String
    /// Provenance shown under the chip or read by VoiceOver.
    public let provenance: String
    public let state: State

    /// The title without the city, for a two-line chip ("Hava verisi yok", "12° · Yağmur").
    public var weatherLine: String {
        let parts = title.components(separatedBy: " · ")
        return parts.dropFirst().joined(separator: " · ")
    }

    public enum State: String, Sendable { case live, lastKnown, noData, preview }

    /// `placeName` replaces the scene city's name when the home shows another place (a world street).
    public static func make(city: SceneCity, freshness: WeatherFreshness, preview: SceneCondition? = nil, placeName: String? = nil) -> WeatherChipText {
        let name = placeName ?? city.displayName
        if let preview {
            let word = preview == .rain ? "Yağmur" : "Açık"
            return WeatherChipText(title: "\(name) · \(word) önizlemesi", provenance: "Önizleme · gerçek hava değil", state: .preview)
        }
        switch freshness {
        case .none:
            return WeatherChipText(title: "\(name) · Hava verisi yok", provenance: "Hava kaynağı bağlı değil", state: .noData)
        case let .live(s):
            return WeatherChipText(title: ([name] + reading(s)).joined(separator: " · "),
                                   provenance: "\(s.source) · \(clock(s.observedAt, city))", state: .live)
        case let .lastKnown(s):
            return WeatherChipText(title: ([name] + reading(s)).joined(separator: " · "),
                                   provenance: "Son bilinen tahmin · \(clock(s.observedAt, city)) · \(s.source)", state: .lastKnown)
        }
    }

    private static func reading(_ s: CityWeatherReading) -> [String] {
        var parts: [String] = []
        if let t = s.temperatureC { parts.append("\(Int(t.rounded()))°") }
        parts.append(s.condition == .rain ? "Yağmur" : "Açık")
        return parts
    }

    private static func clock(_ date: Date, _ city: SceneCity) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = city.timeZone()
        let c = calendar.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d.%02d", c.hour ?? 0, c.minute ?? 0)
    }
}

/// Where weather comes from. No provider is connected in this build (WeatherKit needs the Apple
/// developer agreement and a capability: BLOCKED_EXTERNAL), so the default returns nothing.
public protocol WeatherGateway: Sendable {
    func latest(for city: SceneCity) async -> CityWeatherReading?
}

public struct NoWeatherGateway: WeatherGateway {
    public init() {}
    public func latest(for city: SceneCity) async -> CityWeatherReading? { nil }
}

// MARK: Cache key and plan

/// Everything a day's plan depends on. Any change makes the cached plan stale (v2.8 §05.2).
public struct OutfitCacheKey: Codable, Hashable, Sendable {
    public let cityID: SceneCity
    public let localDate: LocalDate
    public let timeZoneID: String
    public let wardrobeRevision: String
    public let avatarRevision: String
    public let preferencesRevision: String
    public let weatherKey: String
    public let modelVersion: String

    public static let currentModelVersion = "today-engine-1+planner-1"

    public init(cityID: SceneCity, localDate: LocalDate, timeZoneID: String, wardrobeRevision: String, avatarRevision: String,
                preferencesRevision: String, weatherKey: String, modelVersion: String = currentModelVersion) {
        self.cityID = cityID
        self.localDate = localDate
        self.timeZoneID = timeZoneID
        self.wardrobeRevision = wardrobeRevision
        self.avatarRevision = avatarRevision
        self.preferencesRevision = preferencesRevision
        self.weatherKey = weatherKey
        self.modelVersion = modelVersion
    }
}

/// The prepared day: three candidate looks and what they were made from.
public struct DailyPlan: Codable, Hashable, Sendable {
    public let key: OutfitCacheKey
    public let looks: TodayLooks
    public let createdAt: Date
    /// The last weather reading the plan saw, kept so an offline morning can say "son bilinen".
    public let weather: CityWeatherReading?

    public init(key: OutfitCacheKey, looks: TodayLooks, createdAt: Date, weather: CityWeatherReading?) {
        self.key = key
        self.looks = looks
        self.createdAt = createdAt
        self.weather = weather
    }
}

/// The inputs for today, gathered once and turned into a key.
public struct PlanningContext: Sendable {
    public let city: SceneCity
    public let now: Date
    public let deviceTimeZone: TimeZone
    public let wardrobe: Wardrobe
    public let avatarRevision: String
    public let mood: TodayOutfitEngine.Mood
    public let weather: WeatherFreshness
    /// The day of a chosen world street that has no owned scene follows that street's clock.
    public let timeZoneOverride: TimeZone?

    public init(city: SceneCity, now: Date, deviceTimeZone: TimeZone = .current, wardrobe: Wardrobe, avatarRevision: String,
                mood: TodayOutfitEngine.Mood = .balanced, weather: WeatherFreshness, timeZoneOverride: TimeZone? = nil) {
        self.timeZoneOverride = timeZoneOverride
        self.city = city
        self.now = now
        self.deviceTimeZone = deviceTimeZone
        self.wardrobe = wardrobe
        self.avatarRevision = avatarRevision
        self.mood = mood
        self.weather = weather
    }

    public var timeZone: TimeZone { timeZoneOverride ?? city.timeZone(device: deviceTimeZone) }
    public var localDate: LocalDate { LocalDate(instant: now, timeZone: timeZone) }

    public var key: OutfitCacheKey {
        OutfitCacheKey(cityID: city, localDate: localDate, timeZoneID: timeZone.identifier,
                       wardrobeRevision: TodayOutfitEngine.revision(wardrobe), avatarRevision: avatarRevision,
                       preferencesRevision: "mood:\(mood.rawValue)", weatherKey: weather.cacheKey)
    }
}

// MARK: Planner

/// Three looks for the day (v2.8 §05.1). Weather changes the order only when it is live; otherwise
/// the looks say plainly that weather was not used.
public struct DailyOutfitPlanner: Sendable {
    public static let candidateCount = 3
    public init() {}

    public func plan(_ context: PlanningContext) -> DailyPlan {
        var engine = TodayOutfitEngine()
        engine.limit = 8
        let all = engine.looks(for: context.localDate, wardrobe: context.wardrobe, mood: context.mood)
        var looks = all.looks
        if context.weather.isLiveRain, case let .live(s) = context.weather {
            // Stable: looks with an outer layer first, otherwise the engine's order.
            let layered = looks.filter { $0.outfit[.outerwear] != nil }
            let rest = looks.filter { $0.outfit[.outerwear] == nil }
            looks = (layered + rest).map { look in
                let claims = look.unsupportedClaims.filter { !$0.hasPrefix("Hava verisi kullanılmadı") }
                var reasons = look.reasons
                if look.outfit[.outerwear] != nil { reasons.insert("Yağmur için üst katman (\(s.source))", at: 0) }
                return TodayLook(outfit: look.outfit, reasons: reasons, gaps: look.gaps, unsupportedClaims: claims, candidateID: look.candidateID)
            }
        }
        let picked = TodayLooks(localDate: all.localDate, mood: all.mood, source: all.source,
                                looks: Array(looks.prefix(Self.candidateCount)), poolRevision: all.poolRevision)
        let weather: CityWeatherReading? = switch context.weather {
        case let .live(s), let .lastKnown(s): s
        case .none: nil
        }
        return DailyPlan(key: context.key, looks: picked, createdAt: context.now, weather: weather)
    }
}

// MARK: Sealed files

/// How a file is protected at rest. The app passes AES-GCM with a Keychain key (wardrobe names are
/// personal data, v1.5 §111); tests pass a fake. A file that does not open is treated as damaged.
public struct SealingCodec: Sendable {
    public let seal: @Sendable (Data) throws -> Data
    public let open: @Sendable (Data) throws -> Data
    public init(seal: @escaping @Sendable (Data) throws -> Data, open: @escaping @Sendable (Data) throws -> Data) {
        self.seal = seal
        self.open = open
    }
    /// No sealing, for tests and previews only.
    public static let plain = SealingCodec(seal: { $0 }, open: { $0 })
}

/// One JSON value in one sealed file, written atomically.
public struct SealedJSONFile<Value: Codable & Sendable>: Sendable {
    public enum Read: Sendable {
        case value(Value)
        case missing
        case damaged
    }

    public let fileURL: URL
    public let codec: SealingCodec

    public init(fileURL: URL, codec: SealingCodec) {
        self.fileURL = fileURL
        self.codec = codec
    }

    public func read() -> Read {
        guard let sealed = try? Data(contentsOf: fileURL) else { return .missing }
        guard let data = try? codec.open(sealed), let value = try? JSONDecoder().decode(Value.self, from: data) else { return .damaged }
        return .value(value)
    }

    public func write(_ value: Value) throws {
        let sealed = try codec.seal(JSONEncoder().encode(value))
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        #if os(iOS)
        try sealed.write(to: fileURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
        #else
        try sealed.write(to: fileURL, options: [.atomic])
        #endif
    }

    public func clear() { try? FileManager.default.removeItem(at: fileURL) }
}

// MARK: Cache

/// The day's plan on the device, sealed and written atomically. A damaged file is reported, never
/// trusted (UI28-T005).
public struct OutfitCache: Sendable {
    public enum Read: Equatable, Sendable {
        /// The plan was made for exactly this key.
        case hit(DailyPlan)
        /// A plan exists for another key (yesterday, another city, older wardrobe): usable only as a
        /// quiet fallback, never labelled as today's.
        case stale(DailyPlan)
        case miss
        case corrupt
    }

    public static let schemaVersion = 1
    private let file: SealedJSONFile<OutfitCacheEnvelope>
    public var fileURL: URL { file.fileURL }

    public init(fileURL: URL, codec: SealingCodec = .plain) {
        file = SealedJSONFile(fileURL: fileURL, codec: codec)
    }

    public func read(for key: OutfitCacheKey) -> Read {
        switch file.read() {
        case .missing: return .miss
        case .damaged: return .corrupt
        case let .value(envelope):
            guard envelope.schema == Self.schemaVersion, envelope.plan.looks.looks.allSatisfy(Self.isWearable) else { return .corrupt }
            return envelope.plan.key == key ? .hit(envelope.plan) : .stale(envelope.plan)
        }
    }

    public func write(_ plan: DailyPlan) throws {
        try file.write(OutfitCacheEnvelope(schema: Self.schemaVersion, plan: plan))
    }

    public func clear() { file.clear() }

    /// A look the figure can wear without showing a half-dressed frame (UI28-T010).
    public static func isWearable(_ look: TodayLook) -> Bool {
        look.outfit[.dress] != nil || (look.outfit[.top] != nil && look.outfit[.bottom] != nil)
    }
}

/// The cache file's content: a schema number and the plan.
struct OutfitCacheEnvelope: Codable, Sendable {
    let schema: Int
    let plan: DailyPlan
}

// MARK: Reconciler

/// A look the user chose to keep for the day. Weather or city updates never replace it (UI28-T006).
public struct OutfitLock: Codable, Hashable, Sendable {
    public let outfit: DressedOutfit
    public let localDate: LocalDate
    public init(outfit: DressedOutfit, localDate: LocalDate) {
        self.outfit = outfit
        self.localDate = localDate
    }
}

/// What to do with the figure when a new plan arrives (v2.8 §05.6).
public enum ReconcileDecision: Equatable, Sendable {
    /// Leave the figure as it is.
    case keep(reason: String)
    /// Put this look on, in one atomic change, and say so quietly.
    case swap(to: TodayLook, notice: String)
}

public struct OutfitReconciler: Sendable {
    public init() {}

    public func reconcile(showing current: DressedOutfit?, lock: OutfitLock?, today: LocalDate, newPlan: DailyPlan) -> ReconcileDecision {
        if let lock, lock.localDate == today {
            return .keep(reason: "Kilitli kombin korunuyor")
        }
        let wearable = newPlan.looks.looks.filter(OutfitCache.isWearable)
        guard let first = wearable.first else { return .keep(reason: "Yeni giyilebilir aday yok") }
        if let current, wearable.contains(where: { $0.outfit == current }) {
            return .keep(reason: "Mevcut kombin hâlâ adaylar arasında")
        }
        return .swap(to: first, notice: current == nil ? "Bugünün kombini hazır" : "Kombin yenilendi")
    }
}

// MARK: Warm start

/// What the home shows on its first frame and why (v2.8 §05 "Anında açılış protokolü").
public struct WarmStart: Sendable {
    public enum Origin: String, Sendable, Equatable {
        /// Today's cached plan for exactly these inputs.
        case cachedToday = "CACHED_TODAY"
        /// No valid cache: computed now in the foreground (background refresh may never have run).
        case computedNow = "COMPUTED_NOW"
        /// The cache file was damaged; it was discarded and the plan computed now.
        case recoveredFromCorruption = "RECOVERED_FROM_CORRUPTION"
    }

    public let plan: DailyPlan
    public let origin: Origin
    /// A previous plan shown only until the new one is ready; never labelled as today's.
    public let previous: DailyPlan?

    /// Read the cache; compute in the foreground when it does not match; write the result back.
    public static func prepare(_ context: PlanningContext, cache: OutfitCache, planner: DailyOutfitPlanner = DailyOutfitPlanner()) -> WarmStart {
        switch cache.read(for: context.key) {
        case let .hit(plan):
            return WarmStart(plan: plan, origin: .cachedToday, previous: nil)
        case let .stale(old):
            let plan = planner.plan(context)
            try? cache.write(plan)
            return WarmStart(plan: plan, origin: .computedNow, previous: old)
        case .miss:
            let plan = planner.plan(context)
            try? cache.write(plan)
            return WarmStart(plan: plan, origin: .computedNow, previous: nil)
        case .corrupt:
            cache.clear()
            let plan = planner.plan(context)
            try? cache.write(plan)
            return WarmStart(plan: plan, origin: .recoveredFromCorruption, previous: nil)
        }
    }
}
