import DomainContracts
import FitPassport
import Foundation
import LocalStore
import Observation
import ShoppingCopilot
import TravelEngine
import WardrobeDomain

/// Single source of truth for the app. All state is device-local (ADR-002); nothing here talks to a network.
@MainActor
@Observable
final class AppModel {
    private(set) var wardrobe = Wardrobe()
    var passport = FitPassport()
    var measurements = UserMeasurements()
    private(set) var trips: [Trip] = []
    private(set) var plans: [String: TripPlan] = [:]
    private(set) var packingLists: [String: PackingList] = [:]
    /// A replan waiting for the user's approval, per trip (§42.4).
    /// Stores the new weather, not a snapshot of the plan, so approval re-applies it to the *current* plan.
    private(set) var pendingReplans: [String: (weather: [LocalDate: WeatherSnapshot], diff: TripPlanDiff)] = [:]
    private(set) var loadError: String?
    var isPlanning = false

    let catalog: ProductResolver
    private let store: LocalStore?
    /// Collections that exist on disk but could not be read. We refuse to overwrite them (no silent data loss).
    private var unreadable: Set<String> = []
    /// Saves run one after another so an older write can never land after a newer one.
    private var lastSave: Task<Void, Never>?

    init(store: LocalStore? = try? LocalStore.applicationSupport()) {
        self.store = store
        catalog = (try? ProductResolver.syntheticCatalog()) ?? ProductResolver(products: [])
    }

    // MARK: Loading

    func load() async {
        guard let store else { loadError = "Yerel depo açılamadı."; return }
        wardrobe = await read(Wardrobe.self, "wardrobe", Wardrobe.schemaVersion, from: store) ?? Wardrobe()
        passport = await read(FitPassport.self, "fit-passport", FitPassport.schemaVersion, from: store) ?? FitPassport()
        measurements = await read(UserMeasurements.self, "measurements", 1, from: store) ?? UserMeasurements()
        trips = await read([Trip].self, "trips", Trip.schemaVersion, from: store) ?? []
        for trip in trips {
            plans[trip.id] = await read(TripPlan.self, "plan-\(trip.id)", TripPlan.schemaVersion, from: store)
            packingLists[trip.id] = await read(PackingList.self, "packing-\(trip.id)", PackingList.schemaVersion, from: store)
        }
        if !unreadable.isEmpty {
            loadError = "Bazı kayıtlar okunamadı (\(unreadable.sorted().joined(separator: ", "))). Silinmediler ve üzerlerine yazılmayacak."
        }
    }

    /// Each collection loads on its own; one bad file never blocks or endangers the others.
    private func read<T: Codable & Sendable>(_ type: T.Type, _ name: String, _ version: Int, from store: LocalStore) async -> T? {
        do { return try await store.load(type, from: name, currentVersion: version) } catch {
            unreadable.insert(name)
            return nil
        }
    }

    // MARK: Wardrobe

    func loadSyntheticCloset() {
        for garment in SyntheticCloset.demo.garments { wardrobe.upsert(garment) }
        persistWardrobe()
    }

    func upsert(_ garment: Garment) {
        wardrobe.upsert(garment)
        persistWardrobe()
    }

    func removeGarment(id: String) {
        wardrobe.remove(id: id)
        persistWardrobe()
    }

    func setCondition(_ condition: ItemCondition, garmentID: String) {
        wardrobe.setCondition(condition, for: garmentID)
        persistWardrobe()
    }

    private func persistWardrobe() {
        let value = wardrobe
        save(["wardrobe"]) { try await $0.save(value, as: "wardrobe", schemaVersion: Wardrobe.schemaVersion) }
    }

    // MARK: Fit Passport

    func record(_ observation: FitObservation) {
        passport.record(observation)
        persistPassport()
    }

    func deleteObservation(id: UUID) {
        passport.delete(id: id)
        persistPassport()
    }

    func persistPassport() {
        let value = passport, m = measurements
        save(["fit-passport", "measurements"]) {
            try await $0.save(value, as: "fit-passport", schemaVersion: FitPassport.schemaVersion)
            try await $0.save(m, as: "measurements", schemaVersion: 1)
        }
    }

    func resetPassport() {
        passport.reset()
        measurements = UserMeasurements()
        persistPassport()
    }

    // MARK: Travel

    func weatherProvider(for trip: Trip) -> any WeatherProvider {
        // WeatherKit is BLOCKED_EXTERNAL. Only the labelled demo trip gets synthetic weather.
        trip.isSyntheticDemo ? DemoTrip.syntheticWeather(start: trip.dates[0]) : NoDataWeatherProvider()
    }

    func createTrip(_ trip: Trip) async {
        var trip = trip
        trip.state = .planned
        trips.removeAll { $0.id == trip.id }
        trips.append(trip)
        await plan(tripID: trip.id)
        persistTrips()
    }

    func createDemoTrip() async {
        let today = LocalDate(instant: Date(), timeZone: TimeZone(identifier: "Europe/Madrid")!)
        if wardrobe.isEmpty { loadSyntheticCloset() }
        await createTrip(DemoTrip.barcelona(start: today.adding(days: 7)))
    }

    func trip(id: String) -> Trip? { trips.first { $0.id == id } }

    func plan(tripID: String) async {
        guard let trip = trip(id: tripID) else { return }
        isPlanning = true
        defer { isPlanning = false }
        let result = await TripPlanner(weather: weatherProvider(for: trip)).plan(
            trip: trip, wardrobe: wardrobe, previous: plans[tripID], previousList: packingLists[tripID]
        )
        plans[tripID] = result.plan
        packingLists[tripID] = result.packingList
        persistPlan(tripID)
    }

    /// Demo of TRV-13: new synthetic weather arrives; we compute a diff and wait for approval.
    func simulateWeatherUpdate(tripID: String) async {
        guard let trip = trip(id: tripID) else { return }
        let colder = FixtureWeatherProvider(trip.dates.enumerated().map { i, d in
            FixtureWeatherProvider.day(d, low: Double(6 + i), high: Double(12 + i), rain: i == 3 ? 0.8 : 0.2)
        })
        let snapshots = await colder.snapshots(for: trip.destination, dates: trip.dates)
        proposeReplan(tripID: tripID, weather: Dictionary(uniqueKeysWithValues: snapshots.map { ($0.localDate, $0) }))
    }

    private func proposeReplan(tripID: String, weather: [LocalDate: WeatherSnapshot]) {
        guard let trip = trip(id: tripID), let current = plans[tripID] else { return }
        let result = TripPlanner(weather: weatherProvider(for: trip)).replan(
            trip: trip, wardrobe: wardrobe, weatherByDate: weather, previous: current, previousList: packingLists[tripID]
        )
        let packed = Set(packingLists[tripID]?.items.filter(\.isPacked).compactMap(\.garmentID) ?? [])
        pendingReplans[tripID] = (weather, TripPlanDiff.between(old: current, new: result.plan, packedGarmentIDs: packed, reason: .weather))
    }

    /// Applies the new weather to the plan as it is *now*. If the user edited the plan after the proposal
    /// was shown, the proposal is refreshed instead, so the user never approves a diff they did not see.
    func approveReplan(tripID: String) {
        guard let pending = pendingReplans[tripID], let trip = trip(id: tripID), let current = plans[tripID] else { return }
        if current.revision != pending.diff.oldRevision {
            proposeReplan(tripID: tripID, weather: pending.weather)
            return
        }
        let result = TripPlanner(weather: weatherProvider(for: trip)).replan(
            trip: trip, wardrobe: wardrobe, weatherByDate: pending.weather, previous: current, previousList: packingLists[tripID]
        )
        pendingReplans[tripID] = nil
        plans[tripID] = result.plan
        packingLists[tripID] = result.packingList
        persistPlan(tripID)
    }

    func rejectReplan(tripID: String) { pendingReplans[tripID] = nil }

    func choose(_ candidate: OutfitCandidate, tripID: String) {
        guard var plan = plans[tripID], let trip = trip(id: tripID) else { return }
        plan.choose(candidate)
        plans[tripID] = plan
        packingLists[tripID] = TripPlanner.packingList(trip: trip, plan: plan, wardrobe: wardrobe, previous: packingLists[tripID])
        persistPlan(tripID)
    }

    func setLocked(_ locked: Bool, slotID: String, tripID: String) {
        plans[tripID]?.setLocked(locked, slotID: slotID)
        plans[tripID]?.revision += 1
        persistPlan(tripID)
    }

    func setPacked(_ packed: Bool, itemID: String, tripID: String) {
        packingLists[tripID]?.setPacked(packed, itemID: itemID)
        persistPlan(tripID)
    }

    func setQuantity(_ quantity: Int, itemID: String, tripID: String) {
        packingLists[tripID]?.setQuantity(quantity, itemID: itemID)
        persistPlan(tripID)
    }

    func setWeight(_ kg: Double?, itemID: String, tripID: String) {
        packingLists[tripID]?.setWeight(kg, itemID: itemID)
        persistPlan(tripID)
    }

    func addManualItem(title: String, tripID: String) {
        packingLists[tripID]?.addManual(title: title, category: .accessory)
        persistPlan(tripID)
    }

    /// Removes the trip, its plan, packing list and cached weather. Wardrobe and passport stay (T-TRV-013).
    func deleteTrip(id: String) {
        trips.removeAll { $0.id == id }
        plans[id] = nil
        packingLists[id] = nil
        pendingReplans[id] = nil
        persistTrips()
        save(["plan-\(id)", "packing-\(id)"]) {
            try await $0.delete(collection: "plan-\(id)")
            try await $0.delete(collection: "packing-\(id)")
        }
    }

    /// Wipes everything on this device (§11, §34). Separate from per-trip and passport deletion.
    func deleteAllData() {
        wardrobe = Wardrobe()
        passport = FitPassport()
        measurements = UserMeasurements()
        let ids = trips.map(\.id)
        trips = []
        plans = [:]
        packingLists = [:]
        pendingReplans = [:]
        // Explicit user request: this is the one path allowed to remove unreadable files too.
        unreadable = []
        loadError = nil
        save([]) { store in
            for c in ["wardrobe", "fit-passport", "measurements", "trips"] { try await store.delete(collection: c) }
            for id in ids {
                try await store.delete(collection: "plan-\(id)")
                try await store.delete(collection: "packing-\(id)")
            }
        }
    }

    private func persistTrips() {
        let value = trips
        save(["trips"]) { try await $0.save(value, as: "trips", schemaVersion: Trip.schemaVersion) }
    }

    private func persistPlan(_ tripID: String) {
        let plan = plans[tripID], list = packingLists[tripID]
        save(["plan-\(tripID)", "packing-\(tripID)"]) {
            if let plan { try await $0.save(plan, as: "plan-\(tripID)", schemaVersion: TripPlan.schemaVersion) }
            if let list { try await $0.save(list, as: "packing-\(tripID)", schemaVersion: PackingList.schemaVersion) }
        }
    }

    private func save(_ collections: [String], _ work: @escaping @Sendable (LocalStore) async throws -> Void) {
        guard let store else { return }
        let blocked = collections.filter(unreadable.contains)
        guard blocked.isEmpty else {
            loadError = "\(blocked.joined(separator: ", ")) okunamadığı için değişiklik kaydedilmedi. Mevcut dosya korunuyor."
            return
        }
        let previous = lastSave
        lastSave = Task {
            await previous?.value
            do { try await work(store) } catch { self.loadError = "Kaydedilemedi: \(error)" }
        }
    }
}
