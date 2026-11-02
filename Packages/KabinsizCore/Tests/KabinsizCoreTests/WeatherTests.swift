import Foundation
import Testing
@testable import TravelEngine
import WardrobeDomain

@Suite("Weather evidence")
struct WeatherTests {
    let start = LocalDate("2026-11-10")!
    let barcelona = CityDirectory.entries[0]

    @Test("T-TRV-019 days outside the fixture horizon are NO_DATA, never invented")
    func horizon() async {
        let provider = DemoTrip.syntheticWeather(start: start)
        let days = (0..<5).map { start.adding(days: $0) }
        let snaps = await provider.snapshots(for: barcelona, dates: days)
        #expect(snaps.prefix(3).allSatisfy { $0.evidence == .liveForecast && $0.isSynthetic })
        #expect(snaps.suffix(2).allSatisfy { $0.evidence == .noData && $0.lowC == nil && $0.highC == nil })
    }

    @Test("T-TRV-021 default provider returns NO_DATA with no numbers")
    func noDataProvider() async {
        let snaps = await NoDataWeatherProvider().snapshots(for: barcelona, dates: [start])
        #expect(snaps.first?.evidence == .noData)
        #expect(snaps.first?.chipText == "Hava verisi yok")
        #expect(snaps.first?.needsWarmLayer == nil)
    }

    @Test("T-TRV-018 expired forecast is relabelled as cached, not live")
    func stale() {
        let snap = WeatherSnapshot(localDate: start, evidence: .liveForecast, validUntil: Date(timeIntervalSince1970: 100), lowC: 10, highC: 15)
        #expect(snap.aged(now: Date(timeIntervalSince1970: 200)).evidence == .cachedForecast)
        #expect(snap.aged(now: Date(timeIntervalSince1970: 50)).evidence == .liveForecast)
    }

    @Test("Review #5: cached and seasonal numbers always carry their label")
    func labelledNumbers() {
        let date = LocalDate("2026-11-10")!
        let cached = WeatherSnapshot(localDate: date, evidence: .cachedForecast, provider: "X", lowC: 8, highC: 14)
        let seasonal = WeatherSnapshot(localDate: date, evidence: .seasonalGuidance, provider: "X", lowC: 8, highC: 14)
        let live = WeatherSnapshot(localDate: date, evidence: .liveForecast, provider: "X", lowC: 8, highC: 14)
        #expect(cached.chipText.hasPrefix("Son bilinen tahmin"))
        #expect(seasonal.chipText.hasPrefix("Mevsimsel beklenti"))
        #expect(live.chipText == "8–14 °C")
    }

    @Test("Review #5: a saved plan re-ages its weather at display time")
    func displayReAges() async throws {
        let start = LocalDate("2026-11-10")!
        let validUntil = Date(timeIntervalSince1970: 1_000)
        let day = WeatherSnapshot(localDate: start, evidence: .liveForecast, provider: "X", validUntil: validUntil, lowC: 8, highC: 14)
        let trip = DemoTrip.barcelona(start: start)
        let result = await TripPlanner(weather: FixtureWeatherProvider([day])).plan(trip: trip, wardrobe: SyntheticCloset.demo, now: Date(timeIntervalSince1970: 500))
        let slot = try #require(result.plan.slots.first { $0.localDate == start })
        #expect(slot.weather.evidence == .liveForecast)
        #expect(result.plan.displayWeather(for: slot, now: Date(timeIntervalSince1970: 2_000)).evidence == .cachedForecast)
    }

    @Test("T-TRV-025 negative temperatures survive encoding; unknown is not 0")
    func negativeAndUnknown() throws {
        let cold = FixtureWeatherProvider.day(start, low: -7, high: -1)
        let back = try JSONDecoder().decode(WeatherSnapshot.self, from: JSONEncoder().encode(cold))
        #expect(back.lowC == -7)
        #expect(back.chipText.hasPrefix("-7–-1 °C"))
        let unknown = try JSONDecoder().decode(WeatherSnapshot.self, from: JSONEncoder().encode(WeatherSnapshot.noData(start)))
        #expect(unknown.lowC == nil)
        let json = String(decoding: try JSONEncoder().encode(WeatherSnapshot.noData(start)), as: UTF8.self)
        #expect(!json.contains("lowC"))
    }

    @Test("T-TRV-030 provider returning shuffled or extra dates does not mix days")
    func shuffledOrder() async {
        struct Shuffled: WeatherProvider {
            let name = "TEST"
            let start: LocalDate
            func snapshots(for destination: Destination, dates: [LocalDate]) async -> [WeatherSnapshot] {
                [FixtureWeatherProvider.day(start.adding(days: 1), low: 1, high: 2),
                 FixtureWeatherProvider.day(start.adding(days: 30), low: 30, high: 35),
                 FixtureWeatherProvider.day(start, low: 10, high: 12)]
            }
        }
        let trip = Trip(id: "t", title: "t", destination: barcelona, dates: [start, start.adding(days: 1)], events: [], policy: .init(), isSyntheticDemo: true)
        let result = await TripPlanner(weather: Shuffled(start: start)).plan(trip: trip, wardrobe: .init())
        let byDate = Dictionary(uniqueKeysWithValues: result.plan.slots.map { ($0.localDate, $0.weather.lowC) })
        #expect(byDate[start] == 10)
        #expect(byDate[start.adding(days: 1)] == 1)
    }
}
