import DomainContracts
import FitPassport
import Foundation
import LocalStore
import Observation
import ShoppingCopilot
import SystemContracts
import TravelEngine
import Vault
import WardrobeDomain

/// Where each piece of state lives in the vault (§116.1 PrivateVault). Record IDs equal the old
/// LocalStore collection names, so the plaintext migration and the "unreadable" guard share one name.
enum Records {
    static let wardrobe = VaultRecordSpec(id: "wardrobe", type: "wardrobe", domain: .wardrobe)
    static let passport = VaultRecordSpec(id: "fit-passport", type: "fit-passport", domain: .preferences)
    static let measurements = VaultRecordSpec(id: "measurements", type: "measurements", domain: .body, classification: .localSensitive)
    static let trips = VaultRecordSpec(id: "trips", type: "trips", domain: .travel)
    static let consent = VaultRecordSpec(id: "consent", type: "consent", domain: .preferences)
    static func plan(_ tripID: String) -> VaultRecordSpec { VaultRecordSpec(id: "plan-\(tripID)", type: "plan", domain: .travel) }
    static func packing(_ tripID: String) -> VaultRecordSpec {
        VaultRecordSpec(id: "packing-\(tripID)", type: "packing", domain: .travel, derivedFrom: ["plan-\(tripID)"])
    }
}

/// How the app reaches its vault. UI tests point it at a throwaway directory and Keychain item.
struct VaultLocation: Sendable {
    let directory: URL
    let keyStore: any KeyStore
    /// Pre-v1.5 plaintext store, migrated and then removed (WP15-04).
    let legacyDirectory: URL?

    static func standard() throws -> VaultLocation {
        let base = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return VaultLocation(directory: try Vault.defaultDirectory(), keyStore: KeychainKeyStore(),
                             legacyDirectory: base.appendingPathComponent("Kabinsiz", isDirectory: true))
    }
}

/// Single source of truth for the app. All state is device-local in the encrypted vault (§111, §116);
/// the only network path is the user-tapped forecast, and it goes through `CitadelGate` (§112.2).
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
    private let location: VaultLocation?
    private var vault: Vault?
    /// Capabilities, consent and the single egress path. Starts with forecasts revoked and is rebuilt
    /// from the stored ledger on load: until consent is known, nothing may leave (fail closed).
    private var gate = CitadelGate(registry: .p0(), ledger: AppModel.closedLedger)
    private static var closedLedger: ConsentLedger {
        var ledger = ConsentLedger()
        ledger.revoke(.weatherFetch)
        return ledger
    }
    private var loadStarted = false
    /// Whether the user allows forecast requests at all (Profil → Gizlilik). Off stops even the tap.
    private(set) var weatherConsent: ConsentState = .notAsked
    /// Shown after "delete everything": counts and the copies a local delete cannot reach (§116.3).
    private(set) var lastDeletionReceipt: DeletionReceipt?
    /// Records that exist but could not be read. We refuse to overwrite them (no silent data loss).
    private var unreadable: Set<String> = []
    /// Saves run one after another so an older write can never land after a newer one.
    private var lastSave: Task<Void, Never>?

    init(location: VaultLocation? = try? VaultLocation.standard()) {
        self.location = location
        catalog = (try? ProductResolver.syntheticCatalog()) ?? ProductResolver(products: [])
    }

    // MARK: Loading

    /// Runs once, as the first job of the save queue: no save, toggle or "delete everything" can run
        /// before the vault is open and the plaintext migration is done. Later calls just wait for it.
    func load() async {
        if !loadStarted {
            loadStarted = true
            let previous = lastSave
            lastSave = Task {
                await previous?.value
                await self.openAndRead()
            }
        }
        await lastSave?.value
    }

    private func openAndRead() async {
        guard let location else { loadError = "Yerel kasa açılamadı."; return }
        let vault: Vault
        do {
            vault = try Vault.open(directory: location.directory, keyStore: location.keyStore)
        } catch {
            // Never create new keys over data we cannot read (V15-T-CRY-04/06). The user can reset from Profil.
            switch error as? VaultError {
            case .keyUnavailable?:
                loadError = "Şifreli kasanın anahtarı şu an okunamıyor. Veriler silinmedi; cihaz kilidi açıkken tekrar dene."
            case .keyLost?:
                loadError = "Şifreleme anahtarı bu cihazda yok (ör. şifresiz yedekten geri yükleme). Kasa okunamıyor; Profil'den sıfırlayabilirsin."
            default:
                loadError = "Şifreli kasa okunamadı. Hiçbir şey silinmedi."
            }
            return
        }
        self.vault = vault
        if let legacy = location.legacyDirectory { await migrateLegacy(from: legacy, into: vault) }

        wardrobe = await read(Wardrobe.self, Records.wardrobe, Wardrobe.schemaVersion, from: vault) ?? Wardrobe()
        passport = await read(FitPassport.self, Records.passport, FitPassport.schemaVersion, from: vault) ?? FitPassport()
        measurements = await read(UserMeasurements.self, Records.measurements, 1, from: vault) ?? UserMeasurements()
        trips = await read([Trip].self, Records.trips, Trip.schemaVersion, from: vault) ?? []
        for trip in trips {
            plans[trip.id] = await read(TripPlan.self, Records.plan(trip.id), TripPlan.schemaVersion, from: vault)
            packingLists[trip.id] = await read(PackingList.self, Records.packing(trip.id), PackingList.schemaVersion, from: vault)
        }
        // Missing ledger = never asked. Unreadable ledger = unknown, so forecasts stay off until the user decides.
        let stored = await read(ConsentLedger.self, Records.consent, ConsentLedger.schemaVersion, from: vault)
        let ledger = unreadable.contains(Records.consent.id) ? Self.closedLedger : (stored ?? ConsentLedger())
        gate = CitadelGate(registry: .p0(), ledger: ledger)
        weatherConsent = ledger.state(.weatherFetch)
        if !unreadable.isEmpty {
            loadError = "Bazı kayıtlar okunamadı (\(unreadable.sorted().joined(separator: ", "))). Silinmediler ve üzerlerine yazılmayacak."
        }
    }

    /// Each record loads on its own; one bad record never blocks or endangers the others.
    private func read<T: Codable & Sendable>(_ type: T.Type, _ spec: VaultRecordSpec, _ version: Int, from vault: Vault) async -> T? {
        do { return try await vault.get(type, id: spec.id, currentVersion: version) } catch {
            unreadable.insert(spec.id)
            return nil
        }
    }

    /// Moves pre-v1.5 plaintext files into the vault. A file that fails stays where it is and its record
    /// is marked unreadable, so nothing overwrites it until the user decides (§68 no silent data loss).
    private func migrateLegacy(from directory: URL, into vault: Vault) async {
        guard FileManager.default.fileExists(atPath: directory.path), let legacy = try? LocalStore(directory: directory) else { return }
        func move<T: Codable & Sendable>(_ type: T.Type, _ version: Int, _ spec: VaultRecordSpec) async {
            do { _ = try await LegacyImport.move(type, collection: spec.id, version: version, from: legacy, into: vault, as: spec) } catch {
                unreadable.insert(spec.id)
            }
        }
        await move(Wardrobe.self, Wardrobe.schemaVersion, Records.wardrobe)
        await move(FitPassport.self, FitPassport.schemaVersion, Records.passport)
        await move(UserMeasurements.self, 1, Records.measurements)
        await move([Trip].self, Trip.schemaVersion, Records.trips)
        let tripIDs = ((try? await vault.get([Trip].self, id: Records.trips.id, currentVersion: Trip.schemaVersion)) ?? nil)?.map(\.id) ?? []
        for id in tripIDs {
            await move(TripPlan.self, TripPlan.schemaVersion, Records.plan(id))
            await move(PackingList.self, PackingList.schemaVersion, Records.packing(id))
        }
        LegacyImport.removeIfEmpty(legacy)
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
        save([Records.wardrobe.id]) { try await $0.put(value, Records.wardrobe, schemaVersion: Wardrobe.schemaVersion) }
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
        save([Records.passport.id, Records.measurements.id]) {
            try await $0.put(value, Records.passport, schemaVersion: FitPassport.schemaVersion)
            try await $0.put(m, Records.measurements, schemaVersion: 1)
        }
    }

    func resetPassport() {
        passport.reset()
        measurements = UserMeasurements()
        persistPassport()
    }

    // MARK: Travel

    func weatherProvider(for trip: Trip) -> any WeatherProvider {
        // Planning never requests weather on its own. The labelled demo gets synthetic weather; real trips get
        // live weather only through `fetchLiveWeather`, which the user triggers.
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

    /// Last result of a live forecast request, shown under the button. Not persisted.
    private(set) var weatherStatus: [String: String] = [:]
    /// Trips with a forecast request in flight; the button is disabled so taps cannot stack requests.
    private(set) var weatherInFlight: Set<String> = []

    /// Explicit user tap only (§112.2). Sends the destination's city-centre point to Apple Weather and,
    /// like any weather change, shows a diff to approve instead of rewriting the plan.
    func fetchLiveWeather(tripID: String) async {
        guard let trip = trip(id: tripID), !trip.isSyntheticDemo, !weatherInFlight.contains(tripID) else { return }
        guard CityDirectory.cityCenter(for: trip.destination) != nil else {
            weatherStatus[tripID] = "Bu şehrin konumu kayıtlı değil; hava tahmini alınamıyor."
            return
        }
        weatherStatus[tripID] = "Tahmin isteniyor…"
        weatherInFlight.insert(tripID)
        defer { weatherInFlight.remove(tripID) }
        do {
            let snapshots = try await AppleWeatherProvider(gate: gate).fetch(destination: trip.destination, dates: trip.dates)
            let live = snapshots.filter { $0.evidence != .noData }.count
            weatherStatus[tripID] = live == 0
                ? "Seyahat günlerin tahmin aralığının dışında. Tarih yaklaşınca tekrar dene."
                : "\(trip.dates.count) günün \(live) günü için tahmin alındı."
            // The trip may have been deleted while the request was in flight.
            guard self.trip(id: tripID) != nil else { weatherStatus[tripID] = nil; return }
            if live > 0 { proposeReplan(tripID: tripID, weather: Dictionary(uniqueKeysWithValues: snapshots.map { ($0.localDate, $0) })) }
        } catch FaultCode.policyDenied {
            weatherStatus[tripID] = "Hava tahmini izni kapalı. Planın değişmedi."
        } catch {
            weatherStatus[tripID] = "Hava tahmini alınamadı. Planın değişmedi."
        }
    }

    /// Profil switch. Revoking runs the §112.3 chain: outstanding grants die, a response still in flight
    /// is discarded, cached forecasts stay until they expire.
    func setWeatherAllowed(_ allowed: Bool) async {
        if allowed { await gate.grantConsent(.weatherFetch) } else { await gate.revokeConsent(.weatherFetch) }
        let ledger = await gate.ledger
        weatherConsent = ledger.state(.weatherFetch)
        if !allowed { for id in weatherInFlight { weatherStatus[id] = "Hava tahmini izni kapatıldı." } }
        save([Records.consent.id]) { try await $0.put(ledger, Records.consent, schemaVersion: ConsentLedger.schemaVersion) }
    }

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
        weatherStatus[id] = nil
        persistTrips()
        save([Records.plan(id).id, Records.packing(id).id]) {
            // Deleting the plan also deletes the packing list derived from it.
            try await $0.delete(Records.plan(id).id)
            try await $0.delete(Records.packing(id).id)
        }
    }

    /// Wipes everything on this device (§11, §34). Separate from per-trip and passport deletion.
    func deleteAllData() {
        wardrobe = Wardrobe()
        passport = FitPassport()
        measurements = UserMeasurements()
        trips = []
        plans = [:]
        packingLists = [:]
        pendingReplans = [:]
        weatherStatus = [:]
        weatherConsent = .notAsked
        gate = CitadelGate(registry: .p0())
        // Explicit user request: this is the one path allowed to remove unreadable records too.
        unreadable = []
        loadError = nil
        guard let location else { return }
        let previous = lastSave
        lastSave = Task {
            await previous?.value
            do {
                let receipt: DeletionReceipt
                if let vault = self.vault {
                    let result = try await vault.deleteAll()
                    receipt = result.receipt
                    self.vault = result.fresh
                    // Plaintext files left from before v1.5 are ones that failed to migrate; the user asked for everything to go.
                    if let legacy = location.legacyDirectory { try? FileManager.default.removeItem(at: legacy) }
                } else {
                    // The vault could not be opened (lost key): reset it without reading it. Plaintext files that
                    // were never migrated are kept and moved into the new vault, since they are still readable.
                    try Vault.destroy(directory: location.directory, keyStore: location.keyStore)
                    receipt = DeletionReceipt(completedAt: Date(), scope: .everything, deletedCountsByType: [:], destroyedKeyCount: 1)
                    await self.openAndRead()
                }
                self.lastDeletionReceipt = receipt
            } catch {
                // The old instance is closed either way; leave none rather than a dead one. Relaunch reopens.
                self.vault = nil
                self.loadError = "Silme tamamlanamadı: \((error as? VaultError)?.faultCode.userMessage ?? "bilinmeyen hata")"
            }
        }
    }

    private func persistTrips() {
        let value = trips
        save([Records.trips.id]) { try await $0.put(value, Records.trips, schemaVersion: Trip.schemaVersion) }
    }

    private func persistPlan(_ tripID: String) {
        let plan = plans[tripID], list = packingLists[tripID]
        save([Records.plan(tripID).id, Records.packing(tripID).id]) {
            if let plan { try await $0.put(plan, Records.plan(tripID), schemaVersion: TripPlan.schemaVersion) }
            if let list { try await $0.put(list, Records.packing(tripID), schemaVersion: PackingList.schemaVersion) }
        }
    }

    private func save(_ records: [String], _ work: @escaping @Sendable (Vault) async throws -> Void) {
        let blocked = records.filter(unreadable.contains)
        guard blocked.isEmpty else {
            loadError = "\(blocked.joined(separator: ", ")) okunamadığı için değişiklik kaydedilmedi. Mevcut kayıt korunuyor."
            return
        }
        let previous = lastSave
        lastSave = Task {
            await previous?.value
            // Resolved when the save runs, not when it was queued: "delete everything" swaps the vault.
            guard let vault = self.vault else {
                self.loadError = "Şifreli kasa açık değil; değişiklik kaydedilmedi."
                return
            }
            do { try await work(vault) } catch {
                self.loadError = "Kaydedilemedi: \((error as? VaultError)?.faultCode.userMessage ?? "bilinmeyen hata")"
            }
        }
    }
}
