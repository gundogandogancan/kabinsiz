import DomainContracts
import FitPassport
import Foundation
import Testing
@testable import LocalStore
@testable import TravelEngine
@testable import WardrobeDomain

@Suite("Local store and privacy boundaries")
struct StoreAndPrivacyTests {
    func tempStore() throws -> LocalStore {
        try LocalStore(directory: FileManager.default.temporaryDirectory.appendingPathComponent("kabinsiz-test-\(UUID().uuidString)"))
    }

    @Test("T-TRV-011 trip, plan and packing list survive a fresh store instance")
    func roundTrip() async throws {
        let store = try tempStore()
        let start = LocalDate("2026-11-10")!
        let trip = DemoTrip.barcelona(start: start)
        let result = await TripPlanner(weather: DemoTrip.syntheticWeather(start: start)).plan(trip: trip, wardrobe: SyntheticCloset.demo)
        try await store.save([trip], as: "trips", schemaVersion: Trip.schemaVersion)
        try await store.save(result.plan, as: "plan-demo", schemaVersion: TripPlan.schemaVersion)
        try await store.save(result.packingList, as: "packing-demo", schemaVersion: PackingList.schemaVersion)

        let reopened = try LocalStore(directory: store.directory)
        let trips = try await reopened.load([Trip].self, from: "trips", currentVersion: Trip.schemaVersion)
        let plan = try await reopened.load(TripPlan.self, from: "plan-demo", currentVersion: TripPlan.schemaVersion)
        #expect(trips == [trip])
        #expect(plan == result.plan)
    }

    @Test("Newer schema is refused, not overwritten")
    func newerSchema() async throws {
        let store = try tempStore()
        try await store.save(Wardrobe(), as: "wardrobe", schemaVersion: 99)
        await #expect(throws: LocalStoreError.newerSchema(found: 99, supported: 1)) {
            _ = try await store.load(Wardrobe.self, from: "wardrobe", currentVersion: 1)
        }
        #expect(await store.exists(collection: "wardrobe"))
    }

    @Test("T-V13-055 older schema goes through the migration closure")
    func migration() async throws {
        let store = try tempStore()
        struct V0: Codable, Sendable { let names: [String] }
        try await store.save(V0(names: ["a"]), as: "legacy", schemaVersion: 0)
        let migrated = try await store.load([String].self, from: "legacy", currentVersion: 1) { version, data in
            #expect(version == 0)
            struct Env: Decodable { let payload: V0 }
            return try JSONDecoder().decode(Env.self, from: data).payload.names
        }
        #expect(migrated == ["a"])
    }

    @Test("Corrupted file is reported, not silently emptied")
    func corrupted() async throws {
        let store = try tempStore()
        try Data("not json".utf8).write(to: store.directory.appendingPathComponent("wardrobe.json"))
        await #expect(throws: LocalStoreError.corrupted("wardrobe")) {
            _ = try await store.load(Wardrobe.self, from: "wardrobe", currentVersion: 1)
        }
    }

    @Test("T-TRV-013 deleting a trip leaves the wardrobe and passport files intact")
    func deleteIsolation() async throws {
        let store = try tempStore()
        try await store.save(SyntheticCloset.demo, as: "wardrobe", schemaVersion: Wardrobe.schemaVersion)
        try await store.save(FitPassport(), as: "fit-passport", schemaVersion: FitPassport.schemaVersion)
        try await store.save([DemoTrip.barcelona(start: LocalDate("2026-11-10")!)], as: "trips", schemaVersion: 1)
        try await store.save("x", as: "weather-demo-barcelona", schemaVersion: 1)
        try await store.delete(collection: "trips")
        try await store.delete(collection: "weather-demo-barcelona")
        #expect(try await store.load(Wardrobe.self, from: "wardrobe", currentVersion: 1) == SyntheticCloset.demo)
        #expect(await store.exists(collection: "fit-passport"))
        #expect(!(await store.exists(collection: "weather-demo-barcelona")))
    }

    @Test("T-TRV-087 / T-V13-057 core modules contain no networking code")
    func staticEgress() throws {
        let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let repo = package.deletingLastPathComponent().deletingLastPathComponent()
        // Package sources and the iOS app sources (review #14): nothing on device may phone home.
        let roots = [package.appendingPathComponent("Sources"), repo.appendingPathComponent("apps/ios/Kabinsiz")]
        let files = roots.flatMap { root in
            (FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?.compactMap { $0 as? URL } ?? []).filter { $0.pathExtension == "swift" }
        }
        #expect(files.count > 10)
        #expect(files.contains { $0.path.contains("apps/ios/Kabinsiz") }, "app sources were not scanned")
        let forbidden = ["URLSession", "import Network", "NWConnection", "CFNetwork", "URLRequest"]
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for word in forbidden { #expect(!text.contains(word), "\(file.lastPathComponent) contains \(word)") }
        }
    }

    @Test("T-V13-018 fit passport fields do not appear in the product catalog contract")
    func passportNotInCatalog() throws {
        let catalog = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Sources/ShoppingCopilot/Catalog.swift")
        let text = try String(contentsOf: catalog, encoding: .utf8)
        for field in ["FitObservation", "markedSize", "UserMeasurements", "observedOutcome"] {
            #expect(!text.contains(field))
        }
    }
}
