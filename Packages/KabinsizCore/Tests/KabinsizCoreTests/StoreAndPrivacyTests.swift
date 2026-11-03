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
        // Code patterns, not bare words, so comments may name a framework. `import WeatherKit` also matches
        // `@preconcurrency import WeatherKit`; ` WeatherKit.` matches `import struct WeatherKit.X`.
        let forbidden = ["URLSession", "import Network", "NWConnection", "NWListener", "NWBrowser", "NWEndpoint", "CFNetwork", "URLRequest",
                         "import WeatherKit", " WeatherKit.", "WeatherService",
                         "AsyncImage", "CLLocationManager", "CLGeocoder", "MKLocalSearch", "WKWebView", "openURL",
                         // EG-003: Look Around only through the gate, shown only by the home backdrop.
                         "MKLookAroundSceneRequest", "LookAroundPreview", "MKLookAroundSnapshotter",
                         // WP15-03: routes are fixed in SystemContracts; nothing else may add one or open URLs.
                         "EgressRoute(", "routes:", "UIApplication.shared.open"]
        // Egress register: full repo-relative paths, so a same-named file elsewhere gets no exemption.
        let weatherFile = "apps/ios/Kabinsiz/Services/AppleWeatherProvider.swift"
        let allowed: [String: Set<String>] = [
            weatherFile: ["import WeatherKit", "WeatherService", "AsyncImage"],
            "Packages/KabinsizCore/Sources/SystemContracts/CitadelGate.swift": ["EgressRoute(", "routes:"],
            // WP15-06: `NWPathMonitor` only reads whether a path exists (OFFLINE tier); it opens no connection.
            "apps/ios/Kabinsiz/Services/DeviceSignalMonitor.swift": ["import Network"],
            "apps/ios/Kabinsiz/Services/LookAroundProvider.swift": ["MKLookAroundSceneRequest"],
            "apps/ios/Kabinsiz/Features/World/HomeWorldView.swift": ["LookAroundPreview"],
            // UI28-T060: one reduced-accuracy fix on a tap, matched on device, never stored or sent.
            "apps/ios/Kabinsiz/Services/CoarseCityLocator.swift": ["CLLocationManager"],
        ]
        for file in files {
            let relative = String(file.standardizedFileURL.path.dropFirst(repo.standardizedFileURL.path.count + 1))
            let text = try String(contentsOf: file, encoding: .utf8)
            // Whitespace is removed before matching, so `routes :` or `EgressRoute .init(` cannot slip past.
            let compact = text.filter { !$0.isWhitespace }
            for word in forbidden where !(allowed[relative]?.contains(word) ?? false) {
                let needle = word.hasPrefix("import ") || word.hasPrefix(" ") ? word : word.filter { !$0.isWhitespace }
                #expect(!(needle == word ? text : compact).contains(needle), "\(relative) contains \(word)")
            }
            if !(allowed[relative]?.contains("EgressRoute(") ?? false) {
                #expect(!compact.contains("EgressRoute.init("), "\(relative) builds an EgressRoute")
            }
            if relative == "apps/ios/Kabinsiz/Services/CoarseCityLocator.swift" {
                #expect(compact.contains("kCLLocationAccuracyReduced"), "the locator asks for reduced accuracy")
                for leak in ["UserDefaults", "FileManager", "write(", "Logger", "print(", "requestTemporaryFullAccuracy", "startUpdatingLocation", "AlwaysAuthorization"] {
                    #expect(!compact.contains(leak), "the locator must not keep, log or widen the position: \(leak)")
                }
            }
            if relative == "apps/ios/Kabinsiz/Services/LookAroundProvider.swift" {
                let parts = compact.components(separatedBy: "MKLookAroundSceneRequest(")
                #expect(parts.count == 2, "\(relative): exactly one Look Around request")
                let before = parts.first ?? ""
                let sendStart = before.range(of: "gate.send(", options: .backwards)
                #expect(sendStart != nil, "\(relative): Look Around request must come after gate.send(")
                if let sendStart {
                    let span = before[sendStart.upperBound...]
                    #expect(span.filter { $0 == "{" }.count > span.filter { $0 == "}" }.count, "\(relative): Look Around request outside the transport closure")
                }
            }
            // The one exempt file must call WeatherKit only inside the gate's transport closure.
            if relative == weatherFile {
                let parts = compact.components(separatedBy: "WeatherService.shared.weather(")
                #expect(parts.count == 2, "\(relative): exactly one WeatherKit call")
                let before = parts.first ?? ""
                let sendStart = before.range(of: "gate.send(", options: .backwards)
                #expect(sendStart != nil, "\(relative): WeatherKit call must come after gate.send(")
                if let sendStart {
                    // Between `gate.send(` and the call, the closure is still open: more `{` than `}`.
                    let span = before[sendStart.upperBound...]
                    #expect(span.filter { $0 == "{" }.count > span.filter { $0 == "}" }.count, "\(relative): WeatherKit call outside the transport closure")
                }
            }
            // Only the user-tap handler builds the live provider (D-009).
            if relative != weatherFile {
                let uses = compact.components(separatedBy: "AppleWeatherProvider(").count - 1
                #expect(uses == 0 || (relative == "apps/ios/Kabinsiz/App/AppModel.swift" && uses == 1), "\(relative) creates AppleWeatherProvider")
            }
        }
    }

    @Test("Weather requests only ever use the bundled city centre, never a stored or device coordinate")
    func weatherUsesDirectoryOnly() throws {
        let barcelona = try #require(CityDirectory.search("Barselona").first { $0.country == "İspanya" })
        let center = try #require(CityDirectory.cityCenter(for: barcelona))
        #expect(abs(center.latitude - 41.39) < 0.05 && abs(center.longitude - 2.17) < 0.05)
        // Same city name, other country → other point; manual entries → none.
        let venezuela = try #require(CityDirectory.search("Barselona").first { $0.country == "Venezuela" })
        #expect(CityDirectory.cityCenter(for: venezuela) != center)
        #expect(CityDirectory.cityCenter(for: CityDirectory.manual(city: "Barselona", country: "İspanya")) == nil)
        // A saved trip carries no coordinate at all, so editing the file cannot inject one.
        let json = try #require(String(data: JSONEncoder().encode(barcelona), encoding: .utf8))
        #expect(!json.contains("lat") && !json.contains("center"))
        // Every bundled city has a centre.
        #expect(CityDirectory.entries.allSatisfy { CityDirectory.cityCenter(for: $0) != nil })
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
