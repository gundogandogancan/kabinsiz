import AvatarDressing
import DomainContracts
import Foundation
import Testing
@testable import TodayOutfit
import TravelEngine
import WardrobeDomain

@Suite("Today's looks: prepared, honest, from the wardrobe (V25-07)")
struct TodayOutfitTests {
    let date = LocalDate(year: 2026, month: 11, day: 3)!

    @Test("V25-T01: an empty wardrobe gets a labelled synthetic example, never the user's pieces")
    func emptyWardrobe() {
        let looks = TodayOutfitEngine().looks(for: date, wardrobe: Wardrobe())
        #expect(looks.source == .syntheticExample)
        #expect(!looks.looks.isEmpty && looks.looks.count <= 5)
        for look in looks.looks {
            #expect(look.isSyntheticDemo)
            #expect(look.outfit[.top] != nil && look.outfit[.bottom] != nil)
            #expect(look.reasons.first?.contains("sentetik") == true)
            #expect(look.unsupportedClaims.contains { $0.contains("Hava verisi kullanılmadı") })
        }
        #expect(Set(looks.looks.map(\.id)).count == looks.looks.count, "every prepared look is different")
    }

    @Test("Looks come only from the wardrobe's own plannable pieces, deterministically")
    func fromWardrobe() {
        var wardrobe = SyntheticCloset.demo
        wardrobe.setCondition(.inLaundry, for: "syn-bottom-jeans")
        let a = TodayOutfitEngine().looks(for: date, wardrobe: wardrobe)
        let b = TodayOutfitEngine().looks(for: date, wardrobe: wardrobe)
        #expect(a == b)
        #expect(a.source == .wardrobe)
        let ids = Set(wardrobe.garments.map(\.id))
        for look in a.looks {
            #expect(look.outfit.items.values.allSatisfy { ids.contains($0.id) }, "no invented piece")
            #expect(look.outfit[.bottom]?.id != "syn-bottom-jeans", "a piece in the laundry is never proposed")
        }
    }

    @Test("V25-T19: one possible outfit is one look; no fake variety")
    func noFakeVariety() {
        let w = Wardrobe(garments: [
            Garment(id: "t", name: "Beyaz tişört", category: .top, formalityRange: .relaxed ... .smart, colorName: "beyaz", isNeutralColor: true, condition: .clean, provenance: .userEntered),
            Garment(id: "b", name: "Siyah pantolon", category: .bottom, formalityRange: .relaxed ... .smart, colorName: "siyah", isNeutralColor: true, condition: .clean, provenance: .userEntered),
        ])
        let looks = TodayOutfitEngine().looks(for: date, wardrobe: w)
        #expect(looks.source == .wardrobe)
        #expect(looks.looks.count == 1)
        #expect(looks.looks[0].gaps.contains { $0.contains("ayakkabı") }, "missing shoes are said, not drawn")
        #expect(looks.looks[0].outfit[.footwear] == nil)
    }

    @Test("A wardrobe that cannot dress the figure (no bottom) falls back to the labelled example")
    func cannotDress() {
        let w = Wardrobe(garments: [Garment(id: "t", name: "Tişört", category: .top, formalityRange: .casual ... .casual, colorName: "beyaz", isNeutralColor: true, provenance: .userEntered)])
        #expect(TodayOutfitEngine().looks(for: date, wardrobe: w).source == .syntheticExample)
    }

    @Test("Moods re-rank: 'daha cesur' leads with an accent or a layer, 'daha sade' with neutrals only")
    func moods() {
        let engine = TodayOutfitEngine()
        let bold = engine.looks(for: date, wardrobe: SyntheticCloset.studio, mood: .bolder).looks[0].outfit
        #expect(bold.items.values.contains { $0.colorName == "bordo" } || bold[.outerwear] != nil)
        let simple = engine.looks(for: date, wardrobe: SyntheticCloset.studio, mood: .simpler).looks[0].outfit
        #expect(simple.items.values.allSatisfy { $0.colorName != "bordo" })
        let balanced = engine.looks(for: date, wardrobe: SyntheticCloset.studio, mood: .balanced)
        #expect(balanced.looks.map(\.id) != engine.looks(for: date, wardrobe: SyntheticCloset.studio, mood: .relaxed).looks.map(\.id))
    }

    @Test("The pool revision follows every wardrobe change the engine reads")
    func poolRevision() {
        var w = SyntheticCloset.demo
        let r0 = TodayOutfitEngine.revision(w)
        #expect(TodayOutfitEngine.revision(SyntheticCloset.demo) == r0, "stable across calls")
        w.setCondition(.inLaundry, for: "syn-top-white-tee")
        #expect(TodayOutfitEngine.revision(w) != r0)
    }

    @Test("Reasons never state a temperature or weather the engine did not have")
    func noWeatherClaims() {
        for mood in TodayOutfitEngine.Mood.allCases {
            for look in TodayOutfitEngine().looks(for: date, wardrobe: SyntheticCloset.studio, mood: mood).looks {
                for reason in look.reasons {
                    #expect(!reason.contains("°") && !reason.lowercased().contains("yağmur") && !reason.lowercased().contains("soğuk"), "\(reason)")
                }
            }
        }
    }
}
