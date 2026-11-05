import AvatarDressing
import BodyGeometry
import Foundation
import LivingWorld
import MorningReady
import Observation
import SystemContracts
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
    private static let streetKey = "world.street"

    var city: SceneCity {
        didSet {
            UserDefaults.standard.set(city.rawValue, forKey: Self.cityKey)
            if oldValue != city {
                reading = nil
                cityReady = false
                cityLoadFailed = false
                latchedFPS = nil
                frameRates = []
            }
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

    // MARK: Scene quality (v2.8 §06.8 governor)

    /// The last scene update rates (one every two seconds), measured on this device.
    private(set) var frameRates: [Double] = []
    /// A slow-frame step-down holds for the rest of the session in this city, so the scene does not flap.
    private var latchedFPS: Double?
    /// True once the 3D street is on screen; until then the labelled 2D frame shows ("sahne yükleniyor").
    private(set) var cityReady = false
    private(set) var cityLoadFailed = false
    private(set) var thermal: ThermalLevel = .nominal
    private(set) var lowPower = false
    private var forcedTier: SceneRenderTier?

    // MARK: World street (Apple Look Around, EG-003)

    /// The chosen world street, by hand or from "Konumumdaki şehir". Only its id is stored.
    private(set) var street: FamousStreet?
    /// The Look Around scene for `street`, once Apple returned one.
    private(set) var streetScene: LookAroundSceneBox?
    enum StreetStatus: Equatable { case idle, loading, shown, noImagery, offline, off }
    private(set) var streetStatus: StreetStatus = .idle

    /// One line on what happened to the street photo, or nil when no world street is chosen.
    var streetStatusText: String? {
        guard let street else { return nil }
        let fallback = street.ownedScene != nil ? "Kabinsiz sokağı gösteriliyor." : "Nötr stüdyo gösteriliyor."
        return switch streetStatus {
        case .idle, .loading: "\(street.city): cadde fotoğrafı yükleniyor…"
        case .shown: "\(street.city) · \(street.street): Apple Look Around"
        case .noImagery: "Apple'ın \(street.street) için Look Around görüntüsü yok. \(fallback)"
        case .offline: "Cadde fotoğrafı alınamadı (bağlantı ya da Apple). \(fallback)"
        case .off: "Cadde fotoğrafı kapalı. \(fallback)"
        }
    }

    private var cache: OutfitCache
    private var lockFile: SealedJSONFile<OutfitLock>
    private var noticeTask: Task<Void, Never>?
    private var inputs: (wardrobe: Wardrobe, avatarRevision: String)?

    init() {
        let args = ProcessInfo.processInfo.arguments
        city = SceneCity(rawValue: UserDefaults.standard.string(forKey: Self.cityKey) ?? "") ?? .istanbul
        if let i = args.firstIndex(of: "-worldCity"), i + 1 < args.count, let c = SceneCity(rawValue: args[i + 1]) { city = c }
        if args.contains("-worldRainPreview") { preview = .rain }
        if let i = args.firstIndex(of: "-sceneTier"), i + 1 < args.count { forcedTier = SceneRenderTier(rawValue: args[i + 1]) }
        var chosen = UserDefaults.standard.string(forKey: Self.streetKey).flatMap(FamousStreetCatalog.street(id:))
        if let i = args.firstIndex(of: "-worldStreet"), i + 1 < args.count { chosen = FamousStreetCatalog.street(id: args[i + 1]) }
        if args.contains("-resetForUITest"), !args.contains("-worldStreet") { chosen = nil }
        // Same rule as `choose(street:)`: the owned 3D street when there is one, else the neutral studio.
        if let chosen { city = chosen.ownedScene ?? .studio }
        street = chosen
        let codec = MorningStore.codec()
        cache = OutfitCache(fileURL: MorningStore.planURL, codec: codec)
        lockFile = SealedJSONFile(fileURL: MorningStore.lockURL, codec: codec)
        if case let .value(saved) = lockFile.read() { lock = saved }
        readDeviceState()
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
    var chip: WeatherChipText { WeatherChipText.make(city: city, freshness: freshness, preview: preview, placeName: street?.city) }
    var manifest: SceneAssetManifestV1? { SceneAssetManifestV1.manifest(for: city) }
    var outfit: DressedOutfit { dressing.outfit }
    var looks: TodayLooks? { plan?.looks }
    var currentLook: TodayLook? { looks?.looks.indices.contains(lookIndex) == true ? looks?.looks[lookIndex] : nil }
    var isExample: Bool { looks?.source == .syntheticExample }
    var isLocked: Bool { lock?.localDate == today && lock?.outfit == outfit }
    var today: LocalDate { LocalDate(instant: Date(), timeZone: planTimeZone) }
    /// A world street without an owned scene keeps its own clock; otherwise the scene city's.
    var planTimeZone: TimeZone { street?.ownedScene == nil ? street?.timeZone ?? city.timeZone() : city.timeZone() }

    /// Choose a world street (or none, for the owned scenes). A street with an owned 3D scene also moves
    /// the scene city there, so the 3D street is the fallback when no photo is available.
    func choose(street: FamousStreet?) {
        guard street != self.street else { return }
        self.street = street
        streetScene = nil
        streetStatus = .idle
        UserDefaults.standard.set(street?.id, forKey: Self.streetKey)
        if let owned = street?.ownedScene { city = owned } else if street != nil { city = .studio }
        replan()
    }

    /// Fetch (or drop) the street photo for the chosen street. Called from the view's task.
    func loadStreetScene(allowed: Bool, fetch: (FamousStreet) async throws -> LookAroundSceneBox?) async {
        guard let street else { streetScene = nil; streetStatus = .idle; return }
        guard allowed else { streetScene = nil; streetStatus = .off; return }
        streetStatus = .loading
        do {
            let box = try await fetch(street)
            guard street == self.street else { return }
            streetScene = box
            streetStatus = box == nil ? .noImagery : .shown
        } catch FaultCode.policyDenied {
            guard street == self.street else { return }
            streetScene = nil
            streetStatus = .off
        } catch {
            guard street == self.street else { return }
            streetScene = nil
            streetStatus = .offline
        }
    }

    func quality(reduceMotion: Bool) -> SceneQuality {
        let decided = SceneQualityPolicy.decide(hasModel: manifest?.model3D != nil, loadFailed: cityLoadFailed, thermal: thermal,
                                                lowPower: lowPower, reduceMotion: reduceMotion, sustainedFPS: latchedFPS)
        guard let forcedTier else { return decided }
        return SceneQuality(tier: forcedTier, rainScale: decided.rainScale, cameraDrift: forcedTier == .city3D && decided.cameraDrift,
                            reason: "Test ayarı")
    }

    /// What is actually on screen: the 3D street only once it has loaded.
    func shownTier(reduceMotion: Bool) -> SceneRenderTier {
        if streetScene != nil { return .streetPhoto }
        let tier = quality(reduceMotion: reduceMotion).tier
        return tier != .frame2D && cityReady ? tier : .frame2D
    }

    /// Sustained rate over the last three reports (six seconds); a low one latches a step down.
    func reportFrameRate(_ rate: Double) {
        frameRates = Array((frameRates + [rate]).suffix(3))
        guard frameRates.count == 3, cityReady else { return }
        let sustained = frameRates.reduce(0, +) / 3
        if sustained < SceneQualityPolicy.reduceBelowFPS, sustained < (latchedFPS ?? .infinity) {
            latchedFPS = sustained
            Self.log.info("scene rate \(sustained, privacy: .public)/s: stepping down")
        }
    }

    var sustainedFrameRate: Double? { frameRates.count == 3 ? frameRates.reduce(0, +) / 3 : nil }

    func cityDidLoad(_ ready: Bool) {
        cityReady = ready
        if !ready, manifest?.model3D != nil, quality(reduceMotion: false).tier != .frame2D { cityLoadFailed = true }
    }

    func readDeviceState() {
        let info = ProcessInfo.processInfo
        thermal = switch info.thermalState {
        case .nominal: .nominal
        case .fair: .fair
        case .serious: .serious
        case .critical: .critical
        @unknown default: .serious
        }
        lowPower = info.isLowPowerModeEnabled
    }

    // MARK: Morning-ready plan

    /// Bring the plan in line with today's inputs: the cached plan when it matches, else a plan made
    /// now in the foreground. The figure changes only through the reconciler, so a locked look stays
    /// and a look that is still offered is not swapped away.
    func refresh(wardrobe: Wardrobe, avatarRevision: String) {
        inputs = (wardrobe, avatarRevision)
        let context = PlanningContext(city: city, now: Date(), wardrobe: wardrobe, avatarRevision: avatarRevision, mood: mood, weather: freshness,
                                      timeZoneOverride: street?.ownedScene == nil ? street?.timeZone : nil)
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

    /// "Uygula" on a suggestion card: that prepared look, atomically.
    func wearLook(at index: Int) {
        guard let looks, looks.looks.indices.contains(index), index != lookIndex || dressing.outfit != looks.looks[index].outfit else { return }
        let start = ContinuousClock.now
        lookIndex = index
        apply(.wear(looks.looks[index].outfit))
        lastSwapMillis = Self.millis(ContinuousClock.now - start)
        say("Kombin uygulandı")
    }

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
    /// Take a slot off (any slot, dress-up); undo puts it back.
    func remove(_ slot: GarmentSlotID) { apply(.remove(slot)) }
    func undo() {
        apply(.undo)
        notice = nil
    }
    func redo() { apply(.redo) }

    /// Dress-up tray: tap a piece to put it on; tap the worn piece to take it off.
    func toggle(_ item: DressItem) {
        if outfit[item.slot]?.id == item.id { remove(item.slot) } else { wear(item) }
    }

    /// A piece dropped on the figure, by id, from the same pool the tray shows.
    @discardableResult
    func wear(id: String, wardrobe: Wardrobe) -> Bool {
        guard let item = GarmentSlotID.allCases.lazy.flatMap({ self.choices(for: $0, wardrobe: wardrobe) }).first(where: { $0.id == id }) else { return false }
        wear(item)
        return true
    }

    /// Slots the tray offers: those with pieces in the pool or on the figure, in slot order.
    func dressUpSlots(wardrobe: Wardrobe) -> [GarmentSlotID] {
        GarmentSlotID.allCases.filter { outfit[$0] != nil || !choices(for: $0, wardrobe: wardrobe).isEmpty }
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
    /// A garment the user just added (even the first one) can be tried on at once, over the example look.
    func choices(for slot: GarmentSlotID, wardrobe: Wardrobe) -> [DressItem] {
        let pool = wardrobe.garments + (isExample ? SyntheticCloset.studio.garments : [])
        return pool.filter { $0.condition.isPlannable }
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
