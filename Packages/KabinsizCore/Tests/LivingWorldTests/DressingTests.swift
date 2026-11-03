@testable import AvatarDressing
import BodyGeometry
import DomainContracts
import Foundation
import Testing
import WardrobeDomain

@Suite("Avatar dressing: slots, appearance, undo and races (V25-03/04)")
struct DressingTests {
    func item(_ id: String, _ slot: GarmentSlotID, _ form: GarmentForm, synthetic: Bool = true) -> DressItem {
        DressItem(id: id, name: id, slot: slot, form: form, colorHex: 0x808080, colorName: "gri", provenance: synthetic ? .syntheticDemo : .userEntered)
    }

    @Test("The demo closet maps to honest shapes; underlayers are not drawn; colours come from the colour word")
    func appearance() throws {
        let closet = SyntheticCloset.demo
        func form(_ id: String) -> GarmentForm? { closet.garment(id: id).flatMap(GarmentAppearance.dressItem(for:))?.form }
        #expect(form("syn-top-white-tee") == .tee)
        #expect(form("syn-top-overshirt") == .shirt)
        #expect(form("syn-top-casual-shirt") == .shirt)
        #expect(form("syn-bottom-trousers") == .trousers)
        #expect(form("syn-bottom-jeans") == .jeans)
        #expect(form("syn-outer-light-jacket") == .jacket)
        #expect(form("syn-shoes-sneakers") == .sneakers)
        #expect(form("syn-shoes-evening") == .loafers)
        #expect(form("syn-under-socks") == nil)
        #expect(GarmentAppearance.color(named: "Lacivert") == 0x1F2A44)
        #expect(GarmentAppearance.color(named: "açık mavi") == 0x9DB4CC, "longest colour word wins")
        #expect(GarmentAppearance.color(named: "gece yarısı tonu") == 0x9A9590, "unknown → neutral grey, not invented")
        let studio = SyntheticCloset.studio.garments.compactMap(GarmentAppearance.dressItem(for:))
        #expect(Set(studio.map(\.slot)).isSuperset(of: [.top, .bottom, .outerwear, .footwear, .belt, .bag, .otherAccessory]))
        #expect(studio.allSatisfy { $0.tier == .t1 && $0.provenance.isSynthetic && !$0.tier.mayInformSizeAdvice })
    }

    @Test("A dress replaces top and bottom; putting on a top takes the dress off; identity is the piece set")
    func outfitRules() {
        let base = DressedOutfit([item("t", .top, .tee), item("b", .bottom, .jeans), item("s", .footwear, .sneakers)])
        #expect(base.slots == [.top, .bottom, .footwear])
        let swapped = base.replacing(item("k", .top, .knit))
        #expect(swapped[.top]?.id == "k" && swapped[.bottom]?.id == "b" && swapped[.footwear]?.id == "s", "other slots unchanged")
        #expect(DressedOutfit([item("b", .bottom, .jeans), item("t", .top, .tee), item("s", .footwear, .sneakers)]).id == base.id)
        #expect(base.tier == .t1 && DressedOutfit([]).tier == .t0)
        #expect(base.isSynthetic && !DressedOutfit([item("x", .top, .tee, synthetic: false)]).isSynthetic)
    }

    @Test("V25-T17: undo restores the full slot state; redo returns; a new change clears redo")
    func undoRedo() throws {
        let start = DressedOutfit([item("t", .top, .tee), item("b", .bottom, .jeans), item("s", .footwear, .sneakers)])
        var state = DressedAvatarState(outfit: start)
        try state.apply(.init(action: .replace(item("k", .top, .knit)), basedOnRevision: 0))
        try state.apply(.init(action: .replace(item("bt", .footwear, .boots)), basedOnRevision: 1))
        #expect(state.outfit[.top]?.id == "k" && state.outfit[.footwear]?.id == "bt")
        try state.apply(.init(action: .undo, basedOnRevision: 2))
        #expect(state.outfit[.top]?.id == "k" && state.outfit[.footwear]?.id == "s")
        try state.apply(.init(action: .undo, basedOnRevision: 3))
        #expect(state.outfit == start)
        #expect(throws: DressingRefusal.nothingToUndo) { try state.apply(.init(action: .undo, basedOnRevision: 4)) }
        try state.apply(.init(action: .redo, basedOnRevision: 4))
        #expect(state.outfit[.top]?.id == "k")
        try state.apply(.init(action: .wear(DressedOutfit([item("x", .top, .shirt), item("y", .bottom, .trousers)])), basedOnRevision: 5))
        #expect(!state.canRedo)
        #expect(throws: DressingRefusal.nothingToRedo) { try state.apply(.init(action: .redo, basedOnRevision: 6)) }
    }

    @Test("V25-T15: a result based on an older revision never puts an older look back; commands apply once")
    func raceAndDuplicates() throws {
        var state = DressedAvatarState(outfit: DressedOutfit([item("t", .top, .tee), item("b", .bottom, .jeans)]))
        let slow = OutfitChangeRequest(action: .replace(item("old", .top, .shirt)), basedOnRevision: 0)
        let fast = OutfitChangeRequest(action: .replace(item("new", .top, .knit)), basedOnRevision: 0)
        try state.apply(fast)
        #expect(throws: DressingRefusal.staleRevision) { try state.apply(slow) }
        #expect(state.outfit[.top]?.id == "new")
        #expect(throws: DressingRefusal.duplicateCommand) { try state.apply(fast) }
        #expect(throws: DressingRefusal.requiredSlot) { try state.apply(.init(action: .remove(.top), basedOnRevision: 1)) }
        try state.apply(.init(action: .replace(item("belt", .belt, .belt)), basedOnRevision: 1))
        try state.apply(.init(action: .remove(.belt), basedOnRevision: 2))
        #expect(state.outfit[.belt] == nil && state.revision == 3)
    }

    @Test("History is bounded on the device")
    func historyLimit() throws {
        var state = DressedAvatarState(outfit: DressedOutfit([item("t0", .top, .tee), item("b", .bottom, .jeans)]))
        for k in 1...50 { try state.apply(.init(action: .replace(item("t\(k)", .top, .tee)), basedOnRevision: k - 1)) }
        var undone = 0
        while state.canUndo { try state.apply(.init(action: .undo, basedOnRevision: state.revision)); undone += 1 }
        #expect(undone == DressedAvatarState.historyLimit)
    }
}
