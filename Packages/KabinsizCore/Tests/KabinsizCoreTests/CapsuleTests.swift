import DomainContracts
import Foundation
import Testing
@testable import TravelEngine
@testable import WardrobeDomain

@Suite("Capsule packing")
struct CapsuleTests {
    let start = LocalDate("2026-11-10")!

    func demoPlan(weather: any WeatherProvider = NoDataWeatherProvider(), wardrobe: Wardrobe = SyntheticCloset.demo) async -> (Trip, PlanResult) {
        let trip = DemoTrip.barcelona(start: start)
        return (trip, await TripPlanner(weather: weather).plan(trip: trip, wardrobe: wardrobe))
    }

    @Test("T-TRV-042 every slot of the 5-day demo is covered")
    func coverage() async {
        let (trip, result) = await demoPlan()
        #expect(result.plan.solution.isFeasible)
        #expect(Set(result.plan.slots.map(\.localDate)) == Set(trip.dates))
        #expect(result.plan.solution.assignments.count == result.plan.slots.count)
        // Day 3 has a separate evening (dinner) slot.
        #expect(result.plan.slots.filter { $0.dayIndex == 2 }.count == 2)
    }

    @Test("Dinner slot uses evening shoes and smart pieces")
    func dinnerFormality() async throws {
        let (_, result) = await demoPlan()
        let dinner = try #require(result.plan.slots.first { $0.timeBlock == .evening })
        let outfit = try #require(result.plan.outfit(for: dinner.id))
        let closet = SyntheticCloset.demo
        #expect(outfit.garmentIDs.allSatisfy { closet.garment(id: $0)!.covers(.smart) })
        // §56: the smart dinner uses evening shoes and trousers, not the walking sneakers.
        #expect(outfit.garmentIDs.contains("syn-shoes-evening"))
        #expect(outfit.garmentIDs.contains("syn-bottom-trousers"))
    }

    @Test("T-TRV-058 walking days get shoes known to be comfortable")
    func walkingShoes() async {
        let (_, result) = await demoPlan()
        for slot in result.plan.slots where slot.needsWalkingShoes {
            let ids = result.plan.outfit(for: slot.id)?.garmentIDs ?? []
            #expect(ids.contains("syn-shoes-sneakers"), "slot \(slot.id)")
        }
    }

    @Test("T-TRV-043 greedy result matches brute-force optimum on the small fixture")
    func optimality() async throws {
        for preference in [PackingPreference.light, .balanced] {
            var trip = DemoTrip.barcelona(start: start)
            trip.policy.preference = preference
            let result = await TripPlanner(weather: DemoTrip.syntheticWeather(start: start)).plan(trip: trip, wardrobe: SyntheticCloset.demo)
            let optimum = try #require(BruteForceCapsuleSolver.minimumUniquePieces(
                slots: result.plan.slots, candidates: result.plan.candidates, wardrobe: SyntheticCloset.demo, policy: trip.policy
            ))
            #expect(result.plan.uniquePieceCount == optimum, "preference \(preference)")
        }
    }

    @Test("T-TRV-044 an impossible plan names the uncovered slots instead of hiding them")
    func noFeasiblePlan() async {
        // Only casual pieces: the formal dinner cannot be dressed.
        let casual = Wardrobe(garments: SyntheticCloset.demo.garments.filter { !$0.covers(.formal) && $0.formalityRange.upperBound < .smart })
        var trip = DemoTrip.barcelona(start: start)
        trip.events[3].formality = .formal
        let result = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: casual)
        #expect(!result.plan.solution.isFeasible)
        #expect(result.plan.solution.uncoveredSlotIDs.contains { $0.hasSuffix("EVENING") })
        #expect(result.plan.confidence == .partial)
    }

    @Test("T-TRV-046 a locked outfit survives a replan with new weather")
    func lockSurvives() async throws {
        let (trip, first) = await demoPlan()
        var plan = first.plan
        let dinner = try #require(plan.slots.first { $0.timeBlock == .evening })
        plan.setLocked(true, slotID: dinner.id)
        let second = await TripPlanner(weather: DemoTrip.syntheticWeather(start: start)).plan(trip: trip, wardrobe: SyntheticCloset.demo, previous: plan, previousList: first.packingList)
        #expect(second.plan.outfit(for: dinner.id) == plan.outfit(for: dinner.id))
        #expect(second.plan.lockedSlotIDs.contains(dinner.id))
    }

    @Test("T-TRV-047 each garment appears once in the packing list")
    func noDuplicates() async {
        let (_, result) = await demoPlan()
        let owned = result.packingList.items.compactMap(\.garmentID)
        #expect(owned.count == Set(owned).count)
        let reused = result.packingList.items.filter { $0.assignedSlotIDs.count > 1 }
        #expect(!reused.isEmpty, "a 5-day light capsule must reuse something")
    }

    @Test("T-TRV-048 underlayer quantity defaults to days and is editable")
    func underlayers() async throws {
        let (_, result) = await demoPlan()
        var list = result.packingList
        let under = try #require(list.items.first { $0.id == "need-underlayer" })
        #expect(under.quantity == 5)
        list.setQuantity(3, itemID: under.id)
        #expect(list.items.first { $0.id == under.id }?.quantity == 3)
        #expect(list.items.first { $0.id == under.id }?.userEdited == true)
    }

    @Test("T-TRV-049 planning never marks items worn or packed")
    func plannerDoesNotChangeState() async {
        let (_, result) = await demoPlan()
        #expect(result.packingList.items.allSatisfy { !$0.isPacked })
        #expect(result.packingList.items.compactMap(\.garmentID).allSatisfy { id in
            result.packingList.items.first { $0.garmentID == id }?.condition == SyntheticCloset.demo.garment(id: id)?.condition
        })
    }

    @Test("T-TRV-053 unknown weights are not treated as zero")
    func unknownWeight() async {
        let (_, result) = await demoPlan()
        #expect(result.packingList.knownTotalWeightKg == nil)
        #expect(result.packingList.exceedsLimit(7) == nil)
    }

    @Test("T-TRV-054 measured weights over the user's limit raise a real warning")
    func overLimit() async throws {
        var closet = SyntheticCloset.demo
        for g in closet.garments { var w = g; w.weightKg = 0.9; closet.upsert(w) }
        let (_, result) = await demoPlan(wardrobe: closet)
        var list = result.packingList
        // Owned underlayer and sleepwear rows now carry their garment's weight (review #9), so the total is known.
        #expect(list.knownTotalWeightKg != nil)
        // Every unknown row is weighed through the same API the suitcase screen uses.
        for item in list.items where item.weightKg == nil && !item.missing { list.setWeight(0.1, itemID: item.id) }
        #expect(try #require(list.knownTotalWeightKg) > 5)
        #expect(list.exceedsLimit(5) == true)
        #expect(list.exceedsLimit(nil) == nil)
    }

    @Test("T-TRV-056 the light↔variety setting changes the bag predictably")
    func preferenceSlider() async {
        var light = DemoTrip.barcelona(start: start); light.policy.preference = .light
        var variety = light; variety.policy.preference = .variety
        let closet = SyntheticCloset.demo
        let l = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: light, wardrobe: closet)
        let v = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: variety, wardrobe: closet)
        #expect(v.plan.uniquePieceCount >= l.plan.uniquePieceCount)
    }

    @Test("T-TRV-059 rain protection is only claimed with a material claim")
    func rainClaims() async throws {
        let (_, result) = await demoPlan(weather: DemoTrip.syntheticWeather(start: start))
        let rainy = try #require(result.plan.slots.first { $0.weather.rainLikely == true && $0.outdoors })
        let outfit = try #require(result.plan.outfit(for: rainy.id))
        #expect(outfit.gaps.contains("Yağmura dayanıklı olduğu bilinen parça yok"))
        #expect(!outfit.why.contains { $0.contains("dayanıklı") })
    }

    @Test("T-TRV-061 removing a garment invalidates outfits that used it")
    func removedGarment() async {
        let (trip, first) = await demoPlan()
        var closet = SyntheticCloset.demo
        closet.remove(id: "syn-bottom-jeans")
        let second = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: closet, previous: first.plan, previousList: first.packingList)
        #expect(!second.plan.solution.packedGarmentIDs.contains("syn-bottom-jeans"))
        #expect(!second.packingList.items.contains { $0.garmentID == "syn-bottom-jeans" })
    }

    @Test("T-TRV-062 a weather update produces a diff and keeps packed ticks")
    func weatherDiff() async throws {
        let (trip, first) = await demoPlan()
        var list = first.packingList
        let packedItem = try #require(list.items.first { $0.garmentID != nil })
        list.setPacked(true, itemID: packedItem.id)
        let second = await TripPlanner(weather: DemoTrip.syntheticWeather(start: start)).plan(trip: trip, wardrobe: SyntheticCloset.demo, previous: first.plan, previousList: list)
        let packedIDs = Set(list.items.filter(\.isPacked).compactMap(\.garmentID))
        let diff = TripPlanDiff.between(old: first.plan, new: second.plan, packedGarmentIDs: packedIDs, reason: .weather)
        #expect(diff.newRevision == first.plan.revision + 1)
        #expect(!diff.isEmpty, "cool synthetic weather must add a layer somewhere")
        #expect(diff.requiresApproval)
        #expect(try #require(second.packingList.items.first { $0.id == packedItem.id }).isPacked == true)
    }

    @Test("Review #1: a lock that exceeds the reuse limit does not empty the other slots")
    func conflictingLock() async throws {
        let (trip, first) = await demoPlan()
        var plan = first.plan
        let locked = plan.slots.filter { $0.dayIndex < 2 }.map(\.id)
        for id in locked { plan.setLocked(true, slotID: id) }
        var strict = trip
        for c in GarmentCategory.allCases { strict.policy.rewearDaysByCategory[c] = 1 }
        let second = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: strict, wardrobe: SyntheticCloset.demo, previous: plan, previousList: first.packingList)
        #expect(second.plan.solution.assignments.count == second.plan.slots.count)
        for id in locked { #expect(second.plan.outfit(for: id) == plan.outfit(for: id)) }
    }

    @Test("A locked dinner does not let its pieces be reused past the limit on other days")
    func lockDoesNotLiftLimitElsewhere() async throws {
        let (trip, first) = await demoPlan()
        var plan = first.plan
        let dinner = try #require(plan.slots.first { $0.timeBlock == .evening })
        plan.setLocked(true, slotID: dinner.id)
        let second = await TripPlanner(weather: DemoTrip.syntheticWeather(start: start)).plan(trip: trip, wardrobe: SyntheticCloset.demo, previous: plan, previousList: first.packingList)
        let dayBySlot = Dictionary(uniqueKeysWithValues: second.plan.slots.map { ($0.id, $0.dayIndex) })
        var days: [String: Set<Int>] = [:]
        for (slotID, outfit) in second.plan.solution.assignments where slotID != dinner.id {
            for id in outfit.garmentIDs { days[id, default: []].insert(dayBySlot[slotID]!) }
        }
        for (id, used) in days {
            let category = try #require(SyntheticCloset.demo.garment(id: id)).category
            #expect(used.count <= trip.policy.rewearDays(for: category), "\(id) worn on \(used.count) other days")
        }
    }

    @Test("Review #2: a manual swap keeps every packed garment row and its tick")
    func swapKeepsPacked() async throws {
        let (trip, first) = await demoPlan()
        var list = first.packingList
        for item in list.items where item.garmentID != nil { list.setPacked(true, itemID: item.id) }
        let packed = Set(list.items.filter(\.isPacked).compactMap(\.garmentID))
        var plan = first.plan
        var swapped = 0
        for slot in plan.slots {
            if let other = plan.candidates[slot.id]?.first(where: { $0 != plan.outfit(for: slot.id) }) { plan.choose(other); swapped += 1 }
        }
        #expect(swapped > 0)
        let rebuilt = TripPlanner.packingList(trip: trip, plan: plan, wardrobe: SyntheticCloset.demo, previous: list)
        for id in packed {
            let row = try #require(rebuilt.items.first { $0.garmentID == id }, "packed \(id) was dropped")
            #expect(row.isPacked)
        }
        let used = Set(plan.solution.assignments.values.flatMap(\.garmentIDs))
        #expect(rebuilt.items.filter { $0.id.hasPrefix("owned-") && $0.garmentID.map { !used.contains($0) } ?? false }.allSatisfy(rebuilt.isUnplannedButPacked))
    }

    @Test("Review #6: the variety setting does not invent uncovered slots")
    func varietyNoFalseGaps() async {
        var trip = DemoTrip.barcelona(start: start); trip.policy.preference = .variety
        let result = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: SyntheticCloset.demo)
        #expect(result.plan.solution.isFeasible)
        #expect(result.plan.solution.uncoveredSlotIDs.isEmpty)
    }

    @Test("Review #9: a weight the user enters survives a replan and can trigger the limit")
    func weightSurvivesReplan() async throws {
        let (trip, first) = await demoPlan()
        var list = first.packingList
        for item in list.items where !item.missing { list.setWeight(1.5, itemID: item.id) }
        #expect(list.exceedsLimit(5) == true)
        let second = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: SyntheticCloset.demo, previous: first.plan, previousList: list)
        let shirt = try #require(list.items.first { $0.garmentID != nil })
        #expect(second.packingList.items.first { $0.id == shirt.id }?.weightKg == 1.5)
        #expect(second.packingList.items.first { $0.id == "need-underlayer" }?.weightKg == 1.5)
    }

    @Test("T-TRV-065 bottoms reused across days stay in their wardrobe condition")
    func reuseNotDirty() async {
        let (_, result) = await demoPlan()
        for item in result.packingList.items where item.category == .bottom {
            #expect(item.condition == .clean)
        }
    }

    @Test("T-TRV-066 manual suitcase rows survive a replan")
    func manualRows() async {
        let (trip, first) = await demoPlan()
        var list = first.packingList
        list.addManual(title: "Şarj aleti", category: .accessory)
        let second = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: SyntheticCloset.demo, previous: first.plan, previousList: list)
        #expect(second.packingList.items.contains { $0.title == "Şarj aleti" && $0.source == .userEntered })
    }

    @Test("T-TRV-002 empty wardrobe still yields a generic list and explicit gaps")
    func emptyWardrobe() async {
        let (_, result) = await demoPlan(wardrobe: Wardrobe())
        #expect(!result.plan.solution.isFeasible)
        #expect(result.packingList.items.contains { $0.source == .genericNeed && $0.category == .underlayer })
    }

    @Test("Laundry availability unlocks more reuse")
    func laundry() {
        #expect(PackingPolicy(laundryAccess: .yes).rewearDays(for: .top) > PackingPolicy(laundryAccess: .no).rewearDays(for: .top))
        #expect(PackingPolicy(laundryAccess: .yes).rewearDays(for: .underlayer) == 1)
    }

    @Test("T-TRV-064 500-garment / 14-day plan stays bounded", .timeLimit(.minutes(1)))
    func performance() async {
        let closet = SyntheticCloset.generated(count: 500)
        let dates = (0..<14).map { start.adding(days: $0) }
        let events = dates.enumerated().flatMap { i, d in
            [TripEvent(id: "a\(i)", localDate: d, timeBlock: .morning, activity: i % 2 == 0 ? .cityWalk : .business),
             TripEvent(id: "b\(i)", localDate: d, timeBlock: .evening, activity: .dinner)]
        }
        let trip = Trip(id: "perf", title: "perf", destination: CityDirectory.entries[0], dates: dates, events: events, policy: .init(), isSyntheticDemo: true)
        let clock = ContinuousClock()
        var result: PlanResult?
        let elapsed = await clock.measure {
            result = await TripPlanner(weather: NoDataWeatherProvider()).plan(trip: trip, wardrobe: closet)
        }
        print("PERF T-TRV-064 500 garments / 14 days / 28 slots: \(elapsed) (macOS M5, debug, SIMULATED_NOT_DEVICE)")
        #expect(result?.plan.slots.count == 28)
        #expect(elapsed < .seconds(10))
    }
}
