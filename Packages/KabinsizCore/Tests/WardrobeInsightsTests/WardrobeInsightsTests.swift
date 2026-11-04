import DomainContracts
import Foundation
import LivingWorld
import Testing
import TravelEngine
import WardrobeDomain
@testable import WardrobeInsights

@Suite("Wardrobe insights: wear log, cost per wear, gaps, day needs")
struct WardrobeInsightsTests {
    func g(_ id: String, _ c: GarmentCategory, _ f: ClosedRange<Formality> = .casual ... .casual, neutral: Bool = true,
           claims: [MaterialClaim.Property] = [], provenance: Provenance = .userEntered) -> Garment {
        Garment(id: id, name: id, category: c, formalityRange: f, colorName: neutral ? "lacivert" : "turuncu", isNeutralColor: neutral,
                materialClaims: claims.map { MaterialClaim(property: $0, source: .userEntered) }, provenance: provenance)
    }

    func d(_ s: String) -> LocalDate { LocalDate(s)! }

    @Test("INS-T01: a logged day counts once per garment; logging the day again replaces it; empty clears it")
    func logging() {
        var l = WearLedger()
        l.log(WearEntry(date: d("2026-11-01"), garmentIDs: ["a", "b", "a"]))
        l.log(WearEntry(date: d("2026-11-02"), garmentIDs: ["a"]))
        #expect(l.wearCount("a") == 2 && l.wearCount("b") == 1)
        l.log(WearEntry(date: d("2026-11-01"), garmentIDs: ["c"]))
        #expect(l.wearCount("a") == 1 && l.wearCount("b") == 0 && l.wearCount("c") == 1)
        l.log(WearEntry(date: d("2026-11-02"), garmentIDs: []))
        #expect(l.wearCount("a") == 0)
        #expect(l.lastWorn("c") == d("2026-11-01"))
    }

    @Test("INS-T02: cost per wear only from the user's own price and wears; never zero, never a guess")
    func costPerWear() {
        var l = WearLedger()
        #expect(l.costPerWear("a") == nil, "no price, no wears")
        l.setPrice(UserPrice(minorUnits: 120_000, currency: "try"), for: "a")
        #expect(l.costPerWear("a") == nil, "a price but no wears is not 'infinite' or zero; it is nothing")
        for day in 1 ... 3 { l.log(WearEntry(date: d("2026-11-0\(day)"), garmentIDs: ["a"])) }
        let cpw = l.costPerWear("a")
        #expect(cpw?.minorUnits == 40_000 && cpw?.currency == "TRY")
        #expect(UserPrice(minorUnits: 0, currency: "TRY") == nil && UserPrice(minorUnits: 10, currency: "TL") == nil)
    }

    @Test("INS-T03: removing a garment forgets its wears and price; days left empty disappear")
    func forget() {
        var l = WearLedger()
        l.setPrice(UserPrice(minorUnits: 500, currency: "EUR"), for: "a")
        l.log(WearEntry(date: d("2026-11-01"), garmentIDs: ["a"]))
        l.log(WearEntry(date: d("2026-11-02"), garmentIDs: ["a", "b"]))
        l.forget(garmentID: "a")
        #expect(l.wearCount("a") == 0 && l.prices["a"] == nil)
        #expect(l.entries.count == 1 && l.entries[0].garmentIDs == ["b"])
    }

    @Test("INS-T04: repeat avoidance looks back the asked number of days, never at the day itself")
    func recent() {
        var l = WearLedger()
        l.log(WearEntry(date: d("2026-10-25"), garmentIDs: ["old"]))
        l.log(WearEntry(date: d("2026-11-02"), garmentIDs: ["recent"]))
        l.log(WearEntry(date: d("2026-11-04"), garmentIDs: ["today"]))
        #expect(l.recentlyWorn(before: d("2026-11-04"), days: 3) == ["recent"])
        #expect(l.recentlyWorn(before: d("2026-11-04"), days: 14) == ["old", "recent"])
    }

    @Test("INS-T05: most and least worn, never worn and utilisation; underwear is not counted")
    func report() {
        let w = Wardrobe(garments: [g("t1", .top), g("t2", .top), g("p1", .bottom), g("s1", .shoes), g("u1", .underlayer)])
        var l = WearLedger()
        l.log(WearEntry(date: d("2026-11-01"), garmentIDs: ["t1", "p1", "u1"]))
        l.log(WearEntry(date: d("2026-11-02"), garmentIDs: ["t1", "p1"]))
        l.log(WearEntry(date: d("2026-11-03"), garmentIDs: ["t1"]))
        let r = ClosetReport.make(wardrobe: w, ledger: l)
        #expect(r.mostWorn.map(\.garment.id) == ["t1", "p1"])
        #expect(r.mostWorn.first?.wears == 3)
        #expect(Set(r.neverWorn.map(\.id)) == ["t2", "s1"])
        #expect(r.utilisation == 0.5)
        #expect(!r.isSyntheticExample)
        #expect(ClosetReport.make(wardrobe: Wardrobe(), ledger: l).utilisation == nil)
        let demo = Wardrobe(garments: [g("x", .top, provenance: .syntheticDemo)])
        #expect(ClosetReport.make(wardrobe: demo, ledger: WearLedger()).isSyntheticExample, "a demo closet is labelled as an example")
    }

    @Test("INS-T06: gaps follow plain rules; a complete closet has none; an empty closet is not lectured")
    func gaps() {
        #expect(ClosetGapFinder.gaps(in: Wardrobe()).isEmpty)
        let thin = Wardrobe(garments: [g("t1", .top, neutral: false)])
        let kinds = Set(ClosetGapFinder.gaps(in: thin).map(\.kind))
        #expect(kinds.isSuperset(of: [.noBottoms, .noShoes, .noOuterwear, .noRainProtection, .noFormal, .noSmart, .noNeutralBasics]))
        #expect(!kinds.contains(.noTops))
        let full = Wardrobe(garments: [
            g("t1", .top, .casual ... .smart), g("p1", .bottom, .casual ... .formal), g("s1", .shoes),
            g("c1", .outerwear, claims: [.waterResistant]),
        ])
        #expect(ClosetGapFinder.gaps(in: full).isEmpty, "\(ClosetGapFinder.gaps(in: full).map(\.kind))")
        let lopsided = Wardrobe(garments: (1 ... 8).map { g("t\($0)", .top) } + [g("p1", .bottom)])
        #expect(ClosetGapFinder.gaps(in: lopsided).contains { $0.kind == .fewBottomsForTops && $0.message.contains("8 üste 1 alt") })
        #expect(!ClosetGapFinder.footnote.isEmpty)
    }

    @Test("INS-T07: day needs come from evidence only; a preview never changes advice")
    func dayNeeds() {
        let rainObserved = SceneWeatherState.from(.observed(.rain, source: "Test", at: Date()))
        let n = DayNeeds.make(weather: rainObserved, temperatureC: nil, eventTitles: [])
        #expect(n.needsRainProtection && n.needsOuterwear && n.reasons == ["Yağmur gözlendi"])
        let preview = DayNeeds.make(weather: SceneWeatherState.from(.userPreview(.snow)), temperatureC: nil, eventTitles: [])
        #expect(!preview.needsOuterwear && !preview.needsRainProtection && preview.reasons.isEmpty)
        let stale = DayNeeds.make(weather: SceneWeatherState.from(.observed(.rain, source: "Test", at: Date().addingTimeInterval(-5 * 3600))),
                                  temperatureC: nil, eventTitles: [])
        #expect(!stale.needsRainProtection)
        #expect(DayNeeds.make(weather: nil, temperatureC: 9.6, eventTitles: []).reasons == ["Ölçülen sıcaklık 10°"])
        #expect(!DayNeeds.make(weather: nil, temperatureC: nil, eventTitles: []).needsOuterwear, "no data, no claim")
    }

    @Test("INS-T08: calendar titles set the formality floor (Turkish and English); the strictest wins")
    func calendar() {
        #expect(DayNeeds.make(weather: nil, temperatureC: nil, eventTitles: ["Müşteri TOPLANTISI 10:00"]).minimumFormality == .smart)
        #expect(DayNeeds.make(weather: nil, temperatureC: nil, eventTitles: ["Ayşe'nin düğünü", "Gym"]).minimumFormality == .formal)
        let gym = DayNeeds.make(weather: nil, temperatureC: nil, eventTitles: ["Pilates"])
        #expect(gym.activewear && gym.minimumFormality == .relaxed)
        #expect(DayNeeds.make(weather: nil, temperatureC: nil, eventTitles: ["Diş hekimi"]).reasons.isEmpty)
        #expect(OccasionReader.occasion(in: "İŞ GÖRÜŞMESİ")?.formality == .smart, "Turkish upper case İ/Ş folds")
    }
}
