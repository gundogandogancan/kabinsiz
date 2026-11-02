import DomainContracts
import FitPassport
import Foundation
import Testing
@testable import ShoppingCopilot
@testable import WardrobeDomain

@Suite("v1.3 Fit Passport, decision card, shopping guard")
struct ShoppingAndFitTests {
    let resolver = try! ProductResolver.syntheticCatalog()
    let closet = SyntheticCloset.demo

    func product(_ code: String) throws -> CatalogProduct {
        guard case .found(let p) = resolver.resolve(code) else { throw CocoaError(.featureUnsupported) }
        return p
    }

    // MARK: Quick decision

    @Test("T-V13-001 card is composed with no account, empty passport, no measurements")
    func noAccount() throws {
        let card = DecisionComposer.compose(product: try product("KB-TEE-01-WHT"), passport: FitPassport(), measurements: nil, wardrobe: closet)
        #expect(card.reasons.count <= 3)
        #expect(card.isSyntheticData)
    }

    @Test("T-V13-003 unknown code never becomes a specific product", arguments: ["KB-XXX-99", "123456789012"])
    func unknownCode(code: String) {
        #expect(resolver.resolve(code) == .notFound(normalizedCode: code.uppercased()))
    }

    @Test("T-V13-004 a model code with two colour variants asks which one")
    func ambiguousVariant() {
        guard case .ambiguous(let options) = resolver.resolve("kb-jkt-01") else { Issue.record("expected ambiguous"); return }
        #expect(options.map(\.colorName).sorted() == ["haki", "lacivert"])
    }

    @Test("T-V13-034 malicious or oversized input is rejected before lookup",
          arguments: ["https://evil.example/x?y=1", "KB-TEE-01;rm", String(repeating: "A", count: 41), "", "   "])
    func invalidInput(raw: String) {
        #expect(resolver.resolve(raw) == .invalidInput)
    }

    @Test("T-V13-006 no size chart means no size guarantee")
    func noChart() throws {
        let card = DecisionComposer.compose(product: try product("KB-SHR-03-NVY"), passport: FitPassport(), measurements: UserMeasurements(chestCm: 98), wardrobe: closet)
        guard case .abstain = card.size else { Issue.record("expected abstain, got \(card.size)"); return }
        #expect(card.missingInformation.contains("Beden tablosu"))
    }

    @Test("T-V13-007 P0 visuals are labelled 2D, never product 3D")
    func visualTier() throws {
        let card = DecisionComposer.compose(product: try product("KB-TEE-01-WHT"), passport: FitPassport(), measurements: nil, wardrobe: closet)
        #expect(card.visualTier == .flat2D)
        #expect(card.missingInformation.contains("Ürüne özel 3D görünüm"))
    }

    @Test("T-V13-008 empty wardrobe says 'not added', not 'you don't own it'")
    func emptyWardrobe() throws {
        let card = DecisionComposer.compose(product: try product("KB-JNS-02-BLU"), passport: FitPassport(), measurements: nil, wardrobe: Wardrobe())
        #expect(card.wardrobe.comparison == .wardrobeNotAdded)
        #expect(card.wardrobe.headline == "Dolabın eklenmedi")
    }

    @Test("T-V13-009 / T-V13-052 sponsorship changes only the label")
    func sponsorNeutral() throws {
        let sponsored = try product("KB-SNK-04-WHT")
        let neutral = CatalogProduct(
            code: sponsored.code, modelCode: sponsored.modelCode, brandID: sponsored.brandID, brandName: sponsored.brandName,
            name: sponsored.name, category: sponsored.category, colorName: sponsored.colorName, isNeutralColor: sponsored.isNeutralColor,
            formalityLow: sponsored.formalityLow, formalityHigh: sponsored.formalityHigh, catalogRevision: sponsored.catalogRevision,
            sizeChart: sponsored.sizeChart, materialClaims: sponsored.materialClaims, isSponsored: false, provenance: sponsored.provenance
        )
        let a = DecisionComposer.compose(product: sponsored, passport: FitPassport(), measurements: nil, wardrobe: closet)
        let b = DecisionComposer.compose(product: neutral, passport: FitPassport(), measurements: nil, wardrobe: closet)
        #expect(a.sponsoredLabel == "Sponsorlu")
        #expect(b.sponsoredLabel == nil)
        #expect(a.size == b.size)
        #expect(a.wardrobe == b.wardrobe)
        #expect(a.reasons == b.reasons)
    }

    // MARK: Fit Passport

    @Test("T-V13-019 one observation yields history, never a probability")
    func singleObservation() {
        var passport = FitPassport()
        passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", catalogRevision: 1, markedSize: "M", observedOutcome: .fits))
        let advice = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: 1, chart: nil, measurements: nil)
        #expect(advice == .history(size: "M", outcome: .fits))
        #expect(!advice.headline.contains("%"))
    }

    @Test("Two consistent observations yield a 'likely' size")
    func twoObservations() {
        var passport = FitPassport()
        for _ in 0..<2 { passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", catalogRevision: 1, markedSize: "M", observedOutcome: .fits)) }
        #expect(SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: 1, chart: nil, measurements: nil) == .likely(size: "M", basedOn: 2))
    }

    @Test("T-V13-013 / T-V13-014 learning does not leak across category or brand")
    func scope() {
        var passport = FitPassport()
        for _ in 0..<3 { passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits)) }
        let otherCategory = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .bottom, catalogRevision: nil, chart: nil, measurements: nil)
        let otherBrand = SizeAdvisor.advice(passport: passport, brandID: "ornek-b", category: .top, catalogRevision: nil, chart: nil, measurements: nil)
        guard case .abstain = otherCategory, case .abstain = otherBrand else { Issue.record("leaked: \(otherCategory) \(otherBrand)"); return }
    }

    @Test("T-V13-015 a new catalog revision invalidates old size history")
    func revision() {
        var passport = FitPassport()
        for _ in 0..<2 { passport.record(FitObservation(garmentCategory: .outerwear, brandID: "ornek-a", productModelID: "KB-JKT-01", catalogRevision: 1, markedSize: "L", observedOutcome: .fits)) }
        let advice = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .outerwear, productModelID: "KB-JKT-01", catalogRevision: 2, chart: nil, measurements: nil)
        guard case .abstain(let reason) = advice else { Issue.record("expected abstain"); return }
        #expect(reason.contains("kalıbı"))
    }

    @Test("Review #8: another model's catalog revision does not make a record stale")
    func revisionScopedToModel() {
        var passport = FitPassport()
        for _ in 0..<2 { passport.record(FitObservation(garmentCategory: .outerwear, brandID: "ornek-a", productModelID: "KB-JKT-01", catalogRevision: 1, markedSize: "L", observedOutcome: .fits)) }
        let advice = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .outerwear, productModelID: "KB-JKT-09", catalogRevision: 7, chart: nil, measurements: nil)
        #expect(advice == .likely(size: "L", basedOn: 2))
    }

    @Test("Review #7: a contradicting record blocks 'likely'", arguments: [FitOutcome.tight, .loose])
    func contradiction(_ outcome: FitOutcome) {
        var passport = FitPassport()
        for _ in 0..<2 { passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits)) }
        passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: outcome))
        let advice = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil)
        guard case .abstain(let reason) = advice else { Issue.record("expected abstain, got \(advice)"); return }
        #expect(reason.contains("çelişiyor"))
    }

    @Test("Review #7: two different sizes that both fit → abstain, not a guess")
    func twoFittingSizes() {
        var passport = FitPassport()
        passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits))
        passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "L", observedOutcome: .fits))
        guard case .abstain = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil) else {
            Issue.record("expected abstain"); return
        }
    }

    @Test("T-V13-016 / T-V13-017 editing or deleting a record undoes its inference")
    func editDelete() {
        var passport = FitPassport()
        let a = FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits)
        var b = FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits)
        passport.record(a); passport.record(b)
        #expect(SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil) == .likely(size: "M", basedOn: 2))
        b.observedOutcome = .tight
        passport.update(b)
        #expect(SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil) != .likely(size: "M", basedOn: 2))
        passport.delete(id: b.id)
        #expect(passport.observations.count == 1)
        passport.reset()
        #expect(passport.observations.isEmpty)
    }

    @Test("T-V13-020 learning off or brand excluded → passport ignored")
    func learningOff() {
        var passport = FitPassport()
        for _ in 0..<2 { passport.record(FitObservation(garmentCategory: .top, brandID: "ornek-a", markedSize: "M", observedOutcome: .fits)) }
        passport.learningEnabled = false
        guard case .abstain = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil) else { Issue.record("used data"); return }
        passport.learningEnabled = true
        passport.excludedBrandIDs = ["ornek-a"]
        guard case .abstain = SizeAdvisor.advice(passport: passport, brandID: "ornek-a", category: .top, catalogRevision: nil, chart: nil, measurements: nil) else { Issue.record("used data"); return }
    }

    @Test("Synthetic chart match is labelled as synthetic")
    func chartMatch() throws {
        let card = DecisionComposer.compose(product: try product("KB-TEE-01-WHT"), passport: FitPassport(), measurements: UserMeasurements(chestCm: 98), wardrobe: closet)
        #expect(card.size == .chartMatch(size: "M", chartProvenance: .syntheticDemo))
        #expect(card.size.detail.contains("sentetik"))
        // A boundary value that sits in two rows is ambiguous, so no match.
        let edge = DecisionComposer.compose(product: try product("KB-TEE-01-WHT"), passport: FitPassport(), measurements: UserMeasurements(chestCm: 94), wardrobe: closet)
        guard case .abstain = edge.size else { Issue.record("boundary should abstain"); return }
    }

    // MARK: Shopping guard

    @Test("T-V13-045 similar is 'benzer', and different colour is not similar")
    func similarity() throws {
        let tee = DecisionComposer.compose(product: try product("KB-TEE-01-WHT"), passport: FitPassport(), measurements: nil, wardrobe: closet)
        guard case .similarOwned(let g) = tee.wardrobe.comparison else { Issue.record("expected similar"); return }
        #expect(g.map(\.id) == ["syn-top-white-tee"])
        #expect(tee.wardrobe.headline.contains("benzeri"))
        #expect(!tee.wardrobe.headline.lowercased().contains("aynı"))

        let dress = DecisionComposer.compose(product: try product("OB-DRS-01-RED"), passport: FitPassport(), measurements: nil, wardrobe: closet)
        #expect(dress.wardrobe.comparison == .realGap)
    }

    @Test("T-V13-046 owned pairings are shown before any purchase push")
    func pairings() throws {
        let jacket = DecisionComposer.compose(product: try product("KB-JKT-01-NVY"), passport: FitPassport(), measurements: nil, wardrobe: closet)
        #expect(!jacket.wardrobe.pairsWith.isEmpty)
        #expect(jacket.reasons.contains { $0.hasPrefix("Elindeki") })
    }
}
