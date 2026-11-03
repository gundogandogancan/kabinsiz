import AvatarDressing
import Foundation
import LivingWorld
@testable import MorningReady
import Testing
import TodayOutfit
import TravelEngine
import WardrobeDomain

@Suite("v2.8 sabah hazır (UI28-T001…T010)")
struct MorningReadyTests {
    /// 2026-11-03 22:30 UTC: already 4 November in İstanbul (UTC+3), still 3 November in Barcelona (UTC+1).
    let lateEvening = Date(timeIntervalSince1970: 1_793_745_000)

    func context(_ city: SceneCity = .istanbul, now: Date? = nil, wardrobe: Wardrobe = SyntheticCloset.studio,
                 weather: WeatherFreshness = .none, avatar: String = "standin-1") -> PlanningContext {
        PlanningContext(city: city, now: now ?? lateEvening, deviceTimeZone: TimeZone(identifier: "UTC")!, wardrobe: wardrobe,
                        avatarRevision: avatar, weather: weather)
    }

    func tempCache() -> OutfitCache {
        OutfitCache(fileURL: FileManager.default.temporaryDirectory
            .appendingPathComponent("kz-morning-\(UUID().uuidString)").appendingPathComponent("daily-plan.json"))
    }

    func rain(_ city: SceneCity = .istanbul, at: Date) -> CityWeatherReading {
        CityWeatherReading(city: city, condition: .rain, temperatureC: 12, source: "Test verisi", observedAt: at)
    }

    @Test("UI28-T001: a first launch with no cache still opens on three wearable looks, never an empty figure")
    func firstLaunchHasLooks() {
        let start = WarmStart.prepare(context(), cache: tempCache())
        #expect(start.origin == .computedNow)
        #expect(start.plan.looks.looks.count == DailyOutfitPlanner.candidateCount)
        #expect(start.plan.looks.looks.allSatisfy(OutfitCache.isWearable))
    }

    @Test("UI28-T002: the day is the chosen city's day, not the device's")
    func cityLocalDate() {
        #expect(context(.istanbul).localDate == LocalDate("2026-11-04"))
        #expect(context(.barcelona).localDate == LocalDate("2026-11-03"))
        #expect(context(.istanbul).key.timeZoneID == "Europe/Istanbul")
        #expect(context(.istanbul).key != context(.barcelona).key)
    }

    @Test("UI28-T003: a plan cached for the same inputs is shown as is, without recomputing")
    func cacheHit() throws {
        let cache = tempCache()
        let first = WarmStart.prepare(context(), cache: cache)
        let second = WarmStart.prepare(context(), cache: cache)
        #expect(second.origin == .cachedToday)
        #expect(second.plan == first.plan)
    }

    @Test("UI28-T004: with no background run, the next day is prepared in the foreground; the old plan is only a fallback")
    func noBackgroundRun() {
        let cache = tempCache()
        _ = WarmStart.prepare(context(), cache: cache)
        let nextDay = WarmStart.prepare(context(now: lateEvening.addingTimeInterval(24 * 3600)), cache: cache)
        #expect(nextDay.origin == .computedNow)
        #expect(nextDay.previous?.key.localDate == LocalDate("2026-11-04"))
        #expect(nextDay.plan.key.localDate == LocalDate("2026-11-05"))
    }

    @Test("UI28-T005: a damaged cache file is discarded and the plan recomputed, with the origin said")
    func corruptCache() throws {
        let cache = tempCache()
        try FileManager.default.createDirectory(at: cache.fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("{not json".utf8).write(to: cache.fileURL)
        #expect(cache.read(for: context().key) == .corrupt)
        let start = WarmStart.prepare(context(), cache: cache)
        #expect(start.origin == .recoveredFromCorruption)
        #expect(cache.read(for: context().key) == .hit(start.plan))
    }

    @Test("UI28-T006: a look the user locked today is kept when the weather or city changes")
    func lockWins() {
        let today = context().localDate
        let plan = DailyOutfitPlanner().plan(context(weather: .live(rain(at: lateEvening))))
        let mine = DressedOutfit(Array(plan.looks.looks.last!.outfit.items.values))
        let decision = OutfitReconciler().reconcile(showing: mine, lock: OutfitLock(outfit: mine, localDate: today), today: today, newPlan: plan)
        #expect(decision == .keep(reason: "Kilitli kombin korunuyor"))
        // Yesterday's lock does not hold today.
        let yesterday = LocalDate("2026-11-03")!
        let other = DressedOutfit([])
        if case .swap = OutfitReconciler().reconcile(showing: other, lock: OutfitLock(outfit: mine, localDate: yesterday), today: today, newPlan: plan) {
        } else { Issue.record("an expired lock must not hold") }
    }

    @Test("UI28-T007: a manually chosen city plans without any location, in that city's clock")
    func manualCity() {
        let plan = DailyOutfitPlanner().plan(context(.barcelona))
        #expect(plan.key.cityID == .barcelona)
        #expect(plan.key.timeZoneID == "Europe/Madrid")
    }

    @Test("UI28-T008: without a live reading the scene never rains, and the chip says there is no data")
    func noFakeRain() {
        let stale = WeatherFreshness.classify(rain(at: lateEvening.addingTimeInterval(-5 * 3600)), city: .istanbul, now: lateEvening)
        #expect(SceneWeatherState.from(stale.sceneEvidence).rainIntensity == 0)
        #expect(SceneWeatherState.from(WeatherFreshness.none.sceneEvidence).rainIntensity == 0)
        #expect(WeatherChipText.make(city: .istanbul, freshness: .none).title == "İstanbul · Hava verisi yok")
        // Another city's reading is not this city's weather.
        #expect(WeatherFreshness.classify(rain(.barcelona, at: lateEvening), city: .istanbul, now: lateEvening) == .none)
        let live = WeatherFreshness.classify(rain(at: lateEvening.addingTimeInterval(-600)), city: .istanbul, now: lateEvening)
        #expect(SceneWeatherState.from(live.sceneEvidence, now: lateEvening).rainIntensity == 1)
        #expect(WeatherChipText.make(city: .istanbul, freshness: live).title == "İstanbul · 12° · Yağmur")
    }

    @Test("UI28-T009: an old reading is labelled 'Son bilinen tahmin' with its time in the city's clock")
    func lastKnownLabel() {
        let at = Date(timeIntervalSince1970: 1_793_686_800) // 06:20 UTC = 09.20 İstanbul
        let chip = WeatherChipText.make(city: .istanbul, freshness: WeatherFreshness.classify(rain(at: at), city: .istanbul, now: lateEvening))
        #expect(chip.state == .lastKnown)
        #expect(chip.provenance == "Son bilinen tahmin · 09.20 · Test verisi")
    }

    @Test("UI28-T010: when the weather changes the figure swaps to a whole look in one step, never a half-dressed one")
    func weatherSwapIsWhole() {
        let dry = DailyOutfitPlanner().plan(context())
        let wet = DailyOutfitPlanner().plan(context(weather: .live(rain(at: lateEvening))))
        #expect(dry.key != wet.key)
        // Rain puts layered looks first and says why; the "weather not used" claim is dropped.
        #expect(wet.looks.looks.first?.outfit[.outerwear] != nil)
        #expect(wet.looks.looks.first?.reasons.first == "Yağmur için üst katman (Test verisi)")
        #expect(wet.looks.looks.allSatisfy { !$0.unsupportedClaims.contains { $0.hasPrefix("Hava verisi kullanılmadı") } })
        let decision = OutfitReconciler().reconcile(showing: DressedOutfit([]), lock: nil, today: wet.key.localDate, newPlan: wet)
        guard case let .swap(look, _) = decision else { Issue.record("expected a swap"); return }
        #expect(OutfitCache.isWearable(look))
    }

    @Test("Cache key: wardrobe, avatar, mood and weather each invalidate; the reconciler keeps a look still offered")
    func keyInvalidation() {
        let base = context().key
        #expect(context(avatar: "personal-2").key != base)
        #expect(context(wardrobe: SyntheticCloset.demo).key != base)
        #expect(context(weather: .live(rain(at: lateEvening))).key != base)
        let plan = DailyOutfitPlanner().plan(context())
        let showing = plan.looks.looks[1].outfit
        #expect(OutfitReconciler().reconcile(showing: showing, lock: nil, today: plan.key.localDate, newPlan: plan)
            == .keep(reason: "Mevcut kombin hâlâ adaylar arasında"))
    }

    @Test("UI28-T045 at rest: the plan is sealed; a file sealed with another key reads as damaged, never as a plan")
    func sealedAtRest() throws {
        func xor(_ k: UInt8) -> SealingCodec {
            SealingCodec(seal: { Data($0.map { $0 ^ k }) }, open: { d in
                let out = Data(d.map { $0 ^ k })
                guard out.first == UInt8(ascii: "{") else { throw CocoaError(.fileReadCorruptFile) }
                return out
            })
        }
        let url = tempCache().fileURL
        let cache = OutfitCache(fileURL: url, codec: xor(0x5A))
        let start = WarmStart.prepare(context(), cache: cache)
        let raw = try Data(contentsOf: url)
        let name = start.plan.looks.looks[0].outfit.items.values.first!.name
        #expect(!String(decoding: raw, as: UTF8.self).contains(name), "garment names never sit in plain text")
        #expect(cache.read(for: context().key) == .hit(start.plan))
        #expect(OutfitCache(fileURL: url, codec: xor(0x33)).read(for: context().key) == .corrupt)
    }
}
