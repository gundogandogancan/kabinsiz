import Foundation
@testable import LivingWorld
import Testing

/// v3.5 WP35-01 (city identity, three tiers) and WP35-03 (sun light, six weather states).
@Suite("City world: identity, tiers, sun, weather")
struct CityWorldTests {
    func id(_ name: String, _ cc: String, _ src: CityIdentitySource = .reverseGeocoded) -> CityIdentity {
        CityIdentity(name: name, countryCode: cc, timeZoneID: nil, source: src)
    }

    @Test("CITY-T01: no city means the neutral atelier, never a default city that is not the user's")
    func noCity() {
        let d = CitySceneResolver.resolve(nil)
        #expect(d.tier == .atelier && d.scene == .studio)
        #expect(CitySceneResolver.resolve(id("  ", "TR")).tier == .atelier)
    }

    @Test("CITY-T02: a curated city in its own country gets its owned street, whatever language names it")
    func curated() {
        for name in ["İstanbul", "istanbul", "ISTANBUL", "Istanbul"] {
            let d = CitySceneResolver.resolve(id(name, "tr"))
            #expect(d.tier == .curated && d.scene == .istanbul, "\(name)")
            #expect(d.placeName == name.trimmingCharacters(in: .whitespaces))
        }
        for name in ["Barcelona", "Barselona", "barcelona"] {
            #expect(CitySceneResolver.resolve(id(name, "ES")).scene == .barcelona, "\(name)")
        }
    }

    @Test("CITY-T03: wrong-country guard: a city of the same name elsewhere never gets the other street")
    func wrongCountry() {
        let d = CitySceneResolver.resolve(id("Barcelona", "VE"))
        #expect(d.tier == .atelier && d.scene == .studio)
        #expect(d.placeName == "Barcelona", "the chip still says where the user is")
        #expect(CitySceneResolver.resolve(id("Istanbul", "US")).tier == .atelier)
    }

    @Test("CITY-T04: a city with no street is drawn as the atelier under its real name")
    func atelierWithName() {
        let d = CitySceneResolver.resolve(id("Eskişehir", "TR"))
        #expect(d.tier == .atelier && d.placeName == "Eskişehir")
        #expect(d.reason.contains("Eskişehir") && d.reason.contains("atölye"))
        #expect(d.attribution == nil)
    }

    @Test("CITY-T05: tier B only when a built procedural street is bundled, and then with ODbL attribution")
    func procedural() {
        let city = id("Ankara", "TR")
        #expect(CitySceneResolver.bundledProcedural.isEmpty, "no OSM2World output ships in this build")
        #expect(CitySceneResolver.resolve(city).tier == .atelier)
        let d = CitySceneResolver.resolve(city, procedural: [CitySceneResolver.proceduralKey(city)])
        #expect(d.tier == .procedural)
        #expect(d.attribution?.contains("OpenStreetMap") == true && d.attribution?.contains("ODbL") == true)
        // Curated wins over procedural for the same city.
        let ist = id("İstanbul", "TR")
        #expect(CitySceneResolver.resolve(ist, procedural: [CitySceneResolver.proceduralKey(ist)]).tier == .curated)
    }

    @Test("CITY-T06: every catalogue city resolves; only the owned ones are curated")
    func catalogue() {
        for street in FamousStreetCatalog.all {
            let d = CitySceneResolver.resolve(CityIdentity(street: street, source: .catalogue))
            #expect(d.tier == (street.ownedScene == nil ? .atelier : .curated), "\(street.city)")
            #expect(d.placeName == street.city)
        }
    }

    @Test("CITY-T07: an identity stores no position")
    func noPosition() throws {
        let json = String(decoding: try JSONEncoder().encode(id("Ankara", "TR")), as: UTF8.self)
        #expect(!json.contains("lat") && !json.contains("lon"))
    }

    // MARK: Sun

    func date(_ iso: String) -> Date { ISO8601DateFormatter().date(from: iso)! }

    @Test("SUN-T01: known sun heights (NOAA): equator noon at equinox, Istanbul summer noon, midnight below")
    func knownElevations() {
        // March equinox 2026 is 20 March; solar noon at 0° longitude ≈ 12:07 UTC.
        #expect(abs(SolarPosition.elevation(at: date("2026-03-20T12:07:00Z"), latitude: 0, longitude: 0) - 90) < 1.5)
        // Istanbul (41.0 N, 29.0 E) at the June solstice, solar noon ≈ 10:04 UTC: 90 - 41 + 23.44 ≈ 72.4°.
        #expect(abs(SolarPosition.elevation(at: date("2026-06-21T10:04:00Z"), latitude: 41.0082, longitude: 28.9784) - 72.4) < 1.0)
        // Istanbul at local midnight in winter: well below the horizon.
        #expect(SolarPosition.elevation(at: date("2026-12-21T21:00:00Z"), latitude: 41.0082, longitude: 28.9784) < -40)
    }

    @Test("SUN-T02: the light phase follows the day: night, twilight, golden hour, day")
    func phases() {
        let lat = 41.0082, lon = 28.9784
        #expect(LightPhase.at(date("2026-11-04T10:00:00Z"), latitude: lat, longitude: lon) == .day)
        #expect(LightPhase.at(date("2026-11-04T23:00:00Z"), latitude: lat, longitude: lon) == .night)
        // Sunset in Istanbul on 4 Nov is ≈ 14:15 UTC (17:15 local).
        let around = (0..<120).map { LightPhase.at(date("2026-11-04T13:30:00Z").addingTimeInterval(Double($0) * 60), latitude: lat, longitude: lon) }
        #expect(around.contains(.goldenHour) && around.contains(.twilight))
        #expect(LightPhase.from(elevation: 10) == .day && LightPhase.from(elevation: 2) == .goldenHour)
        #expect(LightPhase.from(elevation: -3) == .twilight && LightPhase.from(elevation: -12) == .night)
    }

    @Test("SUN-T03: polar night and midnight sun (Tromsø 69.65 N)")
    func polar() {
        let noonDec = SolarPosition.elevation(at: date("2026-12-21T10:40:00Z"), latitude: 69.6492, longitude: 18.9553)
        #expect(noonDec < 0, "no sunrise in December: \(noonDec)")
        let midnightJune = SolarPosition.elevation(at: date("2026-06-21T22:40:00Z"), latitude: 69.6492, longitude: 18.9553)
        #expect(midnightJune > 0, "sun above the horizon at midnight in June: \(midnightJune)")
    }

    @Test("SUN-T04: darker phases never light the figure brighter than day")
    func lightOrder() {
        let keys = [LightPhase.day, .goldenHour, .twilight, .night].map(\.stageLight.key)
        #expect(keys == keys.sorted(by: >))
    }

    // MARK: Weather

    @Test("WX-T01: six conditions; each preview is drawn and labelled as a preview")
    func previews() {
        #expect(SceneCondition.allCases.count == 6)
        for c in SceneCondition.allCases {
            let s = SceneWeatherState.from(.userPreview(c))
            #expect(s.isPreview && s.label.contains("önizlemesi") && s.label.contains("gerçek hava değil"), "\(c)")
            #expect(s.drawn == c)
        }
    }

    @Test("WX-T02: each condition draws only its own effect; wind is environment only")
    func effects() {
        let rain = SceneWeatherState.from(.userPreview(.rain))
        #expect(rain.rainIntensity == 1 && rain.wetGround && rain.snowIntensity == 0)
        let snow = SceneWeatherState.from(.userPreview(.snow))
        #expect(snow.snowIntensity == 1 && snow.rainIntensity == 0 && !snow.wetGround)
        let cloud = SceneWeatherState.from(.userPreview(.cloudy))
        #expect(cloud.cloudCover > 0.5 && cloud.rainIntensity == 0 && cloud.windStrength == 0)
        let fog = SceneWeatherState.from(.userPreview(.fog))
        #expect(fog.fogDensity == 1 && fog.rainIntensity == 0)
        let wind = SceneWeatherState.from(.userPreview(.wind))
        #expect(wind.windStrength == 1 && wind.rainIntensity == 0 && wind.snowIntensity == 0)
        let clear = SceneWeatherState.from(.userPreview(.clear))
        #expect(clear.cloudCover == 0 && clear.windStrength == 0 && clear.rainIntensity == 0)
    }

    @Test("WX-T03: no data, stale data and a bare probability draw nothing")
    func nothingWithoutEvidence() {
        let now = Date()
        for s in [SceneWeatherState.from(.none),
                  .from(.observed(.snow, source: "Test", at: now.addingTimeInterval(-4 * 3600)), now: now),
                  .from(.probability(rainPercent: 90, source: "Test", at: now), now: now)] {
            #expect(s.drawn == nil && s.rainIntensity == 0 && s.snowIntensity == 0 && s.windStrength == 0 && s.fogDensity == 0)
        }
        let live = SceneWeatherState.from(.observed(.snow, source: "Test", at: now.addingTimeInterval(-600)), now: now)
        #expect(live.drawn == .snow && !live.isPreview && live.label.contains("Kar") && live.label.contains("Test"))
    }

    @Test("WX-T04: conditions written before v3.5 still decode")
    func legacyDecode() throws {
        #expect(try JSONDecoder().decode(SceneCondition.self, from: Data("\"RAIN\"".utf8)) == .rain)
        #expect(try JSONDecoder().decode(SceneCondition.self, from: Data("\"CLEAR\"".utf8)) == .clear)
    }
}
