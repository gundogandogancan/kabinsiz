import BodyGeometry
import DomainContracts
import FitPassport
import Foundation
import LivingWorld
import LocalStore
import Observation
import Octopus
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
    /// Pre-WP15-05 chest/waist record. Only read once, to move its values into the body profile.
    static let legacyMeasurements = VaultRecordSpec(id: "measurements", type: "measurements", domain: .body, classification: .localSensitive)
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
    /// Committed body truth (OCT-07), mirrored from the studio after every commit. Nil = no body yet.
    private(set) var body: BodyProfile?
    private(set) var bodyStatus: BodyStudio.Status = .noProfile
    /// What the screen draws; replaced by every preview and commit.
    private(set) var bodyScene: PreviewScene?
    private(set) var bodyLimitations: [String] = []
    private(set) var bodyMessage: String?
    private(set) var canUndoBody = false
    private(set) var canRedoBody = false
    private(set) var lastBodyDeletionReceipt: DeletionReceipt?
    private var bodyStudio: BodyStudio?
    /// The single §113 governor: thermal, Low Power, memory, lock and network decide what may run.
    let governor = DeviceResourceGovernor()
    private var deviceMonitor: DeviceSignalMonitor?
    /// One calm sentence when the phone limits work (hot, low memory, offline); nil otherwise. No numbers.
    private(set) var deviceNote: String?
    /// §116.1 DerivedEphemeral scratch space; swept at launch so a killed import leaves no plaintext.
    private(set) var ephemeral: EphemeralArea?
    /// Bumped by every commit, undo, redo, delete and reload. A preview started under an older generation is
    /// dropped when it returns, so it can never repaint over newer truth (§105.3).
    private var bodyGeneration = 0
    /// Size advice reads typed measurements only; slider shapes and starting values never reach it (§123 A.5).
    var measurements: UserMeasurements {
        let measured = body?.measuredCentimeters ?? [:]
        return UserMeasurements(chestCm: measured[.chest], waistCm: measured[.waist])
    }
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
        ledger.revoke(.streetImagery)
        return ledger
    }
    private var loadStarted = false
    /// Whether the user allows forecast requests at all (Profil → Gizlilik). Off stops even the tap.
    private(set) var weatherConsent: ConsentState = .notAsked
    /// Whether the home may show Apple Look Around street photos (city sheet switch). Off = owned scene.
    private(set) var streetImageryConsent: ConsentState = .notAsked
    /// True once the gate has been rebuilt from the stored ledger (or loading gave up and it stays closed).
    /// Until then a network feature must wait, not report "off": the closed start ledger is not the user's choice.
    private(set) var consentLoaded = false
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
            startDeviceGovernor()
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
            // The gate stays on the closed ledger: network features report "off", honestly.
            consentLoaded = true
            return
        }
        self.vault = vault
        if let legacy = location.legacyDirectory { await migrateLegacy(from: legacy, into: vault) }

        wardrobe = await read(Wardrobe.self, Records.wardrobe, Wardrobe.schemaVersion, from: vault) ?? Wardrobe()
        passport = await read(FitPassport.self, Records.passport, FitPassport.schemaVersion, from: vault) ?? FitPassport()
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
        streetImageryConsent = ledger.state(.streetImagery)
        consentLoaded = true
        await openBodyStudio(vault: vault)
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
        await move(UserMeasurements.self, 1, Records.legacyMeasurements)
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
        let value = passport
        save([Records.passport.id]) { try await $0.put(value, Records.passport, schemaVersion: FitPassport.schemaVersion) }
    }

    /// Clears try-on history only. The body profile has its own delete (V15-T-BOD-10).
    func resetPassport() {
        passport.reset()
        persistPassport()
    }

    // MARK: Device (§113)

    private func startDeviceGovernor() {
        let monitor = DeviceSignalMonitor(governor: governor)
        deviceMonitor = monitor
        governor.observe { [weak self] decision in
            Task { @MainActor in self?.deviceNote = decision.userNote }
        }
        monitor.start()
        deviceNote = governor.decision.userNote
        if let root = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Kabinsiz-ephemeral", isDirectory: true) {
            ephemeral = try? EphemeralArea(root: root) { EphemeralArea.systemFreeSpace(at: root) }
            ephemeral?.sweepOrphans()
        }
    }

    /// Body writes wait while the phone is locked instead of failing half-way (V15-T-DEV-10).
    private func untilVaultReachable() async {
        try? await governor.untilProtectedDataAvailable()
    }

    // MARK: Body (§133 step 5: slider → revision → preview → local save)

    private func currentVault() -> Vault? { vault }

    private func openBodyStudio(vault: Vault) async {
        let store = VaultBodyStore { [weak self] in await self?.currentVault() }
        let coordinator = OctopusCoordinator(registry: .p0(), governor: governor)
        // Only rebuildable work is evictable; the studio's pending commits and undo history never are.
        governor.registerEvictable("octopus.coalesced") { await coordinator.evictCaches() }
        let studio = BodyStudio(coordinator: coordinator, store: store)
        bodyStudio = studio
        await studio.load()
        await migrateLegacyMeasurements(into: studio, vault: vault)
        await syncBody(from: studio)
        await redrawCommitted(studio)
    }

    /// Draws the committed body through the coordinator, so the device budget picks the detail (BOD-08).
    private func redrawCommitted(_ studio: BodyStudio) async {
        guard let envelope = await studio.currentScene() else { bodyScene = nil; return }
        bodyScene = envelope.value
        bodyLimitations = envelope.limitations
    }

    /// The old chest/waist record becomes typed measurements on a neutral body, then is removed. Values
    /// outside the safe range are not invented into range; they are dropped and the user is told.
    private func migrateLegacyMeasurements(into studio: BodyStudio, vault: Vault) async {
        guard await vault.contains(Records.legacyMeasurements.id) else { return }
        guard await studio.status == .noProfile,
              let old = try? await vault.get(UserMeasurements.self, id: Records.legacyMeasurements.id, currentVersion: 1)
        else { return } // unreadable or a body already exists: leave the old record for the user to decide
        let values: [(BodyParameter, Double)] = [(.chest, old.chestCm), (.waist, old.waistCm)].compactMap { p, v in v.map { (p, $0) } }
        // Out of range is decided here, before anything is written; any other failure keeps the old record.
        let neutral = BodyProfile.neutral()
        let valid = values.filter { (try? neutral.applying(.measured($0.0, $0.1, .centimeters))) != nil }
        let dropped = valid.count < values.count
        if !valid.isEmpty {
            guard await studio.createNeutral().value != nil else { return }
            for (p, cm) in valid where await studio.commit(.measured(p, cm, .centimeters)).value == nil { return }
        }
        do { _ = try await vault.delete(Records.legacyMeasurements.id) } catch { return }
        if dropped { bodyMessage = "Eski ölçülerinden biri güvenli aralığın dışındaydı ve taşınmadı." }
    }

    private func syncBody(from studio: BodyStudio) async {
        body = await studio.profile
        bodyStatus = await studio.status
        canUndoBody = await studio.canUndo
        canRedoBody = await studio.canRedo
        if bodyStatus == .unreadable {
            bodyMessage = "Kayıtlı vücut profili okunamadı. Silinmedi ve üzerine yazılmayacak; istersen silebilirsin."
        }
    }

    private func apply(_ envelope: DecisionEnvelope<PreviewScene>?, from studio: BodyStudio) async {
        bodyGeneration += 1
        await syncBody(from: studio)
        guard let envelope else { return }
        if let scene = envelope.value {
            bodyScene = scene
            bodyLimitations = envelope.limitations
            bodyMessage = nil
        } else if let fault = envelope.fault {
            bodyMessage = fault == .storageCorrupted
                ? "Vücut profili şu an değiştirilemiyor. Hiçbir şey kaydedilmedi."
                : "Bu değer kaydedilmedi: \(fault.userMessage)"
            await redrawCommitted(studio)
        }
    }

    /// The figure the home and "Ben" screens show. The user's own committed body when there is one;
    /// before that, a neutral stand-in computed from `BodyProfile.neutral()` and never saved, so the
    /// first screen already shows a model without asking for any data. nil when the device budget
    /// allows 2D only (UI20-T-014): the caller then shows its 2D fallback.
    var heroMesh: BodyMesh? {
        guard governor.budget.maxVisualTier != .flat2D else { return nil }
        if bodyStatus == .ready { return bodyScene?.mesh }
        return Self.neutralStandIn
    }

    /// True while the figure on screen is the unsaved neutral stand-in, not the user's body.
    var heroIsStandIn: Bool { bodyStatus != .ready }

    /// The body the home world dresses: the user's own when it is ready, else the neutral stand-in.
    var heroSnapshot: AvatarSnapshot? {
        guard governor.budget.maxVisualTier != .flat2D else { return nil }
        if bodyStatus == .ready, let body, let snapshot = try? AvatarSnapshot.make(for: body) { return snapshot }
        return Self.neutralSnapshot
    }

    private static let neutralSnapshot: AvatarSnapshot? = try? AvatarSnapshot.make(for: .neutral())

    /// Idle breathing/sway only when the budget has headroom (no thermal or Low Power note).
    var allowsLivelyMotion: Bool { deviceNote == nil && governor.budget.maxVisualTier != .flat2D }

    private static let neutralStandIn: BodyMesh? = {
        guard let snapshot = try? AvatarSnapshot.make(for: .neutral()) else { return nil }
        return try? BodyMesh.make(from: snapshot)
    }()

    func createNeutralBody(unit: LengthUnit) async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        await apply(await studio.createNeutral(unit: unit), from: studio)
    }

    /// Live drag: latest-wins, nothing saved. A superseded preview changes nothing on screen.
    func previewBody(_ edit: BodyEdit) async {
        guard let studio = bodyStudio else { return }
        let generation = bodyGeneration
        guard let envelope = await studio.preview(edit), let scene = envelope.value,
              generation == bodyGeneration, bodyStatus == .ready else { return }
        bodyScene = scene
        bodyLimitations = envelope.limitations
    }

    func commitBody(_ edit: BodyEdit) async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        await apply(await studio.commit(edit), from: studio)
    }

    func undoBody() async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        await apply(await studio.undo(), from: studio)
    }

    func redoBody() async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        await apply(await studio.redo(), from: studio)
    }

    func setBodyUnit(_ unit: LengthUnit) async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        await apply(await studio.setUnit(unit), from: studio)
    }

    func deleteBody() async {
        guard let studio = bodyStudio else { return }
        await untilVaultReachable()
        bodyGeneration += 1
        switch await studio.deleteProfile() {
        case .success(let receipt):
            lastBodyDeletionReceipt = receipt
            bodyScene = nil
            bodyLimitations = []
            bodyMessage = nil
        case .failure(let fault):
            bodyMessage = "Vücut profili silinemedi: \(fault.userMessage)"
        }
        await syncBody(from: studio)
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

    /// EG-003, on a user choice of a world street (or opening the home with one chosen while allowed).
    func lookAroundScene(for street: FamousStreet) async throws -> LookAroundSceneBox? {
        try await LookAroundProvider(gate: gate).scene(for: street)
    }

    /// City sheet switch "Cadde fotoğrafı". Revoking stops further requests and the home falls back
    /// to the owned 3D street or the studio (§112.3 chain FALL_BACK_TO_OWNED_SCENE).
    func setStreetImageryAllowed(_ allowed: Bool) async {
        if allowed { await gate.grantConsent(.streetImagery) } else { await gate.revokeConsent(.streetImagery) }
        let ledger = await gate.ledger
        streetImageryConsent = ledger.state(.streetImagery)
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
        // The morning plan and the day's lock name garments too: destroy their key and files.
        MorningStore.eraseAll()
        NotificationCenter.default.post(name: .kabinsizDidDeleteAll, object: nil)
        wardrobe = Wardrobe()
        passport = FitPassport()
        body = nil
        bodyScene = nil
        bodyLimitations = []
        bodyMessage = nil
        canUndoBody = false
        canRedoBody = false
        lastBodyDeletionReceipt = nil
        trips = []
        plans = [:]
        packingLists = [:]
        pendingReplans = [:]
        weatherStatus = [:]
        weatherConsent = .notAsked
        streetImageryConsent = .notAsked
        gate = CitadelGate(registry: .p0())
        // Explicit user request: this is the one path allowed to remove unreadable records too.
        unreadable = []
        loadError = nil
        guard let location else { return }
        let previous = lastSave
        let studio = bodyStudio
        lastSave = Task {
            await previous?.value
            // Body commits run in the studio's own queue: close it first so none lands in the fresh vault.
            await studio?.close()
            do {
                let receipt: DeletionReceipt
                if let vault = self.vault {
                    let result = try await vault.deleteAll()
                    receipt = result.receipt
                    self.vault = result.fresh
                    // Plaintext files left from before v1.5 are ones that failed to migrate; the user asked for everything to go.
                    if let legacy = location.legacyDirectory { try? FileManager.default.removeItem(at: legacy) }
                    if let studio {
                        self.bodyGeneration += 1
                        await studio.load()
                        await self.syncBody(from: studio)
                    }
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

extension Notification.Name {
    /// Posted when the user deletes everything, so views holding derived personal data drop it.
    static let kabinsizDidDeleteAll = Notification.Name("app.kabinsiz.didDeleteAll")
}
