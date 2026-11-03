import AvatarDressing
import BodyGeometry
import Foundation
import LivingWorld
import MorningReady
import Observation
import os
import TodayOutfit
import TravelEngine
import WardrobeDomain

/// State of the home world (v2.5 §2, v2.8 §05): the city, the weather and how fresh it is, the day's
/// three prepared looks and the look on the figure with its undo history. The looks come from the
/// on-device cache when it matches today's inputs, so the first frame is already dressed; "Yeni
/// kombin" moves to the next prepared look instead of computing on tap.
@Observable
@MainActor
final class HomeWorldModel {
    private static let log = Logger(subsystem: "app.kabinsiz.ios", category: "world")
    private static let cityKey = "world.city"

    var city: SceneCity {
        didSet {
            UserDefaults.standard.set(city.rawValue, forKey: Self.cityKey)
            if oldValue != city { reading = nil }
        }
    }
    /// The last weather reading from a provider. None is connected in this build (WeatherKit is
    /// BLOCKED_EXTERNAL), so this stays nil outside UI-test fixtures.
    private(set) var reading: CityWeatherReading?
    /// A condition the user asked to preview. Always labelled as a preview, never as weather.
    var preview: SceneCondition?
    private(set) var plan: DailyPlan?
    private(set) var origin: WarmStart.Origin?
    private(set) var lookIndex = 0
    private(set) var dressing = DressedAvatarState()
    var selectedSlot: GarmentSlotID?
    private(set) var mood: TodayOutfitEngine.Mood = .balanced
    private(set) var lock: OutfitLock?
    /// A short note after a change the user may want to take back ("Kombin değişti · Geri al").
    private(set) var notice: String?
    /// Last tap-to-dressed time in milliseconds, for the evidence log (simulator numbers are not device numbers).
    private(set) var lastSwapMillis: Double?
    /// Time from asking for today's plan to having it, in milliseconds (cache read or foreground compute).
    private(set) var warmStartMillis: Double?

    private var cache: OutfitCache
    private var lockFile: SealedJSONFile<OutfitLock>
    private var noticeTask: Task<Void, Never>?
    private var inputs: (wardrobe: Wardrobe, avatarRevision: String)?

    init() {
        let args = ProcessInfo.processInfo.arguments
        city = SceneCity(rawValue: UserDefaults.standard.string(forKey: Self.cityKey) ?? "") ?? .istanbul
        if let i = args.firstIndex(of: "-worldCity"), i + 1 < args.count, let c = SceneCity(rawValue: args[i + 1]) { city = c }
        if args.contains("-worldRainPreview") { preview = .rain }
        let codec = MorningStore.codec()
        cache = OutfitCache(fileURL: MorningStore.planURL, codec: codec)
        lockFile = SealedJSONFile(fileURL: MorningStore.lockURL, codec: codec)
        if case let .value(saved) = lockFile.read() { lock = saved }
        #if DEBUG
        // Labelled test readings for the H01/H05 UI tests; never used outside a test launch.
        if let i = args.firstIndex(of: "-worldWeatherFixture"), i + 1 < args.count {
            let age: TimeInterval = args[i + 1] == "stale" ? 6 * 3600 : 10 * 60
            reading = CityWeatherReading(city: city, condition: .rain, temperatureC: 12, source: "Test verisi",
                                         observedAt: Date().addingTimeInterval(-age))
        }
        #endif
    }

    // MARK: What the scene shows

    var freshness: WeatherFreshness { WeatherFreshness.classify(reading, city: city, now: Date()) }
    var weather: SceneWeatherEvidence { preview.map { .userPreview($0) } ?? freshness.sceneEvidence }
    var sceneWeather: SceneWeatherState { SceneWeatherState.from(weather) }
    var chip: WeatherChipText { WeatherChipText.make(city: city, freshness: freshness, preview: preview) }
    var manifest: SceneAssetManifestV1? { SceneAssetManifestV1.manifest(for: city) }
    var outfit: DressedOutfit { dressing.outfit }
    var looks: TodayLooks? { plan?.looks }
    var currentLook: TodayLook? { looks?.looks.indices.contains(lookIndex) == true ? looks?.looks[lookIndex] : nil }
    var isExample: Bool { looks?.source == .syntheticExample }
    var isLocked: Bool { lock?.localDate == today && lock?.outfit == outfit }
    var today: LocalDate { LocalDate(instant: Date(), timeZone: city.timeZone()) }

    // MARK: Morning-ready plan

    /// Bring the plan in line with today's inputs: the cached plan when it matches, else a plan made
    /// now in the foreground. The figure changes only through the reconciler, so a locked look stays
    /// and a look that is still offered is not swapped away.
    func refresh(wardrobe: Wardrobe, avatarRevision: String) {
        inputs = (wardrobe, avatarRevision)
        let context = PlanningContext(city: city, now: Date(), wardrobe: wardrobe, avatarRevision: avatarRevision, mood: mood, weather: freshness)
        guard plan?.key != context.key else { return }
        let start = ContinuousClock.now
        let warm = WarmStart.prepare(context, cache: cache)
        warmStartMillis = Self.millis(ContinuousClock.now - start)
        origin = warm.origin
        Self.log.info("warm start \(warm.origin.rawValue, privacy: .public) \(self.warmStartMillis ?? 0, privacy: .public) ms")
        let showing = dressing.outfit.items.isEmpty ? nil : dressing.outfit
        plan = warm.plan
        switch OutfitReconciler().reconcile(showing: showing, lock: lock, today: context.localDate, newPlan: warm.plan) {
        case let .keep(reason):
            lookIndex = warm.plan.looks.looks.firstIndex { $0.outfit == dressing.outfit } ?? 0
            Self.log.debug("reconcile keep: \(reason, privacy: .public)")
        case let .swap(look, note):
            lookIndex = warm.plan.looks.looks.firstIndex(of: look) ?? 0
            apply(.wear(look.outfit))
            if showing != nil { say(note) }
        }
    }

    /// Re-run with the inputs last seen (city or mood changed).
    func replan() {
        guard let inputs else { return }
        refresh(wardrobe: inputs.wardrobe, avatarRevision: inputs.avatarRevision)
    }

    func setMood(_ mood: TodayOutfitEngine.Mood) {
        self.mood = mood
        unlock()
        replan()
    }

    /// "Bugün bunu giyeceğim": weather and city updates will not replace this look today.
    func toggleLock() {
        if isLocked { unlock(); return }
        let next = OutfitLock(outfit: outfit, localDate: today)
        lock = next
        try? lockFile.write(next)
    }

    private func unlock() {
        lock = nil
        lockFile.clear()
    }

    /// After "delete everything": forget the plan and the lock held in memory; the files and their key
    /// are already gone (MorningStore.eraseAll).
    func forgetAll() {
        let codec = MorningStore.codec()
        cache = OutfitCache(fileURL: MorningStore.planURL, codec: codec)
        lockFile = SealedJSONFile(fileURL: MorningStore.lockURL, codec: codec)
        lock = nil
        plan = nil
        origin = nil
        notice = nil
        dressing = DressedAvatarState()
        // Everything is gone: the next plan is the labelled example on the stand-in body.
        refresh(wardrobe: Wardrobe(), avatarRevision: "standin")
    }

    // MARK: Dressing

    /// "Yeni kombin": the next prepared look, atomically. With one look there is nothing new to show.
    func nextLook() {
        guard let looks, looks.looks.count > 1 else { return }
        let start = ContinuousClock.now
        lookIndex = (lookIndex + 1) % looks.looks.count
        apply(.wear(looks.looks[lookIndex].outfit))
        lastSwapMillis = Self.millis(ContinuousClock.now - start)
        Self.log.info("look swap \(self.lastSwapMillis ?? 0, privacy: .public) ms (model only)")
        say("Yeni kombin")
    }

    func wear(_ item: DressItem) { apply(.replace(item)) }
    /// Take an accessory slot off; top, bottom and shoes are refused by the dressing state.
    func remove(_ slot: GarmentSlotID) { apply(.remove(slot)) }
    func undo() {
        apply(.undo)
        notice = nil
    }

    private func apply(_ action: OutfitChangeRequest.Action) {
        do {
            try dressing.apply(OutfitChangeRequest(action: action, basedOnRevision: dressing.revision))
        } catch {
            Self.log.debug("dressing refused: \(String(describing: error), privacy: .public)")
        }
    }

    private func say(_ text: String) {
        notice = text
        noticeTask?.cancel()
        noticeTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(6))
            guard !Task.isCancelled else { return }
            self?.notice = nil
        }
    }

    /// Pieces for a slot: the user's own first; the example closet only while the figure wears the example.
    func choices(for slot: GarmentSlotID, wardrobe: Wardrobe) -> [DressItem] {
        let pool = isExample ? SyntheticCloset.studio : wardrobe
        return pool.garments.filter { $0.condition.isPlannable }
            .compactMap(GarmentAppearance.dressItem(for:))
            .filter { $0.slot == slot }
    }

    /// Up to three pieces other than the one worn (v2.8 H02): pieces from today's other looks first,
    /// then the rest of the pool in a stable order.
    func alternatives(for slot: GarmentSlotID, wardrobe: Wardrobe, limit: Int = 3) -> [DressItem] {
        let worn = outfit[slot]?.id
        let fromLooks = (looks?.looks ?? []).compactMap { $0.outfit[slot] }
        var seen = Set<String>(), result: [DressItem] = []
        for item in fromLooks + choices(for: slot, wardrobe: wardrobe) where item.id != worn && seen.insert(item.id).inserted {
            result.append(item)
            if result.count == limit { break }
        }
        return result
    }

    private static func millis(_ d: Duration) -> Double {
        Double(d.components.seconds) * 1000 + Double(d.components.attoseconds) / 1e15
    }
}
